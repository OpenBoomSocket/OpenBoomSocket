<cfparam name="pageFunction" default="showForm">
<cfswitch expression="#pageFunction#">
	<cfcase value="postAssignment">
				<!--- Kill App Scope Variable include here --->
				<!--- Kill App Scope Variable include here --->
				<cfinclude template="#application.globalPath#/appScopeKiller.cfm">
				<!--- Kill App Scope Variable include here --->
				<!--- Kill App Scope Variable include here --->
	<cfoutput>
		<script language="JavaScript">
			function complete(){
				window.opener.location.reload();
				self.close();
			}
		</script> 
	</cfoutput>
	<!--- If "all" pages selected, query for a list of pages using this template. --->
	<cfif form.editpageid eq "all">
		<cfquery name="q_getAllPages" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT page.pageid
			FROM page
			WHERE page.templateid = #form.templateid#
		</cfquery>
		<cfset form.editpageid = valueList(q_getAllPages.pageid)>
	</cfif>
	<!--- Loop over pageid values and update/insert components accordingly --->
		<cfloop list="#form.editpageid#" index="thisPage">
			<cfquery name="q_testPage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT displayhandlerid FROM pagecomponent WHERE pageid = #thisPage# AND containerid = #form.containerid#
			</cfquery>
			<cfif q_testPage.recordCount EQ 0>
				<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="pagecomponent" datasource="#application.datasource#" returnvar="newComponentID">
				<cfquery name="q_InsertPage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					INSERT INTO pagecomponent(pagecomponentid,displayhandlerid,contentobjectid,pageid,containerid)
					VALUES (#newComponentID#,#form.newDH#,NULL,#thisPage#,#form.containerid#)
				</cfquery>
			<cfelse>
				<cfquery name="q_UpdatePage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					UPDATE pagecomponent 
					SET displayhandlerid = #form.newDH# , contentobjectid = NULL 
					WHERE pageid = #thisPage# AND containerid = #form.containerid#
				</cfquery>
			</cfif>
		</cfloop>
</cfcase>
<cfcase value="showForm">
	<cfquery name="q_getFilledContainers" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT pagecomponent.displayhandlerid, container.identifier
		FROM pagecomponent INNER JOIN container ON pagecomponent.containerid = container.containerid
		WHERE pagecomponent.pageid = #url.editpageid# AND pagecomponent.containerid = #url.containerid# AND pagecomponent.displayhandlerid != #application.contentobjectdh#
	</cfquery>
	<cfquery name="q_getCurrentTemplate" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT templateid 
		FROM page 
		WHERE pageid = #url.editpageid#
	</cfquery>
	<cfquery name="q_getAllDH" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT displayhandlername, displayhandlerid 
		FROM displayhandler 
		WHERE displayhandlerid <> #application.contentobjectdh#
		ORDER BY displayhandlername ASC
	</cfquery>
	<cfquery name="q_getAllPages" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT sitesection.sitesectionID, page.pagename AS lookupkeydisplay, page.pageid AS lookupkeyvalue
		FROM page INNER JOIN sitesection ON page.sitesectionid = sitesection.sitesectionid 
		ORDER BY sitesection.sitesectionname ASC, page.pagename ASC
	</cfquery>
		<cfoutput>
			<table width="100%" border="0" cellspacing="1" cellpadding="3">
				<tr>
					<td class="toolheader" colspan="3">Container: #q_getFilledContainers.identifier#</td>
				</tr>
				<tr>
					<td colspan="2" class="subtoolheader">Select a Data Driven Display</td>
					<td class="subtoolheader" align="right">Assign to Page(s):&nbsp;</td>
				</tr>
					<tr>
						<td colspan="3" valign="top">
						<cfif application.getPermissions("addedit",application.tool.displayhandler)>
							<form action="/admintools/index.cfm" method="post" style="margin-bottom: 0px; margin-left: 0px; margin-right: 0px; margin-top: 0px; page-break-before: avoid; page-break-after: avoid;">
								<input type="hidden" name="formstep" value="showform">
								<input type="hidden" name="displayForm" value="1">		
								<input type="hidden" name="i3currenttool" value="#application.tool.displayhandler#">		
								<input type="Hidden" name="containerid" value="#url.containerid#">	
								<input type="Hidden" name="pageid" value="#url.editpageid#">
								<input type="image" value="Add a New Data Driven Display" src="#application.globalPath#/media/images/icon_addFile.gif" alt="Add a New Data Driven Display">&nbsp;
							</form>
						<cfelse>
						&nbsp;	
						</cfif>
						</td>
					</tr>
			<form action="#CGI.script_name#" method="post">
			<input type="Hidden" name="containerid" value="#url.containerid#">
			<input type="Hidden" name="pageFunction" value="postAssignment">
			<input type="Hidden" name="templateid" value="#q_getCurrentTemplate.templateid#">
				<tr>
					<td valign="top">
						<select name="newDH">
							<cfloop query="q_getAllDH">
								<option value="#q_getAllDH.displayhandlerid#"<cfif q_getFilledContainers.displayhandlerid EQ q_getAllDH.displayhandlerid> SELECTED</cfif>>#left(q_getAllDH.displayhandlername,80)#</option>
							</cfloop>
						</select>
					</td>
					<td>&nbsp;</td>
					<td valign="top" align="center">
						<select name="editpageid" multiple size="5">
							<option value="all">Assign to all pages
							<cfloop query="q_getAllPages">
								<option value="#q_getAllPages.lookupkeyValue#"<cfif q_getAllPages.lookupkeyValue EQ url.editpageid> SELECTED</cfif>>#application.getSectionPath(q_getAllPages.sitesectionID,true,'/')#/#q_getAllPages.lookupkeydisplay#
							</cfloop>
						</select>
						<p><input type="Submit" value="Make Assignment" class="submitbutton" style="width:140;"></p>
					</td>
				</tr>
			</table>
			</form>
			</cfoutput>
</cfcase>
</cfswitch>
