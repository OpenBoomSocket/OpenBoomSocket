<cfsilent> <!--- suppress output --->
	<!--- set default session variables --->
	<cfparam name="session.user.filemanager_listuploadcategory" default="100000">
	<cfparam name="session.user.filemanager_filesort" default="uploadtitle,ASC">
	<cfparam name="session.user.filemanager_liststyle" default="details">
	<cfparam name="session.user.hasJavascript" default="0">
	<!--- start paging code --->
	<cfparam name="session.user.usepaging" type="boolean" default="false">
	<cfparam name="maxrecordcount" type="numeric" default="20">
	<cfparam name="session.user.recordendindex" type="numeric" default="#maxrecordcount#">
	<cfparam name="session.user.recordstartindex" type="numeric" default="1">
	<cfparam name="session.user.filecount" type="numeric" default="0">
	<cfparam name="session.user.paginglimit" default="40" type="numeric">
	<cfparam name="session.user.useordinal" default="false" type="boolean">
	<cfset session.user.paginglimit = 40>
	<!--- end paging code --->
	<cfif not IsDefined("session.user.filemanager_openuploadcategories")>
		<cfset session.user.filemanager_openuploadcategories="">
		<cfquery name="q_getAllCats" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT uploadcategoryid FROM uploadcategory
		</cfquery>
		<cfloop query="q_getAllCats">
			<cfset session.user.filemanager_openuploadcategories = listAppend(session.user.filemanager_openuploadcategories,"#q_getAllCats.uploadcategoryid# + ':'+ 0",",")>
		</cfloop>
	</cfif>

	<!--- create instance of file manager component --->
	<cfset fmObj=CreateObject('component', '#APPLICATION.cfcpath#.filemanagerv2')>
	<!--- check table struct for use of ordinal --->
	<cfset q_columnlist = fmObj.getColumnList()>
	<cfif listFindNoCase(q_columnlist.columnlist,"ordinal")>
		<cfset session.user.useordinal = true>
	</cfif>
	<!--- debug output messes up ajax, kill it --->
	<cfsetting showdebugoutput="no">
	<!--- sajax engine --->
	<cfinclude template="#application.globalPath#/includes/sajax/sajaxV1.cfm">
	<!--- primary functions (both CF and JS) code listing--->
	<cfinclude template="#application.globalPath#/fileManager/i_functions.cfm">
	<!--- Request JS wrapper functions from SAJAX for CF code: prepends 'x_' to function name--->
	<cfscript>
		sajax_init();
		//sajax_debug_mode = 1;
		// export cf functions for ajax calling
		sajax_export("addEditCategory");
		sajax_export("addCategory");
		sajax_export("updateCategory");
		sajax_export("deleteCategory");
		sajax_export("addEditFile");
		sajax_export("deleteFile");
		sajax_export("buildFileList");
		sajax_export("buildFilePreview");
		sajax_export("buildCategoryList");
		sajax_export("buildHeader");
		sajax_export("buildSearch");
		sajax_export("updateSessionHasJavascript");
		sajax_export("updateSessionListStyle");
		sajax_export("buildOrdinalList");
		sajax_export("postOrdinal");
		sajax_handle_client_request();
	</cfscript>
</cfsilent> <!--- end output suppression--->
	<!--- include Sajax JS code in document output --->
<cfset outputJS=''>
<cfsavecontent variable="outputJS">
<cfoutput>
	<script type="text/javascript">
		function openPicnik(url,filepath)
		{
			document.cookie='picnikFilePath='+filepath+';path=/';
			newwindow = window.open(url,'name','width=650,height=420,resizable=1');
		}
	</script>
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#outputJS#">

	<script type="text/javascript">
		<cfscript>sajax_show_javascript();</cfscript>
	</script>

<!--- Context driven actions for fm --->
<!--- setup for <a> link default for older browers. If available, onClick() defined in fmv2.js --->
<!---start paging code --->
<cfif isDefined('url.changeindex')>
	<cfset session.user.recordstartindex = (session.user.recordstartindex + url.changeindex)>
	<cfif ((session.user.recordendindex + url.changeindex) LTE session.user.filecount) AND (url.changeindex GT 0)>
		<cfset session.user.recordendindex = (session.user.recordstartindex + url.changeindex - 1)>
	<cfelseif ((session.user.recordendindex + url.changeindex) GT 0) AND (url.changeindex LT 0)>
		<cfset session.user.recordendindex = (session.user.recordstartindex - url.changeindex - 1)>
	<cfelse>
		<cfset session.user.recordendindex = session.user.filecount>
	</cfif>
