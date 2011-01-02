<!--- Query for XML cell data --->
<cfquery datasource="#application.datasource#" name="q_getTableDef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT formobject.tabledefinition, formEnvironment.stylesheet
	FROM formobject INNER JOIN formEnvironment 
					ON formobject.formEnvironmentID = formEnvironment.formEnvironmentID
	WHERE formobjectid = #formobjectid#
</cfquery>
<cftry>
<!--- WDDX unwrap XML cell data --->
<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
input="#q_gettabledef.tabledefinition#"
output="a_tableelements">
<cfcatch type="Any">
	<h1>Invalid XML Object</h1>The object you are trying to reference is not recognizable XML. Check the database.
	<cfdump var="#a_tableelements#">
	<cfabort>
</cfcatch>		
</cftry>

<!--- <cfoutput>#expandPath(application.globalpath)#</cfoutput> --->
<cfif q_getTableDef.stylesheet eq "css\admintools.css">
	<cfset cssFile = "#expandPath(application.globalpath)#\css\admintoolsCSS.cfm">
<cfelse>
	<cfset cssFile = "#application.installpath#\#q_getTableDef.stylesheet#">
</cfif>

<!--- Build a select menu based on the specified style sheet for this form environ --->
<cffile action="READ"
	file="#cssFile#"
	variable="fileContent">

<!--- only grab styles inside the <!-- {} --> list at the top of the stylesheet --->
<cfset thisClassList = "">
<cfset styleRegEx = '<!-- {([a-zA-Z0-9##.,]{1,})} -->'>
<cfset cellpropertiesLenPos = REFindNoCase(styleRegEx , fileContent, 0, true)>
<cfif cellpropertiesLenPos.len[1] gt 0>
	<cfset thisClassList = MID(fileContent, cellpropertiesLenPos.pos[2], cellpropertiesLenPos.len[2])>
</cfif>
			
<!--- Legacy - Used to grab all classes from the stylesheet
<cfscript>
	start=1;
	thisClassList="";
	while (start GT 0) {
		thisClass=REFindNoCase('\.[[:alnum:] ]*\{',filecontent,start,1);
		if (thisClass.pos[1]) {
			thisClassList=listAppend(thisClassList,trim(mid(filecontent,thisClass.pos[1]+1,thisClass.len[1]-2)));
			start=val(thisClass.pos[1]+thisClass.len[1]);
		} else {
			start=0;
		}
	}
</cfscript> --->

<!--- Update XML cell props blob--->
<cfscript>
	form.colspan=evaluate("a_tableelements[#listFirst(thisCell)#].cell_#listLast(thisCell)#.colspan");
	form.rowspan=evaluate("a_tableelements[#listFirst(thisCell)#].cell_#listLast(thisCell)#.rowspan");
	form.width=evaluate("a_tableelements[#listFirst(thisCell)#].cell_#listLast(thisCell)#.width");
	form.valign=evaluate("a_tableelements[#listFirst(thisCell)#].cell_#listLast(thisCell)#.valign");
	form.align=evaluate("a_tableelements[#listFirst(thisCell)#].cell_#listLast(thisCell)#.align");
	form.class=evaluate("a_tableelements[#listFirst(thisCell)#].cell_#listLast(thisCell)#.class");
</cfscript> 

<cfif structKeyExists(evaluate("a_tableelements[#listFirst(thisCell)#].cell_#listLast(thisCell)#"),"nowrap") AND evaluate("a_tableelements[#listFirst(thisCell)#].cell_#listLast(thisCell)#.nowrap") EQ 1>
	<cfset form.nowrap=1>
<cfelse>
	<cfset form.nowrap=0>
</cfif>
<!--- Set defaults from XML --->
<cfparam name="form.colspan" default="">
<cfparam name="form.rowspan" default="">


<cfoutput>
<!--- Show errors if i_validate.cfm found any... --->
<cfif isDefined("request.isError") AND request.isError eq 1>
<h3>Error</h3>
	<ul>
		<cfloop list="#request.errorMsg#" index="error" delimiters="||">
			<li>#error#</li>
		</cfloop>
	</ul>
<hr color="##000000" size="1" align="center" width="100%">
</cfif>
	<form action="#request.page#" method="post">
	<input type="Hidden" name="validatelist" value="colspan,int;rowspan,int;">
	<input type="Hidden" name="toolaction" value="cellpropertiesPost">
	<input type="Hidden" name="formobjectid" value="#formobjectid#">
	<input type="Hidden" name="thisrow" value="#listFirst(thisCell)#">
	<input type="Hidden" name="thiscell" value="#listLast(thisCell)#">
	
	<table align="center" width="100%" height="100%" class="toolTable" cellpadding="3" cellspacing="1">
	<tr>
		<td class="formbuildertext" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="50%" align="left" valign="top">Width<br><input type="Text" name="width" size="4" value="#form.width#"></td>
		<td width="50%" align="left" valign="top">NoWrap<br><input type="checkbox" name="nowrap" value="1"<cfif isDefined("form.nowrap") AND form.nowrap EQ 1> checked</cfif>></td>
	</tr>
	</table></td>
		<td class="formbuildertext" valign="top">Align<br><select name="align">
		<option value="Left"<cfif form.align EQ "Left"> selected</cfif>>Left</option>
		<option value="Right"<cfif form.align EQ "Right"> selected</cfif>>Right</option>
		<option value="Center"<cfif form.align EQ "Center"> selected</cfif>>Center</option></select></td>
	</tr>
	<tr>
		<td class="formbuildertext" valign="top">Style class<br>
		<cfif listLen(thisClassList)>
		<select name="class" size="1">
			<option value="">None</option>
			<cfloop list="#thisClassList#" index="thisClass">	
			<option value="#thisClass#"<cfif form.class EQ thisClass> SELECTED</cfif>>#thisClass#</option>
			</cfloop>
		</select>
	<cfelse><input type="Text" name="class" size="4" value="#form.class#"></cfif></td>
		<td class="formbuildertext" valign="top">Veritcal Align<br><select name="valign">
		<option value="Top"<cfif form.valign EQ "Top"> selected</cfif>>Top</option>
		<option value="Bottom"<cfif form.valign EQ "Bottom"> selected</cfif>>Bottom</option>
		<option value="Middle"<cfif form.valign EQ "Middle"> selected</cfif>>Middle</option></select></td>
	</tr>
	<tr>
		<td class="formbuildertext" valign="top">Column Span<br>
		<select name="colspan">
			<option value="">None
			<cfloop index="i" from="2" to="#url.cols#">
				<option value="#i#"<cfif form.colspan EQ i> SELECTED</cfif>>#i#
			</cfloop>
		</select>
		</td>
		<td class="formbuildertext" valign="top">Row Span<br>
		<select name="rowspan">
			<option value="">None
			<cfloop index="i" from="2" to="#url.rows#">
				<option value="#i#"<cfif form.rowspan EQ i> SELECTED</cfif>>#i#
			</cfloop>
		</select>
		</td>
	</tr>
	<tr>
		<td colspan="2" align="center" class="formbuildertext" valign="top" height="100%"><input type="Submit" value="Update Cell" class="submitbutton" style="width:100px"></td>
	</tr>
	</table>
	</form>
</cfoutput>
