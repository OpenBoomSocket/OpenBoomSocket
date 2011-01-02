<!--- 
	FILENAME ::::::: embedSWF.cfm
	AUTHOR ::::::::: Emile Melbourne (EOM)
	DATE CREATED ::: 6.12.08
	DEPENDENCIES ::: AC_RunActiveContent.js
	DESCRIPTION :::: For use as a ColdFusion Custom Tag
				  :: Embeds an SWF object into a page.

	ATTRIBUTES :::
				  :: file        :::: REQUIRED       :::: url of swf filename.  NOTE:: .swf estension is optional.
				  :: id          :::: DEFAULTS to filename without extension and path :::: id of object tag and name value of embed tag for embeded Flash SWF.
				  :: width       :::: DEFAULT = 100% :::: width of flash object on page.
				  :: height      :::: DEFAULT = 100% :::: height of flash object on page.
				  :: parameters  :::: DEFAULT = ""   :::: array of parameters to past to SWF object via FalshVars. Will be parsed by javascript into a query string style string of key value pairs.  NOTE:: The array values are completely dependent on the Flash SWF Developer.
				  :: winMode      :::: DEFAULT = "noscale" :::: DEFAULT = "transparent"
				  :: scaleMode    :::: DEFAULT = "transparent" :::: DEFAULT = "noscale"
				  :: AC_RunActiveContent_file    :::: DEFAULT = AC_RunActiveContent.js      :::: URL to AC_RunActiveContent.js file in current directory.  In boomsocket, add this file in admintool's javascript Toolbox
--->
<cfsilent>
<cfparam name="ATTRIBUTES.file" >
<cfparam name="ATTRIBUTES.id"  			default="">
<cfparam name="ATTRIBUTES.width"  		default="100%">
<cfparam name="ATTRIBUTES.height"  		default="100%">
<cfparam name="ATTRIBUTES.parameters"  default="">
<cfparam name="ATTRIBUTES.scaleMode"  	default="noscale">
<cfparam name="ATTRIBUTES.winMode"  	default="transparent">
<cfparam name="ATTRIBUTES.AC_RunActiveContent_file"  default="/javascript/AC_RunActiveContent.js">
	
	
	<cfparam name="FORM.isHtmlHeadLoaded" type="boolean" default="false">
	<cfparam name="htmlHeadOutput" 	default="">
	<cfparam name="htmlOutput" 		default="">
	
	<cfif FORM.isHtmlHeadLoaded EQ false>
		<cfset FORM.isHtmlHeadLoaded = true>
		<cfsavecontent variable="htmlHeadOutput">
			<cfoutput>
				<script language="javascript">AC_FL_RunContent = 0;</script>
				<script src="#ATTRIBUTES.AC_RunActiveContent_file#" language="javascript"></script>
			</cfoutput>
		</cfsavecontent>
	</cfif>

	<cfsavecontent variable="htmlOutput">
		<cfoutput>
			<!--- Modify file name by removing extension--->
			<cfparam name="extensionPoint" default="#Len(ATTRIBUTES.file)#" type="integer">
			<cfset extensionPoint = FindNoCase(".swf", ATTRIBUTES.file, 1) - 1>
			<cfset ATTRIBUTES.file = Left(ATTRIBUTES.file, extensionPoint)>
			
			<!--- Set default value for id if one isn't given.--->
			<cfif Len(Trim(ATTRIBUTES.id)) EQ 0> 
				<cfset slashIndex = FindNoCase("/", Reverse(ATTRIBUTES.file))>
				<cfset ATTRIBUTES.id 			= Right(ATTRIBUTES.file, #slashIndex# - 1)>
			</cfif>

			<script language="javascript">
				if (AC_FL_RunContent == 0) {
					alert("This page requires AC_RunActiveContent.js.");
				} else {
					AC_FL_RunContent(
							'codebase', 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version=9,0,0,0',
							'width', '#ATTRIBUTES.width#',
							'height', '#ATTRIBUTES.height#',
							'src', '#ATTRIBUTES.file#',
							'quality', 'high',
							'pluginspage', 'http://www.macromedia.com/go/getflashplayer',
							'align', 'middle',
							'play', 'true',
							'loop', 'true',
							'scale', '#ATTRIBUTES.scaleMode#',
							'wmode', '#ATTRIBUTES.winMode#',
							'devicefont', 'false',
							'id', '#ATTRIBUTES.id#',
							'bgcolor', '##ffffff',
							'name', '#ATTRIBUTES.id#',
							'menu', 'true',
							'allowFullScreen', 'false',
							'allowScriptAccess','sameDomain',
							'movie', '#ATTRIBUTES.file#',
							'salign', '',
							'FlashVars', '#ATTRIBUTES.parameters#'
						); //end AC code
				}
			</script>
			<noscript>
				<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version=9,0,0,0" width="#ATTRIBUTES.width#" height="#ATTRIBUTES.height#" id="#ATTRIBUTES.id#" align="middle">
				<param name="allowScriptAccess" value="sameDomain" />
				<param name="allowFullScreen" value="false" />
				<param name="movie" value="#ATTRIBUTES.file#.swf" />
				<param name="quality" value="high" />
				<param name="scale" value="#ATTRIBUTES.scaleMode#" />
				<param name="wmode" value="transparent" />
				<param name="bgcolor" value="##ffffff" />	
				<param name="parameters" value="#ATTRIBUTES.parameters#" />
				<embed src="#ATTRIBUTES.file#.swf" quality="high" scale="#ATTRIBUTES.scaleMode#" wmode="#ATTRIBUTES.winMode#" bgcolor="##ffffff" width="#ATTRIBUTES.width#" height="#ATTRIBUTES.height#" name="#ATTRIBUTES.id#" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
				</object>
			</noscript>
		</cfoutput>
	</cfsavecontent>
</cfsilent>

<cfhtmlhead text="#htmlHeadOutput#">
<cfoutput>#htmlOutput#</cfoutput> 