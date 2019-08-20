
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineOption -HistoryNoDuplicates: $True
function prompt {
    $time = get-date -Format "HH:mm"
    write-host "$pwd" -ForegroundColor Blue
    write-host "$time" -NoNewline -ForegroundColor White
    write-host " $" -NoNewline -ForegroundColor Green
    return " "
}
