<cfset pluginObj = CreateObject('component','#APPLICATION.cfcPath#.util.plugin')>
<cfif NOT isDefined('FORM.formobjectid') AND NOT IsDefined('URL.formobjectID')>
	<cfset q_tableInfo = pluginObj.getTableInfo()>
    <cfif q_tableInfo.RecordCount GTE 1>
		<cfoutput>
        <h1>Choose the sockets from the list below that you would like to extract</h1>
            <form action="#request.page#" method="post">
            <div style="width:30%; float:left;">
                <table>
                <cfloop query="q_tableInfo" endrow="#val(q_tableInfo.recordcount\2)#">
                    <tr><td><input type="checkbox" name="formobjectid" id="formobjectid" value="#q_tableInfo.formobjectid#" />&nbsp;#q_tableInfo.formobjectname#</td></tr>
                </cfloop>
                </table>
            </div>
            <div style="width:30%; float:left;">
                <table>
                <cfloop query="q_tableInfo" startrow="#val(q_tableInfo.recordcount\2+1)#">
                    <tr><td><input type="checkbox" name="formobjectid" id="formobjectid" value="#q_tableInfo.formobjectid#" />&nbsp;#q_tableInfo.formobjectname#</td></tr>
                </cfloop>
                </table>
            </div>
            <div style="clear:both;"/>
            <input type="submit" value="Extract Sockets" />
            </form>
        </cfoutput>
	<cfelse>
    	<cfoutput>
			<h1>No Custom Tools</h1>
            <p>We could not find any custom tools in this installation. Currently the Socket Packager only works for custom tools (tools with an ID higher than 100000). </p>
		</cfoutput>
    </cfif>
<cfelse>
	<cfif IsDefined('FORM.formobjectid') AND IsNumeric(FORM.formobjectid)>
		<cfset thisFormObjectID = FORM.formobjectid>
	<cfelseif IsDefined('URL.formobjectid') AND IsNumeric(URL.formobjectid)>
		<cfset thisFormObjectID = URL.formobjectid>		
	<cfelse>
		<cfset thisFormObjectID = 0>
	</cfif>
	<cfif thisFormObjectID GT 1>
		<cfloop list="#thisFormObjectID#" index="item">
			<cfset q_tableInfo = pluginObj.getTableInfo(formObjectID = item)>
			<cfif q_tableInfo.RecordCount EQ 1>
				<cfoutput>Extracting: "#q_tableInfo.formobjectname#" socket.<br /></cfoutput>
				<cfinvoke component="#APPLICATION.cfcPath#.util.plugin" method="createPluginFromTool" returnvariable="msg">
					<cfinvokeargument name="formobjectid" value="#item#">
				</cfinvoke>
				<cfoutput>&nbsp;Status:&nbsp;<cfif len(trim(msg))>#msg#<br /><br /><cfelse>Successfully Created socket for: "#q_tableInfo.formobjectname#".<br /><br /></cfif></cfoutput>
			<cfelse>
				<cfoutput>No Form Object found with that ID. <a href="#request.page#">Please try again</a></cfoutput>
			</cfif>
		</cfloop>
	<cfelse>
		<cfset StructDelete(form,formObjectID)>
		<cfset StructDelete(URL,formobjectID)>
		<cflocation url="#request.page#" addtoken="no">
	</cfif>
</cfif>