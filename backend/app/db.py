import os
import aiosqlite
import asyncio
from typing import Dict, Any, List

DB_PATH = os.getenv("DB_PATH", "./honeypot_events.db")

_init_lock = asyncio.Lock()

async def init_db() -> None:
    async with _init_lock:
        # create DB if not exists
        async with aiosqlite.connect(DB_PATH) as db:
            await db.execute(
                """
                CREATE TABLE IF NOT EXISTS events (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    ts TEXT NOT NULL,
                    src_ip TEXT,
                    src_port INTEGER,
                    dest_port INTEGER,
                    protocol TEXT,
                    payload_preview TEXT
                )
                """
            )
            await db.commit()

async def insert_event(event: Dict[str, Any]) -> int:
    async with aiosqlite.connect(DB_PATH) as db:
        cur = await db.execute(
            "INSERT INTO events (ts, src_ip, src_port, dest_port, protocol, payload_preview) VALUES (?, ?, ?, ?, ?, ?)",
            (event.get("ts"), event.get("src_ip"), event.get("src_port"), event.get("dest_port"), event.get("protocol"), event.get("payload_preview")),
        )
        await db.commit()
        return cur.lastrowid or 0

async def fetch_events(limit: int = 50) -> List[Dict[str, Any]]:
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        cur = await db.execute("SELECT id, ts, src_ip, src_port, dest_port, protocol, payload_preview FROM events ORDER BY id DESC LIMIT ?", (limit,))
        rows = await cur.fetchall()
        return [dict(r) for r in rows]
