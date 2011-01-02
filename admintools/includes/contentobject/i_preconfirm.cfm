<!--- i_preconfirm.cfm --->
<cfif isDefined("form.contentid")>
	<!--- query for content object info and set form vars to show confirm page --->
	<cfquery datasource="#application.datasource#" name="q_getContentObject" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT  contentobject.*, displayhandler.displayhandlername
		FROM  contentobject INNER JOIN displayhandler ON contentobject.displayhandlerid = displayhandler.displayhandlerid
		WHERE contentobject.contentobjectid = #listFirst(form.contentid,"~")#
	</cfquery>
	<cfloop list="#q_getContentObject.columnlist#" index="fieldname">
		<cfset "form.#fieldname#"=evaluate("q_getContentObject.#fieldname#")>
	</cfloop>
	<cfset form.displayhandlerid="#q_getContentObject.displayhandlerid#~#q_getContentObject.displayhandlername#">
</cfif>
