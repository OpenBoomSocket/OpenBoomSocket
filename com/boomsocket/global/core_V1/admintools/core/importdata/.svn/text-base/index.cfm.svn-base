<!--- Custom Tool: Socket Data Importer Created on {ts '2007-07-02 14:28:32'} --->
<!--- JPL Modifications made on 6/20/2008 --->
<cfparam name="htmlOutput" default="">
<cfsilent>

<cfsavecontent variable="jsFunctions">
	<cfoutput>
		<script type="text/javascript">
			
			function verifyTable()
			{
				var xmlFile = document.getElementById("fileSelector").value;
				var tableIndex = document.getElementById("formobjectlist").selectedIndex;
				var spliter = xmlFile.split('.');
				if(tableIndex > 0 && xmlFile.length > 0)
				{
					
					if (spliter[spliter.length-1] == 'xml')
						document.getElementById("fieldForm").submit();
					else 
						alert("File must end with a '.xml' extension");
				}
				else
				{
					alert("Must enter both table and file");	}
			}
			
			function verifyFields(length)
			{
				atleastOneChecked = false;
				for (i = 1; i<length; i++)
				{
					string = "fieldname_"+i;
					if (document.getElementById(string).checked == true)
					{
						atleaseOneChecked = true;
						break;
					}	
				}
				if(atleaseOneChecked == true)
				{
					document.getElementById("fieldForm").submit();
				}
				else
				{
					alert("Must select atleast one field to import data to");
				}
			}
			
			function checkAll(length)
			{
				if (document.getElementById('checkall').checked == false)
				{
					for (i = 1; i <= length; i++)
					{
						document.getElementById("fieldname_"+i).checked = false;
					}
				}
				else
				{
					for (i = 1; i <= length; i++)
					{
						document.getElementById("fieldname_"+i).checked = true;
					}
				}
			}
			
		</script>
		<style type="text/css">
			##toolFieldSelection{
				padding-left: 20px;
				padding-top: 20px;
			}
			##tableSelection{
			   float:left;
			   margin-bottom:20px;
			}
			##fieldListing{
				margin-bottom:20px;
			}
			
			##fileSelectionBlock{
				
				float: left;
				margin-left: 100px;
			}
			

		</style>
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#jsFunctions#">

		
<!---Query form objects--->

