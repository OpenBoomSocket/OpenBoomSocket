<form action="<cfoutput>#Request.page#</cfoutput>" method="post" id="navManager" name="navManager">
	<input type="hidden" name="formAction" value="" />
	<input type="hidden" name="liveEditWindow" value="<cfoutput>#FORM.liveEditWindow#</cfoutput>" />
	<cfif IsDefined('thisNavGroupID')>
		<input type="hidden" name="dynamicnavigationgroupid" value="<cfoutput>#thisNavGroupID#</cfoutput>" />
	</cfif>
	<cfif IsDefined('q_Children') and q_Children.recordCount>
		<input type="hidden" name="FieldsSave" value="<cfoutput>#ValueList(q_Children.dynamicnavigationid)#</cfoutput>" />
	<cfelse>
		<input type="hidden" name="FieldsSave" value="<cfoutput>#ValueList(q_parents.dynamicnavigationid)#</cfoutput>" />
	</cfif>
	<cfif IsDefined('q_Detail') and q_Detail.RecordCount>
		<input type="hidden" name="dynamicnavigationid" value="<cfoutput>#q_Detail.dynamicnavigationid#</cfoutput>" />
	</cfif>
	<table width="100%" border="0" cellspacing="1" cellpadding="3" class="tooltable">
		<tr>
		  <td colspan="2" class="toolheader">Navigation Manager</td>
		</tr>
		<tr>
		  <td class="subtoolheader" colspan="2">
		  <input value="New" src="#application.globalPath#/media/images/icon_addFile.gif" title="Add a New Navigation Element" type="image" name="New" id="New" onclick="clearForm(); return false;">
			<cfif IsDefined('message') and Len(Trim(message))>
				<cfoutput><p style="color:##FFFFFF; width:450px; margin-left:50px;">#message#</p></cfoutput>
			</cfif>
		  </td>
		</tr>
		<tr>
			<td width="42%" rowspan="3" align="left" valign="middle" class="formiteminput">
			<table width="0" border="0" align="center" cellpadding="0" cellspacing="0">
				<tr>
				  <td align="right" valign="middle">Double click an item below to edit and reveal its sub menu items.<br /><br />
						<select name="navItems" size="15" id="navItems" ondblclick="updateDetails()">
							<cfif IsDefined('q_Children')>
								<option value="">Top Level</option>
								<cfif IsDefined('FORM.navItems') AND FORM.navItems GT 0>
									<cfset optionList = wrapper.doWrapOption(q_querydata=allnav, wraplevel=0, groupID=thisNavGroupID,currentParentID=FORM.parentid, currentNavID=FORM.navItems, topOnly=0,classbase='navItemLevel')>
								<cfelse>
									<cfset optionList = wrapper.doWrapOption(q_querydata=allnav, wraplevel=0, groupID=thisNavGroupID,currentParentID=FORM.parentid, currentNavID=FORM.dynamicNavigationID, topOnly=0,classbase='navItemLevel')>
								</cfif>										
								<cfoutput>#optionList#</cfoutput>
							<cfelse>
								<cfset optionList = wrapper.doWrapOption(q_querydata=q_parents, groupID=thisNavGroupID, wrapLevel=0)>
								<cfoutput>#optionList#</cfoutput>
							</cfif>
						</select>
				  </td>
				  <td height="33%" align="left" valign="middle"><table width="100%" border="0" cellspacing="1" cellpadding="3">
					<tr>
					  <td align="center" valign="middle"><input name="up" type="button" id="up" value="UP" onclick="Field_up(document.navManager.navItems);" class="submitbutton"/></td>
					</tr>
					<tr>
					  <td align="center" valign="middle">&nbsp;</td>
					</tr>
					<tr>
					  <td align="center" valign="middle"><input name="dn" type="button" id="dn" value="DN" onclick="Field_down(document.navManager.navItems);" class="submitbutton"/></td>
					</tr>
				  </table></td>
				</tr>
			  </table>
		  </td>
		</tr>
		<tr>
			<td align="left" valign="top" class="formiteminput">
			<table width="100%" border="0" cellspacing="0" cellpadding="3">
			  <tr>
				  <td align="right">Parent:</td>
				  <td><select name="parentID" id="parentID">
				  <option value=""><--- Select One ---></option>
				<cfif IsDefined('q_Children')>
					<option value="">Top Level</option>
					<cfif IsDefined('FORM.navItems') AND FORM.navItems GT 0>
						<cfset optionList = wrapper.doWrapOption(q_querydata=allnav, wraplevel=0, groupID=thisNavGroupID,currentParentID=FORM.parentid, currentID=FORM.parentid, currentNavID=FORM.navItems, topOnly=0,classbase='parentLevel')>
					<cfelse>
						<cfset optionList = wrapper.doWrapOption(q_querydata=allnav, wraplevel=0, groupID=thisNavGroupID,currentParentID=FORM.parentid, currentID=FORM.parentid, currentNavID=FORM.dynamicNavigationID, topOnly=0,classbase='parentLevel')>
					</cfif>
					<cfoutput>#optionList#</cfoutput>
				<cfelse>
					<cfset optionList = wrapper.doWrapOption(q_querydata=allnav, wraplevel=0, groupID=thisNavGroupID, topOnly=1)>
					<cfoutput>#optionList#</cfoutput>
				</cfif>
			  </select></td>
			  </tr>
			  <tr>
				<td align="right">Label:</td>
				<td align="left"><input name="label" id="label" type="text" size="40" value="<cfif IsDefined('q_Detail')><cfoutput>#q_Detail.Name#</cfoutput></cfif>" /></td>
			  </tr>
			  <tr>
				<td align="right">Page:</td>
				<td align="left"><select name="pageid" id="pageid">
					<option value=""><--- Select One ---></option>
					<cfoutput query="q_Pages">
					  <cfset thisPath = application.getSectionPath(q_Pages.sitesectionid,true,'/')>
					  <option value="#q_Pages.pageid#" <cfif IsDefined('q_Detail.pageid') AND q_Pages.pageid EQ q_Detail.pageid>selected="selected"</cfif>>/#thisPath#/#q_Pages.pagename#</option>
					</cfoutput>
				  </select></td>
			  </tr>
			  <tr>
				<td colspan="2" style="padding-left:50px;"><strong>OR</strong></td>
			  </tr>
			  <tr>
				<td align="right">URL:</td>
				<td align="left"><input name="href" id="href" type="text" <cfif isdefined('q_detail.href') and len(trim(q_detail.href))>value="<cfoutput>#q_detail.href#</cfoutput>" </cfif>size="40" /></td>
			  </tr>
			  <tr>
				<td align="right">Target:</td>
				<td align="left"><select name="target" id="target">
				  <option value="" <cfif IsDefined('q_Detail.target') AND q_Detail.target EQ '_self' OR IsDefined('q_Detail.target') AND q_Detail.target EQ ''>selected="selected"</cfif>>Same
				  Window</option>
				  <option value="_blank" <cfif IsDefined('q_Detail.target') AND q_Detail.target EQ '_blank'>selected="selected"</cfif>>New
				  Window</option>
				</select></td>
			  </tr>
			  <tr>
				<td colspan="2" class="subtoolheader">Use Images (optional)</td>
			  </tr>
			  <tr class="navImages">
				<td align="right">On State:</td>
				<td><cfmodule template="#application.customTagPath#/filechooser.cfm" categoryid="100007" fieldname="imageOn"></cfmodule></td>
			  </tr>
			  <tr class="navImages">
				<td align="right">Off State:</td>
				<td><cfmodule template="#application.customTagPath#/filechooser.cfm" categoryid="100006" fieldname="imageOff"></cfmodule></td>
			  </tr>
			  <tr class="navImages">
				<td align="right">At State:</td>
				<td><cfmodule template="#application.customTagPath#/filechooser.cfm" categoryid="100008" fieldname="imageAt"></cfmodule></td>
			  </tr>
			  <tr>
				<td align="right">Active:</td>
				<td> <input name="active" type="radio" value="1" checked="checked" /> Yes <input name="active" type="radio" value="0" /> No</td>
			  </tr>
			</table>
			</td>
		</tr>
		<tr>
			<td align="center" class="formiteminput">
				  <input name="menuAction" type="button" id="menuAction" value="Save" onclick="SetFields(document.navManager.navItems,document.navManager.FieldsSave);" class="submitbutton" style="width:90px;"/>
				  <input type="button" value="Close" name="close" id="close" onclick="opener.window.location.reload();self.close();return false;" class="submitbutton" style="width:90px;" />
				  <input name="delAction" type="submit" id="delAction" value="Delete" class="deletebutton" onclick="return confirmDelete();" style="width:90px;"/>
			</td>
		</tr>
	</table>
</form>