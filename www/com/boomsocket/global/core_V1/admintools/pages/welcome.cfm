<!--- read saved tool list if available, otherwise default to preset list --->
<cfparam name="toollist" default="109,103,102,101,104">
<cfinvoke component="#APPLICATION.cfcpath#.dashboard" method="getToolList" returnvariable="toollist">
	<cfinvokeargument name="userid" value="#SESSION.user.ID#">
</cfinvoke>
<cfif len(trim(toollist)) gt 0>
	<cfset toollist = left(toollist,len(trim(toollist)))>
<cfelse>
	<cfset toollist = "109,103,102,101,104">
</cfif>

<cfoutput>
<div id="dashboardPageShell">
	<div id="dashboardPageLeft">
		<h2>#Application.sitename# Dashboard</h2>
		<p>Welcome to your boomsocket dashboard. Below you will see a series of configurable "pods" that give you one click access into the various types of content on your site. Click the "Configure" button to change  what you see.</p>
		<p>Need Pods or Something Here...</p>
	</div>
	<div id="dashboardPageRight">
		<cfinclude template="#APPLICATION.globalPath#/admintools/includes/widgets/i_userinfo.cfm">
	</div>
	<div style="clear:both"></div>
</div>
</cfoutput>
