<!--- Query for this formobjectid --->
<cfquery datasource="#application.datasource#" name="q_getform" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT  *
	FROM   formobject INNER JOIN formEnvironment ON formobject.formEnvironmentID = formEnvironment.formEnvironmentID
	WHERE  (formobject.formobjectid = #trim(formobjectid)#)
</cfquery>
<cfset request.q_getform=q_getform>