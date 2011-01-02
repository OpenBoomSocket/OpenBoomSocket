<cfif isDefined("formobjectid")>
	<cfinclude template="i_getFormobject.cfm">
</cfif>

<!--- If this is a child form, create a link to master --->
	<cfif q_getform.formobjectid eq q_getform.parentid>
		<cfset parentstatus="<span style=""color:##ff0000; font-weight: bold;"">MASTER FORM</span>">
		<cfset lockField=0>
	<!--- get all children of this form --->
		<cfquery datasource="#application.datasource#" name="q_getAllChildren" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT label, formobjectid
			FROM formobject
			WHERE parentid = #formobjectid# AND formobjectid <> #formobjectid#
		</cfquery>
	<cfelse>
		<cfquery datasource="#application.datasource#" name="q_parent" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT label, formobjectid
			FROM formobject
			WHERE formobjectid = #q_getform.parentid#
		</cfquery>
		<cfset lockField=1>
		<cfset parentstatus="Instance of <a href=""#request.page#?toolaction=DEShowForm&formobjectid=#q_parent.formobjectid#"" title=""Click here to edit the master form."">#q_parent.label#</a>">
	</cfif>
<cfquery name="q_getTables" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT name 
	FROM sysobjects 
	WHERE xtype='u' AND name <> 'dtproperties'
	ORDER BY name ASC
