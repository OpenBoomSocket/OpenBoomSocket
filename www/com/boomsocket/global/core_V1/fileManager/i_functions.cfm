<!--- function to generate generic file manipulation dialog--->
<cffunction name="addEditFile" returntype="string">
	<cfargument name="uploadid" required="no" default="0">
	<cfset var outputHTML=''> <!--- form content field --->
	<!--- populate form with existing data if 'edit' --->
	<cfif arguments.uploadid NEQ 0>
		<cfset thisFile=fmObj.getFileData(uploadid=arguments.uploadid)>
		<cfif thisFile.recordCount>
			<cfset form.uploadid = thisFile.uploadid>
			<cfset form.uploadtitle = thisFile.uploadtitle>
			<cfset form.uploaddescription = thisFile.uploaddescription>
			<cfset form.uploadcategoryid = thisFile.uploadcategoryid>
			<cfset form.active = thisFile.active>
			<cfset form.filesize = thisFile.filesize>
			<cfset form.filetype = thisFile.filetype>
		</cfif>
	</cfif>
	<!--- set defaults for 'add' --->
	<cfparam name="form.uploadid" default=0>
	<cfparam name="form.uploadtitle" default="">
	<cfparam name="form.uploaddescription" default="">
	<cfparam name="form.filesize" default=0>
	<cfparam name="form.uploadcategoryid" default="#trim(session.user.filemanager_listuploadcategory)#">
	<cfparam name="form.active" default="1">
	<cfparam name="form.filetype" default="">
	<cfparam name="form.resizeOnValue" default="0">
	<cfparam name="form.imageThumbSize" default="0">
	<cfset categoryList = fmObj.getCategoriesData()>
	<cfsavecontent variable="outputHTML">
	<cfoutput>
	<!--- Header content --->
		<div class="windowTop" style="position: relative; top: 0; left: 0;" id="addEditCategoryHeader">
		<h2><cfif form.uploadid>Edit: #left(form.uploadtitle,40)#<cfif len(form.uploadtitle) gt 30> ...</cfif><cfelse>Add a file/image</cfif></h2>
		<a href="##" class="windowCloser" onclick="document.getElementById('addEditCategoryHolder').style.display='none';">
			<img src="#application.globalPath#/media/images/popupCloseBtn.gif" border=0>
		</a>
	</div><!--- End header content --->
	<!--- Begin file manipulation form layout --->
	
	<form style="padding:0;margin:0;" action="#request.page#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>&<cfif form.uploadid>edit<cfelse>add</cfif>FileSubmit=true" method="post"<cfif session.user.hasJavascript> onsubmit="submitFile();" target="target_upload"</cfif> enctype="multipart/form-data">
	<!--- action="#request.page#?<cfif form.uploadid>edit<cfelse>add</cfif>FileSubmit=true" --->
	<input type="Hidden" name="uploadid" value="#form.uploadid#">
	<input type="Hidden" name="filetype" value="#form.filetype#">
	<input type="Hidden" name="filesize" value="#form.filesize#">
	<table class="tooltable" cellpadding=3 cellspacing=1 width="100%">
		<tr>
			<td class="formitemlabelreq">Title: </td>
			<td class="formiteminput">
			<input type="text" id="uploadtitle" name="uploadtitle" value="#form.uploadtitle#" style="overflow:hidden;white-space:normal;width:250px" onkeyup="myRefresh()"></td>
		</tr>
		<tr>
			<td class="formitemlabelreq" valign="top">Description: </td>
			<td class="formiteminput"><textarea name="uploaddescription" style="height:100px;width:250px">#form.uploaddescription#</textarea></td>
		</tr>
		<tr>
			<td class="formitemlabelreq">Folder: </td>
			<td class="formiteminput">
			<select name="uploadcategoryid" size="1" id="catForm_parentid">
				<option value="">Choose a category for this file</option>

				<cfinvoke component="#application.cfcpath#.util.categoryindent" method="doIndent">
					<cfinvokeargument name="ID" value=0>
					<cfinvokeargument name="idColumn" value="uploadcategoryid">
					<cfinvokeargument name="displayColumn" value="uploadcategorytitle">
					<cfinvokeargument name="parentIdColumn" value="parentid">
					<cfinvokeargument name="tableName" value="uploadcategory">
					<cfinvokeargument name="dbName" value="#application.datasource#">
					<cfinvokeargument name="orderByColumn" value="uploadcategorytitle">
					<cfinvokeargument name="pickLevel" value="current">
					<cfinvokeargument name="nameLengthLimit" value="35">
				</cfinvoke>
					
			</select>
			</td>
		</tr>
		<tr>
			<td class="formitemlabelreq"><cfif form.uploadid>Replace with </cfif>File: </td>
			<td class="formiteminput"><input type="file" name="filename" size="26" onchange="checkFileType(this);"></td>
		</tr>
		<tr>
			<cfset thumbName="#application.installpath#\uploads\#fmObj.getCategoriesData(uploadcategoryid=form.uploadcategoryid).foldername#\#form.uploadid#_thumb.#form.filetype#">
			<cfif fileExists("#thumbName#")><cfset setSize="selected"><cfelse><cfset setSize=""></cfif>
			<cfoutput><script>//alert('#form.filetype#');</script></cfoutput>
			
			<td class="formitemlabelreq">Create Image Thumbnail: </td>
			<td class="formiteminput">
			  <input name="scaleToSize" type="checkbox" value="1" <cfif NOT ListFindNoCase("jpg,bmp,png,tiff", form.filetype, ",") AND len(form.filetype)>disabled="true"</cfif>/>
			  <cfif len(setSize)><span style="font-size:9px; font-weight:bold; color:##cc0000">&nbsp;Thumb Exists - set size!</span></cfif>
			</td>
			</tr>
		<tr>
		<tr>
			<td class="formitemlabelreq">Resize On: </td>
			<td class="formiteminput">
			  <input type="radio" name="resizeOnValue" value="1"<cfif form.active> checked</cfif>>Width <input type="radio" name="resizeOnValue" value="0"<cfif NOT form.active> checked</cfif>>Height
			</td>
			</tr>
		<tr>		<tr>
			<td class="formitemlabelreq">Resize to Pixels: </td>
			<td class="formiteminput">
			  <input name="imageThumbSize" type="text" value="0" size="5" <cfif NOT ListFindNoCase("jpg,bmp,png,tiff", form.filetype, ",") AND len(form.filetype)>disabled="true"</cfif>/>
			</td>
			</tr>
		<tr>
			<td class="formitemlabelreq">Active: </td>
			<td class="formiteminput"><input type="radio" name="active" value="1"<cfif form.active> checked</cfif>>Yes <input type="radio" name="active" value="0"<cfif NOT form.active> checked</cfif>>No</td>
		</tr>
		<tr>
			<td class="formiteminput" colspan="2" align="center"><cfif application.getPermissions("addedit",session.i3currenttool)><input type="submit" name="Submit" value="<cfif form.uploadid>Update File<cfelse>Add File</cfif>" class="submitbutton"></cfif></td>
		</tr>
	</table></form></cfoutput></cfsavecontent>
	<cfreturn outputHTML>
