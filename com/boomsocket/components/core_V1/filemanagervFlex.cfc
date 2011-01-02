<cfcomponent displayname='filemanagerv2' hint='backend for filemanager v2'>
<!--- DATABASE FUNCTIONS --->
	<!--- get child directories --->
	<cffunction name='getCategoriesData' displayname='Get Categories' hint='Get upload categories' access='public' returntype='query' output='false'>
		<cfargument name="parentid" hint="The category to retrieve children for" required="no" displayname="Parent ID">
		<cfargument name="uploadcategoryid" hint="Get data on a specific Category" required="no" displayname="Category ID">
		<cfargument name="dataSource" required="no" default="#APPLICATION.dataSource#" >
		<cfif (NOT isDefined('APPLICATION.datasource')) AND isDefined('ARGUMENTS.dataSource')>
			<cfset APPLICATION.datasource = ARGUMENTS.dataSource>
		</cfif>
		<cftry>
			<cfquery name="q_getcategories" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT uploadcategoryid, uploadcategorytitle, uploadcategorydescription, ordinal, parentid, foldername
				FROM uploadcategory
				<cfif IsDefined('arguments.parentid') AND arguments.parentid NEQ 0>WHERE parentid=#arguments.parentid#
				<cfelseif IsDefined('arguments.uploadcategoryid')>WHERE uploadcategoryid=#arguments.uploadcategoryid#</cfif>
				ORDER BY uploadcategorytitle ASC
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getcategories>
	</cffunction>
	
	<cffunction access="public" name="getFilesForCategory" output="false" returntype="query" displayname="get Files For Category">
		<cfargument name="categoryID" type="numeric" required="yes" displayname="Upload Category ID">
		<cfargument name="fileNameSearch" type="string" required="Yes" displayname="File Name Search" default="">
		<cfargument name="sortby" type="string" required="yes" displayname="Sort By">
		<cfargument name="dataSource" required="no" default="#APPLICATION.dataSource#" >
		<cfif (NOT isDefined('APPLICATION.datasource')) AND isDefined('ARGUMENTS.dataSource')>
			<cfset APPLICATION.datasource = ARGUMENTS.dataSource>
		</cfif>
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getfiles" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT
					u.uploadtitle,
					u.uploaddescription,
					u.uploadid,
					u.filesize,
					u.datemodified,
					u.filetype,
					u.filename,
					u.uploadcategoryid,
					'/uploads/'+uc.foldername+'/'+u.filename AS filepath
				FROM
					upload u LEFT JOIN
						uploadcategory uc ON u.uploadcategoryid = uc.uploadcategoryid
				WHERE 0=0
					<cfif arguments.categoryID NEQ 0> AND (u.uploadcategoryid = #arguments.categoryID#)</cfif>
				<cfif isDefined("arguments.fileNameSearch") AND len(trim(arguments.fileNameSearch))>
				AND ((u.uploadtitle LIKE '%#arguments.fileNameSearch#%') OR (u.uploaddescription LIKE '%#arguments.fileNameSearch#%'))
				</cfif>
				ORDER BY #listFirst(arguments.sortby)# #listLast(arguments.sortby)#
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getfiles>
	</cffunction>

	<cffunction access="public" name="getFileData" output="false" returntype="query" displayname="get File Data">
		<cfargument name="uploadID" type="numeric" required="no" displayname="Upload ID">
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getfileinfo" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT upload.*, '/uploads/'+uploadcategory.foldername+'/'+upload.filename AS filepath
				FROM upload INNER JOIN uploadcategory ON upload.uploadcategoryid = uploadcategory.uploadcategoryid
				<cfif IsDefined('arguments.uploadid') AND Len(Trim(arguments.uploadid))>WHERE upload.uploadid = #arguments.uploadid#</cfif>
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getfileinfo>
	</cffunction>

	<cffunction access="public" name="checkForDirChange" output="false" returntype="query" displayname="check For Dir Change">
		<cfargument name="uploadID" type="numeric" required="yes" displayname="Upload ID">
		<cftry>
			<!--- check to see if the file is getting a new directory --->
			<cfquery name="q_dirchangecheck" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT u.uploadcategoryid, uc.foldername, u.filetype
				FROM upload as u, uploadcategory as uc
				WHERE u.uploadcategoryid=uc.uploadcategoryid
				AND u.uploadid=#arguments.uploadid#
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_dirchangecheck>
	</cffunction>
	
	<cffunction access="public" name="moveFile" output="false" returntype="boolean" displayname="Move File">
		<cfargument name="uploadID" type="numeric" required="yes" displayname="UploadID">
		<cfargument name="newDirID" type="numeric" required="yes" displayname="New Directory ID">
		<cfset var thisFileData = getFileData(arguments.uploadid)>
		<cfset var thisNewDirData = getCategoriesData(uploadcategoryid=newDirID)>
		<cfset var thisOldDirData = getCategoriesData(uploadcategoryid=thisFileData.uploadcategoryid)>
		<cfset var thisFileName = thisFileData.filename>
		<cfset var thisOldDirectory = thisOldDirData.foldername>
		<cfset var thisNewDirectory = thisNewDirData.foldername>
		<cfset var returnThis = true>
		<cftry>
			<cffile action="move" destination="\#application.installPath#\uploads\#thisNewDirectory#" source="\#application.installPath#\uploads\#thisOldDirectory#\#thisFileName#">
			<cfset thumbName="#application.installpath#\uploads\#getCategoriesData(uploadcategoryid=thisFileData.uploadcategoryid).foldername#\#thisFileData.uploadid#_thumb.#thisFileData.filetype#">
			<cfif fileExists("#thumbName#")>
				<cffile action="move" destination="\#application.installPath#\uploads\#thisNewDirectory#" source="#thumbName#">
			</cfif>
			<cftry>
				<cfquery datasource="#APPLICATION.datasource#" name="q_updateFileDir" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE upload
					SET uploadCategoryID = #thisNewDirData.uploadCategoryID#
					WHERE filename = '#thisFileName#'
				</cfquery>
				<cfcatch type="database">
					<cfrethrow>
					<cfset returnThis = false>
				</cfcatch>
			</cftry>
			<cfcatch type="any">
				<cfrethrow>
				<cfset returnThis = false>
			</cfcatch>
		</cftry>
		<cfreturn returnThis>
	</cffunction>

	<cffunction access="public" name="updateFileQuery" output="false" returntype="boolean" displayname="Update File">
		<cfargument name="uploadtitle" type="string" required="yes" default="" displayname="uploadtitle">
		<cfargument name="uploaddescription" type="string" required="no" default="" displayname="uploaddescription">
		<cfargument name="active" type="string" required="no" default="1" displayname="active">
		<cfargument name="filename" type="string" required="no" displayname="filename">
		<cfargument name="uploadcategoryid" type="numeric" required="yes" displayname="uploadcategoryid">
		<cfargument name="filesize" type="string" required="no" displayname="filesize">
		<cfargument name="extension" type="string" required="no" displayname="extension">
		<cfargument name="uploadid" type="numeric" required="yes" displayname="uploadid">
		<cfset var returnThis = true>
		<cfset var argumentCount = 0>
		<cfset var q_getCurrentFolder = "">
		<cfif IsDefined('arguments.uploadtitle') AND Len(Trim(arguments.uploadtitle))>
			<cfset argumentCount = argumentCount+1>
		</cfif>
		<cfif IsDefined('arguments.uploaddescription') AND Len(Trim(arguments.uploaddescription))>
			<cfset argumentCount = argumentCount+1>
		</cfif>
		<cfif IsDefined('arguments.active') AND Len(Trim(arguments.active))>
			<cfset argumentCount = argumentCount+1>
		</cfif>
		<cfif IsDefined('arguments.filename') AND Len(Trim(arguments.filename))>
			<cfset argumentCount = argumentCount+1>
		</cfif>
		<cfif IsDefined('arguments.uploadcategoryid') AND Len(Trim(arguments.uploadcategoryid))>
			<cfset argumentCount = argumentCount+1>
		</cfif>
		<cfif IsDefined('arguments.filesize') AND Len(Trim(arguments.filesize))>
			<cfset argumentCount = argumentCount+1>
		</cfif>
		<cfif IsDefined('arguments.extension') AND Len(Trim(arguments.extension))>
			<cfset argumentCount = argumentCount+1>
		</cfif>
		<cfif IsDefined('arguments.uploadid') AND Len(Trim(arguments.uploadid))>
			<cfset argumentCount = argumentCount+1>
		</cfif>
		<cfquery name="q_getCurrentFolder" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT uploadcategoryid FROM upload WHERE uploadid = #arguments.uploadid#
		</cfquery>
		<cfif q_getCurrentFolder.uploadcategoryid NEQ arguments.uploadcategoryid>
			<cfset moveFile(arguments.uploadid, arguments.uploadcategoryid)>
		</cfif>
		<cftry>
			<cfquery name="q_addnewfile" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE upload
				SET 
				<cfif IsDefined('arguments.uploadtitle') AND Len(Trim(arguments.uploadtitle))>
					uploadtitle = '#trim(arguments.uploadtitle)#',
				</cfif>
				<cfif IsDefined('arguments.uploaddescription') AND Len(Trim(arguments.uploaddescription))>
					uploaddescription = '#trim(arguments.uploaddescription)#',
				</cfif>
				<cfif IsDefined('arguments.active') AND Len(Trim(arguments.active))>
					active = #trim(arguments.active)#,
				</cfif>
				<cfif IsDefined('arguments.filename') AND Len(Trim(arguments.filename))>
					filename = '#arguments.filename#',
				</cfif>
				<cfif IsDefined('arguments.uploadcategoryid') AND Len(Trim(arguments.uploadcategoryid))>
					uploadcategoryid = #trim(arguments.uploadcategoryid)#,
				</cfif>
				<cfif IsDefined('arguments.filesize') AND Len(Trim(arguments.filesize))>
					filesize = '#trim(arguments.filesize)#',
				</cfif>
				<cfif IsDefined('arguments.extension') AND Len(Trim(arguments.extension))>					
					filetype='#arguments.extension#',
				</cfif>
					datemodified = #CreateODBCDateTime(Now())#
				WHERE uploadid = #trim(arguments.uploadid)#
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
					<cfset returnThis = false>
				</cfcatch>
		</cftry>
		<cfreturn returnThis>
	</cffunction>
	
	<cffunction access="public" name="addNewFileQuery" output="false" returntype="numeric" displayname="add New File">
		<cfargument name="uploadtitle" type="string" required="yes" displayname="uploadtitle">
		<cfargument name="uploaddescription" type="string" required="yes" default="" displayname="uploaddescription">
		<cfargument name="active" type="string" required="yes" displayname="active">
		<cfargument name="filename" type="string" required="yes" displayname="filename">
		<cfargument name="uploadcategoryid" type="numeric" required="yes" displayname="uploadcategoryid">
		<cfargument name="filesize" type="string" required="yes" displayname="filesize">
		<cfargument name="extension" type="string" required="yes" displayname="extension">
		<cfargument name="runUpdate" type="boolean" required="yes" default="yes" displayname="Run Update">
		<cfset var returnThis = "">
		<cftry>
			<cftransaction>
				<cfquery name="q_addnewfile" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				INSERT INTO upload
					(uploadtitle, uploaddescription, active, filename, uploadcategoryid, filesize, datemodified, filetype)
				VALUES
					('#trim(arguments.uploadtitle)#', '#trim(arguments.uploaddescription)#', #trim(arguments.active)#, '#arguments.filename#', #trim(arguments.uploadcategoryid)#, '#trim(arguments.filesize)#', #CreateODBCDateTime(Now())#, '#arguments.extension#')
				</cfquery>
				<cfif arguments.runUpdate>
					<cfquery name="q_getnewid" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT max(uploadid) AS thisid FROM upload
					</cfquery>
					<cfquery name="q_updatenewfile" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						UPDATE upload SET filename='#q_getnewid.thisid#.#arguments.extension#' WHERE uploadid=#q_getnewid.thisid#
					</cfquery>
				</cfif>
			</cftransaction>
				<cfset returnThis = q_getnewid.thisid>
				<cfcatch type="database">
					<cfrethrow>
					<cfset returnThis = 0>
				</cfcatch>
		</cftry>
		<cfreturn returnThis>
	</cffunction>
	
	<cffunction access="public" name="deleteFileQuery" output="false" returntype="boolean" displayname="delete File">
		<cfargument name="uploadid" type="numeric" required="yes" displayname="uploadid">
		<cfset var returnThis = true>
		<cfset var thisFileData = getFileData(arguments.uploadid)>
		<cfset var thisCatData = getCategoriesData(uploadcategoryid=thisFileData.uploadcategoryid)>
		<cfif thisFileData.uploadcategoryid EQ '99999'>
			<cftry>
				<!--- We have to delete the file off the server before we can remove it from the DB --->
				<cffile action="delete" file="#APPLICATION.installpath#\uploads\99999_temp\#thisFileData.filename#">
				<cfset thumbName="#application.installpath#\uploads\#getCategoriesData(uploadcategoryid=thisFileData.uploadcategoryid).foldername#\#thisFileData.uploadid#_thumb.#thisFileData.filetype#">
				<cfif fileExists("#thumbName#")>
					<cffile action="delete" file="#thumbName#">
				</cfif>
				<cfquery name="q_deletefile" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					DELETE FROM upload
					WHERE uploadid=#arguments.uploadid#
				</cfquery>
					<cfcatch type="any">
						<cfrethrow>
						<cfset returnThis = false>
					</cfcatch>
			</cftry>
		<cfelse>
			<!--- This is the first time this file has been requested to be deleted so we are just moving it to the recycle bin --->
			<cftry>
				<cfset returnThis = updateFileQuery(uploadid=arguments.uploadid,uploadcategoryid='99999')>
				<!---<cffile action="move" destination="#APPLICATION.installpath#\uploads\99999_temp\" source="#APPLICATION.installpath#\uploads\#thisCatData.foldername#\#thisFileData.filename#">--->
				<cfcatch type="any">
					<cfrethrow>
					<cfset returnThis = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfreturn returnThis>
	</cffunction>

	<cffunction access="public" name="addNewCategory" output="false" returntype="string" displayname="add New Category">
		<cfargument name="uploadcategorytitle" type="string" required="yes" displayname="uploadcategorytitle" default="">
		<cfargument name="uploadcategorydescription" type="string" required="yes" displayname="uploadcategorydescription" default="">
		<cfargument name="parentid" type="numeric" required="yes" displayname="parentid" default="">
		<cfargument name="ordinal" type="string" required="no" displayname="ordinal" default=0>
		<cfargument name="foldername" type="string" required="yes" displayname="foldername" default="">
		<cfset var returnThis = "">
		<cfset var createDir = "">
		<cftry>
			<cftransaction>
				<cfquery name="q_addnewcategory" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				INSERT INTO uploadcategory
					(uploadcategorytitle, uploadcategorydescription, parentid, ordinal)
				VALUES
					('#arguments.uploadcategorytitle#', '#arguments.uploadcategorydescription#', #listFirst(arguments.parentid,"|")#, #arguments.ordinal#)
				</cfquery>
				<cfquery name="q_getnewid" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT max(uploadcategoryid) AS thisid FROM uploadcategory
				</cfquery>
				<cfquery name="q_updatenewfile" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE uploadcategory SET foldername='#q_getnewid.thisid#_#arguments.foldername#' WHERE uploadcategoryid=#q_getnewid.thisid#
				</cfquery>
			</cftransaction>
				<cfset returnThis="#q_getnewid.thisid#_#arguments.foldername#">
				<cfset createDir = createCategoryDirectory(returnThis)>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn returnThis>
	</cffunction>
	
	<cffunction access="private" name="createCategoryDirectory" output="false" returntype="boolean" displayname="Create Category Directory">
		<cfargument name="dirToCreate" type="string" required="yes" displayname="Directory To Create">
		<cfset var returnThis = false>
		<cftry>
			<cfif NOT DirectoryExists('\#APPLICATION.installpath#\uploads\#arguments.dirToCreate#')>
				<cfdirectory directory="\#APPLICATION.installpath#\uploads\#arguments.dirToCreate#" action="create">
				<cfset returnThis = true>
			</cfif>
			<cfcatch type="any">
				<cfrethrow>				
			</cfcatch>
		</cftry>
		<cfreturn returnThis>
	</cffunction>
	
	<cffunction access="private" name="deleteCategoryDirectory" output="false" returntype="string" displayname="Create Category Directory">
		<cfargument name="dirToDelete" type="string" required="yes" displayname="Directory To Create">
		<cfset var returnThis = "">
		<cfreturn returnThis>
	</cffunction>

	<cffunction access="public" name="updatecategoryQuery" output="false" returntype="boolean" displayname="update category query">
		<cfargument name="uploadcategorytitle" type="string" required="no" displayname="uploadcategorytitle">
		<cfargument name="uploadcategorydescription" type="string" required="no" displayname="uploadcategorydescription">
		<cfargument name="parentid" type="numeric" required="no" displayname="parentid">
		<cfargument name="foldername" type="string" required="no" displayname="foldername">
		<cfargument name="uploadcategoryid" type="numeric" required="yes" displayname="uploadcategoryid">
		<cfset var returnThis = true>
		<cfset var argumentCount = 0>
		<cfif IsDefined('arguments.uploadcategorytitle') AND Len(Trim(arguments.uploadcategorytitle))>
			<cfset arguments.uploadcategorytitle = replace(arguments.uploadcategorytitle,"'","''","ALL")>
		</cfif>
		<cfif IsDefined('arguments.uploadcategorydescription') AND Len(Trim(arguments.uploadcategorydescription))>
			<cfset arguments.uploadcategorydescription = replace(arguments.uploadcategorydescription,"'","''","ALL")>
		</cfif>
		<cfif IsDefined('arguments.parentid') AND Len(Trim(arguments.parentid))>
			<cfset argumentCount = argumentCount+1>
		</cfif>
		<cfif IsDefined('arguments.foldername') AND Len(Trim(arguments.foldername))>
			<cfset arguments.foldername = replace(arguments.foldername,"'","''","ALL")>
		</cfif>
		<cfif IsDefined('arguments.uploadcategoryid') AND Len(Trim(arguments.uploadcategoryid))>
			<cfset argumentCount = argumentCount+1>
		</cfif>
		<cfquery name="q_getOldDirName" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT foldername FROM uploadcategory WHERE uploadcategoryid=#arguments.uploadcategoryid#
		</cfquery>
		<cfif q_getOldDirName.recordcount NEQ 0 AND q_getOldDirName.foldername NEQ arguments.foldername>
			<cfset updateCategorySystem(q_getOldDirName.foldername, arguments.foldername)>
		</cfif>
		<cftry>
			<cfset setvalues="">
			<cfif IsDefined('arguments.uploadcategorytitle') AND Len(Trim(arguments.uploadcategorytitle))>
				<cfset setvalues=listAppend(setvalues,"uploadcategorytitle='#arguments.uploadcategorytitle#'")>
			</cfif>
			<cfif IsDefined('arguments.uploadcategorydescription') AND Len(Trim(arguments.uploadcategorydescription))>
				<cfset setvalues=listAppend(setvalues,"uploadcategorydescription='#arguments.uploadcategorydescription#'")>
			</cfif>
			<cfif IsDefined('arguments.parentid') AND Len(Trim(arguments.parentid))>
				<cfset setvalues=listAppend(setvalues,"parentid=#arguments.parentid#")>
			</cfif>
			<cfif IsDefined('arguments.foldername') AND Len(Trim(arguments.foldername))>
				<cfset setvalues=listAppend(setvalues,"foldername='#arguments.foldername#'")>
			</cfif>

			<cfquery name="q_updatecategory" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE uploadcategory
				SET #preservesinglequotes(setvalues)#
				WHERE uploadcategoryid=#arguments.uploadcategoryid# 
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
					<cfset returnThis = false>
				</cfcatch>
		</cftry>
		<cfreturn returnThis>
	</cffunction>
	
	<cffunction access="public" name="getRemoveList" output="false" returntype="query" displayname="get Remove List">
		<cfargument name="uploadcategoryid" type="numeric" required="yes" displayname="uploadcategoryid">
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getremovelist" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT u.uploadid,u.filename,uc.foldername
				FROM upload u RIGHT OUTER JOIN uploadcategory uc ON u.uploadcategoryid=uc.uploadcategoryid
				WHERE uc.uploadcategoryid=#arguments.uploadcategoryid#
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getremovelist>
	</cffunction>

	<cffunction access="public" name="setflags" output="false" returntype="boolean" displayname="set Flags">
		<cfargument name="uploadid" type="numeric" required="yes" displayname="uploadid">
		<cfset returnThis = true>
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_setflags" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE upload
				SET active=0, uploadcategoryid=99999
				WHERE uploadid=#arguments.uploadid#
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
					<cfset returnThis = false>
				</cfcatch>
		</cftry>
		<cfreturn returnThis>
	</cffunction>

	<cffunction access="public" name="deleteCategory" output="false" returntype="string" displayname="deleteCategory">
		<cfargument name="uploadcategoryid" type="numeric" required="yes" displayname="uploadcategoryid">
		<cfset var returnThis = "">
		<cfset var thisCatData = "">
		<!--- First we need to find out the parent of this Category --->
		<cfset thisCatData = getCategoriesData(uploadcategoryid=arguments.uploadcategoryid)>
		<cfif thisCatData.parentID EQ '99999'>
			<!--- this folder is already in the recycle bin --->
			<cftry>
				<cftransaction>
					<cfquery datasource="#application.datasource#" name="q_deletethiscategory" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						DELETE FROM uploadcategory
						WHERE uploadcategoryid=#arguments.uploadcategoryid#
					</cfquery>
					<cfquery datasource="#application.datasource#" name="q_deleteFilesInCategory" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						DELETE FROM upload
						WHERE uploadcategoryid=#arguments.uploadcategoryid#
					</cfquery>
				</cftransaction>
					<cfdirectory directory="\#APPLICATION.installpath#\uploads\#thisCatData.foldername#" action="delete" recurse="yes">
					<cfcatch type="database">
						<cfrethrow>
						<cfset returnThis = 'FAILED'>
					</cfcatch>
			</cftry>
			<cfset returnThis = 'deleted'>
		<cfelse>
			<!--- this folder isn't in the recycle bin so we need to move it there --->
			<cfset thefolder=getcategoriesData(uploadcategoryid=arguments.uploadcategoryid)>
			
			<cfset moveToRecycle = updatecategoryQuery(uploadcategoryid=arguments.uploadcategoryid, foldername=thefolder.foldername, parentid = '99999')>
			<cfset returnThis = 'moved'>
		</cfif>
		<cfreturn returnThis>
	</cffunction>

	<cffunction access="public" name="resetParent" output="false" returntype="boolean" displayname="reset Parent">
		<cfargument name="uploadcategoryid" type="numeric" required="yes" displayname="uploadcategoryid">
		<cfargument name="parentid" type="numeric" required="yes" displayname="parentid" default="100000">		
		<cfset returnThis = true>
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_updateaffectedcategories" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE uploadcategory
				SET parentid=#arguments.parentid#
				WHERE uploadcategoryid=#arguments.uploadcategoryid#
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
					<cfset returnThis = false>
				</cfcatch>
		</cftry>
		<cfreturn returnThis>
	</cffunction>
<!--- FILESYSTEM FUNCTIONS --->
	
<!--- 	<cffunction access="public" name="deleteFileSystem" output="false" returntype="boolean" displayname="delete File">
		<cfargument name="uploadid" type="numeric" required="yes" displayname="uploadid">
		<cfset var returnThis = true>
		<cfset var thisUpload = getFileData(arguments.uploadid)>
		<cftry>
			<cfif fileExists("#application.installpath##thisUpload.filepath#")>
				<cffile action="DELETE" file="#application.installpath##thisUpload.filepath#">
			</cfif>
			<cfif fileExists(replaceNoCase("#application.installpath##thisUpload.filepath#",".","_thumb."))>
				<cffile action="DELETE" file="#replaceNoCase("#application.installpath##thisUpload.filepath#",".","_thumb.")#">
			</cfif>
			<cfcatch type="any">
				<cfrethrow>
				<cfset returnThis = false>
			</cfcatch>
		</cftry>
		<cfreturn returnThis>
	</cffunction> --->
	
	<cffunction access="public" name="updateCategorySystem" output="false" returntype="boolean" displayname="update directory in filesytem">
		<cfargument name="oldfoldername" type="string" required="yes">
		<cfargument name="newfoldername" type="string" required="yes">
		<cfset var returnThis = true>
		<cfset var rootpath = "#application.installpath#\uploads\">
		<cftry>
			<cfif DirectoryExists("#rootpath##arguments.oldfoldername#") AND NOT DirectoryExists("#rootpath##arguments.newfoldername#")>
				<cfdirectory directory="#rootpath##arguments.oldfoldername#" action="rename" newdirectory="#rootpath##arguments.newfoldername#">
			<cfelse>
				<cfthrow message="Old dir #rootpath##arguments.oldfoldername# does not exist or new dir #rootpath##arguments.newfoldername# already exists.">
			</cfif>
			<cfcatch type="any">
				<cfrethrow>
				<cfset returnThis = false>
			</cfcatch>
		</cftry>
		<cfreturn returnThis>
	</cffunction>
	
	<cffunction access="public" name="createDirSystem" output="false" returntype="boolean" displayname="create directory in filesytem">
		<cfargument name="foldername" type="string" required="yes">
		<cfset var returnThis = true>
		<cfset var thisUpload = getFileData(arguments.uploadid)>
		<cftry>
			<cfif fileExists("#application.installpath##thisUpload.filepath#")>
				<cffile action="DELETE" file="#application.installpath##thisUpload.filepath#">
			</cfif>
			<cfif fileExists(replaceNoCase("#application.installpath##thisUpload.filepath#",".","_thumb."))>
				<cffile action="DELETE" file="#replaceNoCase("#application.installpath##thisUpload.filepath#",".","_thumb.")#">
			</cfif>
			<cfcatch type="any">
				<cfrethrow>
				<cfset returnThis = false>
			</cfcatch>
		</cftry>
		<cfreturn returnThis>
	</cffunction>

	<cffunction access="public" name="createThumbNail" output="false" returntype="void" displayname="Create a thumbnail">
		<cfargument name="filename" type="string" required="yes" displayname="filename" hint="Image to thumbnail-ize">
		<cfargument name="dirpath" type="string" required="yes" displayname="dirpath" hint="Location to save the thumbnail">
		<cfargument name="percent" type="any" required="yes" displayname="percent" hint="Percent of the original thumbnail will be">
	
		<!--- This instantiates the componenet, thereby creating an object for us to work with. --->
		<cfset var myImage = CreateObject("Component", "#APPLICATION.customtagpath#.imageComponent.Image").setKey('N5U5Q-M05BF-5Q7D9-VD6XK-21L8J') />

		<!--- Get the entension of the file we are uploading and the name of the file --->
		<cfset var thisfileName = #listFirst(arguments.filename, ".")#>
		<cfset var thisfileExtention = #listLast(arguments.filename, ".")#>

		<!--- Test to make sure this is an ok file. IE it's an image file. --->
		<!--- The getReadableFormats() function returns a list of ok formats to use. --->
		<cfif #ListFindNoCase(#myImage.getReadableFormats()#, #thisfileExtention#, ",")#>
			<!--- read the source image --->

			<cfset myImage.readImage("#arguments.dirpath#\#arguments.filename#") />

			<!--- resize the image to a specific width and height --->
			<cfset myImage.scalePercent(#arguments.percent#,#arguments.percent#) />
			
			<!--- output the image in it's original format with the new _thumbs added to the name. --->
			<cfset myImage.writeImage("#arguments.dirpath#\#thisfileName#_thumb.#thisfileExtention#", "#thisfileExtention#") />
			
			<!--- Dump it into the DB so you can use file manger --->
			<cfquery name="q_getfileData" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT *
				FROM upload
				WHERE filename = '#arguments.filename#'
			</cfquery>		
			<cfdirectory directory="#arguments.dirpath#" action="list" name="getThumbSize" filter="#thisfileName#_thumb.#thisfileExtention#" recurse="no">
			<!--- Commented out code to hid add thumb to DB for corev4 sites. We'll add this back in for coreV5 --->
			<!--- <cfset addThumbToDB = addNewFileQuery(uploadtitle='#q_getfileData.uploadtitle# Thumbnail',uploaddescription='#q_getfileData.uploaddescription#',active=1,filename='#thisfileName#_thumb.#thisfileExtention#',uploadcategoryid=q_getfileData.uploadcategoryid,filesize=getThumbSize.size,extension='#thisfileExtention#',runUpdate='no')> --->
		</cfif>
	</cffunction>
</cfcomponent>