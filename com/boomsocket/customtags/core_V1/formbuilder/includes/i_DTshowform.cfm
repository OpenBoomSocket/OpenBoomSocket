<!--- set Custom Tool id according to formEnvironment:i3SiteTools Custom --->
<cfset customToolID="100002">
<cfset thisIncludePath = "#application.customTagPath#/formbuildFront/includes">
<cfif isDefined("url.formEnvironmentID")>
	<cfset form.formEnvironmentID=url.formEnvironmentID>
</cfif>

<cfif len(trim(formobjectid))>
	<cfinclude template="i_getFormobject.cfm">
	<!--- This is a custom form, so redirect to custom registration form --->
	<cfif q_getForm.externalTool EQ 1>
		<cflocation url="#request.page#?toolaction=ShowFormCustom&formobjectid=#formobjectid#" addtoken="No">
	</cfif>
	<!--- make sure they don't break the form by putting a lower rowcount than there are elements --->
	<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
        input="#q_getform.datadefinition#"
        output="a_formelements">
	<!--- reset hi counts for row and column --->
	<cfset hiRow=1>
	<cfset hiCol=1>
	<cfloop from="1" to="#arrayLen(a_formelements)#" index="r">
		<!--- increment hiRow if needed --->
		<cfif listFirst(a_formelements[r].gridposlabel,"_") GT hiRow><cfset hiRow=listFirst(a_formelements[r].gridposlabel,"_")></cfif>
		<!--- increment hiCol if needed --->
		<cfif listLast(a_formelements[r].gridposlabel,"_") GT hiCol><cfset hiCol=listLast(a_formelements[r].gridposlabel,"_")></cfif>
	</cfloop>
	<!--- If this is a child form, create a link to master --->
	<cfif q_getform.formobjectid eq q_getform.parentid>
		<cfset parentstatus="">
		<cfset isParent=1>
	<cfelse>
		<cfquery datasource="#application.datasource#" name="q_parent" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT label, formobjectid
			FROM formobject
			WHERE formobjectid = #q_getform.parentid#
		</cfquery>
		<cfset parentstatus="Instance of <a href=""#request.page#?toolaction=DTShowForm&formobjectid=#q_parent.formobjectid#"" title=""Click here to edit the master form."">#q_parent.label#</a>">
		<cfset isParent=0>
	</cfif>
	
	<cfparam name="form.formEnvironmentID" default="#q_getform.formEnvironmentID#">
	<cfparam name="form.datatable" default="#q_getform.datatable#">
	<cfparam name="form.formobjectid" default="#q_getform.formobjectid#">
	<cfparam name="form.label" default="#q_getform.label#">
	<cfparam name="form.bulkdelete" default="#q_getform.bulkdelete#">
	<cfparam name="form.singleRecord" default="#q_getform.singleRecord#">
	<cfparam name="form.showconfirm" default="#q_getform.showconfirm#">
	<cfparam name="form.successmsg" default="#q_getform.successmsg#">
	<cfparam name="form.successredirect" default="#q_getform.successredirect#">
	<cfparam name="form.successemail" default="#q_getform.successemail#">
	<cfparam name="form.formname" default="#q_getform.formname#">
	<cfparam name="form.formfilename" default="#q_getform.formfilename#">
	<cfparam name="form.formaction" default="#q_getform.formaction#">
	<cfparam name="form.formmethod" default="#q_getform.formmethod#">
	<cfparam name="form.tableclass" default="#q_getform.tableclass#">
	<cfparam name="form.tablewidth" default="#q_getform.tablewidth#">
	<cfparam name="form.tableborder" default="#q_getform.tableborder#">
	<cfparam name="form.tablepadding" default="#q_getform.tablepadding#">
	<cfparam name="form.tablespacing" default="#q_getform.tablespacing#">
	<cfparam name="form.tablealign" default="#q_getform.tablealign#">
	<cfparam name="form.tablecolumns" default="#q_getform.tablecolumns#">
	<cfparam name="form.tablerows" default="#q_getform.tablerows#">
	<cfparam name="form.preshowform" default="#q_getform.preshowform#">
	<cfparam name="form.prevalidate" default="#q_getform.prevalidate#">
	<cfparam name="form.preconfirm" default="#q_getform.preconfirm#">
	<cfparam name="form.postconfirm" default="#q_getform.postconfirm#">
	<cfparam name="form.precommit" default="#q_getform.precommit#">
	<cfparam name="form.postcommit" default="#q_getform.postcommit#">
	<cfparam name="form.toolcategoryid" default="#q_getform.toolcategoryid#">
	<cfparam name="form.useWorkFlow" default="#q_getform.useWorkFlow#">
	<cfparam name="form.description" default="#q_getform.description#">
	<cfparam name="form.showInDigest" default="#q_getform.showInDigest#">
	<!--- 3/2/2007 DRK new tool functions sekey and navigation --->
	<cfif isDefined('q_getform.useVanityURL')>
		<cfparam name="form.useVanityURL" default="#q_getform.useVanityURL#">
	</cfif>
	<cfif isDefined('q_getform.isNavigable')>
		<cfparam name="form.isNavigable" default="#q_getform.isNavigable#">
	</cfif>
	<!--- 12/08/2006 DRK newfunctionality for mapped content --->
	<cfif isDefined('q_getform.useMappedContent')>
		<cfif len(trim(q_getform.useMappedContent))>
			<cfparam name="form.useMappedContent" default="#q_getform.useMappedContent#">
		<cfelse>
			<cfparam name="form.useMappedContent" default="0">
		</cfif>
	</cfif>
	<cfparam name="form.useOrdinal" default="#q_getform.useOrdinal#">
	<!--- 12/04/2006 DRK new functionality for composite Forms one line --->
	<cfif isDefined('q_getform.compositeForm')>
		<cfparam name="form.compositeForm" default="#q_getform.compositeForm#">
	<cfelse>
		<cfparam name="form.compositeForm" default="0">
	</cfif>
	<!--- <cfparam name="form.restrictByUserType" default="#q_getform.restrictByUserType#"> --->
