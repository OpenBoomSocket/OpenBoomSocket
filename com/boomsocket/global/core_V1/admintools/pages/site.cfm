<cfquery datasource="#APPLICATION.datasource#" name="q_getSockets" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT formobjectid, formobjectname, description, useworkflow
	FROM formobject
	WHERE formobjectid IN (#APPLICATION.tool.sitesection#,#APPLICATION.tool.page#,#APPLICATION.tool.pagecomponentwizard#,#APPLICATION.tool.navmanager#) AND isNull(showInDigest,0) = 1
	ORDER BY formobjectid ASC
</cfquery>

<div id="dashboardPageShell">
	<cfoutput>
		<div id="dashboardPageLeft">
		    <h1>Site</h1>
    		<div id="dashboardIntroText">Below you will find shortcuts to access the tools you use most commonly to manage the architecture of your web site. </div>
			<div id="socketLauncherContainer">
				<cfloop query="q_getSockets">
					<cfif q_getSockets.formobjectid EQ APPLICATION.tool.sitesection>
						<div class="socketLauncherPod">
							<h3>Section Management</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.sitesection,true,true,'Section')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.page>
						<div class="socketLauncherPod">
							<h3>Page Management</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.page,true,true,'Page')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.pagecomponentwizard>
						<div class="socketLauncherPod">
							<h3>Page Layout Wizard</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.pagecomponentwizard,false,true,'Page Layout')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.navmanager>
						<div class="socketLauncherPod">
							<h3>Navigation Management</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.navmanager,false,true,'Navigation')#</div>
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
