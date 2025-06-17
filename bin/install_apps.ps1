Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
$ConfigRoot = "$ENV:USERPROFILE\.config\"

function PrintLogo {
    $Logo = @'

     $$$$$$\                                      $$$$$$\                       $$\               $$\ $$\                     
    $$  __$$\                                     \_$$  _|                      $$ |              $$ |$$ |                    
    $$ /  $$ | $$$$$$\   $$$$$$\   $$$$$$$\         $$ |  $$$$$$$\   $$$$$$$\ $$$$$$\    $$$$$$\  $$ |$$ | $$$$$$\   $$$$$$\  
    $$$$$$$$ |$$  __$$\ $$  __$$\ $$  _____|        $$ |  $$  __$$\ $$  _____|\_$$  _|   \____$$\ $$ |$$ |$$  __$$\ $$  __$$\ 
    $$  __$$ |$$ /  $$ |$$ /  $$ |\$$$$$$\          $$ |  $$ |  $$ |\$$$$$$\    $$ |     $$$$$$$ |$$ |$$ |$$$$$$$$ |$$ |  \__|
    $$ |  $$ |$$ |  $$ |$$ |  $$ | \____$$\         $$ |  $$ |  $$ | \____$$\   $$ |$$\ $$  __$$ |$$ |$$ |$$   ____|$$ |      
    $$ |  $$ |$$$$$$$  |$$$$$$$  |$$$$$$$  |      $$$$$$\ $$ |  $$ |$$$$$$$  |  \$$$$  |\$$$$$$$ |$$ |$$ |\$$$$$$$\ $$ |      
    \__|  \__|$$  ____/ $$  ____/ \_______/       \______|\__|  \__|\_______/    \____/  \_______|\__|\__| \_______|\__|      
              $$ |      $$ |                                                                                                  
              $$ |      $$ |                                                                                                  
              \__|      \__|    

Welcome to Apps Installer <3
'@
    Write-Host $Logo -ForegroundColor Green
}

function CheckSuccessful {
    param (
        [string] $action,
        [string] $name
    )
    # $? is a variable return the state of the latest command
    # i.e: True if the previous command run successfully and vice versa.
    if ($?) {
        Write-Host "[Success] " -ForegroundColor Green -NoNewline
        Write-Host "$action $name successfully."
    } else {
        Write-Host "[Fail] " -ForegroundColor Red -NoNewline
        Write-Host "$action $name fail."
    }
}

function CloneDotfiles {
    if (![System.IO.Directory]::Exists($ConfigRoot)) {
        git clone https://github.com/hungpham3112/.dotfilesWindows.git $ConfigRoot
    } else {
        rd $ConfigRoot -Recurse -Force
        git clone https://github.com/hungpham3112/.dotfilesWindows.git $ConfigRoot
        git config --global --add safe.directory $ENV:USERPROFILE/scoop
    }
}

function InstallScoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "[Success] " -ForegroundColor Green -NoNewline
        Write-Host "Scoop is already installed."
    } else {
        try {
            Write-Host "Installing scoop..." -ForegroundColor Green -NoNewline
            # Handle installation in administrator privilege
            if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole] "Administrator")) {
                iwr -useb get.scoop.sh -outfile 'install.ps1'
                .\install.ps1 -RunAsAdmin | Out-Null
                del .\install.ps1 2>$null
            } else {
                iwr -useb get.scoop.sh | iex
            }
            CheckSuccessful "Install" "Scoop"
        }
        catch {
            Write-Host "[Fail] " -ForegroundColor Red -NoNewline
            Write-Host "An error occurred while installing scoop. Please run installer again..."
            rd $ENV:USERPROFILE/scoop -Recurse -Force >$null 2>$null
        }
    }
}

function InstallGit {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Host "[Success] " -ForegroundColor Green -NoNewline
        Write-Host "Git is already installed."
        git config --global credential.helper manager >$null 2>$null
    } else {
        Write-Host "Installing git..." -ForegroundColor Green 
        scoop install git >$null
        git config --global credential.helper manager >$null 2>$null
        CheckSuccessful "Install" "Git"
    }
}

function PrintFinalMessage {
    $FinalMessage = @"
    ------------------------------------------------------------
    ------------------- Setting up done <3 ---------------------
    ------------------------------------------------------------
"@
    Write-Host $FinalMessage -ForegroundColor Green
}

function InstallApps {
    scoop install gsudo
    gsudo config ForceAttachedConsole true
    gsudo scoop import $ConfigRoot/scoop/apps.json
}


function SymlinkPSSettings {
    Write-Host "Creating symlinks for Windows Powershell Settings..." -ForegroundColor Green 
    $ProfileParent = Split-Path $PROFILE -Parent
    $ProfileLeaf = Split-Path $PROFILE -Leaf
    if (![System.IO.File]::Exists($Profile)) {
        mkdir $ProfileParent 1>$null 2>$null
        gsudo New-Item -ItemType symboliclink -Path $ProfileParent -name $ProfileLeaf -value $ConfigRoot\powershell\Microsoft.PowerShell_profile.ps1
    } else {
        Remove-Item $PROFILE 1>$null 2>$null
        gsudo New-Item -ItemType symboliclink -Path $ProfileParent -name $ProfileLeaf -value $ConfigRoot\powershell\Microsoft.PowerShell_profile.ps1
    }
    CheckSuccessful "Symlink" "Windows Powershell Settings"
}

