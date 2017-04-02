. "Lib.ps1";


# Replace Values in RQL Request
Function ReplaceValuesRQL ($RQL) {
    $XML = [xml]$RQL;
    If($XML.IODATA.HasAttributes) {
        $XML.IODATA.loginguid = $Global:StoreRQL.LoginGUID;
        $XML.IODATA.sessionkey = $Global:StoreRQL.SessionKey;
    }
    If($XML.IODATA.HasChildNodes) {
        If($XML.IODATA.GetElementsByTagName("ADMINISTRATION").action -eq "login") {
            $XML.IODATA.ADMINISTRATION.name = $Global:StoreRQL.Username;
            $XML.IODATA.ADMINISTRATION.password = $Global:StoreRQL.Password;
        }
        If($XML.IODATA.GetElementsByTagName("ADMINISTRATION").action -eq "validate") {
            $XML.IODATA.ADMINISTRATION.guid = $Global:StoreRQL.LoginGUID;
            If($XML.IODATA.ADMINISTRATION.HasChildNodes) {
                If($XML.IODATA.ADMINISTRATION.GetElementsByTagName("PROJECT").HasAttributes) {
                    $XML.IODATA.ADMINISTRATION.PROJECT.guid = $Global:StoreRQL.ProjectGUID;
                }
            }
        }
        If($XML.IODATA.GetElementsByTagName("ADMINISTRATION").HasChildNodes) {
            if($XML.IODATA.ADMINISTRATION.GetElementsByTagName("LOGOUT").HasAttributes) {
                $XML.IODATA.ADMINISTRATION.LOGOUT.guid = $Global:StoreRQL.LoginGUID;
            }
        }
    }
    $RQL = $XML.OuterXml;
    Return $RQL;
}


# Create Global Value Storage
$Global:StoreRQL = New-Object PSCustomObject;
$Global:StoreRQL | Add-Member -Type NoteProperty -Name ("Scriptname") -Value ($MyInvocation.MyCommand.Name) -Force;
$Global:StoreRQL | Add-Member -Type NoteProperty -Name ("Timestamp") -Value ([int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds) -Force;


# Show RQL Store
Function Show-RQLStore () {
    If ($Global:StoreRQL.PSObject.Properties.Count -gt 0) {
        # Show RQL Store Properties
        $Global:StoreRQL | Select-Object * -ExcludeProperty ("Proxy", "ErrorA", "ResultA", "Password") | Format-List;
        #$Global:StoreRQL | Select-Object * -ExcludeProperty ("Proxy", "ErrorA", "ResultA") | Format-List;
        # Show RQL Errors
        If ($Global:StoreRQL.ErrorA.Value) {
            Write-Host ("ErrorA : " + $Global:StoreRQL.ErrorA.Value) -ForegroundColor Red;
            Break;
        }
        # Show RQL Results
        If ($Global:StoreRQL.ResultA.Value) {
            Write-Host ("ResultA : " + $Global:StoreRQL.ResultA.Value);
        }
    }
}


# Open WebService Session
Function RQL-OpenSession () {
    $Global:StoreRQL.Timestamp = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds;
    Write-Host ("ACTION: Open Session");
    # Create New Properties in RQL Store
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("Proxy") -Value ("") -Force;
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("ErrorA") -Value ("") -Force;
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("ResultA") -Value ("") -Force;
    # Connect to WebService
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true};
    $Global:StoreRQL.Proxy = New-WebServiceProxy -Uri ('https://localhost/cms/WebService/RqlWebService.svc?WSDL');
    $Global:StoreRQL.ErrorA = [ref]$Global:StoreRQL.Proxy.value;
    $Global:StoreRQL.ResultA = [ref]$Global:StoreRQL.Proxy.value;
    # Display RQL Store Properties
    Show-RQLStore;
}


