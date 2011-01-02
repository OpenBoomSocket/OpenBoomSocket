<cftransaction>
	<cftry>
		<!--- create table list to check for test records --->
		<cfif isDefined('URL.tableid') and isNumeric(URL.tableid)>
			<cfset idList = valuelist(URL.tableid)>
		<cfelse>
			<!--- get all custom tools --->
			<cfquery name="q_tableList" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT formobjectid
				FROM formobject
				WHERE formobjectid > 100000
			</cfquery>
			<cfset idList = valuelist(q_tableList.formobjectid)>
			<!--- append targeted core tools --->
			<!--- 109:contentelement, 138:guest, 139:guestaddress, 140:guestemail --->
			<cfset coreList = "109, 138, 139, 140">
			<cfset idList = listAppend(idList, coreList)>
			<cfdump var="removing from tables: #idList#">
		</cfif>
		<!--- loop over the list--->
		<cfquery name="q_tableData" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT formobjectid, label, datatable, useWorkFlow
			FROM formobject
			WHERE formobjectid IN (#idList#)
		</cfquery>
		<cfloop query="q_tableData">
			<cfset deleteString = "DELETE FROM #q_tableData.datatable# WHERE #datatable#name LIKE '%[Test Data]%'">
			<cfdump var="#preservesinglequotes(deleteString)#">
			<!--- remove test records --->
			<!--- <cfquery name="q_deleteRecords" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				#preservesinglequotes(deleteString)#
			</cfquery> --->
			<cfif isNumeric(q_tableData.useWorkFlow) AND (q_tableData.useWorkFlow EQ 1)>
				<cfset deleteString = "DELETE FROM version WHERE label LIKE '%[Test Data]%'">
				<cfdump var="#preservesinglequotes(deleteString)#">
				<!--- if versioning, remove versioned items --->
				<!--- <cfquery name="q_deleteVerionRecords" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					#preservesinglequotes(deleteString)#
				</cfquery> --->
			</cfif>
		</cfloop>
		<!--- if possible update tableID records --->
		<cfcatch type="any">
			<cfrethrow>
		</cfcatch>
	</cftry>
</cftransaction>