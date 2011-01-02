<cfquery datasource="#APPLICATION.datasource#" name="q_getSockets" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT formobjectid, formobjectname, description, useworkflow
	FROM formobject
	WHERE formobjectid IN (#APPLICATION.tool.template#,#APPLICATION.tool.toolbuilder#,#APPLICATION.tool.formbuilder#,#APPLICATION.tool.displayhandler#,#APPLICATION.tool.javascript#,#APPLICATION.tool.socket#,#APPLICATION.tool.formEnvironment#) AND isNull(showInDigest,0) = 1
	ORDER BY formobjectid ASC
</cfquery>

<div id="dashboardPageShell">
	<cfoutput>
		<div id="dashboardPageLeft">
		    <h1>Developer</h1>
    		<div id="dashboardIntroText">Below you will find shortcuts to the tools that allow you to do all of the "back-end" work on your website, from building new tools to setting up your first data driven displays.  </div>
			<div id="socketLauncherContainer">
				<cfloop query="q_getSockets">
					<cfif q_getSockets.formobjectid EQ APPLICATION.tool.toolbuilder>
						<div class="socketLauncherPod">
							<h3>Socket Tool Builder</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.toolbuilder,true,true,'Socket Tool')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.formbuilder>
						<div class="socketLauncherPod">
							<h3>Form Builder</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.formbuilder,true,true,'Form')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.displayhandler>
						<div class="socketLauncherPod">
							<h3>Manage Data Driven Displays</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.displayhandler,true,true,'Data Driven Display')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.formEnvironment>
						<div class="socketLauncherPod">
							<h3>Socket Shell Types</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.formEnvironment,true,true,'Socket Shell Type')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.template>
						<div class="socketLauncherPod">
							<h3>Manage HTML Templates</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.template,true,true,'Template')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.javascript>
						<div class="socketLauncherPod">
							<h3>Manage JavaScript</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.javascript,true,true,'JavaScript')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.socket>
						<div class="socketLauncherPod">
							<h3>Socket Library</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.socket,true,true,'Socket')#</div>
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


