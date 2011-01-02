<cfcomponent displayname='i3page' hint='Manages a page in i3sitetools' >
	<!--- init method --->
	<cffunction name='init' displayname='struct init()' hint='initialze the bean' access='public' returntype='struct' output='false'>
		<cfargument name='pageid' displayname='Page ID' hint='The id of the Page' type='numeric' required='no' default=0 />
		<cfargument name='sitesectionid' displayname='Site Section ID' hint='ID of the section page belongs to' type='numeric' required='no' default=0 />
		<cfargument name='templateid' displayname='Template ID' hint='ID of the template the page uses' type='numeric' required='no' default=0 />
		<cfargument name='pagename' displayname='Page Name' hint='Filename for the page' type='string' required='no' default='' />
		<cfargument name='pagetitle' displayname='Page Title' hint='Title of the page' type='string' required='no' default='' />
		<cfargument name='bgcolor' displayname='Background Color' hint='Color of the page background (hex)' type='string' required='no' default='' />
		<cfargument name='backgroundimage' displayname='Background Image' hint='Path to a background image' type='string' required='no' default='' />
		<cfargument name='physicalpagepath' displayname='Physical Page Path' hint='Path to page' type='string' required='no' default='' />
		<cfscript>
			variables.instance = structNew();
			variables.instance.pageid = arguments.pageid;
			variables.instance.sitesectionid = arguments.sitesectionid;
			variables.instance.templateid = arguments.templateid;
			variables.instance.pagename = arguments.pagename;
			variables.instance.pagetitle = arguments.pagetitle;
			variables.instance.bgcolor = arguments.bgcolor;
			variables.instance.backgroundimage = arguments.backgroundimage;
			variables.instance.physicalpagepath = arguments.physicalpagepath;
		</cfscript>
		<cfreturn this />
	</cffunction>

