<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
<cfheader name="pragma" value="no-cache">
<cfheader name="expires" value="#getHttpTimeString(now())#">
<cfif isDefined("hasFlash")>
	<cfinvoke component="#application.CFCPath#.leftNav" method="Init">
		<cfinvokeargument name="useFlash" value="#hasFlash#">
	</cfinvoke>
<cfelse>
<cfoutput>
<p align="center">Detecting Flash...</p>
<meta http-equiv="refresh" content="3;url=#request.page#?hasFlash=false" />
<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version=4,0,0,0" width="80" height="80">
<param name="movie" value="#application.globalPath#/media/swf/flash_detection.swf" />
<param name="flashVars" value="flashContentURL=#request.page#?hasFlash=true&altContentURL=#request.page#?hasFlash=false&contentVersion=7&contentMajorRevision=0&contentMinorRevision=0&allowFlashAutoInstall=false">
<param name="bgcolor" value="##f4f4f4" />
<param name="quality" value="low" />
<embed src="#application.globalPath#/media/swf/flash_detection.swf" bgcolor="##f4f4f4" flashvars="flashContentURL=#request.page#?hasFlash=true&altContentURL=#request.page#?hasFlash=false&contentVersion=7&contentMajorRevision=0&contentMinorRevision=0&allowFlashAutoInstall=false" quality="low" pluginspage="http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash" type="application/x-shockwave-flash" width="80" height="80" />
</object>
</cfoutput>
</cfif>