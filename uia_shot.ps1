$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Public\uia_log.txt'
if (Test-Path $log) { Remove-Item $log -Force }
function L($m){ Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format HH:mm:ss.fff), $m) }
try {
  Add-Type -AssemblyName UIAutomationClient,UIAutomationTypes
  Add-Type -AssemblyName Microsoft.VisualBasic
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing
  L 'shot start'
  $p = Get-Process BHMailer -ErrorAction Stop
  $null = [Microsoft.VisualBasic.Interaction]::AppActivate($p.Id)
  Start-Sleep -Milliseconds 800
  $root = [System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
  $mbCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuBar)
  $mb = $root.FindFirst([System.Windows.Automation.TreeScope]::Children, $mbCond)
  $fileCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, '文件')
  $file = $mb.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $fileCond)
  $inv = $null
  if ($file.TryGetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern, [ref]$inv)) { $inv.Invoke() }
  Start-Sleep -Milliseconds 1500
  $setCond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, '设置...')
  $setItem = $file.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $setCond)
  if (-not $setItem) { L '设置 not found'; throw 'noset' }
  $inv2 = $null
  if ($setItem.TryGetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern, [ref]$inv2)) { $inv2.Invoke() }
  L '设置 invoked, waiting'
  Start-Sleep -Milliseconds 3500
  $b = [System.Windows.Forms.SystemInformation]::VirtualScreen
  $bmp = New-Object System.Drawing.Bitmap($b.Width, $b.Height)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($b.X, $b.Y, 0, 0, (New-Object System.Drawing.Size($b.Width, $b.Height)))
  $bmp.Save('C:\Users\Public\setdlg.png', [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  L 'screen saved'
  $tk = (Get-Content C:\Users\Public\tk.txt -Raw).Trim()
  $bytes = [IO.File]::ReadAllBytes('C:\Users\Public\setdlg.png')
  $b64 = [Convert]::ToBase64String($bytes)
  $json = '{"message":"setdlg","content":"' + $b64 + '"}'
  $hdr = @{ Authorization = ('token ' + $tk) }
  $r = Invoke-WebRequest -UseBasicParsing -Method Put -Headers $hdr -ContentType 'application/json' -Body $json -Uri 'https://api.github.com/repos/xxybbbb/ao-hst/contents/setdlg.png'
  L ('upload status=' + $r.StatusCode)
  L 'shot done'
} catch { L ("ERR: " + $_.Exception.Message) }
