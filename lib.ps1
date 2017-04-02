Function Pause ($Message = "Press any key to continue . . . ") {
    If ($psISE) {
        # The "ReadKey" functionality is not supported in Windows PowerShell ISE.
        $Shell = New-Object -ComObject "WScript.Shell";
        $Button = $Shell.Popup("Click OK to continue.", 0, "Script Paused", 0);
        Return;
    }
    Write-Host -NoNewline $Message;
    $Ignore =
        16,  # Shift (left or right)
        17,  # Ctrl (left or right)
        18,  # Alt (left or right)
        20,  # Caps lock
        91,  # Windows key (left)
        92,  # Windows key (right)
        93,  # Menu key
        144, # Num lock
        145, # Scroll lock
        166, # Back
        167, # Forward
        168, # Refresh
        169, # Stop
        170, # Search
        171, # Favorites
        172, # Start/Home
        173, # Mute
        174, # Volume Down
        175, # Volume Up
        176, # Next Track
        177, # Previous Track
        178, # Stop Media
        179, # Play
        180, # Mail
        181, # Select Media
        182, # Application 1
        183  # Application 2
 
    While ($KeyInfo.VirtualKeyCode -Eq $Null -Or $Ignore -Contains $KeyInfo.VirtualKeyCode) {
        $KeyInfo = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown");
    }
    Write-Host;
}

#Function Pause($M="Press any key to continue . . . "){If($psISE){$S=New-Object -ComObject "WScript.Shell";$B=$S.Popup("Click OK to continue.",0,"Script Paused",0);Return};Write-Host -NoNewline $M;$I=16,17,18,20,91,92,93,144,145,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183;While($K.VirtualKeyCode -Eq $Null -Or $I -Contains $K.VirtualKeyCode){$K=$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")};Write-Host}


Function Write-CHost($message = ""){
    [string]$pipedMessage = @($Input)
    If (!$message)
    {  
        If ( $pipedMessage ) {
            $message = $pipedMessage
        }
    }
	If ( $message ){
    #$RQL = $RQLResponse.OuterXml.Replace("IODATA", "#green#IODATA#white#");
    #$RQLResponse = $RQLResponse.Replace("PAGE", "#red#PAGE#white#");
    #$RQLResponse = $RQLResponse.Replace("PROJECT", "#red#PROJECT#white#");
    #$RQLResponse = $RQLResponse.Replace("ADMINISTRATION", "#red#ADMINISTRATION#white#");
    #$RQLResponse = $RQLResponse.Replace("LINK", "#red#LINK#white#");
		# predefined Color Array
		$colors = @("black","blue","cyan","darkblue","darkcyan","darkgray","darkgreen","darkmagenta","darkred","darkyellow","gray","green","magenta","red","white","yellow");

		# Get the default Foreground Color
		$defaultFGColor = "white";
        
		# Set CurrentColor to default Foreground Color
		$CurrentColor = $defaultFGColor

		# Split Messages
		$message = $message.Split("#")

		# Iterate through splitted array
		ForEach( $RQL in $message ){
			# If a string between #-Tags is equal to any predefined color, and is equal to the defaultcolor: set current color
			If ( $colors -contains $RQL.ToLower() -and $CurrentColor -eq $defaultFGColor ){
				$CurrentColor = $RQL          
			} Else {
				# If string is a output message, than write string with current color (with no line break)
                If ( $CurrentColor -eq "green" ) {
                    #$RQL = "`r`n`t" + $RQL;
                }
				Write-Host -NoNewline -ForegroundColor $CurrentColor $RQL
				# Reset current color
				$CurrentColor = $defaultFGColor
			}
			# Write Empty String at the End
		}
		# Single write-host for the final line break
		Write-Host
	}
}

Function WriteXmlToScreen ([xml]$Xml, $Indent=2)
{
    $StringWriter = New-Object System.IO.StringWriter;
    $XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter;
    $XmlWriter.Formatting = "indented";
    $xmlWriter.Indentation = $Indent;
    $Xml.WriteTo($XmlWriter);
    $XmlWriter.Flush();
    $StringWriter.Flush();
    Write-Output $StringWriter.ToString();
}