function ExecuteScriptInNewPwshSession {
    param (
        [scriptblock] $ScriptBlock
    )
    $proc = Start-Process pwsh.exe `
        -ArgumentList "-NoProfile", "-Command", "& { $ScriptBlock }" `
        -Wait -PassThru
    return $proc.ExitCode
}

function SymlinkPSSettingsInNewPwshSession {
    Write-Host "Creating symlinks for Powershell Settings..." -ForegroundColor Green

    $ScriptBlock = {
        Set-StrictMode -Version Latest
        $ErrorActionPreference = 'Stop'
        
        try {
            $ProfileParent = Split-Path $PROFILE -Parent
            $ProfileLeaf   = Split-Path $PROFILE -Leaf
            $Target        = Join-Path $env:USERPROFILE '.config\powershell\Microsoft.PowerShell_profile.ps1'

            if (-not $ProfileParent -or -not $ProfileLeaf -or -not $Target) {
                throw "One or more required variables are null or empty"
            }

            if (-not (Test-Path $ProfileParent)) {
                New-Item -ItemType Directory -Path $ProfileParent -Force
            }

            if (Test-Path $PROFILE) {
                Remove-Item $PROFILE -Force
            }

            gsudo New-Item -ItemType SymbolicLink `
                -Path  $ProfileParent `
                -Name  $ProfileLeaf `
                -Value $Target `
                -Force

            if ($LASTEXITCODE -ne 0) {
                throw "gsudo command failed with exit code: $LASTEXITCODE"
            }

            if (-not (Test-Path $PROFILE)) {
                throw "Symlink creation failed - profile path does not exist"
            }

            exit 0
        }
        catch {
            exit 1
        }
    }

    $exitCode = ExecuteScriptInNewPwshSession -ScriptBlock $ScriptBlock
    if ($exitCode -ne 0) {
        cmd /c exit $exitCode
    }

    CheckSuccessful "Symlink" "Powershell Settings"
}

