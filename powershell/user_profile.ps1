winfetch

# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

$omp_config = Join-Path $PSScriptRoot "night-owl.omp.json"
oh-my-posh --init --shell pwsh --config $omp_config | Invoke-Expression

# PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar

# Env
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"

function clear { Clear-Host; winfetch }
function refreshenv {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
function mcd {
   [CmdletBinding()]
   param(
      [Parameter(Mandatory = $true)]
      $Path
   )

   New-Item -Path $Path -ItemType Directory

   Set-Location -Path $Path
}
Remove-Alias cls, clear

# Alias
Set-Alias rfenv refreshenv
Set-Alias ll ls 
Set-Alias g git
Set-Alias grep findstr
Set-Alias cls clear
