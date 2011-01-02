<cfquery datasource="dp03prsa" name="q_getNew" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT *
	FROM dp03prsa.formobject
	WHERE formobjectid = '100052'
</cfquery>

<cfloop list="#q_getNew.columnList#" index="i">
	<cfif i neq "formobjectid">
		<cfset "form.#i#"=evaluate("q_getNew."&i)>
	</cfif>
</cfloop>

<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
			 datasource="#application.datasource#"
			 tablename="formobject"
			 assignidfield="formobjectid"> 