</cffunction>


<!--- add/edit a category --->
<cffunction name="addEditCategory" returntype="string">
	<cfargument name="uploadcategoryid" required="yes">
	<cfset var categoryList = fmObj.getCategoriesData()>
	<cfset var thisCategory = fmObj.getCategoriesData(uploadcategoryid=arguments.uploadcategoryid)>
	<cfset var outputHTML=''>
	<!--- Existing data if 'edit' --->
	<cfif thisCategory.recordCount>
		<cfset form.uploadcategorytitle=thisCategory.uploadcategorytitle>
		<cfset form.uploadcategorydescription=thisCategory.uploadcategorydescription>
		<cfset form.foldername=listLast(thisCategory.foldername,'_')>
		<cfset form.parentid=thisCategory.parentid>
		<cfset form.uploadcategoryid=thisCategory.uploadcategoryid>
	</cfif>
	<!--- Default data if 'add' --->
	<cfparam name="form.uploadcategorytitle" default="">
	<cfparam name="form.uploadcategorydescription" default="">
	<cfparam name="form.foldername" default="">
	<cfparam name="form.parentid" default=0>
	<cfparam name="form.uploadcategoryid" default="#trim(session.user.filemanager_listuploadcategory)#">
	<cfsavecontent variable="outputHTML"><cfoutput><div class="windowTop" style="position: relative; top: 0; left: 0;" id="addEditCategoryHeader">
			<h2><cfif arguments.uploadcategoryid>Edit #form.uploadcategorytitle#<cfelse>Create a folder</cfif></h2>
			<a href="##<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform</cfif>" class="windowCloser" onclick="document.getElementById('addEditCategoryHolder').style.display='none';"><img src="#application.globalPath#/media/images/popupCloseBtn.gif" border=0></a>
		</div>
		<form action="#request.page#?fileform=fileform<cfif arguments.uploadcategoryid>&edit<cfelse>&add</cfif>CategorySubmit=true"<cfif session.user.hasJavascript> onsubmit="submit<cfif arguments.uploadcategoryid>Update<cfelse>Add</cfif>Category(); return false;"</cfif> method="post" style="padding:0;margin:0;">
		<input type="hidden" id="catForm_uploadcategoryid" name="uploadcategoryid" value="
		<cfif arguments.uploadcategoryid>#arguments.uploadcategoryid#
		<cfelse>0
		</cfif>">
		<table class="tooltable" cellpadding=3 cellspacing=1 width="100%">
		<tr>
			<td class="formitemlabelreq">Title: </td>
			<td class="formiteminput"><input id="catForm_uploadcategorytitle" name="uploadcategorytitle" value="#form.uploadcategorytitle#" maxlength="255" type="text" style="width:250px;"></td>
		</tr>
		<tr>
			<td class="formitemlabelreq" valign="top">Description: </td>
			<td class="formiteminput"><textarea style="width:250px;height:100px" id="catForm_uploadcategorydescription" name="uploadcategorydescription"><cfif len(form.uploadcategorydescription)>#form.uploadcategorydescription#<cfelse>&nbsp;</cfif></textarea></td>
		</tr>
		<tr>
			<td class="formitemlabelreq">Folder Name: </td>
			<td class="formiteminput"><input name="foldername" id="catForm_foldername" value="#form.foldername#"  style="width:250px;" maxlength="255" type="text"></td>
		</tr>
		<tr>
			<td class="formitemlabelreq">Parent Folder: </td>
			<td class="formiteminput">
			<select name="parentid" size="1" id="catForm_parentid">
				<option value="">Choose a Parent for this Folder </option>

				<cfif arguments.uploadcategoryid>
					<cfset setLevel="parent">
				<cfelse>
					<cfset setLevel="current">
				</cfif>
				
				<cfinvoke component="#application.cfcpath#.util.categoryindent" method="doIndent">
					<cfinvokeargument name="ID" value=0>
					<cfinvokeargument name="idColumn" value="uploadcategoryid">
					<cfinvokeargument name="displayColumn" value="uploadcategorytitle">
					<cfinvokeargument name="parentIdColumn" value="parentid">
					<cfinvokeargument name="tableName" value="uploadcategory">
					<cfinvokeargument name="dbName" value="#application.datasource#">
					<cfinvokeargument name="orderByColumn" value="uploadcategorytitle">
					<cfinvokeargument name="pickLevel" value="#setLevel#">
				</cfinvoke>

			</select>
			</td>
		</tr>
		<tr>
			<td class="formiteminput" colspan="2" align="center"><input name="Submit" value="<cfif arguments.uploadcategoryid>Save Changes<cfelse>Create Folder</cfif>" class="submitbutton" type="submit"></td>
		</tr>
		</table></form></cfoutput></cfsavecontent>
	<cfreturn outputHTML>
