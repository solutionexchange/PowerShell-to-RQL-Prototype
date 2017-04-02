$CredentialsInput = Get-Credential -Message ("Please type the password for WSM Account:");
$CredentialsUserName = $CredentialsInput.GetNetworkCredential().Username;
$CredentialsPassword = $CredentialsInput.GetNetworkCredential().Password;
if ($CredentialsUserName) {
    $CredentialsSecureStringPassword = $CredentialsPassword | ConvertTo-SecureString -AsPlainText -Force;
    $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList ($CredentialsUserName, $CredentialsSecureStringPassword);
    $secureStringOutPut = $CredentialsSecureStringPassword | ConvertFrom-SecureString;
    Set-Content ("..\Store\{0}.pwd" -f $CredentialsUserName) ($secureStringOutPut);
}