</cfif>
<!--- 12/01/2006 BDW DRK new functionality for composite Forms START --->
	<!--- if existing import fields are present make a list of them --->
	<cfif len(trim(formobjectid))>
		<cfset importedFields = arrayNew(1)>
		<cfset fieldCount = 0>
		<cfloop index="currentItemList" from="1" to="#ArrayLen(a_formelements)#">
			<cfif arrayLen(structFindKey(#a_formelements[currentItemList]#, "SOURCEFORMOBJECTID"))>
				<cfset fieldCount = fieldCount + 1>
				<cfset importedFields[fieldCount] = structNew()>
				<cfset importedFields[fieldCount]['tableID'] = a_formelements[currentItemList].SOURCEFORMOBJECTID>
				<cfset importedFields[fieldCount]['fieldname'] = a_formelements[currentItemList].FIELDNAME>
			</cfif>
		</cfloop>
	</cfif>
	<!--- This needs to go into the formwhatever cfc at some point --->
	<!--- Grab form object table data for composite forms --->
	<cfquery name="q_formobjectlist" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT formobjectname, formobjectid, datadefinition, datatable
		FROM formobject
		WHERE (formenvironmentid IN (102,104,106)) AND (isNull(archive,0) <> 1) AND (isNull(ExternalTool,0) <> 1)
		ORDER BY formobjectname
	</cfquery>
	<!--- loop and deserialize data defs for selection of fields --->
	<cfset selectableFormImportData = arrayNew(1)>
	
	<cfloop query="q_formobjectlist">
		<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
			input="#q_formobjectlist.datadefinition#"
			output="a_formelements">
		<cfset selectableFormImportData[q_formobjectlist.currentrow] = structNew()>
		<cfset selectableFormImportData[q_formobjectlist.currentrow].formobjectname = q_formobjectlist.formobjectname>
		<cfset selectableFormImportData[q_formobjectlist.currentrow].formobjectid = q_formobjectlist.formobjectid>
		<cfset a_fields = arrayNew(1)>
		<cfset currentItem = 0>
		<cfset ignoreList = "ordinal,active,archive,datecreated,datemodified,parentid,submit,cancel,#q_formobjectlist.datatable#ID">
		<!--- check list to exclude already imported fields --->
		<cfif len(trim(formobjectid)) AND isDefined('importedFields') AND arrayLen(importedFields) >
			<cfloop index="i" from="1" to="#arrayLen(importedFields)#">
				<cfif (importedFields[i]['tableID'] EQ q_formobjectlist.formobjectid)>
					<cfset ignoreList = ignoreList&",#importedFields[i]['fieldname']#">
				</cfif>
			</cfloop>
		</cfif>
		
		<cfloop index="i" from="1" to="#arrayLen(a_formelements)#">
			<cfset includeInList = true>
			<cfloop list="#ignoreList#" index="j" delimiters=",">
				<cfif findnocase(j,"#a_formelements[i].FIELDNAME#")>
					<cfset includeInList = false>
				</cfif>
			</cfloop>
			<cfif includeInList>
				<cfset currentItem = currentItem + 1>
				<cfset a_fields[currentItem] = a_formelements[i].FIELDNAME>
			</cfif>
		</cfloop>
		<cfset selectableFormImportData[q_formobjectlist.currentrow].fields = a_fields>
	</cfloop>
	<!--- 12/01/2006 BDW DRK new functionality for composite Forms END --->
<!--- if coming from a new tool create, prefill form --->
<cfif isDefined("url.newdatatable")>
	<cfset form.newdatatable=url.newdatatable>
	<cfset form.label=url.label>
	<cfset form.formname=url.newdatatable>
	<cfset form.formEnvironmentID=customToolID>
</cfif>
<!--- Query for environment Type --->
<cfquery datasource="#application.datasource#" name="q_getEnvironment" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT *
	FROM formEnvironment
	WHERE active = 1 <cfif session.i3currenttool EQ application.tool.toolbuilder>AND adminonly = 1<cfelse>AND adminonly <> 1</cfif>
	ORDER BY ordinal ASC, formEnvironmentName ASC
</cfquery>

<script language="JavaScript">
<!---Hide and show Success Message--->
var message;
var parent;
function hideMessage()
{
	message = document.getElementById('successmessage');
	parent = message.parentNode;
	parent.removeChild(message);
	document.getElementById('showlink').style.display="block";
	document.getElementById('hidelink').style.display="none";
}

function showMessage()
{
	parent.appendChild(message);
	document.getElementById('showlink').style.display="none";
	document.getElementById('hidelink').style.display="block";
}

function copyField(copyThis) {
	document.showform.formname.value=copyThis;
	document.showform.formfilename.value="f_"+copyThis+".cfm";
	// Below adds the copy funtionality to the custom includes
	//document.showform.preshowform.value="admintools/includes/"+copyThis+"/i_preshowform.cfm";
	//document.showform.prevalidate.value="admintools/includes/"+copyThis+"/i_prevalidate.cfm";
	//document.showform.preconfirm.value="admintools/includes/"+copyThis+"/i_preconfirm.cfm";
	//document.showform.postconfirm.value="admintools/includes/"+copyThis+"/i_postconfirm.cfm";
	//document.showform.precommit.value="admintools/includes/"+copyThis+"/i_precommit.cfm";
	//document.showform.postcommit.value="admintools/includes/"+copyThis+"/i_postcommit.cfm";
}
<cfoutput query="q_getEnvironment">
	ID#q_getEnvironment.formEnvironmentID# = #q_getEnvironment.dataCapture#;
</cfoutput>
	function hideFields() {
		var thisID=eval('ID'+document.showform.formEnvironmentID.value);
		if (thisID) {
			document.showform.toolaction.value="dtshowform";
			document.showform.formobjectid.value="#formobjectid#";
		} else {
			document.showform.hideFields.value=1;
			document.showform.toolaction.value="dtshowform";
			document.showform.formobjectid.value="#formobjectid#";
		}
		document.showform.submit(); 
	}
<cfif len(trim(formobjectid))>
	function tableCheck() {
		<cfoutput>var hiRow=#variables.hiRow#;
		var hiCol=#variables.hiCol#;</cfoutput>
		document.getElementById('tableAlertRow').style.visibility='hidden';
		document.getElementById('tableAlertCol').style.visibility='hidden';
		if (document.showform.tablerows.value < hiRow) {
			document.getElementById('tableAlertRow').style.visibility='visible';
			alert("You are removing table rows that contain form field elements.\nTo diminish the table structure, you must first remove or reposition\nthese form elements.");
		} else if (document.showform.tablecolumns.value < hiCol) {
			document.getElementById('tableAlertCol').style.visibility='visible';
			alert("You are removing table columns that contain form field elements.\nTo diminish the table structure, you must first remove or reposition\nthese form elements.");
		} else {
			document.showform.submit();
		}
	}
</cfif>
	<!--- functionality for composite Forms --->
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
					newOptText = document.getElementById('importFormSelection')[document.getElementById('importFormSelection').selectedIndex].innerHTML+":"+document.getElementById(removeSelect)[i].innerHTML;
					//remove any wonkiness w/ & (js converts & to &amp; or &amp;amp;etc.)
					newOptText = newOptText.replace("&amp;","&");
					newOptText = newOptText.replace("amp;","");
					newOptIndex = document.getElementById(addSelect).length;
					document.getElementById(addSelect)[newOptIndex] = new Option(newOptText,newOptValue);
					document.getElementById('tablerows').value = Number(document.getElementById('tablerows').value) + 1;
				}
			}
		}   
        //remove item from removeSelect (loop backwards so indexes aren't changing as you delete)
	   if(action == "Remove"){
		   for (var i = document.getElementById(removeSelect).length-1; i >= 0; i--) {
				if (document.getElementById(removeSelect)[i].selected){
					document.getElementById(removeSelect)[i] = null;
					document.getElementById('tablerows').value = Number(document.getElementById('tablerows').value) - 1;
				}
			}
		}
        //Alpha Sort both if necessary
        if(alphaSort == "1"){
            sortSelect(document.getElementById(assignedName), true);
            //sortSelect(document.getElementById(unassignedName), true);
        }
                           
        //reset FORM.importfieldlist OR FORM.imageid
        SetFields(document.getElementById(assignedName),document.getElementById(saveList));
       
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
        lstSave.value="";
        for (t=0;t<=lst.length-1;t++){
            lstSave.value+=String(lst.options[t].value)+",";
        }
        if (lstSave.value.length>0){
            lstSave.value=lstSave.value.slice(0,-1);
        }
    }
	
	var unassignedSource = new Array();
	
	function populateUnassignFields(){
		if(unassignedSource.length == 0){
			for(i=0 ; i<document.getElementById('unassignedFields').options.length ; i++){
				unassignedSource[i] = new Option(document.getElementById('unassignedFields').options[i].text,document.getElementById('unassignedFields').options[i].value,false,false);
			}
		}
		var selectedRow = document.getElementById('importFormSelection').selectedIndex;
		var tableID = document.getElementById('importFormSelection').options[selectedRow].value;
		document.getElementById('unassignedFields').options.length = 0;
		for(i=0 ; i<unassignedSource.length ; i++){
			if(String(unassignedSource[i].value).split(':')[0] == tableID){
				document.getElementById('unassignedFields').options[document.getElementById('unassignedFields').options.length]= new Option(unassignedSource[i].text,unassignedSource[i].value,false,false);
				//document.getElementById('unassignedFields').options[i].className = 'ActiveFormFields';
			}//else{
				//document.getElementById('unassignedFields').options[i].className = 'DormantFormFields';
			//}
		}
		document.getElementById('unassignedFields').selectedIndex = -1;
	}
	function showImportForms(){
		if(document.getElementById('compositeForm').checked){
			document.getElementById('importFormSelection').disabled = null;
			document.getElementById('importFormFieldList').className = "importFormsOn";
		}else{
			document.getElementById('importFormSelection').disabled = "disabled";
			document.getElementById('importFormFieldList').className = "importFormsOff";
		}
	}
	var added = <cfif len(trim(formobjectid))>true<cfelse>false</cfif>;
	function rowCheck(o){
		if(!added && (o.value==1)){
			document.getElementById('tablerows').value = Number(document.getElementById('tablerows').value) + 1;
			added=true;
		}
	}
	function allowSetCount(){
		if(document.getElementById('createfield').checked){
			document.getElementById('createfieldcount').disabled = null;
		}else{
			document.getElementById('createfieldcount').disabled = "disabled";
		}
	}
	function setVanity(o){
		if(o.value==1){
			//alert(document.getElementById('useVanityURL').checked);
			document.getElementById('useVanityURL').checked = true;
		}
	}
	function setIncludePath(inputID){
		switch (inputID){
			case 'preshowform':
				if(document.getElementById('datatable').value.length){
				document.getElementById(inputID).value = "admintools/includes/"+document.getElementById('datatable').value+"/i_preshowform.cfm";
				}else if(document.getElementById('newdatatable').value.length){
					document.getElementById(inputID).value = "admintools/includes/"+document.getElementById('newdatatable').value+"/i_preshowform.cfm";
				}else{
					alert("You must assign a teble name to build this path");
				}
			break;
			case 'prevalidate':
				if(document.getElementById('datatable').value.length){
				document.getElementById(inputID).value = "admintools/includes/"+document.getElementById('datatable').value+"/i_prevalidate.cfm";
				}else if(document.getElementById('newdatatable').value.length){
					document.getElementById(inputID).value = "admintools/includes/"+document.getElementById('newdatatable').value+"/i_prevalidate.cfm";
				}else{
					alert("You must assign a teble name to build this path");
				}
			break;
			case 'preconfirm':
				if(document.getElementById('datatable').value.length){
				document.getElementById(inputID).value = "admintools/includes/"+document.getElementById('datatable').value+"/i_preconfirm.cfm";
				}else if(document.getElementById('newdatatable').value.length){
					document.getElementById(inputID).value = "admintools/includes/"+document.getElementById('newdatatable').value+"/i_preconfirm.cfm";
				}else{
					alert("You must assign a teble name to build this path");
				}
			break;
			case 'postconfirm':
				if(document.getElementById('datatable').value.length){
				document.getElementById(inputID).value = "admintools/includes/"+document.getElementById('datatable').value+"/i_postconfirm.cfm";
				}else if(document.getElementById('newdatatable').value.length){
					document.getElementById(inputID).value = "admintools/includes/"+document.getElementById('newdatatable').value+"/i_postconfirm.cfm";
				}else{
					alert("You must assign a teble name to build this path");
				}
			break;
			case 'precommit':
				if(document.getElementById('datatable').value.length){
				document.getElementById(inputID).value = "admintools/includes/"+document.getElementById('datatable').value+"/i_precommit.cfm";
				}else if(document.getElementById('newdatatable').value.length){
					document.getElementById(inputID).value = "admintools/includes/"+document.getElementById('newdatatable').value+"/i_precommit.cfm";
				}else{
					alert("You must assign a teble name to build this path");
				}
			break;
			case 'postcommit':
				if(document.getElementById('datatable').value.length){
				document.getElementById(inputID).value = "admintools/includes/"+document.getElementById('datatable').value+"/i_postcommit.cfm";
				}else if(document.getElementById('newdatatable').value.length){
					document.getElementById(inputID).value = "admintools/includes/"+document.getElementById('newdatatable').value+"/i_postcommit.cfm";
				}else{
					alert("You must assign a teble name to build this path");
				}
			break;
		}
	}
	function showDigest(){
		if(document.getElementById('showInDigest').checked){
			document.getElementById('showInDigest').value=1;
			document.getElementById('digestField').className = "importFormsOn";
		}else{
			document.getElementById('showInDigest').value=1;
			document.getElementById('digestField').className = "importFormsOff";
		}
	}
