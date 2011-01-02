<cfparam name="request.defaultCall" default="1">
<cfparam name="request.needsHeader" default="#request.defaultCall#">
<cfparam name="request.needsFooter" default="#request.defaultCall#">
<cfparam name="attributes.title" default="Open BoomSocket">
<cfparam name="attributes.css" default="site.css">
<cfparam name="attributes.javascript" default="">
<cfparam name="attributes.onload" default="">
<cfparam name="attributes.bgcolor" default="ffffff">
<cfparam name="attributes.padding" default="0">
<cfsetting enablecfoutputonly="yes">
<cfif thistag.executionmode is "START">
	<cfif request.needsHeader>
		<cfoutput>
		<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
		<html>
		<head>
			<title>#attributes.title#</title>
			<!-- include style sheets -->
			<cfinclude template="#application.globalPath#/css/buttonBarStyles.cfm" />
			<!--- <link rel="stylesheet" href="#application.globalPath#/css/buttonBarStyles.css" type="text/css"><style type="text/css"></style> --->
		
			</cfoutput><cfloop list="#attributes.css#" delimiters="," index="s">
				<cfif findNoCase("http://",s)>
					<cfoutput><link rel="stylesheet" href="#s#" type="text/css" /></cfoutput>
				<cfelse>
					<cfoutput><link rel="stylesheet" href="/css/#s#" type="text/css" /></cfoutput>
				</cfif>
			</cfloop>
			<!--- include any necessary javascript --->
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
		<cfoutput></head>
		<body style="margin: 0px" onLoad="#attributes.onload#" bgcolor="###attributes.bgcolor#"></cfoutput>
		<cfset request.needsHeader=0>
	
</cfif><cfelseif thistag.executionmode is "END">
		<cfif request.needsFooter>
			<cfoutput></body></html></cfoutput>
			<cfset request.needsFooter=0>
		</cfif>
</cfif>
<cfsetting enablecfoutputonly="no">


