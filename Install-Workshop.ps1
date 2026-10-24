# Kingsway Enemy Workshop installer. Run Install.cmd, or:
#   powershell -ExecutionPolicy Bypass -File Install-Workshop.ps1 [-GamePath "D:\Steam\steamapps\common\Kingsway"]
# Works with Windows PowerShell 5.1 and PowerShell 7.
param([string]$GamePath = '', [switch]$Elevated)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.IO.Compression.FileSystem

$KingswayAppId = '588950'
$OriginalHash = '7BE7530EC424F9F5972E142E08E043B71A94D7E894D95D5A67AC26CB0B9184F9'
$UtmtUrl = 'https://github.com/UnderminersTeam/UndertaleModTool/releases/download/0.9.2.0/UndertaleModTool_v0.9.2.0-Windows.zip'
$UtmtHash = '7060496BC1B0047C4309EDE53D564F0E187D43C894253EA3733B48E08E77E3CF'
$DotnetUrl = 'https://aka.ms/dotnet/10.0/dotnet-runtime-win-x64.exe'
$Package = $PSScriptRoot
$Source = Join-Path $Package 'KingswayModdingV2'
$Samples = Join-Path $Package 'Sample Enemies'

function Step([string]$text) { Write-Host ''; Write-Host "== $text" -ForegroundColor Cyan }
function Ok([string]$text) { Write-Host "   $text" -ForegroundColor Green }
function Info([string]$text) { Write-Host "   $text" }
function Ask([string]$question, [bool]$default) {
    $hint = if ($default) { '[Y/n]' } else { '[y/N]' }
    $answer = Read-Host "   $question $hint"
    if ([string]::IsNullOrWhiteSpace($answer)) { return $default }
    return $answer.Trim().ToLower().StartsWith('y')
}
function Download([string]$url, [string]$file) {
    Info "Downloading $url"
    Invoke-WebRequest -Uri $url -OutFile $file -UseBasicParsing
}

function Find-Kingsway {
    $steamRoots = @()
    foreach ($key in 'HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam') {
        $item = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
        if ($item) { foreach ($name in 'SteamPath', 'InstallPath') { if ($item.$name) { $steamRoots += $item.$name } } }
    }
    $libraries = @()
    foreach ($root in ($steamRoots | Select-Object -Unique)) {
        $libraries += $root
        $vdf = Join-Path $root 'steamapps\libraryfolders.vdf'
        if (Test-Path -LiteralPath $vdf) {
            foreach ($match in [regex]::Matches((Get-Content -LiteralPath $vdf -Raw), '"path"\s+"([^"]+)"')) { $libraries += $match.Groups[1].Value.Replace('\\', '\') }
        }
    }
    foreach ($library in ($libraries | Select-Object -Unique)) {
        $manifest = Join-Path $library "steamapps\appmanifest_$KingswayAppId.acf"
        $folder = 'Kingsway'
        if (Test-Path -LiteralPath $manifest) {
            $match = [regex]::Match((Get-Content -LiteralPath $manifest -Raw), '"installdir"\s+"([^"]+)"')
            if ($match.Success) { $folder = $match.Groups[1].Value }
        }
        $candidate = Join-Path $library "steamapps\common\$folder"
        if (Test-Path -LiteralPath (Join-Path $candidate 'data.win')) { return (Resolve-Path -LiteralPath $candidate).Path }
    }
    return ''
}

function Pick-Folder {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Select the Kingsway game folder (the one that contains data.win)'
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $dialog.SelectedPath }
    return ''
}

function Find-Dotnet {
    $ErrorActionPreference = 'Continue'
    $paths = @((Join-Path $env:ProgramFiles 'dotnet\dotnet.exe'))
    $command = Get-Command dotnet -ErrorAction SilentlyContinue
    if ($command) { $paths = @($command.Source) + $paths }
    foreach ($path in $paths) {
        if ($path -and (Test-Path -LiteralPath $path)) {
            $runtimes = & $path --list-runtimes 2>$null
            if ($runtimes -match '^Microsoft\.NETCore\.App 10\.') { return $path }
        }
    }
    return ''
}

function Can-Write([string]$folder) {
    $probe = Join-Path $folder ('.workshop-write-test-' + [guid]::NewGuid().ToString('N'))
    try { [IO.File]::WriteAllText($probe, 'x'); Remove-Item -LiteralPath $probe -Force; return $true } catch { return $false }
}

function Workshop([string[]]$arguments) {
    # Runs the Workshop backend once and returns its output; throws with startup-error.txt on failure.
    # Windows PowerShell 5.1 turns native stderr into a terminating error under 'Stop'.
    $ErrorActionPreference = 'Continue'
    $errorFile = Join-Path $Target 'startup-error.txt'
    if (Test-Path -LiteralPath $errorFile) { Remove-Item -LiteralPath $errorFile -Force }
    $output = & $script:Dotnet (Join-Path $Target 'KingswayWorkshop.dll') @arguments 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        $detail = if (Test-Path -LiteralPath $errorFile) { (Get-Content -LiteralPath $errorFile -TotalCount 3) -join "`n" } else { $output }
        throw "The Workshop reported an error:`n$detail"
    }
    return $output
}

