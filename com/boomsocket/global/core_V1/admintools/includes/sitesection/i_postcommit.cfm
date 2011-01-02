<!--- i_postcommit.cfm --->

<cfif NOT isDefined("form.DELETEINSTANCE")>
	<!--- Set section vars --->
	<cfif isDefined("form.instanceid")>
		<cfset sitesectionid=trim(form.instanceid)>
	<cfelse>
		<cfset sitesectionid=insertid>
	</cfif>
	<cfif NOT len(trim(form.sitesectionparent))>
		<cfset sitesectionparent=sitesectionid>
	</cfif>
	
	<cfif NOT len(trim(form.sitesectionparent))>
		<cfquery datasource="#application.datasource#" name="q_insertParent" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			UPDATE sitesection 
			SET sitesectionparent= #sitesectionid# 
			WHERE sitesectionid= #sitesectionid#
		</cfquery>
	</cfif>
	<!--- only perform these when inserting 1st time --->
	<cfif isDefined('insertid')>
		<!--- Add section permissions for DP user and default supervisor--->
		<cfquery datasource="#application.datasource#" name="q_insertPerms" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			INSERT INTO users_sections (userid,sitesectionid)
			VALUES (100000,#sitesectionid#)
		</cfquery>
		<!--- don't add 100000 a 2nd time --->
		<cfif application.supervisorid neq 100000>
			<cfquery datasource="#application.datasource#" name="q_insertSuperPerms" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				INSERT INTO users_sections (userid,sitesectionid)
				VALUES (#application.supervisorid#,#sitesectionid#)
			</cfquery>
		</cfif>
	</cfif>
	<!--- Create directory path for section --->
	<cfset dirPath="#application.installpath##application.slash##application.getSectionPath(sitesectionid,"true")#">
<cfelse>
	<!--- Delete all associated Javascript relationships --->
	<cfquery datasource="#application.datasource#" name="q_clear" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		DELETE FROM javascript_sitesection
		WHERE sitesectionid IN (#trim(deleteinstance)#)
	</cfquery>
	<!--- Delete section permissions--->
	<cfquery datasource="#application.datasource#" name="q_deletePerms" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		DELETE FROM users_sections
		WHERE sitesectionid IN (#trim(deleteinstance)#)
	</cfquery>
	<cfloop list="#deleteinstance#" index="XX">
		<cfset cssFilename = evaluate("session.cssFilename_#XX#")>
		<cfset tempvar=StructDelete(Session, "cssFilename_#XX#")>
		<cfif fileExists("#application.installpath##application.slash#css#application.slash#section#application.slash##cssFilename#.css")>
			<cffile action="delete" file="#application.installpath##application.slash#css#application.slash#section#application.slash##cssFilename#.css">
		</cfif>
	</cfloop>
</cfif>

<!--- Perform directory write/edit/move/delete actions --->
<cfif isDefined("form.instanceid")><!--- Rename/Move/Create the directory if necessary --->
	<cfif form.olddirpath NEQ dirPath>
		<cffile action="move" destination="#dirPath#" source="#olddirPath#">
		<cfif fileExists("#application.installpath##application.slash#css#application.slash#section#application.slash##ListLast(form.olddirpath,'\')#.css")>
			<cffile action="rename" source = "#application.installpath##application.slash#css#application.slash#section#application.slash##ListLast(form.olddirpath,'\')#.css"  destination = "#application.installpath##application.slash#css#application.slash#section#application.slash##application.getSectionPath(sitesectionid,"true")#.css">
		</cfif>
	</cfif>
<cfelseif isDefined('insertid')>
	<cfif NOT directoryExists(dirPath)>
		<cfdirectory action="CREATE" directory="#dirPath#">
		<!--- 3/2/07 DRK Create default index file --->
		<cffile action="write" file="#dirPath##application.slash#index.cfm" output="/*index.cfm File for #application.getSectionPath(sitesectionid,'true')# generated #dateFormat(now(),'m/d/yyyy')#*/">
		<!--- 3/2/07 DRK add page tool entry for this new page --->
		<cfif isDefined('FORM.createindexpage') AND FORM.createindexpage>
			<cfset FORM.datacreated = Now()>
			<cfset FORM.datamodified = Now()>
			<cfset FORM.pagename = "index.cfm">
			<cfset FORM.sitesectionid = #sitesectionid#>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
					 datasource="#application.datasource#"
					 tablename="page"
					 assignidfield="pageid">
			<cfset thispageid = insertid>
			<cfset form.datemodified = CreateODBCDateTime(now())>
			<cfset form.datecreated = CreateODBCDateTime(now())>
			<cfset form.navitemaddressname = '/'&application.getSectionPath(sitesectionid,"true")&'/'&form.pagename>
			<cfset form.formobjecttableid = 103>
			<cfset form.objectinstanceid = thispageid>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
				 datasource="#application.datasource#"
				 tablename="navitemaddress"
				 assignidfield="navitemaddressid">
			<cfset form.navitemaddressid = insertid>
			<cfset form.navitemname = form.sitesectionname>
			<cfset form.navgroupid = 100000>
			<cfset form.target = "_self">
			<cfset form.active = 1>
			<cfset form.pageid = thispageid>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
				 datasource="#application.datasource#"
				 tablename="navitem"
				 assignidfield="navitemid">
			<cfset form.navitemid = insertid>
			<cfset form.parentid = insertid>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE"
				 datasource="#application.datasource#"
				 tablename="navitem"
				 whereclause="navitemid=#trim(form.navitemid)#"
				 assignidfield="navitemid">
			<cfif NOT isDefined('APPLICATION.navObj') OR isDefined("URL.initializeApp")>
				<cfset APPLICATION.navObj = createObject("component","#APPLICATION.CFCPath#.navitem")>
			</cfif>
			<cfset application.allNavigation = APPLICATION.navObj.getAllNavigation()>
		</cfif>
		<!--- Create css file --->
		<cffile action="write" file="#application.installpath##application.slash#css#application.slash#section#application.slash##replaceNoCase(application.getSectionPath(sitesectionid,'true'),application.slash,'_')#.css" output="/*CSS File for #application.getSectionPath(sitesectionid,'true')# generated #dateFormat(now(),'m/d/yyyy')#*/">
	</cfif>
</cfif>
<!--- Reinitialize Page/Section Query --->
<cfscript>
	kill = createObject("Component","#application.cfcpath#.util.clearAppVars");
	kill.clearPageQuery();
</cfscript>
