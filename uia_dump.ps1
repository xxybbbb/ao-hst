$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Public\uia_log.txt'
if (Test-Path $log) { Remove-Item $log -Force }
function L($m){ Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format HH:mm:ss.fff), $m) }
function DumpTree($el, $depth, $maxDepth) {
  if ($depth -gt $maxDepth) { return }
  $n = $el.Current.Name
  $t = $el.Current.ControlType.ProgrammaticName
  $cn = ''
  try { $cn = $el.Current.ClassName } catch {}
  if ($n -or $t -match 'CheckBox|TabItem|TreeItem|ListItem|Button|MenuItem|Pane') {
    L (("  " * $depth) + $t + " [" + $n + "] cls=" + $cn)
  }
  $kids = $el.FindAll([System.Windows.Automation.TreeScope]::Children, [System.Windows.Automation.Condition]::TrueCondition)
  foreach($k in @($kids)) { DumpTree $k ($depth + 1) $maxDepth }
}
try {
  Add-Type -AssemblyName UIAutomationClient,UIAutomationTypes
  Add-Type -AssemblyName Microsoft.VisualBasic
  L 'dump start'
  $p = Get-Process BHMailer -ErrorAction Stop
  $null = [Microsoft.VisualBasic.Interaction]::AppActivate($p.Id)
  Start-Sleep -Milliseconds 600
  $root = [System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
  L '=== MAIN WINDOW TREE (depth 5) ==='
  DumpTree $root 0 5
  L '=== open 设置 dialog ==='
  $mbCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuBar)
  $mb = $root.FindFirst([System.Windows.Automation.TreeScope]::Children, $mbCond)
  $fileCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, '文件')
  $file = $mb.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $fileCond)
  $inv = $null
  if ($file.TryGetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern, [ref]$inv)) { $inv.Invoke() }
  Start-Sleep -Milliseconds 1200
  $setCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, '设置...')
  $setItem = $file.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $setCond)
  if ($setItem) {
    L 'found 设置, invoking'
    $inv2 = $null
    if ($setItem.TryGetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern, [ref]$inv2)) { $inv2.Invoke() }
    Start-Sleep -Milliseconds 2500
    $desk = [System.Windows.Automation.AutomationElement]::RootElement
    $winCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::Window)
    $wins = $desk.FindAll([System.Windows.Automation.TreeScope]::Children, $winCond)
    foreach($w in @($wins)) {
      if ($w.Current.ProcessId -eq $p.Id) {
        L ("DIALOG: [" + $w.Current.Name + "]")
        DumpTree $w 0 6
      }
    }
  } else { L '设置 item not found' }
  L 'dump done'
} catch { L ("ERR: " + $_.Exception.Message) }
