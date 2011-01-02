<!--- Set admintemplate based on attributes, URL, or Form --->	
	<!--- default template: main --->
	<cfparam name="request.admintemplate" default="main"><!--- blank, editlive, login, main, popup  --->
	<!--- if admintemplate passed in as attribute, use this instead --->
	<cfif isDefined('attributes.admintemplate') AND Len(attributes.admintemplate)>
		<cfset request.admintemplate = attributes.admintemplate>
	</cfif>
	<!--- if admintemplate defined in URL or FORM scope, use this instead --->
	<cfif isDefined('URL.admintemplate') AND Len(Trim(URL.admintemplate))>
		<cfset REQUEST.admintemplate = Trim(URL.admintemplate)>
	<cfelseif isDefined('FORM.admintemplate') AND Len(Trim(FORM.admintemplate))>
		<cfset REQUEST.admintemplate = Trim(FORM.admintemplate)>
	</cfif>
	<cfset attributes.admintemplate = request.admintemplate>


<!--- Set headertext based on attributes, URL, or Form --->
	<cfparam name="request.headerText" default="&nbsp;">
	<!--- if admintemplate passed in as attribute, use this instead --->
	<cfif isDefined('attributes.headerText') AND Len(attributes.headerText)>
		<cfset request.headerText = attributes.headerText>
	</cfif>
	<!--- if admintemplate defined in URL or FORM scope, use this instead --->
	<cfif isDefined('URL.headerText') AND Len(Trim(URL.headerText))>
		<cfset REQUEST.headerText = Trim(URL.headerText)>
	<cfelseif isDefined('FORM.headerText') AND Len(Trim(FORM.headerText))>
		<cfset REQUEST.headerText = Trim(FORM.headerText)>
	</cfif>
	<cfset attributes.headerText = request.headerText>

<cfparam name="request.defaultCall" default="1">
<cfparam name="request.needsHeader" default="#request.defaultCall#">
<cfparam name="request.needsFooter" default="#request.defaultCall#">
<cfparam name="attributes.admintemplate" default="#request.admintemplate#">
<cfparam name="attributes.title" default=":: Open BoomSocket ::">
<cfparam name="attributes.css" default="">
<cfparam name="attributes.javascript" default="">
<cfparam name="attributes.onload" default="">

