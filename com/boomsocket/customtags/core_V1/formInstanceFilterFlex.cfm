<!--- This include is designed to be called before loading
a dynamic form to allow user to pick an existing record to edit
 --->
<cfset formInstanceObj=CreateObject("component","#APPLICATION.CFCPath#.formInstance")>
<cfset AmbiguousList="ParentID,DateCreated,DateModified,Ordinal,active,description,body,abstract">
<cfset CastAsVarcharlist = "">
<!--- If we are on any user management related tool, add in filter on query --->
<cfif session.i3currentTool eq application.tool.users>
	<cfset securitySelect="usertype.roleid">
	<cfset securityFrom=" INNER JOIN [usertype] as ut ON users.usertypeid = ut.usertypeid">
	<cfif session.user.accessLevel EQ 1>
		<cfset securityWhere="[usertype].roleid >= #session.user.accessLevel#">
	<cfelse>
		<cfset securityWhere="[usertype].roleid > #session.user.accessLevel#">
	</cfif>
<cfelseif session.i3currentTool eq application.tool.usertype>
	<cfset securitySelect="[usertype].roleid">
	<cfset securityFrom="">
	<cfif session.user.accessLevel EQ 1>
		<cfset securityWhere="[usertype].roleid >= #session.user.accessLevel#">
	<cfelse>
		<cfset securityWhere="[usertype].roleid > #session.user.accessLevel#">
	</cfif>
</cfif>

	<cfset keyvalue=request.q_getForm.editFieldKeyValue2>
	<cfset fullKeyValueList=request.q_getForm.editFieldKeyValue2>
<!--- 12/06/2006 DRK pull composite form edit and sort keys START --->
<!--- get data definitions in array format --->
<cfif isDefined('request.q_getForm.compositeForm') AND (request.q_getForm.compositeForm EQ 1)>
	<cfset a_formelements= request.a_formelements>
	<!--- <cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
			input="#request.q_getform.datadefinition#"
			output="a_formelements"> DRK - already in request scope--->
	<!--- set up retrieval keys and sort fields for composite elements (allows existing code to work as is) --->
	<cfset compositekey = structNew()>
	<cfset compositetablelist = "">
	<cfset compositesortvalue = "">
	<!--- loop through all form elements including foreign table fields --->
	<cfloop from="1" to="#arrayLen(a_formelements)#" index="i">
		<!--- is this a foreign table field? --->
		<cfif ArrayLen(structFindKey(a_formelements[i],'SOURCEFORMOBJECTID'))>
			<!--- add a listing entry for this table id --->
			<cfif NOT listfindnocase(compositetablelist,a_formelements[i]['SOURCEFORMOBJECTID'])>
				<cfset compositetablelist = listAppend(compositetablelist,a_formelements[i]['SOURCEFORMOBJECTID'])>
				<!--- set up hash table entry for this table --->
				<cfset compositekey[a_formelements[i]['SOURCEFORMOBJECTID']] = "">
			</cfif>
			<!--- check to see if this field has been selected ---->
			<cfloop list="#keyvalue#" index="key">
				<cfif listfindnocase(a_formelements[i]['FIELDNAME'],key)>
					<!--- remove composite field from 'normal' field key list --->
					<cfset keyvalue = listDeleteAt(keyvalue,listfindnocase(keyvalue,key))>
					<!--- append this key to composite field list based on hash value --->
					<cfset compositekey[a_formelements[i]['SOURCEFORMOBJECTID']] = listAppend(compositekey[a_formelements[i]['SOURCEFORMOBJECTID']],a_formelements[i]['FIELDNAME'])>
				</cfif>
			</cfloop>
			<!--- check for inclusion in sort field list by looping through all sort keys --->
			<cfloop list="#sortvalue#" index="j">
				<cfif findnocase(a_formelements[i]['FIELDNAME'],j)>
					<!--- remove sort key from 'normal' sort key listing --->
					<cfset sortvalue = listDeleteAt(sortvalue,listfindnocase(sortvalue,j))>
					<!--- if this element was not already in the list of visible keys, add it --->
					<cfif NOT listfindnocase(compositekey[a_formelements[i]['SOURCEFORMOBJECTID']],a_formelements[i]['FIELDNAME'])>
						<cfset compositekey[a_formelements[i]['SOURCEFORMOBJECTID']] = listAppend(compositekey[a_formelements[i]['SOURCEFORMOBJECTID']],a_formelements[i]['FIELDNAME'])>
					</cfif>
					<!--- append sort to foreign key sort list, will be used after composite query object built --->
					<cfset compositesortvalue = listAppend(compositesortvalue,j)>
				</cfif>
			</cfloop>
		</cfif>
	</cfloop>
