$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Public\uia_log.txt'
if (Test-Path $log) { Remove-Item $log -Force }
function L($m){ Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format HH:mm:ss.fff), $m) }
try {
  Add-Type -AssemblyName UIAutomationClient,UIAutomationTypes
  Add-Type -AssemblyName Microsoft.VisualBasic
  Add-Type -AssemblyName System.Windows.Forms
  L 'relaunch start'
  $exe = 'C:\Program Files (x86)\BHData\BHMailer\BHMailer.exe'
  if (-not (Test-Path $exe)) { L 'exe missing!'; throw 'noexe' }
  Stop-Process -Name BHMailer -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 2
  Start-Process -FilePath $exe -WorkingDirectory 'C:\Program Files (x86)\BHData\BHMailer'
  L 'restarted, waiting 25s for auto-login'
  Start-Sleep -Seconds 25
  $p = Get-Process BHMailer -ErrorAction Stop
  L ('new proc ' + $p.Id + ' handle ' + $p.MainWindowHandle + ' title ' + $p.MainWindowTitle)
  $null = [Microsoft.VisualBasic.Interaction]::AppActivate($p.Id)
  Start-Sleep -Milliseconds 1200
  $root = [System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
  $mbCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuBar)
  $mb = $null
  for ($i = 0; $i -lt 6 -and -not $mb; $i++) {
    $mb = $root.FindFirst([System.Windows.Automation.TreeScope]::Children, $mbCond)
    if (-not $mb) { $mb = $root.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $mbCond) }
    if (-not $mb) { Start-Sleep -Milliseconds 800 }
  }
  if ($mb) { L 'MENUBAR OK' } else { L 'MENUBAR STILL NULL' }
  L 'relaunch done'
} catch { L ("ERR: " + $_.Exception.Message) }