</script>
<!--- 12/01/2006 BDW DRK new functionality for composite Forms START --->
<style>
	.DormantFormFields{
		display: none;
	}
	.ActiveFormFields{
		display: block;
	}
	.importFormsOff{
		display: none;
	}
	.importFormsOn{
		display: ;
	}
</style>
<!--- 12/01/2006 BDW DRK new functionality for composite Forms END --->
	<cfparam name="parentstatus" default="">
	<cfparam name="form.isParent" default="1">
	<cfparam name="form.formEnvironmentID" default="">
	<cfparam name="form.datatable" default="">
	<cfparam name="form.newdatatable" default="">
	<cfparam name="form.formobjectid" default="">
	<cfparam name="form.label" default="">
	<cfparam name="form.bulkdelete" default="1">
	<cfparam name="form.singlerecord" default="0">
	<cfparam name="form.showconfirm" default="0">
	<cfparam name="form.successmsg" default="">
	<cfparam name="form.successredirect" default="">
	<cfparam name="form.successemail" default="">
	<cfparam name="form.formname" default="">
	<cfparam name="form.formfilename" default="">
	<cfparam name="form.formaction" default="">
	<cfparam name="form.formmethod" default="Post">
	<cfparam name="form.tableclass" default="tooltable">
	<cfparam name="form.tablewidth" default="600">
	<cfparam name="form.tableborder" default="0">
	<cfparam name="form.tablepadding" default="3">
	<cfparam name="form.tablespacing" default="1">
	<cfparam name="form.tablealign" default="">
	<cfparam name="form.tablecolumns" default="2">
	<cfparam name="form.tablerows" default="5">
	<cfparam name="form.preshowform" default="">
	<cfparam name="form.prevalidate" default="">
	<cfparam name="form.preconfirm" default="">
	<cfparam name="form.postconfirm" default="">
	<cfparam name="form.precommit" default="">
	<cfparam name="form.postcommit" default="">
	<cfparam name="form.toolcategoryid" default="">
	<cfparam name="form.useWorkFlow" default="0">
	<cfparam name="form.description" default="">
	<cfparam name="form.showInDigest" default="0">
	<!--- 12//08/2006 DRK newfunctionality for mapped content --->
	<cfparam name="form.useMappedContent" default="0">
	<cfparam name="form.useOrdinal" default="0">
	<!--- 12/04/2006 DRK new functionality for composite Forms one line --->
	<cfparam name="form.compositeForm" default="0">
	<!--- 3/2/2007 DRK sekey and navigation --->
	<cfparam name="form.useVanityURL" default="0">
	<cfparam name="form.isNavigable" default="0">
	<!--- <cfparam name="form.restrictByUserType" default="0"> --->
