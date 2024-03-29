
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
                    # save information using cmdkey.exe
                    $s = Get-Secret $Secret
                    $null = cmdkey.exe /generic:$Name /user:$Secret /pass:(ConvertFrom-SecureString $s -AsPlainText)
                    # TODO: Make job that deletes secret in 3 sec instead of having line 50 and 56
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
            Start-Process -FilePath "C:\Windows\System32\mstsc.exe" -ArgumentList "/w:1430", "/h:1000", "/V:$Name"
            Start-Sleep 2 # to delay the removal because of mstsc delay on startup
            Start-Process -FilePath "C:\Windows\System32\cmdkey.exe" -ArgumentList "/delete:$Name"
        }
    }
}