<!--- GETTER/SETTERS --->
	<cffunction name='getPageid' displayname='numeric getPageid()' hint='get the value of the pageid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.pageid />
	</cffunction>
	<cffunction name='setPageid' displayname='setPageid(numeric newPageid)' hint='set the value of the pageid property' access='public' output='false' returntype='void'>
		<cfargument name='newPageid' displayname='numeric newPageid' hint='new value for the pageid property' type='numeric' required='yes' />
		<cfset variables.instance.pageid = arguments.newPageid />
	</cffunction>
	<cffunction name='getSitesectionid' displayname='numeric getSitesectionid()' hint='get the value of the sitesectionid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.sitesectionid />
	</cffunction>
	<cffunction name='setSitesectionid' displayname='setSitesectionid(numeric newSitesectionid)' hint='set the value of the sitesectionid property' access='public' output='false' returntype='void'>
		<cfargument name='newSitesectionid' displayname='numeric newSitesectionid' hint='new value for the sitesectionid property' type='numeric' required='yes' />
		<cfset variables.instance.sitesectionid = arguments.newSitesectionid />
	</cffunction>
	<cffunction name='getTemplateid' displayname='numeric getTemplateid()' hint='get the value of the templateid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.templateid />
	</cffunction>
	<cffunction name='setTemplateid' displayname='setTemplateid(numeric newTemplateid)' hint='set the value of the templateid property' access='public' output='false' returntype='void'>
		<cfargument name='newTemplateid' displayname='numeric newTemplateid' hint='new value for the templateid property' type='numeric' required='yes' />
		<cfset variables.instance.templateid = arguments.newTemplateid />
	</cffunction>
	<cffunction name='getPagename' displayname='string getPagename()' hint='get the value of the pagename property' access='public' output='false' returntype='string'>
		<cfreturn variables.instance.pagename />
	</cffunction>
	<cffunction name='setPagename' displayname='setPagename(string newPagename)' hint='set the value of the pagename property' access='public' output='false' returntype='void'>
		<cfargument name='newPagename' displayname='string newPagename' hint='new value for the pagename property' type='string' required='yes' />
		<cfset variables.instance.pagename = arguments.newPagename />
	</cffunction>
	<cffunction name='getPagetitle' displayname='string getPagetitle()' hint='get the value of the pagetitle property' access='public' output='false' returntype='string'>
		<cfreturn variables.instance.pagetitle />
	</cffunction>
	<cffunction name='setPagetitle' displayname='setPagetitle(string newPagetitle)' hint='set the value of the pagetitle property' access='public' output='false' returntype='void'>
		<cfargument name='newPagetitle' displayname='string newPagetitle' hint='new value for the pagetitle property' type='string' required='yes' />
		<cfset variables.instance.pagetitle = arguments.newPagetitle />
	</cffunction>
	<cffunction name='getBgcolor' displayname='string getBgcolor()' hint='get the value of the bgcolor property' access='public' output='false' returntype='string'>
		<cfreturn variables.instance.bgcolor />
	</cffunction>
	<cffunction name='setBgcolor' displayname='setBgcolor(string newBgcolor)' hint='set the value of the bgcolor property' access='public' output='false' returntype='void'>
		<cfargument name='newBgcolor' displayname='string newBgcolor' hint='new value for the bgcolor property' type='string' required='yes' />
		<cfset variables.instance.bgcolor = arguments.newBgcolor />
	</cffunction>
	<cffunction name='getBackgroundimage' displayname='string getBackgroundimage()' hint='get the value of the backgroundimage property' access='public' output='false' returntype='string'>
		<cfreturn variables.instance.backgroundimage />
	</cffunction>
	<cffunction name='setBackgroundimage' displayname='setBackgroundimage(string newBackgroundimage)' hint='set the value of the backgroundimage property' access='public' output='false' returntype='void'>
		<cfargument name='newBackgroundimage' displayname='string newBackgroundimage' hint='new value for the backgroundimage property' type='string' required='yes' />
		<cfset variables.instance.backgroundimage = arguments.newBackgroundimage />
	</cffunction>
	<cffunction name='getPhysicalpagepath' displayname='string getPhysicalpagepath()' hint='get the value of the physicalpagepath property' access='public' output='false' returntype='string'>
		<cfreturn variables.instance.physicalpagepath />
	</cffunction>
	<cffunction name='setPhysicalpagepath' displayname='setPhysicalpagepath(string newPhysicalpagepath)' hint='set the value of the physicalpagepath property' access='public' output='false' returntype='void'>
		<cfargument name='newPhysicalpagepath' displayname='string newPhysicalpagepath' hint='new value for the physicalpagepath property' type='string' required='yes' />
		<cfset variables.instance.physicalpagepath = arguments.newPhysicalpagepath />
	</cffunction>
	<!--- standard get instance method --->
	<cffunction name='getInstance' displayname='struct getInstance()' hint='get struct instance of the bean' access='public' returntype='struct' output='false'>
		<cfreturn variables.instance />
	</cffunction>
	<!--- standard set instance method --->
	<cffunction name='setInstance' displayname='setInstance(struct newInstance)' hint='set struct instance of the bean' access='public' returntype='void' output='false'>
		<cfargument name='newInstance' displayname='struct newInstance' hint='new instance for the bean' type='struct' required='yes' />
		<cfset variables.instance = arguments.newInstance />
	</cffunction>
	
