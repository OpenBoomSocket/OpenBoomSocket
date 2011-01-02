<!--- i_prevalidate.cfm --->
<cfif ListLast(FORM.pageName,'.') NEQ 'cfm' AND ListLast(FORM.pageName,'.') NEQ 'cfml'>
	<cfset REQUEST.isError = 1>
	<cfset REQUEST.errorMSG = "| Your file name must end with a .cfm or .cfml extension |">
</cfif>

<!--- If this is a new page, check to see that a duplicate pagename does not exist in 
	   the givin section --->
<cfif form.pageid eq "">
	<cfset sectionid = ListFirst(FORM.sitesectionid,'~')>
	<cfquery datasource="#application.datasource#" name="q_getDuplicatePage" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT pagename, sitesectionlabel
			FROM page
			INNER JOIN sitesection ON page.sitesectionid = sitesection.sitesectionid
			WHERE pagename = <cfqueryparam cfsqltype="cf_sql_string" value="#FORM.pagename#">
			AND page.sitesectionid = #sectionid#
	</cfquery>
	
	<cfif q_getDuplicatePage.recordCount>
		<cfset REQUEST.iserror = 1>
		<cfset REQUEST.errorMSG = "File Name '#q_getDuplicatePage.pagename#' alredy exits in Section '#q_getDuplicatePage.sitesectionlabel#'">
	</cfif>
</cfif>