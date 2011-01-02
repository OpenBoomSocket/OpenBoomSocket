<!--- i_postcommit.cfm --->
<cflock type="EXCLUSIVE" scope="SESSION" timeout="5">
	<cfset session.debug=trim(form.debugging)>
</cflock>

<!--- check to see if there's a site entry in Meta yet --->
<cfquery name="q_metaCheck" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT 
		metaid 
	FROM 
		meta
	WHERE 
		metaid=100000
</cfquery>
<cfif NOT q_metaCheck.recordcount>
	<cfquery name="q_metaPut" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		INSERT INTO 
			meta
				(metaid,
				metaIncludeSite,
				metaIncludeSection,
				metaRobotsIndex,
				metaRobotsFollow)
		VALUES 
				(100000,
				0,
				0,
				1,
				1)
	</cfquery>
</cfif>