</cfif>
<!--- end paging code --->
<cfif isDefined('url.deleteuploadconfirm')>
<!--- confirm a file delete --->
	<cfset thisFile=fmObj.getFileData(uploadid=url.deleteuploadconfirm)>
	<cfoutput>
		Are you sure you want to delete #thisFile.uploadtitle#?
		<a href="#request.page#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>deleteupload=#url.deleteuploadconfirm#">Yes</a> <a href="#request.page#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform</cfif>">No</a>
	</cfoutput>
<cfelseif isDefined('url.deleteupload')>
<!--- Delete a file --->
	<cfset deleteFile(url.deleteupload)>
	<cfif isDefined('REQUEST.admintemplate') AND (REQUEST.admintemplate EQ 'popup')>
		<cfset popupStr="?fileform=fileform">
	<cfelse>
		<cfset popupStr="">
	</cfif>
	<cflocation url="#request.page##popupStr#" addtoken="no"></cflocation>
<cfelseif isDefined('url.deleteuploadcategoryconfirm')>
<!--- confirm a category delete --->
	<cfset thisFolder=fmObj.getCategoriesData(uploadcategoryid=url.deleteuploadcategoryconfirm)>
	<cfoutput>
		Are you sure you want to delete #thisFolder.uploadcategorytitle#?
		<a href="#request.page#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>deleteuploadcategory=#url.deleteuploadcategoryconfirm#">Yes</a> <a href="#request.page#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform</cfif>">No</a>
	</cfoutput>
<cfelseif isDefined('url.deleteuploadcategory')>
<!--- Delete a category --->
	<cfset deleteCategory(url.deleteuploadcategory)>
	<cfif isDefined('REQUEST.admintemplate') AND (REQUEST.admintemplate EQ 'popup')>
		<cfset popupStr="?fileform=fileform">
	<cfelse>
		<cfset popupStr="">
	</cfif>
	<cflocation url="#request.page##popupStr#" addtoken="no"></cflocation>
<cfelseif isDefined('url.addCategory')>
<!--- Form to add a category --->
	<cfoutput>#addEditCategory(0)#</cfoutput>
<cfelseif isDefined('url.editCategory')>
<!--- Form to edit a category --->
	<cfoutput>#addEditCategory(url.editCategory)#</cfoutput>
<cfelseif isDefined('url.addCategorySubmit')>
<!--- submit a new category --->
<!--- need to add form checking --->
<!--- <cfdump var="#FORM#">
<cfabort> --->
	<cfif len(form.uploadcategorytitle) AND isNumeric(listfirst(form.parentid,'|')) AND len(form.foldername)>
	<cfset fmObj.addNewCategory(uploadcategorytitle=form.uploadcategorytitle, uploadcategorydescription=form.uploadcategorydescription, parentid=listfirst(form.parentid,'|'), foldername=form.foldername)>
		<cfif isDefined('REQUEST.admintemplate') AND (REQUEST.admintemplate EQ 'popup')>
			<cfset popupStr="?fileform=fileform">
		<cfelse>
			<cfset popupStr="">
		</cfif>
		<cflocation url="#request.page##popupStr#" addtoken="no"></cflocation>
	<cfelse>
		<cfoutput>Must define all form fields (description optional)
		<a href="#request.page#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>addCategory=true">[Back]</a></cfoutput>
	</cfif>
<cfelseif isDefined('url.editCategorySubmit')>
<!--- edit a category --->
	<cfif len(form.uploadcategorytitle) AND isNumeric(listfirst(form.parentid,'|')) AND len(form.foldername)>
	<cfset updateCategory(uploadcategorytitle=form.uploadcategorytitle, uploadcategorydescription=form.uploadcategorydescription, parentid=listfirst(form.parentid,'|'), foldername=form.foldername, uploadcategoryid=form.uploadcategoryid)>
		<cfif isDefined('REQUEST.admintemplate') AND (REQUEST.admintemplate EQ 'popup')>
			<cfset popupStr="?fileform=fileform">
		<cfelse>
			<cfset popupStr="">
		</cfif>
		<cflocation url="#request.page##popupStr#" addtoken="no"></cflocation>
	<cfelse>
		<cfoutput>Must define all form fields (description optional)
		<a href="#request.page#<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'>?fileform=fileform&<cfelse>?</cfif>editCategory=true">[Back]</a></cfoutput>
	</cfif>	
<cfelseif isDefined('url.addFile')>
<!--- Form to add a file --->
	<cfoutput>#addEditFile()#</cfoutput>
<cfelseif isDefined('url.editFile')>
<!--- Form to edit a file --->
	<cfoutput>#addEditFile(url.editFile)#</cfoutput>
