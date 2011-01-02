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
					SELECT contentobjectid 
					FROM pagecomponent 
					WHERE pageid = #thisPage# AND containerid = #form.containerid#
				</cfquery>
				<cfif q_testPage.recordCount EQ 0>
					<cfmodule template="#application.customTagPath#/assignID.cfm" 
					          tablename="pagecomponent" 
							  datasource="#application.datasource#"
							  returnvar="nextID">
					<cfquery name="q_InsertPage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
						INSERT INTO pagecomponent(pagecomponentid,displayhandlerid,contentobjectid,pageid,containerid)
						VALUES (#nextID# + 1,#application.contentObjectDH#,#form.newContent#,#thisPage#,#form.containerid#)
					</cfquery>
				<cfelse>
					<cfquery name="q_UpdatePage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
						UPDATE pagecomponent 
						SET displayhandlerid = #application.contentObjectDH#, contentobjectid = #form.newContent# 
						WHERE pageid = #thisPage# AND containerid = #form.containerid#
					</cfquery>
				</cfif>
			</cfloop>
	</cfcase>
	<cfcase value="showForm">
		<cfquery name="q_getFilledContainers" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT pagecomponent.contentobjectid, container.identifier
			FROM pagecomponent INNER JOIN container ON pagecomponent.containerid = container.containerid
			WHERE pagecomponent.pageid = #url.editpageid# AND pagecomponent.containerid = #url.containerid#
		</cfquery>
		<cfquery name="q_getCurrentTemplate" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT templateid 
			FROM page 
			WHERE pageid = #url.editpageid#
		</cfquery>
		<cfquery name="q_getAllContent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT contentobject.contentobjectname, contentobject.contentobjectid, VersionStatus.status, VersionStatus.colorcode
			FROM contentobject 
				INNER JOIN version ON contentobject.contentobjectid = version.instanceItemID AND version.formobjectitemid = #application.tool.contentobject#
				INNER JOIN VersionStatus ON version.versionStatusID = VersionStatus.versionstatusid
			WHERE (version.archive IS NULL OR version.archive = 0)
			ORDER BY VersionStatus.status, contentobject.contentobjectname
		</cfquery>
		<cfquery name="q_getAllPages" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT sitesection.sitesectionID, page.pagename AS lookupkeydisplay, page.pageid AS lookupkeyvalue
			FROM page INNER JOIN sitesection ON page.sitesectionid = sitesection.sitesectionid 
			ORDER BY sitesection.sitesectionname ASC, page.pagename ASC
		</cfquery>
		<cfmodule template="#application.customTagPath#/htmlshell.cfm" 
	          css="admintools.css" 
			  bgcolor="E6E6E6" 
			  padding="0">
		<cfoutput>  
			<script language="javascript">
				function previewContent(){
					thisContentID=document.contentSelect.newContent.value;
					if(thisContentID != ''){
						window.location.href="#request.page#?pagefunction=previewContent&contentobjectid="+thisContentID;
					} else {
						alert('You must select a content item to preview.');
					}
				}
			</script>
		</cfoutput>
				<table width="100%" border="0" cellspacing="1" cellpadding="3">
				<cfoutput>
					<tr>
						<td class="toolheader" colspan="3">Container: #q_getFilledContainers.identifier#</td>
					</tr>
					<tr>
						<td class="subtoolheader" colspan="2">Select a Content Element:</td>
						<td class="subtoolheader" align="right">Assign to Page(s):&nbsp;</td>
					</tr>
					<tr>
						<td colspan="3" valign="top">
							<form action="/admintools/index.cfm" method="post" style="margin-bottom: 0px; margin-left: 0px; margin-right: 0px; margin-top: 0px; page-break-before: avoid; page-break-after: avoid;">
								<input type="hidden" name="formstep" value="showform">
								<input type="hidden" name="displayForm" value="1">		
								<input type="hidden" name="i3currenttool" value="#application.tool.contentobject#">		
								<input type="Hidden" name="containerid" value="#url.containerid#">	
								<input type="Hidden" name="pageid" value="#url.editpageid#">
								<input type="image" value="Add a New Content Element" src="#application.globalPath#/media/images/icon_addFile.gif" alt="Add new Content Element">&nbsp;
							</form>
						</td>
					</tr>
				<form action="#CGI.script_name#" method="post" name="contentSelect">
				<input type="Hidden" name="containerid" value="#url.containerid#">
				<input type="Hidden" name="templateid" value="#q_getCurrentTemplate.templateid#">
				<input type="Hidden" name="pageFunction" value="postAssignment">
				</cfoutput>
					<tr>
						<td valign="top">
							<select name="newContent">
								<option value="">Select a Content Element
								<cfoutput query="q_getAllContent" group="status">
									<option style="background-color: #q_getAllContent.colorcode#; color:##ffffff;">#q_getAllContent.status#:</option>
									<cfoutput>
										<option value="#q_getAllContent.contentObjectid#"<cfif (q_getFilledContainers.contentObjectid EQ q_getAllContent.contentObjectid) AND (q_getFilledContainers.contentObjectid NEQ 100000)> SELECTED</cfif>>&nbsp;&nbsp;&nbsp;#left(q_getAllContent.contentobjectname,80)#
									</cfoutput>
								</cfoutput>
							</select>
							
						</td>
						<td>&nbsp;</td>
						<td valign="top" align="center">
						<cfoutput>
						<select name="editpageid" multiple size="5">
							<option value="all">Assign to all pages
							<cfloop query="q_getAllPages">
								<option value="#q_getAllPages.lookupkeyValue#"<cfif q_getAllPages.lookupkeyValue EQ url.editpageid> SELECTED</cfif>>#application.getSectionPath(q_getAllPages.sitesectionID,true,'/')#/#q_getAllPages.lookupkeydisplay#
							</cfloop>
						</select>
						<p><input type="Submit" value="Make Assignment" class="submitbutton" style="width:140px;margin-bottom:5px;"><br>
							<input type="Button" value="Preview Content" class="submitbutton" onclick="previewContent();" style="width:140px;">
						</p>
						</cfoutput>
					</td>
					</tr>
				</table>
				</form>
	</cfcase>
	<cfcase value="previewContent">
		<cfquery name="q_showContent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT * 
			FROM contentobject 
			WHERE contentobjectid = #URL.contentobjectid#
		</cfquery>
		<cfoutput>
		<p align="center"><strong>&lt;&lt; <a href="javascript: history.go(-1);">Return to Assignment Wizard</a></strong></p>
			#q_showContent.contentobjectbody#
		</cfoutput>
	</cfcase>
</cfswitch>
