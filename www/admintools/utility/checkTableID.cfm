<cfset thisDSN = application.datasource>
<!--- Grab all the data from Table ID --->
<cfquery name="q_getTableIDData" datasource="#thisDSN#">
	SELECT TableName, ID
	FROM TableID
</cfquery>

<!--- Loop over the records and then compare the ID in Table ID with the MAX actually in that table --->
<cfloop query="q_getTableIDData">
	<cfset thisTableName = q_getTableIDData.TableName>
	<cfset thisTableID = q_getTableIDData.ID>
	<!--- Query this table and get the max ID --->
	<cfquery name="q_getMaxIDInUse" datasource="#thisDSN#">
		SELECT Max(#thisTableName#ID) as topID
		FROM #thisTableName#
	</cfquery>
	<cfif q_getMaxIDInUse.topID GTE 1>
		<cfset thisActualTableID = q_getMaxIDInUse.topID>
	<cfelse>
		<cfset thisActualTableID = 99999>
	</cfif>	
	<cfoutput>
		<h1>#thisTableName#</h1>
		<ul>
			<li>Current Top ID is: <cfif thisActualTableID EQ 99999>Table has no records<cfelse>#thisActualTableID#</cfif></li>
			<li>Table ID Next Record is: #thisTableID#</li>
			<cfif thisTableID EQ thisActualTableID>
				<li style="color:##FF0000">Possible ID conflict value in TableID matches top record in #thisTableName#</li>
			<cfelseif thisActualTableID GTE 99999 AND thisTableID-1 LT thisActualTableID>
				<li style="color:##FF0000">Possible ID conflict value in TableID is less than top record in #thisTableName#</li>
			<cfelseif thisActualTableID GTE 99999 AND thisTableID-1 GT thisActualTableID>
				<li style="color:##FF0000">Possible ID conflict value in TableID is greator than top record in #thisTableName# by a value of #thisTableID-thisActualTableID#</li>
			<cfelse>
				<li style="color:##006600">ID's are in Sync</li>
			</cfif>
		</ul>
	</cfoutput>
</cfloop>
