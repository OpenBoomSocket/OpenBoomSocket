<cfset socketList = "">
<cfloop from="1" to="#arrayLen(SESSION.user.tools)#" index="i">
	<cfif SESSION.user.tools[i][1] GTE 100000>
		<cfset socketList = listAppend(socketList,SESSION.user.tools[i][1])>
	</cfif>
</cfloop>
<!--- Added 30 Jan 2008, Darrin Kay.  To fix if the socketList array has nothing in it --->
<cfif len(socketList) LT 1>
	<cfset socketList = "0">
</cfif>
<cfquery datasource="#APPLICATION.datasource#" name="q_getSockets" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT formobjectid, formobjectname, description, useworkflow
	FROM formobject
	WHERE formobjectid IN (#socketList#) AND isNull(showInDigest,0) = 1
	ORDER BY formobjectname ASC
</cfquery>
<div id="dashboardPageShell">
	<cfoutput>
		<div id="dashboardPageLeft">
		    <h1>Sockets</h1>
    <div id="dashboardIntroText">Below you will find shortcuts to access some of the tools you commonly use to manage the <em>Data Driven Display</em> content on your web site. All of these "sockets" are also available in the navigation menu above.</div>
			<div id="socketLauncherContainer">
				<cfloop query="q_getSockets">
					<div class="socketLauncherPod">
						<h3>#q_getSockets.formobjectname#</h3>
						<div class="socketDescription">#q_getSockets.description#</div>
						<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(q_getSockets.formobjectid,true,true,q_getSockets.formobjectname)#</div>
					</div>
				</cfloop><div style="clear:both"></div>
			</div>
		</div>
	</cfoutput>
	<div id="dashboardPageRight">
		<cfinclude template="#APPLICATION.globalPath#/admintools/includes/widgets/i_userinfo.cfm">
		<cfinclude template="#APPLICATION.globalPath#/admintools/includes/widgets/i_tip.cfm">
		<cfinclude template="#APPLICATION.globalPath#/admintools/includes/widgets/i_faq.cfm">
		<cfinclude template="#APPLICATION.globalPath#/admintools/includes/widgets/i_recentItems.cfm">
	</div><div style="clear:both"></div>
</div>