<!--- i_preshowform.cfm --->
<cfquery name="request.q_customQuery_usertypeid" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#"> 
	SELECT usertypeid AS lookupkey, usertypename AS lookupdisplay
	FROM usertype
	<cfif session.user.accessLevel NEQ 1>WHERE roleid > #session.user.accessLevel#</cfif>
</cfquery>

<cfif isDefined("instanceid")>
	<cfquery name="q_getSections" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT sitesectionid
		FROM Users_Sections
		WHERE userid = #instanceid#
	</cfquery>
	<cfset form.sitesectionid = valueList(q_getSections.sitesectionid)>
<cfelse>
	<cfif NOT IsDefined('form.sitesectionid')>
		<cfset form.sitesectionid = "">	
	</cfif>
</cfif>
	
<cfif isDefined("usertypeid") AND len(usertypeid)>
	<cfquery name="q_getMoreSections" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT sitesectionid
		FROM Usertypes_Sections
		WHERE usertypeid = #listFirst(usertypeid,"~")#
	</cfquery>
	<cfset form.sitesectionid = listAppend(form.sitesectionid,valueList(q_getMoreSections.sitesectionid))>
</cfif>

<cfoutput>
<cfparam name="newQueryString" default="formstep=#formstep#">
<script language="JavaScript">
	function filterSections(usertypeid){
		document.#q_getform.formname#.formstep.value="showForm";
		document.#q_getform.formname#.submit();
	}
</script>
</cfoutput>