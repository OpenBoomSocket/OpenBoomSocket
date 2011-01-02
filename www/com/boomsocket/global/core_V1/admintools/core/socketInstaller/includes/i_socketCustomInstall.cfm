<!------------------------------------------------- >

ORIGINAL AUTHOR ::::::::: Emile Melbourne (EOM)
	CREATION DATE ::::::::::: 6/22/2008
	LAST MODIFIED AUTHOR :::: EOM
	LAST MODIFIED DATE :::::: 6/22/2008
	EDIT HISTORY :::::::::::: 
								  :: 6/22/2008 yyyy-mm-dd Initial Creation EOM
	FILENAME :::::::::::::::: i_socketCustomInstall.cfm
	DESCRIPTION ::::::::::::: 
-----------------------------------------------------> <cfoutput>
	<div id="socketformheader">
		<h2>Socket Tool Custom Installer</h2>
	</div>
	<div class="clearBoth"></div>
	<div id="socketCustomInstall_form"> </div>
	<!--- Read/parse sockets/{socket name}/data/objectdefinition.xml file for socket data to pre-populate socket update form. Need a CFC for this in socket installer  --->
	<cfset socketObjectDefinition="">
	<cfinvoke component="#APPLICATION.cfcpath#.socketInstaller" method="getSocketObjectDefinition_xml" socketName="#FORM.importname#" returnvariable="socketObjectDefinition">
	<form action="#REQUEST.page#" method="post" name="import">
		<input type="hidden" name="importname" id="importname" value="#FORM.importname#">
		<input type="hidden" name="formAction" id="formAction" value="customInstall">
		<input type="Hidden" name="validatelist" value="formEnvironmentID,required;newdatatable,reservedword;label,required;newdatatable,filename;">
		<table>
			<tr>
				<td class="formitemlabelreq" width="30%">Choose type of form:</td>
				<td class="formiteminput" width="70%"><select name="formEnvironmentID" size="1">
						<option value="">Choose Socket Shell Type</option>
						<option value="110">Guest Management</option>
						<option value="104">BoomSocket Admin (Core)</option>
						<option value="105">BoomSocket Admin (Core/NoDB)</option>
						<option value="106">BoomSocket Admin (Core/SiteSection/Page)</option>
						<option value="108">BoomSocket Admin (Custom No Filter)</option>
						<option value="102">BoomSocket Admin (Custom)</option>
						<option value="107">BoomSocket Admin (Custom/No DB)</option>
						<option value="111">BoomSocket Admin (Flex - requires CF 7.0.2+)</option>
					</select>
				</td>
			</tr>
			<tr>
				<td class="formitemlabelreq">Tool Category:</td>
				<td class="formiteminput"><select name="toolcategoryid" size="1">
						<option value="">Choose a Category</option>
						<option value="100001~Developer Use Only">Developer Use Only</option>
						<option value="100003~People Management">People Management</option>
						<option value="100000~Site Administration">Site Administration</option>
						<option value="100002~Site Content">Site Content</option>
						<option value="100004~Site Planning">Site Planning</option>
					</select></td>
			</tr>
			<tr>
				<td class="formitemlabelreq">Data Table Name:</td>
				<td class="formiteminput"><input type="text" name="newdatatable" id="newdatatable" value="#socketObjectDefinition["formobject"]["DATATABLE"].XmlText#" size="20" maxlength="250" onblur="copyField(this.value);"></td>
			</tr>
			<input type="Hidden" name="datatable" value="" id="datatable">
			<tr>
				<td class="formitemlabelreq">Label:</td>
				<td class="formiteminput"><input name="label" type="text" size="40" value="#socketObjectDefinition["formobject"]["LABEL"].XmlText#"></td>
			</tr>
			<tr>
				<td class="formitemlabel">Work Flow &amp; Versioning:</td>
				<td class="formiteminput"><input name="useWorkFlow" type="radio" value="1" <cfif socketObjectDefinition["formobject"]["USEWORKFLOW"].XmlText EQ 1>CHECKED</cfif> >
					Yes
					<input name="useWorkFlow" type="radio" value="0"  <cfif socketObjectDefinition["formobject"]["USEWORKFLOW"].XmlText NEQ 1>CHECKED</cfif>>
					No</td>
			</tr>
			<tr>
				<td class="formitemlabel">Ordinal Step:</td>
				<td class="formiteminput"><input name="useOrdinal" type="radio" value="1" <cfif socketObjectDefinition["formobject"]["USEORDINAL"].XmlText EQ 1>CHECKED</cfif>>
					Yes
					<input name="useOrdinal" type="radio" value="0" <cfif socketObjectDefinition["formobject"]["USEORDINAL"].XmlText NEQ 1>CHECKED</cfif>>
					No</td>
			</tr>
			<tr>
				<td class="formitemlabel">Bulk Delete:</td>
				<td class="formiteminput"><input name="bulkdelete" type="radio" value="1" <cfif socketObjectDefinition["formobject"]["BULKDELETE"].XmlText EQ 1>CHECKED</cfif>>
					Yes
					<input name="bulkdelete" type="radio" value="0" <cfif socketObjectDefinition["formobject"]["BULKDELETE"].XmlText NEQ 1>CHECKED</cfif>>
					No</td>
			</tr>
			<tr>
				<td class="formitemlabel">Single Record:</td>
				<td class="formiteminput"><input name="singleRecord" type="radio" value="1" <cfif socketObjectDefinition["formobject"]["SINGLERECORD"].XmlText EQ 1>CHECKED</cfif>>
					Yes
					<input name="singleRecord" type="radio" value="0" <cfif socketObjectDefinition["formobject"]["SINGLERECORD"].XmlText NEQ 1>CHECKED</cfif>>
					No</td>
			</tr>
			<tr>
				<td class="formitemlabel">Use Friendly URL:</td>
				<td class="formiteminput"><input name="useVanityURL" id="useVanityURL" type="radio" value="1" <cfif socketObjectDefinition["formobject"]["USEVANITYURL"].XmlText EQ 1>CHECKED</cfif>>
					Yes
					<input name="useVanityURL" id="useVanityURL" type="radio" value="0" <cfif socketObjectDefinition["formobject"]["USEVANITYURL"].XmlText NEQ 1>CHECKED</cfif>>
					No</td>
			</tr>
			<tr>
				<td class="formitemlabel">Records are Navigable:</td>
				<td class="formiteminput"><input name="isNavigable" type="radio" value="1" <cfif socketObjectDefinition["formobject"]["USEVANITYURL"].XmlText EQ 1>CHECKED</cfif>>
					Yes
					<input name="isNavigable" type="radio" value="0" <cfif socketObjectDefinition["formobject"]["USEVANITYURL"].XmlText NEQ 1>CHECKED</cfif>>
					No</td>
			</tr>
			<tr>
				<td class="formitemlabel" colspan="2">
					<input value="Install" name="submitBtn" type="submit" class="submitbutton">
					<input value="Cancel" type="button" class="submitbutton" onClick="javascript:window.location='#REQUEST.page#';">
				</td>
			</tr>
		</table>
	</form>
</cfoutput> 