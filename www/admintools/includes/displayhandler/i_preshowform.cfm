<!--- i_preshowform.cfm --->
<!--- Only show this block if have come from the page tool --->
<cfparam name="currentContainer" default="0">
<cfset currentContainer=currentContainer+1>
<cfif isDefined("url.pageid")>	
	<cfquery datasource="#application.datasource#" name="q_getpageinfo" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT pagename,pagetitle,sitesectionid,templateid,pageid
		FROM page
		WHERE pageid = #url.pageid#
	</cfquery>
	<cfset pageLabel=application.getSectionPath(q_getpageinfo.sitesectionid,"TRUE")&"\"&q_getpageinfo.pagename>
	<cfquery datasource="#application.datasource#" name="q_getcontainers" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT *
		FROM container
		WHERE templateid = #q_getpageinfo.templateid#
		ORDER BY containerid ASC
	</cfquery>
	<cfif currentContainer GT q_getcontainers.recordcount>
	<!--- we're finished with this page component wizard, send em back to page --->
		<cflocation url="#request.page#?i3currentTool=#application.tool.page#" addtoken="No">
	<cfelse>
		<cfset form.pageid=q_getpageinfo.pageid>
		<cfset form.containerid=q_getcontainers.containerid[currentContainer]>
		<cfset structInsert(form,"currentContainer","#currentContainer#")>
	<!--- Query for existing pagecomponents--->
	<cfquery datasource="#application.datasource#" name="q_getcurrentComponent" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT displayhandler.displayhandlerid, pagecomponent.contentobjectid
		FROM  pagecomponent INNER JOIN displayhandler ON pagecomponent.displayhandlerid = displayhandler.displayhandlerid
		WHERE pagecomponent.pageid = #form.pageid# AND pagecomponent.containerid = #form.containerid#
	</cfquery>
	<!--- Whoa dog, this is body content, not a Data Driven Display. Send em to the BC tool --->
	<cfif len(q_getcurrentComponent.contentobjectid) AND NOT isDefined("url.swapFunction")>
		<cflocation url="#request.page#?i3currenttool=#application.tool.contentobject#&pageid=#pageid#&formstep=showform&currentContainer=#val(currentContainer-1)#" addtoken="No">
	</cfif>
		<cfoutput>
	<p class="instructionText">
		Now Defining content for: <strong>#q_getcontainers.identifier[currentContainer]#</strong> on <strong><a href="/#listChangeDelims(pageLabel,"/","\")#" target="_blank">#listChangeDelims(pageLabel,"/","\")#</a></strong><br>To use a content element for this page component, <a href="#request.page#?i3currenttool=#application.tool.contentobject#&pageid=#pageid#&formstep=showform&currentContainer=#val(currentContainer-1)#&swapFunction=yes">click here</a>.
		</p>
	<cfquery datasource="#application.datasource#" name="q_getDisplayHandlers" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT displayhandlerid,displayhandlername
			FROM displayhandler
			WHERE displayobjectid <> #application.contentObjectDH# OR displayobjectid IS NULL
			ORDER BY displayhandlername ASC
	</cfquery>
	<cfif q_getDisplayHandlers.recordcount>
		<table width="550" border="0" cellspacing="1" cellpadding="5" class="toolTable">
		<tr>
			<td colspan="2" class="toolheader">Choose a Data Driven Display</td>
		</tr>
		<form action="#request.page#" method="post">
		<input type="Hidden" name="formstep" value="confirm">
		<input type="Hidden" name="pageid" value="#form.pageid#">
		<input type="Hidden" name="containerid" value="#form.containerid#">
		<input type="Hidden" name="currentContainer" value="#currentContainer#">
		<tr>
			<td class="formitemlabel" valign="top" align="right" nowrap>
			<select name="displayid">
				<option value="">Select a Data Driven Display
				<cfloop query="q_getDisplayHandlers">
					<option value="#q_getDisplayHandlers.displayhandlerid#~#q_getDisplayHandlers.displayhandlername#"<cfif q_getCurrentComponent.displayhandlerid EQ q_getDisplayHandlers.displayhandlerid> Selected</cfif>>#q_getDisplayHandlers.displayhandlername#</option>
				</cfloop>
			</select> <input type="Submit" value="Assign Data Driven Display" class="submitbutton" style="width:180px">
			</td>
		</tr>
		</form>
		</table>
		</cfif>
		<br>
		</cfoutput>
	</cfif>
</cfif>