<cfset useridList=form.userid>
<cfset formobjectList=form.formobject>
<cfset form.supervisorid=form.supervisorid>
<cfset form.datecreated=Now()>
<cfset form.datemodified=Now()>

<cfloop list="#useridList#" index="thisUser">
	<cfloop list="#formobjectList#" index="thisFormObjectID">
		<cfset form.userid=thisUser>
		<cfset form.formobject=thisFormObjectID>
		<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
			 datasource="#application.datasource#"
			 tablename="SupervisorRelationship"
			 assignidfield="SupervisorRelationshipid">

	</cfloop>
</cfloop>

<cfset request.succesMsg="You have successfully added Supervisor Relationships">