</cfif>
<!--- 12/06/2006 DRK pull composite form edit and sort keys END --->
<!--- set delete flag DO NOT DELETE THIS COMMENT--->
<!--- <cfif request.getPermissions("remove",session.i3currenttool) AND request.q_getForm.bulkdelete EQ 1>
	<cfset request.deletePerms=1>
<cfelse>
	<cfset request.deletePerms=0>
</cfif> --->

<!--- build select, from, and where clauses, pr3pp1n for the big query shindig --->
<cfif isDefined("securitySelect")>
	<cfset selectClause="#securitySelect#,#request.q_getForm.datatable#.#request.q_getForm.datatable#ID">
<cfelse>
	<cfset selectClause="#request.q_getForm.datatable#.#request.q_getForm.datatable#ID">
</cfif>
<cfif isDefined("securityFrom")>
	<cfset fromClause="#request.q_getForm.datatable# #securityFrom#">
<cfelse>
	<cfset fromClause="#request.q_getForm.datatable#">
</cfif>
<cfif isDefined("securityWhere")>
	<cfset whereClause="#securityWhere#">
<cfelse>
	<cfset whereClause="">
</cfif>
<!--- If we are in a workflow managed object, join to version table --->
<cfif request.q_getForm.useWorkFlow EQ 1>
	<cfset selectClause="[version].version, [versionStatus].status,"&selectClause>
	<cfset fromClause=fromClause&" INNER JOIN [version] ON [#request.q_getForm.datatable#].#request.q_getForm.datatable#id = [version].instanceItemid INNER JOIN [VersionStatus] ON [version].versionStatusID = [VersionStatus].versionstatusid ">
	<cfset whereClause = whereClause& " ([version].archive IS NULL OR [version].archive = 0) AND [version].formobjectitemid = " & #session.i3CurrentTool#>
</cfif>

<cfset newKeyValue="">
<cfset newKeyValue2="">
<!--- DRK CFC candidates? return type Boolean?--->
<!--- <cfloop list="#request.q_getForm.editFieldKeyValue2#" index="i"> --->
<cfloop list="#KeyValue#" index="i">
	<cfif right(i,2) EQ "id">
		<cfset thisTable=removeChars(i,len(i)-1,2)>
		<cfset thisDisplay="[#thisTable#].#thisTable#name">
		<cfset thisDisplayField="#thisTable#name">
		<cfset thisKey=i>
		<!--- check for lookup table assignment --->
		<cfloop index="t" from="1" to="#arrayLen(request.a_formelements)#">
			<cfif structFind(request.a_formelements[t],"fieldname") eq i>
				<cfif findnocase(request.a_formelements[t].LOOKUPTYPE,"table") AND len(trim(request.a_formelements[t].LOOKUPTABLE))>
					<cfset thisTable=request.a_formelements[t].LOOKUPTABLE>
					<cfif len(trim(request.a_formelements[t].LOOKUPKEY))>
						<cfset thisKey=request.a_formelements[t].LOOKUPKEY>
					</cfif>
					<cfif len(trim(request.a_formelements[t].LOOKUPDISPLAY))>
						<cfset thisDisplay="[#thisTable#].#request.a_formelements[t].LOOKUPDISPLAY#">
						<cfset thisDisplayField="#request.a_formelements[t].LOOKUPDISPLAY#">
					</cfif>
				</cfif>
				<cfbreak>
			</cfif>
		</cfloop>
		<!--- see if the table exists --->
		<cfif formInstanceObj.isTableValid(keyField=thisKey,tableName=thisTable,displayField=thisDisplayField)>
			<cfset selectClause=listAppend(selectClause,thisDisplay)>
			<cfset newKeyValue=listAppend(newKeyValue,thisDisplayField)>
			<cfparam name="removeKeyValue" default="">
			<cfset removeKeyValue=ListAppend(removeKeyValue,i)>
			<cfset newSearchKeyValue=thisDisplay>
			<cfif thisTable EQ request.q_getForm.datatable>
				<cfset newKeyValue2=listAppend(newKeyValue2,thisDisplayField)>
			<cfelse>
				<cfset newKeyValue2=listAppend(newKeyValue2,"")>
			</cfif>
			<cfif request.q_getForm.datatable NEQ thisTable>
				<cfset fromClause=fromClause&" LEFT JOIN [#thisTable#] ON  [#request.q_getForm.datatable#].#i#=[#thisTable#].#thisKey#">
			</cfif>
		</cfif>
	</cfif>
