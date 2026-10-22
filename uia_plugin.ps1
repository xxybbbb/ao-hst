$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Public\uia_log.txt'
if (Test-Path $log) { Remove-Item $log -Force }
function L($m){ Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format HH:mm:ss.fff), $m) }
try {
  Add-Type -AssemblyName UIAutomationClient,UIAutomationTypes
  Add-Type -AssemblyName Microsoft.VisualBasic
  Add-Type -AssemblyName System.Windows.Forms
  L 'plugin recon start'
  $p = Get-Process BHMailer -ErrorAction Stop
  $null = [Microsoft.VisualBasic.Interaction]::AppActivate($p.Id)
  Start-Sleep -Milliseconds 600
  $root = [System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
  $mbCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuBar)
  $mb = $root.FindFirst([System.Windows.Automation.TreeScope]::Children, $mbCond)
  $fileCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, '文件')
  $file = $mb.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $fileCond)
  $inv = $null
  if ($file.TryGetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern, [ref]$inv)) { $inv.Invoke() }
  L 'file menu invoked'
  Start-Sleep -Milliseconds 1500
  $miCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuItem)
  $items = $file.FindAll([System.Windows.Automation.TreeScope]::Descendants, $miCond)
  $idx = 0
  foreach($i in @($items)) { L ("mi#" + $idx + " [" + $i.Current.Name + "]"); $idx++ }
  $pmCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, '插件管理')
  $pm = $file.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $pmCond)
  if (-not $pm) {
    $desk = [System.Windows.Automation.AutomationElement]::RootElement
    $pm = $desk.FindFirst([System.Windows.Automation.TreeScope]::Children, $pmCond)
  }
  if ($pm) {
    L 'found 插件管理, invoking'
    $inv2 = $null
    if ($pm.TryGetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern, [ref]$inv2)) { $inv2.Invoke() }
    else {
      $sel = $null
      if ($pm.TryGetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern, [ref]$sel)) { $sel.Select() }
    }
    Start-Sleep -Milliseconds 2000
    $desk = [System.Windows.Automation.AutomationElement]::RootElement
    $winCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::Window)
    $wins = $desk.FindAll([System.Windows.Automation.TreeScope]::Children, $winCond)
    foreach($w in @($wins)) { L ("window: [" + $w.Current.Name + "] pid=" + $w.Current.ProcessId) }
  } else { L '插件管理 NOT FOUND anywhere' }
  L 'plugin recon done'
} catch { L ("ERR: " + $_.Exception.Message) }
