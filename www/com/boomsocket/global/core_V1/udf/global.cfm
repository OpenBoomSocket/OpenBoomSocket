<cffunction name="getUpload"
             returntype="struct"
             displayname="Returns upload info"
             hint="Returns upload info">

	<cfargument name="uploadid" required="true" type="numeric">
	
	<!--- query for upload info --->
	<cftry>
		<cfquery name="q_getUpload" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT u.uploadid, u.filename, u.uploadtitle, u.uploaddescription, u.filesize, u.filetype, uc.uploadcategorytitle, uc.foldername
			FROM upload u INNER JOIN
				uploadcategory uc ON u.uploadcategoryid = uc.uploadcategoryid
			WHERE u.uploadid = #arguments.uploadid#
		</cfquery>		
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
	</cftry>
	
	<!--- create structure to return --->
	<cfset uploadStruct = StructNew()>
	<cfif isDefined('q_getUpload') AND q_getUpload.recordcount>	
		<cfset uploadStruct.uploadid = q_getUpload.uploadid>	
		<cfset uploadStruct.filename = q_getUpload.filename>
		<cfset uploadStruct.uploadtitle = q_getUpload.uploadtitle>
		<cfset uploadStruct.uploaddescription = q_getUpload.uploaddescription>
		<cfset uploadStruct.filesize = q_getUpload.filesize>
		<cfset uploadStruct.filetype = q_getUpload.filetype>
		<cfset uploadStruct.uploadcategorytitle = q_getUpload.uploadcategorytitle>
		<cfset uploadStruct.foldername = q_getUpload.foldername>
		<cfset uploadStruct.machinePath = "#application.installPath#\uploads\#q_getUpload.foldername#\#q_getUpload.filename#">
		<cfset uploadStruct.absolutePath = "/uploads/#q_getUpload.foldername#/#q_getUpload.filename#">
		<cfset uploadStruct.relativePath = "/uploads/#q_getUpload.foldername#/#q_getUpload.filename#">
	<cfelse>
		<cfset uploadStruct.uploadid = "">
		<cfset uploadStruct.filename = "">
		<cfset uploadStruct.uploadtitle = "">
		<cfset uploadStruct.uploaddescription = "">
		<cfset uploadStruct.filesize = "">
		<cfset uploadStruct.filetype = "">
		<cfset uploadStruct.uploadcategorytitle = "">
		<cfset uploadStruct.foldername = "">
		<cfset uploadStruct.machinePath = "">
		<cfset uploadStruct.absolutePath = "">
		<cfset uploadStruct.relativePath = "">
	</cfif>
	
	<cfreturn uploadStruct>
</cffunction>

<cffunction name="convertFromMetric"
             returntype="string"
             displayname="Convert a metric measurment to english."
             hint="Converts metric to english. Assumes input is in inches for length pounds for weight. Returns centimeters and kilogams.">
	<cfargument name="measureVal" required="true" type="string">
	<!--- measureType MUST be either length or weight --->
	<cfargument name="measureType" required="true" type="string">
	<cfargument name="measureRound" required="false" type="string">
		<cfif isDefined('measureRound')>
			<cfif measureRound EQ 'round'>
				<cfset measureRound = 1>
			<cfelse>
				<cfset measureRound = 0>
			</cfif>
		<cfelse>
			<cfset measureRound = 0>
		</cfif>
		<cfif len(trim(measureVal))>
			<cfif measureType EQ "length">
				<cfif measureRound EQ 1>
					<cfset returnVal = round((measureVal / 2.54)*100)/100>
				<cfelse>
					<cfset returnVal = ceiling((measureVal / 2.54)*100)/100>
				</cfif>
			<cfelseif measureType EQ "weight">
				<cfif measureRound EQ 1>
					<cfset returnVal = round((measureVal / .45)*100)/100>
				<cfelse>
					<cfset returnVal = ceiling((measureVal / .45)*100)/100>
				</cfif>
			<cfelse>
				<cfoutput>An error has occured! You must pass a "length" or "weight" to the "convertFromMetric" function.</cfoutput><cfabort>
			</cfif>
		<cfelse>
			<cfset returnVal=0>
		</cfif>
	<cfreturn returnVal>
</cffunction>

<cffunction name="convertToMetric"
             returntype="string"
             displayname="Convert an english measurment to metric"
             hint="Converts english to metric. Assumes input is in inches for length pounds for weight. Returns centimeters and kilogams.">
	<cfargument name="measureVal" required="true" type="string">
	<!--- measureType MUST be either length or weight --->
	<cfargument name="measureType" required="true" type="string">
	<cfargument name="measureRound" required="false" type="string">
		<cfif isDefined('measureRound')>
			<cfif measureRound EQ 'round'>
				<cfset measureRound = 1>
			<cfelse>
				<cfset measureRound = 0>
			</cfif>
		<cfelse>
			<cfset measureRound = 0>
		</cfif>
		<cfif len(trim(measureVal))>
			<cfif measureType EQ "length">
				<cfif measureRound EQ 1>
					<cfset returnVal = round((measureVal * 2.54)*100)/100>
				<cfelse>
					<cfset returnVal = ceiling((measureVal * 2.54)*100)/100>
				</cfif>
			<cfelseif measureType EQ "weight">
				<cfif measureRound EQ 1>
					<cfset returnVal = round((measureVal * .45)*100)/100>
				<cfelse>
					<cfset returnVal = ceiling((measureVal * .45)*100)/100>
				</cfif>
				<cfset returnVal = round((measureVal * .45)*100)/100>
			<cfelse>
				<cfoutput>An error has occured! You must pass a "length" or "weight" to the "convertToMetric" function.</cfoutput><cfabort>
			</cfif>
		<cfelse>
			<cfset returnVal=0>
		</cfif>
	<cfreturn returnVal>
</cffunction>
<!--- getSectionPath --->
<cfsetting enablecfoutputonly="Yes">
<cffunction name="getSectionPath"
             returntype="string"
             displayname="Get Section Path"
             hint="Returns a directory path based on a sectionid.">
  <cfargument name="sitesectionid" required="true" type="numeric">
  <cfargument name="fullpath" type="boolean" default="false">
  <cfargument name="slash" default="#application.slash#">
	<cfparam name="sitesectionid" default="0">
	<cfstoredproc procedure="sp_getsectionpath"
	              datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		<cfprocparam type="In"
             cfsqltype="CF_SQL_INTEGER"
             variable="sitesectionid"
             dbvarname="@sitesectionid"
             value="#arguments.sitesectionid#"
             null="No">
		<cfprocparam type="In"
		             cfsqltype="CF_SQL_CHAR"
		             variable="slash"
		             dbvarname="@slash"
		             value="#arguments.slash#"
		             null="No">
		<cfprocparam type="Out"
		             cfsqltype="CF_SQL_CHAR"
		             variable="sectionlist"
		             dbvarname="@sectionlist"
		             null="No">
		<cfprocparam type="Out"
		             cfsqltype="CF_SQL_CHAR"
		             variable="sectionlistfull"
		             dbvarname="@sectionlistfull"
		             null="No">
	</cfstoredproc>
<cfif arguments.fullpath>
	<cfreturn sectionlistfull>
<cfelse>
	<cfreturn sectionlist>
</cfif>
</cffunction>