# Close WebService Session
Function RQL-CloseSession () {
    $Global:StoreRQL.Timestamp = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds;
    Write-Host ("ACTION: Close Session");
    # Remove Properties from RQL Store
    $Global:StoreRQL.PSObject.Members | ForEach { $Global:StoreRQL.PsObject.Members.Remove($_.Name) }
    # Display RQL Store Properties
    Show-RQLStore;
}


# Prepare Login
Function RQL-GetLoginData ($CredentialsUserName) {
    $Global:StoreRQL.Timestamp = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds;
    Write-Host ("ACTION: Get Login Data");
    # Create New Properties in RQL Store
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("Username") -Value ("") -Force;
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("Password") -Value ("") -Force;
    # Get Credentials
    #$CredentialsUserName = "wsm.powershell.account";
    $CredentialsPasswordFile = Get-Content ("C:\Source\PowerShell\Store\{0}.pwd" -f $CredentialsUserName) -ErrorAction Stop;
    $CredentialsSecurePassword = $CredentialsPasswordFile | ConvertTo-SecureString;
    $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList ($CredentialsUserName, $CredentialsSecurePassword);
    # Store Values to RQL Store Properties
    $Global:StoreRQL.Username = $Credentials.GetNetworkCredential().Username;
    $Global:StoreRQL.Password = $Credentials.GetNetworkCredential().Password;
    # Display RQL Store Properties
    Show-RQLStore;
}


# Login
Function RQL-Login () {
    $Global:StoreRQL.Timestamp = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds;
    Write-Host ("ACTION: Login");
    # Create New Properties in RQL Store
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("UserGUID") -Value ("") -Force;
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("LoginGUID") -Value ("") -Force;
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("SessionKey") -Value ("") -Force;
    # Prepare RQL Request
    $RQL = ("<IODATA><ADMINISTRATION action='login' name='[!username!]' password='[!password!]'/></IODATA>");
    $RQL = ReplaceValuesRQL ($RQL);
    # Send RQL Request to WebService
    [xml]$Response = $Global:StoreRQL.Proxy.Execute($RQL, $Global:StoreRQL.ErrorA, $Global:StoreRQL.ResultA);
    # Store Results to RQL Store Properties
    $Global:StoreRQL.UserGuid = $Response.IODATA.USER.guid;
    $Global:StoreRQL.LoginGuid = $Response.IODATA.LOGIN.guid;
    $Global:StoreRQL.SessionKey = $Response.IODATA.LOGIN.guid;
    # Display RQL Response Object
    $Response.ChildNodes | Format-List;
    # Display RQL Response String
    WriteRQLToScreen $Response.OuterXml.ToString();
    # Display RQL Store Properties
    Show-RQLStore;
}


# Connect to project
Function RQL-ConntectToProject ($ProjectGUID) {
    $Global:StoreRQL.Timestamp = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds;
    Write-Host ("ACTION: Connect to Project");
    # Create New Properties in RQL Store
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("ProjectGUID") -Value ("") -Force;
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("ServerGUID") -Value ("") -Force;
    # Store Values to RQL Store Properties
    $Global:StoreRQL.ProjectGuid = ($ProjectGUID);
    # Prepare RQL Request
    $RQL = ("<IODATA loginguid='[!guid_login!]' sessionkey='[!key!]'><ADMINISTRATION action='validate' guid='[!guid_login!]' useragent='script'><PROJECT guid='[!guid_project!]'/></ADMINISTRATION></IODATA>");
    $RQL = ReplaceValuesRQL ($RQL);
    # Send RQL Request to WebService
    [xml]$Response = $Global:StoreRQL.Proxy.Execute($RQL, $Global:StoreRQL.ErrorA, $Global:StoreRQL.ResultA);
    # Store Results to RQL Store Properties
    $Global:StoreRQL.ServerGUID = $Response.IODATA.SERVER.guid;
    # Display RQL Response Object
    $Response.ChildNodes | Format-List;
    # Display RQL Response String
    WriteRQLToScreen $Response.OuterXml.ToString();
    # Display RQL Store Properties
    Show-RQLStore;
}