</cffunction>
<!--- update a category in the db --->
<cffunction name="updateCategory" returntype="string">
	<cfargument name="uploadcategorytitle" type="string" required="yes" displayname="uploadcategorytitle">
	<cfargument name="uploadcategorydescription" type="string" required="yes" displayname="uploadcategorydescription">
	<cfargument name="parentid" required="yes" displayname="parentid">
	<cfargument name="foldername" type="string" required="yes" displayname="foldername">
	<cfargument name="uploadcategoryid" type="numeric" required="yes" displayname="uploadcategoryid">
	<cfset arguments.parentid = listFirst(arguments.parentid,'|')>
	<cfset arguments.foldername = "#trim(arguments.uploadcategoryid)#_#trim(arguments.foldername)#">
	<cfset fmObj.updatecategoryQuery(uploadcategorytitle=arguments.uploadcategorytitle, uploadcategorydescription=arguments.uploadcategorydescription, parentid=arguments.parentid, foldername=arguments.foldername, uploadcategoryid=arguments.uploadcategoryid)>
</cffunction>
<!--- add a category in the db --->
<cffunction name="addCategory" returntype="string">
	<cfargument name="uploadcategorytitle" type="string" required="yes" displayname="uploadcategorytitle">
	<cfargument name="uploadcategorydescription" type="string" required="yes" displayname="uploadcategorydescription">
	<cfargument name="parentid" required="yes" displayname="parentid">
	<cfargument name="foldername" type="string" required="yes" displayname="foldername">
	<cfset arguments.parentid = listFirst(arguments.parentid,'|')>
	<cfset newCatId = fmObj.addNewCategory(uploadcategorytitle=arguments.uploadcategorytitle, uploadcategorydescription=arguments.uploadcategorydescription, parentid=arguments.parentid, foldername=arguments.foldername)>
	<cfreturn newCatId>
