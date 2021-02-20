$Global:ConfigPath = "$($env:APPDATA)\Powershell\Mstscps\config.json"
$Global:ConfigData = Get-Content $Global:ConfigPath | ConvertFrom-Json

if ($Global:ConfigData.Path) {
    #Path set in config already
    Write-Output "SessionPath is: $($Global:ConfigData.Path)"
    $Script:SessionsPath = $Global:ConfigData.Path
}
else {
    $Script:SessionsPath = "$($env:APPDATA)\Powershell\Mstscps\sessions.csv"
    $null = New-Item $Script:SessionsPath -Force
    $null = New-Item $Global:ConfigPath -Force
    Set-MstscSessionPath $Script:SessionsPath
}