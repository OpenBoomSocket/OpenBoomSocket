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
			complete();
		</script> 
	</cfoutput>
	<!--- If "all" pages selected, query for a list of pages using this template. --->
	<cfif form.editpageid eq "all">
		<!--- grab all pages that use container in question (not just the same template) --->
		<cfquery name="q_getTemplatesWithContainer" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT templateid
			FROM container 
			WHERE containerid = #Trim(FORM.containerid)#
		</cfquery>	
		<cfquery name="q_getAllPages" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT page.pageid
			FROM page
			<cfif q_getTemplatesWithContainer.recordcount>
				WHERE page.templateid IN (#ValueList(q_getTemplatesWithContainer.templateid)#)
			</cfif>
		</cfquery>
		<cfset form.editpageid = valueList(q_getAllPages.pageid)>
	</cfif>
	<!--- Loop over pageid values and update/insert components accordingly --->
		<cfloop list="#form.editpageid#" index="thisPage">
			<cfquery name="q_testPage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT displayhandlerid FROM pagecomponent WHERE pageid = #thisPage# AND containerid = #form.containerid#
			</cfquery>
			<cfif q_testPage.recordCount EQ 0>
				<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="pagecomponent" datasource="#application.datasource#" returnvar="newComponentID">
				<cfquery name="q_InsertPage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO pagecomponent(pagecomponentid,displayhandlerid,contentobjectid,pageid,containerid)
					VALUES (#newComponentID#,#form.newDH#,NULL,#thisPage#,#form.containerid#)
				</cfquery>
			<cfelse>
				<cfquery name="q_UpdatePage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE pagecomponent 
					SET displayhandlerid = #form.newDH# , contentobjectid = NULL 
					WHERE pageid = #thisPage# AND containerid = #form.containerid#
				</cfquery>
			</cfif>
		</cfloop>
</cfcase>
<cfcase value="showForm">
	<cfquery name="q_getThisContainer" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#"><!--- filled or unfilled --->
			SELECT container.identifier
			FROM container 
			WHERE containerid = #url.containerid#
		</cfquery>
	<cfquery name="q_getFilledContainers" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT pagecomponent.displayhandlerid, container.identifier
		FROM pagecomponent INNER JOIN container ON pagecomponent.containerid = container.containerid
		WHERE pagecomponent.pageid = #url.editpageid# AND pagecomponent.containerid = #url.containerid# AND pagecomponent.displayhandlerid != #application.contentobjectdh#
	</cfquery>
	<cfquery name="q_getCurrentTemplate" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT templateid, pagetitle 
		FROM page 
		WHERE pageid = #url.editpageid#
	</cfquery>
	<cfquery name="q_getAllDH" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT displayhandlername, displayhandlerid 
		FROM displayhandler 
		WHERE displayhandlerid <> #application.contentobjectdh#
		ORDER BY displayhandlername ASC
	</cfquery>
	<!--- only pull pages w/ same container for dropdown - get all templates that have this container--->
	<cfquery name="q_getTemplatesWithContainer" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT templateid 
		FROM container 
		WHERE containerid = #trim(url.containerid)#
	</cfquery>
	<cfquery name="q_getAllPages" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT sitesection.sitesectionID, page.pagename AS lookupkeydisplay, page.pageid AS lookupkeyvalue
		FROM page INNER JOIN sitesection ON page.sitesectionid = sitesection.sitesectionid 
		<!--- only pull pages w/ same container for dropdown --->
		<cfif q_getTemplatesWithContainer.recordcount>
			WHERE page.templateid IN (#ValueList(q_getTemplatesWithContainer.templateid)#)
		</cfif> 
		ORDER BY sitesection.sitesectionname ASC, page.pagename ASC
	</cfquery>
		<cfmodule template="#application.customTagPath#/adminskin.cfm" admintemplate="popup" css="" headertext="#q_getCurrentTemplate.pagetitle# :: #q_getThisContainer.identifier#">
		<cfoutput>
			<table width="100%" border="0" cellspacing="1" cellpadding="3">
				<!--- <tr>
					<td class="toolheader" colspan="3">Container: #q_getFilledContainers.identifier#</td>
				</tr> --->
				<tr>
					<td class="subtoolheader">
						<cfif application.getPermissions("addedit",application.tool.displayhandler)>
								<form action="/admintools/index.cfm" method="post" style="float:left; margin-bottom: 0px; margin-left: 0px; margin-right: 0px; margin-top: 0px; page-break-before: avoid; page-break-after: avoid;">
									<input type="hidden" name="formstep" value="showform">
									<input type="hidden" name="displayForm" value="1">		
									<input type="hidden" name="i3currenttool" value="#application.tool.displayhandler#">		
									<input type="Hidden" name="containerid" value="#url.containerid#">	
									<input type="Hidden" name="pageid" value="#url.editpageid#">
									<input type="Hidden" name="admintemplate" value="popup">
									<input type="image" value="Add a New Data Driven Display" src="#application.globalPath#/media/images/icon_addFile.gif" alt="Add a New Data Driven Display">&nbsp;
								</form>
						<cfelse>
							&nbsp;	
						</cfif>
					Select a Data Driven Display</td>
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
										<tr>
					<td class="subtoolheader">Assign to Page(s):&nbsp;</td>
				</tr>
				<tr>
					<td>
						<select name="editpageid" multiple size="5">
							<option value="all">Assign to all pages
							<cfloop query="q_getAllPages">
								<option value="#q_getAllPages.lookupkeyValue#"<cfif q_getAllPages.lookupkeyValue EQ url.editpageid> SELECTED</cfif>>#APPLICATION.getSectionPath(q_getAllPages.sitesectionID,true,'/')#/#q_getAllPages.lookupkeydisplay#
							</cfloop>
						</select>
						<p style="text-align:center"><input type="Submit" value="Make Assignment" class="submitbutton" style="width:140;"></p>
					</td>
					
				</tr>
			</form>
			</table>			
			</cfoutput>
			</cfmodule>
</cfcase>
</cfswitch>
