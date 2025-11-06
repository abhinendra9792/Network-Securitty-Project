# Test Attack Simulator for Remote Access Honeypot
Write-Host "`n===================================================" -ForegroundColor Cyan
Write-Host "  Real-Time Threat Analysis - Attack Simulator" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

Write-Host "`n[*] Simulating various attack patterns..." -ForegroundColor Yellow

# Attack 1: SSH Brute Force Scanner
Write-Host "`n[ATTACK 1] SSH Brute Force Scanner on port 2222" -ForegroundColor Red
try {
    $client = New-Object System.Net.Sockets.TcpClient('127.0.0.1',2222)
    $stream = $client.GetStream()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes('SSH-2.0-OpenSSH_8.9 Malicious-Scanner')
    $stream.Write($bytes,0,$bytes.Length)
    Start-Sleep -Milliseconds 500
    $stream.Close()
    $client.Close()
    Write-Host "  ✓ Attack sent successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed: $_" -ForegroundColor DarkRed
}

Start-Sleep -Seconds 1

# Attack 2: RDP Credential Attack
Write-Host "`n[ATTACK 2] RDP Credential Brute Force on port 3389" -ForegroundColor Red
try {
    $client = New-Object System.Net.Sockets.TcpClient('127.0.0.1',3389)
    $stream = $client.GetStream()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes('Administrator:Password123!')
    $stream.Write($bytes,0,$bytes.Length)
    Start-Sleep -Milliseconds 500
    $stream.Close()
    $client.Close()
    Write-Host "  ✓ Attack sent successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed: $_" -ForegroundColor DarkRed
}

Start-Sleep -Seconds 1

# Attack 3: HTTP Request on SSH Port (Port Scanning)
Write-Host "`n[ATTACK 3] HTTP Request on SSH Port (Port Scanner)" -ForegroundColor Red
try {
    $client = New-Object System.Net.Sockets.TcpClient('127.0.0.1',2222)
    $stream = $client.GetStream()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes("GET /admin HTTP/1.1`r`nHost: target.com`r`n`r`n")
    $stream.Write($bytes,0,$bytes.Length)
    Start-Sleep -Milliseconds 500
    $stream.Close()
    $client.Close()
    Write-Host "  ✓ Attack sent successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed: $_" -ForegroundColor DarkRed
}

Start-Sleep -Seconds 1

# Attack 4: Malformed SSH Handshake
Write-Host "`n[ATTACK 4] Malformed SSH Handshake (Exploit Attempt)" -ForegroundColor Red
try {
    $client = New-Object System.Net.Sockets.TcpClient('127.0.0.1',2222)
    $stream = $client.GetStream()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes('SSH-2.0-AAAAAAAAAAAAAAAAAAA' + 'A' * 500)
    $stream.Write($bytes,0,$bytes.Length)
    Start-Sleep -Milliseconds 500
    $stream.Close()
    $client.Close()
    Write-Host "  ✓ Attack sent successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed: $_" -ForegroundColor DarkRed
}

Start-Sleep -Seconds 2

# Query the REST API to show captured threats
Write-Host "`n===================================================" -ForegroundColor Cyan
Write-Host "  CAPTURED THREAT EVENTS - REAL-TIME ANALYSIS" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8000/events?limit=10"
    Write-Host "`nTotal Events Captured: $($response.Count)`n" -ForegroundColor Yellow
    
    foreach($event in $response) {
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "Event ID: $($event.id)" -ForegroundColor Green
        Write-Host "  Timestamp:     $($event.ts)"
        Write-Host "  Source IP:     $($event.src_ip):$($event.src_port)" -ForegroundColor Cyan
        Write-Host "  Target Port:   $($event.dest_port)" -ForegroundColor Cyan
        Write-Host "  Protocol:      $($event.protocol)"
        Write-Host "  Payload:       " -NoNewline
        Write-Host "$($event.payload_preview.Substring(0, [Math]::Min(100, $event.payload_preview.Length)))" -ForegroundColor Red
        Write-Host ""
    }
} catch {
    Write-Host "`n✗ Failed to retrieve events: $_" -ForegroundColor DarkRed
}

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "`n[*] View all events: http://127.0.0.1:8000/events" -ForegroundColor Yellow
Write-Host "[*] Real-time stream: ws://127.0.0.1:8000/ws/events" -ForegroundColor Yellow
Write-Host ""
