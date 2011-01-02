<cfsilent>
	<!---
        Original Author: Darin Kohles
        Creation Date: unknown
        Last Modified Author: Eric Jones
        Last Modified Date: 01/15/2008
        Edit History:
            UNKNOW Initial Creation DRK
			01/15/2008 modified form post for export so it self posts to the page versus doing a JS new window
				IE browsers didn't like the new window method.
				
			01/29/2008 Update Darrin Kay
				--  Took the primary Key out of the select fields list, but it will stil get added to the select
					clause for use in forgin table joins
					
			02/05/2008 Update CMC
				--  Added check for FORM scope of recordlimit, startdate, enddate - was only checking URL scoped vars so these weren't getting used for the actual export, just the preview
				
			02/14/2008 Update CMC
				--  Revisions to Darrin's 1/29/2008 updates- allowing ID field to be in option for export, making update so not added to query select stmt if it is selected since Darrin is already adding to select stmt regardless of user selection.
    --->
    
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
    <!--- 01/29/2008 Update Darrin Kay --->
     <cfset lID = q_getThisObject.datatable&'id'>
</cfsilent>
	<cfsavecontent variable="jsFunctions">
		<cfoutput>
			<script type="text/javascript">
				// ASSIGN/UNASSIGN ITEMS (action: Add/Remove, assigned select id, unassigned select id, value list id (hidden field), alphaSort: 1/0)
				function MoveAll(action,assignedName,unassignedName,saveList,alphaSort){
					//Default addSelect & removeSelect vars: default adding
					var addSelect = assignedName;
					var removeSelect = unassignedName;
					if (action == "Remove"){
						addSelect = unassignedName;
						removeSelect = assignedName;
					}
					//Select All
					for(var i = 0;i < document.getElementById(removeSelect).length;i++){
						document.getElementById(removeSelect).options[i].selected = true;
					}
					//Move Selected
					MoveSelected(action,assignedName,unassignedName,saveList,alphaSort);
				}
				function MoveSelected(action,assignedName,unassignedName,saveList,alphaSort){
					//Default addSelect & removeSelect vars: default adding
					var addSelect = assignedName;
					var removeSelect = unassignedName;
					if (action == "Remove"){
						addSelect = unassignedName;
						removeSelect = assignedName;
					}   
					var newOptValue;
					var newOptText;
					var newOptIndex;
					var movedValues = new Array();   
					//Add item to bottom of addSelect
					//alert(document.getElementById('tablerows').value);
					if(action != "Remove"){
						for (var i = 0; i < document.getElementById(removeSelect).length; i++) {
							if (document.getElementById(removeSelect)[i].selected){
								//get new option text and value to add
								newOptValue = document.getElementById(removeSelect)[i].value;
								newOptText = document.getElementById(removeSelect)[i].innerHTML;
								//remove any wonkiness w/ & (js converts & to &amp; or &amp;amp;etc.)
								newOptText = newOptText.replace("&amp;","&");
								newOptText = newOptText.replace("amp;","");
								newOptIndex = document.getElementById(addSelect).length;
								document.getElementById(addSelect)[newOptIndex] = new Option(newOptText,newOptValue);
							}
						}
						action = "Remove";
					}   
					//remove item from removeSelect (loop backwards so indexes aren't changing as you delete)
				   if(action == "Remove"){
					   for (var i = document.getElementById(removeSelect).length-1; i >= 0; i--) {
							if (document.getElementById(removeSelect)[i].selected){
								document.getElementById(removeSelect)[i] = null;
							}
						}
					}
					//Alpha Sort both if necessary
					if(alphaSort == "1"){
						sortSelect(document.getElementById(assignedName), true);
						//sortSelect(document.getElementById(unassignedName), true);
					}
									   
					//reset FORM.importfieldlist OR FORM.imageid
					if(assignedName.indexOf('un') == -1){
						SetFields(document.getElementById(assignedName),document.getElementById(saveList));
					}else{
						SetFields(document.getElementById(unassignedName),document.getElementById(saveList));
					}
				   
				}
			
			/* ALPHA SORTING (see: http://www.tek-tips.com/faqs.cfm?fid=5347) */
				// sort function - ascending (case-insensitive)
				function sortFuncAsc(record1, record2) {
					var value1 = record1.optText.toLowerCase();
					var value2 = record2.optText.toLowerCase();
					if (value1 > value2) return(1);
					if (value1 < value2) return(-1);
					return(0);
				}
			
				// sort function - descending (case-insensitive)
				function sortFuncDesc(record1, record2) {
					var value1 = record1.optText.toLowerCase();
					var value2 = record2.optText.toLowerCase();
					if (value1 > value2) return(-1);
					if (value1 < value2) return(1);
					return(0);
				}
			
				function sortSelect(selectToSort, ascendingOrder) {
					if (arguments.length == 1) ascendingOrder = true;    // default to ascending sort
			
					// copy options into an array
					var myOptions = [];
					for (var loop=0; loop<selectToSort.options.length; loop++) {
						myOptions[loop] = { optText:selectToSort.options[loop].text, optValue:selectToSort.options[loop].value };
					}
			
					// sort array
					if (ascendingOrder) {
						myOptions.sort(sortFuncAsc);
					} else {
						myOptions.sort(sortFuncDesc);
					}
			
					// copy sorted options from array back to select box
					selectToSort.options.length = 0;
					for (var loop=0; loop<myOptions.length; loop++) {
						var optObj = document.createElement('option');
						optObj.text = myOptions[loop].optText;
						optObj.value = myOptions[loop].optValue;
						selectToSort.options.add(optObj);
					}
				}
			   
			/* ORDINAL CONTROL */
				//sort up (list to sort)
				function Field_up(lst,saveList)
				{
					var i = lst.selectedIndex;
					if (i>0){
						Field_swap(lst,i,i-1,saveList);
					}
				}
				//sort down (list to sort)
				function Field_down(lst,saveList)
				{
					var i = lst.selectedIndex;
					if (i<lst.length-1){
						Field_swap(lst,i+1,i,saveList);
					}
				}
				//swap fields (list, item1, item2)
				function Field_swap(lst,i,j,saveList)
				{
					var t = '';
					t = lst.options[i].text; lst.options[i].text = lst.options[j].text; lst.options[j].text = t;
					t = lst.options[i].value; lst.options[i].value = lst.options[j].value; lst.options[j].value = t;
					t = lst.options[i].selected; lst.options[i].selected = lst.options[j].selected; lst.options[j].selected = t;
					t = lst.options[i].defaultSelected; lst.options[i].defaultSelected = lst.options[j].defaultSelected; lst.options[j].defaultSelected = t;
					SetFields(document.getElementById(lst.id),document.getElementById(saveList));
				}
				//set hidden form field (list to pull from, list to save to)
				function SetFields(lst,lstSave)
				{
					var t;
					lstSave.value=""
					for (t=0;t<=lst.length-1;t++){
						lstSave.value+=String(lst.options[t].value)+",";
					}
					if (lstSave.value.length>0){
						lstSave.value=lstSave.value.slice(0,-1);
						document.getElementById('previewBtn').disabled=null;
						document.getElementById('previewBtn').className='submitbutton';
						document.getElementById('exportBtn').disabled=null;
						document.getElementById('exportBtn').className='submitbutton';
					}else{
						document.getElementById('previewBtn').disabled="disabled";
						document.getElementById('previewBtn').className='submitbutton disabledStyle';
						document.getElementById('exportBtn').disabled="disabled";
						document.getElementById('exportBtn').className='submitbutton disabledStyle';
					}
					//alert(lstSave.value);
				}
				function populateUnassignFields(){
					var selectedRow = document.getElementById('importFormSelection').selectedIndex
					var tableID = document.getElementById('importFormSelection').options[selectedRow].value;
					for(i=0 ; i<document.getElementById('unassignedFields').options.length ; i++){
						if(String(document.getElementById('unassignedFields').options[i].value).split(':')[0] == tableID){
							document.getElementById('unassignedFields').options[i].className = 'ActiveFormFields';
						}else{
							document.getElementById('unassignedFields').options[i].className = 'DormantFormFields';
						}
					}
					document.getElementById('unassignedFields').selectedIndex = -1;
				}
				function changeTool(){
					window.location.href="#request.page#?excelExport=1&formobjectid="+document.getElementById('formobjectlist').value;
				}
				function loadPreview(){
					var friendlyname = "";
					if(document.getElementById('friendlyname').checked){
						friendlyname = "&friendlyname=1";
					}
					var templateonly = "";
					if(document.getElementById('templateonly').checked){
						friendlyname = "";
						templateonly = "&templateonly=1";
					}
					var startdate = "";
					if(document.getElementById('startdate').value.length){
						startdate = "&startdate="+document.getElementById('startdate').value;
					}
					var enddate = "";
					if(document.getElementById('enddate').value.length){
						enddate = "&enddate="+document.getElementById('enddate').value;
					}
					var recordlimit = "";
					if(document.getElementById('recordlimit').value.length){
						recordlimit = "&recordlimit="+document.getElementById('recordlimit').value;
					}
					document.getElementById('previewExport').src="#request.page#?excelExport=1&formobjectid="+document.getElementById('formobjectid').value+'&preview=1&fieldlist='+document.getElementById('importfieldlist').value+friendlyname+templateonly+startdate+enddate+recordlimit;
				}
				function clearFriendlyNames(){
					if(document.getElementById('templateonly').checked){
						document.getElementById('friendlyname').checked = false;
					}
				}
			</script>
			<style type="text/css">
				##toolFieldSelection{
					padding-left: 20px;
					padding-top: 0px;
				}
				##tableListing{
					float: left;
				}
				##fieldListing{
					float: left;
					margin-left: 60px;
				}
				##previewExport{
					float: right;
					width: 100%;
				}
				##buttonBox{
				margin-top: 30px;
				}
				.disabledStyle{
					opacity:0.5;
					MozOpacity:0.5;
					KhtmlOpacity:0.5;
					filter: 'alpha(opacity=50)';
					color: ##aaaaaa;
				}
			</style>
		</cfoutput>
	</cfsavecontent>
