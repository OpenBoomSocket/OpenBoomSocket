<!--- Query for default homepage and send em on --->
<cfquery datasource="#application.datasource#" name="q_getDefault" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT page.pagename,page.sitesectionid
	FROM sitesettings INNER JOIN page ON sitesettings.defaulthomepage = page.pageid
</cfquery>
<cfif q_getDefault.recordcount>
	<cfset homepage="#application.getSectionPath(q_getDefault.sitesectionid,"true")#/#q_getDefault.pagename#">
	<cfif fileExists("#application.installpath#\#replaceNoCase(homepage,"/","\","all")#")>
		<cfmodule template="#application.customTagPath#/pageconstructor.cfm" pagepath="/#homepage#" />
	<cfelse>
		ERROR: There is no default homepage set!
		<cfabort>
	</cfif>
<cfelse>
		ERROR: There is no default homepage set!
		<cfabort>
</cfif>