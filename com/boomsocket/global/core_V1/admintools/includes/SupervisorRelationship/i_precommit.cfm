<!--- i_precommit.cfm --->
<cfif NOT isDefined("deleteinstance")>
	<cfset useridList=form.userid>
	<cfset formobjectList=form.formobject>
	<cfset form.supervisorid=listFirst(form.supervisorid,"~")>
	
	<cfloop list="#useridList#" index="thisUser">
		<cfloop list="#formobjectList#" index="thisFormObjectID">
			<cfset form.userid=listFirst(thisUser,"~")>
			<cfset form.formobject=listFirst(thisFormObjectID,"~")>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
				 datasource="#application.datasource#"
				 tablename="SupervisorRelationship"
				 assignidfield="SupervisorRelationshipid">	
		</cfloop>
	</cfloop>
<cflocation url="#request.page#">
<cfset request.stopprocess="commit">
</cfif>
