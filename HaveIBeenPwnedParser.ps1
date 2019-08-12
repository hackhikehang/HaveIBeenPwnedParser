# HaveIBeenPwnedParser.ps1
Import-Module ActiveDirectory
cls

$continue = $true

# update for most recent spreadsheet

$pwnedAccounts = Import-Csv "C:\Temp\Pwned email accounts.csv"

while ($continue -eq "y") {
    $filteredPwnedAccounts = @()


    $breachNotificationTerm = Read-Host -Prompt 'Please enter the breach name from the HaveIBeenPwned export'
    ""
    foreach ($pwnedAccount in $pwnedAccounts) {
        $pwnedObject = New-Object -TypeName psobject
        if ($pwnedAccount.Breach -like "*$($breachNotificationTerm)*") {
            $user = Get-ADuser -filter "EmailAddress -eq '$($pwnedAccount.Email)'" -Properties * 
            $pwnedObject | Add-Member -MemberType NoteProperty -Name PwnedEmail -Value $pwnedAccount.Email
            $pwnedObject | Add-Member -MemberType NoteProperty -Name PasswordLastSet -Value $user.PasswordLastSet
            $pwnedObject | Add-Member -MemberType NoteProperty -Name Active -Value $user.Enabled

            $filteredPwnedAccounts += $pwnedObject
        }
    }


    "Accounts found: $($filteredPwnedAccounts.count)"
    "==================================="
    $generateReport = Read-Host -Prompt "Would you like to generate a CSV? Y/N"
    if ($generateReport -eq 'y') {
        $date = Get-Date -UFormat %Y%m%d
        $CSVExport = "C:\Temp\HIBP_$($breachNotificationTerm)_$($date).csv"
        $filteredPwnedAccounts | Export-Csv $CSVExport -NoTypeInformation
    }
    ""

    $continue = Read-Host -Prompt "Would you like to run another query on this dataset? Y/N"

}


