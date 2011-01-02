<!-- saved from url=(0014)about:internet -->
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Content Mapping<cfif isDefined('request.q_getform')> for #request.q_getform.label#</cfif></title>
<script src="/admintools/media/swf/AC_OETags.js" language="javascript"></script>
<style>
body { margin: 0px; overflow:hidden }
</style>
<script language="JavaScript" type="text/javascript">
<!--
// -----------------------------------------------------------------------------
// Globals
// Major version of Flash required
var requiredMajorVersion = 9;
// Minor version of Flash required
var requiredMinorVersion = 0;
// Minor version of Flash required
var requiredRevision = 0;
// -----------------------------------------------------------------------------
// -->
</script>
</head>

<body scroll="no">
<cfsetting showdebugoutput="no">
<cfif isDefined('session.user.name') AND len(trim(session.user.name))>
<cfoutput>
<div style="height: 100%">
<script language="JavaScript" type="text/javascript" src="/admintools/media/swf/history.js"></script>
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
		"id", "ContentMapping",
		"quality", "high",
		"bgcolor", "##869ca7",
		"name", "ContentMapping",
		"allowScriptAccess","any",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
} else if (hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	AC_FL_RunContent(
			"src", "#application.globalpath#/media/swf/ContentMapping",
			"width", "100%",
			"height", "100%",
			"align", "middle",
			"id", "ContentMapping",
			"quality", "high",
			"bgcolor", "##869ca7",
			"name", "ContentMapping",
			"flashvars",'yo=yo<cfif isDefined('URL.thistoolid')>&formobjectid=#URL.thistoolid#<cfelseif isDefined('SESSION.i3currenttool')>&formobjectid=#SESSION.i3currenttool#</cfif><cfif isDefined('URL.adminall')>&adminall=1</cfif><cfif isDefined('APPLICATION.sitemapping')>&sitemapping=#APPLICATION.sitemapping#</cfif><cfif isDefined('URL.thisInstance')>&thisInstance=#URL.thisInstance#</cfif><cfif isDefined('URL.titletext')>&titletext=#URL.titletext#</cfif>&<cfif isDefined('URL.associaterole') AND URL.associaterole>associaterole=1</cfif>&serverURL=#APPLICATION.installurl#&cfcpath=#APPLICATION.cfcpath#',
			"allowScriptAccess","any",
			"type", "application/x-shockwave-flash",
			"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
  } else {  // flash is too old or we can't detect the plugin
    var alternateContent = 'Alternate HTML content should be placed here. '
  	+ 'This content requires the Adobe Flash Player. '
   	+ '<a href=http://www.adobe.com/go/getflash/>Get Flash</a>';
    document.write(alternateContent);  // insert non-flash content
  }
// -->
</script>
<noscript>
  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
			id="ContentMapping" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="/admintools/media/swf/ContentMapping.swf" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="##869ca7" />
			<param name="allowScriptAccess" value="sameDomain" />
			<embed src="ContentMapping.swf" quality="high" bgcolor="##869ca7"
				width="100%" height="100%" name="ContentMapping" align="middle"
				play="true"
				loop="false"
				quality="high"
				allowScriptAccess="sameDomain"
				type="application/x-shockwave-flash"
				pluginspage="http://www.adobe.com/go/getflashplayer">
			</embed>
	</object>
</noscript>
</div>
</cfoutput>
<cfelse>
	<cfoutput>
		<h1>You do not have permission to run this tool</h1>
	</cfoutput>
</cfif>
</body>
</html>
