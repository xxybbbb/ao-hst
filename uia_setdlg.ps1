$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Public\uia_log.txt'
if (Test-Path $log) { Remove-Item $log -Force }
function L($m){ Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format HH:mm:ss.fff), $m) }
function DumpTree($el, $depth, $maxDepth) {
  if ($depth -gt $maxDepth) { return }
  $n = $el.Current.Name
  $t = $el.Current.ControlType.ProgrammaticName
  if ($n -or $t -match 'CheckBox|TabItem|TreeItem|ListItem|Button|RadioButton') {
    L (("  " * $depth) + $t + " [" + $n + "]")
  }
  $kids = $el.FindAll([System.Windows.Automation.TreeScope]::Children, [System.Windows.Automation.Condition]::TrueCondition)
  foreach($k in @($kids)) { DumpTree $k ($depth + 1) $maxDepth }
}
try {
  Add-Type -AssemblyName UIAutomationClient,UIAutomationTypes
  Add-Type -AssemblyName Microsoft.VisualBasic
  L 'setdlg dump start'
  $p = Get-Process BHMailer -ErrorAction Stop
  $null = [Microsoft.VisualBasic.Interaction]::AppActivate($p.Id)
  Start-Sleep -Milliseconds 800
  $desk = [System.Windows.Automation.AutomationElement]::RootElement
  $winCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::Window)
  $wins = $desk.FindAll([System.Windows.Automation.TreeScope]::Children, $winCond)
  foreach($w in @($wins)) {
    if ($w.Current.ProcessId -eq $p.Id -and $w.Current.Name -ne '心蓝邮箱批量管理助手') {
      L ("DIALOG: [" + $w.Current.Name + "]")
      DumpTree $w 0 7
    }
  }
  L 'setdlg dump done'
} catch { L ("ERR: " + $_.Exception.Message) }