</cffunction>
<!--- header for a category --->
<cffunction name="buildHeader" returntype="string">
	<cfargument name="uploadcategoryid" required="yes">
	<cfset var currentDir=fmObj.getCategoriesData(uploadcategoryid=arguments.uploadcategoryid)>
	<cfset var outputHTML=''>
	<cfset var disabled=0>
	<!--- disable delete and edit for root and recycle --->
	<cfif arguments.uploadcategoryid EQ 99999 OR arguments.uploadcategoryid EQ 100000>
		<cfset disabled=1>
	</cfif>
	<cfsavecontent variable="outputHTML"><cfoutput>
		<div id="socketformheader"><h2>File Manager: #currentDir.uploadcategorytitle#</h2></div>
		<div id="buttonSearchWrapper">
			<div id="buttonbar">
			<cfif NOT isDefined('session.user.filemanager_liststyle') OR session.user.filemanager_liststyle EQ 'thumbnails'>
				<a href="<cfoutput>#request.page#</cfoutput><cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>liststyle=details"><img src="#application.globalPath#/media/images/icon_list.gif" border="0" id="catDetailViewButton" alt="View Details" title="View Details"></a>
			<cfelse>
				<a href="<cfoutput>#request.page#</cfoutput><cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>liststyle=thumbnails"><img src="#application.globalPath#/media/images/icon_thumbnails.gif" border="0" id="catThumbViewButton" alt="View Thumbnails" title="View Thumbnails"></a>
			</cfif>
			<a href="<cfoutput>#request.page#</cfoutput><cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>addCategory=true"><img src="#application.globalPath#/media/images/icon_addFolder.gif" border="0" id="addFolderButton" alt="Add a Folder" title="Add a Folder"></a>
			<a href="<cfoutput>#request.page#</cfoutput><cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>addFile=true"><img src="#application.globalPath#/media/images/icon_addFile.gif" border="0" id="addFileButton" alt="Add a File" title="Add a File"></a>
			<a href="<cfoutput>#request.page#</cfoutput><cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>addFile=true&isImg=true"><img src="#application.globalPath#/media/images/icon_addImage.gif" border="0" id="addImgButton" alt="Add an Image" title="Add an Image"></a>
			<cfif NOT disabled><a href="<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>deleteuploadcategoryconfirm=#arguments.uploadcategoryid#"></cfif><img src="#application.globalPath#/media/images/icon_deleteFolder.gif" border="0" id="catDeleteButton" alt="Delete #currentDir.uploadcategorytitle#" title="Delete #currentDir.uploadcategorytitle#"<cfif disabled> class="disabled"</cfif>><cfif NOT disabled></a></cfif>
			<cfif NOT disabled><a href="<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>editCategory=#arguments.uploadcategoryid#"></cfif><img src="#application.globalPath#/media/images/icon_editFolder.gif" border="0" id="catEditButton" alt="Edit #currentDir.uploadcategorytitle#" title="Edit #currentDir.uploadcategorytitle#"<cfif disabled> class="disabled"</cfif>><cfif NOT disabled></a></cfif>
			<cfif session.user.useordinal><cfif NOT disabled><a href="<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>ordinalCategory=#arguments.uploadcategoryid#"></cfif><img src="#application.globalPath#/media/images/icon_ordinal.gif" border="0" id="catOrdinalButton" alt="Order #currentDir.uploadcategorytitle#" title="Order #currentDir.uploadcategorytitle#"<cfif disabled> class="disabled"</cfif>><cfif NOT disabled></a></cfif></cfif>
			</div>
			<div id="searchHeader" class="headerBar">#buildSearch(trim(session.user.filemanager_listuploadcategory))#</div>
		</div>
	</cfoutput></cfsavecontent>
	<cfreturn outputHTML>
</cffunction>
<!--- search for a category --->
<cffunction name="buildSearch" returntype="string">
	<cfargument name="uploadcategoryid" required="yes">
	<cfset var outputHTML=''>
	<cfsavecontent variable="outputHTML"><cfoutput>
	<!--- js to hide form elements when hover over admin nav --->
	<!--- moved to adminskin.cfm 
		<script type="text/javascript">
			function hideSearchForm(){
				if(document.getElementById('adminnavlist') && document.getElementById('searchWrapper')){
					document.getElementById('adminnavlist').onmouseover = function(){
						document.getElementById('searchWrapper').style.display = "none";
					}
					document.getElementById('adminnavlist').onmouseout = function(){
						document.getElementById('searchWrapper').style.display = "block";
					}
				}
			}
			womAdd('hideSearchForm()');
			//womOn(); moved to CustTags/adminskin.cfm
		</script>--->
		<div id="searchWrapper">
			<div id="searchFields">
			<input type="radio" value="#arguments.uploadcategoryid#" id="searchScopeCurrent" name="searchScope" checked> Current Folder
			<input type="radio" value="0" id="searchScopeAll" name="searchScope"> All
			<input type="text" id="searchField" name="searchField" size="30">
			<input type="image" src="#application.globalPath#/media/images/icon_search.gif" border="0" style="vertical-align: top;" id="searchGoButton" name="searchGoButton"></div>
		</div>
	</cfoutput></cfsavecontent>
	<cfreturn outputHTML>
</cffunction>

