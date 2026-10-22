$ErrorActionPreference = 'Continue'
Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/xxybbbb/ao-hst/main/relaunch.ps1 -OutFile C:\Users\Public\relaunch.ps1
schtasks /create /tn bhui /tr "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\Public\relaunch.ps1" /sc once /st 23:59 /ru Administrator /rp "XlHk#2846vQz9" /it /f
schtasks /run /tn bhui
Start-Sleep -Seconds 60
if (Test-Path C:\Users\Public\uia_log.txt) { Get-Content C:\Users\Public\uia_log.txt } else { 'NO-LOG' }
schtasks /delete /tn bhui /f

