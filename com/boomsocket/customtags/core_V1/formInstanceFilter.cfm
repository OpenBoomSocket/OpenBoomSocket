<!--- This include is designed to be called before loading
a dynamic form to allow user to pick an existing record to edit
 --->
<cfif thistag.executionmode is "START">
<cfset AmbiguousList="ParentID,DateCreated,DateModified,Ordinal,active,description,body,abstract,sekeyname,startdate,enddate,bs_pageTitle">
<cfset CastAsVarcharlist = "">
<cfset formInstanceObj=CreateObject("component","#APPLICATION.CFCPath#.formInstance")>
<cfif IsDefined('request.q_getForm')>
	<cfscript>
		thisDataDef = XMLParse(request.q_getForm.DATADEFINITION);
	</cfscript>
	<cfloop list="#request.q_getForm.EDITFIELDKEYVALUE2#" index="thisKeyField2">
		<!--- This is an xpath query which will return the input type from the datadef for the column we are looking at --->
		<cfset thisXmlPos = XmlSearch(thisDataDef,"/datadefinition/item[fieldname='#lCase(thisKeyField2)#']/datatype")>
		<cfif ArrayLen(thisXmlPos) EQ 1>
			<!---
				if the datatype is a text, or ntext field we need to add it to the cast list 
				so that the orderby statement will cast it as a varchar and allow us to order it.
			 --->
			<cfif thisXmlPos[1].XmlText EQ 'text' OR thisXmlPos[1].XmlText EQ 'nText'>
				<cfset CastAsVarcharlist = ListAppend(CastAsVarcharlist, lCase(thisKeyField2), ',')>
			</cfif>
		</cfif>
	<!--- 	<cfoutput>
			XPATH for #thisKeyField2#: /datadefinition/item[fieldname='#lCase(thisKeyField2)#']/datatype
			<br />#thisXmlPos[1].XmlName# :: #thisXmlPos[1].XmlText#
		</cfoutput>
		<cfdump var="#thisXmlPos#"> --->
	</cfloop>
</cfif>
<!--- DRK not used ?--->
<cfset NoSorTypeList="text">

<!--- DRK 2 lines instead of one? --->
<cfset defaultSelectaction="detailView">
<cfparam name="selectaction" default="#defaultSelectaction#">

<cfparam name="maxRecords" default=60>
<cfparam name="maxRows" default="3">
<cfset rowNum=0>
<cfset colNum=0>

<!--- DRK should this path include /media ?? NOT USED --->
<cfset request.filterImages="#application.installurl#/images/formInstanceFilter">

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

<cfparam name="queryFilter" default="">
<!--- Build sort string --->
<cfset newQueryString="">
<cfif listLen(CGI.QUERY_STRING,"&")>
	<cfloop list="#CGI.QUERY_STRING#" index="q" delimiters="&">
		<cfif listFirst(q,"=") NEQ "sort">
			<cfset newQueryString=listAppend(newQueryString,q,"&")>
		</cfif>
	</cfloop>
</cfif>
<!--- Build search string --->
<cfset searchQueryString="">
<cfif listLen(CGI.QUERY_STRING,"&")>
	<cfloop list="#CGI.QUERY_STRING#" index="q" delimiters="&">
		<cfif listFirst(q,"=") NEQ "selectaction">
			<cfset searchQueryString=listAppend(searchQueryString,q,"&")>
		</cfif>
	</cfloop>
</cfif>

<!--- DRK detailView is default --->
<cfif selectaction eq "detailView">
	<cfset keyvalue=request.q_getForm.editFieldKeyValue2>
	<cfset fullKeyValueList=request.q_getForm.editFieldKeyValue2>
	<cfif request.q_getForm.useWorkFlow EQ 1>
		<cfset fullKeyValueList=fullKeyValueList&",Status,Version">
	</cfif>
	<cfloop list="#keyvalue#" index="s">
		<cfset "sort#s#"="DESC">
	</cfloop>
	<cfif isDefined("url.sort")>
		<cfset sortvalue=urldecode(url.sort)>
		<cfset "sort#listFirst(urldecode(url.sort),' ')#"=listLast(urldecode(url.sort)," ")>
	<cfelse>
		<cfset sortvalue=request.q_getForm.editFieldSortOrder2>
	</cfif>
<cfelse>
	<!--- DRK listView --->
	<cfset keyvalue=request.q_getForm.editFieldKeyValue>
	<cfset sortvalue=request.q_getForm.editFieldSortOrder>
	<!--- DRK possible treeView would go here ? --->
</cfif>
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
			<cfif NOT listfindnocase(compositetablelist,a_formelements[i]['SOURCEFORMOBJECTID']) AND ListFindNoCase(keyvalue,a_formelements[i].fieldname)>
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
<cfif APPLICATION.getPermissions("remove",session.i3currenttool) AND request.q_getForm.bulkdelete EQ 1>
	<cfset request.deletePerms=1>
<cfelse>
	<cfset request.deletePerms=0>
</cfif>
<cfparam name="form.search" default="">
<cfoutput>
<div id="socketformheader">
	<h2>#request.q_getForm.label#</h2>
