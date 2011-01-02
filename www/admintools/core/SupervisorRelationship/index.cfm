<cfset defaultSRstep="showList">
<cfparam name="SRstep" default="#defaultSRstep#">
<cfswitch expression="#SRstep#">
	<!---#############################################################--->
	<cfcase value="showList">
		<cfset request.defaultcall=1>
		<cfinclude template="i_showList.cfm">
	</cfcase>
	<!---#############################################################--->
	<cfcase value="add">
		<cfset request.defaultcall=1>
		<cfinclude template="i_add.cfm">
	</cfcase>
	<!---#############################################################--->
	<cfcase value="validate">
		<cfinclude template="i_validate.cfm">
		<cfinclude template="index.cfm">
	</cfcase>
	<!---#############################################################--->
	<cfcase value="confirmAdd">
		<cfset request.defaultcall=1>
		<cfinclude template="i_confirmAdd.cfm">
	</cfcase>
	<!---#############################################################--->
	<cfcase value="addSupervisors">
		<cfinclude template="i_addSupervisors.cfm">
		<cfset SRstep=defaultSRstep>
		<cfinclude template="index.cfm">
	</cfcase>
	<!---#############################################################--->
	<cfcase value="confirmDelete">
		<cfset request.defaultcall=1>
		<cfinclude template="i_confirmDelete.cfm">
		<cfif isDefined("nodelete")>
			<cfset SRstep=defaultSRstep>
			<cfinclude template="index.cfm">		
		</cfif> 
	</cfcase>
	<!---#############################################################--->
	<cfcase value="deleteAction">
		<cfinclude template="i_deleteAction.cfm">
		<cfset SRstep=defaultSRstep>
		<cfinclude template="index.cfm"> 
	</cfcase>
	<cfdefaultcase>
		<cfset SRstep=defaultSRstep>
		<cfinclude template="index.cfm">
	</cfdefaultcase>
</cfswitch>