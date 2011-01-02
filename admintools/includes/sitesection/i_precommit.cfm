<!--- i_precommit.cfm --->

<!--- delete those sucka directories --->
<cfif isDefined("DELETEINSTANCE")><!--- Delete This Dir, already been verified --->
	<cfloop list="#deleteinstance#" index="XX">
		<!--- set session var to for deleting .css file (see i_postcommit.cfm) --->
		<cfset "session.cssFilename_#XX#" = application.getSectionPath(XX,'true')>
		<cfset dirPath="#application.installpath##application.slash##application.getSectionPath(XX,'true')#">
		<cfif DirectoryExists(dirPath)>
            <cflock timeout="20">
                <cfdirectory directory="#dirPath#" action="delete" recurse="yes" >
            </cflock>
        </cfif>
	</cfloop>
<cfelse>
	<cfif form.sitesectionparent GT 0>
		<cfquery name="q_getparentname" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT sitesectionname
			FROM sitesection
			WHERE sitesectionid = <cfqueryparam value="#form.sitesectionparent#" cfsqltype="CF_SQL_INTEGER" >
		</cfquery>
		<cfset form.sitesectionparentname = q_getparentname.sitesectionname>
	</cfif>
</cfif>
