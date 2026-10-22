$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Public\uia_log.txt'
if (Test-Path $log) { Remove-Item $log -Force }
function L($m){ Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format HH:mm:ss.fff), $m) }
function DumpTree($el, $depth, $maxDepth) {
  if ($depth -gt $maxDepth) { return }
  $n = $el.Current.Name
  $t = $el.Current.ControlType.ProgrammaticName
  if ($n -or $t -match 'CheckBox|TabItem|TreeItem|ListItem|Button|MenuItem|RadioButton|ComboBox|Edit|Tab') {
    L (("  " * $depth) + $t + " [" + $n + "]")
  }
  $kids = $el.FindAll([System.Windows.Automation.TreeScope]::Children, [System.Windows.Automation.Condition]::TrueCondition)
  foreach($k in @($kids)) { DumpTree $k ($depth + 1) $maxDepth }
}
try {
  Add-Type -AssemblyName UIAutomationClient,UIAutomationTypes
  Add-Type -AssemblyName Microsoft.VisualBasic
  L 'ao dump start'
  $p = Get-Process AppleOrder -ErrorAction Stop
  L ('proc ' + $p.Id + ' handle ' + $p.MainWindowHandle + ' title ' + $p.MainWindowTitle)
  $null = [Microsoft.VisualBasic.Interaction]::AppActivate($p.Id)
  Start-Sleep -Milliseconds 900
  $root = [System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
  DumpTree $root 0 6
  L 'ao dump done'
} catch { L ("ERR: " + $_.Exception.Message) }