Function WriteRQLToScreen ([xml]$Xml, $Indent=4)
{
    $StringWriter = New-Object System.IO.StringWriter;
    $XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter;
    $XmlWriter.Formatting = "indented";
    $xmlWriter.Indentation = $Indent;
    $xml.WriteTo($XmlWriter);
    $XmlWriter.Flush();
    $StringWriter.Flush();
    #Write-Output $StringWriter.ToString();
    $string = $StringWriter.ToString();
    $string = $string.Replace("IODATA", "#blue#IODATA#white#");
    $string = $string.Replace("ADMINISTRATION ", "#red#ADMINISTRATION#white# ");
    $string = $string.Replace("ELEMENT ", "#red#ELEMENT#white# ");
    $string = $string.Replace("ELEMENTS ", "#yellow#ELEMENTS#white# ");
    $string = $string.Replace("LASTMODULES", "#yellow#LASTMODULES#white#");
    $string = $string.Replace("<LICENSE", "<#red#LICENSE#white# ");
    $string = $string.Replace("LINK", "#red#LINK#white#");
    $string = $string.Replace("<LOGIN ", "<#red#LOGIN#white# ");
    $string = $string.Replace("<MODULE ", "<#red#MODULE#white# ");
    $string = $string.Replace("/MODULE>", "/<#red#MODULE#white#>");
    $string = $string.Replace("<MODULES", "<#yellow#MODULES#white#");
    $string = $string.Replace("/MODULES>", "/#yellow#MODULES#white#>");
    $string = $string.Replace("<PAGE", "<#red#PAGE#white#");
    $string = $string.Replace("/PAGE>", "/#red#PAGE#white#>");
    $string = $string.Replace("PAGES", "#yellow#PAGES#white#");
    $string = $string.Replace("PROJECT ", "#red#PROJECT#white# ");
    $string = $string.Replace("SERVER ", "#red#SERVER#white# ");
    $string = $string.Replace("USER ", "#red#USER#white# ");
    $string = $string.Replace("/USER", "/#red#USER#white#");
    $string = $string.Replace("/>", "#red#/#white#>");
    $string = $string.Replace(" action=", " #green#action=#white#");
    $string = $string.Replace(" guid=", " #green#guid=#white#");
    $string = $string.Replace(" loginguid=", " #green#loginguid=#white#");
    $string = $string.Replace(" id=", " #green#id=#white#");
    $string = $string.Replace(" name=", " #green#name=#white#");
    $string = $string.Replace(" fullname=", " #green#fullname=#white#");
    $string = $string.Replace(" linkguid=", " #green#linkguid=#white#");
    $string = $string.Replace(" editlinkguid=", " #green#editlinkguid=#white#");
    $string = $string.Replace(" targetlinkguid=", " #green#targetlinkguid=#white#");
    $string = $string.Replace(" pageguid=", " #green#pageguid=#white#");
    $string = $string.Replace(" parentguid=", " #green#parentguid=#white#");
    $string = $string.Replace(" project=", " #green#project=#white#");
    $string = $string.Replace(" projectguid=", " #green#projectguid=#white#");
    $string = $string.Replace(" projectname=", " #green#projectname=#white#");
    $string = $string.Replace(" last=", " #green#last=#white#");
    $string = $string.Replace(" key=", " #green#key=#white#");
    $string = $string.Replace(" sessionkey=", " #green#sessionkey=#white#");
    $string = $string.Replace(" userguid=", " #green#userguid=#white#");
    $string = $string.Replace(" userid=", " #green#userid=#white#");
    $string = $string.Replace(" server=", " #green#server=#white#");
    $string = $string.Replace(" serverguid=", " #green#serverguid=#white#");
    $string = $string.Replace(" userkey=", " #green#userkey=#white#");
    $string = $string.Replace(" usertoken=", " #green#usertoken=#white#");
    $string = $string.Replace(" eltname=", " #green#eltname=#white#");
    $string = $string.Replace(" aliasname=", " #green#aliasname=#white#");
    $string = $string.Replace(" value=", " #green#value=#white#");
    $string = $string.Replace(" status=", " #green#status=#white#");
    $string = $string.Replace(" variable=", " #green#variable=#white#");
    $string = $string.Replace(" headline=", " #green#headline=#white#");
    $string = $string.Replace(" type=", " #green#type=#white#");
    $string = $string.Replace(" elttype=", " #green#elttype=#white#");
    $string = $string.Replace(" flags=", " #green#flags=#white#");
    $string = $string.Replace(" eltflags=", " #green#eltflags=#white#");
    $string = $string.Replace(" islink=", " #green#islink=#white#");
    $string = $string.Replace(" level=", " #green#level=#white#");
    $string = $string.Replace(" orderid=", " #green#orderid=#white#");
    $string = $string.Replace(" languageid=", " #green#languageid=#white#");
    $string = $string.Replace(" languagevariantid=", " #green#languagevariantid=#white#");
    $string = $string.Replace(" languagevariantguid=", " #green#languagevariantguid=#white#");
    $string = $string.Replace(" mainlanguagevariantid=", " #green#mainlanguagevariantid=#white#");
    $string = $string.Replace(" mainlanguagevariantguid=", " #green#mainlanguagevariantguid=#white#");
    $string = $string.Replace(" dialoglanguageid=", " #green#dialoglanguageid=#white#");
    $string = $string.Replace(" threadguid=", " #green#threadguid=#white#");
    $string = $string.Replace(" elementguid=", " #green#elementguid=#white#");
    $string = $string.Replace(" mainlinkguid=", " #green#mainlinkguid=#white#");
    $string = $string.Replace(" templateguid=", " #green#templateguid=#white#");
    $string = $string.Replace(" templateelementguid=", " #green#templateelementguid=#white#");
    $string = $string.Replace(" eltrequired=", " #green#eltrequired=#white#");
    $string = $string.Replace(" flags1=", " #green#flags1=#white#");
    $string = $string.Replace(" flags2=", " #green#flags2=#white#");
    $string = $string.Replace(" rights1=", " #green#rights1=#white#");
    $string = $string.Replace(" rights2=", " #green#rights2=#white#");
    $string = $string.Replace(" rights3=", " #green#rights3=#white#");
    $string = $string.Replace(" rights4=", " #green#rights4=#white#");
    $string = $string.Replace(" navigationposition=", " #green#navigationposition=#white#");
    write-chost $string;
}

