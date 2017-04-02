function ReplaceValuesRQL ($sRQL) {
    $xml = [xml]$sRQL;
    if($xml.IODATA.HasAttributes) {
        $xml.IODATA.loginguid = $sStoreRQL.loginguid;
    }
    if($xml.IODATA.HasChildNodes) {
        if($xml.IODATA.GetElementsByTagName("ADMINISTRATION").action -eq "login") {
            $xml.IODATA.ADMINISTRATION.name = $sStoreRQL.username;
            $xml.IODATA.ADMINISTRATION.password = $sStoreRQL.password;
        }
        if($xml.IODATA.GetElementsByTagName("ADMINISTRATION").action -eq "validate") {
            $xml.IODATA.ADMINISTRATION.guid = $sStoreRQL.loginguid;
            if($xml.IODATA.ADMINISTRATION.HasChildNodes) {
                if($xml.IODATA.ADMINISTRATION.GetElementsByTagName("PROJECT").HasAttributes) {
                    $xml.IODATA.ADMINISTRATION.PROJECT.guid = $sStoreRQL.projectguid;
                }
            }
        }
    }
    $sRQL = $xml.OuterXml;
    return $sRQL;
} 


# -------

$global:sStoreRQL = New-Object PSCustomObject;
$global:sStoreRQL | Add-Member -Type NoteProperty -Name ("loginguid") -Value ("LoginGuidValue");
$global:sStoreRQL | Add-Member -Type NoteProperty -Name ("projectguid") -Value ("ProjectGuidValue");
$global:sStoreRQL | Add-Member -Type NoteProperty -Name ("username") -Value ("UsernameValue");
$global:sStoreRQL | Add-Member -Type NoteProperty -Name ("password") -Value ("PasswordValue");

#$global:sStoreRQL;

$sRQL = ("<IODATA><ADMINISTRATION action='login' name='[!username!]' password='[!password!]'/></IODATA>");
$sRQL = ReplaceValuesRQL ($sRQL);
$sRQL;

$sRQL = ("<IODATA loginguid='[!guid_login!]'><ADMINISTRATION action='validate' guid='[!guid_login!]' useragent='script'><PROJECT guid='[!guid_project!]'/></ADMINISTRATION></IODATA>");
$sRQL = ReplaceValuesRQL ($sRQL);
$sRQL;