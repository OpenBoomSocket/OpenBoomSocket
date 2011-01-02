<!--- i_postcommit.cfm --->
<!--- inserting or updating --->
<cfif NOT isDefined("deleteinstance")>
	<cfif isDefined("instanceid")>
		<cfset thisid=instanceid>
	<cfelse>
		<cfset thisid=insertid>
	</cfif>
	<!--- set name = firstname + lastname --->
	<cfset thisname = form.firstname>
	<cfif isDefined('form.middleinit') AND Len(Trim(form.middleinit))>
		<cfset thisname = thisname & ' ' & form.middleinit & '.'>
	</cfif>
	<cfset thisname = thisname & ' ' & form.lastname>
	<cfquery name="q_updateContact" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		UPDATE guestcontact
		SET guestcontactname = '#thisname#' 
		WHERE guestcontactid = #thisid#
	</cfquery>
</cfif>


