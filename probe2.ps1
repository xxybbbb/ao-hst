$out = @()
$mailerIds = (Get-Process BHMailer -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
$listen = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalAddress -eq '0.0.0.0' -or $_.LocalAddress -eq '127.0.0.1' -or $_.LocalAddress -eq '::' }
$seen = @{}
foreach ($c in $listen) {
  $proc = Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue
  $key = '' + $c.LocalPort + $c.OwningProcess
  if (-not $seen[$key]) {
    $seen[$key] = $true
    $out += ('L:' + $c.LocalPort + '=' + $proc.ProcessName)
  }
}
$est = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | Where-Object { $_.OwningProcess -in $mailerIds }
foreach ($e in ($est | Select-Object -First 8)) {
  $out += ('E:' + $e.RemoteAddress + ':' + $e.RemotePort)
}
$out -join ' ;; '
