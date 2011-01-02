<!---
**i3SiteTools Upload Engine Script **
Version: 0.1
Authors: Ben Wakeman, George McLin
Date: July 23, 2002
Purpose: This custom module handles all methods for the user to administer
a uploads in the filesystem, and in the database. Adding, editing and deleting uploads. None of the code should be modified in this file.

Notes: all styles used for formatting can be found in the admintools.css which
resides in root of the admintools directory.

Databse(s):
upload
	uploadid
	label
	uploadtitle
	uploaddescription
	active
	filename
	uploadcategoryid
	filesize
	datemodified
uploadcategory
	uploadcatid
	label
	uploadcatdesc
	ordinal
upload_uploadcategory
	uploadid
	uploadcatid
 --->
<cfif thisTag.executionmode EQ 'start'>
<!--- DECLARE DEFAULT VARIABLES FOR SCRIPT --->
<cfset request.startingdirectory="0">
<cfparam name="url.parentid" default="0">
<cfparam name="thiscategoryid" default="#request.startingdirectory#">
<cfparam name="request.thiscategoryid" default="#thiscategoryid#">
<cfset request.thisDirectory="#application.installpath#\uploads">
<cfset request.tempDirectory="#request.thisDirectory#\99999_temp">
<cfset defaultaction="browse">
<cfparam name="formaction" default="#defaultaction#">
<cfparam name="request.formaction" default="#formaction#">
<cfparam name="url.formname" default="formname">
<cfparam name="url.callingfield" default="0">
<cfparam name="session.callingfield" default="0">
<cfif url.callingfield EQ 0 AND session.i3currenttool EQ application.tool.filemanager>
	<cfset thisTarget="mainFrame">
<cfelse>
	<cfset thisTarget="_top">
</cfif>

<cfswitch expression="#request.formaction#">
<!--- [RIGHT FRAME DIRECTORY BROWSER] --->
<cfcase value="browse">

<!--- get category dirs --->
	<cfquery name="q_getcategories" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT *
		FROM uploadcategory
		WHERE parentid=#request.thiscategoryid#
		ORDER BY uploadcategorytitle ASC
	</cfquery>
