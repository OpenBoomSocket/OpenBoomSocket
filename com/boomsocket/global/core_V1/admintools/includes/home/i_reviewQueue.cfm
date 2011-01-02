
<cfquery name="q_reviewQueueObjects" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT     version.*, VersionStatus.status AS VersionStatus, VersionStatus.colorcode, formobject.label AS FormObjectLabel, 
				UsersOwners.lastName AS ownerLastName, UsersOwners.firstName AS ownerFirstName, UsersOwners.initials AS ownerInitials,
				UsersSupervisors.lastName AS supervisorLastName, UsersSupervisors.firstName AS supervisorFirstName, UsersSupervisors.initials AS supervisorInitials,
				UsersCreators.firstName as creatorFirstName, UsersCreators.lastName as creatorLastName, UsersCreators.initials as creatorInitials
	FROM         version INNER JOIN
				  VersionStatus ON version.versionStatusID = VersionStatus.versionstatusid INNER JOIN
				  Users UsersOwners ON UsersOwners.Usersid = version.ownerid INNER JOIN
				  Users UsersSupervisors ON UsersSupervisors.Usersid = version.supervisorid INNER JOIN
				  Users UsersCreators ON UsersCreators.usersid = version.creatorid INNER JOIN
				  formobject ON formobject.formobjectid = version.formobjectitemid
	WHERE 		(version.supervisorid = #session.user.id# OR version.ownerid = #session.user.id# OR version.creatorid = #session.user.id#)
	ORDER BY FormObjectLabel ASC
</cfquery>
<cfquery name="q_Status" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT * FROM versionstatus
	ORDER BY ordinal ASC
</cfquery>
<!-- open output table -->
<h2>Review Queue</h2>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<cfoutput>
	<tr bgcolor="##cccccc">
		<td>&nbsp;&nbsp;</td>
		<cfloop query="q_Status">
			<td style="color: white; background-color: #q_Status.colorcode#; font-weight:bold;">&nbsp;#q_Status.status#&nbsp;</td>
		</cfloop>
	</tr>
	</cfoutput>
		<cfoutput query="q_reviewQueueObjects" group="FormObjectLabel">
			<cfset thisLoopCount=0>
			<cfloop query="q_Status">
				<cfset "count#q_Status.versionStatusID#"=0>
			</cfloop>
			<cfoutput>
				<cfset thisStatusID=q_reviewQueueObjects.versionStatusID>
				<cfset "count#thisStatusID#"=incrementValue(evaluate("count#thisStatusID#"))>
				<cfset thisLoopCount=incrementValue(thisLoopCount)>
			</cfoutput>
			<tr bgcolor="##dadada">
				<td colspan="#evaluate(q_Status.recordcount+1)#"><strong>#q_reviewQueueObjects.FormObjectLabel#</strong>
				&##151;<a href="#request.page#?mode=homeViewByObject&formobject=#q_reviewQueueObjects.formobjectitemid#&i3currentTool=#application.tool.version#">There <cfif thisLoopCount LT 2>is<cfelse>are</cfif> #thisLoopCount# Item<cfif thisLoopCount GT 1>s</cfif> to review</a>
				</td>
			</tr>
			<tr bgcolor="##dadada">
				<td><a href="#request.page#?mode=homeViewByObject&formobject=#q_reviewQueueObjects.formobjectitemid#&i3currentTool=#application.tool.version#">&lt;View&gt;</a></td>
				<cfloop query="q_Status">
					<td align="center" bgcolor="##999999"><strong>#evaluate("count#q_Status.versionStatusID#")#</strong></td>
				</cfloop>
			</tr>
		</cfoutput>
	</table>
<!-- close output table -->