<!--- list the files in a category --->
<cffunction name="buildFileList" returntype="string">
	<cfargument name="uploadcategoryid" required="yes">
	<cfargument name="fileNameSearch" type="string" required="yes" displayname="File Name Search" default="">
	<cfargument name="sortby" required="no" default="#session.user.filemanager_filesort#">
	<cfset var currentFiles=''>
	<cfset var outputHTML=''>
	<cfsilent><!--- sometimes search var gets confused with sort var, fix it --->
	<cfif find(',DESC',arguments.fileNameSearch) OR find(',ASC',arguments.fileNameSearch)>
		<cfset arguments.fileNameSearch = ''>
	</cfif>
	<cfset currentFiles=fmObj.getFilesForCategory(categoryID=val(trim(arguments.uploadcategoryid)),sortby=arguments.sortby,fileNameSearch=arguments.fileNameSearch)>
	<!--- keep session var updated --->
	<cfif session.user.filemanager_filesort NEQ arguments.sortby>
		<cfset session.user.filemanager_filesort = arguments.sortby>
	</cfif>
	<cfif currentFiles.recordCount>
		<!--- start paging code --->
		<cfif session.user.filecount NEQ currentFiles.recordCount>
			<cfset session.user.recordstartindex = 1>
			<cfset session.user.recordendindex = 20>
		</cfif>
		<cfif currentFiles.recordCount GT session.user.paginglimit>
			<cfset session.user.usePaging = true>
		<cfelse>
			<cfset session.user.usePaging = false>
			<cfset session.user.recordstartindex = 1>
			<cfset session.user.recordendindex = currentFiles.recordCount>
		</cfif>
		<cfset session.user.filecount = currentFiles.recordCount>
		<!--- end paging code --->
		<cfsavecontent variable="outputHTML"><cfoutput>
		<table cellpadding="3" cellspacing="1" border="0" class="tooltable">
		<!--- start paging code --->
			<tr>
		<cfif session.user.usePaging EQ true>
				<td id="previous20list" align="left"><cfif session.user.recordstartindex GT maxrecordcount><a href="<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>#request.page#i3CurrentTool=<cfif isDefined('URL.i3currenttool')>#URL.i3currenttool#<cfelse>#SESSION.i3currenttool#</cfif>&changeindex=-#maxrecordcount#<cfif isDefined('URL.formaction')>&formaction=#URL.formaction#</cfif><cfif isDefined('uploadcategoryid')>&thiscategoryid=#uploadcategoryid#</cfif><cfif isDefined('uploadcategoryid')>&listuploadcategory=#uploadcategoryid#</cfif><cfif isDefined('URL.callingfield')>&callingfield=#URL.callingfield#</cfif><cfif isDefined('URL.formname')>&formname=#URL.formname#</cfif><cfif isDefined('URL.newfile')>&newfile=#URL.newfile#</cfif>">&lt;&lt; Previous #maxrecordcount#</a></cfif></td><td colspan="2" align="center">#currentFiles.recordCount# file(s) (showing #session.user.recordstartindex# through #session.user.recordendindex#)</td><td id="next20list" align="right"><cfif session.user.recordendindex LT session.user.filecount><a href="#request.page#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>i3CurrentTool=<cfif isDefined('URL.i3currenttool')>#URL.i3currenttool#<cfelse>#SESSION.i3currenttool#</cfif>&changeindex=#maxrecordcount#<cfif isDefined('URL.formaction')>&formaction=#URL.formaction#</cfif><cfif isDefined('uploadcategoryid')>&thiscategoryid=#uploadcategoryid#</cfif><cfif isDefined('uploadcategoryid')>&listuploadcategory=#uploadcategoryid#</cfif><cfif isDefined('URL.callingfield')>&callingfield=#URL.callingfield#</cfif><cfif isDefined('URL.formname')>&formname=#URL.formname#</cfif><cfif isDefined('URL.newfile')>&newfile=#URL.newfile#</cfif>">Next #maxrecordcount# &gt;&gt;</a></cfif></td>
		<cfelse>
				<td colspan="4" align="center">#currentFiles.recordCount# file(s) (showing #session.user.recordstartindex# through #session.user.recordendindex#)</td>
		</cfif>
			</tr>
		<!--- end paging code --->
			<tr>
				<th>&nbsp;</th>
				<th><a href="<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>listuploadcategory=#trim(arguments.uploadcategoryid)#&amp;searchstring=#arguments.fileNameSearch#&amp;filesort=<cfif session.user.filemanager_filesort EQ 'uploadtitle,ASC'>uploadtitle,DESC<cfelse>uploadtitle,ASC</cfif>">Name</a></th>
				<th><a href="<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>listuploadcategory=#trim(arguments.uploadcategoryid)#&amp;searchstring=#arguments.fileNameSearch#&amp;filesort=<cfif session.user.filemanager_filesort EQ 'filetype,ASC'>filetype,DESC<cfelse>filetype,ASC</cfif>">Type</a></th>
				<th><a href="<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>listuploadcategory=#trim(arguments.uploadcategoryid)#&amp;searchstring=#arguments.fileNameSearch#&amp;filesort=<cfif session.user.filemanager_filesort EQ 'datemodified,ASC'>datemodified,DESC<cfelse>datemodified,ASC</cfif>">Date</a></th>
			</tr>
			<!--- pagingcode --->
			<cfloop query="currentFiles" startrow="#session.user.recordstartindex#" endrow="#session.user.recordendindex#">
			<cfset currentFiles.filepath = "#ReplaceNoCase(currentFiles.filepath,"//","/")#">
			<cfif currentFiles.currentRow MOD 2>
				<cfset rowClass = "evenrow">
			<cfelse>
				<cfset rowClass = "oddrow">
			</cfif>
			<tr id="fileupload_#currentFiles.uploadid#" class="#rowClass#">
				<td nowrap width="120" align="center">
					<a href="##"><img src="#application.globalPath#/media/images/icon_selectTarget.gif" border="0" title="Select File" style='display: none;'></a>
					<a href="<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>editFile=#currentFiles.uploadid#"><img src="#application.globalPath#/media/images/icon_editFile.gif" border="0" title="Edit File"></a> 
					<cfif NOT isDefined('session.user.filemanager_liststyle') OR session.user.filemanager_liststyle EQ 'details'>
						<a href="#currentFiles.filepath#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform</cfif>" target="_blank" class="previewLink"><img src="#application.globalPath#/media/images/icon_previewFile.gif" border="0" title="Preview File"></a>
					</cfif>
					<a href="<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>viewLink=#currentFiles.filepath#&savename=#currentFiles.uploadtitle#"><img src="#application.globalPath#/media/images/icon_link.gif" border="0" title="View Link to file::#currentFiles.uploadtitle#" name="#currentFiles.filepath#"></a>
					<cfif currentFiles.filetype EQ "jpg" OR currentFiles.filetype EQ "png" OR currentFiles.filetype EQ "gif" OR currentFiles.filetype EQ "bmp">
						<cfset SESSION.picnikFilePath= currentFiles.filepath>
						<a href="javascript:openPicnik('http://www.picnik.com/service?_apikey=9c1abffa535979a8f662de70d87c3637&_import=#APPLICATION.INSTALLURL##currentFiles.filepath#&_export=#APPLICATION.INSTALLURL#/admintools/tasks/picnik.cfm&_export_agent=browser&_export_method=GET&_export_title=Save to boomsocket','#currentFiles.filepath#');"><img src="#application.globalPath#/media/images/icon_picnik.gif" border="0" title="Edit This Image in Picnik"></a>
					</cfif>
					<a href="<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>deleteuploadconfirm=#currentFiles.uploadid#"><img src="#application.globalPath#/media/images/icon_deleteFile.gif" border="0" title="Delete File"></a>
				</td>
				<td class="uploadtitle" title="#currentFiles.uploadtitle#">
					<cfif isDefined('session.user.filemanager_liststyle') AND session.user.filemanager_liststyle EQ 'thumbnails'>
						<cfif currentFiles.filetype EQ 'jpg' OR currentFiles.filetype EQ 'gif'>
							<a href="#currentFiles.filepath#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform</cfif>" target="_blank" class="previewLink"><img src="#currentFiles.filepath#" border="0" height="50" width="75" style="float:left"></a>
						<cfelse>
							<div style="border-width: 1px; border-style: solid; border-color: 000000; width: 75px; height: 50px; text-align: center;"><a href="#currentFiles.filepath#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform</cfif>" target="_blank" class="previewLink">#currentFiles.filetype#</a></div>
						</cfif>
					</cfif>
					#left(currentFiles.uploadtitle,70)#<cfif len(currentFiles.uploadtitle) gt 70> ...</cfif></td>
				<td>#currentFiles.filetype#</td>
				<td>#dateFormat(currentFiles.datemodified,'mm/dd/yyyy')#</td>
			</tr>
			</cfloop>
			<!--- start paging code --->
			<tr>
		<cfif session.user.usePaging EQ true>
				<td id="previous20list" align="left"><cfif session.user.recordstartindex GT maxrecordcount><a href="#request.page#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>i3CurrentTool=<cfif isDefined('URL.i3currenttool')>#URL.i3currenttool#<cfelse>#SESSION.i3currenttool#</cfif>&changeindex=-#maxrecordcount#<cfif isDefined('URL.formaction')>&formaction=#URL.formaction#</cfif><cfif isDefined('uploadcategoryid')>&thiscategoryid=#uploadcategoryid#</cfif><cfif isDefined('uploadcategoryid')>&listuploadcategory=#uploadcategoryid#</cfif><cfif isDefined('URL.callingfield')>&callingfield=#URL.callingfield#</cfif><cfif isDefined('URL.formname')>&formname=#URL.formname#</cfif><cfif isDefined('URL.newfile')>&newfile=#URL.newfile#</cfif>">&lt;&lt; Previous #maxrecordcount#</a></cfif></td><td colspan="2" align="center"></td><td id="next20list"><cfif session.user.recordendindex LT session.user.filecount><a href="#request.page#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>i3CurrentTool=<cfif isDefined('URL.i3currenttool')>#URL.i3currenttool#<cfelse>#SESSION.i3currenttool#</cfif>&changeindex=#maxrecordcount#<cfif isDefined('URL.formaction')>&formaction=#URL.formaction#</cfif><cfif isDefined('uploadcategoryid')>&thiscategoryid=#uploadcategoryid#</cfif><cfif isDefined('uploadcategoryid')>&listuploadcategory=#uploadcategoryid#</cfif><cfif isDefined('URL.callingfield')>&callingfield=#URL.callingfield#</cfif><cfif isDefined('URL.formname')>&formname=#URL.formname#</cfif><cfif isDefined('URL.newfile')>&newfile=#URL.newfile#</cfif>">Next #maxrecordcount# &gt;&gt;</a></cfif></td>
		<cfelse>
				<td colspan="4" align="center"></td>
		</cfif>
			</tr>
			<!--- end paging code --->
		</table>
		</cfoutput></cfsavecontent>
	<cfelse>
		<cfset currentDir=fmObj.getCategoriesData(uploadcategoryid=arguments.uploadcategoryid)>
		<cfset outputHTML='search of #currentDir.uploadcategorytitle# returned no files'>
		<cfset session.user.recordstartindex = 1>
		<cfset session.user.recordendindex = 20>
	</cfif></cfsilent>
	<cfreturn outputHTML>
