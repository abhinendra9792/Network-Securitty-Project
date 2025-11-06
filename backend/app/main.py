import os
import asyncio
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse
from typing import List

from . import db
from .schemas import Event
from .honeypot import start_honeypot

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# in-memory queue for real-time events
event_queue: asyncio.Queue = asyncio.Queue()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Starting Remote Access Honeypot Backend...")
    await db.init_db()
    logger.info("Database initialized")
    
    # Start honeypot background task
    honeypot_task = asyncio.create_task(start_honeypot(event_queue))
    logger.info("Honeypot TCP servers started on ports 2222, 3389")
    
    yield
    
    # Shutdown
    honeypot_task.cancel()
    logger.info("Honeypot stopped")

app = FastAPI(title="Remote Access Honeypot Backend", lifespan=lifespan)

@app.get("/events")
async def get_events(limit: int = 50):
    rows = await db.fetch_events(limit=limit)
    return JSONResponse(rows)

class WebSocketManager:
    def __init__(self):
        self.active: List[WebSocket] = []

    async def connect(self, ws: WebSocket):
        await ws.accept()
        self.active.append(ws)

    def disconnect(self, ws: WebSocket):
        try:
            self.active.remove(ws)
        except ValueError:
            pass

    async def broadcast(self, message: dict):
        living = []
        for ws in list(self.active):
            try:
                await ws.send_json(message)
                living.append(ws)
            except Exception:
                # drop dead websockets
                pass
        self.active = living

ws_manager = WebSocketManager()

@app.websocket("/ws/events")
async def websocket_events(ws: WebSocket):
    await ws_manager.connect(ws)
    try:
        # spin a loop sending events from the queue to this client
        while True:
            # get next event (wait)
            event = await event_queue.get()
            await ws.send_json(event)
    except WebSocketDisconnect:
        ws_manager.disconnect(ws)
    except Exception:
        ws_manager.disconnect(ws)
