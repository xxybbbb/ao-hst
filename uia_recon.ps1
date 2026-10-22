$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Public\uia_log.txt'
if (Test-Path $log) { Remove-Item $log -Force }
function L($m){ Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format HH:mm:ss.fff), $m) }
try {
  Add-Type -AssemblyName UIAutomationClient,UIAutomationTypes
  Add-Type -AssemblyName Microsoft.VisualBasic
  L 'recon start'
  $p = Get-Process BHMailer -ErrorAction Stop
  L ("proc id=" + $p.Id + " mainwin=" + $p.MainWindowTitle + " handle=" + $p.MainWindowHandle)
  $null = [Microsoft.VisualBasic.Interaction]::AppActivate($p.Id)
  Start-Sleep -Milliseconds 800
  $root = [System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
  L ("root name=" + $root.Current.Name + " type=" + $root.Current.ControlType.ProgrammaticName)
  $miCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuItem)
  $menus = $root.FindFirst([System.Windows.Automation.TreeScope]::Children, $miCond)
  if (-not $menus) { $menus = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, $miCond) }
  if ($menus) {
    foreach($m in @($menus)) { L ("menuitem: [" + $m.Current.Name + "]") }
  } else { L 'no menuitem found' }
  $all = $root.FindAll([System.Windows.Automation.TreeScope]::Children, [System.Windows.Automation.Condition]::TrueCondition)
  foreach($c in @($all)) { L ("child: [" + $c.Current.ControlType.ProgrammaticName + "] [" + $c.Current.Name + "]") }
  L 'recon done'
} catch { L ("ERR: " + $_.Exception.Message) }
