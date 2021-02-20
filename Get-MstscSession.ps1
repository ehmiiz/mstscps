class Name : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $Global:Name = (Import-Csv $Global:SessionCSV -Delimiter ";")
        return ($Global:Name).Name
    }
}
function Get-MstscSession {
    <#
.SYNOPSIS
    Gets a list of Mstsc Sessions
.DESCRIPTION
    The list of sessions will contain information about the host
     that is available for connection
.EXAMPLE
    PS C:\> Get-MstscSession
    Displays all sessions
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
    param (
        [ValidateSet([Name], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        $Name
    )

    Begin {
        $Sessions = Import-Csv $Global:ConfigData.Path -Delimiter ";"
        if ($name) {
            $Return = $Sessions | Where-Object -Property Name -eq $name
            return $Return
        }
        else {
            $Sessions
        }
    }
}