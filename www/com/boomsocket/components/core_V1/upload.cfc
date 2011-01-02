<cffunction access="remote" name="getUploadCategories" output="false" returntype="query" displayname="getUploadCategories">
	<cftry>
		<cfquery name="q_getUploadCategories" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT uploadcategoryid, uploadcategorytitle, foldername, parentid
			FROM uploadcategory
		</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
	</cftry>
	<cfreturn q_getUploadCategories>
</cffunction>
<cffunction access="remote" name="getUploadFilesByCategory" output="false" returntype="query" displayname="getUploadFilesByCategory">
	<cfargument name="uploadcategoryid" type="numeric" required="yes">
	<cftry>
		<cfquery name="q_getUploadFilesByCategory" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT uploadid, uploadtitle, uploadcategoryid, filename, foldername, uploadpath
			FROM upload_view
			WHERE uploadcategoryid = #ARGUMENTS.uploadcategoryid#
			ORDER BY uploadtitle
		</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
	</cftry>
	<cfreturn q_getUploadFilesByCategory>
</cffunction>
<cffunction name="saveSecureUploadInfo" output="false" returntype="void" displayname="save_SecureUploadInfo">
	<cfargument name="uploadid" type="numeric" required="yes">
	<cfargument name="uploadpath" type="string" required="yes" default="">
	<cftry>
		<cfquery name="q_saveInfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			INSERT INTO secureupload (uploadid,dateuploaded,filepath) VALUES (#ARGUMENTS.uploadid#,#createODBCDateTime(Now())#,'#ARGUMENTS.uploadpath#')
		</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
	</cftry>
</cffunction>
<cffunction name="deleteSecureUploadInfo" output="false" returntype="void" displayname="delete_SecureUploadInfo">
	<cfargument name="secureuploadid" type="numeric" required="yes">
	<cftry>
		<cfquery name="q_deleteInfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			DELETE secureupload
			WHERE secureuploadid = #ARGUMENTS.secureuploadid#
		</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
	</cftry>
</cffunction>
<cffunction name="getSecureUploadInfo" output="false" returntype="query" displayname="get_SecureUploadInfo">
	<cfargument name="timeframe" type="string" required="no">
	<cfargument name="uploadid" type="numeric" required="no">
	<cfargument name="secureuploadid" type="numeric" required="no">
	<cftry>
		<cfquery name="q_getInfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT *
			FROM secureupload
			WHERE (1=1)
			<cfif isDefined('ARGUMENTS.timeframe')>
				AND dateuploaded < #ARGUMENTS.timeframe#
			</cfif>
			<cfif isDefined('ARGUMENTS.uploadid')>
				AND uploadid = #ARGUMENTS.uploadid#
			</cfif>
			<cfif isDefined('ARGUMENTS.secureuploadid')>
				AND secureuploadid = #ARGUMENTS.secureuploadid#
			</cfif>
		</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
	</cftry>
	<cfreturn q_getInfo>
</cffunction>
