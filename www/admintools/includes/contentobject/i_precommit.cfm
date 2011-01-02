<!--- i_precommit.cfm --->

	<cfif isDefined("form.pageid") AND isDefined("form.contentid")>
		<cfset form.instanceid=listFirst(form.contentid,"~")>
	
	</cfif>	 
	