// JavaScript Document
// The following function dynamically creates a swf/flash object and adds it
// to a holder div, this will aleviate the new 'activation' necessity for IE 7
// The function takes the following parameters:
//
//	DivID		The name of the containing DIV that wraps the object
//	ObjectID	The name of the compiled swf file (minus the .swf extension)
//	WIDTH		The display width for the swf
//	HEIGHT		The display height for the swf
//	URL			The absolute url of the load path for the swf (generally use /media/swf/)
//	WMODE		The window mode (default is opaque)
//	VARS		An Array of key/value objects for optional flashVars (use this syntax [{name:"thisName",value:"thisValue"},(...)]
//
<!--
/* SAMPLE HTML COPY INTO BODY OF NEW DOCUMENT FOR FLASH VERSION CHECKING
	<head>
		<script src="objectImport.js" type="text/javascript">< /script>
	</head>
	<body>
		<div id="containerDiv">
			<script language="VBScript" type="text/vbscript">
				<!-- // Visual basic helper required to detect Flash Player ActiveX control version information
				Function VBGetSwfVer(i)
				  on error resume next
				  Dim swControl, swVersion
				  swVersion = 0
				  
				  set swControl = CreateObject("ShockwaveFlash.ShockwaveFlash." + CStr(i))
				  if (IsObject(swControl)) then
					swVersion = swControl.GetVariable("$version")
				  end if
				  VBGetSwfVer = swVersion
				End Function
				// -->
			</script>
			<script language="JavaScript" type="text/javascript">
				<!-- 
				// Version check for the Flash Player that has the ability to start Player Product Install (6.0r65)
				var hasProductInstall = DetectFlashVer(6, 0, 65);
				
				// Version check based upon the values entered above in "Globals"
				var hasReqestedVersion = DetectFlashVer(requiredMajorVersion, requiredMinorVersion, requiredRevision);
				
				// Location visited after installation is complete if installation is required
				var MMredirectURL = window.location;
				
				// Stored value of document title used by the installation process to close the window that started the installation process
				// This is necessary to remove browser windows that will still be utilizing the older version of the player after installation is complete
				// DO NOT MODIFY THE FOLLOWING TWO LINES
				document.title = document.title.slice(0, 47) + " - Flash Player Installation";
				var MMdoctitle = document.title;
				
				// Check to see if a player with Flash Product Install is available and the version does not meet the requirements for playback
				if ( hasProductInstall && !hasReqestedVersion ) {
					var productInstallOETags = '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"'
					+ 'width="400" height="400"'
					+ 'codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab">'
					+ '<param name="movie" value="playerProductInstall.swf?MMredirectURL='+MMredirectURL+'&MMplayerType=ActiveX&MMdoctitle='+MMdoctitle+'" />'
					+ '<param name="wmode" value="opaque" />'
					+ '<param name="quality" value="high" /><param name="bgcolor" value="##FFFFFF" />'
					+ '<embed src="playerProductInstall.swf?MMredirectURL='+MMredirectURL+'&MMplayerType=PlugIn" quality="high" bgcolor="##FFFFFF" '
					+ 'width="400" height="400" name="detectiontest" aligh="middle"'
					+ 'play="true"'
					+ 'loop="false"'
					+ 'quality="high"'
					+ 'wmode="opaque"'
					+ 'allowScriptAccess="sameDomain"'
					+ 'type="application/x-shockwave-flash"'
					+ 'pluginspage="http://www.macromedia.com/go/getflashplayer">'
					+ '<\/embed>'
					+ '<\/object>';
					document.write(productInstallOETags);   // embed the Flash Product Installation SWF
				  } else if (hasReqestedVersion) {  // if we've detected an acceptable version
					createFPObject("homeLeftPanel", "homeshow", 374, 364, "/media/swf/", "opaque", [{name:"serverURL",value:"#APPLICATION.installurl#"}]);
				  } else {  // flash is too old or we can't detect the plugin
					var alternateContent = 'This content requires the Macromedia Flash Player.'
					+ '<a href=http://www.macromedia.com/go/getflash/>Get Flash</a>';
					document.write(alternateContent);  // insert non-flash content
				  }
				// -->
				</script>
				<noscript>
					This content requires the Macromedia Flash Player and that you have JavaScript turned on.
					<a href="http://www.macromedia.com/go/getflash/">Get Flash</a>  	
				</noscript>
		</div>
	</body>
*/
// -->
//	The call to createObject() can exist in a function in the header, if so the function must be called when the window onLoad event is triggered, otherwise the call will be processed when the script is reached in the load process

<!--
// -----------------------------------------------------------------------------
// Globals
// Major version of Flash required
var requiredMajorVersion = 7;
// Minor version of Flash required
var requiredMinorVersion = 0;
// Revision of Flash required
var requiredRevision = 0;
// the version of javascript supported
var jsVersion = 1.0;
// -----------------------------------------------------------------------------
// -->

