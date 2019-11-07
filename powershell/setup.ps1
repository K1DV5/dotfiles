$deployPath = "D:\Documents\WindowsPowershell\profile.ps1"
del $deployPath
cmd /c mklink $deployPath $PWD\profile.ps1
