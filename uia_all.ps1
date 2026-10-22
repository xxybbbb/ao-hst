$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Public\uia_log.txt'
if (Test-Path $log) { Remove-Item $log -Force }
function L($m){ Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format HH:mm:ss.fff), $m) }
try {
  Add-Type -AssemblyName UIAutomationClient,UIAutomationTypes
  Add-Type -AssemblyName Microsoft.VisualBasic
  Add-Type -AssemblyName System.Windows.Forms
  L 'all menus start'
  $p = Get-Process BHMailer -ErrorAction Stop
  $h = $p.MainWindowHandle
  L ('handle=' + $h + ' title=' + $p.MainWindowTitle)
  if ($h -eq 0) {
    $desk = [System.Windows.Automation.AutomationElement]::RootElement
    $pidCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ProcessIdProperty, $p.Id)
    $wins = $desk.FindAll([System.Windows.Automation.TreeScope]::Children, $pidCond)
    foreach($w in @($wins)) { L ('win: [' + $w.Current.Name + '] type=' + $w.Current.ControlType.ProgrammaticName) }
    L 'handle zero, abort'
    throw 'zero handle'
  }
  $null = [Microsoft.VisualBasic.Interaction]::AppActivate($p.Id)
  Start-Sleep -Milliseconds 1000
  $root = [System.Windows.Automation.AutomationElement]::FromHandle($h)
  $mb = $null
  $mbCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuBar)
  for ($i = 0; $i -lt 5 -and -not $mb; $i++) {
    $mb = $root.FindFirst([System.Windows.Automation.TreeScope]::Children, $mbCond)
    if (-not $mb) {
      $mb = $root.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $mbCond)
    }
    if (-not $mb) { Start-Sleep -Milliseconds 700 }
  }
  if (-not $mb) {
    $kids = $root.FindAll([System.Windows.Automation.TreeScope]::Children, [System.Windows.Automation.Condition]::TrueCondition)
    foreach($k in @($kids)) { L ('rootchild: ' + $k.Current.ControlType.ProgrammaticName + ' [' + $k.Current.Name + ']') }
    throw 'no menubar'
  }
  L 'menubar found'
  $miCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuItem)
  $tops = $mb.FindAll([System.Windows.Automation.TreeScope]::Descendants, $miCond)
  foreach($top in @($tops)) {
    $tn = $top.Current.Name
    L ("TOP [" + $tn + "]")
    $inv = $null
    if ($top.TryGetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern, [ref]$inv)) { $inv.Invoke() }
    Start-Sleep -Milliseconds 1500
    $subs = $top.FindAll([System.Windows.Automation.TreeScope]::Descendants, $miCond)
    foreach($s in @($subs)) { L ("  sub [" + $s.Current.Name + "]") }
    [System.Windows.Forms.SendKeys]::SendWait('{ESC}')
    Start-Sleep -Milliseconds 600
  }
  L 'all menus done'
} catch { L ("ERR: " + $_.Exception.Message) }
