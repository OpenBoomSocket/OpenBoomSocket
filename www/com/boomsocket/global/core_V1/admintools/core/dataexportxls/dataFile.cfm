<cfsilent>
<!---
	Original Author: Eric Jones
	Creation Date: 1/14/2008
	Last Modified Author:
	Last Modified Date:
	Edit History:
		2008-01-14 Initial Creation ERJ
--->
</cfsilent>
<!--- Custom Tool: Data Export - Excel  Created on {ts '2007-06-28 09:31:20'} --->
<cfparam name="formobjectid" default="0">
<cfif isDefined('form.formobjectid')>
	<cfset formobjectid=form.formobjectid>
<cfelseif isDefined('url.formobjectid')>
	<cfset formobjectid=url.formobjectid>
</cfif>
<cfquery datasource="#application.datasource#" name="q_getFormObjects" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT formobject.formobjectname, formobject.formobjectid
	FROM formobject
	INNER JOIN userpermission ON userpermission.formobjectid = formobject.formobjectid
	WHERE (userpermission.userid = #session.user.id#) AND (userpermission.access = 1) AND (formobject.formenvironmentid <> 100) AND (formobject.formenvironmentid <> 105) AND (formobject.formenvironmentid <> 107) <!---  AND (formobject.formenvironmentid <> 109) AND (formobject.formenvironmentid <> 110) --->
	ORDER BY formobjectname
</cfquery>
<cfset q_getThisObject = queryNew("formobjectname,formobjectid,datadefinition,tabledefinition")>
<cfif isDefined('formobjectid') and len(trim(formobjectid))>
	<cfquery datasource="#application.datasource#" name="q_getThisObject" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT formobjectname, formobjectid, datadefinition, datatable, compositeForm, useWorkFlow
		FROM formobject
		WHERE formobjectid = #trim(formobjectid)#
		ORDER BY formobjectname
	</cfquery>
	<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
		input="#q_getThisObject.datadefinition#"
		output="a_formelements">
</cfif>

<cfif isDefined('FORM.importfieldlist')>
	<cfset keyvalue=FORM.importfieldlist>
	<cfset fullKeyValueList=FORM.importfieldlist>
<cfelseif isDefined('URL.fieldlist')>
	<cfset keyvalue=URL.fieldlist>
	<cfset fullKeyValueList=URL.fieldlist>
</cfif>
<cfif NOT isDefined('keyvalue') OR NOT listLen(keyvalue)>
	<cfoutput>
		<h2>You must select at least one field!</h2>
	</cfoutput>
	<cfabort>
</cfif>
<cfset AmbiguousList="ParentID,DateCreated,DateModified,Ordinal,active,description,body,abstract,sekeyname,startdate,enddate">
<cfset CastAsVarcharlist = "">
<cfscript>
	thisDataDef = XMLParse(q_getThisObject.DATADEFINITION);
</cfscript>
<cfloop list="#fullKeyValueList#" index="thisKeyField2">
	<!--- This is an xpath query which will return the input type from the datadef for the column we are looking at --->
	<cfset thisXmlPos = XmlSearch(thisDataDef,"/datadefinition/item[fieldname='#lCase(thisKeyField2)#']/datatype")>
	<cfif ArrayLen(thisXmlPos) EQ 1>
		<cfif thisXmlPos[1].XmlText EQ 'text' OR thisXmlPos[1].XmlText EQ 'nText'>
			<cfset CastAsVarcharlist = ListAppend(CastAsVarcharlist, lCase(thisKeyField2), ',')>
		</cfif>
	</cfif>
</cfloop>
<cfset formInstanceObj = CreateObject('component','#application.cfcpath#.forminstance')>

<!--- 12/06/2006 DRK pull composite form edit and sort keys START --->
<!--- get data definitions in array format --->
<cfif isDefined('q_getThisObject.compositeForm') AND (q_getThisObject.compositeForm EQ 1)>
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
		</cfif>
	</cfloop>
</cfif>
<!--- 12/06/2006 DRK pull composite form edit and sort keys END --->
<cfset selectClause="">
<cfloop list="#keyvalue#" index="m">
	<cfif (m NEQ "version") AND (m NEQ "status")>
		<cfset selectClause=listAppend(selectClause,"[#q_getThisObject.datatable#].#m#")>
	</cfif>
</cfloop>
<cfset fromClause="#q_getThisObject.datatable#">
<cfset whereClause="">
<cfset orderVar="">
<!--- If we are in a workflow managed objecta and fields were selected, join to version table --->
<cfif q_getThisObject.useWorkFlow EQ 1 AND (listfindnocase(keyvalue,'status') OR listfindnocase(keyvalue,'version'))>
	<cfset selectClause="[version].version,[versionStatus].status,"&selectClause>
	<cfset fromClause=fromClause&" INNER JOIN [version] ON [#q_getThisObject.datatable#].#q_getThisObject.datatable#id = [version].instanceItemid INNER JOIN [VersionStatus] ON [version].versionStatusID = [VersionStatus].versionstatusid ">
	<cfset whereClause = whereClause& " ([version].archive IS NULL OR [version].archive = 0) AND [version].formobjectitemid = " & #q_getThisObject.formobjectid#>
</cfif>
<cfset newKeyValue="">
<cfset newKeyValue2="">
<!--- if lookup table field, grab actual value --->
<cfloop list="#KeyValue#" index="i">
	<cfif right(i,2) EQ "id" AND i NEQ "#q_getThisObject.datatable#id">
		<cfset thisTable=removeChars(i,len(i)-1,2)>
		<cfset thisDisplay="[#thisTable#].#thisTable#name">
		<cfset thisDisplayField="#thisTable#name">
		<cfset thisKey=i>
		<!--- check for lookup table assignment --->
		<cfloop index="t" from="1" to="#arrayLen(a_formelements)#">
			<cfif structFind(a_formelements[t],"fieldname") eq i>
				<cfif findnocase(a_formelements[t].LOOKUPTYPE,"table") AND len(trim(a_formelements[t].LOOKUPTABLE))>
					<cfset thisTable=a_formelements[t].LOOKUPTABLE>
					<cfif len(trim(a_formelements[t].LOOKUPKEY))>
						<cfset thisKey=a_formelements[t].LOOKUPKEY>
					</cfif>
					<cfif len(trim(a_formelements[t].LOOKUPDISPLAY))>
						<cfset thisDisplay="[#thisTable#].#a_formelements[t].LOOKUPDISPLAY#">
						<cfset thisDisplayField="#a_formelements[t].LOOKUPDISPLAY#">
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
			<cfif thisTable EQ q_getThisObject.datatable>
				<cfset newKeyValue2=listAppend(newKeyValue2,thisDisplayField)>
			<cfelse>
				<cfset newKeyValue2=listAppend(newKeyValue2,"")>
			</cfif>
			<cfif q_getThisObject.datatable NEQ thisTable>
				<cfset fromClause=fromClause&" LEFT JOIN [#thisTable#] ON  [#q_getThisObject.datatable#].#i#=[#thisTable#].#thisKey#">
			</cfif>
		</cfif>
	</cfif>
</cfloop>
<cfset fieldlistnoForeign = keyvalue>
<cfif listLen(newKeyValue)>
	<cfset keyvalue=listAppend(keyValue,lcase(newKeyValue))>
	<cfset fullKeyValueList=listAppend(fullKeyValueList,lcase(newKeyValue))>
	<cfif isDefined("removeKeyValue")>
		<cfloop index="remMe" list="#removeKeyValue#">
			<cfset keyvalue=listDeleteAt(keyValue,listFindNoCase(keyValue,remMe))>
			<cfset fullKeyValueList=listDeleteAt(fullKeyValueList,listFindNoCase(fullKeyValueList,remMe))>
		</cfloop>
		<cfif FindNoCase(removeKeyValue,whereclause,1)>
			<cfset whereClause=replaceNoCase(whereClause,removeKeyValue,newSearchKeyValue,"all")>
		</cfif>
	</cfif>
</cfif>
<cfset qualifiedSelectList="">
<cfloop list="#fieldlistnoForeign#" index="j">
	<cfif (m NEQ "version") AND (m NEQ "status")>
		<cfset qualifiedSelectList=listAppend(qualifiedSelectList,"[#q_getThisObject.datatable#].#j#",",")>
	</cfif>
</cfloop>	
<cfset selectClause=listAppend(selectClause,"#qualifiedSelectList#")>
<cfif isDefined('removeKeyValue')>
	<cfif FindNoCase(removeKeyValue,orderVar,1)>
		<cfset orderVar = replaceNoCase(orderVar,removeKeyValue,newSearchKeyValue,"all")>
	</cfif>
</cfif>
<cfloop list="#AmbiguousList#" index="thisAmbItem">
	<cfif ListContains(CastAsVarcharlist,thisAmbItem)>
		<cfset orderVar=replaceNoCase(orderVar,"#thisAmbItem# ","CAST(#q_getThisObject.datatable#.#thisAmbItem# AS VarChar(100)) ")>
	<cfelse>
		<cfset orderVar=replaceNoCase(orderVar,"#thisAmbItem# ","#q_getThisObject.datatable#.#thisAmbItem# ")>
	</cfif>
</cfloop>
<cfif right(selectClause,1) EQ ','>
	<cfset selectClause = left(selectClause,len(selectClause) - 1) >
</cfif>
<cfif isDefined('URL.recordlimit') AND isNumeric(URL.recordlimit)>
	<cfset selectClause="TOP #URL.recordlimit# "&selectClause>
</cfif>
<cfif isDefined('URL.startdate') AND isDate(URL.startdate)>
	<cfif len(whereclause)>
		<cfset whereclause = whereclause&" AND">
	</cfif>
	<cfset whereclause = whereclause&"[#q_getThisObject.datatable#].datemodified > "&createODBCDateTime(URL.startdate)>
</cfif>
<cfif isDefined('URL.enddate') AND isDate(URL.enddate)>
	<cfif len(whereclause)>
		<cfset whereclause = whereclause&" AND">
	</cfif>
	<cfset whereclause = whereclause&"[#q_getThisObject.datatable#].datemodified < "&createODBCDateTime(URL.enddate)>
</cfif>
<cfset q_getKeyFields=formInstanceObj.getFormData(selectClause=selectClause,fromClause=fromClause,whereclause=whereclause)>
<cfif isDefined('q_getThisObject.compositeForm') AND (q_getThisObject.compositeForm EQ 1) AND listLen(compositetablelist)>
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
		<cfset currentID = evaluate('q_getKeyFields.'&q_getThisObject.datatable&'id')>
		<!--- loop through the foreign data set --->
		<cfloop query="q_tableList" >
			<!--- check to see if we have values set for these ids --->
			<cfquery name="q_getForeignKey" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT #q_tableList.datatable#ID
				FROM #q_getThisObject.datatable#
				WHERE isNull(#q_tableList.datatable#ID,0) <> 0 AND (#q_tableList.datatable#ID <> '') AND ("#q_getThisObject.datatable#ID" = #currentID#)
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
								<cfset localLookupFound = 1>
								<cfbreak>
							</cfif>
						</cfloop>
						<!--- check to see if assignment for table lookup made in foreign table --->
						<cfif NOT (isDefined('localLookupFound') AND localLookupFound)>
							<cfquery name="q_getForeignDataStruct" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
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
</cfif>
<cfif q_getKeyFields.recordcount>
	<cfif isDefined('url.preview') AND url.preview EQ 0>
		<cfcontent type="application/msexcel" reset="yes">
		<cfheader name="Content-Disposition" value="attachment;filename=datafile.xls;">
	</cfif>
	<cfoutput>
	<table cellspacing="0" cellpadding="1">
	<cfloop list="#fullKeyValueList#" index="i">
		<!--- dood - this puts the label instead of the column name --->
		<cfif isDefined('URL.friendlyname') AND URL.friendlyname EQ 1>
			<cfloop index="t" from="1" to="#arrayLen(a_formelements)#">
				<cfif structFind(a_formelements[t],"fieldname") eq i>
					<cfset thisKey=a_formelements[t].objectlabel>
					<cfbreak>
				<cfelse>
					<cfif NOT (i EQ "name")>
						<cfset thisKey=application.CapFirst(replaceNoCase(i,"name","","all"))>
					<cfelse>
						<cfset thisKey=application.CapFirst(i)>
					</cfif>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset thisKey=application.CapFirst(i)>
		</cfif>
	<tr  ><th class="formiteminput" style="color:##FFFFFF; background-color:##07447F"><strong>#APPLICATION.stripHTML(thisKey)#</strong></th>
	
	</cfloop><cfset thiscount = 1>
	<cfif NOT isDefined('URL.templateonly') OR NOT URL.templateonly>
	<cfloop query="q_getKeyFields">
		<cfif thiscount MOD 2><cfset rowclass="oddrow"><cfelse><cfset rowclass="evenrow"></cfif>
		<tr class="#rowclass#">
			<!--- use full listing for table columns/fields --->
			<cfloop list="#fullKeyValueList#" index="i">
				<!--- this puts the label instead of the column name --->
				<cfloop index="t" from="1" to="#arrayLen(a_formelements)#">
					<!--- date format --->
					<cfif structFind(a_formelements[t],"fieldname") eq i>
						<cfif a_formelements[t].datatype EQ "datetime">
							<cfset thisVal="#DateFormat(evaluate('q_getKeyFields.'&i),'m/d/yyyy')# #TimeFormat(evaluate('q_getKeyFields.'&i),'h:mm TT')#">
							<cfbreak>
						</cfif>
						<!--- Checks to see if this is a bit datatype so we can convert it from a 1 / 0 to a yes / no --->
						<cfif a_formelements[t].datatype EQ 'bit'>
							<cfset isBit = "True">
						<cfelse>
							<cfset isBit = "False">
						</cfif>
						<cfif a_formelements[t].lookuptype EQ 'list'>
							<cfloop list="#structFind(a_formelements[t],'lookuplist')#" delimiters=";" index="listItem">
								<cfif evaluate("q_getKeyFields."&i) EQ listFirst(listItem)>
									<cfset thisVal=listLast(listItem)>
									<cfbreak>
								</cfif>
							</cfloop>
							<cfbreak>
						</cfif>
					<cfelse>
						<cfset thisVal=evaluate("q_getKeyFields."&i)>
					</cfif>
				</cfloop>
				<td valign="top" style="border-width: 0px 1px 1px 0px; border-color: ##333333; border-style: solid; padding: 3px;"><cfif thisVal EQ 1 AND isBit EQ "True">Yes<cfelseif thisVal EQ 0 AND isBit EQ "True">No<cfelse><cfif IsDefined('thisVal') AND Len(Trim(thisVal))>#thisVal#<cfelse>&nbsp;</cfif></cfif></td>
			</cfloop>
		</tr>
		<cfset thiscount = thiscount + 1>
	</cfloop>
	</cfif>
	</table>
	</cfoutput>
</cfif>