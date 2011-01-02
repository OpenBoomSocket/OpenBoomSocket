<cfquery datasource="#APPLICATION.datasource#" name="q_getSockets" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT formobjectid, formobjectname, description, useworkflow
	FROM formobject
	WHERE formobjectid IN (#APPLICATION.tool.users#,#APPLICATION.tool.usertype#,#APPLICATION.tool.sitesettings#,#APPLICATION.tool.SupervisorRelationship#) AND isNull(showInDigest,0) = 1
	ORDER BY formobjectid ASC
</cfquery>

<div id="dashboardPageShell">
	<cfoutput>
		<div id="dashboardPageLeft">
		    <h1>Admin</h1>
    		<div id="dashboardIntroText">Below you will find shortcuts to access the tools for managing the content in your web site.  </div>
			<div id="socketLauncherContainer">
				<cfloop query="q_getSockets">
					<cfif q_getSockets.formobjectid EQ APPLICATION.tool.users>
						<div class="socketLauncherPod">
							<h3>Manage Users</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.users,true,true,'User')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.SupervisorRelationship>
						<div class="socketLauncherPod">
							<h3>Manage Supervisors</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.SupervisorRelationship,true,true,'Supervisor')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.usertype>
						<div class="socketLauncherPod">
							<h3>Manage User Types</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.usertype,true,true,'User Type')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.sitesettings>
						<div class="socketLauncherPod">
							<h3>Site Settings</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.sitesettings,false,true,'Site Settings')#</div>
						</div>
					</cfif> 
				</cfloop>
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
