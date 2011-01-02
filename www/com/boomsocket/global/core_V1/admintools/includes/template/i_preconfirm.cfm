<!--- i_preconfirm.cfm --->
<cfif isDefined("deleteinstance")>
	<cfquery name="q_getAllAffectedPages" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT pagename, sitesectionid
		FROM page
		WHERE templateid = #deleteinstance#
	</cfquery>
	<cfif q_getAllAffectedPages.recordcount>
		<cfoutput>
			<table width="550" border="0" cellspacing="1" cellpadding="4">
				<tr>
					<td class="toolheader" colspan="2">Confirm Delete</td>
				</tr>
				<tr>
					<td class="formitemlabel" colspan="2">
				<p>Are you sure you wish to delete this template?  The following pages are dependent on this template and will not display properly without it:</p>
			<ul>
				<cfloop query="q_getAllAffectedPages">
		<li>/#application.getSectionPath(q_getAllAffectedPages.sitesectionid,"TRUE")#/#q_getAllAffectedPages.pagename#</li>
				</cfloop>
			</ul>
					</td>
				</tr>
				
					<tr>
						<td align="right">
						<form action="index.cfm" method="Post">
							<input type="hidden" value="showForm" name="formstep">
							<input type="hidden" value="#trim(form.deleteinstance)#" name="instanceid">
							<input type="hidden" value="#trim(form.tablename)#" name="tablename">
							<input type="submit" value="Back to Form" class="submitbutton" style="width:120px;">
						</form>
						</td>
						<td><form action="#request.page#" method="post" name="delete">
				<input type="Hidden" name="formstep" value="commit">
				<input type="Hidden" name="tablename" value="#trim(form.tablename)#">
				<input type="Hidden" name="deleteinstance" value="#trim(form.deleteinstance)#"><input type="Submit" class="submitbutton" value="Yes, delete now"></form></td>
						
					</tr>
				
			</table>
		</cfoutput>
	<cfset request.stopprocess="confirm">
	</cfif>
</cfif>