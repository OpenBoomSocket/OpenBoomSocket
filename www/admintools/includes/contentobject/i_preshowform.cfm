<!--- i_preshowform.cfm --->
<!--- Only show this block if have come from the page tool --->
<cfparam name="currentContainer" default="0">
<cfif isNumeric(currentContainer)>
	<cfset currentContainer=currentContainer+1>
</cfif>
<cfif isDefined("url.pageid")>	
	<cfquery datasource="#application.datasource#" name="q_getpageinfo" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT pagename,pagetitle,sitesectionid,templateid,pageid
		FROM page
		WHERE pageid = #url.pageid#
	</cfquery>
	<cfset form.sitesectionid=q_getpageinfo.sitesectionid>
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
		SELECT contentobject.contentobjectid
		FROM  pagecomponent LEFT OUTER JOIN contentobject ON pagecomponent.contentobjectid = contentobject.contentobjectid
		WHERE pagecomponent.pageid = #form.pageid# AND pagecomponent.containerid = #form.containerid#
	</cfquery>
	<!--- Whoa dog, this is a displayhandler, not body content. Send em to the DH tool --->
	<cfif q_getcurrentComponent.recordcount GT 0 AND len(q_getcurrentComponent.contentobjectid) EQ 0 AND NOT isDefined("url.swapFunction")>
		<cflocation url="#request.page#?i3currenttool=#application.tool.displayhandler#&pageid=#pageid#&formstep=showform&currentContainer=#val(currentContainer-1)#" addtoken="No">
	</cfif>
		<cfoutput>
	<p class="instructionText">
		Now Defining content for: <strong>#q_getcontainers.identifier[currentContainer]#</strong> on <strong><a href="/#listChangeDelims(pageLabel,"/","\")#" target="_blank">#listChangeDelims(pageLabel,"/","\")#</a></strong><br>To use a Data Driven Display for this page component, <a href="#request.page#?i3currenttool=#application.tool.displayhandler#&pageid=#pageid#&formstep=showform&currentContainer=#val(currentContainer-1)#&swapFunction=yes">click here</a>.
		</p>
		<cfquery datasource="#application.datasource#" name="q_getcontentobjects" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT contentobjectid,contentobjectname
			FROM contentobject
			ORDER BY contentobjectname ASC
		</cfquery>
		<cfif q_getcontentobjects.recordcount>
		<table width="550" border="0" cellspacing="1" cellpadding="5" class="toolTable">
		<tr>
			<td class="toolheader">Choose a Content Element</td>
		</tr>
		<form action="#request.page#" method="post">
		<input type="Hidden" name="formstep" value="confirm">
		<input type="Hidden" name="pageid" value="#form.pageid#">
		<input type="Hidden" name="containerid" value="#form.containerid#">
		<input type="Hidden" name="skipWorkflow" value="Yes">
		<input type="Hidden" name="currentContainer" value="#currentContainer#">
		<tr>
			<td class="formitemlabel" valign="top" align="right" nowrap>
			<select name="contentid">
				<option value="">Select a Content Item
				<cfloop query="q_getcontentobjects">
					<option value="#q_getcontentobjects.contentobjectid#~#q_getcontentobjects.contentobjectname#"<cfif q_getCurrentComponent.contentObjectid EQ q_getcontentobjects.contentobjectid> Selected</cfif>>#q_getcontentobjects.contentobjectname#</option>
				</cfloop>
			</select> <input type="Submit" value="Assign Content Item" class="submitbutton" style="width:180px">
			</td>
		</tr>
		</form>
		</table>
		</cfif>
		<br>
		</cfoutput>
	</cfif>
</cfif>