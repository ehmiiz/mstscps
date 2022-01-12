class Name : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $Global:Name = (Import-Csv $Global:SessionCSV -Delimiter ";")
        return ($Global:Name).Name
    }
}
function Connect-MstscSession {
    <#
    .SYNOPSIS
        Connects to session Sessions
    .DESCRIPTION
        etc
    .EXAMPLE
        PS C:\> Connect-MstscSession
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
        $Name,
        $Secret
    )
    Begin {
        #1. Create credentials for the $name, pws using secretmgmt
        #2. Store credentials for the $name, pws using secretmgmt
        if (Get-Module -Name Microsoft.PowerShell.SecretManagement -ListAvailable) {
            if ($Secret) {
                try {
                    $Private:SecretMgmtEntry = Get-Secret $Secret
                    $Private:User = $Private:SecretMgmtEntry.UserName
                    $Private:Password = $SecretMgmtEntry.GetNetworkCredential().Password
                    # save information using cmdkey.exe
                    $null = cmdkey.exe /generic:$Name /user:$Private:User /pass:$Private:Password
                }
                catch {
                    Write-Error $Error[0]
                    Break
                }
            }
            else {
                Write-Warning "SecretManagement is installed but no secret was provided"
            }
        }
        else {
            Write-Warning "SSO in this module is dependent on the module MS.PS.SecretMgmt"
        }

        if ($name) {
            Start-Process -FilePath "C:\Windows\System32\mstsc.exe" -ArgumentList "/w:1430", "/h:1000", "/V:$Name"
            Start-Sleep -Seconds 2 # to delay the removal because of mstsc delay on startup
            Start-Process -FilePath "C:\Windows\System32\cmdkey.exe" -ArgumentList "/delete:$Name"
        }
        else {
            $Name = (Get-MstscSession | Out-ConsoleGridView -Title "ServerList" -OutputMode Single).Name
            $null = cmdkey.exe /generic:$Name /user:$Private:User /pass:$Private:Password
            Start-Process -FilePath "C:\Windows\System32\mstsc.exe" -ArgumentList "/w:1430", "/h:1000", "/V:$Name"
            Start-Sleep 2 # to delay the removal because of mstsc delay on startup
            Start-Process -FilePath "C:\Windows\System32\cmdkey.exe" -ArgumentList "/delete:$Name"
        }
    }
}