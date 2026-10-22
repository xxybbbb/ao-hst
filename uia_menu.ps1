$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Public\uia_log.txt'
if (Test-Path $log) { Remove-Item $log -Force }
function L($m){ Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format HH:mm:ss.fff), $m) }
try {
  Add-Type -AssemblyName UIAutomationClient,UIAutomationTypes
  Add-Type -AssemblyName Microsoft.VisualBasic
  Add-Type -AssemblyName System.Windows.Forms
  L 'menu recon start'
  $p = Get-Process BHMailer -ErrorAction Stop
  $null = [Microsoft.VisualBasic.Interaction]::AppActivate($p.Id)
  Start-Sleep -Milliseconds 600
  $root = [System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
  $mbCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuBar)
  $mb = $root.FindFirst([System.Windows.Automation.TreeScope]::Children, $mbCond)
  $fileCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, '文件')
  $file = $mb.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $fileCond)
  if (-not $file) { L 'file menu not found'; throw 'no file' }
  L 'found 文件, expanding'
  $exp = $null
  if ($file.TryGetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern, [ref]$exp)) { $exp.Expand() }
  else {
    $inv = $null
    if ($file.TryGetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern, [ref]$inv)) { $inv.Invoke() }
  }
  Start-Sleep -Milliseconds 900
  $miCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuItem)
  $items = $file.FindAll([System.Windows.Automation.TreeScope]::Descendants, $miCond)
  foreach($i in @($items)) {
    $accel = ''
    try { $accel = $i.Current.AcceleratorKey } catch {}
    L ("submenu: [" + $i.Current.Name + "] accel=[" + $accel + "]")
  }
  [System.Windows.Forms.SendKeys]::SendWait('{ESC}')
  L 'menu recon done'
} catch { L ("ERR: " + $_.Exception.Message) }
