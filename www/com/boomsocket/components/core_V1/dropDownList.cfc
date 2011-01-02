<cfcomponent>
	<cffunction name="DropDownList" access="public" returntype="string">
		<cfargument name="lookupTablename" type="string" required="true">
		<cfargument name="selectListFirstOption" type="string" required="true">
		<cfargument name="whereClause" type="string" required="false">
		<cfargument name="resultPath" type="string" required="true">
		<cfset tableid = #lookupTablename# & "id">
		<cfset tableLabel = #lookupTablename# & "name">
		<cfquery datasource="#application.datasource#" name="q_getList" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT #tableid# as ID, #tableLabel# as label
			FROM #lookupTablename# 
			<cfif whereClause NEQ "">
				WHERE #whereClause#
			</cfif>
			ORDER BY #tableLabel#
		</cfquery>
		<cfsavecontent variable="selectList">
		<cfoutput>
			<script>
				function goTo(resultPath, formName, fieldName)
				{
					var id = eval("document." + formName + "." + fieldName + ".value")
					location.href=resultPath + "?id=" + id
				}
			</script>
			<form name="#lookupTablename#">
			<select name="#tableid#" class="selectmenu"  onChange="return goTo('#resultPath#', '#lookupTablename#', '#tableid#');">
			<option value="">#selectListFirstOption#</option>
			<cfloop query="q_getList">
				<option value="#q_getList.ID#">#q_getList.label#</option>
			</cfloop>
			</select>
			</form>
		</cfoutput>
		</cfsavecontent>
		
		<cfreturn selectList>
	</cffunction>
</cfcomponent>