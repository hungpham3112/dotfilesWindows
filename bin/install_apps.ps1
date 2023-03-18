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

function CloneRepo {
    if (![System.IO.Directory]::Exists($ConfigRoot)) {
        git clone https://github.com/hungpham3112/.dotfiles_Windows.git $ConfigRoot
    } else {
        rd $ConfigRoot -Recurse -Force
        git clone https://github.com/hungpham3112/.dotfiles_Windows.git $ConfigRoot
        git config --global --add safe.directory $ENV:USERPROFILE/scoop
    }
}

function InstallScoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "[Success] " -ForegroundColor Green -NoNewline
        Write-Host "Scoop is already installed."
    } else {
        try {
            Write-Host "Installing scoop..."
            # Handle installation in administrator privilege
            if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole] "Administrator")) {
                iwr -useb get.scoop.sh -outfile 'install.ps1'
                .\install.ps1 -RunAsAdmin | Out-Null
                del .\install.ps1 2>$null
            } else {
                iwr -useb get.scoop.sh | iex
            }
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
        git config --system --unset credential.helper >$null 2>$null
    } else {
        scoop install git >$null
        git config --system --unset credential.helper >$null 2>$null
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
    scoop install sudo
    sudo scoop import $ConfigRoot/scoop/apps.json
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
        Write-Host "$action $name settings successfully."
    } else {
        Write-Host "[Fail] " -ForegroundColor Red -NoNewline
        Write-Host "$action $name settings fail."
    }
}

function SymlinkPSSettings {
    $ProfilePath = "$PSHOME/profile.ps1"
    $ProfileParent = $PSHOME
    $ProfileLeaf = Split-Path $ProfilePath -Leaf
    if (![System.IO.File]::Exists($ProfileParent)) {
        mkdir $ProfileParent 1>$null 2>$null
        sudo New-Item -ItemType symboliclink -Path $ProfileParent -name $ProfileLeaf -value $ConfigRoot\powershell\Microsoft.PowerShell_profile.ps1
    } else {
        Remove-Item $ProfilePath 1>$null 2>$null
        sudo New-Item -ItemType symboliclink -Path $ProfileParent -name $ProfileLeaf -value $ConfigRoot\powershell\Microsoft.PowerShell_profile.ps1
    }
    CheckSuccessful "Symlink" "Powershell"
}

function SymlinkWTSettings {
    $WTSettingsPath = "$ENV:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    $WTSettingsParent = Split-Path $WTSettingsPath -Parent
    $WTSettingsLeaf = Split-Path $WTSettingsPath -Leaf
    if (![System.IO.File]::Exists($WTSettingsPath)) {
        mkdir $WTSettingsParent 1>$null 2>$null
        sudo New-Item -ItemType symboliclink -Path $WTSettingsParent -name $WTSettingsLeaf -value $ConfigRoot\powershell\settings.json
    } else {
        # Force to overwrite the WindowsTerminal's default settings
        sudo New-Item -ItemType symboliclink -Path $WTSettingsParent -name $WTSettingsLeaf -value $ConfigRoot\powershell\settings.json -Force
    }
    CheckSuccessful "Symlink" "Windows Terminal"
}

function SymlinkAlacrittySettings {
    $AlacrittySettingsPath = "$ENV:APPDATA\alacritty\alacritty.yml"
    $AlacrittySettingsParent = Split-Path $AlacrittySettingsPath -Parent
    $AlacrittySettingsLeaf = Split-Path $AlacrittySettingsPath -Leaf
    if (![System.IO.File]::Exists($AlacrittySettingsPath)) {
        mkdir $AlacrittySettingsParent 1>$null 2>$null
        sudo New-Item -ItemType symboliclink -Path $AlacrittySettingsParent -name $AlacrittySettingsLeaf -value $ConfigRoot\alacritty\alacritty.yml
    } else {
        Remove-Item $PROFILE 1>$null 2>$null
        sudo New-Item -ItemType symboliclink -Path $AlacrittySettingsParent -name $AlacrittySettingsLeaf -value $ConfigRoot\alacritty\alacritty.yml
    }
    CheckSuccessful "Symlink" "Alacritty"
}

function ClonePythonRepo {
    sudo git clone https://github.com/hungpham3112/PythonProjects.git $HOME/PythonProjects
    CheckSuccessful "Clone" "Python repository"
}

function CloneJuliaRepo {
    sudo git clone https://github.com/hungpham3112/JuliaProjects.git $HOME/JuliaProjects
    CheckSuccessful "Clone" "Julia repository"
}

function SymlinkJuliaStartupFile {
    $JuliaStartupFilePath = "$ENV:USERPROFILE/.julia/config/startup.jl"
    $JuliaStartupFileParent = Split-Path $JuliaStartupFilePath -Parent
    $JuliaStartupFileLeaf = Split-Path $JuliaStartupFilePath -Leaf
    if (![System.IO.File]::Exists($AlacrittySettingsPath)) {
        mkdir $JuliaStartupFileParent 1>$null 2>$null
        sudo New-Item -ItemType symboliclink -Path $JuliaStartupFileParent -name $JuliaStartupFileLeaf -value $ConfigRoot\julia\startup.jl
    } else {
        Remove-Item $PROFILE 1>$null 2>$null
        sudo New-Item -ItemType symboliclink -Path $JuliaStartupFileParent -name $JuliaStartupFileLeaf -value $ConfigRoot\julia\startup.jl
    }
    CheckSuccessful "Symlink" "Julia startup file"
}

function Main {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    PrintLogo
    InstallScoop
    InstallGit
    CloneRepo
    InstallApps
    SymlinkPSSettings
    SymlinkWTSettings
    SymlinkAlacrittySettings
    SymlinkJuliaStartupFile
    CloneJuliaRepo
    ClonePythonRepo
    PrintFinalMessage
}

Main
