<cftransaction>
	<cftry>
		<!--- create table list to check for test records --->
		<cfif isDefined('URL.tableid') and isNumeric(URL.tableid)>
			<cfset idList = URL.tableid>
		<cfelse>
			<!--- get all custom tools --->
			<cfquery name="q_tableList" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT formobjectid
				FROM formobject
				WHERE formobjectid > 100000 
			</cfquery>
			<cfset idList = valuelist(q_tableList.formobjectid)>
			<!--- append targeted core tools --->
			<!--- 109:contentelement, 138:guest, 139:guestaddress, 140:guestemail --->
			<cfset coreList = "109, 138, 139, 140, 141">
			<cfset idList = listAppend(idList, coreList)>
			<cfdump var="removing from tables: #idList#" ><br/>
		</cfif>
		<!--- loop over the list--->
		<cfquery name="q_tableData" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT formobjectid, label, datatable, useWorkFlow
			FROM formobject
			WHERE (formobjectid IN (#idList#)) AND (datatable <> '')
		</cfquery>
		<cfloop query="q_tableData">
			<cfset deleteString = "DELETE FROM #q_tableData.datatable# WHERE #datatable#name LIKE '%{Test Data}%'">
			<cfdump var="#q_tableData.currentrow#: #preservesinglequotes(deleteString)##chr(13)##chr(10)#"><br/>
			<!--- remove test records --->
			<cfif isDefined('URL.doitnow') and isNumeric(URL.doitnow) AND URL.doitnow>
				<cfquery name="q_deleteRecords" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					#preservesinglequotes(deleteString)#
				</cfquery>
			</cfif>
			<cfif isNumeric(q_tableData.useWorkFlow) AND (q_tableData.useWorkFlow EQ 1)>
				<cfset deleteString = "DELETE FROM version WHERE (label LIKE '%{Test Data}%') AND (formobjectitemid = #q_tableData.formobjectid#)">
				<cfdump var="    Version #preservesinglequotes(deleteString)##chr(13)##chr(10)#"><br/>
				<!--- if versioning, remove versioned items --->
				<cfif isDefined('URL.doitnow') and isNumeric(URL.doitnow) AND URL.doitnow>
					<cfquery name="q_deleteVerionRecords" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						#preservesinglequotes(deleteString)#
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
		<!--- if possible update tableID records --->
		<cfcatch type="any">
			<cfrethrow>
		</cfcatch>
	</cftry>
</cftransaction>