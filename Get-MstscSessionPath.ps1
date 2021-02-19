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
        Write-Output $Global:SessionCSV
    }