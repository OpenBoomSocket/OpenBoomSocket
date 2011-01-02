<cfcomponent>
	<cffunction name="getFormObjects" returntype="query">
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getFormObjects" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT formobject.formobjectname, formobject.formobjectid, formobject.datatable
				FROM formobject
				INNER JOIN userpermission ON userpermission.formobjectid = formobject.formobjectid
				WHERE (userpermission.userid = #session.user.id#) AND (userpermission.access = 1) 
				AND (formobject.formenvironmentid <> 100) AND (formobject.formenvironmentid <> 105) 
				AND (formobject.formenvironmentid <> 107) AND (formobject.formenvironmentid <> 109) 
				AND (formobject.formenvironmentid <> 110) AND (formobject.formobjectid >= 100000)
				ORDER BY formobjectname
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfreturn q_getFormObjects>
	</cffunction>
	
	<cffunction name="getThisObject" returntype="query">
		<cfargument name="formobjectid" required="yes" type="numeric">
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getThisObject" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT formobjectname, formobjectid, formname, datadefinition, datatable, compositeForm, useWorkFlow
				FROM formobject
				WHERE formobjectid = #ARGUMENTS.formobjectid#
				ORDER BY formobjectname
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfreturn q_getThisObject>
	</cffunction>
	
	<cffunction name="deleteRecords" returntype="void">
		<cfargument name="tablename" required="yes" type="string">
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getThisObject" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE
				FROM #ARGUMENTS.tablename#
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="deleteVersions" returntype="void">
		<cfargument name="tableid" required="yes" type="string">
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getThisObject" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE
				FROM version
				WHERE formobjectitemid = #ARGUMENTS.tableid#
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
	</cffunction>
	
		
	<cffunction name="getIds" returntype="query">
		<cfargument name="idfield" required="yes" type="string">
		<cfargument name="tablename" required="yes" type="string">
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getIds" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT #ARGUMENTS.idfield# AS id
				FROM #ARGUMENTS.tablename#
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfreturn q_getIds>
	</cffunction>
	
	<cffunction name="convertDisplayData" returntype="any">
		<cfargument name="lookuptable" required="yes" type="string">
		<cfargument name="lookupdisplay" required="yes" type="string">
		<cfargument name="lookupkey" required="yes" type="string">
		<cfargument name="displayData" required="yes" type="any">
		<!--- <cfdump var="#ARGUMENTS.lookuptable#-#ARGUMENTS.lookupdisplay#-#ARGUMENTS.lookupkey#-#ARGUMENTS.displayData#">
		<cfabort> --->
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getKeyData" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT #ARGUMENTS.lookupkey# AS keyData
				FROM #ARGUMENTS.lookuptable#
				WHERE #ARGUMENTS.lookupdisplay# = <cfif isnumeric(ARGUMENTS.displayData)>#ARGUMENTS.displaydata#<cfelse>'#ARGUMENTS.displaydata#'</cfif>
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		
		</cftry>
		<cfreturn q_getKeyData.keyData>
	</cffunction>
</cfcomponent>