<cfif NOT isDefined('URL.preview')>
	<cfhtmlhead text="#jsFunctions#">
	<cfoutput>
	<div id="socketformheader">
		<h2>Export To Excel</h2>
	</div><div style="clear:both";></div>
	</div>
	<div id="toolFieldSelection">
		<form id="fieldForm" name="fieldForm" method="post" action="#request.page#?#SESSION.URLToken#&excelExport=1&formobjectid=#URL.formobjectid#&preview=0" >
		<div id="tableListing">
		<h3>Available Tables</h3>
		<select id="formobjectlist" name="formobjectlist" onchange="javascript:changeTool();">
			<cfloop query="q_getFormObjects">
				<option value="#q_getFormObjects.formobjectid#" <cfif q_getThisObject.formobjectid EQ q_getFormObjects.formobjectid> SELECTED=selected</cfif>>#q_getFormObjects.formobjectname#</option>
			</cfloop>
		</select>
		<div id="buttonBox"><input type="checkbox" id="friendlyname" name="friendlyname" onclick="javascript:clearFriendlyNames()">Use Friendly Column Name</input><br /><input type="checkbox" id="templateonly" name="templateonly" onclick="javascript:clearFriendlyNames()">Create Blank Template Only</input><br /><br /><input name="startdate" type="text" id="startdate" style="margin-bottom:2px;" size="12"/>&nbsp;Start Date<br /><input name="enddate" type="text" id="enddate" style="margin-bottom:2px;" size="12"/>&nbsp;End Date<br /><input name="recordlimit" type="text" id="recordlimit" size="12"/>&nbsp;Record Limit<br /><br /><input type="button" id="previewBtn" name="previewBtn" class="submitbutton disabledStyle" value="Preview" onclick="loadPreview();" disabled="disabled" /><input type="button" id="exportBtn" name="exportBtn" class="submitbutton disabledStyle" value="Export" onclick="javascript:document.fieldForm.submit();" disabled="disabled" /></div>
		</div>
		<input type="hidden" name="formobjectid" id="formobjectid" value="#q_getThisObject.formobjectid#" />
		<cfif q_getThisObject.recordcount>
		<!--- <cfdump var="#a_formelements[1]#"> --->
		<div id="fieldListing">
		<input type="hidden" name="importfieldlist" id="importfieldlist" value="" />
       
		<h3>Select Fields</h3>
		<table>
			<tr>
				<td width="40%" align="left">
                	<select name="unassignedFields" id="unassignedFields" multiple="multiple" size="12" style="width: 180px;">
						<cfloop from="1" to="#arrayLen(a_formelements)#" index="i">
							<!---<cfif #a_formelements[i]['fieldname']# NEQ #lID#> 01/29/2008 Update Darrin Kay so PrimaryID will not show up --->
								<cfif (a_formelements[i]['fieldname'] NEQ 'Submit') AND ((a_formelements[i]['commit'] EQ 1) OR (structKeyExists(a_formelements[i],'SOURCEFORMOBJECTID') AND (a_formelements[i]['SOURCEFORMOBJECTID'] GT 0)))>
                                    <option value="#a_formelements[i]['fieldname']#" title="#a_formelements[i]['objectlabel']# : #a_formelements[i]['fieldname']#">#a_formelements[i]['fieldname']# (#a_formelements[i]['objectlabel']#)</option>
                                </cfif>
                            <!---</cfif> 01/29/2008 Update Darrin Kay --->
						</cfloop>
						<cfif q_getThisObject.useWorkFlow EQ 1>
						<option value="Version" title="Version">Version</option>
						<option value="Status" title="Status">Status</option>
						</cfif>
					</select>
				</td>
				<td align="center" valign="top">
					<div>Assign</div>
					<div><input type="button" name="add" class="submitbutton" value="&gt;"  onclick="MoveSelected('Add','assignedFields','unassignedFields','importfieldlist','0');"></div>
					<div>UnAssign</div>
					<div><input type="button" name="add" class="submitbutton" value="&lt;"  onclick="MoveSelected('Add','unassignedFields','assignedFields','importfieldlist','0');"></div>
				</td>
				<!--- Assigned Select --->
				<td width="40%" align="left">
					<select name="assignedFields" id="assignedFields" multiple size="12" style="width: 180px;">
					</select>
				</td>
				<td align="center" valign="top">
					<div>Up</div>
					<div><input type="button" name="add" class="submitbutton" value="+"  onclick="Field_up(document.getElementById('assignedFields'),'importfieldlist');"></div>
					<div>Down</div>
					<div><input type="button" name="add" class="submitbutton" value="-"  onclick="Field_down(document.getElementById('assignedFields'),'importfieldlist');"></div>
				</td>
			</tr>
		</table>
		</form>
		</div>
		<div style="clear:both;"></div>
		<div id="previewListing"style=" margin:0px 15px 20px 5px;">
		<h3>Preview Data</h3>
		<iframe id="previewExport" name="previewExport" style="border: none; height:280px;"></iframe>
		</div>
		<div style="clear:both;"></div>
		</cfif>
	</div>
	
