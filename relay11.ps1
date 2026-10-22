$ErrorActionPreference = 'Continue'
$tk = (Get-Content C:\Users\Public\tk.txt -Raw).Trim()
$pw = (Get-Content C:\Users\Public\pw.txt -Raw).Trim()
$hdr = @{ Authorization = ('token ' + $tk) }
Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/xxybbbb/ao-hst/main/uia_ao.ps1 -OutFile C:\Users\Public\uia_ao.ps1
schtasks /create /tn bhui /tr "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\Public\uia_ao.ps1" /sc once /st 23:59 /ru Administrator /rp $pw /it /f
schtasks /run /tn bhui
Start-Sleep -Seconds 20
if (Test-Path C:\Users\Public\uia_log.txt) { Get-Content C:\Users\Public\uia_log.txt } else { 'NO-LOG' }
schtasks /delete /tn bhui /f
