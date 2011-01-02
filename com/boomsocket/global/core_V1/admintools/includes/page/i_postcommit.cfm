<!--- i_postcommit.cfm --->
<!--- get the dirPath --->
<cfif NOT isDefined("deleteinstance")>
	<cfset sitesectionid=listfirst(sitesectionid,"~")>
	<cfset dirPath="#application.installpath##application.slash##application.getSectionPath(sitesectionid,"true")##application.slash##form.pagename#">
	<cfif isDefined("instanceid")>
		<cfset thispageid=instanceid>
	<cfelse>
		<cfset thispageid=insertid>
	</cfif>
</cfif>

<!--- Perform file write/edit/move/delete actions --->
<cfif isDefined("deleteinstance")><!--- Delete This file, already been verified --->
	<cfloop list="#olddirpath#" index="thisDelFile">
		<!--- delete file --->
		<cfif fileExists("#thisDelFile#")>
			<cffile action="DELETE" file="#thisDelFile#">
		</cfif>
	</cfloop>
	<cfloop list="#deleteinstance#" index="x">
		<!--- delete entry from page --->
		<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE"
			 datasource="#application.datasource#"
			 tablename="page"
			 whereclause="pageid=#x#">
		<!--- delete from pagecomponent --->
		<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE"
			 datasource="#application.datasource#"
			 tablename="pagecomponent"
			 whereclause="pageid=#x#">
	</cfloop>
<cfelseif isDefined("form.instanceid") AND fileexists(form.olddirpath)><!--- Rename/Move/Create the file if necessary --->
	<cfif isDefined("form.olddirpath") AND (form.olddirpath NEQ dirPath)>
		<cffile action="move" destination="#dirPath#" source="#olddirPath#">
	</cfif>
<cfelse><!--- Create the New file if it's not there already --->
	<cfif NOT fileexists(dirPath)>
		<cffile action="WRITE" file="#dirPath#" output="<!--- #form.pagename# --->" addnewline="No">
	</cfif>
</cfif>

<!--- Reinitialize Page Query --->
<cfscript>
	kill = createObject("Component","#application.cfcpath#.util.clearAppVars");
	kill.clearPageQuery();
</cfscript>

<cfif NOT isDefined("deleteinstance")>
	<!--- if adding new page (if form.pageid = "")--->
	<cfif form.pageid eq "">
		<!--- create navigation entities --->
		<cfif isDefined('FORM.addtonav') AND Trim(FORM.addtonav)>
			<cfset form.datemodified = CreateODBCDateTime(now())>
			<cfset form.datecreated = CreateODBCDateTime(now())>
			<cfset form.navitemaddressname = '/'&application.getSectionPath(sitesectionid,"true")&'/'&form.pagetitle>
			<cfset form.formobjecttableid = 103>
			<cfset form.objectinstanceid = thispageid>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
				 datasource="#application.datasource#"
				 tablename="navitemaddress"
				 assignidfield="navitemaddressid">
			<cfset form.navitemaddressid = insertid>
			<cfset form.navitemname = form.pagetitle>
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
		<cfif isDefined('form.createbodycontent') AND form.createbodycontent eq 1>
		<!--- insert content element --->
			<!--- query for section, pagename --->
			<cfquery datasource="#application.datasource#" name="q_getContentName" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT p.pagetitle, s.sitesectionlabel
				FROM page p
					Inner Join sitesection s ON p.sitesectionid = s.sitesectionid
				Where pageid = #thispageid#
			</cfquery>
			<cfset form.contentobjectname = q_getContentName.sitesectionlabel & ": " & q_getContentName.pagetitle>
			<cfset form.contentobjectbody = "content pending">
			<cfset form.displayhandlerid = 100>			
		
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
			 datasource="#application.datasource#"
			 tablename="ContentObject"
			 assignidfield="contentobjectid">
			 <cfset variables.contentobjectid = insertid>
		
		
		<!--- insert version--->
			<!--- query for user's supervisor, if none set to main site sup --->
			<cfquery datasource="#application.datasource#" name="q_Supervisor" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT supervisorid
				FROM supervisorrelationship
				Where userid = #session.user.id#
			</cfquery>
			<cfif q_Supervisor.recordcount eq 0>got here
				<cfquery name="q_Supervisor" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					SELECT supervisorid FROM sitesettings
				</cfquery>
			</cfif>
			<cfset form.label = q_getContentName.sitesectionlabel & ": " & q_getContentName.pagetitle>
			<cfset form.parentid = insertid>
			<cfset form.instanceItemID = insertid>
			<cfset form.version = 1>
			<cfset form.ownerid = session.user.id>
			<cfset form.supervisorid = q_Supervisor.supervisorid>
			<cfset form.versionstatusid = 100002>
			<cfset form.creatorid = session.user.id>
			<cfset form.formobjectitemid = application.tool.contentobject>

			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
			 datasource="#application.datasource#"
			 tablename="version"
			 assignidfield="versionid">		
		
		<!--- insert version---> 
			<cfset form.containerid = form.containertoassign>
			<cfset form.displayhandlerid = 100>
			<cfset form.pageid = thispageid>
			<cfset form.contentobjectid = variables.contentobjectid>
			
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
			 datasource="#application.datasource#"
			 tablename="pagecomponent"
			 assignidfield="pagecomponentid">	
			 
			<!--- if form.editoncompletion then redirect to edit --->
			<cfif form.editoncompletion eq "1">
				<cflocation url="index.cfm?i3currenttool=#form.formobjectitemid#&instanceid=#form.instanceItemID#&displayForm=1&formstep=showform">
			</cfif>
		</cfif>
	</cfif>

	<!--- On to the pagecomponentwizard --->
	<cflocation url="#request.page#?i3currenttool=#application.tool.pagecomponentwizard#&editpageid=#thispageid#&pageFunction=showform" addtoken="No">
</cfif>
