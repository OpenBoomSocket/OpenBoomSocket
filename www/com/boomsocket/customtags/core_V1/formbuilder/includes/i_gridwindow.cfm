<cfquery datasource="#application.datasource#" name="q_tableDef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT *
	FROM formobject
	WHERE formobjectid = #url.formobjectid#
</cfquery>
<cfoutput>
	<table border="1" cellpadding="0" cellspacing="0" bordercolor="##000000" bgcolor="##FFFFFF">
		<tr>
			<!--- add top row to show col position --->
			<td><img src="/admintools/media/images/spacer.gif" border="0" height="35" width="35"></td>
			<cfloop index="c" from="1" to="#q_tableDef.tablecolumns#"><td align="center" valign="middle">#c#</td></cfloop>
		</tr>
		<cfloop index="r" from="1" to="#q_tableDef.tablerows#">
		<tr>
			<td align="center" valign="middle">#r#</td>
			<cfloop index="c" from="1" to="#q_tableDef.tablecolumns#">
				<td <cfif c MOD 2>bgcolor="##dadada"<cfelse>bgcolor="##333333"</cfif>><a href="##" onClick="parent.opener.document.fieldform.#inputfield#.value='#r#,#c#';top.window.close();" title="Row #r#, Column #c#" style="cursor:pointer;"><img src="/admintools/media/images/spacer.gif" border="0" height="35" width="35" alt="Row #r#, Column #c#"></a></td>
			</cfloop>
		</tr>
		</cfloop>
	</table>
</cfoutput>