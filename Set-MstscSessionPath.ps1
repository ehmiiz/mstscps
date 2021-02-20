function Set-MstscSessionPath {
    <#
    .DESCRIPTION
        Sets the path to the CSV file with Sessions
    .EXAMPLE
        PS C:\> Set-MstscSessionpath C:\Users\MyUser\MySessions.csv
        Sets the path to the CSV file MySessions, the file must be ";" separated and
            have the headers Name;Description; in it.
    #>
    param (
        $Path
    )
    Begin {
        $Global:SessionCSV = $Path # Needs to have a check for if the user applied a supported file format (CSV)
        Write-Output "Path set: ""$Global:SessionCSV"""
        [PSCustomObject]@{
            Path = $Global:SessionCSV
        } | ConvertTo-Json | Out-File $Global:ConfigPath -Force
    }
}