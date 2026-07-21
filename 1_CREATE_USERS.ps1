$PASSWORD_FOR_USERS = "Password1"
$USER_FIRST_LAST_LIST = Get-Content .\names.txt  

$password = ConvertTo-SecureString $PASSWORD_FOR_USERS -AsPlainText -Force
New-ADOrganizationalUnit -Name _USERS -ProtectedFromAccidentalDeletion $false

$nameTracker = @{}

foreach ($n in $USER_FIRST_LAST_LIST) {
    $first = $n.Split(" ")[0].ToLower()
    $last = $n.Split(" ")[1].ToLower()
    $firstStartLetter = $first.Chars(0)
    
    $baseUsername = "$firstStartLetter$last"
    
    if ($nameTracker.ContainsKey($baseUsername)) {
        $nameTracker[$baseUsername]++
    } else {
        $nameTracker[$baseUsername] = 1
    }
    
    $numberSuffix = "{0:D2}" -f $nameTracker[$baseUsername]
    $username = "$baseUsername$numberSuffix"
    Write-Host "Creating user: $($username)" -BackgroundColor Black -ForegroundColor Cyan

    New-AdUser -AccountPassword $password `
            -GivenName $first `
            -Surname $last `
            -DisplayName $username `
            -Name $username `
            -EmployeeID $username `
            -PasswordNeverExpires $true `
            -Path "ou=_USERS,$(([ADSI]`"").distinguishedName)" `
            -Enabled $true
}