function SymlinkWTSettings {
    Write-Host "Creating symlinks for Windows Terminal Settings..." -ForegroundColor Green

    $TargetSettings = "$ConfigRoot\powershell\settings.json"

    $WTSettingsPaths = @(
        "$ENV:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json",
        "$ENV:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    )

    foreach ($WTSettingsPath in $WTSettingsPaths) {
        $WTSettingsParent = Split-Path $WTSettingsPath -Parent
        $WTSettingsLeaf = Split-Path $WTSettingsPath -Leaf

        mkdir $WTSettingsParent -Force | Out-Null

        sudo powershell -Command "Remove-Item -Path "$WTSettingsPath" -Force -ErrorAction SilentlyContinue"
        sudo powershell -Command "New-Item -ItemType SymbolicLink -Path "$WTSettingsParent" -Name "$WTSettingsLeaf" -Value "$TargetSettings" -Force"
    }

    CheckSuccessful "Symlink" "Windows Terminal Settings"
}

function SymlinkAlacrittySettings {
    Write-Host "Creating symlinks for Alacritty Settings..." -ForegroundColor Green
    $AlacrittySettingsPath = "$ENV:APPDATA\alacritty\alacritty.toml"
    $AlacrittySettingsParent = Split-Path $AlacrittySettingsPath -Parent
    $AlacrittySettingsLeaf = Split-Path $AlacrittySettingsPath -Leaf
    if (![System.IO.File]::Exists($AlacrittySettingsPath)) {
        mkdir $AlacrittySettingsParent 1>$null 2>$null
        gsudo New-Item -ItemType symboliclink -Path $AlacrittySettingsParent -name $AlacrittySettingsLeaf -value $ConfigRoot\alacritty\alacritty.toml
    } else {
        Remove-Item $AlacrittySettingsPath 1>$null 2>$null
        gsudo New-Item -ItemType symboliclink -Path $AlacrittySettingsParent -name $AlacrittySettingsLeaf -value $ConfigRoot\alacritty\alacritty.toml
    }
    CheckSuccessful "Symlink" "Alacritty Settings"
}

function ClonePythonRepo {
    Write-Host "Cloning PythonProjects repo..." -ForegroundColor Green
    gsudo git clone https://github.com/hungpham3112/PythonProjects.git $HOME/PythonProjects
    CheckSuccessful "Clone" "Python repository"
}

function CloneJuliaRepo {
    Write-Host "Cloning JuliaProjects repo..." -ForegroundColor Green
    gsudo git clone https://github.com/hungpham3112/JuliaProjects.git $HOME/JuliaProjects
    CheckSuccessful "Clone" "Julia repository"
}

function SymlinkJuliaStartupFile {
    Write-Host "Creating symlinks for Julia Startup File..." -ForegroundColor Green
    $JuliaStartupFilePath = "$ENV:USERPROFILE/.julia/config/startup.jl"
    $JuliaStartupFileParent = Split-Path $JuliaStartupFilePath -Parent
    $JuliaStartupFileLeaf = Split-Path $JuliaStartupFilePath -Leaf
    if (![System.IO.File]::Exists($JuliaStartupFilePath)) {
        mkdir $JuliaStartupFileParent 1>$null 2>$null
        gsudo New-Item -ItemType symboliclink -Path $JuliaStartupFileParent -name $JuliaStartupFileLeaf -value $ConfigRoot\julia\startup.jl
    } else {
        Remove-Item $JuliaStartupFilePath 1>$null 2>$null
        gsudo New-Item -ItemType symboliclink -Path $JuliaStartupFileParent -name $JuliaStartupFileLeaf -value $ConfigRoot\julia\startup.jl
    }
    CheckSuccessful "Symlink" "Julia startup file"
}

function SymlinkSpicetifySettings {
    Write-Host "Creating symlinks for Spicetify Settings..." -ForegroundColor Green
    $SpicetifySettingsPath = "$ENV:APPDATA/spicetify/config-xpui.ini"
    $SpicetifySettingsParent = Split-Path $SpicetifySettingsPath -Parent
    $SpicetifySettingsLeaf = Split-Path $SpicetifySettingsPath -Leaf
    if (![System.IO.File]::Exists($SpicetifySettingsPath)) {
        mkdir $SpicetifySettingsParent 1>$null 2>$null
        gsudo New-Item -ItemType symboliclink -Path $SpicetifySettingsParent -name $SpicetifySettingsLeaf -value $ConfigRoot\spicetify\config-xpui.ini
    } else {
        Remove-Item $SpicetifySettingsPath 1>$null 2>$null
        gsudo New-Item -ItemType symboliclink -Path $SpicetifySettingsParent -name $SpicetifySettingsLeaf -value $ConfigRoot\spicetify\config-xpui.ini
    }
    CheckSuccessful "Symlink" "Spicetify"
}

function InstallSpicetifyMarketplace { 
    Write-Host "Installing Spicetify Marketplace..." -ForegroundColor Green
    iwr -useb https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.ps1 | iex
    CheckSuccessful "Install" "Spicetify Marketplace"
}

function RemoveBloatware {
    Write-Host "Removing Bloatware..." -ForegroundColor Green

    $Win11DebloatRoot = Join-Path $env:TEMP "Win11Debloat"
    if (Test-Path $Win11DebloatRoot -PathType Leaf) {
        Remove-Item $Win11DebloatRoot -Force
    }
    if (-not (Test-Path $Win11DebloatRoot -PathType Container)) {
        New-Item -ItemType Directory -Path $Win11DebloatRoot -Force | Out-Null
    }
    Copy-Item $ConfigRoot\win11debloat\CustomAppsList $Win11DebloatRoot -Force

    $fixedBlock = @'
$debloatScript = "$env:TEMP\Win11Debloat\Win11Debloat.ps1"
$lines = Get-Content $debloatScript
if ($lines.Count -gt 0) {
    $lines[0..($lines.Count - 2)] | Set-Content $debloatScript
}
'@
    $script = (irm "https://debloat.raphi.re/")
    $patchedScript = $script -replace '(?ms)(^\s*Write-Output\s+"> Running Win11Debloat\.\.\."\s*\r?\n)', "`$1$fixedBlock`r`n"   

    $patchedPath = "$env:TEMP\Win11Debloat\PatchedWin11Debloat.ps1"
    Set-Content -Path $patchedPath -Value $patchedScript -Encoding UTF8

    # Start a new PowerShell process to run the script silently
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$patchedPath`" -RemoveAppsCustom -DisableFastStartup -ShowHiddenFolders -ShowKnownFileExt -EnableDarkMode  -HideSearchTb  -HideTaskview -HideChat -DisableWidgets -EnableEndTask -HideHome -HideGallery -ExplorerToHome  -DisableRecall  -DisableCopilot  -DisableBing -DisableSettingsHome -DisableSettings365Ads -DisableLockscreenTips -DisableTelemetry -DisableDesktopSpotlight  -DisableSuggestions -DisableStartPhoneLink -DisableStartRecommended -ClearStartAllUsers -DisableDVR -RemoveGamingApps  -RemoveDevApps -RemoveCommApps -Silent" -WindowStyle Hidden -Wait

    CheckSuccessful "Remove" "Bloatware"
}

function Main {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    PrintLogo
    InstallScoop
    InstallGit
    CloneDotfiles
    InstallApps
    SymlinkPSSettingsInNewPwshSession
    SymlinkPSSettings
    SymlinkWTSettings
    SymlinkAlacrittySettings
    SymlinkJuliaStartupFile
    SymlinkSpicetifySettings
    RemoveBloatware
    CloneJuliaRepo
    ClonePythonRepo
    PrintFinalMessage
}

Main
