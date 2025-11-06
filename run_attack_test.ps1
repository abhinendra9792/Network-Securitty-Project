# Simple Attack Test for Remote Access Honeypot
Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "  Real-Time Threat Analysis - Attack Test" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

# Attack 1: SSH Scanner
Write-Host "[ATTACK 1] SSH Brute Force Scanner on port 2222" -ForegroundColor Red
try {
    $client = New-Object System.Net.Sockets.TcpClient('127.0.0.1',2222)
    $stream = $client.GetStream()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes('SSH-2.0-OpenSSH_8.9 Malicious-Scanner')
    $stream.Write($bytes,0,$bytes.Length)
    Start-Sleep -Milliseconds 500
    $stream.Close()
    $client.Close()
    Write-Host "  Status: Attack sent successfully`n" -ForegroundColor Green
} catch {
    Write-Host "  Status: Failed - $($_.Exception.Message)`n" -ForegroundColor DarkRed
}

Start-Sleep -Seconds 1

# Attack 2: RDP Credential Attack
Write-Host "[ATTACK 2] RDP Credential Brute Force on port 3389" -ForegroundColor Red
try {
    $client = New-Object System.Net.Sockets.TcpClient('127.0.0.1',3389)
    $stream = $client.GetStream()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes('Administrator:Password123!')
    $stream.Write($bytes,0,$bytes.Length)
    Start-Sleep -Milliseconds 500
    $stream.Close()
    $client.Close()
    Write-Host "  Status: Attack sent successfully`n" -ForegroundColor Green
} catch {
    Write-Host "  Status: Failed - $($_.Exception.Message)`n" -ForegroundColor DarkRed
}

Start-Sleep -Seconds 1

# Attack 3: HTTP on SSH Port
Write-Host "[ATTACK 3] HTTP Request on SSH Port (Port Scanner)" -ForegroundColor Red
try {
    $client = New-Object System.Net.Sockets.TcpClient('127.0.0.1',2222)
    $stream = $client.GetStream()
    $httpRequest = "GET /admin HTTP/1.1" + [char]13 + [char]10 + "Host: target.com" + [char]13 + [char]10 + [char]13 + [char]10
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($httpRequest)
    $stream.Write($bytes,0,$bytes.Length)
    Start-Sleep -Milliseconds 500
    $stream.Close()
    $client.Close()
    Write-Host "  Status: Attack sent successfully`n" -ForegroundColor Green
} catch {
    Write-Host "  Status: Failed - $($_.Exception.Message)`n" -ForegroundColor DarkRed
}

Start-Sleep -Seconds 1

# Attack 4: Buffer Overflow Attempt
Write-Host "[ATTACK 4] Buffer Overflow Attempt on SSH" -ForegroundColor Red
try {
    $client = New-Object System.Net.Sockets.TcpClient('127.0.0.1',2222)
    $stream = $client.GetStream()
    $payload = 'SSH-2.0-' + ('A' * 500)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
    $stream.Write($bytes,0,$bytes.Length)
    Start-Sleep -Milliseconds 500
    $stream.Close()
    $client.Close()
    Write-Host "  Status: Attack sent successfully`n" -ForegroundColor Green
} catch {
    Write-Host "  Status: Failed - $($_.Exception.Message)`n" -ForegroundColor DarkRed
}

Start-Sleep -Seconds 2

# Query captured threats
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  CAPTURED THREAT EVENTS - ANALYSIS" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8000/events?limit=10"
    Write-Host "Total Events Captured: $($response.Count)`n" -ForegroundColor Yellow
    
    $counter = 1
    foreach($evt in $response) {
        Write-Host "[$counter] Event ID: $($evt.id)" -ForegroundColor Green
        Write-Host "    Timestamp:   $($evt.ts)"
        Write-Host "    Source:      $($evt.src_ip):$($evt.src_port)" -ForegroundColor Cyan
        Write-Host "    Target Port: $($evt.dest_port)" -ForegroundColor Cyan
        Write-Host "    Protocol:    $($evt.protocol)"
        
        $payload = $evt.payload_preview
        if ($payload.Length -gt 80) {
            $payload = $payload.Substring(0, 80) + "..."
        }
        Write-Host "    Payload:     $payload`n" -ForegroundColor Red
        $counter++
    }
} catch {
    Write-Host "Failed to retrieve events: $($_.Exception.Message)`n" -ForegroundColor DarkRed
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "View all events: http://127.0.0.1:8000/events" -ForegroundColor Yellow
Write-Host "Real-time stream: ws://127.0.0.1:8000/ws/events" -ForegroundColor Yellow
Write-Host "================================================`n" -ForegroundColor Cyan