<cfquery datasource="#application.datasource#" name="q_getFormObjects" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT formobject.formobjectname, formobject.formobjectid
	FROM formobject
	INNER JOIN userpermission ON userpermission.formobjectid = formobject.formobjectid
	WHERE (userpermission.userid = #session.user.id#) AND (userpermission.access = 1) AND (formobject.formenvironmentid <> 100) AND (formobject.formenvironmentid <> 105) AND (formobject.formenvironmentid <> 107) AND (formobject.formenvironmentid <> 109) AND (formobject.formenvironmentid <> 110)
	ORDER BY formobjectname
</cfquery>

<cfif isdefined("form.import") AND NOT isdefined("form.fieldsSelected")>
	<cfset SESSION.formobjectid = #trim(FORM.formobjectlist)#>
</cfif>

<cfif isdefined("form.import")>
	
	<cfquery datasource="#application.datasource#" name="q_getThisObject" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT formobjectname, formobjectid, formobject.formname, datadefinition, datatable, compositeForm, useWorkFlow
		FROM formobject
		WHERE formobjectid = #SESSION.formobjectid#
		ORDER BY formobjectname
	</cfquery>
	
	<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
		input="#q_getThisObject.datadefinition#"
		output="a_formelements">
<cfelse>
	<cfif isdefined ("SESSION.fieldNamesArray")>
		<cfset structDelete(SESSION,"fieldNamesArray")>
		<cfset structDelete(SESSION,"recordsArray")>
		<cfset structDelete(SESSION,"formobjectid")>
	</cfif>
</cfif>


<cfif isdefined("form.import") AND NOT isdefined("form.fieldsSelected")>	
	<cfsavecontent variable="htmlOutput">
	
	<!---Upload file to temp directory--->
	
	<cftry>
		
		<cffile accept="text/xml" action="upload" destination="#application.installpath#\temp\" filefield="fileselector" nameconflict="overwrite" result="thisUpload">
		 <cfset dataURL = "#thisUpload.serverDirectory#\#thisUpload.clientfile#">
		<cffile action="read" file="#dataURL#" variable="dataRAW">
		<cfset data = xmlParse(dataRAW)> 
	 <cfcatch>
		<cfset REQUEST.iserror = 1>
		<cfset REQUEST.errormsg =  "<b>ERROR: </b>XML file unable to be uploaded to server">
	</cfcatch> 
	</cftry>

	<!--- Parse the xml into an array of field names and a record array of field data arrays --->
	
	 <cfif NOT isdefined("REQUEST.iserror") OR REQUEST.iserror NEQ 1>
		<cftry>
			<cfscript>
				SESSION.fieldNamesArray = Arraynew(1);
				SESSION.recordsArray = Arraynew(1);
				firstRow = true;
				rowXML = data.Workbook.Worksheet.Table.xmlChildren;
			</cfscript>
			
			<cfloop index="rowIndex" from="1" to="#ArrayLen(rowXML)#">
				<cfif rowXML[rowIndex].xmlName EQ "Row">
					<cfset cellXML = rowXML[rowIndex].xmlChildren>
					<cfset recordDataArray = Arraynew(1)>
					<cfloop index="cellIndex" from="1" to="#ArrayLen(cellXML)#">
						<cfset dataXML = cellXML[cellIndex].xmlChildren>
						<cfif arrayLen(dataXML) GT 0>
							<cfloop index="dataIndex" from="1" to="#ArrayLen(dataXML)#">
								<cfif firstRow>
									<cfset arrayAppend(SESSION.fieldNamesArray,dataXML[dataIndex].xmlText)>
								<cfelse>
									<cfset arrayAppend(recordDataArray,dataXML[dataIndex].xmlText)>
								</cfif>
							</cfloop>
						<cfelse>
							<cfif firstRow>
								<cfset arrayAppend(SESSION.fieldNamesArray,"")>
							<cfelse>
								<cfset arrayAppend(recordDataArray,"")>
							</cfif>
						</cfif>
						<cfset cellIndex = cellIndex+1>
					</cfloop>
					<cfif firstRow>
						<cfset firstRow = false>
					<cfelse>
						<cfset arrayAppend(SESSION.recordsArray,recordDataArray)>
					</cfif>
				</cfif>
				<cfset rowIndex = rowIndex+1>
			</cfloop>
		<cfcatch>
			<cfset REQUEST.iserror = 1>
			<cfset REQUEST.errormsg =  "<b>ERROR: </b>Could not parse XML in current format">
		</cfcatch>
		</cftry>
	</cfif>
	
	<cfif NOT isdefined("REQUEST.iserror") OR REQUEST.iserror NEQ 1>
		<cfif arrayLen(SESSION.fieldNamesArray) EQ 0>
			<cfset REQUEST.iserror = 1>
			<cfset REQUEST.errormsg = "<b>ERROR: </b>No field names found in XML">
		</cfif>
	</cfif>
	
	<!--- Check to see if any of the fields in the xml file are not in the specfied table, throw error if one or more exist--->
	
	<cfif NOT isdefined("REQUEST.iserror") OR REQUEST.iserror NEQ 1>
		<cfset unMatchedArray = Arraynew(1)>
		<cfloop index="dataIndex" from="1" to="#arrayLen(SESSION.fieldNamesArray)#">
			<cfset foundMatch = false>
			<cfset currentField = SESSION.fieldNamesArray[dataIndex]>
			<cfloop index="tableIndex" from="1" to="#arrayLen(a_formelements)#">
				<cfif currentField EQ a_formelements[tableIndex].fieldName>
					<cfset foundMatch = true>
					<cfbreak>
				</cfif>
			</cfloop>
			<cfif NOT foundMAtch>
				<cfset arrayAppend(unMatchedArray,currentField)>
			</cfif>
		</cfloop>
		<cfif arrayLen(unMatchedArray) GT 0>
			<cfset REQUEST.iserror = 1>
			<cfset REQUEST.errormsg =  "<b>ERROR: </b>The following fields in the uploaded xml file were not found in the given table '#q_getThisObject.formobjectname#':<br />">
				<cfloop index="i" from="1" to="#arrayLen(unMatchedArray)#">
					<cfset REQUEST.errormsg =  REQUEST.errormsg&"#unmatchedArray[i]#<br />">
				</cfloop>
		</cfif>
	</cfif>
	</cfsavecontent>
</cfif>

	
<cfif isdefined("form.fieldsSelected")>
	<cfsavecontent variable="htmlOutput">
	
		<!--- Write all the fields in the XML that were also specified in the import field form into the specified table --->
		<cfif NOT isdefined("REQUEST.iserror") OR REQUEST.iserror NEQ 1>
			<cfset fieldnames = form.fieldnames>
			<!--- <cftry> --->
				<cfloop index="recordIndex" from="1" to="#arrayLen(SESSION.recordsArray)#">
					<cfset structclear(form)>
					<cfset currentRecordArray = SESSION.recordsArray[recordIndex]>
					<cfloop index="dataIndex" from="1" to="#arrayLen(SESSION.fieldNamesArray)#">
						<cfif len(trim(currentRecordArray[dataIndex]))>
					
							<cfset insertField = false>
							<cfloop index="listIndex" from="1" to="#listlen(fieldnames)#">
								<cfif findNoCase(SESSION.fieldNamesArray[dataIndex],listgetAt(fieldnames,listIndex))>
									<cfset insertField = true>
									<cfbreak>
								</cfif>
							</cfloop>
							
							<cfif insertField>
								<cfif currentRecordArray[dataIndex] EQ 'yes'>
									<cfset "form.#SESSION.fieldNamesArray[dataIndex]#" = 1>
								<cfelseif currentRecordArray[dataIndex] EQ 'no'>
									<cfset "form.#SESSION.fieldNamesArray[dataIndex]#" = 0>
								<cfelseif SESSION.fieldNamesArray[dataIndex] EQ 'datemodified'>
									<cfset "form.#SESSION.fieldNamesArray[dataIndex]#" = createodbcdatetime(now())>
								<cfelseif SESSION.fieldNamesArray[dataIndex] EQ 'datecreated'>
									<cfset "form.#SESSION.fieldNamesArray[dataIndex]#" = createodbcdatetime(now())>
								<cfelse>
									<cfset "form.#SESSION.fieldNamesArray[dataIndex]#" = currentRecordArray[dataIndex]>
								</cfif>
							</cfif>
							
						</cfif>
					</cfloop>
					
					
					<cfif structcount(form)>
						<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
									 datasource="#application.datasource#"
									 tablename="#q_getThisObject.formname#"
									 assignidfield="#q_getThisObject.formName#id">
					</cfif>
				</cfloop>
			<!--- <cfcatch>
				<cfset REQUEST.iserror = 1>
				<cfset REQUEST.errormsg = "<b>ERROR: </b>Could not write into table">
			</cfcatch>
			</cftry> --->
		</cfif>
		
		<cfif NOT isdefined("REQUEST.iserror") OR REQUEST.iserror NEQ 1>
			<cfset REQUEST.iserror = 1>
			<cfset REQUEST.errormsg = "Successfully entered data into table">
		</cfif>
	
		</cfsavecontent>
</cfif> 

	<!---Build import form--->
	
	<cfsavecontent variable="htmlOutput">
		<cfoutput>
		<div id="socketformheader">
			<h2>Import Data</h2>
		</div>
		<div style="clear:both";></div>
		<cfif isdefined("REQUEST.iserror")>
			#REQUEST.errormsg#
		</cfif>
			<table style="margin-left:40px;">
				<tbody>
				<form method="post" name="fieldForm" id="fieldForm" enctype="multipart/form-data" >
				<tr>
					<td class="formitemlabelreq">Select Table to Import to</td>
					<cfif isDefined('form.import') AND (NOT isdefined("REQUEST.iserror") OR REQUEST.iserror NEQ 1)>
						<td class="formiteminput">
							<select id="formobjectlist" name="formobjectlist" disabled="disabled">
							<option SELECTED=selected value="#q_getThisObject.formobjectid#">#q_getThisObject.formobjectname#</option>

							</select>
						</td>
					<cfelse>
						<td class="formiteminput">
							<select id="formobjectlist" name="formobjectlist">
							<option value="0">Select Table</option>
							<cfloop query="q_getFormObjects">
								<option value="#q_getFormObjects.formobjectid#">#q_getFormObjects.formobjectname#</option>
							</cfloop>
							</select>
						</td>
					</cfif>
				</tr>
						
				<tr>
					<td class="formitemlabelreq">Select XML File</td>
					<td class="formiteminput">
						<cfif isDefined('form.import') AND (NOT isdefined("REQUEST.iserror") OR REQUEST.iserror NEQ 1)>
							<input type="file" name="fileSelector" value="form.fileSelector" id="fileSelector" disabled="disabled"/>
						<cfelse>
							<input type="file" name="fileSelector" id="fileSelector"/>
						</cfif>
					</td>
					
				</tr>
			
				
				<cfif isDefined('form.import') AND (NOT isdefined("REQUEST.iserror") OR REQUEST.iserror NEQ 1)>
					<tr>
						<td class="formitemlabelreq">Select which of the following<br /> fields to import data</td>
						<td class="formiteminput">
						<cfloop index="i" from="1" to="#arraylen(SESSION.fieldNamesArray)#">
							#SESSION.fieldNamesArray[i]#:<input type="checkbox" id="fieldname_#i#" name="fieldname_#SESSION.fieldNamesArray[i]#" />&nbsp;&nbsp;
						</cfloop><br /><br />
						Check all: <input type="checkbox" id = "checkall" onchange="checkAll(#arraylen(SESSION.fieldNamesArray)#)" />
						</td>
					</tr>
					<tr>
					<input type="hidden" name="fieldsSelected" value="1" />
						<td colspan="2" align="center"><input type="button" class="submitbutton" onclick="verifyFields(#arraylen(SESSION.fieldNamesArray)#)" value="Import File" /></td>
					</tr>
				<cfelse>
				`	<tr>
					<td colspan="2" align="center">
					<input type="button" class="submitbutton" onclick="verifyTable()" value="Import File" />
					</td>
				</cfif>
				<input type="hidden" name="import" value="1"/>
				</form>
			</tbody>
			</table>
			</div>
			
	</cfoutput>
	</cfsavecontent>
	
</cfsilent>

<cfoutput>#htmlOutput#</cfoutput>


