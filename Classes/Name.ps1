class Name : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $Global:Name = (Import-Csv $Global:SessionsPath -Delimiter ";")
        return ($Global:Name).Name
    }
}