function Get-MstscSessionPath {
    <#
.DESCRIPTION
    Gets the path to the CSV file with Sessions
.EXAMPLE
    PS C:\> Get-MstscSessionPath
    C:\Users\MyUser\MySessions.csv
    Gets the path to the CSV file MySessions, the file must be ";" separated and
     have the headers Name;Description; in it.
#>
    Write-Output $Global:ConfigData.Path


    $Global:ConfigPath = "$($env:APPDATA)\Powershell\Mstscps\config.json"
    $Global:ConfigData = Get-Content $Global:ConfigPath -ErrorAction SilentlyContinue | ConvertFrom-Json

    if ((Test-Path $Global:ConfigData.Path -ErrorAction SilentlyContinue)) {
        #Path set in config already
        Write-Output "SessionPath is: $($Global:ConfigData.Path)"
        $Global:SessionsPath = $Global:ConfigData.Path
    }
    else {
        $Global:SessionsPath = "$($env:APPDATA)\Powershell\Mstscps\sessions.csv"
        $null = New-Item $Global:SessionsPath -Force
        $null = New-Item $Global:ConfigPath -Force
        Set-MstscSessionPath -Path $Global:SessionsPath
    }
}