<cfelseif isDefined('url.addFileSubmit')>
	<!--- <script type="text/javascript">alert('upload file.');</script> add file popup submission not showing this--->
<!--- submit a new file --->
	<cffile action="UPLOAD" filefield="form.filename" destination="#application.tempDirpath#\" nameconflict="OVERWRITE">
	<cfset form.filesize=cffile.fileSize>
	<cfset form.filetype=cffile.clientFileExt>
	<cfset form.uploadcategoryid = listFirst(form.uploadcategoryid,'|')>
	<cfset newid =  fmObj.addNewFileQuery(uploadtitle=form.uploadtitle,uploaddescription=form.uploaddescription,active=form.active,filename=form.filename,uploadcategoryid=form.uploadcategoryid,filesize=form.filesize,extension=form.filetype)>
	<cfset newFileName = "#newid#.#form.filetype#">
	<cfset newFileDir = "#application.installpath#\uploads\#fmObj.getCategoriesData(uploadcategoryid=form.uploadcategoryid).foldername#">
	<cffile action="MOVE" source="#form.filename#" destination="#newFileDir#\#newFileName#">
	<cfif isdefined('form.scaleToSize') and form.scaleToSize GTE 1>
		<cfset fmObj.createThumbNail(filename=newFileName,dirpath=newFileDir,resizeOnValue=form.resizeOnValue,imageThumbSize=form.imageThumbSize)>
	</cfif>
		<script type="text/javascript">
			parent.updateView(<cfoutput>#trim(session.user.filemanager_listuploadcategory)#</cfoutput>);
			parent.showMessage('File added.', true);
		</script>
	<cfif session.user.hasJavascript>
	<cfelse>
		<cfif isDefined('REQUEST.admintemplate') AND (REQUEST.admintemplate EQ 'popup')>
			<cfset popupStr="?fileform=fileform">
		<cfelse>
			<cfset popupStr="">
		</cfif>
		<cflocation url="#request.page##popupStr#" addtoken="no"></cflocation>
	</cfif>
<cfelseif isDefined('url.editFileSubmit')>
<!--- edit a file --->
	<cfset form.uploadcategoryid = listFirst(form.uploadcategoryid,'|')>
	<cfif len(form.filename)>
		<cffile action="UPLOAD" filefield="form.filename" destination="#application.tempDirpath#\" nameconflict="OVERWRITE">
		<cfset form.filesize=cffile.fileSize>
		<cfset form.filetype=cffile.clientFileExt>
		<cfset  fmObj.updateFileQuery(uploadtitle=form.uploadtitle,uploaddescription=form.uploaddescription,active=form.active,filename='#form.uploadid#.#form.filetype#',uploadcategoryid=form.uploadcategoryid,filesize=form.filesize,extension=form.filetype,uploadid=form.uploadid)>

		<cfset newFileName = "#form.uploadid#.#form.filetype#">
		<cfset newFileDir = "#application.installpath#\uploads\#fmObj.getCategoriesData(uploadcategoryid=form.uploadcategoryid).foldername#">
		<cffile action="MOVE" source="#form.filename#" destination="#newFileDir#\#newFileName#">
		<cfif isDefined('form.scaleToSize') AND form.scaleToSize NEQ ''>
			<cfset fmObj.createThumbNail(filename=newFileName,dirpath=newFileDir,resizeOnValue=form.resizeOnValue,imageThumbSize=form.imageThumbSize)>
		</cfif>
	<cfelse>
		<cfset fmObj.updateFileQuery(uploadtitle=form.uploadtitle,uploaddescription=form.uploaddescription,active=form.active,uploadcategoryid=form.uploadcategoryid,uploadid=form.uploadid)>
		<cfset newFileName = "#fmObj.getFileData(uploadid=form.uploadid).filename#">
		<cfset newFileDir = "#application.installpath#\uploads\#fmObj.getCategoriesData(uploadcategoryid=form.uploadcategoryid).foldername#">
		<cfif isDefined('form.scaleToSize') AND TRIM(form.scaleToSize) NEQ ''>
			<cfset fmObj.createThumbNail(filename=newFileName,dirpath=newFileDir,resizeOnValue=form.resizeOnValue,imageThumbSize=form.imageThumbSize)>
		</cfif>
	</cfif>
	
		<script type="text/javascript">
			parent.updateView(<cfoutput>#trim(session.user.filemanager_listuploadcategory)#</cfoutput>);
			parent.showMessage('File updated.', true);
		</script>
	<cfif session.user.hasJavascript>
	<cfelse>
		<cfif isDefined('REQUEST.admintemplate') AND (REQUEST.admintemplate EQ 'popup')>
			<cfset popupStr="?fileform=fileform">
		<cfelse>
			<cfset popupStr="">
		</cfif>
		<cflocation url="#request.page##popupStr#" addtoken="no"></cflocation>
	</cfif>
<cfelse>
<!--- List files --->
	<cfsilent>
		<cfif isDefined("url.listuploadcategory")>
			<cfset session.user.filemanager_listuploadcategory = trim(url.listuploadcategory)>
		</cfif>
		<cfif isDefined("url.filesort")>
			<cfset session.user.filemanager_filesort = urldecode(url.filesort)>
		</cfif>
		<cfif isDefined("url.liststyle")>
			<cfset session.user.filemanager_liststyle = urldecode(url.liststyle)>
		</cfif>
	</cfsilent>

	<cfoutput>
	<script type="text/javascript" src="#application.globalPath#/javascript/wz_dragdrop.js"></script>
	<script type="text/javascript" src="#application.globalPath#/javascript/ajax/windowstyle.js"></script>
	<script type="text/javascript" src="#application.globalPath#/javascript/ajax/fmv2.js"></script>
	<style type="text/css"><cfinclude template="#application.globalPath#/css/filemanagerCSS.cfm"></style>
	<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate eq "popup">
		<style type="text/css">
			body{background-color:##fff;}
			##searchHeader{
				top:32px;
			}
		</style>
	</cfif>
	</cfoutput>
	<!--[if lt IE 7]>
	<style type="text/css">
	/* Serve gif images to IE/Win pre version 7 */
	.i1,
	.i2 { background-image:url('<cfoutput>#application.globalPath#</cfoutput>/media/images/popupborder.gif'); }
	.bt,
	.bt div,
	.bb,
	.bb div { background-image:url('<cfoutput>#application.globalPath#</cfoutput>/media/images/popupbox.gif'); }
	/* Set a height to fix up some rendering issues. */
	.i1,
	.i3 { height:1px; }
	</style>
	<![endif]-->
	<!--- these vars are used for selecting to formbuilder or FCK --->
	<cfif isDefined("url.callingfield")>
		<input type="hidden" id="parentWindow_callingfield" value="<cfoutput>#url.callingfield#</cfoutput>">
	<cfelseif isDefined('URL.CKEditor') AND isDefined('URL.CKEditorFuncNum')>
		<input type="hidden" id="parentWindow_caller" value="CKEditor">
		<input type="hidden" id="parentWindow_callingfield" value="<cfoutput>#url.CKEditor#</cfoutput>">
		<input type="hidden" id="parentWindow_callingFuncNum" value="<cfoutput>#url.CKEditorFuncNum#</cfoutput>">
	</cfif>
	<cfif isDefined("url.formname")>
		<input type="hidden" id="parentWindow_formname" value="<cfoutput>#url.formname#</cfoutput>">
	</cfif>
	<cfset currentDir=fmObj.getCategoriesData(uploadcategoryid=trim(session.user.filemanager_listuploadcategory))>
	<div id="linkHolder" style="position: absolute; top: 100px; left: 200px; width: 360px; <!--- height: 170px; ---> display: <cfif isDefined('url.viewLink')>block<cfelse>none</cfif>; padding:10px;" >
	<!--- Local File Path--->
	<div id="linkData"><a name="linkBox"></a>Local File Path (for pages in this site):<br /><input id="linkURL" name="linkURL" type="text" size="50" style="margin: 0px" value="<cfif isDefined('url.viewLink')><cfoutput>#url.viewLink#</cfoutput></cfif>"/>
	<!--- Absolute File Path--->
	<br /><br/>Absolute Path/URL (for external pages and links):<br /><input id="linkURLWeb" name="linkURLWeb" type="text" size="50" style="margin: 0px" value="<cfif isDefined('url.viewLink')><cfoutput>#url.viewLink#</cfoutput></cfif>"/>
	<!--- Friendly Download Link --->
	<cfif fileExists("#application.installpath#\home\friendlyDownload.cfm")>
		<cfif isDefined('url.viewLink')>
			<cfset thisDirectoryName = ListGetAt(url.viewLink,2,"/")>
			<cfset thisFileName = ListLast(url.viewLink,"/")>
			<cfset thisFileExt = ListLast(thisFileName,".")>
			<cfset thisSavename = url.savename>
			<cfset thisSavename = ReplaceNoCase(thisSavename," ","%20",'all')>
			<cfset thisSavename = ReplaceNoCase(thisSavename,"&","And",'all')>
			<cfset thisSavename = ReplaceNoCase(thisSavename,".","",'all')>
			<cfset thisSavename = ReplaceNoCase(thisSavename,"?","",'all')>
		</cfif>
		<br /><br/>Friendly Path/URL (for saving with a friendly name):<br /><input id="friendlyURL" name="friendlyURL" type="text" size="50" style="margin: 0px" value="<cfif isDefined('url.viewLink') AND isDefined('url.savename')><cfoutput>/home/friendlyDownload.cfm?directory=#thisDirectoryName#&actualFile=#thisFileName#&saveName=#thisSavename#.#thisFileExt#
</cfoutput></cfif>"/>
	</cfif>
	<br /><br /><div style="margin:0 auto; text-align:center"><cfif isDefined('url.viewLink')><a href="#request.page#"></cfif><input style="margin:0 auto;" align="middle" type="button" class="submitButton" onclick="document.getElementById('linkHolder').style.display='none';" value="Close" /><cfif isDefined('url.viewLink')></a></cfif>	
	</div></div></div>
	<div id="fmContainer">
		<!--- build header for current selected folder/category --->
		<div id="filelistHeader" class="headerBar"><cfoutput>#buildHeader(trim(session.user.filemanager_listuploadcategory))#</cfoutput></div>
		<!--- clear floating divs --->
		<div style="clear: both;"></div>
		<!--- build main category tree structure --->
		<div id="categoryholder">
			<!--- <cfdump var="#buildCategoryList(trim(session.user.filemanager_listuploadcategory),0,'stuff')#">
			<cfabort> --->
			<cfoutput>#buildCategoryList(trim(session.user.filemanager_listuploadcategory),0,'stuff')#</cfoutput>
		</div>
		<!--- folder contents (files) display region --->
		<div id="fileholder">
		<cfoutput>#buildFileList(trim(session.user.filemanager_listuploadcategory),'',session.user.filemanager_filesort)#</cfoutput>
		</div>
		<!--- generic popup add/edit window used for file and category --->
		<div id="addEditCategoryHolder" style="position: absolute; top: 100px; left: 100px; width: 400px; height: 300px;"><div id="addEditCategoryData" class="cbb"><cfoutput>#addEditCategory(0)#</cfoutput></div>
		</div>
		<!--- generic message holder used by showMessage() --->
		<div id="messageHolder" style="position: absolute; top: 100px; left: 200px; width: 360px; height: 80px;">
			<div id="messageData" class="cbb"><object type="application/x-shockwave-flash" data="#application.globalPath#/fileManager/swf/throbber.swf" height="79" width="109" style="vertical-align: middle; margin: 0;"><param name="wmode" value="transparent"><param name="movie" value="#application.globalPath#/fileManager/swf/throbber.swf"><param name="quality" value="high"></object>
			</div>
		</div>
		<div style="clear: both;"></div>
		<iframe id='target_upload' name='target_upload' src='' style='width:1px;height:1px;border:0;background-color:E6E6E6'></iframe>
	</div> <!--- end fmContainer div --->
	
	<cffunction name="buildCategoryListTopDown" returntype="string">
		<cfargument name="currentuploadcategoryid">
		<cfargument name="first">
		<cfargument name="builtdata">
		<cfset var currentcategoryid="">
		<cfset nestinglevel=0>
		
		<cfset currentdir=listGetAt(session.user.filemanager_openuploadcategories,currentuploadcatergoryid,",")>
		<cfset currentcategoryid=listGetAt(currentdir,1,":")>
		<cfset categoryopenstate=listGetAt(currentdir ,2,":")>
		
	<!--- build list element --->	
		<cfif #categoryopenstate#>
			getChildren(currentuploadcategoryid,nestinglevel);
		</cfif>
			

	</cffunction>
	<cffunction name="getCategoryChildren" return="string">
		<cfargument name="currentcategoryid">
		<cfargument name="nestinglevel">
		<cfquery name="q_findChildren" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT categoryid FROM uploadcategory WHERE parentid=#currentcategoryid#
		</cfquery>
		<cfif #q_findChildren.recordcount# NEQ 0>
			buildCategoryListTopDown()
		</cfif>
	</cffunction>
	
	<script type="text/javascript">
	<!--	

	SET_DHTML("addEditCategoryHolder"+RESET_Z+MAXOFFLEFT+0+MAXOFFTOP+0, "messageHolder"+NO_DRAG+RESET_Z);
	
	
	//-->
	</script>
	<script type="text/javascript">
		<cfif isDefined('REQUEST.admintemplate') AND REQUEST.admintemplate EQ 'popup'></cfif>
		attachBehaviors();
	</script>

</cfif>