<!-- // Detect Client Browser type
var isIE  = (navigator.appVersion.indexOf("MSIE") != -1) ? true : false;
var isWin = (navigator.appVersion.toLowerCase().indexOf("win") != -1) ? true : false;
var isOpera = (navigator.userAgent.indexOf("Opera") != -1) ? true : false;
jsVersion = 1.1;
// JavaScript helper required to detect Flash Player PlugIn version information
function JSGetSwfVer(i){
	// NS/Opera version >= 3 check for Flash plugin in plugin array
	if (navigator.plugins != null && navigator.plugins.length > 0) {
		if (navigator.plugins["Shockwave Flash 2.0"] || navigator.plugins["Shockwave Flash"]) {
			var swVer2 = navigator.plugins["Shockwave Flash 2.0"] ? " 2.0" : "";
      		var flashDescription = navigator.plugins["Shockwave Flash" + swVer2].description;
			descArray = flashDescription.split(" ");
			tempArrayMajor = descArray[2].split(".");
			versionMajor = tempArrayMajor[0];
			versionMinor = tempArrayMajor[1];
			if ( descArray[3] != "" ) {
				tempArrayMinor = descArray[3].split("r");
			} else {
				tempArrayMinor = descArray[4].split("r");
			}
      		versionRevision = tempArrayMinor[1] > 0 ? tempArrayMinor[1] : 0;
            flashVer = versionMajor + "." + versionMinor + "." + versionRevision;
      	} else {
			flashVer = -1;
		}
	}
	// MSN/WebTV 2.6 supports Flash 4
	else if (navigator.userAgent.toLowerCase().indexOf("webtv/2.6") != -1) flashVer = 4;
	// WebTV 2.5 supports Flash 3
	else if (navigator.userAgent.toLowerCase().indexOf("webtv/2.5") != -1) flashVer = 3;
	// older WebTV supports Flash 2
	else if (navigator.userAgent.toLowerCase().indexOf("webtv") != -1) flashVer = 2;
	// Can't detect in all other cases
	else {
		
		flashVer = -1;
	}
	return flashVer;
} 
// If called with no parameters this function returns a floating point value 
// which should be the version of the Flash Player or 0.0 
// ex: Flash Player 7r14 returns 7.14
// If called with reqMajorVer, reqMinorVer, reqRevision returns true if that version or greater is available
function DetectFlashVer(reqMajorVer, reqMinorVer, reqRevision) 
{
 	reqVer = parseFloat(reqMajorVer + "." + reqRevision);
   	// loop backwards through the versions until we find the newest version	
	for (i=25;i>0;i--) {	
		if (isIE && isWin && !isOpera) {
			versionStr = VBGetSwfVer(i);
		} else {
			versionStr = JSGetSwfVer(i);		
		}
		if (versionStr == -1 ) { 
			return false;
		} else if (versionStr != 0) {
			if(isIE && isWin && !isOpera) {
				tempArray         = versionStr.split(" ");
				tempString        = tempArray[1];
				versionArray      = tempString .split(",");				
			} else {
				versionArray      = versionStr.split(".");
			}
			versionMajor      = versionArray[0];
			versionMinor      = versionArray[1];
			versionRevision   = versionArray[2];
			
			versionString     = versionMajor + "." + versionRevision;   // 7.0r24 == 7.24
			versionNum        = parseFloat(versionString);
        	// is the major.revision >= requested major.revision AND the minor version >= requested minor
			if ( (versionMajor > reqMajorVer) && (versionNum >= reqVer) ) {
				return true;
			} else {
				return ((versionNum >= reqVer && versionMinor >= reqMinorVer) ? true : false );	
			}
		}
	}	
	return (reqVer ? false : 0.0);
}

function createFPObject(DivID, ObjectID, WIDTH, HEIGHT, URL, WMODE, VARS){
	var tempString;
	tempString = '<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0" width="'+WIDTH+'" height="'+HEIGHT+'" id="'+ObjectID+'" align="middle"><param name="allowScriptAccess" value="sameDomain" />';
	if(!(WMODE.length > 0)){
		tempString+='<param name="wmode" value="opaque" />';
	}else{
		tempString+='<param name="wmode" value="'+WMODE+'" />';
	}
	if(VARS.length>0){
		tempString+='<param name="flashVars" value=\"'+VARS[0].name+'='+VARS[0].value;
		for(var i=1 ; i<VARS.length ; i++){
			tempString+='&'+VARS[i].name+'='+VARS[i].value;
		}
		tempString+='\" />';
	}
	tempString+='<param name="movie" value="'+URL+ObjectID+'.swf" /><param name="quality" value="high" /><param name="bgcolor" value="#ffffff" /><embed src="'+URL+ObjectID+'.swf" quality="high" bgcolor="#ffffff" width="'+WIDTH+'" height="'+HEIGHT+'" name="'+ObjectID+'" align="middle" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" ';
	if(!(WMODE.length > 0)){
		tempString+=' wmode="opaque"';
	}else{
		tempString+=' wmode="'+WMODE+'"';
	}
	if(VARS.length>0){
		tempString+=' flashVars="'+VARS[0].name+'='+VARS[0].value;
		for(var i=1 ; i<VARS.length ; i++){
			tempString+='&'+VARS[i].name+'='+VARS[i].value;
		}
		tempString+='\" /></object>';
	}else{
		tempString+=' /></object>';
	}
	document.getElementById(DivID).innerHTML = tempString;
}
// -->