<!--- QUERIES --->	
<!--- Add page to DB --->
	<cffunction name="queryAddPage" displayname="Add Page to DB" hint="Add page to DB" access="public" returntype="void" output="false">
		<cfset var q_updatePage = "">
		<cfif getSitesectionid() EQ 0><cfthrow message="You must supply a sitesection id." detail="The function queryAddPage requires a sitesectionid. You can supply one by setting a sitesectionid at the instance level."></cfif>
		<cfif getTemplateid() EQ 0><cfthrow message="You must supply a template id." detail="The function queryAddPage requires a templateid. You can supply one by setting a templateid at the instance level."></cfif>
		<cfif len(getPagename()) EQ 0><cfthrow message="You must supply a pagename." detail="The function queryAddPage requires a pagename. You can supply one by setting a pagename at the instance level."></cfif>
		<cfif len(getPagetitle()) EQ 0><cfthrow message="You must supply a pagetitle." detail="The function queryAddPage requires a pagetitle. You can supply one by setting a pagetitle at the instance level."></cfif>
		<cftransaction>
			<cfquery name="q_getNextPageID" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT (ID + 1) AS id
				FROM TableID
				WHERE (TableName = 'page')
			</cfquery>
			<cfquery name="q_setNextPageID" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE TableID SET id = #q_getNextPageID.id#
				WHERE TableName = 'page'
			</cfquery>
			<cfquery name="q_updatePage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				INSERT INTO page
					(pageid, sitesectionid,templateid,pagename,pagetitle,bgcolor,backgroundimage)
				VALUES
					(#q_getNextPageID.id#, #getSitesectionid()#,#getTemplateid()#,'#getPagename()#','#replaceNoCase(getPagetitle(),"'","''")#','#getBgcolor()#','#getBackgroundimage()#')
			</cfquery>
		</cftransaction>
		<cfset setPageid(q_getNextPageID.id)>
	</cffunction>
<!--- Update page in DB by pageid --->
	<cffunction name="queryUpdatePageById" displayname="Query Update Page By ID" hint="Update page information by pageid in the DB" access="public" returntype="void" output="false">
		<cfset var q_updatePage = "">
		<cfif getPageid() EQ 0><cfthrow message="You must supply a page id." detail="The function queryPageById requires a pageid. You can supply one by setting a pageid at the instance level."></cfif>
		<cfif getSitesectionid() EQ 0><cfthrow message="You must supply a sitesection id." detail="The function queryUpdatePageById requires a sitesectionid. You can supply one by or setting a sitesectionid at the instance level."></cfif>
		<cfif getTemplateid() EQ 0><cfthrow message="You must supply a template id." detail="The function queryUpdatePageById requires a templateid. You can supply one by setting a templateid at the instance level."></cfif>
		<cfif len(getPagename()) EQ 0><cfthrow message="You must supply a pagename." detail="The function queryUpdatePageById requires a pagename. You can supply one by setting a pagename at the instance level."></cfif>
		<cfif len(getPagetitle()) EQ 0><cfthrow message="You must supply a pagetitle." detail="The function queryUpdatePageById requires a pagetitle. You can supply one by setting a pagetitle at the instance level."></cfif>
		<cfquery name="q_updatePage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			UPDATE page SET sitesectionid = #getSitesectionid()#, templateid = #getTemplateid()#, pagename = '#getPagename()#', pagetitle = '#replaceNoCase(getPagetitle(),"'","''")#', bgcolor = '#getBgcolor()#', backgroundimage = '#getBackgroundimage()#' WHERE pageid = #getPageid()#
		</cfquery>
	</cffunction>
<!--- Delete page info from DB by pageid --->
	<cffunction name="queryDeletePageById" displayname="Delete Page By ID" hint="Delete page by pageid from DB" access="public" returntype="void" output="false">
		<cfset var q_getPage = "">
		<cfif getPageid() EQ 0><cfthrow message="You must supply a page id." detail="The function queryDeletePageById requires a pageid. You can supply one by setting a pageid at the instance level."></cfif>
		<cfquery name="q_getPage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			DELETE FROM page WHERE pageid = #getPageid()#
		</cfquery>
	</cffunction>
<!--- Retrieve page info from DB by pageid --->
	<cffunction name="queryPageById" displayname="Query Page By ID" hint="Query page information by pageid" access="public" returntype="query" output="false">
		<cfargument name='pageid' displayname='numeric pageid' hint='Id of the page to retrieve' type='numeric' required='yes' />
		<cfset var q_getPage = "">
		<cfquery name="q_getPage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT * FROM page WHERE pageid = #arguments.pageid#
		</cfquery>
		<cfreturn q_getPage>
	</cffunction>
<!--- Retrieve page info from DB by pagename and sitesectionid --->
	<cffunction name="queryPageBySectionPageName" displayname="Query Page By ID" hint="Query page information by pagename and sitesectionid" access="public" returntype="query" output="false">
		<cfargument name='pagename' displayname='string pagename' hint='Filename of the page to retrieve' type='string' required='yes' />
		<cfargument name='sitesectionid' displayname='numeric sitesectionid' hint='Id of the section to check' type='numeric' required='yes' />
		<cfset var q_getPage = "">
		<cfquery name="q_getPage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT * FROM page WHERE pagename = '#arguments.pagename#' AND sitesectionid = #arguments.sitesectionid#
		</cfquery>
		<cfreturn q_getPage>
	</cffunction>
<!--- Retrieve page info from DB by templateID --->
	<cffunction name="queryPageByTemplateID" displayname="Query Page By Template ID" hint="Query page information by templateid" access="public" returntype="query" output="false">
		<cfargument name='templateid' displayname='numeric templateid' hint='Id of the template to retrievepage information' type='numeric' required='yes' />
		<cfset var q_getPage = "">
		<cfquery name="q_getPage" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT * FROM page WHERE templateid = #arguments.templateid#
		</cfquery>
		<cfreturn q_getPage>
	</cffunction>
	
<!--- POPULATE FROM DBers --->
<!--- Set page info from DB to page instance using its id --->
	<cffunction name="popPageById" displayname="Populate Page By ID" hint="Populate the page instance from the DB using pageid" access="public" returntype="void" output="false">
		<cfargument name='pageid' displayname='numeric pageid' hint='Id of the page to retrieve' type='numeric' required='yes' />
		<cfset var pageQuery = "">
		<cfset var sitesection = "">
		<cfset pageQuery = queryPageById(pageid=arguments.pageid)>
		<cfif pageQuery.recordcount NEQ 0>
			<cfset setPageId(pageQuery.pageid)>
			<cfset setSiteSectionId(pageQuery.sitesectionid)>
			<cfset setTemplateId(pageQuery.templateid)>
			<cfset setPagename(pageQuery.pagename)>
			<cfset setPageTitle(pageQuery.pagetitle)>
			<cfset setBGColor(pageQuery.bgcolor)>
			<cfset setBackgroundimage(pageQuery.backgroundimage)>
			<cfset sitesection = createObject("component","core.sitesection")>
			<cfset sitesection.init()>
			<cfif(sitesection.existsSectionById(getSitesectionid()))>
				<cfset setPhysicalpagepath("#sitesection.physicalPathById(getSitesectionid())##pageQuery.pagename#")>
			</cfif>
		<cfelse>
			<cfthrow message="The pageid #arguments.pageid# does not exist" detail="You have attempted to call the function popPageById with a pageid that does not exist in the system.">
		</cfif>
	</cffunction>
<!--- Set page info from DB to page instance using its pagename and sitesectionid --->
	<cffunction name="popPageBySectionPageName" displayname="Populate Page By ID" hint="Populate the page instance from the DB using pageid" access="public" returntype="void" output="false">
		<cfargument name='pagename' displayname='string pagename' hint='Filename of the page to retrieve' type='string' required='yes' />
		<cfargument name='sitesectionid' displayname='numeric sitesectionid' hint='Id of the section to check' type='numeric' required='yes' />
		<cfset var pageQuery = "">
		<cfset var sitesection = "">
		<cfset pageQuery = queryPageBySectionPageName(pagename=arguments.pagename,sitesectionid=arguments.sitesectionid)>
		<cfif pageQuery.recordcount NEQ 0>
			<cfset setSitesectionid(pageQuery.sitesectionid)>
			<cfset setPageName(pageQuery.pagename)>
			<cfset setPageId(pageQuery.pageid)>
			<cfset setTemplateId(pageQuery.templateid)>
			<cfset setPageTitle(pageQuery.pagetitle)>
			<cfset setBGColor(pageQuery.bgcolor)>
			<cfset setBackgroundimage(pageQuery.backgroundimage)>
			<cfset sitesection = createObject("component","core.sitesection")>
			<cfset sitesection.init()>
			<cfset sitesection.setSitesectionid(getSitesectionid())>
			<cfif(sitesection.existsSectionById(arguments.sitesectionid))>
				<cfset setPhysicalpagepath("#sitesection.physicalPathById(getSitesectionid())##pageQuery.pagename#")>
			</cfif>
		<cfelse>
			<cfthrow message="The page #getPagename()# does not exist in the section with an id of #getSitesectionId()#" detail="You have attempted to call the function popPageBySectionPageName with a pageid that does not exist in the system.">
		</cfif>
	</cffunction>
	
<!--- EXISTANCE CHECKS --->
<!--- Check to see if file exists --->
	<cffunction name="existsFile" displayname="Exists File By ID" hint="Check to see if file exists on server by pageid" access="public" returntype="boolean" output="false">
		<cfargument name='physicalpagepath' displayname='string physicalpagepath' hint='Filepath of the page' type='string' required='yes' />
		<cfset var pageQuery = "">
		<cfreturn fileexists(arguments.physicalpagepath)>
	</cffunction>
<!--- Check to see if page exists in system by pageid --->
	<cffunction name="existsPageById" displayname="Exists Page By ID" hint="Check to see if page exists in system by pageid" access="public" returntype="boolean" output="false">
		<cfargument name='pageid' displayname='numeric pageid' hint='Id of the page to retrieve' type='numeric' required='yes' />
		<cfset var pageQuery = "">
		<cfset pageQuery = queryPageById(pageid=arguments.pageid)>
		<cfreturn pageQuery.recordCount>
	</cffunction>
<!--- Check to see if page exists in section by pagename and sitesectionid --->
	<cffunction name="existsInSection" displayname="Exists in Section" hint="Check to see if page exists in section by pagename and sitesectionid" access="public" returntype="boolean" output="false">
		<cfargument name='pagename' displayname='string pagename' hint='Filename of the page to retrieve' type='string' required='yes' />
		<cfargument name='sitesectionid' displayname='numeric sitesectionid' hint='Id of the section to check' type='numeric' required='yes' />
		<cfset var pageQuery = "">
		<cfset pageQuery = queryPageBySectionPageName(sitesectionid=arguments.sitesectionid, pagename=arguments.pagename)>
		<cfreturn pageQuery.recordCount>
	</cffunction>
	
<!--- PHYSICAL FILE MANAGEMENT --->
<!--- Delete a file --->
	<cffunction name="filePageDelete" displayname="Delete a page file" hint="Deletes the physical file of a page" access="public" returntype="void" output="false">
		<cfif len(getPhysicalpagepath()) EQ 0><cfthrow message="You must supply a filepath." detail="The function fileDelete requires a physicalpagepath. You can supply one by setting a physicalpagepath at the instance level."></cfif>
		<cfif existsFile(getPhysicalpagepath())>
			<cffile action="DELETE" file="#getPhysicalpagepath()#">
		</cfif>
	</cffunction>
<!--- Add a file --->
	<cffunction name="fileAdd" displayname="Create a page file" hint="Creates the physical file of a page" access="public" returntype="void" output="false">
		<cfif len(getPhysicalpagepath()) EQ 0><cfthrow message="You must supply a filepath." detail="The function fileAdd requires a physicalpagepath. You can supply one by setting a physicalpagepath at the instance level."></cfif>
		<!--- in case of accident, don't overwrite old file! --->
		<cfif NOT existsFile(getPhysicalpagepath())>
			<cffile action="WRITE" file="#getPhysicalpagepath()#" output="<!--- #form.pagename# --->" addnewline="No">
		<cfelse>
			<cfthrow message="File #getPhysicalpagepath()# already exists." detail="The function fileAdd has attempted to create a new file at #getPhysicalpagepath()# however one already exists in that location. Please move the file or choose another target location.">
		</cfif>
	</cffunction>
<!--- Move/Rename a file --->
	<cffunction name="fileMove" displayname="Move/Rename a page file" hint="Moves/Renames the physical file of a page" access="public" returntype="void" output="false">
		<cfargument name='newpath' displayname='string newpath' hint='New Filepath of the page' type='string' required='yes' />
		<cfif len(getPhysicalpagepath()) EQ 0><cfthrow message="You must supply a filepath." detail="The function fileAdd requires a physicalpagepath. You can supply one by setting a physicalpagepath at the instance level."></cfif>
		<!--- in case of accident, don't overwrite old file! --->
		<cfif fileexists(arguments.newpath) AND NOT(getPhysicalpagepath() EQ arguments.newpath)>
			<cfthrow message="File #arguments.newpath# already exists." detail="The function fileMove has attempted to create a new file at #arguments.newpath# however one already exists in that location. Please move the file or choose another target location.#(getPhysicalpagepath() EQ arguments.newpath)#">
		</cfif>
		<!--- make sure old file does exist --->
		<cfif NOT existsFile(getPhysicalpagepath())>
			<cfthrow message="File #getPhysicalpagepath()# does not exist." detail="The function fileMove has attempted to use the file #getPhysicalpagepath()# however it does not exist.">
		</cfif>
		<cffile action="move" destination="#arguments.newpath#" source="#getPhysicalpagepath()#">
		<cfset setPhysicalpagepath(arguments.newpath)>
	</cffunction>
</cfcomponent>