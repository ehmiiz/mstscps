$Global:ConfigPath = "$($env:APPDATA)\Powershell\Mstscps\config.json"
$Script:SessionsPath = "$($env:APPDATA)\Powershell\Mstscps\sessions.csv"

$ConfigData = Get-Content $Global:ConfigPath | ConvertFrom-Json
if ($ConfigData.Path) {
    #Path set in config already
    Write-Output "SessionPath is: $(Get-MstscSessionPath)"
}
else {
    $null = New-Item $Script:SessionsPath -Force
    $null = New-Item $Global:ConfigPath -Force
    Set-MstscSessionPath $Script:SessionsPath
}