<!--- get files in selected category --->
	<cfparam name="url.sort" default="uploadtitle,ASC">
	<cfquery datasource="#application.datasource#" name="q_getfiles" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT
			u.uploadtitle,
			u.uploaddescription,
			u.uploadid,
			u.filesize,
			u.datemodified,
			u.filetype,
			u.filename,
			u.uploadcategoryid
		FROM
			upload u CROSS JOIN
				uploadcategory uc
		WHERE
			(u.uploadcategoryid = uc.uploadcategoryid) AND (u.uploadcategoryid = #request.thiscategoryid#)
		<cfif isDefined("url.fileNameSearch") AND len(trim(url.fileNameSearch))>
		AND ((u.uploadtitle LIKE '%#url.fileNameSearch#%') OR (u.uploaddescription LIKE '%#url.fileNameSearch#%'))
		</cfif>
		ORDER BY #listFirst(url.sort)# #listLast(url.sort)#
	</cfquery>
<!--- get current folder name --->
	<cfset currentDir="">
	<cfset thisparentid=request.thiscategoryid>
	<cfloop condition="thisparentid neq ''">
		<cfquery datasource="#application.datasource#" name="q_getcurrentdir" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT uploadcategorytitle,parentid,uploadcategoryid FROM uploadcategory WHERE uploadcategoryid=#thisparentid#
		</cfquery>
		<cfset thisparentid=q_getcurrentdir.parentid>
		<cfset currentDir=listPrepend(currentDir,'<a href="/admintools/core/filemanager/index.cfm?formaction=fileform&thiscategoryid=#q_getcurrentdir.uploadcategoryid#&uploadcategoryid=#q_getcurrentdir.uploadcategoryid#" target="#thisTarget#">#q_getcurrentdir.uploadcategorytitle#</a>',"\")>
	</cfloop>
<!--- loop thru categories by title, showing subs, and files. --->
<cfmodule template="#application.customTagPath#/htmlshell.cfm" css="site.css,admintools.css" title="File Manager" bgcolor="e6e6e6" padding="8">
	<cfoutput>
<table width="100%" class="toolTable" cellpadding="3" cellspacing="1">
<cfif application.getPermissions("addedit",session.i3currenttool)>
	<tr>
		<td class="dirtreebuttonbar" colspan="4"><a href="filemanager.cfm?formaction=catform&parentid=#request.thiscategoryid#" target="left" style="color:white;text-decoration:none;">Add Categories</a> | <a href="filemanager.cfm?formaction=fileform&uploadcategoryid=#request.thiscategoryid#" target="left" style="color:white;text-decoration:none;">Add Files</a></td>
	</tr>
</cfif>
<!--- if there is are files in this folder, show the 'search' filter form for them --->
<cfif q_getfiles.recordcount>
<tr>
	<td colspan="4" class="dirtreeheadertext">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
				<td class="dirtreeheadertext">&nbsp;</td>
				<td><form action="filemanager.cfm" method="GET" style="margin-bottom: 0px; margin-left: 0px; margin-right: 0px; margin-top: 0px; page-break-before: avoid; page-break-after: avoid;"><input name="fileNameSearch" type="text" title="Use this to search the product Titles and Descriptions" size="20" maxlength="30"> <input name="submit" type="submit" value="Find" class="submitbuttonsmall">
				<cfloop index="thisURLvar" list="#CGI.QUERY_STRING#" delimiters="&">
				<cfif listFirst(thisURLvar,'=') NEQ "fileNameSearch">
				<input name="#listFirst(thisURLvar,'=')#" type="hidden" value="#evaluate('URL.#listFirst(thisURLvar,'=')#')#">
				</cfif>
				</cfloop>
				</form></td>
		</tr>
		</table>
	</td>
</tr>
</cfif>
<tr>
	<td class="dirtreeheadertext">
	<cfif listLast(url.sort) eq "ASC">
	<a href="filemanager.cfm?formaction=browse&sort=uploadtitle,DESC&thiscategoryid=#request.thiscategoryid#<cfif isDefined("url.fileNameSearch")>&fileNameSearch=#url.fileNameSearch#</cfif>" style="color:white;text-decoration:none;">File</a>
	<cfelse>
	<a href="filemanager.cfm?formaction=browse&sort=uploadtitle,ASC&thiscategoryid=#request.thiscategoryid#<cfif isDefined("url.fileNameSearch")>&fileNameSearch=#url.fileNameSearch#</cfif>" style="color:white;text-decoration:none;">File</a>
	</cfif>
	</td>
	<td class="dirtreeheadertext" nowrap>
	<cfif listLast(url.sort) eq "ASC">
	<a href="filemanager.cfm?formaction=browse&sort=filesize,DESC&thiscategoryid=#request.thiscategoryid#<cfif isDefined("url.fileNameSearch")>&fileNameSearch=#url.fileNameSearch#</cfif>" style="color:white;text-decoration:none;">Size</a>
	<cfelse>
	<a href="filemanager.cfm?formaction=browse&sort=filesize,ASC&thiscategoryid=#request.thiscategoryid#<cfif isDefined("url.fileNameSearch")>&fileNameSearch=#url.fileNameSearch#</cfif>" style="color:white;text-decoration:none;">Size</a>
	</cfif>
	</td>
	<td class="dirtreeheadertext" nowrap>
	<cfif listLast(url.sort) eq "ASC">
	<a href="filemanager.cfm?formaction=browse&sort=filetype,DESC&thiscategoryid=#request.thiscategoryid#<cfif isDefined("url.fileNameSearch")>&fileNameSearch=#url.fileNameSearch#</cfif>" style="color:white;text-decoration:none;">Type</a>
	<cfelse>
	<a href="filemanager.cfm?formaction=browse&sort=filetype,ASC&thiscategoryid=#request.thiscategoryid#<cfif isDefined("url.fileNameSearch")>&fileNameSearch=#url.fileNameSearch#</cfif>" style="color:white;text-decoration:none;">Type</a>
	</cfif>
	</td>
	<td class="dirtreeheadertext">
	<cfif listLast(url.sort) eq "ASC">
	<a href="filemanager.cfm?formaction=browse&sort=datemodified,DESC&thiscategoryid=#request.thiscategoryid#<cfif isDefined("url.fileNameSearch")>&fileNameSearch=#url.fileNameSearch#</cfif>" style="color:white;text-decoration:none;">Modified</a>
	<cfelse>
	<a href="filemanager.cfm?formaction=browse&sort=datemodified,ASC&thiscategoryid=#request.thiscategoryid#<cfif isDefined("url.fileNameSearch")>&fileNameSearch=#url.fileNameSearch#</cfif>" style="color:white;text-decoration:none;">Modified</a>
	</cfif>
	</td>
</tr>
<tr>
	<td colspan="4" class="dirtreecurrentfolder"><cfif request.thiscategoryid NEQ request.startingdirectory><a href="/admintools/core/filemanager/index.cfm?formaction=fileform&thiscategoryid=#url.parentid#&uploadcategoryid=#url.parentid#" target="#thisTarget#"><img src="/admintools/media/images/upfolder.gif" border="0"></a></cfif>#currentDir#
	</td>
</tr>
<cfloop query="q_getcategories">
<tr>
	<td colspan="4" class="dirtreefoldertext"><a href="/admintools/core/filemanager/index.cfm?formaction=fileform&uploadcategoryid=#q_getcategories.uploadcategoryid#&thiscategoryid=#q_getcategories.uploadcategoryid#&parentid=#q_getcategories.parentid#" target="#thisTarget#">
<cfif q_getcategories.uploadcategoryid eq 99999>
 <img src="/admintools/media/images/icon_recycle.gif" alt="Recycle Bin" border="0">
<cfelse>
<img src="/admintools/media/images/folder.gif" alt="" hspace="0" vspace="0" border="0" align="absbottom">
</cfif>
#q_getcategories.uploadcategorytitle#</a>
<cfif thiscategoryid GT 0>
<cfif application.getPermissions("addedit",session.i3currenttool)><a href="filemanager.cfm?formaction=catform&uploadcategoryid=#uploadcategoryid#" target="left" title="Edit Category"><img src="/admintools/media/images/icon_edit.gif" border="0"></a></cfif>
</cfif>
</td>
</tr>
</cfloop>
<cfloop query="q_getfiles">
	<cfquery datasource="#application.datasource#" name="q_getFolder" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT foldername FROM uploadcategory WHERE uploadcategoryid = #q_getfiles.uploadcategoryid#
	</cfquery>
	<script language="JavaScript">
		function ClipBoard(clipLink) 
		{
				linkWin=window.open(clipLink,'LinkWindow','scrollbars=auto,resizable=yes,status=no,height=30');
				linkWin.document.write(clipLink);
		}
	</script>
	<textarea id="holdtext" style="display:none;"></textarea>
<tr>
	<td class="dirtreefiletext"><a href="##" title="Click to copy this link to your clipboard..." onclick="ClipBoard('/uploads/#q_getFolder.foldername#/#q_getfiles.filename#');">[link]</a> <a href="filemanager.cfm?formaction=fileform&uploadid=#q_getfiles.uploadid#" target="left" title="#q_getfiles.uploaddescription#"> #q_getfiles.uploadtitle#</a>
	</td>
	<td class="dirtreefiletext" align="right">#evaluate(q_getfiles.filesize\1024)#K</td>
	<td class="dirtreefiletext">#q_getfiles.filetype#</td>
	<td class="dirtreefiletext" nowrap>#dateformat(q_getfiles.datemodified,"m-d-yy")# #timeformat(q_getfiles.datemodified,"h:mmt")#</td>
</tr>
</cfloop>
</table>
	</cfoutput>

</cfmodule>
</cfcase>

<!--- LEFT FRAME DISPLAY FORM FOR FILE ADD/EDIT --->
<cfcase value="fileform">
<!--- Check for calling page form field name variable --->
	<cfif (session.callingfield EQ 0) OR (isDefined("url.newfile") AND url.newfile EQ "true")>
		<cflock scope="SESSION" type="EXCLUSIVE" timeout="5">
			<cfset session.callingfield=url.callingfield>
			<cfset session.formname=url.formname>
		</cflock>
		<cfset url.newfile="false">
	</cfif>
<cfparam name="uploadid" default="0">
	<cfif uploadid and NOT isDefined("request.success")>
		<cfquery datasource="#application.datasource#" name="q_getfileinfo" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT *
			FROM upload
			WHERE uploadid = #uploadid#
		</cfquery>
			<cfparam name="form.uploadid" default="#q_getfileinfo.uploadid#">
			<cfparam name="form.uploadtitle" default="#q_getfileinfo.uploadtitle#">
			<cfparam name="form.uploaddescription" default="#q_getfileinfo.uploaddescription#">
			<cfparam name="form.active" default="#q_getfileinfo.active#">
			<cfparam name="form.filename" default="#q_getfileinfo.filename#">
			<cfparam name="form.uploadcategoryid" default="#q_getfileinfo.uploadcategoryid#">
			<cfparam name="form.datemodified" default="#q_getfileinfo.datemodified#">
			<!--- OS_Issue Thumb Creation params --->
	<cfelse>
			<cfparam name="form.uploadid" default="0">
			<cfparam name="form.uploadtitle" default="">
			<cfparam name="form.uploaddescription" default="">
			<cfparam name="form.active" default=1>
			<cfparam name="form.filename" default="">
			<cfif isDefined("url.uploadcategoryid")>
				<cfparam name="form.uploadcategoryid" default="#url.uploadcategoryid#">
			<cfelse>
				<cfparam name="form.uploadcategoryid" default="">
			</cfif>
			<cfparam name="form.datemodified" default="">
			<!--- OS_Issue Thumb Creation params --->
	</cfif>

<cfmodule template="#application.customTagPath#/htmlshell.cfm" css="site.css,admintools.css" title="File Manager" bgcolor="e6e6e6" padding="8">
<cfoutput>
	<table width="100%" class="toolTable" cellpadding="3" cellspacing="1">
	<tr>
		<td class="toolheader" style="text-align:left;" colspan="3">File Management</td>
	</tr>
	<!--- show error or success message --->
	<cfif isDefined("request.success")>
	<tr>
		<td class="successtext" colspan="3"><ul>#request.success#</ul></td>
	</tr>
	<cfelseif isDefined("request.errorMsg")>
	<tr>
		<td class="errortext" colspan="3"><ul>#request.errorMsg#</ul></td>
	</tr>
	</cfif>
	<form action="#request.page#?formaction=fileconfirm" method="post" enctype="multipart/form-data">
	<input type="Hidden" name="uploadid" value="#form.uploadid#">
	<input type="Hidden" name="filename" value="#form.filename#">
	<input type="Hidden" name="oldfilename" value="#form.filename#">
	<input type="Hidden" name="extension" value="#listlast(form.filename, ".")#">
	<tr>
		<td width="41%" class="formitemlabelreq">Category: </td>
		<td colspan="2" class="formiteminput">
	<select name="uploadcategoryid" size="1">
		<cfmodule template="#application.customTagPath#/categoryindent.cfm"
			item_id_col = "uploadcategoryid"
			display_name_col = "uploadcategorytitle"
			item_parent_id_col = "parentid"
			the_table = "uploadcategory"
			db = "#application.datasource#"
			id = "0"
			order_by = "uploadcategorytitle">
	</select>
		</td>
	</tr>
	<tr>
		<td class="formitemlabelreq">Title: </td>
		<td colspan="2" class="formiteminput"><input type="text" name="uploadtitle" value="#form.uploadtitle#" size="25" maxlength="255"></td>
	</tr>
	<tr>
		<td class="formitemlabelreq">Description: </td>
		<td colspan="2" class="formiteminput"><textarea cols="25" rows="5" name="uploaddescription">#form.uploaddescription#</textarea></td>
	</tr>
	<cfif form.uploadid>
	<tr>
		<td class="formitemlabelreq">Replace File: </td>
		<td colspan="2" class="formiteminput"><input type="radio" name="replace" value="1">Yes <input type="radio" name="replace" value="0" checked>No</td>
	</tr>
	</cfif>
	<tr>
		<td class="formitemlabelreq">File: </td>
		<td colspan="2" class="formiteminput"><input type="file" name="filename" style="width: 230"></td>
	</tr>
	<!--- OS_Issue Thumb Creation size options --->
	<tr>
		<td class="formitemlabelreq">Active: </td>
		<td colspan="2" class="formiteminput"><input type="radio" name="active" value="1"<cfif form.active> checked</cfif>>Yes <input type="radio" name="active" value="0"<cfif NOT form.active> checked</cfif>>No</td>
	</tr>
	<tr>
		<td class="formiteminput" colspan="3" align="center"><cfif application.getPermissions("addedit",session.i3currenttool)><input type="submit" name="Submit" value="<cfif form.uploadid>Update<cfelse>Add</cfif>" class="submitbuttonsmall"></cfif>
<cfif form.uploadid>
<cfquery name="q_getcatname4preview" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT foldername FROM uploadcategory WHERE uploadcategoryid='#form.uploadcategoryid#'
	</cfquery>
<cfif application.getPermissions("remove",session.i3currenttool)><input type="button" name="delete" value="Delete" onclick="javascript:window.location='filemanager.cfm?formaction=filedelete&uploadid=#form.uploadid#';" class="submitbuttonsmall"></cfif> <input type="button" name="" value="Preview" onclick="javascript:window.open('/uploads/#q_getcatname4preview.foldername#/#form.filename#','previewwin','toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=650,height=400');" class="submitbuttonsmall">

<cfif session.i3currenttool neq application.tool.filemanager>
<cfif session.callingfield NEQ 0><input type="button" name="" value="Select" onclick="<cfif session.callingfield EQ 'FCKImageManager'>parent.opener.document.getElementById('txtURL').value='/uploads/#q_getcatname4preview.foldername#/#form.filename#';<cfelse>parent.opener.document.#session.formname#.#session.callingfield#.options[0].text='#form.uploadtitle#';parent.opener.document.#session.formname#.#session.callingfield#.options[0].value='#form.uploadid#~$#form.uploadtitle#';parent.opener.document.#session.formname#.#session.callingfield#_display.value='#form.uploadtitle#';parent.opener.document.#session.formname#.#session.callingfield#.options[0].selected=true;</cfif>top.window.close();" class="submitbuttonsmall"></cfif>
</cfif>
</cfif>

</td>
	</tr>

	</form>
	</table>
</cfoutput>
</cfmodule>
</cfcase>

<!--- [LEFT FRAME CONFIRM FILE ADD/EDIT ]--->
<cfcase value="fileconfirm">
<!--- check required fields display errors--->
	<cfif isDefined("form.submit")>
	<cfset request.isError=0>
	<cfset request.errorMsg="">
		<cfif NOT len(trim(form.uploadcategoryid))>
			<cfset request.isError=1>
			<cfset request.errorMsg=request.errorMsg&"<li>Upload Category is required.</li>">
		</cfif>
		<cfif NOT len(trim(form.uploadtitle))>
			<cfset request.isError=1>
			<cfset request.errorMsg=request.errorMsg&"<li>Upload Title is required.</li>">
		</cfif>
	</cfif>
	<cfif request.isError>
		<cfset request.formaction="fileform">
		<cfmodule template="filemanager.cfm">
	<cfelse>
	<!--- upload/check file --->
	<cfset request.thisUUID=CreateUUID()>
		<cfif form.uploadid eq 0 OR form.replace eq 1>
			<cfif len(trim(form.filename))><!--- if there's a filename, then upload it! --->
				<cffile action="UPLOAD"
				        filefield="filename"
				        destination="#request.tempDirectory#\"
				        nameconflict="OVERWRITE">
				<cfset form.filesize=cffile.fileSize>
				<cfset form.extension=cffile.clientFileExt>
				<!--- Validate file extension --->
					<cfif NOT len(trim(cffile.clientFileExt))>
						<cfset request.isError=1>
						<cfset request.errorMsg="<li>Your file does not have a valid extension (ex: .jpg).</li>">
					</cfif>
				<!--- rename up'd file to UUID, prep for copy to final directory --->
				<cffile action="RENAME"
				        source="#request.tempDirectory#\#clientFile#"
				        destination="#request.tempDirectory#\#request.thisUUID#.#cffile.clientFileExt#">
			<cfelse><!--- No file specified, show error --->
					<cfset request.isError=1>
					<cfset request.errorMsg="<li>Please Choose a replacement file.</li>">
			</cfif>
		</cfif>
		<cfif request.isError>
			<cfset request.formaction="fileform">
			<cfmodule template="filemanager.cfm">
		</cfif>
	</cfif>
	<!--- No Errors, Show Confirmation of data entered --->
	<cfif NOT request.isError>
		<cfoutput>
			<cfmodule template="#application.customTagPath#/htmlshell.cfm" css="site.css,admintools.css" title="File Manager" bgcolor="e6e6e6" padding="8">
			<div align="center">
					<table width="400" class="toolTable" cellpadding="3" cellspacing="1">
					<tr>
						<td colspan="2" class="toolheader">Please Confirm File Info</td>
					</tr>
					<tr>
						<td colspan="2" class="formconfirminput"><font size="-1">Review the information you entered. If everything is correct, post your changes, if not, use the "Cancel" button to return to the form.</font></td>
					</tr>
					<tr>
						<td class="formconfirmlabel">Title: </td>
						<td class="formconfirminput">#form.uploadtitle#</td>
					</tr>
					<tr>
						<td class="formconfirmlabel">Description: </td>
						<td class="formconfirminput">#form.uploaddescription#</td>
					</tr>
					<tr>
						<td class="formconfirmlabel">Category: </td>
						<td class="formconfirminput">#listLast(form.uploadcategoryid, "|")#</td>
					</tr>
				<cfif isDefined("form.filesize")>
					<tr>
						<td class="formconfirmlabel">Filesize: </td>
						<td class="formconfirminput">#form.filesize#</td>
					</tr>
				</cfif>
					<tr>
						<td colspan="2" align="center" class="formconfirminput">
						<form action="/admintools/core/filemanager/index.cfm" enctype="multipart/form-data" target="#thisTarget#" method="get">
						<input type="hidden" name="formaction" value="fileaction">
						<input type="hidden" name="thisdirectory" value="#listFirst(form.uploadcategoryid, "|")#">
						<input type="hidden" name="UUID" value="#request.thisUUID#">
						<input type="Hidden" name="thiscategoryid" value="#listFirst(form.uploadcategoryid, "|")#">
						<cfif isDefined("form.filesize")>
						<input type="hidden" name="filesize" value="#form.filesize#">
						<input type="hidden" name="extension" value="#form.extension#">
						</cfif>
						<input type="hidden" name="newcategory" value="#form.uploadcategoryid#">
						<cfset form.uploadcategoryid=listFirst(form.uploadcategoryid, "|")>
						<!--- use custom tag to pass hidden form fields --->
						 <cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="filesize,extension">

						<input type="submit" value="Post" name="submit" class="submitbuttonsmall">
						<input type="button" value="Cancel" onclick="javascript:history.go(-1);" class="submitbuttonsmall"  style="width: 60px;">
</form>
						</td>
					</tr>
					</table>
					</div>
			</cfmodule>
		</cfoutput>
	</cfif>
</cfcase>

<!--- [ADD/EDIT FILE] --->
<cfcase value="fileaction">
	<!--- add/update db --->
	<cfif url.uploadid>
		<!--- check to see if the file is getting a new directory --->
		<cfquery name="q_dirchangecheck" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT u.uploadcategoryid, uc.foldername, u.filetype
			FROM upload as u, uploadcategory as uc
			WHERE u.uploadcategoryid=uc.uploadcategoryid
			AND u.uploadid=#url.uploadid#
		</cfquery>
		<cfset filename="#url.uploadid#.#q_dirchangecheck.filetype#">
		<cfif q_dirchangecheck.uploadcategoryid NEQ listfirst(url.newcategory, "|")>
			<!--- query for destination folder name --->
			<cfquery name="q_destinationFolder" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT uploadcategoryid,foldername
				FROM uploadcategory
				WHERE uploadcategoryid=#listFirst(url.newcategory, "|")#
			</cfquery>
			<cffile action="MOVE"
		        source="#request.thisDirectory#\#q_dirchangecheck.foldername#\#variables.filename#"
		        destination="#request.thisDirectory#\#q_destinationFolder.foldername#\#variables.filename#">
		        <!--- OS_Issue Thumbnail Creation Can Go Here --->
		</cfif>
		<!--- make db update --->
		<cfquery name="q_addnewfile" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			UPDATE upload
			SET uploadtitle = '#trim(url.uploadtitle)#', uploaddescription = '#trim(url.uploaddescription)#', active = #trim(url.active)#<cfif isDefined("url.filename")>, filename = '#variables.filename#'</cfif>, uploadcategoryid = #trim(url.uploadcategoryid)#<cfif isDefined("url.filesize")>, filesize = '#trim(url.filesize)#', filetype='#url.extension#'</cfif>, datemodified = #CreateODBCDateTime(Now())#
			WHERE uploadid = #trim(url.uploadid)#
		</cfquery>
		<cfset request.success="<li>The file <b>#url.uploadtitle#</b> has been successfully updated.</li>">
	<cfelse>
		<cftransaction>
			<cfquery name="q_addnewfile" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			INSERT INTO upload
				(uploadtitle, uploaddescription, active, filename, uploadcategoryid, filesize, datemodified, filetype)
			VALUES
				('#trim(url.uploadtitle)#', '#trim(url.uploaddescription)#', #trim(url.active)#, '#url.filename#', #trim(url.uploadcategoryid)#, '#trim(url.filesize)#', #CreateODBCDateTime(Now())#, '#url.extension#')
			</cfquery>
			<cfquery name="q_getnewid" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT max(uploadid) AS thisid FROM upload
			</cfquery>
			<cfquery name="q_updatenewfile" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE upload SET filename='#q_getnewid.thisid#.#url.extension#' WHERE uploadid=#q_getnewid.thisid#
			</cfquery>
		</cftransaction>
	<cfset filename="#q_getnewid.thisid#.#url.extension#">
	</cfif>

	<cfif url.uploadid eq 0 OR url.replace eq 1>
		<!--- move file to appropriate dir from /temp --->
		<cfquery name="q_getDir" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT foldername, uploadcategorytitle
			FROM uploadcategory
			WHERE uploadcategoryid=#trim(url.uploadcategoryid)#
		</cfquery>
		<!--- kill old file if replace --->
		<cfif isDefined("url.replace") AND url.replace eq 1>
			<cffile action="DELETE" file="#request.thisDirectory#\#q_getDir.foldername#\#url.oldfilename#">
		</cfif>
		<cffile action="MOVE"
	        source="#request.tempDirectory#\#url.UUID#.#url.extension#"
	        destination="#request.thisDirectory#\#q_getDir.foldername#\#variables.filename#">
			<!--- OS_Issue Thumbnail Creation Can Go Here --->
		<cfset request.success="<li>The file <b>#url.uploadtitle#</b> has been successfully uploaded to <b>#q_getDir.uploadcategorytitle#</b>.</li>">
	</cfif>

	<!--- clear form, and start all over --->
		<!--- save these url vars so the frame can know where to go on refresh --->
	<cfset request.parentid=url.parentid>
	<cfset killform=structClear(url)>
	<cfset url.parentid=request.parentid>
	<cfset request.formaction="fileform">
	<!--- send directory back here or no? --->
	<cfmodule template="filemanager.cfm">
</cfcase>
<!--- [DELETE FILE] --->
<cfcase value="filedelete">
	<cfif isDefined("url.confirmdelete")>
		<!--- clear this file from the filesystem --->
			<!--- get file name --->
			<cfquery name="q_getthisfileid" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT u.uploadtitle, u.filename, uc.foldername
				FROM upload AS u, uploadcategory AS uc
				WHERE u.uploadcategoryid=uc.uploadcategoryid
				AND uploadid=#url.uploadid#
			</cfquery>
			<!--- delete file --->
			<cfif FileExists("#request.thisDirectory#\#q_getthisfileid.foldername#\#q_getthisfileid.filename#")>
				<cffile action="DELETE" file="#request.thisDirectory#\#q_getthisfileid.foldername#\#q_getthisfileid.filename#">
			</cfif>
			<!--- OS_Issue Thumbnail deletion Can Go Here --->
		<!--- clear this file from the db --->
		<cfquery name="q_deletefile" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			DELETE FROM upload
			WHERE uploadid=#url.uploadid#
		</cfquery>
		<!--- Editied below line to append request.success instead of initiating it.--->
		<cfset request.success="You have successfully deleted the #q_getthisfileid.uploadtitle#.">
		<cfif IsDefined('thumbnailFound') and #thumbnailFound# is 'true'><cfset request.success=#request.success#&"<li>A thumbnail was found for this image and has been removed.</li>"></cfif>
		<cfset request.formaction="fileform">
		<cfmodule template="filemanager.cfm">
	<cfelse>
	<!--- Retrieve file info to display for confirm delete --->
	<cfquery name="q_thisfile" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT *
		FROM upload
		WHERE uploadid=#url.uploadid#
	</cfquery>
		<cfmodule template="#application.customTagPath#/htmlshell.cfm" css="site.css,admintools.css" title="File Manager" bgcolor="e6e6e6" padding="8">
		<table width="300" border="1" cellspacing="0" cellpadding="0" bordercolor="#000000" align="center">
			<tr>
				<td class="formiteminput">
				<cfoutput>Are you sure you wish to delete:<p>
					<b>File Title:</b> #q_thisfile.uploadtitle#<br>
					<b>File Size:</b> #q_thisfile.filesize#<br>
					<b>Last Modified:</b> #DateFormat(q_thisfile.datemodified,"mmmm d, yyyy")# at #timeFormat(q_thisfile.datemodified,"h:mm tt")#
				<form action="/admintools/core/filemanager/index.cfm" target="#thisTarget#" method="get">
				<input type="Hidden" name="formaction" value="filedelete">
				<input type="Hidden" name="thiscategoryid" value="#q_thisfile.uploadcategoryid#">
				<input type="Hidden" name="uploadid" value="#url.uploadid#">
				<input type="Hidden" name="confirmdelete" value="1">
				<input type="Submit" value="Delete Now" class="submitbutton">
				<input type="button" value="Cancel" onclick="javascript:history.go(-1);" class="submitbutton"  style="width: 60px;">
				</form>
				</cfoutput>
				</td>
			</tr>
		</table>
	</cfmodule>
	</cfif>

</cfcase>
<!--- [REPLICATE FILE] --->
<cfcase value="replicate">

</cfcase>

<!--- [LEFT FRAME DISPLAY FORM FOR CATEGORY ADD/EDIT] --->
<cfcase value="catform">
<cfparam name="uploadcategoryid" default="0">
	<cfif uploadcategoryid and NOT isDefined("request.success")>
		<cfquery datasource="#application.datasource#" name="q_getcategoryinfo" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT *
			FROM uploadcategory
			WHERE uploadcategoryid = #uploadcategoryid#
		</cfquery>
			<cfparam name="form.uploadcategoryid" default="#q_getcategoryinfo.uploadcategoryid#">
			<cfparam name="form.uploadcategorytitle" default="#q_getcategoryinfo.uploadcategorytitle#">
			<cfparam name="form.uploadcategorydescription" default="#q_getcategoryinfo.uploadcategorydescription#">
			<cfparam name="form.ordinal" default="#q_getcategoryinfo.ordinal#">
			<cfparam name="form.parentid" default="#q_getcategoryinfo.parentid#">
			<cfparam name="form.foldername" default="#listDeleteAt(q_getcategoryinfo.foldername,1,"_")#">
	<cfelse>
			<cfparam name="form.uploadcategoryid" default="0">
			<cfparam name="form.uploadcategorytitle" default="">
			<cfparam name="form.uploadcategorydescription" default="">
			<cfparam name="form.ordinal" default="0">
			<cfif isDefined("url.parentid")>
				<cfparam name="form.parentid" default="#url.parentid#">
			<cfelse>
				<cfparam name="form.parentid" default="0">
			</cfif>
			<cfparam name="form.foldername" default="">
	</cfif>
<cfmodule template="#application.customTagPath#/htmlshell.cfm" css="site.css,admintools.css" title="File Manager" bgcolor="e6e6e6" padding="8">
<cfoutput>
	<table width="100%" border="0" class="toolTable" cellpadding="3" cellspacing="1">
	<tr>
		<td class="toolheader" colspan="2" style="text-align:left;">File Category Manager</td>
	</tr>
	<!--- show error or success message --->
	<cfif isDefined("request.success")>
	<tr>
		<td class="successtext" colspan="2"><ul>#request.success#</ul></td>
	</tr>
	<cfelseif isDefined("request.errorMsg")>
	<tr>
		<td class="errortext" colspan="2"><ul>#request.errorMsg#</ul></td>
	</tr>
	</cfif>
	<form action="#request.page#?formaction=catconfirm" method="post" enctype="multipart/form-data">
	<input type="Hidden" name="uploadcategoryid" value="#form.uploadcategoryid#">
	<input type="Hidden" name="ordinal" value="#form.ordinal#">
		<tr>
		<td class="formitemlabelreq">Title: </td>
		<td class="formiteminput"><input type="text" name="uploadcategorytitle" value="#form.uploadcategorytitle#" size="25" maxlength="255"></td>
	</tr>
	<tr>
		<td class="formitemlabelreq">Description: </td>
		<td class="formiteminput"><textarea cols="25" rows="5" name="uploadcategorydescription">#form.uploadcategorydescription#</textarea></td>
	</tr>
	<!--- get all categories --->
	<cfquery name="q_getallcategories" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT *
		FROM uploadcategory
		WHERE uploadcategoryid <> 99999
	</cfquery>
	<tr>
		<td class="formitemlabelreq">Parent Category: </td>
		<td class="formiteminput">
	<select name="parentid" size="1">
			<option value="">Choose a Parent for this Category </option>
		<cfloop query="q_getallcategories">
			<cfif q_getallcategories.uploadcategoryid NEQ form.uploadcategoryid>
				<option value="#q_getallcategories.uploadcategoryid#|#q_getallcategories.uploadcategorytitle#" <cfif q_getallcategories.uploadcategoryid eq listfirst(form.parentid,"|")>selected</cfif>>#q_getallcategories.uploadcategorytitle#</option>
			</cfif>
		</cfloop>
	</select>
		</td>
	</tr>
	<tr>
		<td class="formitemlabelreq">Folder: </td>
		<td class="formiteminput"><input type="text" name="foldername" value="#form.foldername#" size="25" maxlength="255"></td>
	</tr>
	<tr>
		<td class="formitemlabelreq">Icon: </td>
		<td class="formiteminput"><input name="icon" type="file" size="25"></td>
	</tr>
	<tr>
		<td class="formiteminput" colspan="2" align="center"><cfif application.getPermissions("addedit",session.i3currenttool)><input type="submit" name="Submit" value="<cfif form.uploadcategoryid>Update<cfelse>Add</cfif>" class="submitbuttonsmall"></cfif><cfif form.uploadcategoryid> <cfif application.getPermissions("remove",session.i3currenttool)><input type="button" name="delete" value="Delete" onclick="javascript:window.location='filemanager.cfm?formaction=catconfirm&delete=yes&uploadcategoryid=#form.uploadcategoryid#';" class="submitbuttonsmall"></cfif></cfif></form></td>
	</tr>

	</table>
</cfoutput>
</cfmodule>

</cfcase>

<!--- [LEFT FRAME CONFIRM CATEGORY ADD/EDIT] --->
<cfcase value="catconfirm">
<cfscript>
// directory check
function IsDirectory(str) {
if (REFindNoCase("^[_A-Za-z0-9]+$",str)) return TRUE;
	else return FALSE;
}
</cfscript>

<!--- check required fields display errors--->
	<cfif isDefined("url.delete")>
	<!--- Show confirm delete of cat message --->
		<cfmodule template="#application.customTagPath#/htmlshell.cfm" css="site.css,admintools.css" title="File Manager" bgcolor="e6e6e6" padding="8">
		<table width="100%" class="toolTable" cellpadding="3" cellspacing="1">
		<tr>
			<td class="formconfirminput">Are you sure you want to delete this category?</td>
		</tr>
		<tr>
			<td align="center" class="formconfirminput">
			<cfoutput><form action="/admintools/core/filemanager/index.cfm" target="#thisTarget#" method="get">
			<input type="Hidden" name="uploadcategoryid" value="#url.uploadcategoryid#">
			<input type="Hidden" name="formaction" value="cataction">
			<input type="Hidden" name="delete" value="1">
			<input type="Hidden" name="thiscategoryid" value="#request.startingdirectory#">
			<input type="submit" value="Delete Now" name="submit" class="submitbutton">
			<input type="button" value="Cancel" onclick="javascript:history.go(-1);" class="submitbutton"  style="width: 60px;">
			</form></cfoutput>
			</td>
		</tr>
		</table>
		</cfmodule>
	<cfelse>
	<!--- Upload Icon File if one has been specified --->
	<cfif len(trim(form.icon))>
		<cffile action="UPLOAD"
				filefield="icon"
				destination="#request.tempDirectory#\"
				nameconflict="OVERWRITE">
				
		<!--- rename up'd file to UUID, prep for copy to final directory --->
		<cfset request.iconUUID=createUUID()>
		<cffile action="RENAME"
				source="#request.tempDirectory#\#clientFile#"
				destination="#request.tempDirectory#\#request.iconUUID#.#cffile.clientFileExt#">
	</cfif>
		<cfif isDefined("form.submit")>
		<cfset request.isError=0>
		<cfset request.errorMsg="">
			<cfif NOT len(trim(form.uploadcategorytitle))>
				<cfset request.isError=1>
				<cfset request.errorMsg=request.errorMsg&"<li>Category Title is required.</li>">
			</cfif>
			<cfif form.parentid EQ "" OR form.parentid EQ 0>
				<cfset request.isError=1>
				<cfset request.errorMsg=request.errorMsg&"<li>Category Location is required.</li>">
			</cfif>
			<cfif NOT IsDirectory(trim(form.foldername))>
				<cfset request.isError=1>
				<cfset request.errorMsg=request.errorMsg&"<li>A valid Directory Name is required.</li>">
			</cfif>
		</cfif>
		<cfif request.isError>
			<cfset request.formaction="catform">
			<cfmodule template="filemanager.cfm">
		<cfelse><!--- Display data for confirmation --->
		<cfmodule template="#application.customTagPath#/htmlshell.cfm" css="site.css,admintools.css" title="File Manager" bgcolor="e6e6e6" padding="8">
			<cfoutput>
				<div align="center">
						<table width="400">
						<tr>
							<td colspan="2" class="toolheader">Please Confirm Category Info</td>
						</tr>
						<tr>
							<td colspan="2" class="formconfirminput"><font size="-1">Review the information you entered. If everything is correct, post your changes, if not, use the "Cancel" button to return to the form.</font></td>
						</tr>
						<tr>
							<td class="formconfirmlabel">Category Title: </td>
							<td class="formconfirminput">#form.uploadcategorytitle#</td>
						</tr>
						<tr>
							<td class="formconfirmlabel">Category Description: </td>
							<td class="formconfirminput">#form.uploadcategorydescription#</td>
						</tr>
						<tr>
							<td class="formconfirmlabel">Parent Category: </td>
							<td class="formconfirminput">#listLast(form.parentid, "|")#</td>
						</tr>
						<cfif isDefined("request.iconUUID")>
							<tr>
								<td class="formconfirmlabel">Icon: </td>
								<td class="formconfirminput" valign="top"><img src="/uploads/99999_temp/#request.iconUUID#.#cffile.clientFileExt#" border="0"></td>
							</tr>
						</cfif>
						<tr>
							<td colspan="2" align="center" class="formconfirminput">
							<form action="/admintools/core/filemanager/index.cfm" method="get" target="#thisTarget#">
							<cfif isDefined("request.iconUUID")>
								<input type="hidden" name="iconFile" value="#request.iconUUID#.#cffile.clientFileExt#">
							</cfif>
							<cfset form.parentid=listFirst(form.parentid, "|")>
							<!--- use custom tag to pass hidden form fields --->
							<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="icon">
							<input type="hidden" name="formaction" value="cataction">
							<input type="submit" value="Post" name="submit" class="submitbuttonsmall">
							<input type="button" value="Cancel" onclick="javascript:history.go(-1);" class="submitbuttonsmall"  style="width: 60px;">
							</form>
							</td>
						</tr>
						</table>
						</div>
					</cfoutput>
				</cfmodule>
		</cfif>
		<!--- Close test for Delete --->
	</cfif>
</cfcase>

<!--- [ADD/EDIT/REMOVE CATEGORY] --->
<cfcase value="cataction">
<cfparam name="form.uploadcategoryid" default="0">
<cfparam name="url.uploadcategoryid" default="0">
	<!--- get new id to write folder name, add record, create folder --->
		<!--- db stuff --->
		<cfif url.uploadcategoryid EQ 0 AND NOT isDefined("url.delete")>
			<cftransaction>
				<cfquery name="q_addnewcategory" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				INSERT INTO uploadcategory
					(uploadcategorytitle, uploadcategorydescription, parentid, ordinal)
				VALUES
					('#url.uploadcategorytitle#', '#url.uploadcategorydescription#', #listFirst(url.parentid,"|")#, #url.ordinal#)
				</cfquery>
				<cfquery name="q_getnewid" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT max(uploadcategoryid) AS thisid FROM uploadcategory
				</cfquery>
				<cfquery name="q_updatenewfile" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE uploadcategory SET foldername='#q_getnewid.thisid#_#url.foldername#' WHERE uploadcategoryid=#q_getnewid.thisid#
				</cfquery>
				<cfset catname="#q_getnewid.thisid#_#url.foldername#">
			</cftransaction>
			<!--- add folder --->
			<cfdirectory action="CREATE"
	             directory="#request.thisDirectory#\#catname#">
			<cfset request.success="<li>You have successfully added the #url.uploadcategorytitle# category.</li>">
			<!--- Move uploaded icon into this new directory and give standard 'catIcon.*' name --->
			<cfif isDefined("iconFile")>
				<cffile action="MOVE"
						source="#request.tempDirectory#\#trim(iconFile)#"
						destination="#request.thisDirectory#\#catname#\catIcon.#listLast(trim(iconFile),".")#">
				</cfif>
		<cfelse>
			<cfif isDefined("url.delete")>
			<!--- Delete this category  --->
				<!--- move all files to temp dir --->
				<cfquery datasource="#application.datasource#" name="q_getremovelist" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT u.uploadid,u.filename,uc.foldername
					FROM upload u RIGHT OUTER JOIN uploadcategory uc ON u.uploadcategoryid=uc.uploadcategoryid
					WHERE uc.uploadcategoryid=#url.uploadcategoryid#
				</cfquery>
				<!--- Loop over files to be removed --->
				<cfloop query="q_getremovelist">
				<!--- reset all files to inactive and change category to 99999 (recycle bin) --->
					<cfif Len(q_getremovelist.uploadid)>
						<cfquery datasource="#application.datasource#" name="q_setflags" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							UPDATE upload
							SET active=0, uploadcategoryid=99999
							WHERE uploadid=#q_getremovelist.uploadid#
						</cfquery>
						<cffile action="MOVE"
							source="#request.thisDirectory#\#q_getremovelist.foldername#\#q_getremovelist.filename#"
							destination="#request.tempDirectory#\#q_getremovelist.filename#">
					</cfif>	
				</cfloop>
				<!--- If icon file in this folder, move it into the trash --->
				<cfif fileExists("#request.thisDirectory#\#q_getremovelist.foldername#\catIcon.gif")>
					<cffile action="MOVE"
							source="#request.thisDirectory#\#q_getremovelist.foldername#\catIcon.gif"
							destination="#request.tempDirectory#\catIcon#UPLOADCATEGORYID#.gif">
				</cfif>
				<cfif fileExists("#request.thisDirectory#\#q_getremovelist.foldername#\catIcon.jpg")>
					<cffile action="MOVE"
							source="#request.thisDirectory#\#q_getremovelist.foldername#\catIcon.jpg"
							destination="#request.tempDirectory#\catIcon#UPLOADCATEGORYID#.jpg">
				</cfif>
				<!--- reset all categories' parentids --->
				<cfquery datasource="#application.datasource#" name="q_getaffectedcategories" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT uploadcategoryid
					FROM uploadcategory
					WHERE parentid=#url.uploadcategoryid#
				</cfquery>
				<cfloop query="q_getaffectedcategories">
					<cfquery datasource="#application.datasource#" name="q_updateaffectedcategories" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						UPDATE uploadcategory
						SET parentid=100000
						WHERE uploadcategoryid=#q_getaffectedcategories.uploadcategoryid#
					</cfquery>
				</cfloop>
				<!--- Query for foldername to delete --->
				<cfquery datasource="#application.datasource#" name="q_getfolder" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT foldername
					FROM uploadcategory
					WHERE uploadcategoryid=#url.uploadcategoryid#
				</cfquery>
				<!--- delete directory --->
				<cfdirectory action="DELETE"
				             directory="#request.thisDirectory#\#q_getfolder.foldername#">
				<!--- remove dir from db --->
				<cfquery datasource="#application.datasource#" name="q_deletethiscategory" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					DELETE FROM uploadcategory
					WHERE uploadcategoryid=#url.uploadcategoryid#
				</cfquery>

				<!--- clear url, and start all over --->
				<cfset killform=structClear(url)>
				<cfset request.formaction="fileform">
			<cfelse>
				<!--- Update This Category --->
				<cfquery name="q_updatecategory" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE uploadcategory
					SET
						uploadcategorytitle='#url.uploadcategorytitle#',
						uploadcategorydescription='#url.uploadcategorydescription#',
						parentid=#listFirst(url.parentid,"|")#,
						foldername='#url.uploadcategoryid#_#url.foldername#'
					WHERE
						uploadcategoryid=#url.uploadcategoryid#
				</cfquery>
				<!--- rename folder --->
				<!--- find old directoryname --->
				<cfdirectory action="LIST"
		             directory="#request.thisDirectory#"
		             name="q_oldDirname"
		             filter="#url.uploadcategoryid#*">
				<cfif q_oldDirname.Name NEQ "#url.uploadcategoryid#_#url.foldername#">
					<!--- rename this directory to the new name --->
					<cfdirectory action="RENAME"
			             directory="#request.thisDirectory#\#q_oldDirname.Name#"
			             newdirectory="#request.thisDirectory#\#url.uploadcategoryid#_#url.foldername#">
				</cfif>
				<!--- Move uploaded icon into this new directory and give standard 'catIcon.*' name --->
				<cfif isDefined("iconFile")>
					<cffile action="MOVE"
							source="#request.tempDirectory#\#trim(iconFile)#"
							destination="#request.thisDirectory#\#url.uploadcategoryid#_#url.foldername#\catIcon.#listLast(trim(iconFile),".")#">
				</cfif>
				<cfset request.success="<li>You have successfully modified the #url.uploadcategorytitle# category.</li>">
			</cfif>
		</cfif>
	<!--- send back, show success --->
	<cfset request.formaction="catform">
	<cfset killform=structClear(form)>
	<cfmodule template="filemanager.cfm">

</cfcase>
<cfdefaultcase>
	<cflocation url="#request.page#?formaction=#defaultaction#">
</cfdefaultcase>

</cfswitch>
</cfif>