<cfoutput>
<cfif isDefined('URL.templateName') AND isDefined('URL.sourceFolder')>
	<cfinclude template="#APPLICATION.customTagPath#/formbuilder/includes/i_createToolPost.cfm">
</cfif>
<form action="#request.page#" method="post" name="showform">
<input name="toolaction" type="hidden" value="DTPost" />
<input type="Hidden" name="hideFields" value="">
<input type="Hidden" name="formobjectid" value="#formobjectid#">
<input type="Hidden" name="isParent" value="#form.isParent#">
<cfif isDefined('URL.templateName') AND isDefined('URL.sourceFolder')>
	<input type="Hidden" name="templateName" value="#URL.templateName#">
	<input type="Hidden" name="sourceFolder" value="#URL.sourceFolder#">
</cfif>
<!--- CMC MOD 1/11/07: take success email out of validation to allow comma delim list [successemail,email;] --->
<input type="Hidden" name="validatelist" value="formEnvironmentID,required;newdatatable,reservedword;label,required;formname,required;formname,filename;tablerows,int;tablecolumns,int;useWorkFlow,required;newdatatable,filename;<cfif isDefined('q_getform') AND NOT (q_getform.formobjectid eq q_getform.parentid)>tableclass,filename;tableborder,int;</cfif>">
<input name="formname" type="hidden" value="#form.formname#" />
<input name="formfilename" type="hidden" value="#form.formfilename#" />

<cfquery name="q_getTables" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT name 
	FROM sysobjects 
	WHERE xtype='u' AND name <> 'dtproperties'
	ORDER BY name ASC
</cfquery>
<div id="socketformheader"><h2><cfif session.i3currenttool eq application.tool.toolbuilder>Socket Tool Builder<cfelse>Form Builder</cfif></h2><div id="returnToIndex"><a href="/admintools/index.cfm?i3currentTool=#session.i3currentTool#" >&lt; Socket Listing Index</a></div>
</div><div style="clear:both;"></div>

<table cellpadding="3" cellspacing="1" border="0" id="socketformtable" width="" >
<tr>
	<td colspan="2">
		<p>The first step in creating a new Socket Tool is to define the general settings for your new tool which help to define the data table and the basic layout of the data entry form. Most of the fields are preselected to use the most common default values.</p>
	</td>