# Create and Connect Page
Function RQL-CreateConnectPage ($TemplateGUID, $LinkGUID) {
    $Global:StoreRQL.Timestamp = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds;
    Write-Host ("ACTION: Create and Connect Page");
    # Create New Properties in RQL Store
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("PageGUID") -Value ("") -Force;
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("PageID") -Value ("") -Force;
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("LinkGUID") -Value ($LinkGUID) -Force;
    $Global:StoreRQL | Add-Member -Type NoteProperty -Name ("TemplateGUID") -Value ($TemplateGUID) -Force;
    # Prepare RQL Request
    $RQL = ("<IODATA loginguid='[!guid_login!]' sessionkey='[!key!]'><LINK action='assign' guid='[!guid_link!]'><PAGE action='addnew' templateguid='[!guid_template!]'/></LINK></IODATA>");
    $RQL = $RQL.Replace("[!guid_template!]", $TemplateGUID).Replace("[!guid_link!]", $LinkGUID);
    $RQL = ReplaceValuesRQL ($RQL);
    # Send RQL Request to WebService
    [xml]$Response = $Global:StoreRQL.Proxy.Execute($RQL, $Global:StoreRQL.ErrorA, $Global:StoreRQL.ResultA);
    # Store Results to RQL Store Properties
    $Global:StoreRQL.PageGUID = $Response.IODATA.LINK.PAGE.guid;
    $Global:StoreRQL.PageID = $Response.IODATA.LINK.PAGE.id;
    # Display RQL Response Object
    $Response.ChildNodes | Format-List;
    # Display RQL Response String
    WriteRQLToScreen $Response.OuterXml.ToString();
    # Display RQL Store Properties
    $Global:StoreRQL | Select-Object * -ExcludeProperty ("Proxy", "ErrorA", "ResultA") | Format-List;
    If ($Global:StoreRQL.ErrorA.Value) {
        $Global:StoreRQL | Select-Object ErrorA.Value | Format-List;
    }
    $Global:StoreRQL.ResultA.Value;
}


# Logout
Function RQL-Logout () {
    $Global:StoreRQL.Timestamp = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds;
    Write-Host ("ACTION: Logout");
    # Prepare RQL Request
    $RQL = ("<IODATA loginguid='[!guid_login!]' sessionkey='[!key!]'><ADMINISTRATION><LOGOUT guid='[!guid_login!]'/></ADMINISTRATION></IODATA>");
    $RQL = ReplaceValuesRQL ($RQL);
    # Send RQL Request to WebService
    [xml]$Response = $Global:StoreRQL.Proxy.Execute($RQL, $Global:StoreRQL.ErrorA, $Global:StoreRQL.ResultA);
    # Display RQL Response Object
    $Response | Format-List;
    # Display RQL Response String
    WriteRQLToScreen $Response.OuterXml.ToString();
    # Remove Properties from RQL Store
    $Global:StoreRQL.PSObject.Members | Where-Object {$_.Name -like ("*GUID") -or $_.Name -like ("*ID") -or $_.Name -like ("*Key")} | ForEach { $Global:StoreRQL.PsObject.Members.Remove($_.Name) }
    # Display RQL Store Properties
    Show-RQLStore;
}


# ------


RQL-OpenSession;
Pause;
Write-Host ("---------------");

RQL-GetLoginData ("wsm.powershell.account");
Pause;
Write-Host ("---------------");

RQL-Login;
Pause;
Write-Host ("---------------");

RQL-ConntectToProject -ProjectGUID ("BC55EB11F6FA4A77884AB1872D82FDC9");
Pause;
Write-Host ("---------------");

RQL-CreateConnectPage -TemplateGUID ("D2797377A4DA438D836E142893B5BB64") -LinkGUID ("374B05435E964819A1181963D895AFBD");
Pause;
Write-Host ("---------------");

RQL-Logout;
Pause;
Write-Host ("---------------");

RQL-CloseSession;
Write-Host ("---------------");