<cfquery datasource="#APPLICATION.datasource#" name="q_getSockets" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT formobjectid, formobjectname, description, useworkflow
	FROM formobject
	WHERE formobjectid IN (#APPLICATION.tool.meta#,#APPLICATION.tool.filemanager#,#APPLICATION.tool.contentobject#,#APPLICATION.tool.version#) AND isNull(showInDigest,0) = 1
	ORDER BY formobjectid ASC
</cfquery>

<div id="dashboardPageShell">
	<cfoutput>
		<div id="dashboardPageLeft">
		    <h1>Content</h1>
    		<div id="dashboardIntroText">Below you will find shortcuts to access the tools for managing the content in your web site.  </div>
			<div id="socketLauncherContainer">
				<cfloop query="q_getSockets">
					<cfif q_getSockets.formobjectid EQ APPLICATION.tool.filemanager>
						<div class="socketLauncherPod">
							<h3>File Manager</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.filemanager,true,true,'File')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.meta>
						<div class="socketLauncherPod">
							<h3>Meta Data Tag</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.meta,true,true,'Meta Data Tag')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.version>
						<div class="socketLauncherPod">
							<h3>Content Review Queue</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.version,false,true,'Version')#</div>
						</div>
					<cfelseif q_getSockets.formobjectid EQ APPLICATION.tool.contentobject>
						<div class="socketLauncherPod">
							<h3>Content Elements</h3>
							<div class="socketDescription">#q_getSockets.description#</div>
							<div class="socketLauncherButtonBar">#APPLICATION.makeSocketLaunchBar(APPLICATION.tool.contentobject,true,true,'Content Element')#</div>
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
