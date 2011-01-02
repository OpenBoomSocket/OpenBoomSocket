<cfparam name="innerstep" default="showForm">
<cfswitch expression="#innerstep#">
<cfcase value="postOrderElements">
	<cfset position=1>
	<cfloop list="#form.fieldssave#" index="x">
		<<cfquery datasource="#application.datasource#" name="q_updateElements" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			UPDATE formobject
			SET ordinal = #position#
			WHERE  formobjectid = #x#
		</cfquery>
		<cfset position=position+1>
	</cfloop>
	<cflocation url="#request.page#">
</cfcase>
	<cfcase value="showForm">
		<cfquery name="q_getToolCategories" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT toolcategoryid, toolcategoryname FROM toolcategory
		</cfquery>
		<cfoutput>
			<form name="chooseCat" action="#request.page#" method="post" onSubmit="SetFields(document.orderRows.sort);">
				<input type="hidden" name="formobjectid" value="116">
				<input type="hidden" name="toolaction" value="ordinalForm">
				<input type="hidden" name="innerstep" value="showForm">
				Tool Category: 
				<select name="toolcategoryid" onChange="chooseCat.submit()">
					<cfloop query="q_getToolCategories">
						<option value="#q_getToolCategories.toolcategoryid#"<cfif isDefined('form.toolcategoryid')><cfif form.toolcategoryid EQ q_getToolCategories.toolcategoryid> selected</cfif></cfif>>#q_getToolCategories.toolcategoryname#</option>
					</cfloop>
				</select>
			</form>
		</cfoutput>
		<cfif isDefined('form.toolcategoryid')>
			<cfquery datasource="#application.datasource#" name="q_getElements" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT formobjectname AS thisValue, formobjectid AS thisID, ordinal
				FROM formobject
				WHERE toolcategoryid = #form.toolcategoryid#
				ORDER BY ordinal ASC
			</cfquery>
			<cfif q_getElements.recordcount GT 25>
				<cfset selectSize=25>
			<cfelse>
				<cfset selectSize=q_getElements.recordcount>
			</cfif>
			<!--- This include provides an interface for sorting the order of table rows --->
			<cfoutput>
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
			
			
			
			<form name="orderRows" action="#request.page#" method="post"  onSubmit="SetFields(document.orderRows.sort);">
				<input type="hidden" name="formobjectid" value="116">
				<input type="hidden" name="toolaction" value="ordinalForm">
				<input type="hidden" name="innerstep" value="postOrderElements">
				<input type="hidden" name="FieldsSave">
					<table cellpadding="3" cellspacing="1" border="0" width="450" class="toolTable">
					<tr>
						<td valign="top" colspan="2" class="toolheader">Order Tools</td>
					<tr>
						<td valign="top" colspan="2" class="formitemlabelreq">Use the directional buttons below to modify the display order of the records in this table.</td>
					</tr>
					<tr valign="top">
						<td class="formitemlabel" align="center">
							<select name="sort" size="#selectSize#" multiple style="background: ##B0C4DE; font-size: 14px; font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; border: 1px solid ##000000;">
								<cfloop query="q_getElements">
									<option value="#q_getElements.thisID#">#q_getElements.thisValue#</option>
								</cfloop>
							</select>
						</td>
						<td class="formitemlabel">
						<input type="button" name="up" class="submitbutton" value="up" style="width: 60;" onClick="javascript:Field_up(document.orderRows.sort)">
						<p>
						<input type="button" name="down" class="submitbutton" value="down" style="width: 60;" onClick="javascript:Field_down(document.orderRows.sort)">
						<p>
						<input type="button" name="mode" value="Update Layout" class="submitbutton"  style="width: 120;" onClick="javascript:SetFields(document.orderRows.sort,document.orderRows.FieldsSave);document.orderRows.submit()"></td>
					</tr>
					</table>
				</form>
			</cfoutput>
			</cfif>
	</cfcase>
</cfswitch>