</tr>
<!--- Show errors if i_validate.cfm found any... --->
<cfif isDefined("request.isError") AND request.isError eq 1>
<tr>
	<td colspan="2">
	<div id="errorBlock">
		<h2>Errors found...</h2>
		<ul>
			<cfloop list="#request.errorMsg#" index="error" delimiters="||">
				<li>#error#</li>
			</cfloop>
		</ul>
	</div>
	</td>
</tr>
</cfif>
<tr>
	<td class="formitemlabelreq" colspan="2">#parentstatus#</td>
</tr>
<tr>
	<td class="formitemlabelreq" width="30%">Choose type of form:</td>
	<td class="formiteminput" width="70%">
		<select name="formEnvironmentID" size="1"<!---  onChange="javascript: hideFields();" --->>
			<option value="">Choose Socket Shell Type</option>
			<cfloop query="q_getEnvironment">
				<option value="#q_getEnvironment.formEnvironmentID#"<cfif q_getEnvironment.formEnvironmentID eq form.formEnvironmentID> SELECTED</cfif>>#q_getEnvironment.formEnvironmentName#</option>
			</cfloop>
		</select>
	</td>
</tr>
<cfif session.i3currenttool EQ application.tool.toolbuilder>
<cfquery datasource="#application.datasource#" name="q_getToolCategories" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT *
	FROM toolcategory
	ORDER BY toolcategoryname ASC
</cfquery>
<tr>
	<td class="formitemlabelreq">Tool Category:</td>
	<td class="formiteminput"><select name="toolcategoryid" size="1">
			<option value="">Choose a Category</option>
			<cfloop query="q_getToolCategories">
				<option value="#q_getToolCategories.toolcategoryid#~#q_getToolCategories.toolcategoryname#"<cfif q_getToolCategories.toolcategoryid eq form.toolcategoryid> SELECTED</cfif>>#q_getToolCategories.toolcategoryname#</option>
			</cfloop>
		</select></td>
</tr>
<cfelse>
<input type="Hidden" name="toolcategoryid" value="0">
</cfif>
<cfif len(trim(formobjectid)) OR (isDefined("hideFields") AND hideFields EQ 1)>
	<input type="Hidden" name="datatable" id="datatable" value="#datatable#">
	<input type="Hidden" name="newdatatable" value="">
<cfelse>
<tr>
	<td class="formitemlabelreq">Data Table Name:</td>
	<td class="formiteminput"><input type="text" name="newdatatable" id="newdatatable" value="#form.newdatatable#" size="20" maxlength="250" onblur="copyField(this.value);"><cfif isDefined('URL.templateName')>&nbsp;If using template to create a duplicate table, you must change the table name.</cfif></td>
</tr>
<input type="Hidden" name="datatable" value="" id="datatable">
</cfif>

<tr>
	<td class="formitemlabelreq">Label:</td>
	<td class="formiteminput"><input name="label" type="text" size="40" value="#form.label#"></td>
</tr>
<cfif session.i3currenttool EQ application.tool.toolbuilder> 
    <tr>
        <td class="formitemlabel">Work Flow &amp; Versioning:</td>
        <td class="formiteminput"><cfif len(trim(formobjectid))><cfif form.useWorkFlow EQ 1>Yes</cfif><cfif form.useWorkFlow EQ 0>No</cfif><input type="hidden" name="useWorkFlow" value="#form.useWorkFlow#" /><cfelse><input name="useWorkFlow" type="radio" value="1" <cfif len(trim(formobjectid))>disabled="disabled"</cfif><cfif form.useWorkFlow EQ 1> CHECKED</cfif>> Yes <input name="useWorkFlow" type="radio" value="0" <cfif len(trim(formobjectid))>disabled="disabled"</cfif><cfif form.useWorkFlow EQ 0> CHECKED</cfif>> No</cfif></td>
    </tr>
    <!--- Remove Comment to Enable Content Mapping Functionality
    <tr>
        <td class="formitemlabel">Use Mapped Content:</td>
        <td class="formiteminput"><input name="useMappedContent" onchange="rowCheck(this)" type="radio" value="1" <cfif form.useMappedContent EQ 1> CHECKED</cfif>> Yes <input name="useMappedContent" onchange="rowCheck(this)" type="radio" value="0" <cfif form.useMappedContent EQ 0> CHECKED</cfif>> No</td>
    </tr>
    --->
    <tr>
        <td class="formitemlabel">Ordinal Step:</td>
        <td class="formiteminput"><input name="useOrdinal" type="radio" value="1"<cfif form.useOrdinal EQ 1> CHECKED</cfif>> Yes <input name="useOrdinal" type="radio" value="0"<cfif form.useOrdinal EQ 0> CHECKED</cfif>> No</td>
    </tr>
    <tr>
        <td class="formitemlabel">Bulk Delete:</td>
        <td class="formiteminput"><input name="bulkdelete" type="radio" value="1"<cfif form.bulkdelete EQ 1> CHECKED</cfif>> Yes <input name="bulkdelete" type="radio" value="0"<cfif form.bulkdelete EQ 0> CHECKED</cfif>> No</td>
    </tr>
    <tr>
        <td class="formitemlabel">Single Record:</td>
        <td class="formiteminput"><input name="singleRecord" type="radio" value="1"<cfif form.singleRecord EQ 1> CHECKED</cfif>> Yes <input name="singleRecord" type="radio" value="0"<cfif form.singleRecord EQ 0> CHECKED</cfif>> No</td>
    </tr>
    <!--- 3/2/2007 DRK sekey and navigation --->
    <tr>
        <td class="formitemlabel">Use Friendly URL:</td>
        <td class="formiteminput"><cfif len(trim(formobjectid))><cfif form.useVanityURL EQ 1>Yes</cfif><cfif form.useVanityURL EQ 0>No</cfif><input type="hidden" name="useVanityURL" value="#form.useVanityURL#" /><cfelse><input name="useVanityURL" id="useVanityURL" type="radio" value="1" onchange="rowCheck(this)" <cfif len(trim(formobjectid))>disabled="disabled"</cfif><cfif form.useVanityURL EQ 1> CHECKED</cfif>> Yes <input name="useVanityURL" id="useVanityURL" onchange="rowCheck(this)" type="radio" value="0" <cfif len(trim(formobjectid))>disabled="disabled"</cfif><cfif form.useVanityURL EQ 0> CHECKED</cfif>> No</cfif></td>
    </tr>
    <!--- 3/2/2007 DRK coming soon !!! --->
    <tr>
        <td class="formitemlabel">Records are Navigable:</td>
        <td class="formiteminput"><cfif len(trim(formobjectid))><cfif form.isNavigable EQ 1>Yes</cfif><cfif form.isNavigable EQ 0>No</cfif><input type="hidden" name="isNavigable" value="#form.isNavigable#" /><cfelse><input name="isNavigable" onchange="setVanity(this)" type="radio" value="1" <cfif len(trim(formobjectid))>disabled="disabled"</cfif><cfif form.isNavigable EQ 1> CHECKED</cfif>> Yes <input name="isNavigable" onchange="setVanity(this)" type="radio" value="0" <cfif len(trim(formobjectid))>disabled="disabled"</cfif><cfif form.isNavigable EQ 0> CHECKED</cfif>> No</cfif><cfif NOT len(trim(formobjectid))>&nbsp; Use only if you plan on using navigation to individual items</cfif></td>
    </tr>