<!--- getPageList --->
<cffunction name="getPageList" returntype="query" displayname="Get Page List" hint="Returns a list of pages.">
	<cfargument name="sitesectionid" required="false" type="numeric" default="0">
	<cfargument name="sortField" required="false" type="string" default="fullpagepath" hint="Choose fullpagepath, pageid, pagename, or pagetitle">
	<cfargument name="sortOrder" required="false" type="string" default="ASC" hint="ASC or DESC">
	<cfargument name="slash" required="false" type="string" default="/">
	<cfquery name="q_getPages" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT sitesection.sitesectionID, page.pagename, page.pageid, page.pagetitle
		FROM page INNER JOIN sitesection ON page.sitesectionid = sitesection.sitesectionid
		<cfif arguments.sitesectionid NEQ 0>WHERE sitesectionID = #arguments.sitesectionid#</cfif>
	</cfquery>
	<!--- Create a new query where we can sort by the determined sectionpath --->
	<cfset q_sortedSections = queryNew("pageid,fullpagepath,pagetitle,pagename")>
	<cfloop query="q_getPages">
		<cfset queryAddRow(q_sortedSections)>
		<cfset querySetCell(q_sortedSections,"pageid",q_getPages.pageid,q_getPages.currentrow)>
		<cfset querySetCell(q_sortedSections,"fullpagepath","#application.getSectionPath(q_getPages.sitesectionID,true,arguments.slash)#/#q_getPages.pagename#",q_getPages.currentrow)>
		<cfset querySetCell(q_sortedSections,"pagetitle",q_getPages.pagetitle,q_getPages.currentrow)>
		<cfset querySetCell(q_sortedSections,"pagename",q_getPages.pagename,q_getPages.currentrow)>
	</cfloop>
	<cfquery name="q_getPages" dbtype="query">
		SELECT *
		FROM q_sortedSections
		ORDER BY #arguments.sortField# #arguments.sortOrder#
	</cfquery>
	<cfreturn q_getPages>
</cffunction>

<!--- getSectionList --->
<cffunction name="getSectionList" returntype="query" displayname="Get Section List" hint="Returns a list of sections.">
	<cfargument name="parentid" required="false" type="numeric" default="0">
	<cfargument name="sortField" required="false" type="string" default="sitesection.sitesectionname">
	<cfargument name="sortOrder" required="false" type="string" default="ASC" hint="ASC or DESC">
	<cfargument name="slash" required="false" type="string" default="/">
	<cfquery name="q_getSections" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT sitesectionID
		FROM sitesection
		<cfif arguments.parentid NEQ 0>WHERE parentid = #arguments.parentid#</cfif>
		ORDER BY #arguments.sortField# #arguments.sortOrder#
	</cfquery>
	<!--- Create a new query where we can sort by the determined sectionpath --->
	<cfset q_sortedSections = queryNew("id,sectionpath")>
	<cfloop query="q_getSections">
		<cfset queryAddRow(q_sortedSections)>
		<cfset querySetCell(q_sortedSections,"id",q_getSections.sitesectionid,q_getSections.currentrow)>
		<cfset querySetCell(q_sortedSections,"sectionpath",application.getSectionPath(q_getSections.sitesectionID,true,arguments.slash),q_getSections.currentrow)>
	</cfloop>
	<cfreturn q_sortedSections>
</cffunction>

<!--- getPermissions --->
<cffunction name="getPermissions"
             returntype="string"
             displayname="Authenticate user access to an object."
             hint="Returns boolean value based on the method.">
	<cfargument name="type" required="true" type="string">
	<cfargument name="objectid" required="true" type="numeric">
	<cfset var granted=0>
	
	<cfif NOT listfindnocase("access,addedit,remove",arguments.type)>
		<cfset arguments.type="access">
	</cfif>
	<cfif NOT isDefined("session.user")>
		<cfset granted=0>
	<cfelse>
		<cfset granted=0>
		<cfloop from="1" to="#arrayLen(session.user.tools)#" index="i">
			<cfif session.user.tools[i][1] eq arguments.objectid>
				<cfset granted=evaluate("session.user.tools[i][2]."&arguments.type)>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn granted>
</cffunction>
<!--- editButton
displays an edit instance form button when passed an objectid and an instancid
 --->
<cffunction access="remote" name="showEditInstanceButton"
             returntype="string"
             displayname="Show Edit Instance Button"
             hint="Returns an Edit Instance Button for Data Driven Display">
	<cfargument name="thisObjectid" type="numeric" required="true" displayname="ObjectID">
	<cfargument name="thisInstanceID" type="numeric" required="true" displayname="instanceID">
	<cfargument name="thisButtonLabel" type="string" required="false" default="Edit" displayname="label for button">
	<cfargument name="thisExtraURLVars" type="string" required="false" displayname=" Extra URL Vars for returned HTML link">
		<!---Check to see if this object uses workflow--->
		<cfquery name="q_usesWorkflow" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT useWorkflow,datatable,RestrictByUserType
			FROM formobject
			WHERE formobjectid = #arguments.thisObjectid#
		</cfquery>
		<!--- If we are restricting content by usertype, then check this instance for editability --->
		<cfif q_usesWorkflow.RestrictByUserType eq 1>
			<cfquery name="q_userAccess" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT RestrictByUserTypeID
				FROM #q_usesWorkflow.datatable#
				WHERE #q_usesWorkflow.datatable#id = #arguments.thisInstanceID#
			</cfquery>
			<cfif q_userAccess.RestrictByUserTypeID EQ session.user.usertypeid>
				<cfset hasAccess=1>
			<cfelse>
				<cfset hasAccess=0>
			</cfif>
		<cfelse>
			<cfset hasAccess=1>
		</cfif>
		<!--- Do they have permissions for this tool? --->
		<cfif IsDefined('session.user')>
			<cfloop index="i" from="1" to="#arrayLen(session.user.tools)#">
				<cfif session.user.tools[i][1] EQ arguments.thisObjectid>
					<cfif (session.user.tools[i][2].addedit EQ 0) OR (session.user.tools[i][2].access EQ 0)>
						<cfset hasAccess=0>
					</cfif>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset hasAccess=0>
		</cfif>
		<cfif hasAccess>
			<cfsavecontent variable="editButton">
				<cfif isDefined("session.user.liveEdit") AND session.user.liveEdit EQ 1>
				<!--- make sure request.page = request.thispage if doesn't already exist --->
				<cfif NOT isDefined('REQUEST.page') AND isDefined('REQUEST.thispage')>
					<cfset REQUEST.page = REQUEST.thispage>
				</cfif>
				<cfoutput>
					<!--- if content element --->
					<cfif arguments.thisObjectid EQ 109>
						<a href="#request.page#?editInPlace=yes&contentobjectid=#thisInstanceID#<cfif isdefined('arguments.thisExtraURLVars') AND Len(Trim(arguments.thisExtraURLVars))>&#arguments.thisExtraURLVars#</cfif>" style="border-width: 0px; display: block; width: 100%" title="#arguments.thisButtonLabel#" onclick="liveWin=window.open('/admintools/liveEdit.cfm?contentobjectid=#thisInstanceID#&targetdiv=le#thisInstanceID#<cfif isdefined('arguments.thisExtraURLVars') AND Len(Trim(arguments.thisExtraURLVars))>&#arguments.thisExtraURLVars#</cfif>','liveEditWindow','width=700,height=650,resizable=yes');liveWin.focus(); return false;"><img src="#application.globalPath#/media/images/icon_liveedit.gif" border="0"></a>
						<!--- <a href="#request.page#?editInPlace=yes&contentobjectid=#thisInstanceID#<cfif isdefined('arguments.thisExtraURLVars') AND Len(Trim(arguments.thisExtraURLVars))>&#arguments.thisExtraURLVars#</cfif>" style="border-width: 0px; display: block; width: 100%" title="#arguments.thisButtonLabel#" onclick="liveWin=window.open('/admintools/index.cfm?i3displayMode=editLivePopup&contentobjectid=#thisInstanceID#&targetdiv=le#thisInstanceID#<cfif isdefined('arguments.thisExtraURLVars') AND Len(Trim(arguments.thisExtraURLVars))>&#arguments.thisExtraURLVars#</cfif>','liveEditWindow','width=700,height=650,resizable=yes');liveWin.focus(); return false;"><img src="#application.globalPath#/media/images/icon_liveedit.gif" border="0"></a> --->
					<!--- if tool --->
					<cfelse>
						<a href="##" title="#arguments.thisButtonLabel#"><img src="#application.globalPath#/media/images/icon_liveedit.gif" border="0" width="20" height="15" alt="#arguments.thisButtonLabel#" value="#arguments.thisButtonLabel#" onclick="javascript: window.open('/admintools/index.cfm?contentobjectid=#thisInstanceID#&displayForm=1&targetPageID=#request.thispageid#&targetPage=#CGI.server_name##CGI.script_name#&i3currenttool=#arguments.thisObjectid#&formobjectitemid=#arguments.thisObjectid#&instanceid=#arguments.thisInstanceID#&formstep=showform<cfif isdefined('arguments.thisExtraURLVars') AND Len(Trim(arguments.thisExtraURLVars))>&#arguments.thisExtraURLVars#</cfif>','editWindow', 'width=700,height=500,scrollbars=yes,resizable=yes'); return false;"></a>
					</cfif>
				</cfoutput>
				</cfif>
			</cfsavecontent>
		<cfelse>
			<cfset editButton="">
		</cfif>
	<cfreturn editButton>