</div><div style="clear:both";></div>
<div class="subtoolheader" style="padding-bottom:0;">
	<div id="leftBtns" style="float:left; width:50%;">
	 <cfif selectaction EQ "listing">
		<a href="#request.page#?selectaction=detailView&#searchQueryString#" title="View Details"><img src="#application.globalPath#/media/images/icon_detail.gif" border="0"></a>
	 <cfelse>
		<a href="#request.page#?selectaction=listing&#searchQueryString#" title="View as List"><img src="#application.globalPath#/media/images/icon_list.gif" border="0"></a>
	</cfif>
	<cfif APPLICATION.getPermissions("addedit",session.i3currenttool)>
		<a href="#request.page#?formstep=showform&displayform=1"><img src="#application.globalPath#/media/images/icon_addFile.gif" border="0" title="Add new #request.q_getForm.label# item."/></a>
		<cfif request.q_getForm.useOrdinal eq 1>
			<a href="#request.page#?formstep=ordinalForm&formobjectid=#request.q_getForm.formobjectid#"><img src="#application.globalPath#/media/images/icon_ordinal.gif" border="0" title="Modify order of #request.q_getForm.label#" /></a>
		</cfif>
		<cfset allowExport = false>
		<cfloop from="1" to="#arrayLen(session.user.tools)#" index="toolindex">
			<cfif (session.user.tools[toolindex][1] EQ request.q_getForm.formobjectid) AND (session.user.tools[toolindex][2].access EQ 1)>
				<cfset allowExport = true>
			</cfif>
		</cfloop>
		<cfif allowExport>
			<a href="#request.page#?excelExport=1&formobjectid=#request.q_getForm.formobjectid#"><img src="#application.globalPath#/media/images/icon_exportExcel.gif" border="0" title="Export #request.q_getForm.label# data for Excel" /></a>
		</cfif>
		<cfif isDefined('request.q_getForm.useMappedContent') AND request.q_getForm.useMappedContent eq 1>
			<a href="##" onclick="window.open('/admintools/includes/i_ContentMapping.cfm?formstep=showform&associaterole=1','MapContent','menubar=no,statusbar=no,resizable,width=600,height=400')"><img src="#application.installurl#/admintools/media/images/icon_mapping.gif" border="0" title="Modify mappings of #request.q_getForm.label# items" /></a>
		</cfif>	
	</cfif>
	</div>
<div id="searchWrapper" style="float:right; width:50%;">
<form action="#request.page#" method="get" name="form1" id="form1" style="margin-bottom: 0px; margin-left: 0px; margin-right: 0px; margin-top: 0px; float: right;">
		<script type="text/javascript">
			function swapField(o){
				for(i=0 ; i<o.options.length ; i++){
					document.getElementById(o.options[i].value).style.display = "none";
				}
				document.getElementById(o.value).style.display = "inline";
			}
		</script>
		<input type="Hidden" name="search" value="1">
		<input type="Hidden" name="selectaction" value="#selectaction#">
		<input type="hidden" name="formname" value="#request.q_getForm.formname#">
		<select id="searchField" onchange="javascript:swapField(this);" style="position:relative;top:-7px;">
		<cfloop list="#request.q_getForm.editFieldKeyValue2#" index="i">
			<!--- loop to find label --->
			<cfloop index="t" from="1" to="#arrayLen(request.a_formelements)#">
				<cfif structFind(request.a_formelements[t],"fieldname") eq i>
					<cfset thisKey=request.a_formelements[t].objectlabel>
					<cfbreak>
				<cfelse>
					<cfset thisKey=i>
				</cfif>
			</cfloop>
			<option value="search_#i#">#thisKey#</option>
		</cfloop>
		</select>
		<cfset rowCount=1>
		<cfloop list="#request.q_getForm.editFieldKeyValue2#" index="i">
			<!--- loop to find label --->
			<cfloop index="t" from="1" to="#arrayLen(request.a_formelements)#">
				<cfif structFind(request.a_formelements[t],"fieldname") eq i>
					<cfset thisKey=request.a_formelements[t].objectlabel>
					<cfbreak>
				<cfelse>
					<cfset thisKey=i>
				</cfif>
			</cfloop>
			<div id="search_#i#" <cfif rowCount EQ 1>style="display:inline;"<cfelse>style="display:none;"</cfif>><input type="text" name="#i#" <cfif isdefined("url.#i#")>value="#evaluate('url.#i#')#" </cfif>size="25" style="position:relative;top:-7px;"></div>
			<cfset rowCount=rowCount+1>
		</cfloop>
<input name="Search" type="image" value="Search"  src="#APPLICATION.globalpath#/media/images/icon_search.gif" />
</form>
</div>
<div style="clear:both"></div>
</div>
<table id="socketindextable" border="0" cellspacing="0" cellpadding="0">
	</cfoutput>

