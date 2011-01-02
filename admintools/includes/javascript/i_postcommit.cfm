<!--- i_postcommit.cfm --->
<cfif isDefined("deleteinstance")>
	<cfquery datasource="#application.datasource#" name="q_clear" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		DELETE FROM javascript_sitesection
		WHERE javascriptid = #trim(deleteinstance)#
	</cfquery>
	<cfquery datasource="#application.datasource#" name="q_clear" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		DELETE FROM javascript_page
		WHERE javascriptid = #trim(deleteinstance)#
	</cfquery>
<cfelse>
	<cfif isDefined("instanceid")>
		<cfset thisHereID=instanceid>
	<cfelse>
		<cfset thisHereID=insertid>
	</cfif>
<!--- Deal with pages --->
	<cfquery datasource="#application.datasource#" name="q_clear" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		DELETE FROM javascript_page
		WHERE javascriptid = #trim(thisHereID)#
	</cfquery>
	<cfloop list="#form.pageid#" index="p">
		<cfquery datasource="#application.datasource#" name="q_populate" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			INSERT INTO javascript_page (javascriptid, pageid)
			VALUES (#trim(thisHereID)#,#listFirst(p,"~")#)
		</cfquery>
	</cfloop>
<!--- Deal with section --->
	<cfquery datasource="#application.datasource#" name="q_clear" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		DELETE FROM javascript_sitesection
		WHERE javascriptid = #trim(thisHereID)#
	</cfquery>
	<cfloop list="#form.sitesectionid#" index="s">
		<cfquery datasource="#application.datasource#" name="q_populate" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			INSERT INTO javascript_sitesection (javascriptid, sitesectionid)
			VALUES (#trim(thisHereID)#,#listFirst(s,"~")#)
		</cfquery>
	</cfloop>
</cfif>

