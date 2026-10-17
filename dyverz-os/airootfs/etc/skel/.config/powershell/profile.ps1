# Dyverz OS — PowerShell 7 preview gets a real C: drive (the WinKernel partition) and can run .exe/.msi
$env:WINEPREFIX = "$HOME/.wine-cdrive"; $env:WINEDEBUG = "-all"
if (-not (Test-Path $env:WINEPREFIX)) { & winkernel init | Out-Null }
if (-not (Get-PSDrive C -ErrorAction SilentlyContinue)) { New-PSDrive -Name C -PSProvider FileSystem -Root /mnt/cdrive -Scope Global | Out-Null }
Set-Location C:\
function Invoke-WindowsApp { param([Parameter(Mandatory)][string]$Path, [Parameter(ValueFromRemainingArguments)]$Args)
  $p = if ($Path -match '^[A-Za-z]:\\') { & winepath -u $Path } else { $Path }
  if ($p -match '\.msi$') { & wine msiexec /i $p @Args } else { & wine start /wait /unix $p @Args } }
Set-Alias winrun Invoke-WindowsApp; Set-Alias Install-WindowsApp dyverz-exe-install
function winecfg { & wine winecfg }; function regedit { & wine regedit }; function cmd { & wincmd @args }
$ExecutionContext.InvokeCommand.PreCommandLookupAction = { param($cmd, $ea)
  if ($cmd -match '\.(exe|msi)$' -and (Test-Path $cmd)) { $ea.CommandScriptBlock = { Invoke-WindowsApp $cmd @args }.GetNewClosure(); $ea.StopSearch = $true } }
function prompt { "PS $($executionContext.SessionState.Path.CurrentLocation -replace '^/mnt/cdrive','C:')> " }
Write-Host "Dyverz WinKernel C: mounted at /mnt/cdrive  —  winrun app.exe | Install-WindowsApp setup.exe | cmd" -ForegroundColor Cyan
