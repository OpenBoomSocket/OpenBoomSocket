<!--- This include provides an interface for sorting the order of table rows --->
<script>
	// This is for the change sort order functionality
	function Field_up(lst) 
	{
		var i = lst.selectedIndex;
		if (i>0) Field_swap(lst,i,i-1);
	}
	function Field_down(lst) 
	{
		var i = lst.selectedIndex;
		if (i<lst.length-1) Field_swap(lst,i+1,i);
	}
	function Field_swap(lst,i,j) 
	{
		var t = '';
		t = lst.options[i].text; lst.options[i].text = lst.options[j].text; lst.options[j].text = t;
		t = lst.options[i].value; lst.options[i].value = lst.options[j].value; lst.options[j].value = t;
		t = lst.options[i].selected; lst.options[i].selected = lst.options[j].selected; lst.options[j].selected = t;
		t = lst.options[i].defaultSelected; lst.options[i].defaultSelected = lst.options[j].defaultSelected; lst.options[j].defaultSelected = t;
	}
	function SetFields(lst,lstSave) 
	{
		var t;
		lstSave.value=""
		for (t=0;t<=lst.length-1;t++)
			lstSave.value+=String(lst.options[t].value)+",";
		if (lstSave.value.length>0)
			lstSave.value=lstSave.value.slice(0,-1);
	}
</script>
	<cfquery datasource="#application.datasource#" name="q_getDataDef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT datadefinition, tablerows
		FROM  formobject
		WHERE (formobjectid = #formobjectid#)
	</cfquery>
		<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
		input="#q_getdatadef.datadefinition#"
		output="a_formelements">
				
		<cfset a_optionItems=arrayNew(1)>
		<cfloop from="1" to="#q_getDataDef.tablerows#" index="k">
			<cfset a_optionItems[k]="---UNASSIGNED---">
		</cfloop>
			<cfloop from="1" to="#arrayLen(a_formelements)#" index="j">
				<cfscript>
					if (NOT listFind("hidden",a_formelements[j].inputtype)){
						position=listFirst(structFind(a_formelements[j],"gridposlabel"),"_");
						a_optionItems[position]=a_formelements[j].objectlabel;
					}
				</cfscript>
			</cfloop>
<cfif q_getDataDef.tablerows GT 25>
	<cfset selectSize=25>
<cfelse>
	<cfset selectSize=q_getDataDef.tablerows>
</cfif>

<cfoutput>
	<form name="orderRows" action="#request.page#" method="post"  onsubmit="SetFields(document.orderRows.sort);">
	<input type="hidden" name="formobjectid" value="#formobjectid#">
	<input type="hidden" name="toolaction" value="shufflelayoutPost">
	<input type="hidden" name="FieldsSave">
		<table cellpadding="4" cellspacing="1" border="0" align="center" width="100%">
			<td valign="top" colspan="2" class="formitemlabelreq">Use the directional buttons below to shift rows to new positions in the form.</td>
		</tr>
		<tr valign="top">
			<td class="formitemlabel">
				<select name="sort" size="#selectSize#" multiple="multiple" class="ordinalSelect">
				 	<cfloop index="i" from="1" to="#arrayLen(a_optionItems)#">
						<option value="#i#">[row #i#] #a_optionItems[i]#</option>
					</cfloop>
				</select>
			</td>
			<td class="formitemlabel">
			<input type="button" name="up" class="submitbutton" value="up" style="width: 60;" onclick="javascript:Field_up(document.orderRows.sort)">
			<p>
			<input type="button" name="down" class="submitbutton" value="down" style="width: 60;" onclick="javascript:Field_down(document.orderRows.sort)">
			<p>
			<input type="button" name="mode" value="Update Layout" class="submitbutton"  style="width: 120;" onclick="javascript:SetFields(document.orderRows.sort,document.orderRows.FieldsSave);document.orderRows.submit()"></td>
		</tr>
		</table>
	</form>
</cfoutput>