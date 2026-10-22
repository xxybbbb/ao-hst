$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Public\uia_log.txt'
if (Test-Path $log) { Remove-Item $log -Force }
function L($m){ Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format HH:mm:ss.fff), $m) }
try {
  Add-Type -AssemblyName UIAutomationClient,UIAutomationTypes
  Add-Type -AssemblyName Microsoft.VisualBasic
  Add-Type -AssemblyName System.Windows.Forms
  L 'menus dump start'
  $p = Get-Process BHMailer -ErrorAction Stop
  $null = [Microsoft.VisualBasic.Interaction]::AppActivate($p.Id)
  Start-Sleep -Milliseconds 800
  $root = [System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
  $mbCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuBar)
  $mb = $root.FindFirst([System.Windows.Automation.TreeScope]::Children, $mbCond)
  $miCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuItem)
  $tops = $mb.FindAll([System.Windows.Automation.TreeScope]::Descendants, $miCond)
  foreach($top in @($tops)) {
    $tn = $top.Current.Name
    L ("TOP [" + $tn + "]")
    $inv = $null
    if ($top.TryGetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern, [ref]$inv)) { $inv.Invoke() }
    Start-Sleep -Milliseconds 1200
    $subs = $top.FindAll([System.Windows.Automation.TreeScope]::Descendants, $miCond)
    foreach($s in @($subs)) { L ("  sub [" + $s.Current.Name + "]") }
    [System.Windows.Forms.SendKeys]::SendWait('{ESC}')
    Start-Sleep -Milliseconds 500
  }
  L 'menus dump done'
} catch { L ("ERR: " + $_.Exception.Message) }