</cfoutput><cfelse>
	<cfsilent>	<!--- 	
    	<cfdump var="#url#">
    <cfabort> --->
		<cfif isDefined('FORM.importfieldlist')>
            <cfset keyvalue=FORM.importfieldlist>
            <cfset fullKeyValueList=FORM.importfieldlist>
        <cfelseif isDefined('URL.fieldlist')>
            <cfset keyvalue=URL.fieldlist>
            <cfset fullKeyValueList=URL.fieldlist>
        </cfif>
	</cfsilent>
	<cfif NOT isDefined('keyvalue') OR NOT listLen(keyvalue)>
		<cfoutput>
			<h2>You must select at least one field!</h2>
		</cfoutput>
		<cfabort>
	</cfif>
	<cfsilent>
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
        <cfset selectClause="[#q_getThisObject.datatable#].#lID#"> <!--- 01/29/2008 Update Darrin Kay --->
        <cfloop list="#keyvalue#" index="m">
            <cfif (m NEQ "version") AND (m NEQ "status") AND (m NEQ lID)>
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
        <cfif (isDefined('URL.recordlimit') AND isNumeric(URL.recordlimit)) OR (isDefined('FORM.recordlimit') AND isNumeric(FORM.recordlimit))>
			<cfif (isDefined('URL.recordlimit') AND isNumeric(URL.recordlimit))>
           		<cfset selectClause="TOP #URL.recordlimit# "&selectClause>
			<cfelseif (isDefined('FORM.recordlimit') AND isNumeric(FORM.recordlimit))>
				<cfset selectClause="TOP #FORM.recordlimit# "&selectClause>
			</cfif>
        </cfif>
        <cfif (isDefined('URL.startdate') AND isDate(URL.startdate)) OR (isDefined('FORM.startdate') AND isDate(FORM.startdate))>
            <cfif len(whereclause)>
                <cfset whereclause = whereclause&" AND">
            </cfif>
			<cfif (isDefined('URL.startdate') AND isDate(URL.startdate))>
            	<cfset whereclause = whereclause&"[#q_getThisObject.datatable#].datemodified > "&createODBCDateTime(URL.startdate)>
			<cfelseif (isDefined('FORM.startdate') AND isDate(FORM.startdate))>
				<cfset whereclause = whereclause&"[#q_getThisObject.datatable#].datemodified > "&createODBCDateTime(FORM.startdate)>
			</cfif>
        </cfif>
        <cfif (isDefined('URL.enddate') AND isDate(URL.enddate)) OR (isDefined('FORM.enddate') AND isDate(FORM.enddate))>
            <cfif len(whereclause)>
                <cfset whereclause = whereclause&" AND">
            </cfif>
			<cfif (isDefined('URL.enddate') AND isDate(URL.enddate))>
           	 	<cfset whereclause = whereclause&"[#q_getThisObject.datatable#].datemodified < "&createODBCDateTime(URL.enddate)>
			 <cfelseif (isDefined('FORM.enddate') AND isDate(FORM.enddate))>
			 	<cfset whereclause = whereclause&"[#q_getThisObject.datatable#].datemodified < "&createODBCDateTime(FORM.enddate)>
			 </cfif>
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
	</cfsilent>
	<cfif q_getKeyFields.recordcount>
        <cfsavecontent variable="excelOutput">
			<cfoutput>
                <table cellspacing="0" cellpadding="1">
                <cfloop list="#fullKeyValueList#" index="i">
                    <cfsilent>
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
                    </cfsilent>
                <tr  ><th class="formiteminput" style="color:##FFFFFF; background-color:##07447F"><strong>#APPLICATION.stripHTML(thisKey)#</strong></th>
                
                </cfloop><cfset thiscount = 1>
                <cfif NOT isDefined('URL.templateonly') OR NOT URL.templateonly>
                <cfloop query="q_getKeyFields">
                    <cfif thiscount MOD 2><cfset rowclass="oddrow"><cfelse><cfset rowclass="evenrow"></cfif>
                    <tr class="#rowclass#">
                        <!--- use full listing for table columns/fields --->
                        <cfloop list="#fullKeyValueList#" index="i">
                            <cfsilent>
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
                                                <cfif isDefined('q_getKeyFields.#i#') AND evaluate("q_getKeyFields."&i) EQ listFirst(listItem)>
                                                    <cfset thisVal=listLast(listItem)>
                                                    <cfbreak>
                                                </cfif>
                                            </cfloop>
                                            <cfbreak>
                                        </cfif>
                                    <cfelse>
                                        <cfif isDefined('q_getKeyFields.#i#')>
                                        	<cfset thisVal=evaluate("q_getKeyFields."&i)>
										<cfelse>
											<cfset thisVal="">
										</cfif>
                                    </cfif>
                                </cfloop>
                            </cfsilent>
                            <td valign="top" style="border-width: 0px 1px 1px 0px; border-color: ##333333; border-style: solid; padding: 3px;"><cfif thisVal EQ 1 AND isBit EQ "True">Yes<cfelseif thisVal EQ 0 AND isBit EQ "True">No<cfelse><cfif IsDefined('thisVal') AND Len(Trim(thisVal))>#thisVal#<cfelse>&nbsp;</cfif></cfif></td>
                        </cfloop>
                    </tr>
                    <cfset thiscount = thiscount + 1>
                </cfloop>
                </cfif>
                </table>
			</cfoutput>
		</cfsavecontent>
		<cfif isDefined('url.preview') AND url.preview EQ 0>
            <cfcontent type="application/vnd.ms-excel" reset="yes">
			<cfheader name="Content-Disposition" value="attachment;filename=datafile_#DateFormat(now(),'mm_dd_yyyy')#.xls">
            <cfoutput>#excelOutput#</cfoutput>
        <cfelse>
        	<cfoutput>#excelOutput#</cfoutput>
  		</cfif>
	</cfif>

</cfif>