$out = @()
$mailer = Get-Process BHMailer -ErrorAction SilentlyContinue
$order = Get-Process AppleOrder -ErrorAction SilentlyContinue
$out += ('MAILER-PID: ' + ($mailer | ForEach-Object { $_.Id }) -join ',')
$out += ('ORDER-PID: ' + ($order | ForEach-Object { $_.Id }) -join ',')
$ports = @()
if ($mailer) {
  $conns = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.OwningProcess -in ($mailer | ForEach-Object { $_.Id }) }
  $ports = $conns | ForEach-Object { $_.LocalPort } | Select-Object -Unique
  $out += ('MAILER-PORTS: ' + ($ports -join ','))
}
foreach ($port in $ports) {
  try {
    $r = Invoke-WebRequest ("http://127.0.0.1:" + $port + "/") -UseBasicParsing -TimeoutSec 6
    $body = $r.Content
    if ($body.Length -gt 220) { $body = $body.Substring(0, 220) }
    $out += ('PROBE ' + $port + ': HTTP ' + $r.StatusCode + ' BODY ' + $body)
  } catch {
    $out += ('PROBE ' + $port + ': ERR ' + $_.Exception.Message)
  }
}
$out -join ' ;; '
