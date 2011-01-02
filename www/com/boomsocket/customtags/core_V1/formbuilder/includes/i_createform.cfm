<cfif isDefined("formobjectid")>
	<cfinclude template="i_getFormobject.cfm">
<cfelse>
This action requires a formobject ID!
	<cfabort>
</cfif>

<cfif isdefined("SESSION.currentFieldRow")>
	<cfset StructDelete(Session, "currentFieldRow")>
</cfif>

<!--- BUILD FORM for display --->
<cfsavecontent variable="flatHTML">
	<cfset request.createflatfile=0>
</cfsavecontent>
<!--- Final form step in process. Configure Form Output options --->
<cfoutput>

<script language="JavaScript">
	function Field_up(lst) {
			var i = lst.selectedIndex;
			if (i>0) Field_swap(lst,i,i-1);
		}
	function Field_down(lst) {
			var i = lst.selectedIndex;
			if (i<lst.length-1) Field_swap(lst,i+1,i);
		}
	function Field_swap(lst,i,j) {
			var t = '';
			t = lst.options[i].text; lst.options[i].text = lst.options[j].text; lst.options[j].text = t;
			t = lst.options[i].value; lst.options[i].value = lst.options[j].value; lst.options[j].value = t;
			t = lst.options[i].selected; lst.options[i].selected = lst.options[j].selected; lst.options[j].selected = t;
			t = lst.options[i].defaultSelected; lst.options[i].defaultSelected = lst.options[j].defaultSelected; lst.options[j].defaultSelected = t;
		}		
	function SetFields(lst,lstSave) {
			var t;
			lstSave.value=""
			for (t=0;t<=lst.length-1;t++)
				lstSave.value+=String(lst.options[t].value)+",";
			if (lstSave.value.length>0)
				lstSave.value=lstSave.value.slice(0,-1);
			return true;
		}
	function validateSelections(){
		if(document.finalform.editfieldkeyvalue.value == ''){
			document.finalform.toolaction.value='createform';
			alert('You must select at least one (1) Key Field from the List View Fields');
			return false;
		}else if(document.finalform.editfieldsortorder.value == ''){
			document.finalform.toolaction.value='createform';
			alert('You must select at least one (1) Sort Key Field from the List View Fields');
			return false;
		}else if(document.finalform.editfieldkeyvalue2.value == ''){
			document.finalform.toolaction.value='createform';
			alert('You must select at least one (1) Key Field from the Detail View Fields');
			return false;
		}else if(document.finalform.editfieldsortorder2.value == ''){
			document.finalform.toolaction.value='createform';
			alert('You must select at least one (1) Sort Key Field Default from the Detail View Fields');
			return false;
		}else{
			document.finalform.toolaction.value='createformpost';
			document.finalform.submit();
		}
	}	
</script>
	<form action="#request.page#" method="post" id="finalform" name="finalform">
	<input type="Hidden" name="formobjectid" id="formobjectid" value="#formobjectid#">
	<input type="Hidden" name="formenvironmentname" id="formenvironmentname" value="#q_getform.formenvironmentname#">
	<input type="Hidden" name="toolaction" id="toolaction" value="createformpost">
	<input type="Hidden" name="formEnvironmentID" id="formEnvironmentID" value="#q_getform.formEnvironmentID#">
	<div id="socketformheader"><h2>Shuffle Table Layout</h2></div><div style="clear:both;"></div>
	<table cellpadding="3" cellspacing="1" id="socketformtable">
	<tr>
		<td class="formiteminput">Form Type:</td>
		<td class="formiteminput">#q_getform.formEnvironmentName#</td>
	</tr>
