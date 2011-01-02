<!--- i_preconfirm.cfm --->

<cfif isDefined("instanceid") OR isDefined("deleteinstance")>
<cfif isDefined("instanceid")>
	<cfset thisID=instanceid>
<cfelse>
	<cfset thisID=deleteinstance>
</cfif>


<cfif listLen(thisID)>

	<cfset dirPath="">
	<cfloop list="#thisID#" index="X">
		<!--- get orignal pagename --->
		<cfquery name="q_getOldname" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT pagename FROM page WHERE pageid='#X#'
		</cfquery>
		<cfquery datasource="#application.datasource#" name="q_getsectioninfo" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT sitesectionid, templateid
			FROM page
			WHERE pageid = #X#
		</cfquery>
		<cfset sitesectionid=q_getsectioninfo.sitesectionid>
		<cfset oldtemplateid=q_getsectioninfo.templateid>
		
		<!--- Create directory path for old section --->
		<cfset tmp="#application.installpath##application.slash##application.getSectionPath(sitesectionid,"true")##application.slash##q_getOldname.pagename#">
		<cfset dirPath=listAppend(dirPath,tmp)>
	</cfloop>		
	<cfset structInsert(form,"olddirPath","#dirPath#")>
	<cfset structInsert(form,"oldtemplateid","#oldtemplateid#")>
	
<cfelse>

	<!--- get orignal pagename --->
	<cfquery name="q_getOldname" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT pagename FROM page WHERE pageid='#thisID#'
	</cfquery>
	<cfquery datasource="#application.datasource#" name="q_getsectioninfo" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT sitesectionid
		FROM page
		WHERE pageid = #thisID#
	</cfquery>
	<cfset sitesectionid=q_getsectioninfo.sitesectionid>
	
	<!--- Create directory path for old section --->
		<cfset dirPath="#application.installpath##application.slash##application.getSectionPath(sitesectionid,"true")#">
		<cfset structInsert(form,"olddirPath","#dirPath##application.slash##q_getOldname.pagename#")>
	</cfif>

</cfif>