</cfloop>
<!---If the filter "restrictByUserType" was selected, add to the where clause--->
<cfif request.q_getForm.RestrictByUserType eq 1>
<!--- write a query to look up this user's supervisor and allow them to see the content as well --->
		<cfif len(whereclause)>
			<cfset whereclause=urlDecode(whereclause)&" AND ">
		</cfif>
	<cfset whereclause = whereclause & "(restrictByUserTypeId = #session.user.usertypeid#)">
</cfif>
<cfset fieldlistnoForeign = keyvalue>
<cfif listLen(newKeyValue)>
	<cfset keyvalue=listAppend(keyValue,lcase(newKeyValue))>
	<cfset fullKeyValueList=listAppend(fullKeyValueList,lcase(newKeyValue))>
	<cfif isDefined("removeKeyValue")>
		<!--- 
			ERJ MOD 1/23/06
			Turned removeKeyValue into a list so it would handle muliple <tablename>id fields
		 --->
		<cfloop index="remMe" list="#removeKeyValue#">
			<cfset keyvalue=listDeleteAt(keyValue,listFindNoCase(keyValue,remMe))>
			<cfset fullKeyValueList=listDeleteAt(fullKeyValueList,listFindNoCase(fullKeyValueList,remMe))>
		</cfloop>
		<cfif FindNoCase(removeKeyValue,whereclause,1)>
			<cfset whereClause=replaceNoCase(whereClause,removeKeyValue,newSearchKeyValue,"all")>
		</cfif>
	</cfif>
</cfif>
<!--- If we are in a workflow managed object, join to version table --->
<cfset keyvalue=request.q_getForm.editFieldKeyValue2>
<cfif request.q_getForm.useWorkFlow EQ 1>
	<cfset keyvalue=keyvalue&",Status,Version">
</cfif>
<cfset qualifiedSelectList="">
<cfloop list="#fieldlistnoForeign#" index="j">
	<cfset qualifiedSelectList=listAppend(qualifiedSelectList,"[#request.q_getForm.datatable#].#j#",",")>
</cfloop>
<cfset selectClause=listAppend(selectClause,"#qualifiedSelectList#")>
<cfset orderVar=request.q_getForm.editFieldSortOrder2>
<cfif isDefined('removeKeyValue')>
	<cfif FindNoCase(removeKeyValue,orderVar,1)>
		<cfset orderVar = replaceNoCase(orderVar,removeKeyValue,newSearchKeyValue,"all")>
	</cfif>
</cfif>
<cfloop list="#AmbiguousList#" index="thisAmbItem">
	<cfif ListContains(CastAsVarcharlist,thisAmbItem)>
		<cfset orderVar=replaceNoCase(orderVar,"#thisAmbItem# ","CAST(#request.q_getForm.datatable#.#thisAmbItem# AS VarChar(100)) ")>
	<cfelse>
		<cfset orderVar=replaceNoCase(orderVar,"#thisAmbItem# ","#request.q_getForm.datatable#.#thisAmbItem# ")>
	</cfif>
