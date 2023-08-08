# ===== WINFETCH CONFIGURATION =====

$currentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$imagesFolder = Join-Path -Path $currentDir -ChildPath "images"

# Array of image file extensions to filter
$imageExtensions = @(".jpg", ".jpeg", ".png", ".gif")

# Function to recursively find image file paths
function Get-ImageFilePaths {
    param (
        [string]$folder,
        [string[]]$extensions
    )
    
    Get-ChildItem -Path $folder -Recurse | Where-Object {
        $_.Extension -in $extensions
    } | Select-Object -ExpandProperty FullName
}

# Get image file paths
$imageFilePaths = Get-ImageFilePaths -folder $imagesFolder -extensions $imageExtensions

# Output the list of image file paths
$image = Get-Random $imageFilePaths

# Rest of your WinFetch configuration here...
$logo = "Windows 10"
$ShowDisks = @("C:")
$ShowPkgs = @("scoop")
function info_custom_time {
    return @{
        title = "Time"
        content = (Get-Date)
    }
}

@(
    "title"
    "dashes"
    "os"
    "computer"
    "kernel"
    "motherboard"
    "pkgs"
    "pwsh"
    "resolution"
    "terminal"
    "cpu"
    "gpu"
    "memory"
    "disk"
    "custom_time"
    "blank"
    "colorbar"
)