</cffunction>
<!--- Query Live Versions Returns a Query Variable containing all live versions of an object type.--->
<cffunction access="remote" name="queryLiveVersions"
             returntype="string"
             displayname="Query Live Versions"
             hint="Returns a Query Variable containing all live versions of an object type.">
	<!--- 100002 is "Approved and Live" --->
	<cfargument name="thisTableName" type="string" required="true" displayname="tableName">
	<cfargument name="thisQueryVar" type="string" required="true" displayname="queryVar">
	<cfargument name="thisWhereClause" type="string" required="false" displayname="whereClause" default="">
	<cfquery name="#arguments.thisQueryVar#" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT  *
		FROM #arguments.thisTableName# INNER JOIN version ON #arguments.thisTableName#.#arguments.thisTableName#id = version.instanceItemID
		WHERE (version.versionStatusID = 100002)
		<cfif len(arguments.thisWhereClause)>AND #arguments.thisWhereClause#</cfif>
	</cfquery>
	<cfreturn thisQueryVar>
</cffunction>
<cffunction name="FlashHTMLFormat" access="private" output="false" returntype="string" displayname="Flash HTML Format" hint="Formats HTML for Flash output">
	<cfargument name="badText" required="yes" type="string" displayname="Bad Text" hint="This is the unformated html text">
	<cfset var returnText = badText>
	<cfset var listCount = 0>
	<cfset returnText = ReplaceNoCase(returnText, "#Chr(10)#", "", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, "<OL></OL>", "", "ALL")>
	<cfset returnText = StripCR(returnText)>
	
	<cfloop condition="FindNoCase('<OL>', returnText) neq 0">
		<cfloop condition="(FindNoCase('</OL>', returnText) gt FindNoCase('<li>', returnText)) AND (FindNoCase('<li>', returnText) neq 0)">
			<cfset startSearchAt = FindNoCase('<OL>', returnText)>		
			<cfset listCount = listCount + 1>
			<!--- replaces the next <li> with the correct number --->
			<cfif listCount GT 9>
				<cfset returnText = ReplaceNoCase(returnText, "<li>", "<BR>  #listCount#.  ")>
			<cfelse>
				<cfset returnText = ReplaceNoCase(returnText, "<li>", "<BR>    #listCount#.  ")>
			</cfif>
		</cfloop>
				<!--- we are done with that list, get rid of the <ol> tag so we can find the next  --->
		<cfset listCount = 0>
		<cfset returnText = ReplaceNoCase(returnText, "<OL>", "<br>", "one")>
		<cfset returnText = ReplaceNoCase(returnText, "</OL>", "<br><br>", "one")>
	</cfloop>
	<cfset returnText = ReplaceNoCase(returnText, "<LI>", "<br>", "ALL")>
	<!--- Step xx, get rid of ALL </li>, </ol>, and </ul> tags --->
	<cfset returnText = ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(returnText, "</li>", "", "ALL"), "</ol>", "<br><br>", "ALL"), "</ul>", "<br><br>", "ALL")>
	<!--- Step xx, REReplace statement changes the color attribute of the font tag to have --->
	<!--- quotes around it...ActiveEdit strips them out :( --->
	<cfset returnText = REReplaceNoCase(returnText, "<FONT color=(#Chr(35)#[A-Za-z0-9]*)></FONT>", "", "ALL")>
	<cfset returnText = REReplaceNoCase(returnText, "target=([A-Za-z0-9_]*)", "target=#Chr(34)#\1#Chr(34)#", "ALL")>
	<cfset returnText = REReplaceNoCase(returnText, "face=([A-Za-z0-9_ ]*)", "face=#Chr(34)#\1#Chr(34)#", "ALL")>
	<cfset returnText = REReplaceNoCase(returnText, "color=(#Chr(35)#[A-Za-z0-9]*)", "color=#Chr(34)#\1#Chr(34)#", "ALL")>
	<cfset returnText = REReplaceNoCase(returnText, "size=([A-Za-z0-9]*)", "size=#Chr(34)#\1#Chr(34)#", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, "&nbsp>", " ", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, "&##39>", "'", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, "'", "'", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, "'", "'", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, """", "#Chr(34)#", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, """", "#Chr(34)#", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, "<EM>", "<i>", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, "</EM>", "</i>", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, "<STRONG>", "<b>", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, "</STRONG>", "</b>", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, "<P>", "<br>", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, "</P>", "<br>", "ALL")>
	<cfset returnText = ReplaceNoCase(returnText, "<br>", "<br />", "ALL")>
	<cfreturn returnText>
</cffunction>

<!---
 Sorts a query using Query of Query.
 Updated for CFMX var syntax.
 
 @param query 	 The query to sort. (Required)
 @param column 	 The column to sort on. (Required)
 @param sortDir  	 The direction of the sort. Default is "ASC." (Optional)
 @return Returns a query. 
 @author Raymond Camden (ray@camdenfamily.com) 
 @version 2, October 15, 2002 
--->
<cffunction name="QuerySort" output="no" returntype="query">
	<cfargument name="query" type="query" required="true">
	<cfargument name="column" type="string" required="true">
	<cfargument name="sortDir" type="string" required="false" default="asc">

	<cfset var newQuery = "">
	
	<cfquery name="newQuery" dbtype="query">
		select * from query
		order by #column# #sortDir#
	</cfquery>
	
	<cfreturn newQuery>
	
</cffunction>
<!--- This function displays the socket launcher button bar that appears on the admin dashboard pages --->
<cffunction access="private" name="makeSocketLaunchBar" output="true" returntype="string">
	<cfargument name="toolid" type="numeric" required="yes">
	<cfargument name="showAdd" type="boolean" required="no" default="true">
	<cfargument name="showManage" type="boolean" required="no" default="true">
	<cfargument name="toolname" type="string" required="no" default="Item">
	<cfsavecontent variable="socketLaunchBar">
		<cfif ARGUMENTS.showAdd>
		<a href="#REQUEST.page#?i3CurrentTool=#ARGUMENTS.toolid#&formstep=showForm&displayform=1"><img src="#application.globalPath#/media/images/btn_dashboardAddContent_off.gif" border="0" onmouseover='this.src="#application.globalPath#/media/images/btn_dashboardAddContent_on.gif";' onmouseout='this.src="#application.globalPath#/media/images/btn_dashboardAddContent_off.gif";' title="Add New #ARGUMENTS.toolname#" /></a><cfelse><img src="#application.globalPath#/media/images/btn_dashboardAddContent_off.gif" border="0" title="Add method unavailable." style="opacity:.8; filter: alpha(opacity=80);" /></cfif><cfif ARGUMENTS.showManage><a href="#REQUEST.page#?i3CurrentTool=#ARGUMENTS.toolid#"><img src="#application.globalPath#/media/images/btn_dashboardManageContent_off.gif" border="0" onmouseover='this.src="#application.globalPath#/media/images/btn_dashboardManageContent_on.gif";' onmouseout='this.src="#application.globalPath#/media/images/btn_dashboardManageContent_off.gif";' title="Manage #ARGUMENTS.toolname#" /></a><cfelse><img src="#application.globalPath#/media/images/btn_dashboardManageContent_off.gif" border="0" style="opacity:.8; filter: alpha(opacity=80);" title="Manage method unavailable." /></cfif>
	</cfsavecontent>
	<cfreturn socketLaunchBar>
</cffunction>

<cfscript>
/*
Add new UDFs below and be sure to set them to the request scope at the
bottom of this script so that they can be seen inside custom tags
*/
//STRIP OUT WHITE SPACE and MAKE HTML pretty
	function HtmlCompressFormat(sInput)
	{
	   var level = 2;
	   if( arrayLen( arguments ) GTE 2 AND isNumeric(arguments[2]))
	   {
	      level = arguments[2];
	   }
	   // just take off the useless stuff
	   sInput = trim(sInput);
	   switch(level)
	   {
	      case "3":
	      {
	         //   extra compression can screw up a few little pieces of HTML, doh
	         sInput = reReplace( sInput, "[[:space:]]{2,}", " ", "all" );
	         sInput = replace( sInput, "> <", "><", "all" );
	         sInput = reReplace( sInput, "<!--[^>]+>", "", "all" );
	         break;
	      }
	      case "2":
	      {
	         sInput = reReplace( sInput, "[[:space:]]{2,}", chr( 13 ), "all" );
	         break;
	      }
	      case "1":
	      {
	         // only compresses after a line break
	         sInput = reReplace( sInput, "(" & chr( 10 ) & "|" & chr( 13 ) & ")+[[:space:]]{2,}", chr( 13 ), "all" );
	         break;
	      }
	   }
	   return sInput;
	}
// Remove All HTML tags from a passed string.
function stripHTML(str){
	return ReReplaceNoCase(str, "<[^>]*>", "", "ALL");
}
// Validate filename
function filename(str) {
if (REFindNoCase("[ \\/*&()!@%##\^+=?;:!~\[\]|,${}]",str)) return FALSE;
	else return TRUE;
}
// Validate email
function email(str) {
if (REFindNoCase("^['_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.(([a-z]{2,3})|(aero|coop|info|museum|name))$",str)) return TRUE;
	else return FALSE;
}
// Validate US Phone Number
function phone(valueIn) {
 	var re = "^(([0-9]{3}-)|\([0-9]{3}\) ?)?[0-9]{3}-[0-9]{4}$";
 	return	ReFindNoCase(re, valueIn);
}
// Validate US Zip Code
function IsZipUS(str) {
	return REFind('^[[:digit:]]{5}(( |-)?[[:digit:]]{4})?$', str);
}
// Validate creditcard
function creditcard(ccNo)
{
	var rv = "";
	var str = "";
	var chk = 0;
	var ccln = 0;
	var strln = 0;
	var i = 1;

	if(reFind("[^[0-9][-\s]?]",ccNo)) 
		return FALSE;
     ccNo = replace(ccNo," ","","ALL");
	ccNo = replace(ccNo,"-","","ALL");
	
	/*JPL 11/10/2008 Added Code to Make Sure 
	nonnumbers are not being passed into credit card field*/
	if(reFind("[^0-9]",ccNo)) 
		return FALSE;
		
	rv = Reverse(ccNo);
	ccln = Len(ccNo);
	if(ccln lt 12) return FALSE;
	for(i = 1; i lte ccln;  i = i + 1) {
		if(i mod 2 eq 0) {
			str = str & Mid(rv, i, 1) * 2;
		} else {
			str = str & Mid(rv, i, 1);
		}
	}
	strln = Len(str);
	for(i = 1; i lte strln; i = i + 1) chk = chk + Mid(str, i, 1);
	if((chk neq 0) and (chk mod 10 eq 0)) {
		if(ArrayLen(Arguments) lt 2) return TRUE;
		switch(UCase(Arguments[2])) {
		case "AMEX":		if ((ccln eq 15) and (((Left(ccNo, 2) is "34")) or ((Left(ccNo, 2) is "37")))) return TRUE; break;
		case "DINERS":		if ((ccln eq 14) and (((Left(ccNo, 3) gte 300) and (Left(ccNo, 3) lte 305)) or (Left(ccNo, 2) is "36") or (Left(ccNo, 2) is "38"))) return TRUE; break;
		case "DISCOVER":	if ((ccln eq 16) and (Left(ccNo, 4) is "6011")) return TRUE; break;
		case "MASTERCARD":	if ((ccln eq 16) and (Left(ccNo, 2) gte 51) and (Left(ccNo, 2) lte 55)) return TRUE; break;
		case "VISA":		if (((ccln eq 13) or (ccln eq 16)) and (Left(ccNo, 1) is "4")) return TRUE; break;
		default: return TRUE;
		}
	}
	return FALSE;
}
//This function removes specified chars from the beginning or the end of a string
function smartTrim(str,char){
	if (len(trim(str))) {
		while (findNoCase(left(trim(str),1),char)) {
			str=removeChars(str,1,1);
		}
		while (findNoCase(right(trim(str),1),char)) {
			str=removeChars(str,len(str),1);
		}
	}else {
		str='';
	}
	return str;
}
function CapFirst(str) {
	var newstr = "";
	var word = "";
	var i = 1;
	var strlen = listlen(str," ");
	for(i=1;i lte strlen;i=i+1) {
		word = ListGetAt(str,i," ");
		newstr = newstr & UCase(Left(word,1));
		if(len(word) gt 1) newstr = newstr & Right(word,Len(word)-1);
		if(i lt strlen) newstr = newstr & " ";
	}
	return newstr;
}
/**
 * Create a zip file of a directory or just a file.
 *
 * @param zipPath 	 File name of the zip to create. (Required)
 * @param toZip 	 Folder or full path to file to add to zip. (Required)
 * @param relativeFrom 	 Some or all of the toZip path, from which the entries in the zip file will be relative (Optional)
 * @return Returns nothing.
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 1.1, January 19, 2004
 */
function zipFileNew(zipPath,toZip){
	//make a fileOutputStream object to put the ZipOutputStream into
	var output = createObject("java","java.io.FileOutputStream").init(zipPath);
	//make a ZipOutputStream object to create the zip file
	var zipOutput = createObject("java","java.util.zip.ZipOutputStream").init(output);
	//make a byte array to use when creating the zip
	//yes, this is a bit of hack, but it works
	var byteArray = repeatString(" ",1024).getBytes();
	//we'll need to create an inputStream below for writing out to the zip file
	var input = "";
	//we'll be making zipEntries below, so make a variable to hold them
	var zipEntry = "";
	var zipEntryPath = "";
	//we'll use this while reading each file
	var len = 0;
	//a var for looping below
	var ii = 1;
	//a an array of the files we'll put into the zip
	var fileArray = arrayNew(1);
	//an array of directories we need to traverse to find files below whatever is passed in
	var directoriesToTraverse = arrayNew(1);
	//a var to use when looping the directories to hold the contents of each one
	var directoryContents = "";
	//make a fileObject we can use to traverse directories with
	var fileObject = createObject("java","java.io.File").init(toZip);
	//which part of the file path should be excluded in the zip?
	var relativeFrom = "";

	//if there is a 3rd argument, that is the relativeFrom value
	if(structCount(arguments) GT 2){
		relativeFrom = arguments[3];
	}

	//
	// first, we'll deal with traversing the directory tree below the path passed in, so we get all files under the directory
	// in reality, this should be a separate function that goes out and traverses a directory, but cflib.org does not allow for UDF's that rely on other UDF's!!
	//

	//if this is a directory, let's set it in the directories we need to traverse
	if(fileObject.isDirectory())
		arrayAppend(directoriesToTraverse,fileObject);
	//if it's not a directory, add it the array of files to zip
	else
		arrayAppend(fileArray,fileObject);
	//now, loop through directories iteratively until there are none left
	while(arrayLen(directoriesToTraverse)){
		//grab the contents of the first directory we need to traverse
		directoryContents = directoriesToTraverse[1].listFiles();
		//loop through the contents of this directory
		for(ii = 1; ii LTE arrayLen(directoryContents); ii = ii + 1){
			//if it's a directory, add it to those we need to traverse
			if(directoryContents[ii].isDirectory())
				arrayAppend(directoriesToTraverse,directoryContents[ii]);
			//if it's not a directory, add it to the array of files we want to add
			else
				arrayAppend(fileArray,directoryContents[ii]);
		}
		//now kill the first member of the directoriesToTraverse to clear out the one we just did
		arrayDeleteAt(directoriesToTraverse,1);
	}

	//
	// And now, on to the zip file
	//

	//let's use the maximum compression
	zipOutput.setLevel(9);
	//loop over the array of files we are going to zip, adding each to the zipOutput
	for(ii = 1; ii LTE arrayLen(fileArray); ii = ii + 1){
		//make a fileInputStream object to read the file into
		input = createObject("java","java.io.FileInputStream").init(fileArray[ii].getPath());
		//make an entry for this file
		zipEntryPath = fileArray[ii].getPath();
		//if we are making the zip relative from a certain directory, exclude that from the zipEntryPath
		if(len(relativeFrom)){
			zipEntryPath = replace(zipEntryPath,relativeFrom,"");
		}
		zipEntry = createObject("java","java.util.zip.ZipEntry").init(zipEntryPath);
		//put the entry into the zipOutput stream
		zipOutput.putNextEntry(zipEntry);
		// Transfer bytes from the file to the ZIP file
		len = input.read(byteArray);
		while (len GT 0) {
			zipOutput.write(byteArray, 0, len);
			len = input.read(byteArray);
		}
		//close out this entry
		zipOutput.closeEntry();
		input.close();
	}
	//close the zipOutput
	zipOutput.close();
	//return nothing
	return "";
}
//getContainer
/**
 * Gets the next text container (placeholder, tag, etc.) from a string as designated by starting and ending identifiers.
 *
 * @return Returns a structure.
 * @author Shawn Seley (shawnse@aol.com)
 * @version 0, October 2, 2002
 */
function GetContainer(theString, startIdentifier, endIdentifier){
	// some code based on Joshua Miller's RePlaceHolders()
	var startIdentifier_len  = Len(startIdentifier);
	var endIdentifier_len    = Len(endIdentifier);
	var container            = StructNew();

	var startIndex = 1;
	if(ArrayLen(Arguments) GTE 4) startIndex = Arguments[4];

	container.start      = 0;
	container.end        = 0;
	container.len        = 0;
	container.str        = 0;

	container.contents         = StructNew();
	container.contents.start   = 0;
	container.contents.end     = 0;
	container.contents.len     = 0;
	container.contents.str     = 0;

	container.start = FindNoCase(startIdentifier, theString, startIndex);
	if (container.start GT 0) {
		container.end      = FindNoCase(endIdentifier, theString, container.start+startIdentifier_len) + endIdentifier_len -1;
		container.len      = container.end - container.start +1;
		container.str      = Mid(theString, container.start, container.len);

		container.contents.start   = container.start + startIdentifier_len;
		container.contents.end     = container.end - endIdentifier_len;
		container.contents.len     = container.contents.end - container.contents.start +1;
		container.contents.str     = Mid(theString, container.contents.start, container.contents.len);
	}

	return container;
}

/**
 * Strips all characters from a string except the ones that you want to keep.
 *
 * @param strSource 	 The string to strip. (Required)
 * @param strKeep 	 List of  characters to keep. (Required)
 * @param beCS 	 Boolean that determines if the match should be case sensitive. Default is true. (Optional)
 * @return Returns a string.
 * @author Scott Jibben (scott@jibben.com)
 * @version 1, July 2, 2002
 */
function stripAllBut(str,strip) {
	var badList = "\";
	var okList = "\\";
	var bCS = true;

	if(arrayLen(arguments) gte 3) bCS = arguments[3];

	strip = replaceList(strip,badList,okList);

	if(bCS) return rereplace(str,"[^#strip#]","","all");
	else return rereplaceNoCase(str,"[^#strip#]","","all");
}

/**
 * Detects 40+ browsers.
 * 
 * @return Returns a string. 
 * @author John Bartlett (jbartlett@strangejourney.net) 
 * @version 1, September 30, 2005 
 */
function browserDetect() {
	var loc=0;
	var i=0;
	var b=0;
	var tmp="";
	var browserList="";
	var currBrowser="";
	
	// Avant Browser (Not all Avant browsers contain "Avant" in the string)
	loc=findNoCase("Avant",CGI.HTTP_USER_AGENT);
	if(loc GT 0) {
		loc=listFindNoCase(CGI.HTTP_USER_AGENT,"MSIE"," ");
		if(loc GT 0) {
			tmp=listGetAt(CGI.HTTP_USER_AGENT,loc + 1," ");
			return "Avant " & left(tmp,len(tmp) - 1);
		}
	}

	// PocketPC
	if(findNoCase("Windows CE",CGI.HTTP_USER_AGENT)) return "PocketPC";

	// Misc (browser x.x)
	browserList="Acorn Browse,Check&Get,iCab,Netsurf,Opera,Oregano,SIS";
	for (b=1; b lte listLen(BrowserList); b=b+1) {
		currBrowser=listGetAt(browserList,b);
		loc=listFindNoCase(CGI.HTTP_USER_AGENT,currBrowser," ");
		if(loc GT 0) return currBrowser & " " & listGetAt(CGI.HTTP_USER_AGENT,loc + 1," ");
	}

	// Misc (browser/x.x)
	BrowserList="Amaya,AmigaVoyager,Amiga-AWeb,Camino,Chimera,Contiki,cURL,Dillo,DocZilla,edbrowse,Emacs-W3,Epiphany,Firefox,IBrowse,iCab,K-Meleon,Konqueror,Lynx,Mosaic,NetPositive,Netscape,OmniWeb,Opera,Safari,SWB,Sylera,W3CLineMode,w3m,WebTV";
	for (b=1; b LTE ListLen(BrowserList); b=b+1) {
		currBrowser=listGetAt(browserList,b);
		loc=findNoCase(currBrowser,CGI.HTTP_USER_AGENT);
		if(loc GT 0) {
			// Locate Browser version in string
			for(i=1;i lte listLen(CGI.HTTP_USER_AGENT," ");i=i+1) {
				if(lCase(left(listGetAt(CGI.HTTP_USER_AGENT,i," "),len(currBrowser) + 1)) eq "#CurrBrowser#/") return currBrowser & " " & listLast(listGetAt(CGI.HTTP_USER_AGENT,i," "),"/");
			}
		}
	}

	// Misc (browser, no version)
	browserList="BrowseX,ELinks,Links,OffByOne,BlackBerry";
	for(b=1; b lte listLen(BrowserList); b=b+1) {
		currBrowser=listGetAt(browserList,b);
		if(findNoCase(currBrowser,CGI.HTTP_USER_AGENT) gt 0) return currBrowser;
	}

	// Mozila (must be done after Firefox, Netscape, and other Mozila clones)
	loc=findNoCase("Gecko",CGI.HTTP_USER_AGENT);
	if(loc GT 0) {
		// Locate revision number in string
		for(i=1;i lte listLen(CGI.HTTP_USER_AGENT," ");i=i+1) {
			if(lCase(left(listGetAt(CGI.HTTP_USER_AGENT,i," "),3)) eq "rv:") return "Mozilla " & val(listLast(ListGetAt(CGI.HTTP_USER_AGENT,i," "),":"));
		}
	}

	// IE (Must be last due to other browsers "spoofing" it.
	loc=listFindNoCase(CGI.HTTP_USER_AGENT,"MSIE"," ");
	if(Loc GT 0) {
		tmp=listGetAt(CGI.HTTP_USER_AGENT,loc + 1," ");
		return "MSIE " & left(tmp,len(tmp) - 1);
	}

	// Unable to detect browser
	return "Unknown";
}

/**
 * Detects Visitors OS & possible Version
 * 
 * Based on a PHP example by John Harrison http://www.weberdev.com/get_example-3387.html
 * 
 * @return Returns a string. 
 * @author Eric Jones (support@d-p.com) 
 * @version 1, March 10, 2006
 * 
 */
function osDetect() {
	var currentOS = "unknown";
	var tmp = ArrayNew(1);
	var thisVersion = "";
	var thisUserAgent = CGI.HTTP_USER_AGENT;

	
	if(ReFindNoCase("linux",thisUserAgent)){
		currentOS = "Linux";
	}
	else if(ReFindNoCase("win32",thisUserAgent)){
		currentOS = "Windows";
	}
	else if(ReFindNoCase("Win 9x 4.90",thisUserAgent)){
		currentOS = "Windows Me";
	}
	else if(ReFindNoCase("windows 2000",thisUserAgent) OR ReFindNoCase("(windows nt)( ){0,1} (5.0)",thisUserAgent) ){
		currentOS = "Windows 2000";}
	else if(ReFindNoCase("(windows nt)( ){0,1}(5.1)",thisUserAgent) ){
		currentOS = "Windows XP";
	}else if(ReFindNoCase("(windows nt)( ){0,1}(5.2)",thisUserAgent) ){
		currentOS = "Windows 2003";
	}
	else if(ReFindNoCase("(win)([0-9]{2})",thisUserAgent) OR ReFindNoCase ("(windows)([0-9]{2})",thisUserAgent) ){
		arrayAppend(tmp, ReFindNoCase("(win)([0-9]{1,1}.[0-9]{1,1})",thisUserAgent,1,true));
		arrayAppend(tmp, ReFindNoCase ("(windows)([[0-9]{1,1}.[0-9]{1,1})",thisUserAgent,1,true));
		
		if (isStruct(tmp[1]) AND ArrayLen(tmp[1].pos) GT 1){
			thisVersion = MID(thisUserAgent, tmp[1].pos[ArrayLen(tmp[1].pos)],tmp[1].len[ArrayLen(tmp[1].len)]);
		}else if (isStruct(tmp[1]) AND ArrayLen(tmp[1].pos) GT 1){
			thisVersion = MID(thisUserAgent, tmp[2].pos[ArrayLen(tmp[2].pos)],tmp[2].len[ArrayLen(tmp[2].len)]);
		}
		currentOS = "Windows ";
	}
	else if(ReFindNoCase("(winnt)([0-9]{1,2}.[0-9]{1,2}){0,1}",thisUserAgent) ){
		arrayAppend(tmp, ReFindNoCase("(winnt)([0-9]{1,2}.[0-9]{1,2}){0,1}",thisUserAgent,1,true));
		if (isStruct(tmp[1]) AND ArrayLen(tmp[1].pos) GT 1){
			thisVersion = MID(thisUserAgent, tmp[1].pos[ArrayLen(tmp[1].pos)],tmp[1].len[ArrayLen(tmp[1].len)]);
		}
		currentOS = "Windows NT #thisVersion#";
	}
	else if(ReFindNoCase("(windows nt)( ){0,1}([0-9]{1,2}.[0-9]{1,2}){0,1}",thisUserAgent) ){
		arrayAppend(tmp, ReFindNoCase("(windows nt)( ){0,1}([0-9]{1,2}.[0-9]{1,2}){0,1}",thisUserAgent,1,true));
		if (isStruct(tmp[1]) AND ArrayLen(tmp[1].pos) GT 1){
			thisVersion = MID(thisUserAgent, tmp[1].pos[ArrayLen(tmp[1].pos)],tmp[1].len[ArrayLen(tmp[1].len)]);
		}
		currentOS = "Windows NT #thisVersion#";
	}
	else if(ReFindNoCase("mac",thisUserAgent)){
		currentOS = "Macintosh";
	}
	else if( ReFindNoCase("(sunos) ([0-9]{1,2}.[0-9]{1,2}){0,1}",thisUserAgent)){
		arrayAppend(tmp, ReFindNoCase("(sunos) ([0-9]{1,2}.[0-9]{1,2}){0,1}",thisUserAgent,1,true));
		if (isStruct(tmp[1]) AND ArrayLen(tmp[1].pos) GT 1){
			thisVersion = MID(thisUserAgent, tmp[1].pos[2],tmp[1].len[2]);
		}
		currentOS = "SunOS #thisVersion#";
	}
	else if( ReFindNoCase("(beos) r([0-9]{1,2}.[0-9]{1,2}){0,1}",thisUserAgent)){
		arrayAppend(tmp, ReFindNoCase("(beos) r([0-9]{1,2}.[0-9]{1,2}){0,1}",thisUserAgent,1,true));
		if (isStruct(tmp[1]) AND ArrayLen(tmp[1].pos) GT 1){
			thisVersion = MID(thisUserAgent, tmp[1].pos[2],tmp[1].len[2]);
		}
		currentOS = "BeOS #thisVersion#";
	}
	else if(ReFindNoCase("freebsd",thisUserAgent)){
		currentOS = "FreeBSD";
	}
	else if(ReFindNoCase("openbsd",thisUserAgent)){
		currentOS = "OpenBSD";
	}
	else if(ReFindNoCase("irix",thisUserAgent)){
		currentOS = "IRIX";
	}
	else if(ReFindNoCase("os/2",thisUserAgent)){
		currentOS = "OS/2";
	}
	else if(ReFindNoCase("plan9",thisUserAgent)){
		currentOS = "Plan9";
	}
	else if(ReFindNoCase("unix",thisUserAgent) OR ReFindNoCase("hp-ux",thisUserAgent) OR ReFindNoCase("X11",thisUserAgent) ){
		currentOS = "Unix";
	}
	else if(ReFindNoCase("osf",thisUserAgent)){
		currentOS = "OSF";
	}
	else{
		currentOS = "Unknown";
	}
	
	return currentOS;
}

/**
 * Returns the amount of space (in bytes) of all files and subfolders contained in the specified folder. (Windows only)
 * 
 * @param path 	 Absolute or relative path to the specified folder. 
 * @return Returns a simple value. 
 * @author Rob Brooks-Bilson (rbils@amkor.com) 
 * @version 1.0, July 23, 2001 
 */
function FolderSize(path)
{
  Var fso  = CreateObject("COM", "Scripting.FileSystemObject");
  Var folder = fso.GetFolder(arguments.path);
  Return folder.Size;
}

/**
 * Pass in a value in bytes, and this function converts it to a human-readable format of bytes, KB, MB, or GB.
 * Updated from Nat Papovich's version.
 * 01/2002 - Optional Units added by Sierra Bufe (sierra@brighterfusion.com)
 * 
 * @param size 	 Size to convert. 
 * @param unit 	 Unit to return results in.  Valid options are bytes,KB,MB,GB. 
 * @return Returns a string. 
 * @author Paul Mone (paul@ninthlink.com) 
 * @version 2.1, January 7, 2002 
 */
function byteConvert(num) {
	var result = 0;
	var unit = "";
	
	// Set unit variables for convenience
	var bytes = 1;
	var kb = 1024;
	var mb = 1048576;
	var gb = 1073741824;

	// Check for non-numeric or negative num argument
	if (not isNumeric(num) OR num LT 0)
		return "Invalid size argument";
	
	// Check to see if unit was passed in, and if it is valid
	if ((ArrayLen(Arguments) GT 1)
		AND ("bytes,KB,MB,GB" contains Arguments[2]))
	{
		unit = Arguments[2];
	// If not, set unit depending on the size of num
	} else {
		  if      (num lt kb) {	unit ="bytes";
		} else if (num lt mb) {	unit ="KB";
		} else if (num lt gb) {	unit ="MB";
		} else                {	unit ="GB";
		}		
	}
	
	// Find the result by dividing num by the number represented by the unit
	result = num / Evaluate(unit);
	
	// Format the result
	if (result lt 10)
	{
		result = NumberFormat(Round(result * 100) / 100,"0.00");
	} else if (result lt 100) {
		result = NumberFormat(Round(result * 10) / 10,"90.0");
	} else {
		result = Round(result);
	}
	// Concatenate result and unit together for the return value
	return (result & " " & unit);
}

/**
 * Concatenate two queries together.
 * 
 * @param q1 	 First query. (Optional)
 * @param q2 	 Second query. (Optional)
 * @return Returns a query. 
 * @author Chris Dary (umbrae@gmail.com) 
 * @version 1, February 23, 2006 
 */
function queryConcat(q1,q2) {
	var row = "";
	var col = "";

	if(q1.columnList NEQ q2.columnList) {
		return q1;
	}

	for(row=1; row LTE q2.recordCount; row=row+1) {
	 queryAddRow(q1);
	 for(col=1; col LTE listLen(q1.columnList); col=col+1)
		querySetCell(q1,ListGetAt(q1.columnList,col), q2[ListGetAt(q1.columnList,col)][row]);
	}
	return q1;
}

/**
 * Converts a query object into an array of structures.
 * 
 * @param query 	 The query to be transformed 
 * @return This function returns a structure. 
 * @author Nathan Dintenfass (nathan@changemedia.com) 
 * @version 1, September 27, 2001 
 */
function QueryToArrayOfStructures(theQuery){
	var theArray = arraynew(1);
	var cols = ListtoArray(theQuery.columnlist);
	var row = 1;
	var thisRow = "";
	var col = 1;
	for(row = 1; row LTE theQuery.recordcount; row = row + 1){
		thisRow = structnew();
		for(col = 1; col LTE arraylen(cols); col = col + 1){
			thisRow[cols[col]] = theQuery[cols[col]][row];
		}
		arrayAppend(theArray,duplicate(thisRow));
	}
	return(theArray);
}

/**
 * Converts an array of structures to a CF Query Object.
 * 6-19-02: Minor revision by Rob Brooks-Bilson (rbils@amkor.com)
 * 
 * Update to handle empty array passed in. Mod by Nathan Dintenfass. Also no longer using list func.
 * 
 * @param Array 	 The array of structures to be converted to a query object.  Assumes each array element contains structure with same  (Required)
 * @return Returns a query object. 
 * @author David Crawford (rbils@amkor.comdcrawford@acteksoft.com) 
 * @version 2, March 19, 2003 
 */
function arrayOfStructuresToQuery(theArray){
	var colNames = "";
	var theQuery = queryNew("");
	var i=0;
	var j=0;
	//if there's nothing in the array, return the empty query
	if(NOT arrayLen(theArray))
		return theQuery;
	//get the column names into an array =
	colNames = structKeyArray(theArray[1]);
	//build the query based on the colNames
	theQuery = queryNew(arrayToList(colNames));
	//add the right number of rows to the query
	queryAddRow(theQuery, arrayLen(theArray));
	//for each element in the array, loop through the columns, populating the query
	for(i=1; i LTE arrayLen(theArray); i=i+1){
		for(j=1; j LTE arrayLen(colNames); j=j+1){
			querySetCell(theQuery, colNames[j], theArray[i][colNames[j]], i);
		}
	}
	return theQuery;
}

/**
 * Abbreviates a given string to roughly the given length, stripping any tags, making sure the ending doesn't chop a word in two, and adding an ellipsis character at the end.
 * Fix by Patrick McElhaney
 * v3 by Ken Fricklas kenf@accessnet.net, takes care of too many spaces in text.
 * 
 * @param string 	 String to use. (Required)
 * @param len 	 Length to use. (Required)
 * @return Returns a string. 
 * @author Gyrus (kenf@accessnet.netgyrus@norlonto.net) 
 * @version 3, September 6, 2005 
 */
function abbreviate(string,len) {
	var newString = REReplace(string, "<[^>]*>", " ", "ALL");
	var lastSpace = 0;
	newString = REReplace(newString, " \s*", " ", "ALL");
	if (len(newString) gt len) {
		newString = left(newString, len-2);
		lastSpace = find(" ", reverse(newString));
		lastSpace = len(newString) - lastSpace;
		newString = left(newString, lastSpace) & "  &##8230;";
	}	
	return newString;
}
/**
 * Removes potentially nasty HTML text.
 * Version 2 by Lena Aleksandrova - changes include fixing a bug w/ arguments and use of REreplace where REreplaceNoCase should have been used.
 * version 4 fix by Javier Julio - when a bad event is removed, remove the arg too, ie, remove onclick=&quot;foo&quot;, not just onclick.
 * 
 * @param text 	 String to be modified. (Required)
 * @param strip 	 Boolean value (defaults to false) that determines if HTML should be stripped or just escaped out. (Optional)
 * @param badTags 	 A list of bad tags. Has a long default list. Consult source. (Optional)
 * @param badEvents 	 A list of bad HTML events. Has a long default list. Consult source. (Optional)
 * @return Returns a string. 
 * @author Nathan Dintenfass (nathan@changemedia.com) 
 * @version 4, October 16, 2006 
 */
function safetext(text) {
	//default mode is "escape"
	var mode = "escape";
	//the things to strip out (badTags are HTML tags to strip and badEvents are intra-tag stuff to kill)
	//you can change this list to suit your needs
	var badTags = "SCRIPT,OBJECT,APPLET,EMBED,FORM,LAYER,ILAYER,FRAME,IFRAME,FRAMESET,PARAM,META";
	var badEvents = "onClick,onDblClick,onKeyDown,onKeyPress,onKeyUp,onMouseDown,onMouseOut,onMouseUp,onMouseOver,onBlur,onChange,onFocus,onSelect,javascript:";
	var stripperRE = "";
	
	//set up variable to parse and while we're at it trim white space 
	var theText = trim(text);
	//find the first open bracket to start parsing
	var obracket = find("<",theText);		
	//var for badTag
	var badTag = "";
	//var for the next start in the parse loop
	var nextStart = "";
	//if there is more than one argument and the second argument is boolean TRUE, we are stripping
	if(arraylen(arguments) GT 1 AND isBoolean(arguments[2]) AND arguments[2]) mode = "strip";
	if(arraylen(arguments) GT 2 and len(arguments[3])) badTags = arguments[3];
	if(arraylen(arguments) GT 3 and len(arguments[4])) badEvents = arguments[4];
	//the regular expression used to stip tags
	stripperRE = "</?(" & listChangeDelims(badTags,"|") & ")[^>]*>";	
	//Deal with "smart quotes" and other "special" chars from MS Word
	theText = replaceList(theText,chr(8216) & "," & chr(8217) & "," & chr(8220) & "," & chr(8221) & "," & chr(8212) & "," & chr(8213) & "," & chr(8230),"',',"","",--,--,...");
	//if escaping, run through the code bracket by bracket and escape the bad tags.
	if(mode is "escape"){
		//go until no more open brackets to find
		while(obracket){
			//find the next instance of one of the bad tags
			badTag = REFindNoCase(stripperRE,theText,obracket,1);
			//if a bad tag is found, escape it
			if(badTag.pos[1]){
				theText = replace(theText,mid(TheText,badtag.pos[1],badtag.len[1]),HTMLEditFormat(mid(TheText,badtag.pos[1],badtag.len[1])),"ALL");
				nextStart = badTag.pos[1] + badTag.len[1];
			}
			//if no bad tag is found, move on
			else{
				nextStart = obracket + 1;
			}
			//find the next open bracket
			obracket = find("<",theText,nextStart);
		}
	}
	//if not escaping, assume stripping
	else{
		theText = REReplaceNoCase(theText,stripperRE,"","ALL");
	}
	//now kill the bad "events" (intra tag text)
	theText = REReplaceNoCase(theText,'(#ListChangeDelims(badEvents,"|")#)[^ >]*',"","ALL");
	//return theText
	return theText;
}

/**
 * Scramail takes a string as an argument and changes the characters in the email to their ascii equivelents to hide the email address from spam bots.
 * 
 * @param str 	 String to parse. (Required)
 * @return Returns a string. 
 * @author Deva Nando (d.nando@gmail.com) 
 * @version 1, August 10, 2006 
 */
function scramail(str) {
	var emailregex = "(['_a-z0-9-]+(\.['_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.(([a-z]{2,3})|(aero|coop|info|museum|name)))";
	var i = 1;
	var email = "";
	var ascMail = "";
	var marker = 1;
	var matches = "";
	
	matches = reFindNoCase(emailregex,str,marker,marker);

	while(matches.len[1] gt 0) {
		email = mid(str,matches.pos[1],matches.len[1]);
		for (i=1; i LTE len(email); i=i+1) {
			ascMail = ascMail & "&##" & asc(mid(email,i,1)) & ";";
		}
		str = replace(str,email,ascMail,"all");
		marker = matches.pos[1] + matches.len[1];
		matches = reFindNoCase(emailregex,str,marker,marker);
	}
	return str;
}

function arrayDefinedAt(arr,pos) {
	var temp = "";
	try {
		temp = arr[pos];
		return true;
	} 
	catch(coldfusion.runtime.UndefinedElementException ex) {
		return false;
	}
	catch(coldfusion.runtime.CfJspPage$ArrayBoundException ex) {
		return false;
	}
}


//if we're initializing app, dump them in app scope
if(NOT isDefined("application.getUpload") OR isDefined("URL.initializeApp")){
	application.getUpload=getUpload;
	application.CapFirst=CapFirst;
	application.convertToMetric=convertToMetric;
	application.convertFromMetric=convertFromMetric;
	application.stripHTML=stripHTML;
	application.HtmlCompressFormat=HtmlCompressFormat;
	application.filename=filename;
	application.email=email;
	application.zipFileNew=zipFileNew;
	application.phone=phone;
	application.IsZipUS=IsZipUS;
	application.creditcard=creditcard;
	application.smartTrim=smartTrim;
	application.getSectionPath=getSectionPath;
	application.getPermissions=getPermissions;
	application.showEditInstanceButton=showEditInstanceButton;
	application.queryLiveVersions=queryLiveVersions;
	application.GetContainer = GetContainer;
	application.getSectionList = getSectionList;
	application.getPageList = getPageList;
	application.stripAllBut = stripAllBut;
	application.FlashHTMLFormat = FlashHTMLFormat;
	application.browserDetect = browserDetect;
	application.osDetect = osDetect;
	application.FolderSize = FolderSize;
	application.byteConvert = byteConvert;
	application.queryConcat = queryConcat;
	application.QuerySort = QuerySort;
	application.QueryToArrayOfStructures = QueryToArrayOfStructures;
	application.arrayOfStructuresToQuery = arrayOfStructuresToQuery;
	application.makeSocketLaunchBar = makeSocketLaunchBar;
	application.abbreviate = abbreviate;
	application.safetext = safetext;
	application.scramail = scramail;
	application.arrayDefinedAt = arrayDefinedAt;
}
</cfscript>
