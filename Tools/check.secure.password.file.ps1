$CredentialsUserName = "wsm.powershell.account";
$CredentialsPasswordFile = Get-Content ("..\Store\{0}.pwd" -f $CredentialsUserName);
$CredentialsSecurePassword = $CredentialsPasswordFile | ConvertTo-SecureString;
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList ($CredentialsUserName, $CredentialsSecurePassword);
$PlainPassword = $Credentials.GetNetworkCredential().Password;
$Credentials | Format-List;
$PlainPassword;