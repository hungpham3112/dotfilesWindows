winfetch

# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

$omp_config = Join-Path $env:POSH_THEMES_PATH "montys.omp.json"
oh-my-posh init pwsh --config $omp_config | Invoke-Expression

# PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar

# Env
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"
$env:JULIA_NUM_THREADS = 8

# refreshenv is using to handle the bug with sync environment in pwsh.
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

# Alias
Set-Alias rfenv refreshenv
