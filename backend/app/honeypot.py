import asyncio
import os
import logging
from datetime import datetime
from typing import Dict

from . import db

logger = logging.getLogger(__name__)
PAYLOAD_PREVIEW_BYTES = int(os.getenv("PAYLOAD_PREVIEW_BYTES", "1024"))

async def handle_client(reader: asyncio.StreamReader, writer: asyncio.StreamWriter, event_queue: asyncio.Queue):
    peer = writer.get_extra_info("peername") or ("unknown", 0)
    src_ip, src_port = peer[0], peer[1]
    dest_port = writer.get_extra_info("sockname")[1]
    
    logger.info(f"[THREAT DETECTED] Connection from {src_ip}:{src_port} to port {dest_port}")

    try:
        # read a small amount (non-blocking with timeout)
        data = await asyncio.wait_for(reader.read(PAYLOAD_PREVIEW_BYTES), timeout=5.0)
    except asyncio.TimeoutError:
        data = b""
    except Exception:
        data = b""

    payload_preview = None
    try:
        payload_preview = data.decode("utf-8", errors="replace")[:PAYLOAD_PREVIEW_BYTES]
    except Exception:
        payload_preview = repr(data[:200])

    event = {
        "ts": datetime.utcnow().isoformat() + "Z",
        "src_ip": src_ip,
        "src_port": src_port,
        "dest_port": dest_port,
        "protocol": "tcp",
        "payload_preview": payload_preview,
    }

    # persist to DB (best-effort)
    try:
        event_id = await db.insert_event(event)
        logger.info(f"[EVENT {event_id}] Logged attack: {src_ip}:{src_port} -> port {dest_port}, payload: {payload_preview[:50]}")
    except Exception as e:
        logger.error(f"Failed to insert event: {e}")

    # push to queue for real-time broadcast
    try:
        await event_queue.put(event)
    except Exception as e:
        logger.error(f"Failed to queue event: {e}")

    # respond with a minimal banner (harmless) and close
    try:
        writer.write(b"\n")
        await writer.drain()
    except Exception:
        pass

    try:
        writer.close()
        await writer.wait_closed()
    except Exception:
        pass

async def start_honeypot(event_queue: asyncio.Queue, ports=None):
    if ports is None:
        ports = os.getenv("HONEYPOT_PORTS", "2222,3389")
    if isinstance(ports, str):
        ports = [int(p.strip()) for p in ports.split(",") if p.strip()]

    servers = []
    for port in ports:
        try:
            server = await asyncio.start_server(
                lambda r, w: handle_client(r, w, event_queue), 
                host="0.0.0.0", 
                port=port
            )
            servers.append(server)
            logger.info(f"✓ Honeypot listening on 0.0.0.0:{port}")
        except Exception as e:
            logger.error(f"✗ Failed to start honeypot on port {port}: {e}")

    # keep running until cancelled
    try:
        await asyncio.gather(*[s.serve_forever() for s in servers])
    except asyncio.CancelledError:
        logger.info("Honeypot servers shutting down...")
        for server in servers:
            server.close()
            await server.wait_closed()
