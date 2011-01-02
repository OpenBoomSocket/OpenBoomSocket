<!--- i_precommit.cfm --->
<cfif isDefined("deleteinstance")>
	<cfloop list="#deleteinstance#" index="thisTemplateDel">
		<!--- delete the file --->
		<cfquery datasource="#application.datasource#" name="q_getfilename" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT templatefilename
			FROM template
			WHERE templateid=#thisTemplateDel#
		</cfquery>
		<cflock type="EXCLUSIVE" timeout="5">
			<cffile action="DELETE"
			        file="#application.templatepath#\#q_getfilename.templatefilename#">
		</cflock>
	</cfloop>
</cfif>