</cffunction>
<!--- create preview for file --->
<cffunction name="buildFilePreview" returntype="string">
	<cfargument name="uploadid" required="yes">
	<cfset var currentFile=fmObj.getFileData(uploadid=arguments.uploadid)>
	<cfset var outputHTML=''>
	<cfif currentFile.recordcount>
	<cfsavecontent variable="outputHTML"><cfoutput>
		<div class="windowTop">
			<h2>File Details</h2>
			<a href="##" class="windowCloser" onclick="document.getElementById('addEditCategoryHolder').style.display='none';"><img src="#application.globalPath#/media/images/popupCloseBtn.gif" border=0></a>
		</div>
		<cfif currentFile.filetype EQ 'jpg' OR currentFile.filetype EQ 'gif'><img src="#ReplaceNoCase(currentFile.filepath,'//','/')#" width="380" alt="#currentFile.uploadtitle#"><br></cfif>
		Size: #currentFile.filesize#<br>
		Date Uploaded: #dateFormat(currentFile.datemodified,'mm/dd/yyyy')#<br>
		Type: #currentFile.filetype#
		<div>#currentFile.uploaddescription#</div>
	</cfoutput></cfsavecontent>
	</cfif>
	<cfreturn outputHTML>
</cffunction>
<cfscript>
// list a category, its siblings, and its parents
function buildCategoryList(currentuploadcategoryid,prevuploadcategoryid,builtdata){
	var tempChildList='';
	var innerTempChildList='';
	var children=fmObj.getCategoriesData(parentid=trim(arguments.currentuploadcategoryid));
	//changing to a new category, set session var
	if(arguments.builtdata EQ 'start'){
		session.user.filemanager_listuploadcategory = trim(arguments.currentuploadcategoryid);
	}
	if(children.recordcount){
		tempChildList='#tempChildList#<ul>';
		for(i=1;i LTE children.recordCount;i=i+1){
			if(children.uploadcategoryid[i] EQ session.user.filemanager_listuploadcategory){
				tempChildList='#tempChildList#<li class="current"><a href="?';
				if(isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'){
					tempChildList=tempChildList&'fileform=fileform&listuploadcategory=#children.uploadcategoryid[i]#">#children.uploadcategorytitle[i]#</a></li>#arguments.builtdata#';
				}else{
				tempChildList=tempChildList&'listuploadcategory=#children.uploadcategoryid[i]#">#children.uploadcategorytitle[i]#</a></li>#arguments.builtdata#';
				}
			}else if(children.uploadcategoryid[i] EQ arguments.prevuploadcategoryid){
				tempChildList='#tempChildList#<li class="parent"><a href="?';
				if(isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'){
					tempChildList=tempChildList&'fileform=fileform&listuploadcategory=#children.uploadcategoryid[i]#">#children.uploadcategorytitle[i]#</a></li>#arguments.builtdata#';
				}else{
				tempChildList=tempChildList&'listuploadcategory=#children.uploadcategoryid[i]#">#children.uploadcategorytitle[i]#</a></li>#arguments.builtdata#';
				}
			}else{
				tempChildList='#tempChildList#<li><a href="?';
				if(isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'){
					tempChildList=tempChildList&'fileform=fileform&listuploadcategory=#children.uploadcategoryid[i]#">#children.uploadcategorytitle[i]#</a></li>';
				}else{
				tempChildList=tempChildList&'listuploadcategory=#children.uploadcategoryid[i]#">#children.uploadcategorytitle[i]#</a></li>';
				}
			}
		}
		tempChildList='#tempChildList#</ul>';
	}
	thisCategoryData=fmObj.getCategoriesData(uploadcategoryid=arguments.currentuploadcategoryid);
	if(thisCategoryData.recordCount AND thisCategoryData.parentid NEQ 0){
		tempChildList='#buildCategoryList(thisCategoryData.parentid,arguments.currentuploadcategoryid,tempChildList)#';
	}else{
		if(arguments.currentuploadcategoryid EQ 99999 AND session.user.filemanager_listuploadcategory EQ 99999){
			innerTempChildList = tempChildList;
			tempChildList='<ul><li class="current"><a href="?';
			if(isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'){
				tempChildList=tempChildList&'fileform=fileform&listuploadcategory=99999">Recycle Bin</a></li>#innerTempChildList#<li><a href="?fileform=fileform&listuploadcategory=100000">Root Directory</a></li></ul>';
			}else{
				tempChildList=tempChildList&'listuploadcategory=99999">Recycle Bin</a></li>#innerTempChildList#<li><a href="?listuploadcategory=100000">Root Directory</a></li></ul>';
			}
		}else if(arguments.currentuploadcategoryid EQ 99999){
			innerTempChildList = tempChildList;
			tempChildList='<ul><li class="parent"><a href="?';
			if(isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'){
				tempChildList=tempChildList&'fileform=fileform&listuploadcategory=99999">Recycle Bin</a></li>#innerTempChildList#<li><a href="?fileform=fileform&listuploadcategory=100000">Root Directory</a></li></ul>';
			}else{
				tempChildList=tempChildList&'listuploadcategory=99999">Recycle Bin</a></li>#innerTempChildList#<li><a href="?listuploadcategory=100000">Root Directory</a></li></ul>';
			}
		}else if(session.user.filemanager_listuploadcategory EQ 100000){
			innerTempChildList = tempChildList;
			tempChildList='<ul><li><a href="?';
			if(isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'){
				tempChildList=tempChildList&'fileform=fileform&listuploadcategory=99999">Recycle Bin</a></li><li class="current"><a href="?fileform=fileform&listuploadcategory=100000">Root Directory</a></li>#innerTempChildList#</ul>';
			}else{
				tempChildList=tempChildList&'listuploadcategory=99999">Recycle Bin</a></li><li class="current"><a href="?listuploadcategory=100000">Root Directory</a></li>#innerTempChildList#</ul>';
			}
		}else{
			innerTempChildList = tempChildList;
			tempChildList='<ul><li><a href="?';
			if(isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'){
				tempChildList=tempChildList&'fileform=fileform&listuploadcategory=99999">Recycle Bin</a></li><li class="parent"><a href="?fileform=fileform&listuploadcategory=100000">Root Directory</a></li>#innerTempChildList#</ul>';
			}else{
				tempChildList=tempChildList&'listuploadcategory=99999">Recycle Bin</a></li><li class="parent"><a href="?listuploadcategory=100000">Root Directory</a></li>#innerTempChildList#</ul>';
			}
		}
	}
	return tempChildList;
}
// move a file from one category to another
function moveFile(uploadid, newDirID){
	fmObj.moveFile(arguments.uploadID, arguments.newDirID);

}
// delete a file
function deleteFile(uploadid){
//	fmObj.deleteFileSystem(arguments.uploadid);
	fmObj.deleteFileQuery(arguments.uploadid);
	return session.user.filemanager_listuploadcategory;
}
// delete a category
function deleteCategory(uploadid){
	fmObj.deleteCategory(arguments.uploadid);
	session.user.filemanager_listuploadcategory = 100000;
	return true;
}
//update the hasJavascript session variable (for call from AJAX)
function updateSessionHasJavascript(val){
	session.user.hasJavascript=arguments.val;
	return true;
}
//update the filemanager_liststyle session variable (for call from AJAX)
function updateSessionListStyle(val){
	session.user.filemanager_liststyle=arguments.val;
	return trim(session.user.filemanager_listuploadcategory);
}
</cfscript>
<cffunction name="buildOrdinalList" returntype="string">
	<cfargument name="uploadcategoryid" type="numeric" required="yes">
	<cfif NOT isDefined('fmObj')>
		<cfset fmObj=CreateObject('component', '#APPLICATION.cfcpath#.filemanagerv2')>
	</cfif>
	<cfset q_getElements = fmObj.getFilesForCategory(categoryID=uploadcategoryid,sortby="ordinal,ASC")>
	<cfif q_getElements.recordcount GT 25>
		<cfset selectSize=25>
	<cfelse>
		<cfset selectSize=q_getElements.recordcount>
	</cfif>
	<cfsavecontent variable="ordinalForm">
		<cfoutput>
			<form name="orderRows" action="#request.page#?fileform=fileform" method="post"  onsubmit="SetFields(document.orderRows.sort);">
			<input type="hidden" name="ordinalCategory" value="#uploadcategoryid#">
			<input type="hidden" name="formstep" value="ordinalPost">
			<input type="hidden" name="FieldsSave">
				<table cellpadding="3" cellspacing="1" border="0" width="450" class="toolTable">
				<tr>
					<td valign="top" colspan="2" class="toolheader">Order Elements</td>
				<tr>
					<td valign="top" colspan="2" class="formitemlabelreq">Use the directional buttons below to modify the display order of the records in this table.</td>
				</tr>
				<tr valign="top">
					<td class="formitemlabel" align="center">
						<select name="sort" size="#selectSize#" multiple style="background: ##B0C4DE; font-size: 14px; font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; border: 1px solid ##000000;">
							<cfloop query="q_getElements">
								<!--- Added check for active so we can tell people which ordinal items aren't active. --->
								<option value="#q_getElements.uploadid#">#q_getElements.uploadtitle#</option>
							</cfloop>
						</select>
					</td>
					<td class="formitemlabel">
					<input type="button" name="up" class="submitbutton" value="up" style="width: 60;" onclick="javascript:Field_up(document.orderRows.sort)">
					<p>
					<input type="button" name="down" class="submitbutton" value="down" style="width: 60;" onclick="javascript:Field_down(document.orderRows.sort)">
					<p>
					<input type="button" name="mode" value="Update Order" class="submitbutton"  style="width: 120;" onclick="javascript:SetFields(document.orderRows.sort,#uploadcategoryid#)"></td>
				</tr>
				</table>
			</form>
		</cfoutput>
	</cfsavecontent>
	<cfreturn ordinalForm>
</cffunction>
<cffunction name="postOrdinal" output="false" returntype="numeric">
	<cfargument name="fieldList" type="string">
	<cfargument name="uploadcategoryid" type="numeric" required="yes">
	<cfset position=1>
	<cfif NOT isDefined('formProcessObj')>
		<cfset formProcessObj=CreateObject('component', '#APPLICATION.cfcpath#.formprocess')>
	</cfif>
	<cfloop list="#fieldList#" index="x">
		<cfset q_updateElements = formProcessObj.updateOrdinal(datatable="upload",datatableid=x,position=position)>
		<cfset position=position+1>
	</cfloop>
	<cfset msg=URLEncodedFormat("You have successfully updated the order of the elements in this content object.")>
	<cfreturn uploadcategoryid>
</cffunction>