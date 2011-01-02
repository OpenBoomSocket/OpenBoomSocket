<!--- i_preshowform.cfm --->
<!--- Query the javascript directory for files --->
<cfdirectory action="LIST"
             directory="#application.installpath##application.slash#javascript"
             name="tmpQuery" 
			 filter="*.js">
<cfset q_customQuery_javascriptfile=queryNew("lookupkey,lookupdisplay")>
<cfloop query="tmpQuery">
	<cfset tmpRow=QueryAddRow(q_customQuery_javascriptfile)>
	<cfset tmpCell=QuerySetCell(q_customQuery_javascriptfile,"lookupkey",tmpQuery.Name)>
	<cfset tmpCell=QuerySetCell(q_customQuery_javascriptfile,"lookupdisplay",tmpQuery.Name)>
</cfloop>
<cfset request.q_customQuery_javascriptfile=q_customQuery_javascriptfile>

<cfif isDefined("instanceid")>
	<cfquery datasource="#application.datasource#" name="q_getPages" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT * FROM javascript_page
		WHERE javascriptid = #instanceid#
	</cfquery>
	<cfset form.pageid=valueList(q_getPages.pageid)>
	<cfquery datasource="#application.datasource#" name="q_getSections" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT * FROM javascript_sitesection
		WHERE javascriptid = #instanceid#
	</cfquery>
	<cfset form.sitesectionid=valueList(q_getSections.sitesectionid)>
<cfelse>
	<cfset form.sitesectionid="">
	<cfset form.pageid="">
</cfif>