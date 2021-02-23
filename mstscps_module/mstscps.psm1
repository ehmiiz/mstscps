class Name : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $Global:Name = (Import-Csv $Global:SessionsPath -Delimiter ";")
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
        $Name,
        [switch]$Edit
    )

    Begin {
        
        if ($name) {
            $Sessions = Import-Csv $Global:SessionsPath -Delimiter ";"
            $Return = $Sessions | Where-Object -Property Name -eq $name
            return $Return
        }
        elseif ($Edit) {
            notepad $Global:SessionsPath
        }
        else {
            $Sessions = Import-Csv $Global:SessionsPath -Delimiter ";"
            $Sessions
        }
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
            Start-Process -FilePath "C:\Windows\System32\mstsc.exe" -ArgumentList "/w:1230", "/h:693", "/V:$Name"
            Start-Sleep -Seconds 2 # to delay the removal because of mstsc delay on startup
            Start-Process -FilePath "C:\Windows\System32\cmdkey.exe" -ArgumentList "/delete:$Name"
        }
        else {
            $Name = (Get-MstscSession | Out-ConsoleGridView -Title "ServerList" -OutputMode Single).Name
            $null = cmdkey.exe /generic:$Name /user:$Private:User /pass:$Private:Password
            Start-Process -FilePath "C:\Windows\System32\mstsc.exe" -ArgumentList "/w:1230", "/h:693", "/V:$Name"
            Start-Sleep 2 # to delay the removal because of mstsc delay on startup
            Start-Process -FilePath "C:\Windows\System32\cmdkey.exe" -ArgumentList "/delete:$Name"
        }
    }
}

# Sets MstscSessionPath
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
        $Global:SessionsPath = $Path # Needs to have a check for if the user applied a supported file format (CSV)
        Write-Output "Path set: ""$Global:SessionsPath"""
        [PSCustomObject]@{
            Path = $Global:SessionsPath
        } | ConvertTo-Json | Out-File $Global:ConfigPath -Force
    }
}

# Gets MstscSesssion DataPath
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
}

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