<!--- i_preshowform.cfm --->
<cfif NOT isDefined("deleteinstance")>
	<cfquery name="q_stuff" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT     version.*, VersionStatus.status AS VersionStatus, formobject.label AS FormObjectLabel, UsersOwners.lastName AS ownerLastName, 
                      UsersOwners.firstName AS ownerFirstName, UsersSupervisors.lastName AS supervisorLastName, 
                      UsersSupervisors.firstName AS supervisorFirstName
		FROM         version INNER JOIN
                      VersionStatus ON version.versionStatusID = VersionStatus.versionstatusid INNER JOIN
                      Users UsersOwners ON UsersOwners.Usersid = version.ownerid INNER JOIN
                      Users UsersSupervisors ON UsersSupervisors.Usersid = version.supervisorid INNER JOIN
                      formobject ON formobject.formobjectid = version.formobjectitemid
		ORDER BY version.datemodified, VersionStatus.status
	</cfquery>
</cfif>

<cfdump var="#q_stuff#">
<table cellpadding="3" cellspacing="2" border="0">
<tr>
	<th>Name</th>
	<th>Object Type</th>
	<td>Version</td>
	<th>Owner</th>
	<th>Supervisor</th>
	<th>Status</th>
</tr>
</table>
<cfoutput query="q_stuff">
	<tr>
		<Td>???</Td>
		<td>#q_stuff.FormObjectLabel#</td>
		<td>#q_stuff.version#</td>
		<td>#q_stuff.ownerFirstName# #q_stuff.ownerLastName#</td>
		<td>#q_stuff.supervisorFirstName# #q_stuff.supervisorLastName#</td>
		<td>#q_stuff.verstionstatus#</td>
	</tr>
</cfoutput>
