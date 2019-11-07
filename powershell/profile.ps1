
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineOption -HistoryNoDuplicates: $True
# function prompt {
#     $time = get-date -Format "HH:mm"
#     write-host "$pwd" -ForegroundColor Blue
#     write-host "$time" -NoNewline -ForegroundColor White
#     write-host " $" -NoNewline -ForegroundColor Cyan
#     return " "
# }

New-Alias gpg D:\K1DV5\DevPrograms\gnupg\bin\gpg
# Set-Alias curl D:\K1DV5\DevPrograms\Neovim\bin\curl

# hehe, sudo!
function sudo {
    $executable, $arguments = $args.Split(" ", 2)
    if ($arguments) {
        Start-Process $executable -args $arguments -Verb runAs
    } else {
        Start-Process $executable -Verb runAs
    }
}

New-Alias chrome "C:\Program Files (x86)\Google\Chrome\Application\chrome"
New-Alias 7z D:\K1DV5\DevPrograms\7-z\7z

# posh-git installation and update
# PowerShellGet\Install-Module posh-git -Scope CurrentUser -AllowPrerelease -Force
# PowerShellGet\Update-Module posh-git
Import-Module D:\Documents\WindowsPowerShell\Modules\posh-git\src\posh-git.psd1
# $GitPromptSettings.DefaultPromptPath = $(Get-PromptPath)
$GitPromptSettings.DefaultPromptPath = get-date -Format "HH:mm"

$GitPromptSettings.DefaultPromptSuffix = $(" $ " * ($nestedPromptLevel + 1))
