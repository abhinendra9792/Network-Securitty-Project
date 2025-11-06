# Remote Access Honeypot Backend

This backend provides a simple, extendable remote-access honeypot for real-time threat analysis.

Features
- Async TCP honeypot (configurable ports) that accepts incoming connections and records metadata and a payload preview.
- Stores events in SQLite using `aiosqlite`.
- FastAPI REST API to query recent events.
- WebSocket endpoint to stream events in real-time for analysis or a UI.

Quick start (PowerShell)
1. Create a virtual environment and activate it:

```powershell
python -m venv .venv; .\.venv\Scripts\Activate.ps1
```

2. Install dependencies:

```powershell
pip install -r backend/requirements.txt
```

3. Run the backend (development):

```powershell
# from the workspace root
uvicorn backend.app.main:app --reload --port 8000
```

Endpoints
- `GET /events?limit=50` — returns recent events from the DB (JSON).
- `GET /ws/events` — WebSocket endpoint that streams events as they are observed.

Config
- Ports and DB path are configurable via environment variables; see `.env.example`.

Next steps
- Add authentication and rate-limits for UI endpoints.
- Add richer protocol emulation (SSH, RDP fake banners), improved parsing, and geolocation enrichment.
