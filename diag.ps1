$out = @()
Get-Process | Where-Object { $_.Path -and $_.Path -notlike 'C:\Windows*' } | ForEach-Object { $out += ('PROC: ' + $_.Name + ' => ' + $_.Path) }
$out += ('SEP1')
$out += ('FILES-BHDATA: ' + (Get-ChildItem 'C:\Program Files (x86)\BHData' -Recurse -File -ErrorAction SilentlyContinue).Count)
$out += ('SEP2')
Get-ChildItem 'C:\Program Files (x86)','C:\Program Files' -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-1) } | ForEach-Object { $out += ('NEW: ' + $_.FullName) }
$out += ('SEP3')
Get-ChildItem 'C:\Users\Administrator\Desktop','C:\ProgramData\Microsoft\Windows\Start Menu\Programs' -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-1) } | ForEach-Object { $out += ('SHC: ' + $_.FullName) }
$out -join ' ;; '
