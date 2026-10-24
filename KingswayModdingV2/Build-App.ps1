$ErrorActionPreference='Stop'
if($PSVersionTable.PSEdition -ne 'Core'){
  $pw=@((Get-Command pwsh -ErrorAction SilentlyContinue).Source,(Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'),(Join-Path ${env:ProgramFiles(x86)} 'PowerShell\7\pwsh.exe'),(Join-Path $env:LOCALAPPDATA 'Microsoft\powershell\pwsh.exe')) + @(Get-ChildItem (Join-Path $env:ProgramFiles 'PowerShell') -Filter pwsh.exe -Recurse -ErrorAction SilentlyContinue | ForEach-Object FullName) + @(Get-ChildItem (Join-Path $env:ProgramFiles 'WindowsApps') -Filter pwsh.exe -Recurse -Depth 2 -ErrorAction SilentlyContinue | ForEach-Object FullName)
  $pw=$pw | Where-Object {$_ -and (Test-Path $_)} | Select-Object -First 1
  if(!$pw){throw 'PowerShell 7 (pwsh.exe) was not found. Install it from the Microsoft Store (PowerShell) or https://aka.ms/powershell, then run this again.'}
  & $pw -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath
  exit $LASTEXITCODE
}
$lib=Join-Path (Split-Path $PSScriptRoot -Parent) 'UndertaleModdingTool'
foreach($n in @('Microsoft.CodeAnalysis.dll','Microsoft.CodeAnalysis.CSharp.dll')){[Reflection.Assembly]::LoadFrom((Join-Path $PSHOME $n)) | Out-Null}
$refs=[Collections.Generic.List[Microsoft.CodeAnalysis.MetadataReference]]::new()
$runtime=[IO.Path]::GetDirectoryName([object].Assembly.Location)
foreach($p in (Get-ChildItem $runtime -Filter '*.dll').FullName){try{$null=[Reflection.AssemblyName]::GetAssemblyName($p);$refs.Add([Microsoft.CodeAnalysis.MetadataReference]::CreateFromFile($p))}catch{}}
foreach($n in @('UndertaleModLib.dll','Underanalyzer.dll','Magick.NET-Q8-AnyCPU.dll','Magick.NET.Core.dll')){$refs.Add([Microsoft.CodeAnalysis.MetadataReference]::CreateFromFile((Join-Path $lib $n)))}
$trees=[Collections.Generic.List[Microsoft.CodeAnalysis.SyntaxTree]]::new()
foreach($p in (Get-ChildItem (Join-Path $PSScriptRoot 'Src') -Filter '*.cs' | Sort-Object Name).FullName){$trees.Add([Microsoft.CodeAnalysis.CSharp.CSharpSyntaxTree]::ParseText([IO.File]::ReadAllText($p),$null,$p))}
$opts=[Microsoft.CodeAnalysis.CSharp.CSharpCompilationOptions]::new([Microsoft.CodeAnalysis.OutputKind]::ConsoleApplication).WithOptimizationLevel([Microsoft.CodeAnalysis.OptimizationLevel]::Release).WithDeterministic($true)
$comp=[Microsoft.CodeAnalysis.CSharp.CSharpCompilation]::Create('KingswayWorkshop',$trees,$refs,$opts)
$out=Join-Path $PSScriptRoot 'KingswayWorkshop.dll'
# Compile in memory first: a failed build never stops the Workshop or damages the DLL.
$stream=[IO.MemoryStream]::new()
try{$result=$comp.Emit($stream)}finally{$bytes=$stream.ToArray();$stream.Dispose()}
if(!$result.Success){$result.Diagnostics | Where-Object Severity -eq Error | ForEach-Object ToString; throw 'Backend compilation failed'}
# A running Workshop keeps KingswayWorkshop.dll open. Ask it to shut down, then stop any
# Workshop process from this folder that is still running (server.json can be stale).
$running=@(Get-CimInstance Win32_Process -Filter "Name='dotnet.exe'" | Where-Object { $_.CommandLine -and $_.CommandLine.Contains($out) })
if($running.Count){
  Write-Output 'Stopping the running Workshop...'
  & dotnet $out stop 2>$null | Out-Null
  foreach($p in $running){try{Wait-Process -Id $p.ProcessId -Timeout 5 -ErrorAction Stop}catch{Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue}}
  Start-Sleep -Milliseconds 300
}
[IO.File]::WriteAllBytes($out,$bytes)
'{"runtimeOptions":{"tfm":"net10.0","framework":{"name":"Microsoft.NETCore.App","version":"10.0.0"}}}' | Set-Content (Join-Path $PSScriptRoot 'KingswayWorkshop.runtimeconfig.json')
Write-Output 'Built KingswayWorkshop.dll'
# Restart the Workshop if this build had to stop it.
if($running.Count){Start-Process -FilePath 'wscript.exe' -ArgumentList ('"'+(Join-Path $PSScriptRoot 'Start Workshop.vbs')+'"') -WorkingDirectory $PSScriptRoot;Write-Output 'Restarted the Workshop.'}
