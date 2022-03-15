# ===== WINFETCH CONFIGURATION =====

 #$image = "$env:USERPROFILE/.config/winfetch/image.png"
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
