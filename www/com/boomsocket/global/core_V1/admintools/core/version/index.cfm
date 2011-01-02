<cfif NOT isDefined("deleteinstance")>
<script type="text/javascript" src="<cfoutput>#application.globalPath#</cfoutput>/admintools/includes/javascript/version.js"></script>
<cfif NOT isDefined("SESSION.ReviewQueue")>
	<cfset SESSION.ReviewQueue = createObject("component","#APPLICATION.CFCPath#.reviewQueue")>	
</cfif>
<cfset ReviewQueue = SESSION.ReviewQueue>

<!--- set arguments for reviewqueue.cfc getAllContentElements --->
<cfset varInstanceid = ''>
<cfset varViewall = ''>
<cfset varSortby = ''>
<cfset varStatusFilter = ''>
<cfset varViewByStatus = false>
<cfif isDefined("url.instanceid") AND Len(url.instanceid)>
	<cfset varInstanceid = url.instanceid>		
</cfif>
<cfif isDefined("url.viewall") AND Len(url.viewall)>
	<cfset varViewall = url.viewall>		
</cfif>
<cfif isDefined("url.sortby") AND Len(url.sortby)>
	<cfset varSortby = url.sortby>		
</cfif>
<cfif isDefined("url.statusFilter") AND Len(url.statusFilter)>
	<cfset varStatusFilter = url.statusFilter>		
</cfif>
<cfif isDefined("url.viewByStatus") AND Len(url.viewByStatus)>
	<cfset varViewByStatus = true>		
</cfif>
<!--- call cfc functions--->
<cfset q_Status = ReviewQueue.getAllStatus()>	
<cfset q_RQformobjectid = ReviewQueue.getRQformobjectid()>

<!--- if just updated the status/owner of an item, select the updated version in the condensed/dashboard view--->
<cfparam name="UpdatedVersion" default="0">
<cfif isDefined('url.UpdatedVersion') AND Len(Trim(url.UpdatedVersion))>
	<cfset UpdatedVersion = url.UpdatedVersion>
</cfif>

<!--- Change ownership; see reviewqueue.cfc--->
<cfif isDefined("form.ownerid")>
	<cfset UpdateOwner_versionid = ReviewQueue.updateElementOwner(formobject=#trim(form.formobject)#,ownerid=#trim(form.ownerid)#,versionid=#trim(form.versionid)#)>
	<cfset UpdatedVersion = UpdateOwner_versionid>	
</cfif>

<!--- Update Status; see reviewqueue.cfc --->
<cfif isDefined("form.versiondirectiveid") AND Trim(form.versiondirectiveid) eq 0>
	<!--- get default directive for this status --->
	<cftry>
		<cfset q_getDefaultDirective = ReviewQueue.getDirectives(versionstatusid=trim(form.versionstatusid),isDefault=true)>
		<cfif q_getDefaultDirective.recordcount>
			<cfset form.versiondirectiveid = q_getDefaultDirective.versiondirectiveid>
		</cfif>
		<cfcatch type="database"></cfcatch>
	</cftry> 			
</cfif>
<cfif isDefined("form.versionstatusid") AND isDefined("form.versiondirectiveid")>
	<cfset UpdateStatus_versionid = ReviewQueue.updateElementStatus(versionstatusid=#trim(form.versionstatusid)#,versionid=#trim(form.versionid)#,formobjectitemid=#trim(form.formobject)#,parentid=#trim(form.parentid)#,versiondirectiveid=#form.versiondirectiveid#)>
	<cfset UpdatedVersion = UpdateStatus_versionid>	
<cfelseif isDefined("form.versionstatusid")>	
	<cfset UpdateStatus_versionid = ReviewQueue.updateElementStatus(versionstatusid=#trim(form.versionstatusid)#,versionid=#trim(form.versionid)#,formobjectitemid=#trim(form.formobject)#,parentid=#trim(form.parentid)#)>
	<cfset UpdatedVersion = UpdateStatus_versionid>		
</cfif>
	
<!--- if owner or status has been updated, refresh page to show changes--->
<cfif isDefined("form.ownerid") OR isDefined("form.versionstatusid")>
	<cfset url2 = "#request.page#?UpdatedVersion=" & UpdatedVersion>
		<cfif isDefined("form.viewall")>
			<cfset url2 = url2 & "&viewall=yes">
		</cfif>
		<cfif isDefined("form.sortBy")>
			<cfset url2 = url2 & "&sortBy=#form.sortBy#">
		</cfif>
		<cfif isDefined("form.viewByStatus")>
			<cfset url2 = url2 & "&viewByStatus=yes">
		</cfif>
	<cflocation addtoken="No" url="#url2#">
</cfif>
	
<!--- Presentation --------------------------------------->
<!--- Homepage/Dashboard viewer --->
	<cfif NOT isDefined("session.i3currenttool") OR len(session.i3currentTool) EQ 0>
		<cftry>
			<cfset q_getVersionDirective = ReviewQueue.getDirectives()>
			<cfcatch type="database"></cfcatch>
		</cftry> 
		<cfset variables.pageview = "dashboard">
		<cfif isDefined('q_getVersionDirective')>
			<cfinclude template="../../includes/version/i_reviewQ_dashboard.cfm">
		<cfelse>
			<cfinclude template="../../includes/version/i_reviewQ_condensed.cfm">
		</cfif> 		
	<cfelse>
<!--- ReviewQueue Views -------------------------------->				
		<!--- Version Management ---------------------------------------------------------------->
		<cfif isDefined('url.parentid') AND Len(url.parentid) AND isDefined('url.formobjectid') AND Len(url.formobjectid)>
			<cfinclude template="../../includes/version/i_reviewQ_versionMgt.cfm">					
		
		<!--- View By Status ---------------------------------------------------------------->
		<cfelseif varViewByStatus eq "yes">
			<cfinclude template="../../includes/version/i_reviewQ_versionInventory.cfm">
		<!--- Condensed View ---------------------------------------------------------------->
		<cfelse>
			<cfset variables.pageview = "reviewq">
			<cfinclude template="../../includes/version/i_reviewQ_condensed.cfm">
		</cfif>
	</cfif>
</cfif>