<cfsetting enablecfoutputonly="yes">
<!--- HEADER --->
<cfif thistag.executionmode is "START">
	<cfif request.needsHeader>
		<cfoutput><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
			<title>#attributes.title#</title>
			<!--- include css --->
			<style type="text/css"><cfinclude template="#application.globalPath#/css/admintoolsCSS.cfm"></style>
			
			</cfoutput><cfinclude template="/css/navigation/adminstyles.cfm">
			<cfloop list="#attributes.css#" delimiters="," index="s">
				<cfif findNoCase("http://",s)>
					<cfoutput><link rel="stylesheet" href="#s#" type="text/css" /></cfoutput>
				<cfelse>
					<cfoutput><link rel="stylesheet" href="/css/#s#" type="text/css" /></cfoutput>
				</cfif>
			</cfloop>			
			<!--- include any necessary javascript --->
			<cfoutput><script type="text/javascript" src="/javascript/WOM.js"></script></cfoutput>
			<cfif len(attributes.javascript)>
				<cfoutput><script type="text/JavaScript"></cfoutput>
					<cfloop list="#attributes.javascript#" delimiters="," index="j">
						<cfif fileExists("#application.installpath#\javascript\#j#")>
							<cfoutput><cfinclude template="/#application.sitemapping#/javascript/#j#"></cfoutput>
						<cfelse>
							<cfoutput>alert("Your javascript include was not found!");</cfoutput>
						</cfif>
					</cfloop>
			<!--- If we are in an edit window and have completed a cycle, refresh parent and close --->
					<cfif isDefined("url.closeWindow")>
				<!--- if we are using a pop-up tool inside another tool process, post the parent tool form--->
						<cfif isDefined("session.i3previoustool")>
							<cfset tmp=structFindValue(application.tool,"#session.i3previoustool#")>
							<cfset structDelete(session,"i3previoustool")>
							<cfoutput>window.opener.document.#tmp[1].key#.formstep.value="showform";</cfoutput>
							<cfoutput>window.opener.document.#tmp[1].key#.submit();</cfoutput>
				<!--- just refresh the parent window --->
						<cfelse>
							<cfoutput>window.opener.location.reload();</cfoutput>
						</cfif>
						<cfoutput>self.close();</cfoutput>
					</cfif>
				<cfoutput></script></cfoutput>
			</cfif>
			<!--- sIFR js & css goes here --->
			<cfoutput>
				<cfif FileExists('#ExpandPath(application.globalPath)#/sifr/sIFR-screen.css')>
					<link rel="stylesheet" href="#APPLICATION.globalpath#/sifr/sIFR-screen.css" type="text/css" media="screen" />
				</cfif>
				<cfif FileExists('#ExpandPath(application.globalPath)#/sifr/sIFR-print.css')>
					<link rel="stylesheet" href="#APPLICATION.globalpath#/sifr/sIFR-print.css" type="text/css" media="print" />
				</cfif>
				<cfif FileExists('#application.installpath#/sifr/sifr.css')>
					<link rel="stylesheet" href="/sifr/sifr.css" type="text/css" media="screen" />
				</cfif>
				<cfif FileExists('#application.installpath#/sifr/sifr-replaceElements.js')>
					<script src="/sifr/sifr-replaceElements.js" type="text/javascript"></script>
				</cfif>
				<cfif FileExists('#ExpandPath(application.globalPath)#/sifr/sifr.js')>
					<script src="#APPLICATION.globalpath#/sifr/sifr.js" type="text/javascript"></script>
				</cfif>	
			</cfoutput>	
		<cfoutput></head>
		<body style="margin: 0px" onload="#attributes.onload#">
			<!--- precontent for each template --->
			<cfswitch expression="#LCase(attributes.admintemplate)#">
				<!--- login  template -------------------------------------------------------------------------->
				<cfcase value="login">
					<cfsavecontent variable="loginheaderstuff">
						<style type="text/css">
							body{
								background-color:##002142;
								background-image:url(/admintools/media/images/loginstarsBG.jpg);
								background-repeat:no-repeat;
								background-position:top left;
							}
						</style>
					</cfsavecontent>
					<cfhtmlhead text="#loginheaderstuff#">
				</cfcase>
				
				<!--- editlive template ------------------------------------------------------------------------>
				<cfcase value="editlive">
					<cfsavecontent variable="headerStuff">
						<cfoutput>
							<style type="text/css">
								body{
									background-image:url(/admintools/media/images/topBlueGradSmallBG.png);
									background-color:##fff;
									background-repeat:repeat-x;
								}
								##header{
									background-image:url(/admintools/media/images/headerBGliveEdit.jpg);
									background-repeat:no-repeat;
									background-position:top;
									height:21px;
									text-align: right;
								}
								##topNavBar{
									width: 950px;
									margin: 0 auto;
									margin-top:2px;
								}
								
								/* if keep iframe */
								##mainShell{
									width: 100%;
									background-image:none;
									min-height: 400px;
								}
								##liveEditWrapper{
									margin-top:25px;
									##margin-top:28px;
								}
							</style>
							<script type="text/javascript">				//http://www.huntingground.freeserve.co.uk/main/mainfram.htm?../webplus/iframes/iframe_resize.htm
							<!--			
							moz=document.getElementById&&!document.all;
							mozHeightOffset=20;
							
							function resize_iframe(){						
							document.getElementById("liveEditFrame").height=400; // required for Moz bug, value can be "", null, or integer
							document.getElementById('liveEditFrame').height=window.frames["liveEditFrame"].document.body.scrollHeight+50+(moz?mozHeightOffset:0);
							}
							// -->
							</script>
						</cfoutput>
					</cfsavecontent>
					<cfhtmlhead text="#headerStuff#">
					
					<!--- Turn live edit on --->
					<cfif isDefined('URL.switch') AND Trim(URL.switch)>
						<cfif NOT isDefined('session.user.liveEdit') OR session.user.liveEdit neq 1>
							<cflock scope="SESSION" timeout="5" type="EXCLUSIVE">
								<cfset session.user.liveEdit=1>
							</cflock>
						</cfif>
					<!--- Turn live edit off --->
					<cfelseif isDefined('URL.switch') AND NOT Trim(URL.switch)>
						<cfif isDefined('session.user.liveEdit') AND session.user.liveEdit eq 1>
							<cflock scope="SESSION" timeout="5" type="EXCLUSIVE">
								<cfset session.user.liveEdit=0>
							</cflock>
						</cfif>
					</cfif>
					
				<cfsavecontent variable="topnavtoolbar"><cfoutput><cfmodule template="#APPLICATION.customTagPath#/nav.cfm" navgroupid="1000" textonly="0" classbase="adminnavlist" issecure="1" usepermissions="1"></cfoutput></cfsavecontent>
				<!--- output page content --->
					<div id="mainShell">
						<div id="header">
							<div id="topNavBar"><div id="nonNavItems"><a href="/admintools/index.cfm?i3displaymode=welcome" onmouseover='javascript:this.getElementsByTagName("img")[0].src="/admintools/media/images/homeSmall_on.png";' onmouseout='javascript:this.getElementsByTagName("img")[0].src="/admintools/media/images/homeSmall_off.png";'><img src="/admintools/media/images/homeSmall_off.png" border="0" /></a><cfif isDefined('SESSION.user.liveEdit') AND SESSION.user.liveEdit><a href="/admintools/index.cfm?i3displayMode=editLive&switch=0" onmouseover='javascript:this.getElementsByTagName("img")[0].src="/admintools/media/images/editLiveON_on.png";' onmouseout='javascript:this.getElementsByTagName("img")[0].src="/admintools/media/images/editLiveON_off.png";'><img src="/admintools/media/images/editLiveON_off.png" border="0" /></a><cfelse><a href="/admintools/index.cfm?i3displayMode=editLive&switch=1" onmouseover='javascript:this.getElementsByTagName("img")[0].src="/admintools/media/images/editLiveOFF_on.png";' onmouseout='javascript:this.getElementsByTagName("img")[0].src="/admintools/media/images/editLiveOFF_off.png";'><img src="/admintools/media/images/editLiveOFF_off.png" border="0" /></a></cfif></div><cfoutput>#trim(topnavtoolbar)#</cfoutput></div>
						</div>
						<div id="liveEditWrapper">				
				</cfcase>
				
				<!--- popup template --------------------------------------------------------------------------->
				<cfcase value="popup">
					<cfsavecontent variable="popupheaderstuff">
						<style type="text/css">
							body{
								background:none;
								background-color:##002850;
								}
						</style>
					</cfsavecontent>
					<cfhtmlhead text="#popupheaderstuff#">
					<!--- need to search for popupcontent sitewide to take out & pass in header attribute --->
					<div id="socketformheader"><h2>#attributes.headerText#</h2></div>
					<div style="clear:both;"></div>
					<div id="popupcontent">			
				</cfcase>
				
				<!--- blank template --------------------------------------------------------------------------->
				<cfcase value="blank">
					<cfsavecontent variable="blankheaderstuff">
						<style type="text/css">
							body{
								background:none;
								background-color:##fff;
								}
						</style>
					</cfsavecontent>
					<cfhtmlhead text="#blankheaderstuff#">
				</cfcase>
				
				<!--- main template ---------------------------------------------------------------------------->
				<cfdefaultcase>
					<cfsavecontent variable="topnavtoolbar"><cfoutput><cfmodule template="#APPLICATION.customTagPath#/nav.cfm" navgroupid="1000" textonly="0" classbase="adminnavlist" issecure="1" usepermissions="1"></cfoutput></cfsavecontent>
					<div id="mainShell">
						<div id="header">
							<div id="textNav"><cfoutput><a href="/admintools/index.cfm?i3displayMode=help">help</a> | <a href="#application.installurl#/" target="_blank">live site</a> | <a href="login.cfm?logout=yes" target="_top">log out</a></cfoutput></div>
							<a href="/admintools/index.cfm?i3displayMode=welcome"><img src="/admintools/media/images/boomsocket_logo.png" width="210" height="72" id="logo" border="0" /></a>
							<div id="topNavBar"><div id="nonNavItems"><a href="/admintools/index.cfm?i3displaymode=welcome" onmouseover='javascript:this.getElementsByTagName("img")[0].src="/admintools/media/images/home_on.png";' onmouseout='javascript:this.getElementsByTagName("img")[0].src="/admintools/media/images/home_off.png";'><img src="/admintools/media/images/home_off.png" border="0" /></a><cfif isDefined('SESSION.user.liveEdit') AND SESSION.user.liveEdit><a href="/admintools/index.cfm?i3displayMode=editLive&switch=0" onmouseover='javascript:this.getElementsByTagName("img")[0].src="/admintools/media/images/editLiveON_on.png";' onmouseout='javascript:this.getElementsByTagName("img")[0].src="/admintools/media/images/editLiveON_off.png";'><img src="/admintools/media/images/editLiveON_off.png" border="0" /></a><cfelse><a href="/admintools/?i3displayMode=editLive&switch=1" onmouseover='javascript:this.getElementsByTagName("img")[0].src="/admintools/media/images/editLiveOFF_on.png";' onmouseout='javascript:this.getElementsByTagName("img")[0].src="/admintools/media/images/editLiveOFF_off.png";'><img src="/admintools/media/images/editLiveOFF_off.png" border="0" /></a></cfif></div><cfoutput>#trim(topnavtoolbar)#</cfoutput></div>
						</div>
						<div id="contentArea">
							<!--- js to hide form elements when hover over admin nav --->
							<!--- This is also in BS_Global/filemanager/i_functions.cfm --->
							<script type="text/javascript">
							function hideSearchForm(){
								if(document.getElementById('adminnavlist') && document.getElementById('searchWrapper')){
									document.getElementById('adminnavlist').onmouseover = function(){
										document.getElementById('searchWrapper').style.display = "none";
									}
									document.getElementById('adminnavlist').onmouseout = function(){
										document.getElementById('searchWrapper').style.display = "block";
									}
								}
							}
							womAdd('hideSearchForm()');
							womOn();
							</script>				
				</cfdefaultcase>
			</cfswitch>		
		</cfoutput>
		<cfset request.needsHeader=0>
	