<cfswitch expression="#selectaction#">
<!--- Display in column view with sort functionality --->
<cfcase value="detailView">
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

		<!--- Adds code to check for Active fields and puts in abilty to hide inactive items etc --->
		<cfif FindNoCase('<FIELDNAME>active</FIELDNAME>', REQUEST.q_getform.datadefinition)>
			<cfif IsDefined('URL.setActive')>
				<cfset SESSION.thisSetActive = URL.setActive>
			</cfif>
			<cfif IsDefined('FORM.setActive')>
				<cfset SESSION.thisSetActive = FORM.setActive>
			</cfif>
			<cfif ISDefined('SESSION.thisSetActive') AND SESSION.thisSetActive EQ 1>
				<cfif Len(whereclause)>
					<cfset whereclause = whereclause & ' AND '>
				</cfif>
				<cfset whereclause = whereclause & '[#request.q_getForm.datatable#].active=#SESSION.thisSetActive#'>
			<cfelseif  ISDefined('SESSION.thisSetActive') AND SESSION.thisSetActive EQ 0>
				<cfset whereclause = whereclause>
			<!---<cfelse>
				<cfif Len(whereclause)>
					<cfset whereclause = whereclause & ' AND '>
				</cfif>
				 <cfset whereclause = whereclause & '#request.q_getForm.datatable#.active=1'> --->
			</cfif>
		</cfif>

		<cfset newKeyValue="">
		<cfset newKeyValue2="">
		<!--- DRK CFC candidates? return type Boolean?--->
		<!--- 12/07/2006 DRK use composite trimmed keyvalue instead --->
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
					<!---
						ERJ MOD: 1/23/06
						Need to make removeKeyValue a list so that it will handle multiple <tablename>id fields
					--->
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
			<cfif isDefined("url.#i#") AND len(evaluate('url.'&i))>
				<cfif len(whereclause)>
					<cfset whereclause=whereclause&" AND ">
				</cfif>
				<cfif findnocase("date",i)>
					<cfset whereClause=whereclause&"[#request.q_getForm.datatable#].#i# < #dateadd("d",1,urlDecode(evaluate('url.'&i)))# AND [#request.q_getForm.datatable#].#i# >#dateadd("d",0,urlDecode(evaluate('url.'&i)))#">
				<cfelse>
					<!--- check to see if its an id field, may need to check another table name field --->
					<cfif LCase(Right(i,2)) eq 'id'>
						<cfset thistable = Left(i,Len(i)-2)>
						<cfset thistablename = thistable & 'name'>
						<cfset whereClause=whereclause&"[#thistable#].#thistablename# LIKE '%#urlDecode(evaluate('url.'&i))#%'">
					<cfelse>
						<cfset whereClause=whereclause&"[#request.q_getForm.datatable#].#i# LIKE '%#urlDecode(evaluate('url.'&i))#%'">
					</cfif>
					<!--- CMC: need to have table defined in case join causes ambiguous column names
					<cfset whereClause=whereclause&"#i# LIKE '%#urlDecode(evaluate('url.'&i))#%'"> --->
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
		<cfset qualifiedSelectList="">
		<!--- 12/07/2006 DRK use composite trimmed keyvalue instead --->
		<!--- <cfloop list="#request.q_getForm.editFieldKeyValue2#" index="j"> --->
		<cfloop list="#fieldlistnoForeign#" index="j">
			<cfset qualifiedSelectList=listAppend(qualifiedSelectList,"[#request.q_getForm.datatable#].#j#",",")>
		</cfloop>		
				
		<cfset selectClause=listAppend(selectClause,"#qualifiedSelectList#")>
					
			<!--- GEOMOD 030811 - check of AmbiguousList and append the tablename to the beginning --->
				<cfif isDefined("url.sort")>
					<cfset orderVar=urldecode(url.sort)>
					<!--- 12/07/2006 remove composite fields from sort START --->
					<cfif isDefined('request.q_getForm.compositeForm') AND (request.q_getForm.compositeForm EQ 1)>
						<cfloop list="#compositetablelist#" index="i">
							<cfloop list="#compositekey[i]#" index="j">
								<cfif findnocase(#j#, orderVar)>
									<cfset compositesortvalue = orderVar>
									<cfset orderVar = "">
								</cfif>
							</cfloop>
						</cfloop>
					</cfif>
					<!--- 12/07/2006 remove composite fields from sort END --->
				<cfelse>
					<cfset orderVar=SortValue>
				</cfif>		
				<cfif isDefined('removeKeyValue')>
					<cfif FindNoCase(removeKeyValue,orderVar,1)>
						<cfset orderVar = replaceNoCase(orderVar,removeKeyValue,newSearchKeyValue,"all")>
					</cfif>
				</cfif>
				<cfloop list="#AmbiguousList#" index="thisAmbItem">
				<!--- 
					ERJ NOTE: 4-14-2006
					Possible regex to check to ambigious title fields but ignore things like short title, long title etc
					(?<![ ])title
					Need to implement and test.				
				--->
						<cfif ListContains(CastAsVarcharlist,thisAmbItem)>
							<cfset orderVar=replaceNoCase(orderVar,"#thisAmbItem# ","CAST(#request.q_getForm.datatable#.#thisAmbItem# AS VarChar(100)) ")>
						<cfelse>
							<cfset orderVar=replaceNoCase(orderVar,"#thisAmbItem# ","#request.q_getForm.datatable#.#thisAmbItem# ")>
						</cfif>
				</cfloop>
			<!--- /GEOMOD 030811 - check of AmbiguousList and append the tablename to the beginning --->
			<!--- DRK cfc candidate --->
			<cfset q_getKeyFields=formInstanceObj.getFormData(selectClause=selectClause,fromClause=fromClause,whereclause=whereclause,orderVar=orderVar)>
			<!--- 12/06/2006 DRK add composite form prefill functionality START --->
			<!--- composite form? using keys from foreign tables? --->
			<cfif isDefined('request.q_getForm.compositeForm') AND (request.q_getForm.compositeForm EQ 1) AND listLen(compositetablelist)>
				<cfset formProcessObj = CreateObject('component','#application.cfcpath#.formprocess')>
				<!--- Initialize arrays for column insertion variable --->
				<cfloop list="#compositetablelist#" index="j">
					<cfloop list="#compositekey[j]#" index="fieldName">
						<cfset "a_#fieldName#" = arrayNew(1)>
					</cfloop>
				</cfloop>
				<cfset formProcessObj = CreateObject('component','#application.cfcpath#.formprocess')>
				<cfset q_tableList = formProcessObj.getTablesFromIDs(formObjectIds=compositetablelist)>
				<!--- loop through each record to add necessary fields from foreign tables --->
				<cfloop query="q_getKeyFields">
					<cfset currentID = evaluate('q_getKeyFields.'&request.q_getForm.datatable&'id')>
					<!--- loop through the foreign data set --->
					<cfloop query="q_tableList" >
						<!--- check to see if we have values set for these ids --->
						<cfquery name="q_getForeignKey" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT #q_tableList.datatable#ID
							FROM #request.q_getForm.datatable#
							WHERE isNull(#q_tableList.datatable#ID,0) <> 0 AND (#q_tableList.datatable#ID <> '') AND ("#request.q_getForm.datatable#ID" = #currentID#)
						</cfquery>
						<cfif (q_getForeignKey.recordcount GT 0) AND listLen(compositekey[q_tableList.formobjectid])>
							<!--- get the foreign table data using only the fields that are used --->
							<cfset selectClause = compositekey[q_tableList.formobjectid]>
							<cfset fromClause = q_tableList.datatable>
							<cfset whereClause ="#q_tableList.datatable#ID = "&evaluate('q_getForeignKey.'&q_tableList.datatable&'ID')>
							<!--- 12/19/2006 DRK Replace out foreign data that has lookup assigned START--->
							<cfloop list="#compositekey[q_tableList.formobjectid]#" index="i">
								<cfif right(i,2) EQ "id">
									<cfset thisTable=removeChars(i,len(i)-1,2)>
									<cfset thisDisplay="[#thisTable#].#thisTable#name">
									<cfset thisDisplayField="#thisTable#name">
									<cfset thisKey=i>
									<!--- check to see if assignment for table lookup made locally --->
									<cfloop index="t" from="1" to="#arrayLen(request.a_formelements)#">
										<cfif structFind(request.a_formelements[t],"fieldname") EQ i>
											<cfif findnocase(request.a_formelements[t].LOOKUPTYPE,"table") AND len(trim(request.a_formelements[t].LOOKUPTABLE))>
												<cfset thisTable=request.a_formelements[t].LOOKUPTABLE>
												<cfif len(trim(request.a_formelements[t].LOOKUPKEY))>
													<cfset thisKey=request.a_formelements[t].LOOKUPKEY>
												</cfif>
												<cfif len(trim(request.a_formelements[t].LOOKUPDISPLAY))>
													<cfset thisDisplay="[#thisTable#].#request.a_formelements[t].LOOKUPDISPLAY#">
													<cfset thisDisplayField="#request.a_formelements[t].LOOKUPDISPLAY#">
												</cfif>
												<cfif formInstanceObj.isTableValid(keyField=thisKey,tableName=thisTable,displayField=thisDisplayField)>
													<cfset selectClause = replacenocase(selectClause,i,"#thisDisplay# AS #i#","all")>
													<cfset fromClause = fromClause&" LEFT JOIN [#thisTable#] ON  [#q_tableList.datatable#].#i#=[#thisTable#].#thisKey#">
												</cfif>
											</cfif>
											<cfset localLookupFound = 1>
											<cfbreak>
										</cfif>
									</cfloop>
									<!--- check to see if assignment for table lookup made in foreign table --->
									<cfif NOT (isDefined('localLookupFound') AND localLookupFound)>
										<cfquery name="q_getForeignDataStruct" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
											SELECT datadefinition, formobjectid
											FROM formobject
											WHERE (datatable = '#q_tableList.datatable#') AND (formobjectid = parentid)
										</cfquery>
										<!--- deserialize data --->
										<cfset a_formelements = structNew()>
										<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
											input="#q_getForeignDataStruct.datadefinition#"
											output="a_formelements">
										<!--- check for lookup table assignment --->
										<cfloop index="t" from="1" to="#arrayLen(a_formelements)#">
											<cfif structFind(a_formelements[t],"fieldname") EQ i>
												<cfif findnocase(a_formelements[t].LOOKUPTYPE,"table") AND len(trim(a_formelements[t].LOOKUPTABLE))>
													<cfset thisTable=a_formelements[t].LOOKUPTABLE>
													<cfif len(trim(a_formelements[t].LOOKUPKEY))>
														<cfset thisKey=a_formelements[t].LOOKUPKEY>
													</cfif>
													<cfif len(trim(a_formelements[t].LOOKUPDISPLAY))>
														<cfset thisDisplay="[#thisTable#].#a_formelements[t].LOOKUPDISPLAY#">
														<cfset thisDisplayField="#a_formelements[t].LOOKUPDISPLAY#">
													</cfif>
													<cfif formInstanceObj.isTableValid(keyField=thisKey,tableName=thisTable,displayField=thisDisplayField)>
														<cfset selectClause = replacenocase(selectClause,i,"#thisDisplay# AS #i#","all")>
														<cfset fromClause = fromClause&" LEFT JOIN [#thisTable#] ON  [#q_tableList.datatable#].#i#=[#thisTable#].#thisKey#">
													</cfif>
												</cfif>
												<cfbreak>
											</cfif>
										</cfloop>
									</cfif>
								</cfif>
							</cfloop>
							<!--- 12/19/2006 DRK Replace out foreign data that has lookup assigned END--->
							<!--- grab foreign instance data --->
							<cfset q_foreignInstanceData = formprocessObj.getFormData(selectClause=selectClause,fromClause=fromClause,whereClause=whereClause)>
							<!--- assign foreign data to array scope --->
							<cfloop list="#q_foreignInstanceData.columnlist#" index="fieldName">
								<cfset thisArray = evaluate("a_#fieldName#")>
								<cfset thisArray[q_getKeyFields.currentrow] =evaluate('q_foreignInstanceData.'&fieldName)>
								<cfset "a_#fieldName#" = thisArray>
							</cfloop>
						<cfelse>
							<!--- assign empty data to array scope --->
							<cfloop list="#compositekey[q_tableList.formobjectid]#" index="fieldName">
								<cfset thisArray = evaluate("a_#fieldName#")>
								<cfset thisArray[q_getKeyFields.currentrow] = "">
								<cfset "a_#fieldName#" = thisArray>
							</cfloop>
						</cfif>
					</cfloop>
				</cfloop>
				<!--- assign foreign data array to query scope --->
				<cfloop list="#compositetablelist#" index="j">
					<cfloop list="#compositekey[j]#" index="fieldName">
						<cfset thisArray = evaluate("a_#fieldName#")>
						<cfset blah = QueryAddColumn(q_getKeyFields,fieldName,evaluate("a_#fieldName#")) >
					</cfloop>
				</cfloop>
				<!--- apply sorting rules for composite key values --->
				<cfif len(trim(compositesortvalue))>
					<cfquery name="sorted_q_getKeyFields" dbtype="query" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT *
						FROM q_getKeyFields
						ORDER BY #compositesortvalue#
					</cfquery>
					<cfset q_getKeyFields = sorted_q_getKeyFields>
				</cfif>
				<!--- apply filtering --->
				<cfset whereClause="">
				<!--- build where condition --->
				<cfloop query="q_tableList">
					<cfloop list="#compositekey[q_tableList.formobjectid]#" index="fieldName">
						<cfif isDefined("url.#fieldName#") AND len(evaluate('url.'&fieldName))>
							<cfif len(whereClause)>
								<cfset whereClause=whereClause&" AND ">
							</cfif>
							<cfset thisMatchString = "'%#lcase(urlDecode(evaluate('url.'&fieldName)))#%'">
							<cfset whereClause=whereClause&"LOWER(#fieldName#) LIKE #thisMatchString#">
						</cfif>
					</cfloop>
				</cfloop>
				<cfif len(trim(whereClause))>
					<!--- perform filter --->
					<cfquery name="filtered_q_getKeyFields" dbtype="query" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT *
						FROM q_getKeyFields
						WHERE #preservesinglequotes(whereClause)#
					</cfquery>
					<cfset q_getKeyFields = filtered_q_getKeyFields>
				</cfif>
			</cfif>
			<!--- 12/06/2006 DRK add composite form prefill functionality END --->
		<cfif q_getKeyFields.recordcount>
			<cfif ISDefined('FORM.setActive') and FORM.setActive EQ 0 OR ISDefined('SESSION.thisSetActive') and SESSION.thisSetActive EQ 0 >
				<cfset checkBoxValue = 1>
			<cfelse>
				<cfset checkBoxValue = 0>
			</cfif>
			<cfif ISDefined('FORM.setActive') AND FORM.setActive EQ 1 OR  ISDefined('SESSION.thisSetActive') and SESSION.thisSetActive EQ 1 >
				<cfset checkedAllValue = ''>
				<cfset checkedActiveValue = 'checked'>
			<cfelseif NOT IsDefined('FORM.setActive') AND NOT IsDefined('SESSION.thisSetActive')>
				<cfset checkedAllValue = 'checked'>
				<cfset checkedActiveValue = ''>
			<cfelse>
				<cfset checkedAllValue = 'checked'>
				<cfset checkedActiveValue = ''>
			</cfif> 
			<!--- DRK custom tag candidates? alternative for tree view? --->
			<cfif FindNoCase('<FIELDNAME>active</FIELDNAME>', REQUEST.q_getform.datadefinition)>
				<cfoutput><form action="#request.page#" method="post" name="viewActive"><input type="hidden" name="displayForm" value="5"><input type="hidden" name="setActive" value="#checkBoxValue#">
					<tr>
						<td>
							<input name="setActiveCheck" type="radio" value="0" onclick="document.viewActive.submit();" #checkedAllValue#> View All Items
							<input name="setActiveCheck" type="radio" value="1" onclick="document.viewActive.submit();" #checkedActiveValue#> View Active Items</td>
						<td align="right">#q_getKeyFields.recordcount# Record<cfif q_getKeyFields.recordcount GT 1>s</cfif> Found.</td>
					</tr></form>
				</cfoutput>
			<cfelse>
				<cfoutput>
					<tr>
						<td colspan="2" align="right">#q_getKeyFields.recordcount# Record<cfif q_getKeyFields.recordcount GT 1>s</cfif> Found.</td>
					</tr>
				</cfoutput>
			</cfif>
		</cfif>

		<cfif q_getKeyFields.recordcount EQ 1 AND isDefined("url.search")>
			<cflocation url="#request.page#?instanceid=#evaluate('q_getKeyFields.#request.q_getForm.datatable#ID')#&formstep=showform">
		<cfelseif request.q_getForm.singleRecord EQ 1 AND q_getKeyFields.recordcount EQ 1>
			<cflocation url="#request.page#?instanceid=#evaluate('q_getKeyFields.#request.q_getForm.datatable#ID')#&formstep=showform">
		<cfelseif request.q_getForm.singleRecord EQ 1 AND q_getKeyFields.recordcount EQ 0>
			<cflocation url="#request.page#?formstep=showform">
		</cfif>
	<!--- DRK cfparam move --->
	<cfparam name="attributes.page_size" default="#val(maxRecords\3)#">
	<cfmodule template="#application.customtagpath#/previous_next.cfm" query="#q_getKeyFields#" query_name="thisList" page_size="#attributes.page_size#">
	<cfloop from="1" to="#maxRows#" step="1" index="colCt">
		<cfif thisList.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
			<cfset rowNum=round(thisList.recordcount/colCt)>
			<cfset colNum=colCt>
		</cfif>
	</cfloop>
	<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
	<!--- DRK custom tag candidate --->
<cfif isDefined("successMsg")>
	<tr>
		<td colspan="2" class="successmsg" align="center"><cfoutput>#successMsg#</cfoutput></td>
	</tr>
</cfif>
	<cfoutput>
<cfif request.deletePerms>
	<!--- DRK added type attrib (this code used twice)--->
	<script language="JavaScript" type="text/javascript">
	var checkflag = "false";
	function check(field) {
	if (checkflag == "false") {
	for (i = 0; i < field.length; i++) {
	field[i].checked = true;}
	checkflag = "true";
	return "Uncheck All"; }
	else {
	for (i = 0; i < field.length; i++) {
	field[i].checked = false; }
	checkflag = "false";
	return "Check All"; }
	}
	</script>
</cfif>
<!--- DRK listing logic custom tag?--->
<cfif thisList.recordcount>
	<tr>
		<td colspan="2" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="1">
	<cfif request.deletePerms AND request.q_getForm.useWorkFlow EQ 0>
		<form action="#request.page#" method="post" name="deleteEntries" id="deleteEntries">
		<!--- GEOMOD 030808 - wrapped formstep below with isDefined to cover bulk delete press
				that goes across without any items being checked (line 300 formprocess.cfm) --->
		<cfif NOT isDefined("formstep")><input type="hidden" name="formstep" value="confirm"></cfif>
		<input type="hidden" name="deleteInstance" value="">
		<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="displayform,confirmedDeleteList,deleteList">
	</cfif>
	<tr class="columnheaderrow">
		<cfif request.deletePerms AND request.q_getForm.useWorkFlow EQ 0><td class="deleteRow" style="background:none;"><img src="#application.globalPath#/media/images/icon_delete.gif" title="Select check box for deletion."/></td></cfif>
		<!--- use full listing for search fields --->
		<cfloop list="#fullKeyValueList#" index="i">
			<!--- dood - this puts the label instead of the column name --->
			<cfloop index="t" from="1" to="#arrayLen(request.a_formelements)#">
				<cfif structFind(request.a_formelements[t],"fieldname") eq i>
					<cfset thisKey=request.a_formelements[t].objectlabel>
					<cfbreak>
				<cfelse>
					<cfif NOT (i EQ "name")>
						<cfset thisKey=application.CapFirst(replaceNoCase(i,"name","","all"))>
					<cfelse>
						<cfset thisKey=application.CapFirst(i)>
					</cfif>
				</cfif>
			</cfloop>
		<td class="formiteminput"<cfif isDefined('url.sort') AND findNoCase(i,url.sort)> style="background-color: 749BAD;"</cfif>><a href="#request.page#?sort=<cfif isDefined('sort#i#') AND evaluate('sort#i#') EQ "ASC">#urlencodedformat("#i# DESC")#<cfelse>#urlencodedformat("#i# ASC")#</cfif><cfif len(newQueryString)>&#newQueryString#</cfif>"><strong>#APPLICATION.stripHTML(thisKey)#</strong></a></td>
		</cfloop>
	<!--- CMC MOD 05/24/06: content elements & display handlers: add "in use" column (check to see if attached to a page component)--->
		<cfif request.q_getForm.datatable eq "contentobject" OR request.q_getForm.datatable eq "displayhandler">
			<td class="formiteminput"><strong>In Use</strong> </td>
		</cfif>
	</tr>
		<cfset thiscount = 1>
		<cfloop query="thisList">
			<cfif thiscount MOD 2><cfset rowclass="oddrow"><cfelse><cfset rowclass="evenrow"></cfif>
			<tr class="#rowclass#">
				<cfif request.deletePerms AND request.q_getForm.useWorkFlow EQ 0><td class="deleteRow"><input type="checkbox" name="deleteInstance" value="#evaluate('thisList.#request.q_getForm.datatable#id')#" style="margin: 0px 0px 0px 0px;"></td></cfif>
				<!--- use full listing for table columns/fields --->
				<cfloop list="#fullKeyValueList#" index="i">
					<!--- this puts the label instead of the column name --->
					<cfloop index="t" from="1" to="#arrayLen(request.a_formelements)#">
						<!--- date format --->
						<cfif structFind(request.a_formelements[t],"fieldname") eq i>
							<cfif request.a_formelements[t].datatype EQ "datetime">
								<cfset thisVal="#DateFormat(evaluate('thisList.'&i),'m/d/yyyy')# #TimeFormat(evaluate('thisList.'&i),'h:mm TT')#">
								<cfbreak>
							</cfif>
							<!--- Checks to see if this is a bit datatype so we can convert it from a 1 / 0 to a yes / no --->
							<cfif request.a_formelements[t].datatype EQ 'bit'>
								<cfset isBit = "True">
							<cfelse>
								<cfset isBit = "False">
							</cfif>
							<cfif request.a_formelements[t].lookuptype EQ 'list'>
								<cfloop list="#structFind(request.a_formelements[t],'lookuplist')#" delimiters=";" index="listItem">
									<cfif evaluate("thisList."&i) EQ listFirst(listItem)>
										<cfset thisVal=listLast(listItem)>
										<cfbreak>
									</cfif>
								</cfloop>
								<cfbreak>
							</cfif>
						<cfelse>
							<cfset thisVal=evaluate("thisList."&i)>
						</cfif>
					</cfloop>
					<td><a href="#request.page#?instanceid=#evaluate('thisList.#request.q_getForm.datatable#ID')#&displayForm=1&formstep=showform"><cfif thisVal EQ 1 AND isBit EQ "True">Yes<cfelseif thisVal EQ 0 AND isBit EQ "True">No<cfelse>#thisVal#</cfif></a></td>
				</cfloop>
	<!--- CMC MOD 05/24/06: content elements & display handlers: add "in use" column (check to see if attached to a page component)--->
			<cfif request.q_getForm.datatable eq "contentobject" OR request.q_getForm.datatable eq "displayhandler">
				<!--- query to see if content element/display handler is attached to a container --->
				<cfset q_getAssignment=formInstanceObj.getFormData(selectClause="#request.q_getForm.datatable#id",fromClause="pagecomponent",whereclause="#request.q_getForm.datatable#id = #evaluate('thisList.#request.q_getForm.datatable#ID')#")>
				<td align="center"><img src="#application.globalPath#/media/images/icon_<cfif NOT q_getAssignment.recordcount>in</cfif>complete.gif" /></td>
			</cfif>
			</tr>
			<cfset thiscount = thiscount + 1>
		</cfloop>
		<!--- <cfdump var="#thisList#"> --->
	<cfif request.q_getForm.useWorkFlow EQ 1>
		<cfif request.q_getForm.datatable eq "contentobject" OR request.q_getForm.datatable eq "displayhandler">
			<cfset thisSpan = 2>
		<cfelse>
			<cfset thisSpan = 1>
		</cfif>
	<cfelse>
		<cfset thisSpan = 0>
	</cfif>
	<cfif page_count GT 1>
	<tr>
		<td align="center" colspan="#val(listLen(keyvalue)+1+thisSpan)#">
		<div id="pagingControls">&lt;#prev_link# Page #page_no# of #page_count#  :   #pages_link# #next_link#&gt;</div>
		</td>
	</tr>
	</cfif>
	<tr>
		<cfif request.deletePerms AND request.q_getForm.useWorkFlow EQ 0>
			<!--- CMC MOD 05/24/06: determine colspan if "in use" col is displayed--->
			<cfif request.q_getForm.datatable eq "contentobject" OR request.q_getForm.datatable eq "displayhandler">
				<cfif request.q_getForm.useWorkFlow EQ 1>
					<cfset thisColSpan = val(listLen(thisList.columnlist)+2)>
				<cfelse>
					<cfset thisColSpan = val(listLen(thisList.columnlist)+1)>
				</cfif>
			<cfelse>
				<cfset thisColSpan = val(listLen(thisList.columnlist))>
			</cfif>
			<td class="formiteminput" align="center" colspan="#thisColSpan#">
				<input type=button value="Check All" onclick="this.value=check(this.form.deleteInstance)" class="submitbutton" style="width:100">
				<input type="submit" name="deleteEm" value="Delete Selected" class="submitbutton" style="width:130"></form></td></cfif>
		
	</tr>
	</table>
		</td>
	</tr>
	<cfelse>
		<tr>
			<td colspan="#val(listLen(keyvalue)+1)#">There are currently no items. Click the (+) button above to begin.</td>
		</tr>
	</cfif>
	</cfoutput>
	<!--- </table> --->
	</cfmodule>
</cfcase>
<!--- href list of item choices --->
<cfcase value="listing">

		<cfif isDefined("securitySelect")>
			<!--- 12/07/2006 DRK use composite trimmed keyvalue instead --->
			<!--- <cfset selectClause="#securitySelect#,#request.q_getForm.datatable#.#request.q_getForm.datatable#ID, #request.q_getForm.editFieldKeyValue#"> --->
			<cfset selectClause="#securitySelect#,#request.q_getForm.datatable#.#request.q_getForm.datatable#ID, #KeyValue#">
		<cfelse>
			<cfset selectClause="#request.q_getForm.datatable#.#request.q_getForm.datatable#ID, #request.q_getForm.editFieldKeyValue#">
			<!--- <cfset selectClause="#request.q_getForm.datatable#.#request.q_getForm.datatable#ID, #request.q_getForm.editFieldKeyValue#"> --->
			<cfset selectClause="#request.q_getForm.datatable#.#request.q_getForm.datatable#ID, #KeyValue#">
		</cfif>
		<cfif isDefined("securityFrom")>
			<cfset fromClause="#request.q_getForm.datatable##securityFrom#">
		<cfelse>
			<cfset fromClause="#request.q_getForm.datatable#">
		</cfif>
		<cfif isDefined("securityWhere")>
			<cfset whereClause="#securityWhere#">
		<cfelse>
			<cfset whereClause="">
		</cfif>

		<cfloop list="#request.q_getForm.editFieldKeyValue#" index="i">
			<cfif isDefined("url.#i#") AND len(evaluate('url.'&i))>
				<cfif len(whereclause)>
					<cfset whereclause=urlDecode(whereclause)&" AND ">
				</cfif>
				<cfset whereclause=whereclause&"#i# LIKE '%#evaluate('url.'&i)#%'">
			</cfif>
		</cfloop>
		<cfif request.q_getForm.RestrictByUserType eq 1>
				<cfif len(whereclause)>
					<cfset whereclause=urlDecode(whereclause)&" AND ">
				</cfif>
			<cfset whereclause = whereclause & "(restrictByUserTypeId = #session.user.usertypeid#)">
		</cfif>

		<!--- DRK cfc candidate --->
		<cfif isDefined("url.sort")>
			<cfset orderVar = urldecode(url.sort)>
			<cfif isDefined('request.q_getForm.compositeForm') AND (request.q_getForm.compositeForm EQ 1)>
				<cfloop list="#compositetablelist#" index="i">
					<cfloop list="#compositekey[i]#" index="j">
						<cfif findnocase(#j#, orderVar)>
							<cfset compositesortvalue = orderVar>
							<cfset orderVar = "">
						</cfif>
					</cfloop>
				</cfloop>
			</cfif>
		<cfelse>
			<cfset orderVar = SortValue>
		</cfif>
		<cfset q_getKeyFields=formInstanceObj.getFormData(selectClause=selectClause,fromClause=fromClause,whereclause=whereclause,orderVar=orderVar)>
		<!--- 12/07/2006 DRK add composite form prefill functionality START --->
		<!--- composite form? using keys from foreign tables? --->
		<cfif isDefined('request.q_getForm.compositeForm') AND (request.q_getForm.compositeForm EQ 1) AND listLen(compositetablelist)>
			<cfset formProcessObj = CreateObject('component','#application.cfcpath#.formprocess')>
			<!--- Initialize arrays for column insertion variable --->
			<cfloop list="#compositetablelist#" index="j">
				<cfloop list="#compositekey[j]#" index="fieldName">
					<cfset "a_#fieldName#" = arrayNew(1)>
				</cfloop>
			</cfloop>
			<cfset formProcessObj = CreateObject('component','#application.cfcpath#.formprocess')>
			<cfset q_tableList = formProcessObj.getTablesFromIDs(formObjectIds=compositetablelist)>
			<!--- loop through each record to add necessary fields from foreign tables --->
			<cfloop query="q_getKeyFields">
				<cfset currentID = evaluate('q_getKeyFields.'&request.q_getForm.datatable&'id')>
				<!--- loop through the foreign data set --->
				<cfloop query="q_tableList" >
					<!--- check to see if we have values set for these ids --->
					<cfquery name="q_getForeignKey" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT #q_tableList.datatable#ID
						FROM #request.q_getForm.datatable#
						WHERE isNull(#q_tableList.datatable#ID,0) <> 0 AND ("#q_tableList.datatable#ID" <> '') AND ("#request.q_getForm.datatable#ID" = #currentID#)
					</cfquery>
					<cfif (q_getForeignKey.recordcount GT 0) AND listLen(compositekey[q_tableList.formobjectid])>
					<!--- get the foreign table data using only the fields that are used --->
						<cfset selectClause = compositekey[q_tableList.formobjectid]>
						<cfset fromClause = q_tableList.datatable>
						<cfset whereClause ="#q_tableList.datatable#ID = "&evaluate('q_getForeignKey.'&q_tableList.datatable&'ID')>
						<!--- grab foreign instance data --->
						<cfset q_foreignInstanceData = formprocessObj.getFormData(selectClause=selectClause,fromClause=fromClause,whereClause=whereClause)>
						<!--- assign foreign data to array scope --->
						<cfloop list="#q_foreignInstanceData.columnlist#" index="fieldName">
							<cfset thisArray = evaluate("a_#fieldName#")>
							<cfset thisArray[q_getKeyFields.currentrow] =evaluate('q_foreignInstanceData.'&fieldName)>
							<cfset "a_#fieldName#" = thisArray>
						</cfloop>
					<cfelse>
						<!--- assign empty data to array scope --->
						<cfloop list="#compositekey[q_tableList.formobjectid]#" index="fieldName">
							<cfset thisArray = evaluate("a_#fieldName#")>
							<cfset thisArray[q_getKeyFields.currentrow] = "">
							<cfset "a_#fieldName#" = thisArray>
						</cfloop>
					</cfif>
				</cfloop>
			</cfloop>
			<!--- assign foreign data array to query scope --->
			<cfloop list="#compositetablelist#" index="j">
				<cfloop list="#compositekey[j]#" index="fieldName">
					<cfset thisArray = evaluate("a_#fieldName#")>
					<cfset blah = QueryAddColumn(q_getKeyFields,fieldName,evaluate("a_#fieldName#")) >
				</cfloop>
			</cfloop>
			<!--- apply sorting rules for composite key values --->
			<cfif len(trim(compositesortvalue))>
				<cfquery name="sorted_q_getKeyFields" dbtype="query" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT *
					FROM q_getKeyFields
					ORDER BY #compositesortvalue#
				</cfquery>
				<cfset q_getKeyFields = sorted_q_getKeyFields>
			</cfif>
			<!--- apply filtering --->
			<cfset whereClause="">
			<!--- build where condition --->
			<cfloop query="q_tableList">
				<cfloop list="#compositekey[q_tableList.formobjectid]#" index="fieldName">
					<cfif isDefined("url.#fieldName#") AND len(evaluate('url.'&fieldName))>
						<cfif len(whereClause)>
							<cfset whereClause=whereClause&" AND ">
						</cfif>
						<cfset thisMatchString = "'%#lcase(urlDecode(evaluate('url.'&fieldName)))#%'">
						<cfset whereClause=whereClause&"LOWER(#fieldName#) LIKE #thisMatchString#">
					</cfif>
				</cfloop>
			</cfloop>
			<cfif len(trim(whereClause))>
				<!--- perform filter --->
				<cfquery name="filtered_q_getKeyFields" dbtype="query" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT *
					FROM q_getKeyFields
					WHERE #preservesinglequotes(whereClause)#
				</cfquery>
				<cfset q_getKeyFields = filtered_q_getKeyFields>
			</cfif>
		</cfif>
		<!--- 12/07/2006 DRK add composite form prefill functionality END --->
		<cfif q_getKeyFields.recordcount>
			<cfoutput>
				<tr>
					<td colspan="2" align="right">#q_getKeyFields.recordcount# Record<cfif q_getKeyFields.recordcount GT 1>s</cfif> Found.</td>
				</tr>
			</cfoutput>
		</cfif>

		<cfif q_getKeyFields.recordcount EQ 1 AND isDefined("url.search")>
			<cflocation url="#request.page#?instanceid=#evaluate('q_getKeyFields.#request.q_getForm.datatable#ID')#&formstep=showform">
		<cfelseif request.q_getForm.singleRecord EQ 1 AND q_getKeyFields.recordcount EQ 1>
			<cflocation url="#request.page#?instanceid=#evaluate('q_getKeyFields.#request.q_getForm.datatable#ID')#&formstep=showform">
		<cfelseif request.q_getForm.singleRecord EQ 1 AND q_getKeyFields.recordcount EQ 0>
			<cflocation url="#request.page#?formstep=showform">
		</cfif>

	<!--- DRK param to top --->
	<cfparam name="attributes.page_size" default="#maxRecords#">
	<!--- DRK added required param 'query' to tag call --->
	<cfmodule template="#application.customtagpath#/previous_next.cfm" query="#q_getKeyFields#" query_name="thisList" page_size="#attributes.page_size#">
	<cfloop from="1" to="#maxRows#" step="1" index="colCt">
		<cfif thisList.recordcount GT round(maxRecords*((round(100/maxRows)*(colCt-1))/100))>
			<cfset rowNum=round(thisList.recordcount/colCt)>
			<cfset colNum=colCt>
		</cfif>
	</cfloop>
	<cfif val(rowNum*colNum) LT maxRecords><cfset rowNum=rownum+1></cfif>
<cfif isDefined("successMsg")>
	<tr>
		<td colspan="2" class="successmsg" align="center"><cfoutput>#successMsg#</cfoutput></td>
	</tr>
</cfif>
	<cfoutput>
<cfif request.deletePerms>
	<script language="JavaScript" type="text/javascript">
		var checkflag = "false";
		function check(field) {
		if (checkflag == "false") {
		for (i = 0; i < field.length; i++) {
		field[i].checked = true;}
		checkflag = "true";
		return "Uncheck All"; }
		else {
		for (i = 0; i < field.length; i++) {
		field[i].checked = false; }
		checkflag = "false";
		return "Check All"; }
		}
	</script>
</cfif>
<!--- DRK list logic to custom tag? --->
<cfif thisList.recordcount>
<tr>
	<td colspan="2" valign="top">
		<table width="100%" border="0" cellpadding="0" cellspacing="1">
<form action="#request.page#" method="post" name="deleteEntries" id="deleteEntries">
<input type="hidden" name="formstep" value="confirm">
<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="displayform,confirmedDeleteList,deleteList">

	<cfloop from="1" to="#rowNum#" index="thisRow">
	<tr>
		<cfloop from="1" to="#colNum#" index="thisCol">
			<td valign="top">
				<cfset thisHereRecord=val(thisRow+((thisCol-1)*rowNum))>
				<cfif thisHereRecord LTE thisList.recordcount><cfif request.deletePerms><table style="margin: 0px 0px 0px 0px;"><tr><td valign="top"><input type="checkbox" name="deleteInstance" value="#evaluate('thisList.#request.q_getForm.datatable#ID[thisHereRecord]')#" style="margin: 0px 0px 0px 0px;">&nbsp;</td><td valign="top"></cfif><a href="#request.page#?instanceid=#evaluate('thisList.#request.q_getForm.datatable#ID[thisHereRecord]')#&displayForm=1&formstep=showform"><cfset selectClause="#request.q_getForm.datatable#.#request.q_getForm.datatable#ID, #request.q_getForm.editFieldKeyValue#"><!--- <cfloop list="#request.q_getForm.editFieldKeyValue#" index="i">#evaluate('thisList.#i#[thisHereRecord]')# </cfloop> ---><cfloop list="#KeyValue#" index="i">#evaluate('thisList.#i#[thisHereRecord]')# </cfloop></a><cfif request.deletePerms></td></tr></table></cfif><cfelse>&nbsp;</cfif>
			</td>
		</cfloop>
	</tr>
	</cfloop>
	<cfif page_count GT 1>
	<tr>
		<td<cfif colNum GT 1> colspan="#colNum#"</cfif> align="center">
		<div id="pagingControls">&lt;#prev_link# Page #page_no# of #page_count#  :   #pages_link# #next_link#&gt;</div>
		</td>
	</tr>
	</cfif>
	<tr>
		<td<cfif colNum GT 1> colspan="#colNum#"</cfif> class="formiteminput" align="center"><cfif request.deletePerms><input type=button value="Check All" onclick="this.value=check(this.form.deleteInstance)" class="submitbutton" style="width:100">
<input type="submit" name="deleteEm" value="Delete Selected" class="submitbutton" style="width:130"></form></cfif>
		</td>
	</tr>
	</table>
	</td>
</tr>
<cfelse>
		<tr>
			<td colspan="#val(listLen(keyvalue)+1)#">There are currently no items. Click the (+) button above to begin.</td>
		</tr>
</cfif>
</cfoutput>
	</cfmodule>
</cfcase>

</cfswitch>
</table>
</cfif>