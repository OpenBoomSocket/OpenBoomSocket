<cfif isDefined("URL.fileid") OR isDefined('URL.actualfile')>
	<cfif NOT directoryExists(#APPLICATION.installpath#&'/uploads/temp')>
		<cfdirectory action="create" directory="#APPLICATION.installpath#/uploads/temp">
	</cfif>
	<!--- use file id or actualfile name for backwards compatibility --->
	<cfif isDefined("URL.fileid")>
		<cfset thisfileid = URL.fileid>
	<cfelse>
		<cfset thisfileid = listFirst(URL.actualfile,'.')>
	</cfif>
	<!--- get file specific info  --->
	<cfquery name="q_fileDetails" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT upload.filename, upload.filetype, upload.uploadtitle, uploadcategory.foldername, upload.datemodified, upload.filesize
		FROM upload
			INNER JOIN uploadcategory ON uploadcategory.uploadcategoryid = upload.uploadcategoryid
		WHERE upload.uploadid = #thisfileid#
	</cfquery>
	<!--- set up to strip out unwanted characters and replace spaces ' ' with '_' --->
	<cfset filenameRE = "[" & "'" & '"' & "##" & "/\\%&`@~!,:;=<>\+\*\?\[\]\^\$\(\)\{\}\|]" />
	<cfset newfilename = reReplace(trim(q_fileDetails.uploadtitle),filenameRE,"","all") />
	<cfset newfilename = replace(newfilename," ","_","all") />
	
	<!--- define useful path stings --->
	<cfset oldFileFullPath = #APPLICATION.installpath#&'\uploads\'&#q_fileDetails.foldername#&'\'&#q_fileDetails.filename#>
	<cfset newFileFullPath = #APPLICATION.installpath#&'\uploads\temp\'&#newfilename#&'.'&#q_fileDetails.filetype#>
	<cfset newFileURL = #APPLICATION.installURL#&'/uploads/temp/'&#newfilename#&'.'&#q_fileDetails.filetype#>
	
	<!--- check /uploads/temp directory for existance of file --->
	<cfif fileExists(#newFileFullPath#)>
		<!--- get current directory info to make sure file hasn't changed --->
		<cfdirectory action="list" directory="#APPLICATION.installpath#\uploads\temp" name="dirlist">
		<cfset newFile = false>
		<!--- loop through files to find file of interest --->
		<cfloop query="dirlist">
			<cfset thisNameArr = structFindKey(dirlist,"NAME")>
			<cfset thisName = thisNameArr[1].value>
			<!--- check if this is the file of interest --->
			<cfif thisname EQ #newfilename#&'.'&#q_fileDetails.filetype#>
				<cfset thisDateArr = structFindKey(dirlist,"DATELASTMODIFIED")>
				<cfset thisDate = thisDateArr[1].value>
				<cfset thisSizeArr = structFindKey(dirlist,"SIZE")>
				<cfset thisSize = thisSizeArr[1].value>
				<!--- make sure modified date and file size haven't changed --->
				<cfif (dateDiff("s",thisDate,q_fileDetails.datemodified)  LT 0) OR (NOT (thisSize EQ q_fileDetails.filesize))>
					<cfset newFile = true>
				</cfif>
			</cfif>
		</cfloop>
		<!--- if something changed, copy correct file to temp folder --->
		<cfif newFile>
			<cffile action="delete" file="#newFileFullPath#" >
			<cffile action="copy" source="#oldFileFullPath#" destination="#newFileFullPath#" >
		</cfif>
		<!--- let browser handle download --->
		<cflocation url="#newFileURL#" addtoken="no">
	<!--- file hasn't been copied yet --->
	<cfelseif fileExists(#oldFileFullPath#)>
		<!--- copy file to temp folder --->
		<cffile action="copy" source="#oldFileFullPath#" destination="#newFileFullPath#" >
		<!--- let browser handle download --->
		<cflocation url="#newFileURL#" addtoken="no">
	</cfif>
	<!--- If all else fails (e.g. file doesn't exist) fail silently --->
</cfif>
