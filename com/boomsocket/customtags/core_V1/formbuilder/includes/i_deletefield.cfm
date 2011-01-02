<cfinclude template="i_getFormobject.cfm">
<cftry>
<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
        input="#q_getform.datadefinition#"
        output="a_formelements">
<cfcatch type="Any">
	<H1>Invalid XML Object</H1>The object you are trying to reference is not recognizable XML. Check the database.
	<cfdump var="#q_getForm.datadefinition#">
	<cfabort>
</cfcatch>		
</cftry>

<cfscript>
	commit=a_formelements[arrayposition].commit;
	arraydeleteat(a_formelements,arrayposition);
</cfscript>

<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="CFML2XML"
        input="#a_formelements#"
        output="form.datadefinition">

	<cfmodule template="#application.customTagPath#/dbaction.cfm" 
			action="UPDATE" 
			tablename="formobject"
			datasource="#application.datasource#"
			whereclause="formobjectid=#trim(form.formobjectid)#">

<cfif q_getForm.parentid EQ q_getForm.formobjectid>
<!--- MASTER FORM OBJECT --->
	<!--- If we are editing a field, drop it from the table first --->
	<cfif commit>
		<cfquery datasource="#application.datasource#" name="q_createTable" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			ALTER TABLE #q_getForm.datatable# DROP COLUMN #trim(form.edit)#
		</cfquery>
	</cfif>
<!--- If this has children, recursively remove field from them --->
<!--- get all children of this form --->
	<cfquery datasource="#application.datasource#" name="q_getAllChildren" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT datadefinition, formobjectid, omitfieldlist
		FROM formobject
		WHERE parentid = #formobjectid#
		AND formobjectid <> #formobjectid#
	</cfquery>
	<cfif q_getAllChildren.recordcount>
		<cfloop query="q_getAllChildren">
		<!--- if the field (form.edit) is found in the omit field list, you only
		have to remove it from the list, then move on - it's not in the xml --->
			<cfset thisListPos=listfindnocase(q_getAllChildren.omitfieldlist,trim(form.edit))>
			<cfif thisListPos>
				<cfquery datasource="#application.datasource#" name="q_updateOmits" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE formobject
					SET omitfieldlist = '#listDeleteAt(q_getAllChildren.omitfieldlist,thisListPos)#'
					WHERE formobjectid = #q_getAllChildren.formobjectid#
				</cfquery>			
			<cfelse>
				<!--- Get XML data definition for child form --->
				<cfquery datasource="#application.datasource#" name="q_getChildDef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT datadefinition
					FROM formobject
					WHERE formobjectid = #q_getAllChildren.formobjectid#
				</cfquery>
				<!--- Deserialize definition --->
				<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
					input="#q_getChildDef.datadefinition#"
					output="a_formelements">
				<!--- loop over array structure until we find the fieldname to be deleted and remove --->
				<cfloop index="i" from="#arrayLen(a_formelements)#" to="1" step="-1">
					<cfif structfind(a_formelements[i],"fieldname") eq trim(form.edit)>
						<cfset dump=arrayDeleteAt(a_formelements,i)>
					</cfif>
				</cfloop>
				<!--- Serialize the structure --->
				<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="CFML2XML"
					input="#a_formelements#"
					output="datadefinition">
				<!--- Insert XML structure back into DB --->
				<cfquery datasource="#application.datasource#" name="q_updateChildDef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE formobject 
					SET datadefinition='#datadefinition#'
					WHERE formobjectid = #q_getAllChildren.formobjectid#
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>

<cfelse>
	<!--- CHILD FORM OBJECT --->
	<!--- If child object add field to omitfieldlist --->
	<cfquery datasource="#application.datasource#" name="q_addToOmitFieldList" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		UPDATE formobject 
		SET omitfieldlist='#listAppend(q_getForm.omitfieldlist,trim(form.edit))#'
		WHERE formobjectid=#form.formobjectid#
	</cfquery>
</cfif>
	<cflocation url="#request.page#?formobjectid=#formobjectid#&toolaction=DEShowForm">