<cfelse>
	<input type="hidden" name="useWorkFlow" value="#form.useWorkFlow#" />
	<input type="hidden" name="useOrdinal" value="#form.useOrdinal#" />
	<input type="hidden" name="bulkdelete" value="#form.bulkdelete#" />
	<input type="hidden" name="singleRecord" value="#form.singleRecord#" />
	<input type="hidden" name="useVanityURL" value="#form.useVanityURL#" />
	<input type="hidden" name="isNavigable" value="#form.isNavigable#" />
</cfif>

<!--- <tr>
	<td class="formitemlabel">Restrict by User Type:</td>
	<td class="formiteminput"><input name="restrictByUserType" type="radio" value="1"<cfif form.restrictByUserType EQ 1> CHECKED</cfif>> Yes <input name="restrictByUserType" type="radio" value="0"<cfif form.restrictByUserType EQ 0> CHECKED</cfif>> No</td>
</tr> --->
<!--- 12/01/2006 BDW DRK new functionality for compisite Forms START --->
<cfif session.i3currenttool eq application.tool.toolbuilder>
<tr>
	<td class="subtoolheader" colspan="2"><strong>Import Existing Forms</strong><input id="compositeForm" type="checkbox" name="compositeForm" onchange="showImportForms()" <cfif isDefined('form.compositeForm') AND form.compositeForm EQ 1>checked</cfif> /></td>
</tr>
<input type="hidden" name="importfieldlist" id="importfieldlist" value="" />
<tr id="importFormTableList" class="importFormsOn" >
	<td class="formitemlabel">Select Forms:</td>
	<td class="formiteminput">
		<select id="importFormSelection" name="importFormSelection" <cfif (NOT isDefined('form.compositeForm')) OR (form.compositeForm EQ 0) OR (len(trim(form.compositeForm)) EQ 0)>disabled="disabled"</cfif> onchange="populateUnassignFields()" >
			<option value="0" >- Select Form -</option>
			<cfloop index="i" from="1" to="#arrayLen(selectableFormImportData)#">
				<!--- if edit don't include current table otherwise include --->
				<cfif NOT len(trim(formobjectid)) OR (len(trim(formobjectid)) AND selectableFormImportData[i].formobjectid NEQ formobjectid)>
				<option value="#selectableFormImportData[i].formobjectid#">#selectableFormImportData[i].formobjectname#</option>
				</cfif>
			</cfloop>
		</select>
	</td>
</tr>
<tr id="importFormFieldList" class="importForms<cfif isDefined('FORM.compositeForm') AND FORM.compositeForm EQ 1>ON<cfelse>Off</cfif>">
	<td class="formitemlabel">Fields:</td>
	<td class="formiteminput">
		<table width=""  border="0" cellspacing="5" cellpadding="0" align="center">       
        <tr>
            <td><strong>Available</strong></td>
            <td>&nbsp;</td>
            <td><strong>Assigned</strong></td>                   
        </tr>
		
        <tr>
            <!--- Unassigned Select --->
            <td width="40%" align="left">
                <select name="unassignedFields" id="unassignedFields" multiple size="7">
					<cfloop index="i" from="1" to="#arrayLen(selectableFormImportData)#">
						<cfloop  index="j" from="1" to="#arrayLen(selectableFormImportData[i].fields)#">
							<option value="#selectableFormImportData[i].formobjectid#:#selectableFormImportData[i].fields[j]#" class="DormantFormFields">#selectableFormImportData[i].fields[j]#</option>
						</cfloop>
					</cfloop>
                </select>
            </td>
            <!--- Add/Remove Buttons --->
            <td align="center" valign="middle">
				<div>Assign</div>
				<div><input type="button" name="add" class="submitbutton" value="&gt;"  onClick="MoveSelected('Add','assignedFields','unassignedFields','importfieldlist','1');"></div>
				<div>UnAssign</div>
				<div><input type="button" name="add" class="submitbutton" value="&lt;"  onClick="MoveSelected('Remove','assignedFields','unassignedFields','importfieldlist','1');"></div>
            </td>
            <!--- Assigned Select --->
            <td width="40%" align="left">
                <select name="assignedFields" id="assignedFields" multiple size="7">
                    <!--- <cfif isDefined('q_Assigned')>
                        <cfloop index="i">
                            <option value=""></option>
                        </cfloop>
                    </cfif> --->
                </select>
            </td>
        </tr>
    </table></td>
</tr>
</cfif>
<!--- 12/01/2006 BDW DRK new functionality for compisite Forms END --->
<tr>
	<td class="subtoolheader" colspan="2"><strong>Form Controls</strong></td>
</tr>
<tr>
	<td class="formitemlabel">Show Confirmation:</td>
	<td class="formiteminput"><input type="radio" name="showconfirm" value="1"<cfif form.showconfirm> checked</cfif>>Yes <input type="radio" name="showconfirm" value="0"<cfif NOT form.showconfirm> checked</cfif>>No</td>
