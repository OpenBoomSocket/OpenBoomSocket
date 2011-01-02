<!--- Custom Tool: Shop Administrator Created on {ts '2006-10-26 17:44:51'} --->
<!--- <cfsetting showdebugoutput="no"> --->
<cfif (listfirst(server.ColdFusion.ProductVersion) GT 7) OR (listfirst(server.ColdFusion.ProductVersion) EQ 7 AND (listgetat(server.ColdFusion.ProductVersion,2) GT 0 OR ((listgetat(server.ColdFusion.ProductVersion,2) EQ 0 AND listgetat(server.ColdFusion.ProductVersion,3) GTE 2) OR listgetat(server.ColdFusion.ProductVersion,2) GT 0)))>
<cfif isDefined('session.user.name') AND len(trim(session.user.name))>
<cfoutput>
<div id="flashContainer" style="margin: 0px; padding: 0px; width: 100%;	height: 100%; z-index: 1;">
<script src="#application.globalPath#/javascript/Flash/AC_OETags.js" language="javascript"></script>
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

/* CMC: No Longer need these if wmode=transparent allows nav to overlap **************************
document.getElementById('adminnavlist').onmouseover = function(){
	//document.getElementById('flashContainer').getElementsByTagName('embed')[0].style.margin = "150px 0px 0px 0px";
	document.getElementById('flashContainer').getElementsByTagName('embed')[0].style.width = "1%";
	//document.getElementById('flashContainer').getElementsByTagName('embed')[0].enabled = "false";
}
document.getElementById('adminnavlist').onmouseout = function(){
	//document.getElementById('flashContainer').getElementsByTagName('embed')[0].style.margin = "10px 0px 0px 0px";
	document.getElementById('flashContainer').getElementsByTagName('embed')[0].style.width = "100%";
	//document.getElementById('flashContainer').getElementsByTagName('embed')[0].enabled = "true";
}
**************************************************************************************************/

</script>
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
		"width", "800",
		"height", "500",
		"align", "middle",
		"id", "StoreFront",
		"quality", "high",
		"bgcolor", "##869ca7",
		"wmode", "opaque",
		"menu", "false",
		"name", "StoreFront",
		"allowScriptAccess","sameDomain",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer",
		"wmode","transparent"
	);
} else if (hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	if(isIE){
		objHeight = "630px";
	}else{
		objHeight = "630px";
	}
	AC_FL_RunContent(
			"src", "#application.globalpath#/media/swf/NavManager",
			"width", "100%",
			"height", objHeight,
			"align", "middle",
			"id", "StoreFront",
			"quality", "high",
			"bgcolor", "##FFFFFF",
			"name", "NavManager",
			"flashvars",'<cfif isDefined('APPLICATION.sitemapping')>&sitemapping=#APPLICATION.sitemapping#</cfif>&serverURL=#APPLICATION.installurl#',
			"allowScriptAccess","sameDomain",
			"type", "application/x-shockwave-flash",
			"pluginspage", "http://www.adobe.com/go/getflashplayer",
			"wmode","transparent"
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
			id="StoreFront" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="/admintools/media/swf/NavManager.swf" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="##FFFFFF" />
			<param name="allowScriptAccess" value="sameDomain" />
			<param name="wmode" value="transparent" />
			<embed src="/admintools/media/swf/NavManager.swf" quality="high" bgcolor="##FFFFFF"
				width="100%" height="100%" name="StoreFront" align="middle"
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
<cfelse>
<cfoutput><div>This utility requires CF version 7.0.2 or higher to support Flex based Flash Remoting.</div></cfoutput>
</cfif>