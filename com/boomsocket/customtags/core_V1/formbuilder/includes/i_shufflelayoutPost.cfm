<!--- Update Table Layout --->
<cfsavecontent variable="closeWindowJS">
	<cfoutput>
		<script language="JavaScript">
			function complete(){
			//var x=1;
				window.opener.location.reload();
				self.close();
			}
			complete();
		</script>
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#closeWindowJS#">
	<cfquery datasource="#application.datasource#" name="q_getDataDef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT datadefinition, tablerows, tabledefinition
		FROM  formobject
		WHERE (formobjectid = #formobjectid#)
	</cfquery>
		<cfmodule template="#application.customTagPath#/xmlConvert.cfm" 
				action="XML2CFML"
				input="#q_getdatadef.datadefinition#"
				output="a_formelements">
		<cfmodule template="#application.customTagPath#/xmlConvert.cfm" 
				action="XML2CFML"
				input="#q_getDataDef.tabledefinition#"
				output="a_tableelements">	
	
			<cfloop from="1" to="#arrayLen(a_formelements)#" index="j">
				<cfscript>
					isInList=listFind(form.fieldssave,listFirst(a_formelements[j].gridposlabel,"_" ));
					if (isInList){
						a_formelements[j].gridposlabel="#isInList#_#listLast(a_formelements[j].gridposlabel,"_" )#";
						a_formelements[j].gridposvalue="#isInList#_#listLast(a_formelements[j].gridposvalue,"_" )#";
					}
				</cfscript>
			</cfloop>
			
		<!--- reorder the actual table rows --->
		<!--- make a copy --->
		<cfset a_tableelementsTmp=a_tableelements>
		<cfloop from="1" to="#arrayLen(a_tableelements)#" index="m">
			<cfset a_tableelements[listFind(form.fieldssave,m)]=a_tableelementsTmp[m]>
		</cfloop>
		<cfmodule template="#application.customTagPath#/xmlConvert.cfm" 
				action="CFML2XML"
				input="#a_formelements#"
				output="datadefinition">
		<cfmodule template="#application.customTagPath#/xmlConvert.cfm" 
				action="CFML2XML"
				input="#a_tableelements#"
				output="tabledefinition">
		<cfquery datasource="#application.datasource#" name="q_updateDataDefOrder" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			UPDATE formobject
			SET datadefinition = '#datadefinition#', tabledefinition = '#tabledefinition#'
			WHERE (formobjectid = #form.formobjectid#)
		</cfquery>
		