param(
  [ValidateSet('Gui', 'Exe', 'Portable')]
  [string]$Mode = 'Gui'
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$distRoot = Join-Path $projectRoot 'dist'

function Show-Result([string]$message, [string]$path) {
  [System.Windows.Forms.MessageBox]::Show($message, 'ASCII Art Studio Builder', 'OK', 'Information') | Out-Null
  Start-Process explorer.exe -ArgumentList "/select,`"$path`""
}

function Build-StandaloneExe {
  Set-Location $projectRoot
  & npm.cmd run package:win
  if ($LASTEXITCODE -ne 0) { throw 'EXE build failed. See the terminal output for details.' }
  $output = Join-Path $distRoot 'ASCII-Art-Studio.exe'
  if (-not (Test-Path $output)) { throw 'The EXE build did not produce its output file.' }
  return $output
}

function Build-PortableZip {
  $packageRoot = Join-Path $distRoot 'portable-build\ASCII-Art-Studio'
  $zipPath = Join-Path $distRoot 'ASCII-Art-Studio-Portable.zip'
  $runtimeRoot = Join-Path $packageRoot 'runtime'
  if (Test-Path (Join-Path $distRoot 'portable-build')) { Remove-Item -LiteralPath (Join-Path $distRoot 'portable-build') -Recurse -Force }
  if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
  New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null

  foreach ($file in @('server.js', 'app.js', 'index.html', 'styles.css', 'package.json')) {
    Copy-Item -LiteralPath (Join-Path $projectRoot $file) -Destination $packageRoot -Force
  }
  Copy-Item -LiteralPath (Join-Path $projectRoot 'fonts') -Destination (Join-Path $packageRoot 'fonts') -Recurse -Force
  New-Item -ItemType Directory -Path (Join-Path $packageRoot 'node_modules') -Force | Out-Null
  Copy-Item -LiteralPath (Join-Path $projectRoot 'node_modules\figlet') -Destination (Join-Path $packageRoot 'node_modules\figlet') -Recurse -Force
  $nodePath = (Get-Command node.exe -ErrorAction Stop).Source
  Copy-Item -LiteralPath $nodePath -Destination (Join-Path $runtimeRoot 'node.exe') -Force

  $launcher = @'
@echo off
cd /d "%~dp0"
runtime\node.exe server.js
'@
  Set-Content -LiteralPath (Join-Path $packageRoot 'Run-Local.cmd') -Value $launcher -Encoding ASCII
  $readme = @'
ASCII Art Studio portable project

Double-click Run-Local.cmd to start the app. It contains its own Node runtime,
the local FIGlet font library, and all required project files. No npm install
and no internet connection are required after extraction.
'@
  Set-Content -LiteralPath (Join-Path $packageRoot 'README.txt') -Value $readme -Encoding ASCII
  Compress-Archive -Path (Join-Path $packageRoot '*') -DestinationPath $zipPath -Force
  Remove-Item -LiteralPath (Join-Path $distRoot 'portable-build') -Recurse -Force
  return $zipPath
}

if ($Mode -eq 'Exe') {
  Build-StandaloneExe
  exit $LASTEXITCODE
}
if ($Mode -eq 'Portable') {
  Build-PortableZip
  exit 0
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'ASCII Art Studio - Distribution Builder'
$form.Size = New-Object System.Drawing.Size(510, 285)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

$title = New-Object System.Windows.Forms.Label
$title.Text = 'Choose a distribution format'
$title.Font = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(28, 25)
$title.Size = New-Object System.Drawing.Size(440, 32)

$description = New-Object System.Windows.Forms.Label
$description.Text = 'Both outputs include the local font library and work without an internet connection.'
$description.Location = New-Object System.Drawing.Point(30, 62)
$description.Size = New-Object System.Drawing.Size(440, 38)

$exeButton = New-Object System.Windows.Forms.Button
$exeButton.Text = 'Build standalone EXE'
$exeButton.Location = New-Object System.Drawing.Point(30, 112)
$exeButton.Size = New-Object System.Drawing.Size(210, 52)

$portableButton = New-Object System.Windows.Forms.Button
$portableButton.Text = 'Build portable project ZIP'
$portableButton.Location = New-Object System.Drawing.Point(260, 112)
$portableButton.Size = New-Object System.Drawing.Size(210, 52)

$status = New-Object System.Windows.Forms.Label
$status.Text = 'Ready'
$status.Location = New-Object System.Drawing.Point(30, 184)
$status.Size = New-Object System.Drawing.Size(440, 28)

$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = 'Close'
$closeButton.Location = New-Object System.Drawing.Point(370, 218)
$closeButton.Size = New-Object System.Drawing.Size(100, 30)
$closeButton.Add_Click({ $form.Close() })

$exeButton.Add_Click({
  try {
    $exeButton.Enabled = $false; $portableButton.Enabled = $false; $status.Text = 'Building standalone EXE...'
    $output = Build-StandaloneExe
    $status.Text = 'Done'
    Show-Result 'Standalone EXE created in the dist folder.' $output
  } catch { [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Build failed', 'OK', 'Error') | Out-Null; $status.Text = 'Build failed' }
  finally { $exeButton.Enabled = $true; $portableButton.Enabled = $true }
})

$portableButton.Add_Click({
  try {
    $exeButton.Enabled = $false; $portableButton.Enabled = $false; $status.Text = 'Building portable project ZIP...'
    $output = Build-PortableZip
    $status.Text = 'Done'
    Show-Result 'Portable project ZIP created in the dist folder.' $output
  } catch { [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Build failed', 'OK', 'Error') | Out-Null; $status.Text = 'Build failed' }
  finally { $exeButton.Enabled = $true; $portableButton.Enabled = $true }
})

$form.Controls.AddRange(@($title, $description, $exeButton, $portableButton, $status, $closeButton))
[void]$form.ShowDialog()
