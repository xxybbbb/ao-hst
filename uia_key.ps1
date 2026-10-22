$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Public\uia_log.txt'
if (Test-Path $log) { Remove-Item $log -Force }
function L($m){ Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format HH:mm:ss.fff), $m) }
function Shot($name) {
  $b = [System.Windows.Forms.SystemInformation]::VirtualScreen
  $bmp = New-Object System.Drawing.Bitmap($b.Width, $b.Height)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($b.X, $b.Y, 0, 0, (New-Object System.Drawing.Size($b.Width, $b.Height)))
  $bmp.Save(('C:\Users\Public\' + $name), [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}
try {
  Add-Type -AssemblyName UIAutomationClient,UIAutomationTypes
  Add-Type -AssemblyName Microsoft.VisualBasic
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing
  L 'key run start'
  $p = Get-Process BHMailer -ErrorAction Stop
  L ('proc ' + $p.Id + ' win ' + $p.MainWindowTitle)
  $null = [Microsoft.VisualBasic.Interaction]::AppActivate($p.Id)
  Start-Sleep -Milliseconds 1000
  Shot 'key0.png'
  L 'key0 shot'
  [System.Windows.Forms.SendKeys]::SendWait('%f')
  Start-Sleep -Milliseconds 1200
  Shot 'key1.png'
  L 'key1 shot (alt+f)'
  [System.Windows.Forms.SendKeys]::SendWait('{ESC}')
  $tk = (Get-Content C:\Users\Public\tk.txt -Raw).Trim()
  $hdr = @{ Authorization = ('token ' + $tk) }
  foreach($n in @('key0.png','key1.png')) {
    $bytes = [IO.File]::ReadAllBytes(('C:\Users\Public\' + $n))
    $b64 = [Convert]::ToBase64String($bytes)
    $json = '{"message":"' + $n + '","content":"' + $b64 + '"}'
    $r = Invoke-WebRequest -UseBasicParsing -Method Put -Headers $hdr -ContentType 'application/json' -Body $json -Uri ('https://api.github.com/repos/xxybbbb/ao-hst/contents/' + $n)
    L ('upload ' + $n + ' = ' + $r.StatusCode)
  }
  L 'key run done'
} catch { L ("ERR: " + $_.Exception.Message) }
