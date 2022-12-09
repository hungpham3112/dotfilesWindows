Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
$ConfigRoot = "$env:USERPROFILE\.config\"

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

function InstallScoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "[Success] " -ForegroundColor Green -NoNewline
        Write-Host "Scoop is already installed" 
    } else {
        try {
            Write-Host "Installing scoop..."
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
            rd $env:USERPROFILE/scoop -Recurse -Force >$null 2>$null
        }
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
    sudo scoop import $ConfigRoot/scoop/apps.txt 
}

function MovePSSettings {
    Copy-Item -Path $env:USERPROFILE\.config\powershell\Microsoft.PowerShell_profile.ps1 -Destination $PROFILE 2>$null
    if ($?) {
        Write-Host "[Success] " -ForegroundColor Green -NoNewline
        Write-Host "Move PowerShell settings successfully"
    } else {
        Write-Host "[Fail] " -ForegroundColor Red -NoNewline
        Write-Host "Move PowerShell settings fail"
    }
}

function Main {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    PrintLogo
    InstallScoop
    InstallApps
    MovePSSettings
    PrintFinalMessage
}

Main