</tr>
<!--- 3/2/2007 DRK only show form controls for front end --->
<cfif isDefined('q_getform') AND NOT (q_getform.formobjectid eq q_getform.parentid)>
<!--- 6/18/2008 Inserted Show Link and WysiwygEditor--->
 <tr >
	<td class="formitemlabel" id="successlabel"><a onclick="javascript:showMessage()" style="cursor:pointer"  id="showlink"><b>Create Success Message</b></a><a id="hidelink"  onclick="javascript:hideMessage()" style="cursor:pointer"><b>Hide Success Message</b></a></td>
	<td class="formiteminput"  id="successmessage">
		<cfscript>
			fckEditor = createObject("component", "#application.globalPath#/fckeditor/#application.fckVersion#/fckeditor");								
			fckEditor.basePath		= "#application.globalPath#/fckeditor/#application.fckVersion#/";
			fckEditor.instanceName	= "successmsg";
			fckEditor.value			= "#form.successmsg#";
			fckEditor.width			= "496";
			fckEditor.height		= "296";
			fckEditor.toolbarSet	= "Default";
			fckEditor.create();
		</cfscript>
	<!--- <textarea cols="30" rows="3" name="successmsg" id="successmsg">#form.successmsg#</textarea> --->
	</td>
</tr>
<tr>
	<td class="formitemlabel">Success Redirect:</td>
	<td class="formiteminput"><input name="successredirect" type="text" size="40" value="#form.successredirect#"></td>
</tr>
<tr>
	<td class="formitemlabel">Success Email:</td>
	<td class="formiteminput"><input name="successemail" type="text" size="40" value="#form.successemail#"></td>
</tr>
<!--- <tr>
	<td class="formitemlabel">Action:<br>(if not self-posting)</td>
	<td class="formiteminput"><input name="formaction" type="text" size="40" value="#form.formaction#"></td>
</tr>
<tr>
	<td class="formitemlabel">Method:</td>
	<td class="formiteminput">
	<select name="formmethod">
		<option value="Post"<cfif form.formmethod eq 'Post'> selected</cfif>>Post</option>
		<option value="Get"<cfif form.formmethod eq 'Get'> selected</cfif>>Get</option>
	</select></td>
</tr> --->
<cfelse>
	<input type="hidden" name="formmethod" value="Post" />
	<input type="hidden" name="successmsg" value="" />
	<input type="hidden" name="successredirect" value="" />
	<input type="hidden" name="successemail" value="" />
</cfif>
<tr>
	<td class="subtoolheader" colspan="2"><strong>HTML Table Controls</strong></td>
</tr>
<!--- 3/2/2007 DRK only show form controls for front end --->
<cfif isDefined('q_getform') AND NOT (q_getform.formobjectid eq q_getform.parentid)>
<tr>
	<td class="formitemlabel">Table CSS Class:</td>
	<td class="formiteminput"><input name="tableclass" type="text" size="15" value="#form.tableclass#"></td>
</tr>
<tr>
	<td class="formitemlabel">Table Align:</td>
	<td class="formiteminput">
	<select name="tablealign">
		<option value="">Select alignment</option>
		<option value="Center"<cfif form.tablealign eq 'Center'> selected</cfif>>Center</option>
		<option value="Left"<cfif form.tablealign eq 'Left'> selected</cfif>>Left</option>
		<option value="Right"<cfif form.tablealign eq 'Right'> selected</cfif>>Right</option>
	</select></td>
</tr>
<cfelse>
	<input type="hidden" name="tableclass" value="" />
	<input type="hidden" name="tablealign" value="" />
</cfif>

<!--- If there URL.addRow = 1 add a row to current number and submit form if URL.addRow = -1 delete row and submit---> 
<cfif isdefined("URL.addRow") AND URL.addRow GT 0>
	<cfset newTableRows = #form.tablerows#+1>
<cfelseif isdefined("URL.addRow") AND URL.addRow LT 0>
	<cfset newTableRows = #form.tablerows#-1>
</cfif>

<tr>
	<td class="formitemlabel">Number of Rows:</td>
	<td class="formiteminput"><input id="tablerows" name="tablerows" type="text" size="10" <cfif isdefined("newTableRows") AND isnumeric(newTableRows)>value="#newTableRows#"<cfelse>value="#form.tablerows#" maxlength="10"></cfif><cfif len(trim(formobjectid))>&nbsp;&nbsp;&nbsp;<span id="tableAlertRow" style="visibility: hidden; background-color: ##cc0000; color: ##ffffff; font-weight: bold; padding: 5px,5px,5px,5px;">This value can't be less than #hiRow#.</span></cfif>
	</td>
</tr>
<tr>
	<td class="formitemlabel">Number of Columns:</td>
	<td class="formiteminput"><input name="tablecolumns" type="text" size="10" value="#form.tablecolumns#" maxlength="10"><cfif len(trim(formobjectid))>&nbsp;&nbsp;&nbsp;<span id="tableAlertCol" style="visibility: hidden; background-color: ##cc0000; color: ##ffffff; font-weight: bold; padding: 5px,5px,5px,5px;">This value can't be less than #hiCol#.</span></cfif></td>
</tr>
<!--- 3/2/2007 DRK only show form controls for front end --->
<cfif isDefined('q_getform') AND NOT (q_getform.formobjectid eq q_getform.parentid)>
<tr>
	<td class="formitemlabel">Table Width:</td>
	<td class="formiteminput"><input name="tablewidth" type="text" size="10" value="#form.tablewidth#" maxlength="10"></td>
</tr>
<tr>
	<td class="formitemlabel">Table Border:</td>
	<td class="formiteminput"><input name="tableborder" type="text" size="10" value="#form.tableborder#" maxlength="10"></td>
</tr>
<tr>
	<td class="formitemlabel">Cell Padding:</td>
	<td class="formiteminput"><input name="tablepadding" type="text" size="10" value="#form.tablepadding#" maxlength="10"></td>
</tr>
<tr>
	<td class="formitemlabel">Cell Spacing:</td>
	<td class="formiteminput"><input name="tablespacing" type="text" size="10" value="#form.tablespacing#" maxlength="10"></td>
</tr>
<cfelse>
	<input type="hidden" name="tablewidth" value="100%" />
	<input type="hidden" name="tableborder" value="0" />
	<input type="hidden" name="tablepadding" value="0" />
	<input type="hidden" name="tablespacing" value="0" />
</cfif>
<tr>
	<td class="subtoolheader" colspan="2"><strong>Custom Interrupt Includes</strong></td>
