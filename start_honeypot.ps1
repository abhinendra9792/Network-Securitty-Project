# Start Remote Access Honeypot Backend
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Remote Access Honeypot for Threat Analysis" -ForegroundColor Cyan  
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Activate virtual environment
& ".\.venv\Scripts\Activate.ps1"

Write-Host "[*] Starting honeypot backend..." -ForegroundColor Yellow
Write-Host "[*] Honeypot ports: 2222 (SSH), 3389 (RDP)" -ForegroundColor Yellow
Write-Host "[*] API endpoint: http://127.0.0.1:8000/events" -ForegroundColor Yellow
Write-Host "[*] WebSocket: ws://127.0.0.1:8000/ws/events" -ForegroundColor Yellow
Write-Host ""
Write-Host "[!] Press CTRL+C to stop the honeypot" -ForegroundColor Red
Write-Host ""

# Run the server
& "D:/Network Securitty Project/.venv/Scripts/python.exe" -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000
