$ErrorActionPreference = 'Stop'
try {
  Write-Host '[1/5] verifying hash'
  $h = (Get-FileHash C:\ao_new.zip -Algorithm SHA256).Hash
  Write-Host ('      ' + $h)
  if ($h -ne '66918D2F01B87F2218DF2B295C6D1EEE6A03E95EE6820EF728503E4E2F1070BC') { throw 'hash-mismatch' }
  Write-Host '[2/5] extracting'
  New-Item -ItemType Directory -Force -Path C:\AppleOrder | Out-Null
  Expand-Archive C:\ao_new.zip C:\AppleOrder\app -Force
  Write-Host '[3/5] shortcut'
  $ws = New-Object -ComObject WScript.Shell
  $l = $ws.CreateShortcut('C:\Users\Administrator\Desktop\AppleOrder.lnk')
  $l.TargetPath = 'C:\AppleOrder\app\AppleOrder.exe'
  $l.WorkingDirectory = 'C:\AppleOrder\app'
  $l.Save()
  Write-Host '[4/5] cleanup zip'
  Remove-Item C:\ao_new.zip -Force
  Write-Host '[5/5] FRESH-DONE'
} catch {
  Write-Host ('FRESH-FAIL-' + $_.Exception.Message)
}