try {
    Write-Host 'Kingsway Enemy Workshop installer' -ForegroundColor White
    if (!(Test-Path -LiteralPath (Join-Path $Source 'KingswayWorkshop.dll'))) {
        throw "KingswayModdingV2 was not found next to this installer. Extract the whole download first, then run Install.cmd from the extracted folder."
    }

    Step 'Finding Kingsway'
    if (!$GamePath) { $GamePath = Find-Kingsway }
    if (!$GamePath) {
        Info 'Kingsway was not found automatically. Choose its folder in the window that opens.'
        $GamePath = Pick-Folder
    }
    if (!$GamePath -or !(Test-Path -LiteralPath (Join-Path $GamePath 'data.win'))) { throw 'That folder does not contain Kingsway (data.win is missing).' }
    $GamePath = (Resolve-Path -LiteralPath $GamePath).Path
    $Target = Join-Path $GamePath 'KingswayModdingV2'
    Ok $GamePath

    if (!(Can-Write $GamePath)) {
        if ($Elevated) { throw "Cannot write to $GamePath even as administrator." }
        Info 'Administrator permission is needed to write to the game folder. Approve the Windows prompt to continue.'
        $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-GamePath', "`"$GamePath`"", '-Elevated')
        Start-Process -FilePath (Get-Process -Id $PID).Path -ArgumentList $arguments -Verb RunAs
        return
    }

    while (Get-Process -Name Kingsway -ErrorAction SilentlyContinue) {
        Read-Host '   Kingsway is running. Close the game, then press Enter'
    }

    Step 'Checking the game version'
    $legacyBackup = Join-Path $GamePath 'KingswayModding\backup\data.win'
    $ownBackup = Join-Path $Target 'Recovery\original\data.win'
    if ((Test-Path -LiteralPath $legacyBackup) -or (Test-Path -LiteralPath $ownBackup)) {
        Ok 'An original data.win backup already exists.'
    } elseif ((Get-FileHash -LiteralPath (Join-Path $GamePath 'data.win') -Algorithm SHA256).Hash -eq $OriginalHash) {
        Ok 'Unmodded Kingsway 1.2.1 found.'
    } else {
        Info 'data.win is not the unmodded Kingsway 1.2.1 file. Opening Steam to verify the game files...'
        Start-Process "steam://validate/$KingswayAppId"
        throw 'When Steam finishes verifying Kingsway, run Install.cmd again. (If Steam says the files are fine, this Kingsway version is not supported.)'
    }

    Step 'Checking .NET 10'
    $script:Dotnet = Find-Dotnet
    if ($script:Dotnet) {
        Ok '.NET 10 runtime found.'
    } else {
        $installer = Join-Path $env:TEMP 'dotnet-runtime-10-win-x64.exe'
        Download $DotnetUrl $installer
        $signature = Get-AuthenticodeSignature -FilePath $installer
        if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'O=Microsoft Corporation') { throw 'The downloaded .NET installer is not signed by Microsoft; stopping.' }
        Info 'Installing .NET 10 (approve the Windows prompt if asked)...'
        $process = Start-Process -FilePath $installer -ArgumentList '/install', '/passive', '/norestart' -Wait -PassThru
        Remove-Item -LiteralPath $installer -Force -ErrorAction SilentlyContinue
        if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 3010) { throw ".NET installer exited with code $($process.ExitCode)." }
        $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
        $script:Dotnet = Find-Dotnet
        if (!$script:Dotnet) { throw '.NET 10 was installed but could not be found. Restart Windows and run Install.cmd again.' }
        Ok '.NET 10 installed.'
    }

    Step 'Checking UndertaleModTool'
    $utmt = Join-Path $GamePath 'UndertaleModdingTool'
    if (Test-Path -LiteralPath (Join-Path $utmt 'UndertaleModLib.dll')) {
        $version = (Get-Item -LiteralPath (Join-Path $utmt 'UndertaleModLib.dll')).VersionInfo.FileVersion
        if ($version -ne '0.9.2.0') { Write-Host "   UndertaleModTool $version found; the Workshop is made for 0.9.2.0." -ForegroundColor Yellow } else { Ok 'UndertaleModTool 0.9.2.0 found.' }
    } else {
        $zip = Join-Path $env:TEMP 'UndertaleModTool_v0.9.2.0-Windows.zip'
        if (!(Test-Path -LiteralPath $zip) -or (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash -ne $UtmtHash) { Download $UtmtUrl $zip }
        if ((Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash -ne $UtmtHash) { throw 'The UndertaleModTool download did not match the official 0.9.2.0 file; stopping.' }
        Info 'Extracting (this takes a moment)...'
        $staging = Join-Path $env:TEMP ('utmt-' + [guid]::NewGuid().ToString('N'))
        [IO.Compression.ZipFile]::ExtractToDirectory($zip, $staging)
        New-Item -ItemType Directory -Force -Path $utmt | Out-Null
        Copy-Item -Path (Join-Path $staging '*') -Destination $utmt -Recurse -Force
        Remove-Item -LiteralPath $staging -Recurse -Force
        Remove-Item -LiteralPath $zip -Force
        Ok "Installed to $utmt"
    }

    Step 'Installing the Workshop'
    $updating = Test-Path -LiteralPath (Join-Path $Target 'KingswayWorkshop.dll')
    if ($updating) {
        Info 'Existing Workshop found: updating the app. Your projects, mods and settings are kept.'
        # "stop" only succeeds while the Workshop is running; otherwise there is nothing to stop.
        if (Test-Path -LiteralPath (Join-Path $Target 'server.json')) { try { Workshop @('stop') | Out-Null } catch {} }
        Start-Sleep -Seconds 1
    }
    foreach ($file in Get-ChildItem -LiteralPath $Source -Recurse -File) {
        $relative = $file.FullName.Substring($Source.Length + 1)
        $destination = Join-Path $Target $relative
        $parts = $relative.Split('\')
        # Never replace a user's own projects, managed mods or enabled list.
        if ($parts[0] -in 'Projects', 'Mods' -and (Test-Path -LiteralPath (Join-Path $Target (Join-Path $parts[0] $parts[1])))) { continue }
        if ($relative -eq 'enabled.json' -and (Test-Path -LiteralPath $destination)) { continue }
        New-Item -ItemType Directory -Force -Path (Split-Path $destination) | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
        Unblock-File -LiteralPath $destination
    }
    Ok $Target

    Step 'First start (backs up data.win and reads the game; can take a minute)'
    Workshop @('status') | Out-Null
    Ok 'The Workshop is ready.'

    $sampleFiles = @(Get-ChildItem -LiteralPath $Samples -Filter '*.zip' -File -ErrorAction SilentlyContinue)
    if ($sampleFiles.Count -and (Ask "Import the $($sampleFiles.Count) sample enemies?" $true)) {
        Step 'Importing sample enemies'
        $results = Workshop (@('import') + ($sampleFiles | ForEach-Object { $_.FullName })) | ConvertFrom-Json
        foreach ($result in $results) {
            if ($result.error -and $result.error -match 'already exists') { Info "$($result.file): already imported" }
            elseif ($result.error) { Write-Host "   $($result.file): $($result.error)" -ForegroundColor Yellow }
            else { Ok "$($result.file): imported" }
        }
        if (Ask 'Build the enabled mods and install them into Kingsway now?' $false) {
            Step 'Building and installing mods'
            Workshop @('build') | Out-Null
            Workshop @('install') | Out-Null
            Ok 'Installed. Start Kingsway to meet them. "Restore exact original" in the Mod manager undoes this.'
        } else {
            Info 'To use them in the game later: Mod manager > Rebuild & install.'
        }
    }

    $launcher = Join-Path $Target 'Start Workshop.vbs'
    if (Ask 'Create a desktop shortcut?' $true) {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Desktop')) 'Kingsway Enemy Workshop.lnk'))
        $shortcut.TargetPath = Join-Path $env:WINDIR 'System32\wscript.exe'
        $shortcut.Arguments = "`"$launcher`""
        $shortcut.WorkingDirectory = $Target
        $shortcut.IconLocation = (Join-Path $GamePath 'Kingsway.exe') + ',0'
        $shortcut.Save()
        Ok 'Shortcut created.'
    }

    Step 'Done'
    Info "The Workshop is in $Target"
    Info 'Start it any time with "Start Workshop.cmd" in that folder.'
    if (Ask 'Open the Workshop now?' $true) { Start-Process -FilePath (Join-Path $env:WINDIR 'System32\wscript.exe') -ArgumentList "`"$launcher`"" -WorkingDirectory $Target }
} catch {
    Write-Host ''
    Write-Host "Installation stopped: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ''
Read-Host 'Press Enter to close'
