<!--- Create page selector form --->
<cfsavecontent variable="pageSelector">
	<cfif isDefined("editpageid")>
		<cfset currentPageID=editpageid>
	<cfelse>
		<cfset currentPageID=0>
	</cfif>
	<cfquery name="q_getPages" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT sitesection.sitesectionID, page.pagename AS lookupkeydisplay, page.pageid AS lookupkeyvalue
		FROM page INNER JOIN sitesection ON page.sitesectionid = sitesection.sitesectionid 
		ORDER BY sitesection.sitesectionname ASC, page.pagename ASC
	</cfquery>
	<cfquery name="q_getPageTitle" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT pagetitle
		FROM page 
		WHERE pageid = #currentPageID#
	</cfquery>
	<cfoutput>
		<div id="socketformheader">
			<h2>Page Layout Wizard</h2> 
		</div>
		<div class="subtoolheader">	
			<form action="#request.page#" method="get" style="margin:0;padding:0;">
				<a href="#REQUEST.page#?formstep=showform&i3CurrentTool=#application.tool.page#&displayForm=1"><img src="#application.globalPath#/media/images/icon_addFile.gif" border="0" alt="Add new Page"/></a>
				<select name="editpageid">
					<cfloop query="q_getPages">
						<option value="#q_getPages.lookupkeyvalue#"<cfif currentPageID EQ q_getPages.lookupkeyvalue> SELECTED</cfif>>#APPLICATION.getSectionPath(q_getPages.sitesectionID,true,'/')#/#q_getPages.lookupkeydisplay#
					</cfloop>
				</select>
				<input type="Submit" class="submitbutton" value="Edit Page Components">
			</form>
		</div>
	</cfoutput>
