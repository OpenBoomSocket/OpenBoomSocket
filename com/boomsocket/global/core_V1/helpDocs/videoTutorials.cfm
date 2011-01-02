<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Untitled Document</title>
</head>

<body>
<cfsavecontent variable="headerStuff">
<cfoutput>
<script src="/admintools/media/swf/AC_OETags.js" language="javascript"></script>
<script language="JavaScript" type="text/javascript">
<!--
// -----------------------------------------------------------------------------
// Globals
// Major version of Flash required
var requiredMajorVersion = 8;
// Minor version of Flash required
var requiredMinorVersion = 0;
// Minor version of Flash required
var requiredRevision = 0;
// -----------------------------------------------------------------------------
// -->

function setNominee(memberid,membername){
//	alert('function called');
//	alert('you selected ' + membername + ' with id ' + memberid);
	document.awardnominee.nomineeID.value = memberid;
	document.awardnominee.awardnomineename.value = membername;
}
</script>
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#headerStuff#">
<cfoutput>
<div id="TutorialPlayerWidget">
<script language="JavaScript" type="text/javascript">
<!--
// Version check for the Flash Player that has the ability to start Player Product Install (6.0r65)
var hasProductInstall = DetectFlashVer(6, 0, 65);
// Version check based upon the values defined in globals
var hasRequestedVersion = DetectFlashVer(requiredMajorVersion, requiredMinorVersion, requiredRevision);
// Check to see if a player with Flash Product Install is available and the version does not meet the requirements for playback
if ( hasProductInstall && !hasRequestedVersion ) {
	// MMdoctitle is the stored document.title value used by the installation process to close the window that started the process
	// This is necessary in order to close browser windows that are still utilizing the older version of the player after installation has completed
	// DO NOT MODIFY THE FOLLOWING FOUR LINES
	// Location visited after installation is complete if installation is required
	var MMPlayerType = (isIE == true) ? "ActiveX" : "PlugIn";
	var MMredirectURL = window.location;
    document.title = document.title.slice(0, 47) + " - Flash Player Installation";
    var MMdoctitle = document.title;

	AC_FL_RunContent(
		"src", "/admintools/media/swf/playerProductInstall",
		"FlashVars", "MMredirectURL="+MMredirectURL+'&MMplayerType='+MMPlayerType+'&MMdoctitle='+MMdoctitle+"",
		"width", "100%",
		"height", "100%",
		"align", "middle",
		"id", "playerProductInstall",
		"quality", "high",
		"bgcolor", "##ffffff",
		"name", "playerProductInstall",
		"allowScriptAccess","sameDomain",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
} else if (hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	AC_FL_RunContent(
			"src", "#application.globalMapping#/media/swf/TutorialPlayer",
			"width", "100%",
			"height", "100%",
			"id", "TutorialPlayer",
			"quality", "high",
			"bgcolor", "##FFFFFF",
			"wmode","opaque",
			"name", "TutorialPlayer",
			"flashvars",'serverURL=#application.installURL#',
			"allowScriptAccess","sameDomain",
			"type", "application/x-shockwave-flash",
			"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
  } else {  // flash is too old or we can't detect the plugin
    var alternateContent = '<h3>Flash Player 9 is Required use the Member Finder application...</h3>';
    document.write(alternateContent);  // insert non-flash content
  }
// -->
</script>
<noscript>
  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
			id="MemberDirectory" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="#application.globalMapping#/media/swf/TutorialPlayer.swf" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="##ffffff" />
			<param name="allowScriptAccess" value="sameDomain" />
            <param name="flashvars" value="userRole=serverURL=#application.installURL#" />
			<embed src="#application.globalMapping#/media/swf/TutorialPlayer.swf" quality="high" bgcolor="##ffffff"
				width="100%" height="100%" name="TutorialPlayer" align="middle"
				play="true"
				loop="false"
				quality="high"
				allowScriptAccess="sameDomain"
				type="application/x-shockwave-flash"
				flashvars="serverURL=#application.installURL#"
				pluginspage="http://www.adobe.com/go/getflashplayer">
            </embed>			
	</object>
</noscript>
</div>
<input type="hidden" id="nomineeID" name="nomineeID" value="" />
</cfoutput>
</body>
</html>
