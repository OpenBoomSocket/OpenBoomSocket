<cfset ReviewQueue = createObject("component","#APPLICATION.CFCPath#.reviewQueue")>	
<cfset q_Status = ReviewQueue.getAllStatus()>
<cfset q_RQformobjectid = ReviewQueue.getRQformobjectid()>
<cfoutput>
<!--- Home page grid --->
<table border="0" cellspacing="0" cellpadding="8">
<tr>
	<td valign="top" width="60%">
		<p><cfinclude template="/#application.sitemapping#/admintools/utility/welcomeMessage.cfm">
	</td>
<cfset request.containerTop=1>
<cfset request.containerBottom=1>
	<td valign="top" width="40%">
		<p><cfinclude template="/#application.sitemapping#/admintools/utility/getNews.cfm">
	</td>
</tr>
<cfset request.containerTop=1>
<cfset request.containerBottom=1>
<tr>
	<td valign="top" width="65%"><cfmodule template="#application.customTagPath#/containerShell.cfm" padding="6" width="100%">
	<cfif FileExists('#application.installPath#/admintools/core/version/index.cfm')> 
		 <cfinclude template="/#application.sitemapping#/admintools/core/version/index.cfm"> 
	<cfelse> 
		 <cfinclude template="#application.globalPath#/admintools/core/version/index.cfm"> 
	</cfif></cfmodule>
	</td>
	<td valign="top" width="35%">
		<strong><font size="2" color="##000000">Welcome to the Review Queue!</font></strong>
		<p>From here you can:
		<ul>
			<li>View all unpublished items that you created, own, or supervise</li>
			<li>Edit items <img src="#application.globalPath#/media/images/icon_editVersion.gif" border="0" title="edit" /> (permissions pending)</li>
			<li>Manage versions of this item <img src="#application.globalPath#/media/images/icon_manageVersions.gif" border="0" title="version management" /> (permissions pending)</li>
			<li>View any version of an item by using the version dropdown</li>
			<li>Automatically update the owner or status (permissions pending)</li>
			<li>View <a href="index.cfm?i3currenttool=#q_RQformobjectid.formobjectid#&viewall=yes">everyone's content</a> or switch to the <a href="index.cfm?i3currenttool=#q_RQformobjectid.formobjectid#&viewByStatus=yes">version inventory</a> view</li>
		</ul></p>
		<p>The status color key has not changed:
		<ul>
		<cfloop query="q_Status">
			<li><span style="color:#q_Status.colorcode#">#q_Status.status#</span></li>
		</cfloop>
		</ul></p>

	</td>
</tr>
</table>
</cfoutput>