</cfsavecontent>
<cfif isDefined("editpageid")>
	<cfif isDefined('FORM.delete')>
		<cfquery name="q_delPageComponent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			DELETE FROM pagecomponent 
			WHERE pagecomponentID = #FORM.deleteID# AND pageid = #editpageid#
		</cfquery>
	</cfif>
	<cfquery name="q_getTemplate" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT page.templateid, page.pagename, sitesection.sitesectionname
		FROM page INNER JOIN sitesection ON page.sitesectionid = sitesection.sitesectionid 
		WHERE pageid = #editpageid#
	</cfquery>
	<cfquery name="q_getTemplateFile" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT wireframe 
		FROM template 
		WHERE templateid = #q_getTemplate.templateid#
	</cfquery>
	<cfquery name="q_getContainers" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT containerid, identifier 
		FROM container 
		WHERE templateid = #q_getTemplate.templateid#
	</cfquery>
	<cfquery name="q_getFilledContainers" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT containerid, displayhandlerid, contentobjectid, pagecomponentID
		FROM pagecomponent 
		WHERE pageid = #editpageid#
	</cfquery>
	
	<cfscript>
		start=1;
		thisContainerList="";
		str=q_getTemplateFile.wireframe;
		while (start GT 0) {
			thiscontainer=REFindNoCase('\[\[[[:alnum:]_^ ]*\]\]',str,start,1);
			if (thiscontainer.pos[1]) {
				start=val(thiscontainer.pos[1]+thiscontainer.len[1]);
				thiscontainerList=listAppend(thiscontainerList,trim(mid(str,thiscontainer.pos[1]+2,thiscontainer.len[1]-4)));
				//thiscontainerList=listAppend(thiscontainerList,trim(mid(str,thiscontainer.pos[1]+2,thiscontainer.len[1]-4))&':'&start);
			} else {
				start=0;
			}
		}
	</cfscript>
	<cfset wireFrame=q_getTemplateFile.wireframe>
	<cfloop index="i" list="#thiscontainerlist#">
		<cfsavecontent variable="replacement">
			<cfoutput>
			<div class="columnheaderrow">#listGetAt(i,1,'^')#</div>
			<div class="pageContainerOff" onmouseover="this.className='pageContainerHover'" onmouseout="this.className='pageContainerOff'">
			<strong>Current:</strong>
			<cfloop query="q_getFilledContainers">
				<cfset showForm = 0>
				<cfif q_getFilledContainers.containerid EQ listGetAt(i,2,'^')>
					<cfif q_getFilledContainers.displayhandlerid NEQ #application.contentobjectdh#>
						<img src="#application.globalPath#/media/images/icon_DDD.gif" border="0" alt="Data Driven Display">
						<cfquery name="q_getDH" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
							SELECT displayhandlername FROM displayhandler WHERE displayhandlerid = #q_getFilledContainers.displayhandlerid#
						</cfquery>
						<cfset showForm = q_getDH.RecordCount>
						<strong>#q_getDH.displayhandlername#</strong>
					<cfelseif len(q_getFilledContainers.contentobjectid)>
						<img src="#application.globalPath#/media/images/icon_BC.gif" border="0" alt="Body Content">
						<cfquery name="q_getContent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
							SELECT contentobjectname, contentobjectid FROM contentobject WHERE contentobjectid = #q_getFilledContainers.contentobjectid#
						</cfquery>
						<cfset showForm = q_getContent.RecordCount>
						<strong>#q_getContent.contentobjectname#</strong>
					<cfelse>
						none
					</cfif>
				</cfif>
				<cfif showForm GT 0>
					<cfsavecontent variable="deleteButton">
						<cfoutput>
							<form action="index.cfm" method="post" style="margin-bottom: 0px; margin-left: 0px; margin-right: 0px; margin-top: 0px; page-break-before: avoid; page-break-after: avoid;">
								<input type="hidden" name="i3currenttool" value="#application.tool.pageComponentWizard#">		
								<cfif isDefined('editpageid')><input type="hidden" name="editpageid" value="#editpageid#" /></cfif>
								<input type="hidden" name="deleteID" value="#q_getFilledContainers.pageComponentid#" />
								<input type="submit" name="delete" value="Delete" class="deletePageComponent" title="Delete this Assignment" onmouseover="this.className='deletePageComponentHover';" onmouseout="this.className='deletePageComponent';">
							</form>
						</cfoutput>
					</cfsavecontent>
				<cfelseif NOT IsDefined('deleteButton')>
					<cfset deleteButton = "">
				</cfif>
			</cfloop>
					<br /><br /><cfif isDefined('deleteButton')><div style="float:left;margin-right:3px;">#deleteButton#</div></cfif>
					<input name="ChooseDDD" type="button" class="chooseDDDButton" title="Choose a New Data Driven Display" onclick="window.open('/admintools/core/pageComponentWizard/dhpopup.cfm?editpageid=#editpageid#&amp;containerid=#listGetAt(i,2,'^')#','chooseDisplayHandler','scrollbars=yes,width=565,height=500,resizable=yes')" onmouseover="this.className='chooseDDDButtonOver';" onmouseout="this.className='chooseDDDButton';" value="Choose" />
					<input name="ChooseBC" type="button" class="chooseBCButton" title="Choose a New Content Element" onclick="window.open('/admintools/core/pageComponentWizard/contentpopup.cfm?editpageid=#editpageid#&amp;containerid=#listGetAt(i,2,'^')#','chooseContent','scrollbars=yes,width=565,height=500,resizable=yes')" onmouseover="this.className='chooseBCButtonOver';" onmouseout="this.className='chooseBCButton';" value="Choose" />		
					
				</div>
			</cfoutput>
			<cfset deleteButton = "">
		</cfsavecontent>
		<cfset wireFrame = replacenocase(wireFrame,'[['&i&']]',replacement)>
	</cfloop>
	<cfoutput>
		#pageSelector#
		<div id="pageWireFrame"><h3>#q_getPageTitle.pagetitle#</h3>
			#wireFrame#
		</div>
	</cfoutput>
<cfelse>
	<cfoutput>
		#pageSelector#
	</cfoutput>
</cfif>