<cfif q_getform.datacapture>
<!--- If this object will be editable show controls for selecting fields to expose for identification
in some type of select mechanism --->
	<cfif q_getform.editfieldkey EQ 1>
	<!--- Create deserialized listing of form elements to replace column listing --->
		<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
			input="#q_getform.datadefinition#"
			output="a_formelements">
		<tr>
			<td colspan="2" class="subtoolheader">List View Fields</td>
		</tr>
		<tr>
			<td valign="top" class="formitemlabelreq">Key Field(s):</td>
			<td class="formiteminput">


				<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="formiteminput">
					<input type="hidden" name="updatesort1" value="yes">
					<input type="HIDDEN" name="FieldsSave1">
					<select name="editfieldkeyvalue" size="#arrayLen(a_formelements)#" multiple="multiple" class="ordinalSelect" style="width:300px;">
						<cfloop list="#q_getform.editfieldkeyvalue#" index="k">
							<option value="#k#" selected>#k#</option>
						</cfloop>
						<cfloop from="1" to="#ArrayLen(a_formelements)#" index="i">
							<cfif NOT listfindnocase(q_getform.editfieldkeyvalue,a_formelements[i].fieldname,",")>
								<option value="#a_formelements[i].fieldname#">#a_formelements[i].fieldname#</option>
							</cfif>
						</cfloop>
					</select>
				</td>
					<td width="100%" class="formiteminput"><input type="button" name="up" value="up" class="submitbutton" style="width: 50px;" onclick="javascript:Field_up(document.finalform.editfieldkeyvalue);"><br /><input type="button" name="down" value="down" class="submitbutton" style="width: 50px;" onclick="javascript:Field_down(document.finalform.editfieldkeyvalue);">
					</td>
				</tr>
				</table>
				
			</td>
		</tr>
		<tr>
			<td valign="top" class="formitemlabelreq">Sort Key Field(s):</td>
			<td valign="top" class="formiteminput"> 
			<cfset selectSize=(arraylen(a_formelements)\2)+1>
			<select name="editfieldsortorder" size="#selectSize#" multiple="multiple" class="ordinalSelect" style="width:300px;">
				<cfloop from="1" to="#ArrayLen(a_formelements)#" index="i">
					<option value="#a_formelements[i].fieldname# ASC"<cfif listfindnocase(q_getform.editfieldsortorder,"#a_formelements[i].fieldname# ASC",",")> SELECTED</cfif>>#a_formelements[i].fieldname# ASC </option>
					<option value="#a_formelements[i].fieldname# DESC"<cfif listfindnocase(q_getform.editfieldsortorder,"#a_formelements[i].fieldname# DESC",",")> SELECTED</cfif>>#a_formelements[i].fieldname# DESC </option>
				</cfloop>
			</select>
			</td>
		</tr>
		<tr>
			<td colspan="2" class="subtoolheader">Detail View Fields</td>
		</tr>
		<tr>
			<td valign="top" class="formitemlabelreq">Key Field(s):</td>
			<td class="formiteminput">


				<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="formiteminput">
					<input type="hidden" name="updatesort" value="yes">
					<input type="HIDDEN" name="FieldsSave2">
					<select name="editfieldkeyvalue2" size="#arrayLen(a_formelements)#" multiple="multiple" class="ordinalSelect" style="width:300px;">
						<cfloop list="#q_getform.editfieldkeyvalue2#" index="k">
							<option value="#k#" selected>#k#</option>
						</cfloop>
						<cfloop from="1" to="#ArrayLen(a_formelements)#" index="i">
							<cfif NOT listfindnocase(q_getform.editfieldkeyvalue2,a_formelements[i].fieldname,",")>
								<option value="#a_formelements[i].fieldname#">#a_formelements[i].fieldname#</option>
							</cfif>
						</cfloop>
					</select>
				</td>
					<td width="100%" class="formiteminput"><input type="button" name="up" value="up" class="submitbutton" style="width: 50px;" onclick="javascript:Field_up(document.finalform.editfieldkeyvalue2);"><br /><input type="button" name="down" value="down" class="submitbutton" style="width: 50px;" onclick="javascript:Field_down(document.finalform.editfieldkeyvalue2);"></td>
				</tr>
				</table>
				
			</td>
		</tr>
		<tr>
			<td valign="top" class="formitemlabelreq">Sort Key Field Default:</td>
			<td valign="top" class="formiteminput">
			<cfset selectSize=(arrayLen(a_formelements)\2)+1>
			<select name="editfieldsortorder2" style="width:300px;" class="ordinalSelect">
				<cfloop from="1" to="#ArrayLen(a_formelements)#" index="i">
					<option value="#a_formelements[i].fieldname# ASC"<cfif listfindnocase(q_getform.editfieldsortorder2,"#a_formelements[i].fieldname# ASC",",")> SELECTED</cfif>>#a_formelements[i].fieldname# ASC </option>
					<option value="#a_formelements[i].fieldname# DESC"<cfif listfindnocase(q_getform.editfieldsortorder2,"#a_formelements[i].fieldname# DESC",",")> SELECTED</cfif>>#a_formelements[i].fieldname# DESC </option>
				</cfloop>
			</select>
			</td>
		</tr>
	</cfif>
	<!--- close test for datacapture --->
	</cfif>
	<cfif q_getform.editfieldkey EQ 1>
		<cfset jscript="javascript:SetFields(document.finalform.editfieldkeyvalue,document.finalform.FieldsSave1);javascript:SetFields(document.finalform.editfieldkeyvalue2,document.finalform.FieldsSave2);">
	<cfelse>
		<cfset jscript="">
	</cfif>
	<tr>
		<td align="center" class="formiteminput" colspan="2"><input type="button" value="Back" class="submitbutton" style="width:100;" onclick="javascript: window.location.href='#request.page#?formobjectid=#formobjectid#&toolaction=DEShowForm';" /><cfif q_getform.generateFile GT 0 OR len(q_getform.generateFile) GT 0><input type="button" value="Complete Form" class="submitbutton" onclick="#jscript#<cfif q_getform.editfieldkey EQ 1>javascript:validateSelections();<cfelse>submit();</cfif>"><cfelse><input type="submit" value="Complete Form" class="submitbutton" onclick="#jscript#"></cfif></td>
	</tr>
	</table>
	</form>
<!--- Show this only if there is no engine path specified in the form environment--->
<cfif NOT len(q_getform.engineDefaultPath)>
	<hr color="##000000" width="70%" size="1" align="center" noshade>
		<form>
			#flatHTML#
		</form>
	
	<form>
	<h3>Copy your HTML form here...</h3>
		<table cellpadding="3" cellspacing="1"><!--- Display HTML FORM CODE --->
			<tr>
				<td colspan="2" class="formiteminput"><textarea cols="80" rows="30" name="flatHTML" wrap="off">#chr(60)#form action="#q_getForm.formaction#" method="#q_getForm.formmethod#"#chr(62)##application.HtmlCompressFormat(flatHTML)##chr(60)#/form#chr(62)#</textarea></td>
			</tr>
			<tr>
				<td align="center"><input type="Button" value="Return to FormBuilder" class="submitbutton" onclick="javascript: window.open('#request.page#','_top');"></td>
			</tr>
		</table>
		
	</form>
</cfif>
</cfoutput>

