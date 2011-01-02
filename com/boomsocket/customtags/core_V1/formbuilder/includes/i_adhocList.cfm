<cfsilent>
<cfparam name="htmlOutput" default="">
<!--- skip include if formfield tool does not exist --->
<cfif isDefined('APPLICATION.tool.formfield')>
<!--- grab ad hoc categories from formfield datadefinition --->
<cfinvoke component="#APPLICATION.cfcPath#.formprocess" method="getForm" returnvariable="q_AdHocForm">
	<cfinvokeargument name="formobjectid" value="#APPLICATION.tool.formfield#">
</cfinvoke>
<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
	input="#q_AdHocForm.datadefinition#"
	output="a_formelements">
<cfset omitList = "formfieldid,datecreated,datemodified,parentid,ordinal,submit,definitionheader,inputheader,lookupheader">
<cfset fieldList = "">
<cfloop from="1" to="#arrayLen(a_formelements)#" index="i">
	<!--- build select list while we are here --->
	<cfif NOT findNoCase(a_formelements[i].fieldname,omitList)>
		<cfif len(trim(fieldList))>
			<cfset fieldList = fieldList&','>
		</cfif>
		<cfset fieldList = fieldList&a_formelements[i].fieldname>
	</cfif>
</cfloop>
<!--- grab adhoc fields from table --->
<cfset q_categorylist = "">
<cfset q_FieldList = "">
<cfinvoke component="#APPLICATION.cfcPath#.forminstance" method="getFormData" returnvariable="q_categorylist">
	<cfinvokeargument name="selectClause" value="formfieldcategoryname,formfieldcategoryid">
	<cfinvokeargument name="fromClause" value="formfieldcategory">
	<cfinvokeargument name="orderVar" value="ordinal">
</cfinvoke>
<cfquery name="q_FieldList" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT formfield.*, formfieldcategory.formfieldcategoryid
	FROM formfield
	INNER JOIN formfield_formfieldcategory ON formfield.formfieldid = formfield_formfieldcategory.formfieldid
	INNER JOIN formfieldcategory ON formfieldcategory.formfieldcategoryid = formfield_formfieldcategory.formfieldcategoryid
	ORDER BY formfieldcategory.formfieldcategoryid
