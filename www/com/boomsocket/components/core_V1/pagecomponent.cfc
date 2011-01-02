<cfcomponent displayname='pagecomponent' hint='pagecomponent CFC Bean' >
	<!--- init method --->
	<cffunction name='init' displayname='pagecomponentBean init()' hint='initialze the bean' access='public' returntype='struct' output='false'>
		<cfargument name='pagecomponentid' displayname='Pagecomponent ID' hint='ID of the pagecomponent' type='numeric' required='yes' default='0' />
		<cfargument name='containerid' displayname='Container ID' hint='ID of the container' type='numeric' required='yes' default='0' />
		<cfargument name='displayhandlerid' displayname='Data Driven Display ID' hint='ID of the Data Driven Display' type='numeric' required='yes' default='0' />
		<cfargument name='pageid' displayname='Page ID' hint='ID of the page' type='numeric' required='yes' default='0' />
		<cfargument name='templateid' displayname='Template ID' hint='ID of the template' type='numeric' required='yes' default='0' />
		<cfargument name='allpages' displayname='All Pages' hint='Boolean to tell us to update all pages' type='boolean' required='yes' default='FALSE' />
		<cfargument name='contentobjectid' displayname='Content Object ID' hint='ID of the content object' type='numeric' required='yes' default='0' />
		<cfscript>
			variables.instance = structNew();
			variables.instance.pagecomponentid = arguments.pagecomponentid;
			variables.instance.containerid = arguments.containerid;
			variables.instance.displayhandlerid = arguments.displayhandlerid;
			variables.instance.pageid = arguments.pageid;
			variables.instance.templateid = arguments.templateid;
			variables.instance.allpages = arguments.allpages;
			variables.instance.contentobjectid = arguments.contentobjectid; 
			
			// We use page functions withing our page component CFC
			// The page CFC isn't extended so we instantiate here for each component that gets made
			variables.instance.pageCFC = createObject('component', 'page');		//notice there is no path. these file are in the same directory so we don't need it.
		</cfscript>
		<cfreturn this />
	</cffunction>

	<cffunction access="public" name="checkPageComponent" output="false" returntype="numeric" displayname="Check Component Exists" hint="Check to see if the component you're working with is alreadyin the DB">
		<cfquery name="q_testPageComponent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			<cfif getContentObjectID() NEQ 0>
				SELECT contentobjectid 
			<cfelse>
				SELECT displayhandlerid 
			</cfif>
				FROM pagecomponent
				WHERE pageid = #getPageID()# AND containerid = #getContainerid()#
		</cfquery>
		<cfreturn q_testPageComponent.recordCount>
	</cffunction>

	<cffunction access="public" name="insertPageComponent" output="false" returntype="boolean" displayname="Insert Component" hint="Inserts a component for a page into the pagecomponet table">
		<cftry>
			<cftransaction>
				<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="pagecomponent" datasource="#application.datasource#"returnvar="nextID">
				<cfquery name="q_InsertPageComponent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						INSERT INTO pagecomponent(pagecomponentid,displayhandlerid,contentobjectid,pageid,containerid)
					<cfif getContentObjectID() NEQ 0>
						VALUES (#nextID# + 1,#getdisplayhandlerid()#,#getcontentobjectid()#,#getPageID()#,#getContainerid()#)
					<cfelse>
						VALUES (#nextID# + 1,#getdisplayhandlerid()#,NULL,#getPageID()#,#getContainerid()#)
					</cfif>
				</cfquery>
			</cftransaction>
			<cfreturn 'true'>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction access="public" name="updatePageComponent" output="false" returntype="boolean" displayname="Update Page Component" hint="Updates a page component in the DB with new data">
		<cftry>
			<cfquery name="q_UpdatePageComponent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE pagecomponent 
				<cfif getContentObjectID() NEQ 0>
					SET displayhandlerid = #getdisplayhandlerid()#, contentobjectid = #getcontentobjectid()# 
				<cfelse>
					SET displayhandlerid = #getdisplayhandlerid()# , contentobjectid = NULL 
				</cfif>
					WHERE pageid = #getPageID()# AND containerid = #getContainerid()#
			</cfquery>
			<cfreturn 'true'>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction access="public" name="deletePageComponent" output="false" returntype="boolean" displayname="Delete Page Component" hint="Deletes a page component in the DB">
		<cftry>
			<cfquery name="q_DeletePageComponent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					DELETE FROM pagecomponent 
					WHERE pagecomponentid = #getPageComponentID()#
			</cfquery>
			<cfreturn 'true'>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction access="public" name="associateComponent" output="false" returntype="boolean" displayname="Add Data Driven Display" hint="This add's a Data Driven Display to the page component system">
		<cfset var editPageIDList = ''>
		<cfset var returnValue = 'false'>
		<cftry>
			<cfset getInstance()>
			<cfcatch type="coldfusion.runtime.UndefinedElementException">
				<cfthrow message="No Object Instantiated" type="exception" detail="You do not have a page component object instantiated. Please instantiate a page component object. #CFCATCH.Detail#" extendedinfo="Error occured while trying to run the associate Component Method of the pageComponent CFC">		
			</cfcatch>
			<cfcatch type="any">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfif getallpages() >
			<cfset returnValue = associateAllPages()>
		<cfelse>
		 	<cfset editPageIDList = getpageid()>
			<cfif checkPageComponent() EQ 0>
				<cfif insertPageComponent()>
					<cfset returnValue = 'true'>				
				</cfif>
			<cfelse>
				<cfif updatePageComponent()>
					<cfset returnValue = 'true'>				
				</cfif>
			</cfif>
		</cfif>
		<cfreturn returnValue>
	</cffunction>

	<cffunction access="private" name="associateAllPages" output="false" returntype="boolean" displayname="Add Data Driven Display" hint="This add's a Data Driven Display to the page component system">
		<cfset var currentPageId = getPageID()>
		<cfset q_getAllPages = variables.instance.pageCFC.queryPageByTemplateID(gettemplateid())>
		<cfset editPageIDList = valueList(q_getAllPages.pageid)>
		<!--- Loop over pageid values and update/insert components accordingly --->
		<cfloop list="#editPageIDList#" index="thisPage">
			<cfset setPageID(thisPage)>
			<cfif checkPageComponent() EQ 0>
				<cfif insertPageComponent()>
					<cfset returnValue = 'true'>				
				</cfif>
			<cfelse>
				<cfif updatePageComponent()>
					<cfset returnValue = 'true'>				
				</cfif>
			</cfif>
		</cfloop>
		<cfset setPageID(currentPageId)>
		<cfreturn returnValue>
	</cffunction>

	<!--- standard getter/setter methods --->
	<cffunction name='getPagecomponentid' displayname='numeric getPagecomponentid()' hint='get the value of the pagecomponentid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.pagecomponentid />
	</cffunction>
	<cffunction name='setPagecomponentid' displayname='setPagecomponentid(numeric newPagecomponentid)' hint='set the value of the pagecomponentid property' access='public' output='false' returntype='void'>
		<cfargument name='newPagecomponentid' displayname='numeric newPagecomponentid' hint='new value for the pagecomponentid property' type='numeric' required='yes' />
		<cfset variables.instance.pagecomponentid = arguments.newPagecomponentid />
	</cffunction>

	<cffunction name='getContainerid' displayname='numeric getContainerid()' hint='get the value of the containerid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.containerid />
	</cffunction>
	<cffunction name='setContainerid' displayname='setContainerid(numeric newContainerid)' hint='set the value of the containerid property' access='public' output='false' returntype='void'>
		<cfargument name='newContainerid' displayname='numeric newContainerid' hint='new value for the containerid property' type='numeric' required='yes' />
		<cfset variables.instance.containerid = arguments.newContainerid />
	</cffunction>

	<cffunction name='getDisplayhandlerid' displayname='numeric getDisplayhandlerid()' hint='get the value of the displayhandlerid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.displayhandlerid />
	</cffunction>
	<cffunction name='setDisplayhandlerid' displayname='setDisplayhandlerid(numeric newDisplayhandlerid)' hint='set the value of the displayhandlerid property' access='public' output='false' returntype='void'>
		<cfargument name='newDisplayhandlerid' displayname='numeric newDisplayhandlerid' hint='new value for the displayhandlerid property' type='numeric' required='yes' />
		<cfset variables.instance.displayhandlerid = arguments.newDisplayhandlerid />
	</cffunction>

	<cffunction name='getPageid' displayname='numeric getPageid()' hint='get the value of the pageid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.pageid />
	</cffunction>
	<cffunction name='setPageid' displayname='setPageid(numeric newPageid)' hint='set the value of the pageid property' access='public' output='false' returntype='void'>
		<cfargument name='newPageid' displayname='numeric newPageid' hint='new value for the pageid property' type='numeric' required='yes' />
		<cfset variables.instance.pageid = arguments.newPageid />
	</cffunction>

	<cffunction name='gettemplateid' displayname='numeric gettemplateid()' hint='get the value of the templateid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.templateid />
	</cffunction>
	<cffunction name='settemplateid' displayname='settemplateid(numeric newtemplateid)' hint='set the value of the templateid property' access='public' output='false' returntype='void'>
		<cfargument name='newtemplateid' displayname='numeric newtemplateid' hint='new value for the templateid property' type='numeric' required='yes' />
		<cfset variables.instance.templateid = arguments.newtemplateid />
	</cffunction>

	<cffunction name='getallpages' displayname='boolean getallpages()' hint='get the value of the allpages property' access='public' output='false' returntype='boolean'>
		<cfreturn variables.instance.allpages />
	</cffunction>
	<cffunction name='setallpages' displayname='setallpages(booelan newallpages)' hint='set the value of the allpages property' access='public' output='false' returntype='void'>
		<cfargument name='newallpages' displayname='numeric newallpages' hint='new value for the allpages property' type='boolean' required='yes' />
		<cfset variables.instance.allpages = arguments.newallpages />
	</cffunction>
	
	<cffunction name='getContentobjectid' displayname='numeric getContentobjectid()' hint='get the value of the contentobjectid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.contentobjectid />
	</cffunction>
	<cffunction name='setContentobjectid' displayname='setContentobjectid(numeric newContentobjectid)' hint='set the value of the contentobjectid property' access='public' output='false' returntype='void'>
		<cfargument name='newContentobjectid' displayname='numeric newContentobjectid' hint='new value for the contentobjectid property' type='numeric' required='yes' />
		<cfset variables.instance.contentobjectid = arguments.newContentobjectid />
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
<!--- Retrieve pagecomponent info from DB by pagecomponentid --->
	<cffunction name="querypagecomponentById" displayname="Query pagecomponent By ID" hint="Query pagecomponent information by pagecomponentid" access="public" returntype="query" output="false">
		<cfargument name='pagecomponentid' displayname='numeric pagecomponentid' hint='Id of the pagecomponent to retrieve' type='numeric' required='yes' />
		<cfset var q_getPagecomponent = "">
		<cfquery name="q_getPagecomponent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT * FROM pagecomponent WHERE pagecomponentid = #arguments.pagecomponentid#
		</cfquery>
		<cfreturn q_getPagecomponent>
	</cffunction>	

<!--- POPULATE FROM DBers --->
<!--- Set pagecomponent info from DB to pagecomponent instance using its id --->
	<cffunction name="popPagecomponentById" displayname="Populate pagecomponent By ID" hint="Populate the pagecomponent instance from the DB using pagecomponentid" access="public" returntype="void" output="false">
		<cfargument name='pagecomponentid' displayname='numeric pagecomponentid' hint='Id of the pagecomponent to retrieve' type='numeric' required='yes' default="0" />
		<cfset var pagecomponentQuery = "">
		<cfset pagecomponentQuery = queryPagecomponentById(pagecomponentid=arguments.pagecomponentid)>
		<cfif pagecomponentQuery.recordcount NEQ 0>
			<cfset setPagecomponentID(pagecomponentQuery.pagecomponentid)>
		<cfelse>
			<cfthrow message="The pagecomponentid #getpagecomponentid()# does not exist" detail="You have attempted to call the function popPagecomponentById with a pagecomponentid that does not exist in the system.">
		</cfif>
	</cffunction>

<!--- EXISTANCE CHECKS --->
<!--- Check to see if section exists in system by sitesectionid --->
	<cffunction name="existsPagecomponentById" displayname="Exists pagecomponent By ID" hint="Check to see if pagecomponent exists in system by pagecomponentid" access="public" returntype="boolean" output="false">
		<cfargument name='pagecomponentid' displayname='numeric pagecomponentid' hint='Id of the pagecomponent to retrieve' type='numeric' required='yes' />
		<cfset var pagecomponentQuery = queryPagecomponentById(pagecomponentid=arguments.pagecomponentid)>
		<cfreturn pagecomponentQuery.recordCount>
	</cffunction>
	
<!--- OTHER FUNCTIONS --->

</cfcomponent>