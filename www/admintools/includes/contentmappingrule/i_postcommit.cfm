<!--- i_postcommit.cfm --->
<!--- set rule name--->
<!--- inserting or updating --->
<cfif NOT isDefined("deleteinstance")>
	<cfif isDefined("instanceid")>
		<cfset thisid=instanceid>
	<cfelse>
		<cfset thisid=insertid>
	</cfif>
	<cfset mappingObj = createobject("component","#APPLICATION.sitemapping#.components.contentmapping")>
	<cfset forminstanceObj = CreateObject('component','#application.CFCpath#.formInstance')>
	<cfset currentMaster = ListFirst(Trim(form.masterFormobjectid),'~')>
	<cfset currentItem = 1>
	<!--- loop over all associate items --->
	<!--- assocList set in precommit --->
	<cfloop index="thisAssoc" list="#assocList#" delimiters=",">
		<cfset thisMasterFormobjectid = currentMaster>
		<cfset thisAssociateFormobjectid = thisAssoc>	
		<cfset q_masterFormObject = forminstanceObj.getToolInfo(toolid=thisMasterFormobjectid)>
		<cfset q_associateFormObject = forminstanceObj.getToolInfo(toolid=thisAssociateFormobjectid)>	
		<cfset thisname = q_masterFormObject.formobjectname & ' Has ' & q_associateFormObject.formobjectname>
		<cfset form.associateformobjectid = thisAssociateFormobjectid>
		<cfif currentItem EQ 1>
			<cfquery name="q_updateRule" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE contentmappingrule
				SET contentmappingrulename = '#thisname#' 
				WHERE contentmappingruleid = #thisid#
			</cfquery>
		<cfelse>
			<!--- check to see if reverse rule already exists --->
			<cfset thisMasterFormobjectid = currentMaster>
			<cfset thisAssociateFormobjectid = thisAssoc>
			<cfset q_masterFormObject = forminstanceObj.getToolInfo(toolid=thisMasterFormobjectid)>
			<cfset q_associateFormObject = forminstanceObj.getToolInfo(toolid=thisAssociateFormobjectid)>
			<cfset ruleExists = mappingObj.RuleExists(masterFormobjectid=thisMasterFormobjectid,associateFormobjectid=thisAssociateFormobjectid)>
			<cfif NOT ruleExists>
				<cfset form.masterformobjectid = thisMasterFormobjectid>
				<cfset form.associateformobjectid = thisAssociateFormobjectid>
				<cfset form.contentmappingrulename = q_masterFormObject.formobjectname & ' Has ' & q_associateFormObject.formobjectname>
				<cfset structDelete(form,"contentmappingruleid")>
				<cftry>
					<cfmodule template="#application.customTagPath#/dbaction.cfm" 
						action="INSERT" 
						tablename="contentmappingrule"  
						datasource="#application.datasource#" 
						assignidfield="contentmappingruleid">
					<cfcatch type="any">
						<cflog log="application" text="#cfcatch#">
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>
	
		<!--- create reverse rule if applicable --->
		<cfif isDefined('FORM.createReverse') AND listFirst(FORM.createReverse,'~') EQ 1>
			<!--- check to see if reverse rule already exists --->
			<cfset thisMasterFormobjectid = thisAssoc>
			<cfset thisAssociateFormobjectid = currentMaster>	
			<cfset ruleExists = mappingObj.RuleExists(masterFormobjectid=thisMasterFormobjectid,associateFormobjectid=thisAssociateFormobjectid)>
			<!--- if doesn't exists, add --->
			<cfif NOT ruleExists>
				<cfset form.masterformobjectid = thisMasterFormobjectid>
				<cfset form.associateformobjectid = thisAssociateFormobjectid>
				<cfset form.contentmappingrulename = q_associateFormObject.formobjectname & ' Has ' & q_masterFormObject.formobjectname>
				<cfmodule template="#application.customTagPath#/dbaction.cfm" 
					action="INSERT" 
					tablename="#trim(form.tablename)#"  
					datasource="#application.datasource#" 
					assignidfield="#q_getform.datatable#id">
			</cfif>
		</cfif>
		<cfset currentItem = currentItem+1>
	</cfloop>
<cfelse>
	<!---delete mappings for this rule--->
	<cfquery name="q_deleteMappings" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		DELETE FROM contentmapping
		WHERE contentmappingruleid IN (#deleteinstance#)
	</cfquery>
</cfif>