</cfquery>
<!--- define DHTML behavior --->
<cfsavecontent variable="htmlOutput">
<cfoutput>
	<script type="text/javascript">
		<!--- build option lists --->
		var fieldArray = new Array();
		<cfset currentRow = 0>
		<cfloop list="#q_FieldList.columnlist#" index="thisItem">
			fieldArray[#currentRow#] = '#lcase(thisItem)#';
			<cfset currentRow = val (currentRow+1)>
		</cfloop>
		var optionArray = new Array();
		
		<cfloop query="q_categorylist">
			<cfset thisCat = q_categorylist.formfieldcategoryid>
			optionArray[#thisCat#] = new Array();
			thisList = new Array();
			thisList[0] = document.createElement('option');
			thisList[0].value = 0;
			thisList[0].appendChild(document.createTextNode("- Select a Field -"));
			<cfset currentOpt = 1>
			<cfloop query="q_FieldList">
				<!--- <cfdump var="#q_FieldList.formfieldcategoryid# #thisCat#"> --->
				<cfif q_FieldList.formfieldcategoryid EQ thisCat>
			thisList[#currentOpt#] = document.createElement('option');
			thisList[#currentOpt#].value="#q_FieldList.formfieldname#"
			thisList[#currentOpt#].title="#q_FieldList.description#"
			thisList[#currentOpt#].appendChild(document.createTextNode("#q_FieldList.objectlabel# - #q_FieldList.description#"));
				<cfset currentOpt = currentOpt + 1>
				</cfif>
			</cfloop>
			optionArray[#thisCat#] = thisList;

		</cfloop>
		var fieldObj = new Object();
		<cfloop query="q_FieldList">
			fieldObj['#q_FieldList.formfieldname#'] = new Object();
			<cfset currentObj = q_FieldList>
			<!--- <cfdump var="#currentObj#">
			<cfabort> --->
			<cfloop list="#q_FieldList.columnlist#" index="thisItem">
			fieldObj['#q_FieldList.formfieldname#']['#lcase(thisItem)#'] = '#evaluate("q_FieldList.#thisItem#")#';
			<!--- if ('#q_FieldList.formfieldname#' == 'stateid' && '#lcase(thisItem)#' == 'lookupkey')
			{
				<!--- <cfdump var=#q_FieldList#>;
				<cfabort>--->
			}--->
			</cfloop>
		</cfloop>
		
		function setFields(){
			if(document.getElementById('fieldCategory').value > 0){
				for(i=document.getElementById('fieldList').childNodes.length-1 ; i>=0 ;i--){
					thisOpt = document.getElementById('fieldList').childNodes[i];
					document.getElementById('fieldList').removeChild(thisOpt);
				}
				document.getElementById('fieldList').focus();
				for(j=0 ; j<optionArray[document.getElementById('fieldCategory').value].length ;j++){
					document.getElementById('fieldList').appendChild(optionArray[document.getElementById('fieldCategory').value][j]);
				}
				//document.getElementById('fieldList').innerHTML = optionArray[document.getElementById('fieldCategory').value];
			}else{
				document.getElementById('fieldList').innerHTML = optionArray[#q_categorylist.formfieldcategoryid#];
			}
		}
		function populateField(){
			
			var doReSubmit = false;
			var submitValue = "";
			var lookupName="";
			var lookupValue="";
			var lookupKeyValue = "";
			var lookupDisplayValue = "";
			for (i=0 ; i<fieldArray.length ; i++){
				//alert(fieldArray[i]+' '+fieldObj[document.getElementById('fieldList').value][fieldArray[i]]);
				switch(fieldArray[i]){
					case 'fieldheight':
						lookupName = 'height';
						lookupValueType = 'value';
						lookupValue = fieldObj[document.getElementById('fieldList').value][fieldArray[i]];
					break;
					case 'fieldwidth':
						lookupName = 'width';
						lookupValueType = 'value';
						lookupValue = fieldObj[document.getElementById('fieldList').value][fieldArray[i]];
					break;
					case 'formfieldname':
						lookupName = 'fieldname';
						lookupValueType = 'value';
						lookupValue = fieldObj[document.getElementById('fieldList').value][fieldArray[i]];
					break;
					case 'lengthvalue':
						lookupName = 'length';
						lookupValueType = 'value';
						lookupValue = fieldObj[document.getElementById('fieldList').value][fieldArray[i]];
					break;
					case 'lookuptype':
						lookupName = 'select';
						lookupValueType = 'value';
						lookupValue = fieldObj[document.getElementById('fieldList').value][fieldArray[i]];
					break;
					case 'lookupkey':
						lookupName = 'lookupkey';
						lookupValueType = 'innerHTML';
						if(fieldObj[document.getElementById('fieldList').value][fieldArray[i]].length)
						{
							<!--- JPL 6/17/08 Changed code lookup key is set to the ID of the table in the adhoc list --->
							lookupKeyValue = fieldObj[document.getElementById('fieldList').value][fieldArray[i]];
							var opt = document.createElement("option");
							opt.innerHTML = lookupKeyValue;
							opt.value = lookupKeyValue;
							opt.selected = "selected";
							document.getElementById('lookupkey').options[0] = null;
							document.getElementById('lookupkey').appendChild(opt);		
							
						}
						else 
						{
							var opt = document.createElement("option");
							opt.innerHTML = "Select Key";
							opt.value = "Select Key";
							//document.getElementByID(lookupName).appendChild(opt);
							//lookupValue ='<option value="Select Key">Select Key</option>';
						}								
					break;
					case 'lookupdisplay':
						alert
						lookupName = 'lookupdisplay';
						lookupValueType = 'innerHTML';
						if(fieldObj[document.getElementById('fieldList').value][fieldArray[i]].length)
						{
							<!--- JPL 6/17/08 Changed code lookup display is set to the name field of the table in the adhoc list --->
							lookupDisplayValue = fieldObj[document.getElementById('fieldList').value][fieldArray[i]];
							var opt = document.createElement("option");
							opt.innerHTML = lookupDisplayValue;
							opt.value = lookupDisplayValue;
							opt.selected = "selected";
							document.getElementById('lookupdisplay').options[0] = null;
							document.getElementById('lookupdisplay').appendChild(opt);	
						}else{
							var opt = document.createElement("option");
							opt.innerHTML = "Select Key";
							opt.value = "Select Key";
							//document.getElementByID(lookupName).appendChild(opt);
							//lookupValue ='<option value="Select Key">Select Key</option>';
						}
					break;
					case 'lookuptablecustom':
						lookupName = 'lookuptable';
						if(fieldObj[document.getElementById('fieldList').value][fieldArray[i]].length){
							lookupValueType = 'value';
							lookupValue = fieldObj[document.getElementById('fieldList').value][fieldArray[i]];
						}else{
							lookupValueType = 'selectedIndex';
							lookupValue = 0;
						}
					break;
					case 'inputtype':
						lookupName = fieldArray[i];
						lookupValueType = 'value';
						lookupValue = fieldObj[document.getElementById('fieldList').value][fieldArray[i]];
						doReSubmit = true;
						submitValue = lookupValue;
					break;
					default:
						lookupName = fieldArray[i];
						lookupValueType = 'value';
						lookupValue = fieldObj[document.getElementById('fieldList').value][fieldArray[i]];
					break;
				}
				if(document.getElementById(lookupName)){
					//alert(document.getElementById(lookupName)[lookupValueType]);	
					if(lookupName != 'lookupdisplay' && lookupName != 'lookupkey') {
						document.getElementById(lookupName)[lookupValueType] = lookupValue;	
					}			
				}
			}
			if (doReSubmit && ((submitValue=='filechooser') || (submitValue=='formatonly') || (submitValue=='custominclude') || (submitValue=='image') || (submitValue=='submit') || (submitValue=='cancel') || (submitValue=='sekeyname') || (submitValue=='calendarPopUp') || (submitValue=='bs_pageTitle'))) {
			//submit form and modify loaded form to include additional fields.
				document.fieldform.toolaction.value="DEShowForm";
				document.fieldform.submit();
			}
		}
	</script>
	<!--- build HTML output --->
	<!--- JPL 5-14-2008 Changed not to display on Form Builder --->
	<cfif NOT isDefined('q_getform') OR (q_getform.formobjectid eq q_getform.parentid)>
		<div class="adHocFields">
			<select id="fieldCategory" onchange="setFields()">
				<option value="0" selected="selected">- Select a Field Category -</option>
				<cfloop query="q_categorylist">
					<option value="#q_categorylist.formfieldcategoryid#">#q_categorylist.formfieldcategoryname#</option>
				</cfloop>
			</select>
			<select id="fieldList" onchange="populateField()">
				<option value="0" selected="selected">- Select a Field -</option>
				<cfloop query="q_FieldList">
					<cfif q_FieldList.formfieldcategoryid EQ q_categorylist.formfieldcategoryid>
						<option value="#q_FieldList.formfieldname#" title="#q_FieldList.description#">#q_FieldList.objectlabel# - #q_FieldList.description#</option>
					</cfif>
				</cfloop>
			</select>
		</div>
	</cfif>
</cfoutput>
</cfsavecontent>
</cfif>
</cfsilent>
<cfoutput>#htmlOutput#</cfoutput>