<!--- FOOTER --->
</cfif><cfelseif thistag.executionmode is "END">
		<cfif request.needsFooter>
			<cfoutput>
			<!--- postcontent for each template --->
			<cfswitch expression="#LCase(attributes.admintemplate)#">
				<!--- login  template -------------------------------------------------------------------------->
				<cfcase value="login">
					<!--- empty --->
				</cfcase>
				
				<!--- editlive template ------------------------------------------------------------------------>
				<cfcase value="editlive">
						</div>
					</div>
				</cfcase>
				
				<!--- popup template --------------------------------------------------------------------------->
				<cfcase value="popup">
					<!--- need to search for popupcontent sitewide to take out & pass in header attribute--->
					</div> 
				</cfcase>
				
				<!--- blank template --------------------------------------------------------------------------->
				<cfcase value="blank">
					<!--- empty --->
				</cfcase>
				
				<!--- main template ---------------------------------------------------------------------------->
				<cfdefaultcase>
					</div>
						</div>
						<div id="footer">
							All content &copy; 2006-<cfoutput>#DateFormat(now(),'yyyy')#</cfoutput> <a href="http://www.openboomsocket.com" target="_blank">Open BoomSocket</a>
						</div>
				</cfdefaultcase>
			</cfswitch>	
			<cfsavecontent variable="womOnCall"><script type="text/javascript">womOn();</script></cfsavecontent>
			<cfhtmlhead text="#womOnCall#">
			</body></html></cfoutput>
			<cfset request.needsFooter=0>
		</cfif>
</cfif>
<cfsetting enablecfoutputonly="no">