</cfquery>
<!--- If fieldname is available, deserialize form element data and set vars --->
<cfif isDefined("fieldname")>
	<cfif isDefined("edit")>
		<cfset fieldname=edit>
	</cfif>
	<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
        input="#q_getform.datadefinition#"
        output="a_formelements">

	<cfloop index="x" from="1" to="#arrayLen(a_formelements)#">
		<cfif a_formelements[x].fieldname eq fieldname>
			<cfparam name="form.fieldname" default="#a_formelements[x].fieldname#">
			<cfparam name="form.objectlabel" default="#a_formelements[x].objectlabel#">
			<cfparam name="form.datatype" default="#a_formelements[x].datatype#">
			<cfparam name="form.length" default="#a_formelements[x].length#">
			<cfparam name="form.pk" default="#a_formelements[x].pk#">
			<cfparam name="form.required" default="#a_formelements[x].required#">
			<cfparam name="form.validate" default="#a_formelements[x].validate#">
			<cfparam name="form.inputtype" default="#a_formelements[x].inputtype#">
			<cfparam name="form.maxlength" default="#a_formelements[x].maxlength#">
			<cfparam name="form.height" default="#a_formelements[x].height#">
			<cfparam name="form.width" default="#a_formelements[x].width#">
			<cfparam name="form.lookuptype" default="#a_formelements[x].lookuptype#">
			<cfparam name="form.lookuplist" default="#a_formelements[x].lookuplist#">
			<cfparam name="form.lookupquery" default="#a_formelements[x].lookupquery#">
			<cfparam name="form.lookuptable" default="#a_formelements[x].lookuptable#">
			<cfparam name="form.lookupkey" default="#a_formelements[x].lookupkey#">
			<cfparam name="form.lookupdisplay" default="#a_formelements[x].lookupdisplay#">
			<cfparam name="form.lookupmultiple" default="#a_formelements[x].lookupmultiple#">
			<cfparam name="form.defaultvalue" default="#a_formelements[x].defaultvalue#">
			<cfparam name="form.inputstyle" default="#a_formelements[x].inputstyle#">
			<cfparam name="form.gridposlabel" default="#a_formelements[x].gridposlabel#">
			<cfparam name="form.gridposvalue" default="#a_formelements[x].gridposvalue#">
			<cfparam name="form.commit" default="#a_formelements[x].commit#">
			<cfparam name="form.javascript" default="#a_formelements[x].javascript#">
			<cfparam name="form.javascriptHandler" default="#a_formelements[x].javascriptHandler#">
			<cfparam name="form.readonly" default="#a_formelements[x].readonly#">
			<cfparam name="form.tabindex" default="#a_formelements[x].tabindex#">
			<cfparam name="form.arrayposition" default="#x#">
			<cfif form.inputtype eq "filechooser">
				<cfparam name="form.uploadcategoryid" default="#a_formelements[x].uploadcategoryid#">
			<cfelseif form.inputtype eq "guestrolechooser">
				<cfparam name="form.uploadcategoryid" default="#a_formelements[x].uploadcategoryid#">
			<cfelseif form.inputtype eq "formatonly">
				<cfparam name="form.formatonly" default="#a_formelements[x].formatonly#">
			<cfelseif form.inputtype eq "custominclude">
				<cfparam name="form.custominclude" default="#a_formelements[x].custominclude#">
			<cfelseif form.inputtype eq "image">
				<cfparam name="form.imagebuttonpath" default="#a_formelements[x].imagebuttonpath#">
			<cfelseif form.inputtype eq "submit">
				<cfparam name="form.submitbuttonimage" default="#a_formelements[x].submitbuttonimage#">
			<cfelseif form.inputtype eq "cancel">
				<cfparam name="form.cancelbuttonimage" default="#a_formelements[x].cancelbuttonimage#">
			<cfelseif form.inputtype eq "sekeyname">
				<cfparam name="form.sekeynamefield" default="#a_formelements[x].sekeynamefield#">
			<cfelseif form.inputtype eq "bs_pageTitle">
				<cfparam name="form.bs_pageTitlefield" default="#a_formelements[x].bs_pageTitlefield#">
			</cfif>
			<!--- 12/04/2006 DRK check if import field used to disable commit checkbox--->
			<cfif arrayLen(structFindKey(#a_formelements[x]#,"SOURCEFORMOBJECTID"))>
				<cfparam name="form.SOURCEFORMOBJECTID" default="#a_formelements[x].SOURCEFORMOBJECTID#">
			<cfelse>
				<cfparam name="form.SOURCEFORMOBJECTID" default="0">
			</cfif>
			<!--- 12/05/2006 DRK foreign key id save/dont't save switch for imported fields --->
			<cfif arrayLen(structFindKey(#a_formelements[x]#,"COMMITFOREIGNTABLE"))>
				<cfparam name="form.COMMITFOREIGNTABLE" default="#a_formelements[x].COMMITFOREIGNTABLE#">
			</cfif>
			<cfif arrayLen(structFindKey(#a_formelements[x]#,"FOREIGNKEY"))>
				<cfparam name="form.FOREIGNKEY" default="#a_formelements[x].FOREIGNKEY#">
			</cfif>
			<!--- 12/08/2006 DRK content mapping fields --->
			<cfif arrayLen(structFindKey(#a_formelements[x]#,"useMappedContent"))>
				<cfparam name="form.useMappedContent" default="#a_formelements[x].useMappedContent#">
			</cfif>
			<!--- 12/14/2006 DRK master key flag for update/insert ordering --->
			<cfif arrayLen(structFindKey(#a_formelements[x]#,"ISMASTERTABLE"))>
				<cfparam name="form.ISMASTERTABLE" default="#a_formelements[x].ISMASTERTABLE#">
			</cfif>
		</cfif>
	</cfloop>
</cfif>

<cfparam name="form.fieldname" default="">
<cfparam name="form.objectlabel" default="">
<cfparam name="form.datatype" default="">
<cfparam name="form.length" default="">
<cfparam name="form.pk" default="0">
<cfparam name="form.required" default="0">
<cfparam name="form.validate" default="">
<cfparam name="form.inputtype" default="">
<cfparam name="form.maxlength" default="">
<cfparam name="form.height" default="">
<cfparam name="form.width" default="">
<cfparam name="form.lookuptype" default="">
<cfparam name="form.lookuplist" default="">
<cfparam name="form.lookupquery" default="">
<cfparam name="form.lookuptable" default="">
<cfparam name="form.lookupkey" default="">
<cfparam name="form.lookupdisplay" default="">
<cfparam name="form.lookupmultiple" default="">
<cfparam name="form.defaultvalue" default="">
<cfparam name="form.inputstyle" default="">
<cfparam name="form.gridposlabel" default="">
<cfparam name="form.gridposvalue" default="">
<cfparam name="form.javascript" default="">
<cfparam name="form.javascriptHandler" default="">
<cfparam name="form.tabindex" default="">
<cfparam name="form.readonly" default="">
<cfparam name="form.commit" default="1">
<!--- 12/04/2006 DRK pass along table id for imported fields ---> 
<cfparam name="form.SOURCEFORMOBJECTID" default="0">
<!--- Used to support update of exisating composite form --->
<cfparam name="form.ISMASTERTABLE" default="0">
<cfif form.inputtype eq "filechooser">
	<cfparam name="form.uploadcategoryid" default="">
<cfelseif form.inputtype eq "guestrolechooser">
	<cfparam name="form.uploadcategoryid" default="">
<cfelseif form.inputtype eq "formatonly">
	<cfparam name="form.formatonly" default="">
	<cfset form.commit=0>
<cfelseif form.inputtype eq "custominclude">
	<cfparam name="form.custominclude" default="admintools/includes/#request.q_getform.formname#/">
<cfelseif form.inputtype eq "image">
	<cfparam name="form.imagebuttonpath" default="media/images/">
	<cfset form.commit=0>
<cfelseif form.inputtype eq "submit">
	<cfparam name="form.submitbuttonimage" default="media/images/">
	<cfset form.commit=0>
<cfelseif form.inputtype eq "cancel">
	<cfparam name="form.cancelbuttonimage" default="media/images/">
	<cfset form.commit=0>
<cfelseif form.inputtype eq "sekeyname">
	<cfparam name="form.sekeynamefield" default="">
<cfelseif form.inputtype eq "bs_pageTitle">
	<cfparam name="form.bs_pageTitlefield" default="">
<cfelseif form.inputtype eq "useMappedContent">
	<!--- 12/08/2006 DRK content mapping fields --->
	<cfparam name="form.useMappedContent" default="0">
</cfif>
<cfparam name="form.toolaction" default="">
<cfoutput>
<script language="JavaScript" type="text/javascript">
	<cfif isDefined("q_getAllChildren.formobjectid") AND q_getAllChildren.recordcount GT 0>
		function gotoChildForm(formobjectid){
			if (formobjectid != 0){
				var url="#request.page#?toolaction=DEShowForm&formobjectid="+formobjectid;
				window.open(url,"_self");
			}
		}
	</cfif>
		function nonCommit() { 
			<cfif isDefined("fieldname")>
				alert("By un-checking Commit, you will be deleting this\ntable column as well as all of the data it contains.\nAre you sure you wish to do this?");
			<cfelse>
				alert("By un-checking Commit, you are not going to be writing \nthe data in this field in the database. \nRe-check the box if you do wish to capture data.");
			</cfif>
			}
		function nonCommitForeign() { 
				alert("By un-checking Commit, you are not going to be writing \nthe data in this field in the database. \nRe-check the box if you do wish to capture data.");
			}
	<cfif isDefined("fieldname")>
		function deleteField(name) {
			<cfif len(fieldname)>
				name='#fieldname#';
			</cfif>
			<cfif listlast(form.commit) AND NOT lockField>
				var agree=confirm("You are about to delete "+name+ " which may contain data that \nwill be permanently removed if you proceed. \nDo you want to delete '#fieldname#'?");
			<cfelse>
				var agree=confirm("Are you sure you wish to delete '#fieldname#'?");
			</cfif>
			if (agree) {
				<cfif isDefined("q_getAllChildren.recordcount") AND q_getAllChildren.recordcount>
					<cfset formList=valueList(q_getAllChildren.label,", ")>
					var agree2=confirm("'#fieldname#' is used in these forms: #formList#.\n Are you sure you want to remove it?");
					if (agree2) {
						document.fieldform.toolaction.value="deletefield";
						document.fieldform.submit();
				} else {
					return false ;
				}
				<cfelse>
					document.fieldform.fieldname = name;
					document.fieldform.toolaction.value="deletefield";
					document.fieldform.submit();
				</cfif>
				
			} else {
				return false ;
			}
		}
	</cfif>
	function manageInput(inputtype) {
		if ((inputtype=='filechooser') || (inputtype=='guestrolechooser') || (inputtype=='formatonly') || (inputtype=='custominclude') || (inputtype=='image') || (inputtype=='submit') || (inputtype=='cancel') || (inputtype=='sekeyname') || (inputtype=='calendarPopUp') || (inputtype=='colorPicker') || (inputtype=='bs_pageTitle')) {
		//submit form and modify loaded form to include additional fields.
			document.fieldform.toolaction.value="DEShowForm";
			document.fieldform.submit();
		}
		<cfif form.inputtype eq "filechooser">
		else {
			document.fieldform.toolaction.value="DEShowForm";
			document.fieldform.gridposlabel.value='';
			document.fieldform.gridposvalue.value='';
			document.fieldform.submit();
		}
		</cfif>
		var lastPos='#q_getForm.tablerows#,#q_getForm.tablecolumns#';
		if ((inputtype=='hidden') || (inputtype=='submit') || (inputtype=='button') || (inputtype=='reset') || (inputtype=='image') || (inputtype=='cancel')) {
				document.fieldform.gridposlabel.value=lastPos;
				document.fieldform.gridposvalue.value=lastPos;
			} else {
				if (document.fieldform.gridposlabel.value==lastPos) {
					document.fieldform.gridposlabel.value='';
				}
				if (document.fieldform.gridposvalue.value==lastPos) {
					document.fieldform.gridposvalue.value='';
				}
			}
		}
	function setMaxLength() {
	document.fieldform.maxlength.value = document.fieldform.length.value;
		/*if (document.fieldform.length.value != ''){
			
		}*/
	}
	function chooseTable(lookuptable) {
		document.fieldform.submit();
	}
	
	function nextStep() {
		if (document.fieldform.commit.checked==true){
			if (((document.fieldform.datatype.value=="varchar") || (document.fieldform.datatype.value=="nvarchar") || (document.fieldform.datatype.value=="varchar")) && ((document.fieldform.length.value=='')  || (document.fieldform.datatype.value=="nvarchar")) && ((document.fieldform.length.value=='') || (isNaN(document.fieldform.length.value)))){
				alert("You must provide a length when selecting a datatype of 'varchar' or 'nvarchar'.");
				return false;
			}
		}
		if (isNaN(document.fieldform.tabindex.value)){
			alert("Tab index must be a numeric value.");
			return false;
		}
		if (document.fieldform.lookuptype.value=="query"){
			var queryStr=document.fieldform.lookupquery.value;
			if (queryStr==''){
				alert("You must provide a query when selecting a lookup type of 'query'.");
				return false;
			}
			if (queryStr.indexOf("lookupkey") < 1){
				alert("Your custom query must return 'lookupkey' as a column variable.");
				return false;
			}else if (queryStr.indexOf("lookupdisplay") < 1){
				alert("Your custom query must return 'lookupdisplay' as a column variable.");
				return false;
			}
		}
		if ((document.fieldform.lookuptype.value=="list") && (document.fieldform.lookuplist.value=='')){
			alert("You must provide a Key/Value list when selecting a lookup type of 'list'.");
			return false;
		}
		if ((document.fieldform.lookuptype.value=="table") && ((document.fieldform.lookuptable.value=='') || (document.fieldform.lookupkey.value=='') || (document.fieldform.lookupdisplay.value==''))){
			alert("You must provide a Table, Key, and Display list when selecting a lookup type of 'table'.");
			return false;
		}
		<cfif form.inputtype eq "filechooser">
		if ((document.fieldform.inputtype.value=="filechooser") && (document.fieldform.uploadcategoryid.value=='')){
			alert("You must specify a category to use the filechooser input type. \nIf you need to create a new category, use the file upload tool.");
			return false;
		}
		</cfif>
		<cfif isDefined("fieldname") AND len(fieldname) AND NOT isDefined("form.addChildField")>
		if ((document.fieldform.datatype.value != '#a_formelements[form.arrayposition].datatype#') || (document.fieldform.length.value != 
<cfif len(a_formelements[form.arrayposition].length)>#a_formelements[form.arrayposition].length#<cfelse>0</cfif>)){
			var agree=confirm("You have made changes to the data column \nwhich will delete any data in that column. \n Do you want to proceed?");
			if (!agree) {
				return false;
			}
		}
		</cfif> 
		//if this is format only field do not allow db commit
		if (document.fieldform.inputtype.value=="formatonly" || document.fieldform.inputtype.value=="image" || document.fieldform.inputtype.value=="cancel" || document.fieldform.inputtype.value=="submit" || document.fieldform.inputtype.value=="button"){
			document.fieldform.commit.checked=false;
		}
		document.fieldform.toolaction.value="DEPost";
		document.fieldform.submit();
	}
	function manageLabelFormat(){
		// this routine swap out class for a required field - not caputured on page reload so depreciated
		var pos = "#FORM.gridposlabel#";
		/*
		if(document.getElementById('required').checked){
			if(pos.length){
				if((document.getElementById(pos).className.indexOf('formitemlabelreq') == -1) && (document.getElementById(pos).className.indexOf('formitemlabel') != -1)){
					document.getElementById(pos).className = document.getElementById(pos).className.replace('formitemlabel','formitemlabelreq', 'g')
				}else{
					document.getElementById(pos).className += " formitemlabelreq";
				}
			}
		}else{
			if(pos.length){
				if(document.getElementById(pos).className.indexOf('formitemlabelreq') != -1){
					document.getElementById(pos).className = document.getElementById(pos).className.replace('formitemlabelreq','formitemlabel', 'g')
				}else{
					document.getElementById(pos).className += " foritemlabel";
				}
			}
		}
		*/
	}
	<cfif isDefined("deletefield") AND deletefield>
		window.onload= deleteField;
	</cfif>
	
</script>
</cfoutput>
<cfif len(trim(lookuptable))>
	<cfquery datasource="#application.datasource#" name="q_getTableItems" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT *
		FROM #form.lookuptable#
	</cfquery>
</cfif>
<cfif ((len(trim(fieldname)) GT 0) AND (lockField GT 0)) OR lockField EQ 0>
<cfoutput>
<form action="#request.page#" method="post" name="fieldform">
<input type="hidden" name="lockField" id="lockField" value="#lockField#">
<input type="Hidden" name="validatelist" value="fieldname,required;fieldname,reservedword;fieldname,filename;objectlabel,required;datatype,required;inputtype,required;gridposlabel,required;gridposvalue,required">
<input type="hidden" name="toolaction" value="#toolaction#">
<input type="hidden" name="formobjectid" value="#formobjectid#">
<!--- 12/04/2006 DRK pass along id for imported fields ---> 
<cfif form.SOURCEFORMOBJECTID GT 0>
<input type="hidden" name="SOURCEFORMOBJECTID" value="#form.SOURCEFORMOBJECTID#">
</cfif>
<!--- 12/05/2006 DRK foreign key id save/don't save switch for imported fields --->
<cfif isDefined('form.FOREIGNKEY')>
<input type="hidden" name="FOREIGNKEY" value="#form.FOREIGNKEY#">
</cfif>
<!--- 12/05/2006 DRK foreign key id save/don't save switch for imported fields --->
<cfif isDefined('form.useMappedContent')>
<input type="hidden" name="useMappedContent" value="#form.useMappedContent#">
</cfif>
<cfif isDefined("form.addChildField")>
	<input type="hidden" name="addChildField" value="#form.addChildField#">
</cfif>
<cfif len(trim(fieldname))><!--- post this form in edit mode --->
	<input type="hidden" name="edit" value="#fieldname#">
	<input type="hidden" name="arrayposition" value="#form.arrayposition#">
<cfelse>
	<input type="hidden" name="edit" value="">
</cfif>
<cfset formObj =  CreateObject('component','#application.cfcpath#.formprocess')>
<!--- Main Window Header --->
<!--- JPL 5-14-2008 Changed to different display in Form Builder --->
<div id="socketformheader">
	<cfif isDefined('q_getform') AND NOT (q_getform.formobjectid eq q_getform.parentid)>
		<h2>FormBuilder</h2>
	<cfelse>
		<h2>SocketBuilder</h2>
	</cfif>
	<h3>#q_getform.label# &gt; <cfif len(objectlabel)>Edit : #objectlabel#<cfif isDefined('FORM.SOURCEFORMOBJECTID') AND (FORM.SOURCEFORMOBJECTID GT 0)>(From Table: #formObj.getFormObjectTable(formobjectid=FORM.SOURCEFORMOBJECTID).datatable#)</cfif><cfelse>Add New Field</cfif></h3>
	<div id="returnToIndex"><a href="#request.page#?formobjectid=#formobjectid#&toolaction=DTShowForm" style="font-weight:bold;color:white;">&lt; Back to Configuration</a></div>
</div>
<div style="clear:both;"></div>

<!--- Show errors if i_validate.cfm found any... --->
<cfif isDefined("request.isError") AND request.isError eq 1>
	<div id="errorBlock">
		<h2>Problem with Submission...</h2>
		<ul>
			<cfloop list="#request.errorMsg#" index="error" delimiters="||">
				<li>#error#</li>
			</cfloop>
		</ul>
	</div>
</cfif>
<table id="sockebuildertable" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td class="formitemlabelreq" colspan="3">
		<cfinclude template="i_adhocList.cfm">
		</td>
		<td class="formitemlabelreq" colspan="3" align="right">#parentstatus#
		<cfif isDefined("q_getAllChildren.recordcount") AND q_getAllChildren.recordcount>
			<select name="childformid" onchange="javascript: gotoChildForm(this.value);">	
				<option value="0">Go to a dependent form...
				<cfloop query="q_getAllChildren">
					<option value="#q_getAllChildren.formobjectid#">#q_getAllChildren.label#
				
			</cfloop></select>
		<cfelse>
			&nbsp;
		</cfif>
		</td>
	</tr>
	<tr>
		<td valign="top" colspan="2" class="socketbuildertablehdr">Define Data Field</td>
		<td valign="top" colspan="2" class="socketbuildertablehdr">Define Form Input</td>
		<td valign="top" colspan="2" class="socketbuildertablehdr">Define Lookup (optional)</td>
	</tr>
	<tr>
		<td valign="top" colspan="2">
			Fieldname<br />
		  	<cfif lockField>
		   		<input type="hidden" name="fieldname" id="fieldname" value="#form.fieldname#">
				#form.fieldname#
			<cfelse>
				<input type="text" <cfif (form.SOURCEFORMOBJECTID GT 0) OR (isDefined('form.useMappedContent') AND form.useMappedContent GT 0)>disabled="disabled" </cfif> name="fieldname" id="fieldname" value="#form.fieldname#" maxlength="250" tabindex="1" style="width:233px"><cfif (form.SOURCEFORMOBJECTID GT 0) OR (isDefined('form.useMappedContent') AND form.useMappedContent GT 0)><input type="hidden" name="fieldname" id="fieldname" value="#form.fieldname#" maxlength="250" tabindex="1" style="width:233px"></cfif>
			</cfif>
		</td>
		<td valign="top">
		<cfif isDefined('FORM.useMappedContent') AND (form.inputtype EQ "useMappedContent")><input name="inputtype" id="inputtype" type="hidden" value="useMappedContent" /></cfif>
			Input Type<br /> <select name="inputtype" id="inputtype" size="1" onchange="javascript:manageInput(this.value);" tabindex="12" <cfif isDefined('FORM.useMappedContent') AND (form.inputtype EQ "useMappedContent")>disabled="disabled"</cfif>>
          <option value="Text"<cfif form.inputtype EQ "Text"> SELECTED</cfif>>Text</option>
          <option value="Textarea"<cfif form.inputtype EQ "Textarea"> SELECTED</cfif>>Textarea</option>
          <option value="radio"<cfif form.inputtype EQ "radio"> SELECTED</cfif>>Radio Button</option>
          <option value="checkbox"<cfif form.inputtype EQ "checkbox"> SELECTED</cfif>>Check Box</option>
          <option value="Password"<cfif form.inputtype EQ "Password"> SELECTED</cfif>>Password</option>
          <option value="button"<cfif form.inputtype EQ "button"> SELECTED</cfif>>Button</option>
		  <option value="image"<cfif form.inputtype EQ "image"> SELECTED</cfif>>Image</option>
		  <option value="hidden"<cfif form.inputtype EQ "hidden"> SELECTED</cfif>>Hidden</option>
          <option value="select"<cfif form.inputtype EQ "select"> SELECTED</cfif>>Select</option>
		  <option value="submit"<cfif form.inputtype EQ "submit"> SELECTED</cfif>>Submit</option>
		  <option value="reset"<cfif form.inputtype EQ "reset"> SELECTED</cfif>>Reset</option>
		  <option value="">--custom types--</option>
		  <option value="cancel"<cfif form.inputtype EQ "cancel"> SELECTED</cfif>>Cancel</option>
		  <option value="custominclude"<cfif form.inputtype EQ "custominclude"> SELECTED</cfif>>Custom Include</option>
		  <option value="activEdit"<cfif form.inputtype EQ "activEdit"> SELECTED</cfif>>ActivEdit</option>
		  <option value="WYSIWYGBasic"<cfif form.inputtype EQ "WYSIWYGBasic"> SELECTED</cfif>>WYSIWYG Basic</option>
		  <option value="WYSIWYGSimple"<cfif form.inputtype EQ "WYSIWYGSimple"> SELECTED</cfif>>WYSIWYG Simple</option>
		  <option value="WYSIWYGDefault"<cfif form.inputtype EQ "WYSIWYGDefault"> SELECTED</cfif>>WYSIWYG Default</option>
		  <option value="filechooser"<cfif form.inputtype EQ "filechooser"> SELECTED</cfif>>File Chooser</option>
		  <option value="guestrolechooser"<cfif form.inputtype EQ "guestrolechooser"> SELECTED</cfif>>Guest Role Type</option>
		  <option value="formatonly"<cfif form.inputtype EQ "formatonly"> SELECTED</cfif>>Formatting Only</option>
		  <option value="sekeyname"<cfif form.inputtype EQ "sekeyname"> SELECTED</cfif>>SEO Key Name</option>
		  <option value="calendarPopUp"<cfif form.inputtype EQ "calendarPopUp"> SELECTED</cfif>>Calendar Pop-Up</option>
		  <option value="colorPicker"<cfif form.inputtype EQ "colorPicker"> SELECTED</cfif>>Color Picker</option>
          <option value="bs_pageTitle"<cfif form.inputtype EQ "bs_pageTitle"> SELECTED</cfif>>Open BoomSocket Page Title</option>
		  <cfif isDefined('FORM.useMappedContent') AND (form.inputtype EQ "useMappedContent")> <option value="useMappedContent" selected>Content Mapping</option></cfif>
        </select>
		<cfif form.inputtype eq "filechooser"><br>
		<!--- query for upload categories --->
		<cfquery datasource="#application.datasource#" name="q_getuploads" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT *
			FROM uploadcategory
			ORDER by parentid , uploadcategorytitle ASC
		</cfquery>
			<select name="uploadcategoryid">
			<option value="">Select file category</option>
			<cfinvoke component="#application.cfcpath#.util.categoryindent" method="doIndent">
				<cfinvokeargument name="ID" value=0>
				<cfinvokeargument name="idColumn" value="uploadcategoryid">
				<cfinvokeargument name="displayColumn" value="uploadcategorytitle">
				<cfinvokeargument name="parentIdColumn" value="parentid">
				<cfinvokeargument name="tableName" value="uploadcategory">
				<cfinvokeargument name="dbName" value="#application.datasource#">
				<cfinvokeargument name="orderByColumn" value="uploadcategorytitle">
				<cfinvokeargument name="pickLevel" value="current">
				<cfinvokeargument name="nameLengthLimit" value="24">
			</cfinvoke>
			</select>
			<input type="Hidden" name="formatonly" value="">
		<cfelseif form.inputtype eq "guestrolechooser"><br>
		<!--- query for upload categories --->
			Limit by Parent Role<br/>
			<select name="uploadcategoryid">
			<option value="">Select parent role</option>
			<cfquery name="getParents" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT	Cast(guestroleparentchild.parentid AS varchar(10))+'^'+Cast(guestroleparentchild.childid AS varchar(10)) AS keyValue,
						guestrolename
				FROM	guestroleparentchild
				INNER JOIN guestrole ON guestrole.guestroleid = guestroleparentchild.childid
				WHERE guestroleparentchild.parentid = guestroleparentchild.childid
				ORDER BY guestrolename
			</cfquery>
			<cfloop query="getParents">
				<option value="#getParents.keyValue#" <cfif getParents.keyValue EQ FORM.uploadcategoryid> selected</cfif>>#getParents.guestrolename#</option>
			</cfloop>
			</select>
			<input type="Hidden" name="formatonly" value="">
		<cfelseif form.inputtype eq "formatonly">
		 <br><span>Add HTML below:</span><br>
			<textarea name="formatonly" cols="15" rows="4">#form.formatonly#</textarea>
			<input type="Hidden" name="uploadcategoryid" value="">
		<cfelseif form.inputtype eq "custominclude">
		 <br><span>Custom include path:</span><br>
			<input type="text" name="custominclude" value="#form.custominclude#" width="26">
		<cfelseif form.inputtype eq "image">
		 <br><span>Image path:</span><br>
			<input type="text" name="imagebuttonpath" value="#form.imagebuttonpath#" width="26">
		<cfelseif form.inputtype eq "submit">
		 <br><span>Image path:</span><br>
			<input type="text" name="submitbuttonimage" value="#form.submitbuttonimage#" width="26">
		<cfelseif form.inputtype eq "cancel">
		 <br><span>Image path:</span><br>
			<input type="text" name="cancelbuttonimage" value="#form.cancelbuttonimage#" width="26">
		<cfelseif form.inputtype eq "sekeyname">
		<br><span>Source Field:</span><br>
		<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
			input="#q_getform.datadefinition#"
			output="a_formelements">
			<select name="sekeynamefield">
				<cfloop index="x" from="1" to="#arrayLen(a_formelements)#">
					<cfif a_formelements[x].inputtype EQ "text">
						<option value="#a_formelements[x].fieldname#">#a_formelements[x].fieldname#</option>
					</cfif>
				</cfloop>
			</select>
		<cfelseif form.inputtype eq "bs_pageTitle">
		<br><span>Source Field:</span><br>
		<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
			input="#q_getform.datadefinition#"
			output="a_formelements">
			<select name="bs_pageTitlefield">
				<cfloop index="x" from="1" to="#arrayLen(a_formelements)#">
					<cfif a_formelements[x].inputtype EQ "text">
						<option value="#a_formelements[x].fieldname#">#a_formelements[x].fieldname#</option>
					</cfif>
				</cfloop>
			</select>
		</cfif>
		</td>
		<td valign="top">
			Validate<br /> <select name="validate" id="validate" size="1" tabindex="13">
	          <option value="">None</option>
			  <option value="creditcard"<cfif form.validate EQ "creditcard"> SELECTED</cfif>>Credit Card</option>
	          <option value="date"<cfif form.validate EQ "date"> SELECTED</cfif>>Date/Time</option>
	          <option value="email"<cfif form.validate EQ "email"> SELECTED</cfif>>Email</option>
			  <option value="filename"<cfif form.validate EQ "filename"> SELECTED</cfif>>Filename</option>
	          <option value="int"<cfif form.validate EQ "int"> SELECTED</cfif>>Number</option>
	          <option value="telephone"<cfif form.validate EQ "telephone"> SELECTED</cfif>>Telephone</option>
			  <option value="urlsafestring"<cfif form.validate EQ "urlsafestring"> SELECTED</cfif>>URL Safe Text</option>
			  <option value="IsZipUS"<cfif form.validate EQ "IsZipUS"> SELECTED</cfif>>U.S. ZipCode</option>
			  <option value="vanityURL"<cfif form.validate EQ "vanityURL"> SELECTED</cfif>>Vanity URL</option>
	        </select>
		</td>
		<td valign="top">
			Lookup Type<br /> <select name="lookuptype" id="select" size="1" tabindex="24">
          <option value=""<cfif form.lookuptype EQ ""> SELECTED</cfif>>None</option>
          <option value="List"<cfif form.lookuptype EQ "List"> SELECTED</cfif>>List</option>
          <option value="Table"<cfif form.lookuptype EQ "Table"> SELECTED</cfif>>Table</option>
          <option value="Query"<cfif form.lookuptype EQ "Query"> SELECTED</cfif>>Query</option>
        </select>
		</td>
		<td valign="top">
			Lookup Table <br> <select name="lookuptable" id="lookuptable" onchange="javascript:chooseTable(this.value);" tabindex="25">
          <option value="">None</option>
		  <cfloop query="q_getTables">
          <option value="#q_getTables.name#"<cfif form.lookuptable EQ q_getTables.name> SELECTED="SELECTED"</cfif>>#lcase(q_getTables.name)#</option>
		  </cfloop>
        </select>
		</td>
	</tr>
	<tr>
		<td valign="top" colspan="2">
			Label<br /> 
			<input type="text" name="objectlabel" id="objectlabel" value="#form.objectlabel#" maxlength="250" tabindex="2" style="width:233px">
		</td>
		<td valign="top">
			Height<br /> <input type="text" name="height" id="height" value="#form.height#" maxlength="250" tabindex="14" style="width:83px">
		</td>
		<td valign="top">
			Width<br /> <input type="text" name="width" id="width" value="#form.width#" maxlength="250" tabindex="15" style="width:83px">
		</td>
		<td valign="top">
			Lookup Key<br /> 
			<select  name="lookupkey" id="lookupkey" tabindex="26">
			          <option value="">Select Key</option>
				<cfif len(trim(form.lookuptable))>
					<cfloop list="#q_getTableItems.columnlist#" index="thisColumn">
						<!--- ADD: Sept 7, 2004 Added code below to check for an exisiting value and add selected attribute for this item versus the ID / Name pair --->
			          <option value="#thisColumn#"
					  	<cfif IsDefined('form.lookupkey') AND Len(Trim(form.lookupkey)) GT 0>
							<cfif form.lookupkey EQ thisColumn>
								SELECTED
							</cfif>
						<cfelse>
							<cfif thisColumn EQ '#form.lookuptable#id'>
								SELECTED
							</cfif>
						</cfif>>#thisColumn#</option>
					</cfloop>
				</cfif>
	        </select>
		</td>
		<td valign="top">
			Lookup Display<br /> 
			<select  name="lookupdisplay" id="lookupdisplay" tabindex="27">
	          <option value="">Select Display</option>
			<cfif len(trim(lookuptable))>
			<cfloop list="#q_getTableItems.columnlist#" index="thisColumn">
		          <option value="#thisColumn#"
				  <cfif IsDefined('form.lookupdisplay') AND Len(Trim(form.lookupdisplay)) GT 0>
						<cfif form.lookupdisplay EQ thisColumn>
							SELECTED
						</cfif>
					<cfelse>
						<cfif thisColumn EQ '#form.lookuptable#name'>
							SELECTED
						</cfif>
					</cfif>>#thisColumn#</option>
			</cfloop>
			</cfif>
	        </select>
		</td>
	</tr>
	<tr>
		<td valign="top">
			Data Type<br />
		  	<cfif lockField OR (form.SOURCEFORMOBJECTID GT 0)>
		 		<input type="hidden" name="datatype" id="datatype" value="#form.datatype#">
				#form.datatype#
			<cfelse>
			 <select name="datatype" id="datatype" size="1" tabindex="3" <cfif form.SOURCEFORMOBJECTID GT 0>disabled="disabled"</cfif>>
	          <option value="nvarchar"<cfif form.datatype EQ "nvarchar"> SELECTED</cfif>>nvarchar</option>
	          <option value="varchar"<cfif form.datatype EQ "varchar"> SELECTED</cfif>>varchar</option>
			  <option value="autonumber"<cfif form.datatype EQ "autonumber"> SELECTED</cfif>>autonumber</option>
	          <option value="int"<cfif form.datatype EQ "int"> SELECTED</cfif>>int</option>
	          <option value="text"<cfif form.datatype EQ "text"> SELECTED</cfif>>text</option>
	          <option value="ntext"<cfif form.datatype EQ "ntext"> SELECTED</cfif>>ntext</option>
	          <option value="datetime"<cfif form.datatype EQ "datetime"> SELECTED</cfif>>datetime</option>
	          <option value="bit"<cfif form.datatype EQ "bit"> SELECTED</cfif>>bit</option>
	          <option value="float"<cfif form.datatype EQ "float"> SELECTED</cfif>>float</option>
	        </select>
			</cfif>
		</td>
		<td valign="top">
			Length<br />
			<cfif form.SOURCEFORMOBJECTID GT 0><input type="hidden" name="length" id="length" value="#form.length#" ></cfif>
		 	<input type="text" name="length" id="length" value="#form.length#" maxlength="250" onblur="javascript:setMaxLength();" tabindex="4" <cfif form.SOURCEFORMOBJECTID GT 0>disabled="disabled"</cfif> style="width:112px">
		</td>
		<td valign="top">
			Input Style<br>
		 	<input type="text" name="inputstyle" id="inputstyle" value="#form.inputstyle#" maxlength="250" tabindex="16" style="width:83px">
		</td>
		<td valign="top">
			MaxLength<br /> <input type="text" name="maxlength" id="maxlength" value="#form.maxlength#"  maxlength="250" tabindex="17" style="width:83px">
		</td>
		<td valign="top" colspan="2" rowspan="2">
			Lookup Custom Query<br> <textarea cols="35" rows="4" name="lookupquery" id="lookupquery" tabindex="28">#form.lookupquery#</textarea>
		</td>
	</tr>
	<tr>
		<td valign="top" colspan="2">
			 <cfif lockField>
				 <input type="hidden" name="pk" id="pk" value="#form.pk#"><cfif form.pk>Yes<cfelse>No</cfif>
			 <cfelse>
				 <input type="checkbox" name="pk" id="form.pk" value="1"<cfif pk> checked</cfif> tabindex="5">
			</cfif>Primary Key 
			<input type="checkbox" name="required" id="required" onchange="manageLabelFormat()" value="1"<cfif form.required> checked</cfif> tabindex="5">Required
			 <!--- 12/05/2006 DRK foreign key id save/dont't save switch for imported fields --->
			 <cfif lockField OR (form.SOURCEFORMOBJECTID GT 0)><input type="hidden" name="commit" id="commit" value="#form.commit#" tabindex="6"><cfif listlast(form.commit)>Yes&nbsp;<cfelse>No&nbsp;</cfif><cfelse><!--- 12/04/2006 DRK check if import field used to disable commit checkbox---><input type="checkbox" name="commit" id="commit"  <cfif (form.SOURCEFORMOBJECTID GT 0) OR (isDefined('form.useMappedContent') AND form.useMappedContent GT 0)>disabled="disabled" </cfif> value="1" onclick="javascript:if(!this.checked){nonCommit();}"<cfif listlast(form.commit)> checked</cfif> tabindex="7">
			</cfif>Commit to db
			<cfif isDefined('form.FOREIGNKEY')><div>
			<!--- 12/05/2006 DRK foreign key id save/dont't save switch for imported fields --->
				<input type="checkbox" name="COMMITFOREIGNTABLE" id="COMMITFOREIGNTABLE" value="1" onclick="javascript:if(!this.checked){nonCommitForeign();}"<cfif isDefined('form.COMMITFOREIGNTABLE') AND form.COMMITFOREIGNTABLE> checked</cfif> tabindex="7">Commit to Foreign db<!--- 12/14/2006 DRK master key flag for update/insert ordering ---><input type="checkbox" name="ISMASTERTABLE" id="ISMASTERTABLE" value="1" onclick="javascript:if(!this.checked){nonCommitForeign();}"<cfif isDefined('form.ISMASTERTABLE') AND form.ISMASTERTABLE> checked</cfif> tabindex="7">Is Master Table
			</div></cfif>
		</td>
		<td valign="top">
			Tab Index<br /> <input type="text" name="tabindex" id="tabindex" value="#form.tabindex#" maxlength="3" tabindex="18" style="width:83px">
		</td>
		<td valign="top">
			Select Size<br> <!--- <input type="text" name="lookupmultiple" id="lookupmultiple" value="#form.lookupmultiple#" size="10" maxlength="3" tabindex="19"> --->
			<select name="lookupmultiple" id="lookupmultiple"  size="1" tabindex="19">
				<cfloop from="0" to="20" index="i">
					<option value="#i#" <cfif form.lookupmultiple EQ i>SELECTED="selected"</cfif>>#i#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td colspan="2" valign="top" class="formbuilderheader">Grid Position</td>
		<td valign="top">
			Default Value<br> <input type="text" name="defaultvalue" id="defaultvalue" value="#form.defaultvalue#" maxlength="250" tabindex="20" style="width:83px">
		</td>
		<td valign="top">
			<input type="checkbox" name="readonly" id="readonly" value="1"<cfif form.readonly NEQ ''><cfif form.readonly> checked</cfif></cfif> tabindex="21">Read Only
		</td>
		<td valign="top" colspan="2">
			Lookup Key/Value List<br> <input type="Text" name="lookuplist" id="lookuplist" value="#form.lookuplist#" tabindex="29" style="width:300px">
		</td>
	</tr>
	
	<cfset prepopulateGridPos = false>
	<cfif NOT len(trim(form.gridposlabel)) AND NOT len(trim(form.gridposvalue)) AND isdefined("SESSION.currentFieldRow") AND q_getform.tablecolumns EQ 2 AND SESSION.currentFieldRow LTE q_getform.tablerows>
		<cfset prepopulateGridPos = true>
	</cfif>
	
	<tr>
		<td valign="top">Label<br><input type="text" name="gridposlabel" id="gridposlabel" <cfif prepopulateGridPos> value="#SESSION.currentFieldRow#,1"<cfelse> value="#listchangedelims(form.gridposlabel,",","_")#"</cfif> maxlength="250" tabindex="8" style="width:68px" ><input type="Button" class="submitbutton" value="set" onclick="javascript:window.open('#request.page#?toolaction=gridwindow&formobjectid=#formobjectid#&inputfield=gridposlabel','gridWindow','height=<cfif q_getform.tablerows GT 20>#evaluate((20*35)+(q_getform.tablerows+30+35))#<cfelse>#evaluate((q_getform.tablerows*35)+(q_getform.tablerows+30+35))#</cfif>,width=<cfif q_getform.tablerows GT 20>#evaluate((q_getform.tablecolumns*35)+(q_getform.tablecolumns+35+35))#<cfelse>#evaluate((q_getform.tablecolumns*35)+(q_getform.tablecolumns+15+35))#</cfif>,toolbars=no,resize=yes,scrollbars=<cfif q_getform.tablerows GT 20>yes<cfelse>auto</cfif>,location=no');" style="width:40" tabindex="9"></td>
      <td valign="top">Input<br><input type="text" name="gridposvalue" id="gridposvalue" <cfif prepopulateGridPos> value="#SESSION.currentFieldRow#,2"<cfelse>  value="#listchangedelims(form.gridposvalue,",","_")#" </cfif> maxlength="250" tabindex="10" style="width:68px"><input type="Button" class="submitbutton" value="set" onclick="javascript:window.open('#request.page#?toolaction=gridwindow&formobjectid=#formobjectid#&inputfield=gridposvalue','gridWindow','height=<cfif q_getform.tablerows GT 20>#evaluate((20*35)+(q_getform.tablerows+30+35))#<cfelse>#evaluate((q_getform.tablerows*35)+(q_getform.tablerows+30+35))#</cfif>,width=<cfif q_getform.tablerows GT 20>#evaluate((q_getform.tablecolumns*35)+(q_getform.tablecolumns+35+35))#<cfelse>#evaluate((q_getform.tablecolumns*35)+(q_getform.tablecolumns+15+35))#</cfif>,toolbars=no,resize=yes,scrollbars=<cfif q_getform.tablerows GT 20>yes<cfelse>auto</cfif>,location=no');" style="width:40" tabindex="11"></td>
		<td valign="top">
			Javascript call<br><input type="Text" value="#form.javascript#" name="javascript" maxlength="200" tabindex="22" style="width:112px">
		</td>
		<td valign="top">
			Event Handler<br>
			<select name="javascriptHandler" tabindex="23">
				<option value="onClick" <cfif form.javascriptHandler eq "onClick">SELECTED</cfif>>onClick
				<option value="onBlur" <cfif form.javascriptHandler eq "onBlur">SELECTED</cfif>>onBlur
				<option value="onChange" <cfif form.javascriptHandler eq "onChange">SELECTED</cfif>>onChange
				<option value="onSubmit" <cfif form.javascriptHandler eq "onSubmit">SELECTED</cfif>>onSubmit
				<option value="onFocus" <cfif form.javascriptHandler eq "onFocus">SELECTED</cfif>>onFocus
				<option value="onKeyPress" <cfif form.javascriptHandler eq "onKeyPress">SELECTED</cfif>>onKeyPress
			</select>
		</td>
		<td colspan="2" align="center">
		  	<cfif len(trim(fieldname))>
				<cfif lockField><input type="button" value="Cancel Edit" onclick="javascript: window.open('#request.page#?toolaction=DEShowForm&formobjectid=#formobjectid#','_self');" class="submitbutton" style="width:75px" tabindex="31"> 
				<cfelse>
				</cfif>
				<input type="button" value="Update Field" onclick="javascript:nextStep();" class="submitbutton" style="width:75px; margin-left:-20px;" tabindex="32"> 
				<input name="delete" type="button" value="Delete Field" onclick="javascript:deleteField();" class="deletebutton" style="width:75px; margin-left:20px;" tabindex="32">
			<cfelse>
				<input type="button" value="Submit Field" onclick="javascript:nextStep();" class="submitbutton" style="width:75px; margin-left:-20px;" tabindex="32"> 			</cfif>
		</td>
	</tr>
</table>
</form>
</cfoutput>
<!--- <cfelse>
<cfoutput>
<form>
<input type="button" value="Next Step" onclick="javascript:window.open('#request.page#?toolaction=createform&formobjectid=#formobjectid#','_self');" class="submitbutton" style="width:75px">
</form>
</cfoutput> --->
</cfif>

<cfinclude template="i_buildTable.cfm">