</tr>
<tr>
	<td class="formitemlabel">Pre-Show Form:</td>
	<td class="formiteminput"><cfif isDefined("q_getForm.serverroot")>/#q_getForm.serverroot#/</cfif><input name="preshowform" id="preshowform" type="text" size="40" value="#form.preshowform#" maxlength="255"><input type="button" value="Default Path" class="submitbutton" onclick="setIncludePath('preshowform');" /></td>
</tr>
<tr>
	<td class="formitemlabel">Pre-Validate Form:</td>
	<td class="formiteminput"><cfif isDefined("q_getForm.serverroot")>/#q_getForm.serverroot#/</cfif><input name="prevalidate" id="prevalidate" type="text" size="40" value="#form.prevalidate#" maxlength="255"><input type="button" value="Default Path" class="submitbutton" onclick="setIncludePath('prevalidate');" /></td>
</tr>
<tr>
	<td class="formitemlabel">Pre-Confirm Form:</td>
	<td class="formiteminput"><cfif isDefined("q_getForm.serverroot")>/#q_getForm.serverroot#/</cfif><input name="preconfirm" id="preconfirm" type="text" size="40" value="#form.preconfirm#" maxlength="255"><input type="button" value="Default Path" class="submitbutton" onclick="setIncludePath('preconfirm');" /></td>
</tr>
<tr>
	<td class="formitemlabel">Post-Confirm Form:</td>
	<td class="formiteminput"><cfif isDefined("q_getForm.serverroot")>/#q_getForm.serverroot#/</cfif><input name="postconfirm" id="postconfirm" type="text" size="40" value="#form.postconfirm#" maxlength="255"><input type="button" value="Default Path" class="submitbutton" onclick="setIncludePath('postconfirm');" /></td>
</tr>
<tr>
	<td class="formitemlabel">Pre-Commit Form:</td>
	<td class="formiteminput"><cfif isDefined("q_getForm.serverroot")>/#q_getForm.serverroot#/</cfif><input name="precommit" id="precommit" type="text" size="40" value="#form.precommit#" maxlength="255"><input type="button" value="Default Path" class="submitbutton" onclick="setIncludePath('precommit');" /></td>
</tr>
<tr>
	<td class="formitemlabel">Post-Commit Form:</td>
	<td class="formiteminput"><cfif isDefined("q_getForm.serverroot")>/#q_getForm.serverroot#/</cfif><input name="postcommit" id="postcommit" type="text" size="40" value="#form.postcommit#" maxlength="255"><input type="button" value="Default Path" class="submitbutton" onclick="setIncludePath('postcommit');" /></td>
</tr>
<cfif session.i3currenttool EQ application.tool.toolbuilder>
<tr>
	<td class="subtoolheader" colspan="2"><strong>Show Digest Entry</strong><input id="showInDigest" type="checkbox" name="showInDigest" onchange="showDigest()" <cfif isDefined('form.showInDigest') AND form.showInDigest EQ 1>checked value="1"<cfelse>value="0"</cfif> /></td>
</tr>
<cfelse>
	<input type="hidden" name="showInDigest" id="showInDigest" value="#form.showInDigest#" />
</cfif>
<tr id="digestField" class="importForms<cfif isDefined('form.showInDigest') AND form.showInDigest EQ 1>On<cfelse>Off</cfif>" >
	<td class="formitemlabel">Digest Tool Summary:</td>
	<td class="formiteminput">
		<textarea id="description" name="description" cols="50" rows="5">#FORM.description#</textarea>
	</td>
</tr>
<cfif session.i3currenttool EQ application.tool.toolbuilder>
<tr>
	<td class="subtoolheader" colspan="2"><strong>Fill Data (Greeking) Creation:</strong></td>
</tr>
</cfif>
<tr>
	<td class="formitemlabel">Create Test Data:</td>
	<td class="formiteminput">
	<input type="checkbox" name="createfield" id="createfield" onchange="allowSetCount()" /> 
		Number of records to generate: <select name="createfieldcount" id="createfieldcount" disabled="disabled" >
		<option value="1">1</option>
		<option value="3">3</option>
		<cfloop from="1" to="10" index="i">
			<option value="#val(i*5)#">#val(i*5)#</option>
		</cfloop>
	</select><br />
	<strong>Note:</strong> Test data is not created until the last step of Socket Tool Builder.
</td>
</tr>

<!--- JPL 5-14-2008 Changed to different display in Form Builder --->
<cfif len(formobjectid)>
<tr>
	<td <!--- class="formitemlabel"  --->colspan="2" align="center">
		<cfif isDefined('q_getform') AND NOT (q_getform.formobjectid eq q_getform.parentid)>
			<input type="button" class="submitbutton" value="Save Form" onClick="javascript:tableCheck();" style="margin-left:0px; margin-right:15px; width:90px;">
			<input type="button" class="deletebutton" value="Delete Form" style="width:90px;" onclick="javascript:document.deleteForm.submit()">
		<cfelse>
			<input type="button" class="submitbutton" value="Save Socket Tool" onClick="javascript:tableCheck();" style="margin-left:0px; margin-right:15px; width:90px;">
			<input type="button" class="deletebutton" value="Delete Socket" style="width:90px;" onclick="javascript:document.deleteForm.submit()">
		</cfif>
	</td>
</tr>
<cfelse>
<tr>
	<td <!--- class="formitemlabel"  --->colspan="2" align="center">
		<input type="Submit" class="submitbutton" value="Create New Socket Tool" style="margin-left:0px; margin-right:15px;">
	</td>
</tr>
</cfif>

</form>
<cfif isdefined("URL.addRow") AND URL.addRow>
	<script type="text/javascript">
		tableCheck();
	</script>
</cfif>
<cfif len(formobjectid)>
	<form id="deleteForm" name="deleteForm" action="#request.page#" method="post">
	<input type="Hidden" name="toolaction" value="deleteobject">
	<input type="Hidden" name="objectname" value="#form.label#">
	<input type="Hidden" name="formobjectid" value="#formobjectid#">
	<input type="Hidden" name="datatable" value="#form.datatable#">
	</form>
	<!--- <tr>
		<td <!--- class="formitemlabel"  --->colspan="2" align="center"><input type="Submit" class="deletebutton" value="Delete Socket" style="width:90px;"></td>
	</form>
	</tr> --->
</cfif>
</table>
<script language="JavaScript">
hideMessage();
</script>
</cfoutput>
