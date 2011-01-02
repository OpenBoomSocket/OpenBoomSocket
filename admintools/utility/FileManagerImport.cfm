
<!--- 
Filemanager Utility for importing files from a source folder within www of a site into a destination Filemanager folder within the uploads directory
Author: Ben Wakeman
Date: 4/4/2007
--->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>File Import</title>
<style type="text/css">
	body{
		font-family:Arial, Helvetica, sans-serif;
		font-size: 11px;
	}
	.formElement{

		margin-top: 5px;
	}
	#fileForm{
		margin:0 auto; 
		width:380px; 
		padding:15px;
		background-color:#f1f1f1; 
		border:1px solid #999999;
	}
	.errorBlock{
		color:#cc0000;
		padding: 15px;
		margin:0 auto;
		border: 1px solid #cc0000;
		width: 380px;
	}
</style>
</head>

<body>
<!--- 
<cfquery datasource="#APPLICATION.datasource#" name="q_getEm">
	SELECT uploadtitle, uploadid
	FROM upload
	WHERE uploadcategoryid = 100016
	ORDER BY uploadtitle ASC
</cfquery>
<cfdump var="#q_getEm#">
<cfloop query="q_getEm">
	<cfif isNumeric(listFirst(q_getEm.uploadtitle,"-"))>
		<cfquery datasource="#APPLICATION.datasource#" name="q_update">
			UPDATE property
			<cfif listLast(q_getEm.uploadtitle,"-") LTE 5>
				SET image#listLast(q_getEm.uploadtitle,"-")# = '#q_getEm.uploadid#'
				WHERE mlsnumber = #listFirst(q_getEm.uploadtitle,"-")#
			<cfelse>
				SET image1 = ''
				WHERE 0 = 1
			</cfif>
		</cfquery>
	</cfif>
</cfloop>
 --->

<cfparam name="FORM.sourcefolderpath" default="">
<cfparam name="FORM.targetFolder" default="">

<cfif len(trim(FORM.targetFolder)) AND len(trim(FORM.sourcefolderpath))>
	<cfset sourceFolderPath = "#APPLICATION.installpath#\#trim(FORM.sourceFolderPath)#">
	<cfset targetFolder = trim(FORM.targetFolder)>
	<cfif NOT directoryExists(sourceFolderPath)>
		<cfoutput>
			<div class="errorBlock">
				<h1>ERROR!</h1>
				<strong>The source folder path you specified: <strong>#sourceFolderPath#</strong> was not found beneath www of the site.</strong>
				<cfset isError = 1>
			</div>
		</cfoutput>
	</cfif>
	<cfif NOT directoryExists("#APPLICATION.installpath#\uploads\#targetFolder#")>
		<div class="errorBlock">
			<h1>ERROR!</h1>
			<strong>The filemanager folder you specified does not exist in www/uploads of the site.</strong>
			<cfset isError = 1>
		</div>
	</cfif>
	<!--- If source and destination are valid, proceed with script --->
	<cfif NOT isDefined("isError")>
		<cfset filemanagerObj = createObject("component","cfc.core_v1a.filemanagerv2")>
		<cfdirectory directory="#sourceFolderPath#" action="list" name="q_getFiles">
		<!--- <cfdump var="#q_getFiles#"> --->
		<cfloop query="q_getFiles">
			<cftransaction>
				<cfquery name="q_getNextID" datasource="#APPLICATION.datasource#">
					SELECT MAX(uploadid) AS nextID
					FROM upload
				</cfquery>
				<cfif q_getNextID.nextID eq "">
					<cfset newFile = 100000 & "." & listLast(q_getFiles.name,".")>
				<cfelse>
					<cfset newFile = val(q_getNextID.nextID + 1) & "." & listLast(q_getFiles.name,".")>
				</cfif>
				
				<cffile action="move" 
						source="#sourceFolderPath#\#q_getFiles.name#" 
						destination="#APPLICATION.installpath#\uploads\#targetFolder#\#newFile#">
				
				<cfquery name="q_insertFile" datasource="#APPLICATION.datasource#">
					INSERT INTO upload (uploadtitle, active, filename, uploadcategoryid, datemodified, filetype)
					VALUES ('#q_getFiles.name#', 1, '#newFile#', #listFirst(targetFolder,"_")#, #createODBCDateTime(now())#, '#listLast(q_getFiles.name,".")#')
				</cfquery>
				<!---
				<cfscript>
					filemanagerObj.createThumbNail(filename="#newFile#",dirpath="#APPLICATION.installpath#\uploads\#targetFolder#",imageThumbSize=90);
				</cfscript>
				--->
			</cftransaction>
		</cfloop>
		<cfdirectory directory="#APPLICATION.installpath#\uploads\#targetFolder#" action="list" name="q_getCopiedFiles">
		<h1>Import Successful</h1>
		Below are the contents of the target Upload directory you specified:
		<cfdump var="#q_getCopiedFiles#">
	</cfif>
<cfelse>
	<div class="errorBlock">
		<h1>ERROR!</h1>
		<strong>You must enter values for both fields!</strong>
	</div>
</cfif>
<!--- Display the Form --->
<cfoutput>
	<div id="fileForm">
		<form action="filemanagerimport.cfm" method="post">
			<div class="formElement">Source Folder in www:<br /><input type="text" size="50" name="sourcefolderpath" value="#trim(FORM.sourcefolderpath)#" /></div>
			<div class="formElement">Target Filemanger Folder in www\uploads:<br /><input type="text" size="50" name="targetFolder" value="#trim(FORM.targetFolder)#" /></div>
			<div class="formElement"><input type="submit" value="Submit" /></div>
		</form>
	</div>
</cfoutput>
</body>
</html>
