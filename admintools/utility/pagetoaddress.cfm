<cfquery name="q_pages" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT page.*, sitesectionname
	FROM page
		INNER JOIN sitesection 
			ON page.sitesectionid = sitesection.sitesectionid
	ORDER BY sitesection.sitesectionname ASC
</cfquery>
<cfloop query="q_pages">
	<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="navitemaddress" datasource="#APPLICATION.datasource#"username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	<cfquery name="q_makeAddress" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		INSERT INTO navitemaddress (navitemaddressid,navitemaddressname,datecreated,datemodified,ordinal,formobjecttableid,objectinstanceid) VALUES (#newID#,'#q_pages.sitesectionname#/#q_pages.pagename#',#CreateODBCDateTime(now())#,#CreateODBCDateTime(now())#,#q_pages.currentrow#,103,#q_pages.pageid#)
	</cfquery>
</cfloop>