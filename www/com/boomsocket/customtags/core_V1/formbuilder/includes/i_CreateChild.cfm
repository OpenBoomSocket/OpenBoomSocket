<cftransaction>
	<cfquery datasource="#application.datasource#" name="q_replicate" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		exec dbo.CreateChildRowInTable @TableName=formobject, @ParentID=#trim(form.parentid)#
	</cfquery>
<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="formobject">
</cftransaction>
<!--- <cfquery datasource="#application.datasource#" name="q_dump">
		Select datadefinition
		from formobject
		where formobjectid = #newid#
</cfquery>
<cfdump var="#q_dump#">
<cfabort> --->
<cflocation url="#request.page#?toolaction=DTShowForm&formobjectid=#q_replicate.ID#">