</cfloop>
<!--- Begin display coding to include Flex viewer --->
<!--- make sure the CF version supports Flash Remoting --->
<cfif (listfirst(server.ColdFusion.ProductVersion) GT 7) OR (listfirst(server.ColdFusion.ProductVersion) EQ 7 AND (listgetat(server.ColdFusion.ProductVersion,2) GT 0 OR ((listgetat(server.ColdFusion.ProductVersion,2) EQ 0 AND listgetat(server.ColdFusion.ProductVersion,3) GTE 2) OR listgetat(server.ColdFusion.ProductVersion,2) GT 0)))>
<cfoutput>
	<div id="formViewer" style="text-align: center;">
	<!-- saved from url=(0014)about:internet -->
		<script src="#application.globalpath#/javascript/Flash/AC_OETags.js" language="javascript"></script>
		<!--- <style>
		body { margin: 0px; overflow:hidden }
		</style> --->
		<script language="JavaScript" type="text/javascript">
		<!--
		// -----------------------------------------------------------------------------
		// Globals
		// Major version of Flash required
		var requiredMajorVersion = 9;
		// Minor version of Flash required
		var requiredMinorVersion = 0;
		// Minor version of Flash required
		var requiredRevision = 0;
		// -----------------------------------------------------------------------------
		// -->
		//document.getElementById('adminnavlist').onmouseover = function(){
		//document.getElementById('formViewer').getElementsByTagName('embed')[0].style.style.width = "1%";
		//document.getElementById('flashContainer').visibility = "show";
		//}
		//document.getElementById('adminnavlist').onmouseout = function(){
		//document.getElementById('formViewer').getElementsByTagName('embed')[0].style.style.width = "100%";
		//document.getElementById('flashContainer').visibility = "hide";
		//}
		</script>
		<script language="JavaScript" type="text/javascript" src="#application.globalpath#/javascript/Flash/history.js"></script>
		<script language="JavaScript" type="text/javascript">
		<!--
		// Version check for the Flash Player that has the ability to start Player Product Install (6.0r65)
		var hasProductInstall = DetectFlashVer(6, 0, 65);
		
		// Version check based upon the values defined in globals
		var hasRequestedVersion = DetectFlashVer(requiredMajorVersion, requiredMinorVersion, requiredRevision);
		
		
		// Check to see if a player with Flash Product Install is available and the version does not meet the requirements for playback
		if ( hasProductInstall && !hasRequestedVersion ) {
			// MMdoctitle is the stored document.title value used by the installation process to close the window that started the process
			// This is necessary in order to close browser windows that are still utilizing the older version of the player after installation has completed
			// DO NOT MODIFY THE FOLLOWING FOUR LINES
			// Location visited after installation is complete if installation is required
			var MMPlayerType = (isIE == true) ? "ActiveX" : "PlugIn";
			var MMredirectURL = window.location;
			document.title = document.title;
			var MMdoctitle = document.title;
		
			AC_FL_RunContent(
				"src", "/admintools/media/swf/playerProductInstall",
				"FlashVars", "MMredirectURL="+MMredirectURL+'&MMplayerType='+MMPlayerType+'&MMdoctitle='+MMdoctitle+"",
				"width", "100%",
				"height", "100%",
				"align", "middle",
				"id", "FormViewer",
				"quality", "high",
				"bgcolor", "##869ca7",
				"name", "ToolViewer",
				"allowScriptAccess","sameDomain",
				"type", "application/x-shockwave-flash",
				"pluginspage", "http://www.adobe.com/go/getflashplayer",
				"wmode","transparent"
			);
		} else if (hasRequestedVersion) {
			// if we've detected an acceptable version
			// embed the Flash Content SWF when all tests are passed
			if(isIE){
				objHeight = "600px";
			}else{
				objHeight = "600px";
			}
			AC_FL_RunContent(
					"src", "#APPLICATION.globalpath#/media/swf/FormViewer",
					"width", "100%",
					"height", objHeight,
					"align", "middle",
					"id", "ToolViewer",
					"quality", "high",
					"bgcolor", "##869ca7",
					"name", "FormViewer",
					"flashvars",'toolid=#session.i3currentTool#&selectClause=#selectClause#&fromClause=#fromClause#&whereClause=#whereclause#&orderVars=#orderVar#&dataSource=#APPLICATION.datasource#&requestpage=#CGI.SCRIPT_NAME#&serverURL=#APPLICATION.installurl#&sitemapping=#APPLICATION.sitemapping#&keyList=#fullKeyValueList#',
					"allowScriptAccess","sameDomain",
					"type", "application/x-shockwave-flash",
					"pluginspage", "http://www.adobe.com/go/getflashplayer",
					"wmode","transparent"
			);
		  } else {  // flash is too old or we can't detect the plugin
			var alternateContent = 'Alternate HTML content should be placed here. '
			+ 'This content requires the Adobe Flash Player. '
			+ '<a href=http://www.adobe.com/go/getflash/>Get Flash</a>';
			document.write(alternateContent);  // insert non-flash content
		  }
		// -->
		</script>
		<noscript>
			<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
					id="FormViewer" width="100%" height="100%"
					codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
					<param name="movie" value="#APPLICATION.installurl#/admintools/media/swf/FormViewer.swf" />
					<param name="quality" value="high" />
					<param name="bgcolor" value="##869ca7" />
					<param name="allowScriptAccess" value="sameDomain" />
					<param name="wmode" value="transparent" />
					<embed src="/admintools/media/swf/FormViewer.swf" quality="high" bgcolor="##869ca7"
						width="100%" height="100%" name="ToolViewer" align="middle"
						play="true"
						loop="false"
						quality="high"
						allowScriptAccess="sameDomain"
						type="application/x-shockwave-flash"
						pluginspage="http://www.adobe.com/go/getflashplayer">
					</embed>
			</object>
		</noscript>
		<!--- <iframe name="_history" src="/admintools/media/swf/history.htm" frameborder="0" scrolling="no" width="22" height="0"></iframe> --->
	</div>
</cfoutput>
<cfelse>
	<cfinclude template="#application.customtagpath#/forminstancefilter.cfm">
</cfif>