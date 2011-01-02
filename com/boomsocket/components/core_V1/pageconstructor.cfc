<!--- queries and such for page constructor --->

<cfcomponent displayname='Page Constructor' hint='Assembles a frontend page in i3sitetools' >
<!--- init method --->
	<cffunction name='init' displayname='struct init()' hint='initialze' access='public' returntype='struct' output='false'>
		<cfargument name='pageid' displayname='Page ID' hint='The id of the Page' type='numeric' required='no' default=0 />
		<cfargument name='sitesectionid' displayname='Section ID' hint='The id of the Section' type='numeric' required='no' default=0 />
		<cfargument name='thispage' displayname='Filename' hint='Filename of the page' type='string' required='yes' />
		<cfargument name='filepath' displayname='Physical Page Path' hint='Path to page' type='string' required='yes' />
		<cfargument name='datasource' displayname='Datasource' type='string' required='no' />
		<cfargument name='installurl' displayname='installurl' type='string' required='no' />
		<cfscript>
			variables.instance = structNew();
			variables.instance.thispage = arguments.thispage;
			variables.instance.filepath = arguments.filepath;
			if( IsDefined('arguments.datasource') AND Len(Trim(arguments.datasource))){
				variables.instance.datasource = arguments.datasource;
			}else{
				variables.instance.datasource = application.datasource;
			}
			if( IsDefined('arguments.installurl') AND Len(Trim(arguments.installurl))){
				variables.instance.installurl = arguments.installurl;
			}else{
				variables.instance.installurl = application.installurl;
			}
			if((arguments.pageid EQ 0) OR (arguments.sitesectionid EQ 0)){
				initPageSectionid();
			}else{
				variables.instance.pageid = arguments.pageid;
				variables.instance.sitesectionid = arguments.sitesectionid;
			}
		</cfscript>
		<cfreturn this />
	</cffunction>
<!--- Use filename and page path to determine page and sectionid --->
	<cffunction name='initPageSectionid' displayname='Init Page and Section id' hint='Use filename and page path to determine page and section id' access='public' output='false' returntype='void'>
		<cfset var thispageid = 0>
		<cfquery datasource="#variables.instance.datasource#" name="q_getpagesbyname" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT pageid,sitesectionid 
            FROM page 
            WHERE page.pagename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getthispage()#">
		</cfquery>
		<!--- if there is more than one with this name, loop and compare to filepaths --->
		<cfif q_getpagesbyname.recordcount>
			<cfloop query="q_getpagesbyname">
				<cfset thisSectionPath = application.getSectionPath(q_getpagesbyname.sitesectionid,"true","/")>
				<cfif getfilepath() EQ "/#application.getSectionPath(q_getpagesbyname.sitesectionid,"true","/")#/#getthispage()#">
					<cfset setPageid(q_getpagesbyname.pageid)>
					<cfset setSitesectionid(q_getpagesbyname.sitesectionid)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset setPageid(0)>
			<cfset setSitesectionid(0)>
		</cfif>
	</cffunction>
<!--- Build application query for all page construction data --->
	<cffunction name='getAllPageInfo' displayname='Get All page info' hint='query for all page construction data' access='public' output='false' returntype='query'>
		<cfset var q_getAllPageInfo = ''>
		<cfquery datasource="#variables.instance.datasource#" name="q_getAllPageInfo" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT DISTINCT pagedata.*, pagecontainerdata.displayobjectid, pagecontainerdata.objectid, pagecontainerdata.customInclude, pagecontainerdata.invokefilename, pagecontainerdata.contentobjectid, pagecontainerdata.containerid, pagecontainerdata.formObjectID
			FROM  pagedata LEFT OUTER JOIN pagecontainerdata ON pagedata.pageid = pagecontainerdata.pageid
			WHERE pagedata.pageActive = 1 AND pagedata.sitesectionActive = 1  
			ORDER BY pagedata.pageid
		</cfquery>
		<cfreturn q_getAllPageInfo>
	</cffunction>
<!--- Query for this page construction data --->
	<cffunction name='getThisPageInfo' displayname='Get This page info' hint='query for instance page construction data' access='public' output='false' returntype='query'>
		<cfargument name='allPageQuery' displayname='query allPageQuery' hint='query containing all page construction data' type='query' required='yes' />
		<cfset var q_getThisPageInfo = ''>
		<cfquery name="q_getThisPageInfo" dbtype="query" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT *
			FROM  arguments.allPageQuery
			WHERE pageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#getpageid()#">
			ORDER BY containerid
		</cfquery>
		<!--- allPageQuery may be outdated, do a fix for contentobject associations --->
		<cfif len(q_getThisPageInfo.containerid)>
			<cfquery datasource="#variables.instance.datasource#" name="q_getNewContent" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT containerid, contentobjectid
				FROM pagecomponent
				WHERE containerid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#valueList(q_getThisPageInfo.containerid)#" list="yes">) AND pageid=<cfqueryparam cfsqltype="cf_sql_integer" value="#getpageid()#">
				ORDER BY containerid
			</cfquery>
			<!--- Manually update the record set to use the latest content objects --->
			<cfloop query="q_getNewContent">
				<cfset q_getThisPageInfo.contentobjectid[q_getNewContent.currentrow] = q_getNewContent.contentobjectid>
			</cfloop>
		</cfif>
		<cfreturn q_getThisPageInfo>
	</cffunction>
<!--- Determine if two content objects have matching parents (are they versions of the same content?) --->
	<cffunction name='parentsMatch' displayname='Parents Match' hint='Determine if two content objects have matching parents (are they versions of the same content?)' access='public' output='false' returntype='boolean'>
		<cfargument name='contentobject1' displayname='numeric contentobject1' hint='contentobject 1' type='numeric' required='yes' />
		<cfargument name='contentobject2' displayname='numeric contentobject2' hint='contentobject 2' type='numeric' required='yes' />
			<cfif arguments.contentobject1 EQ arguments.contentobject2>
				<cfreturn true>
			<cfelse>
				<cfquery name="getParents" datasource="#variables.instance.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT parentid FROM version 
                    WHERE instanceItemId IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contentobject1#">, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contentobject2#">)
				</cfquery>
				<cfif getParents.recordCount EQ 2 AND getParents.parentid[1] EQ getParents.parentid[2]>
					<cfreturn true>
				<cfelse>
					<cfreturn false>
				</cfif>
			</cfif>
	</cffunction>
<!--- Get all javascripts used on this site --->
	<cffunction name='getAllJS' displayname='Get All JavaScript' hint='query for all site javascript' access='public' output='false' returntype='query'>
		<cfset var q_getAllJS = ''>
		<cfquery datasource="#variables.instance.datasource#" name="q_getAllJS" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT javascript.*, javascript_page.*, javascript_sitesection.*
			FROM javascript 
            	LEFT OUTER JOIN javascript_page 
                	ON javascript_page.javascriptid = javascript.javascriptid 
                 LEFT OUTER JOIN javascript_sitesection 
                 	ON javascript.javascriptid =javascript_sitesection.javascriptid
		</cfquery>
		<cfreturn q_getAllJS>
	</cffunction>
<!--- Get all javascripts used on this page --->
	<cffunction name='getPageJS' displayname='Get Page JavaScript' hint='query for javascripts used on this page' access='public' output='false' returntype='query'>
		<cfargument name='allJSQuery' displayname='query allJSQuery' hint='query containing all site javascript' type='query' required='yes' />
		<cfset var q_getPageJS = ''>
		<cfquery name="q_getPageJS" dbtype="query" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT DISTINCT *
			FROM arguments.allJSQuery
			WHERE useSiteWide = 1 OR pageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#getPageid()#"> OR sitesectionid = <cfqueryparam cfsqltype="cf_sql_integer" value="#getSitesectionid()#">
		</cfquery>
		<cfreturn q_getPageJS>
	</cffunction>
<!--- get all css used on this page --->
	<cffunction name='getPageCSS' displayname='Get Page CSS' hint='find css used on this page' access='public' output='false' returntype='array'>
		<cfset var cssFileArray = arrayNew(1)>
		<!--- button bar css --->
		<cfset arrayAppend(cssFileArray, "#application.globalPath#/css/buttonBarStyles.css")>
		<!--- site-wide css --->
		<cfif isDefined('application.cssIncludes')>
			<cfloop list="#application.cssIncludes#" index="thisStyleSheet">
				<cfset arrayAppend(cssFileArray, "/css/#thisStyleSheet#")>
			</cfloop>
		</cfif>
		<!--- section css--->
		<cfset cssfile = "">
		<cfloop from="1" to="#listlen(request.pagepath,'/')-1#" index="i">
			<cfset cssfile=listAppend(cssfile,listGetAt(request.pagepath,i,'/'),'_')>
		</cfloop>
		<cfif request.section EQ 'root'>
			<cfset cssfile = "home">
		</cfif>
		<cfset arrayAppend(cssFileArray, "/css/section/#cssfile#.css")>
		<!--- display css--->
		<cfset cssfile = "">
		<cfquery name="q_getDHcss" datasource="#variables.instance.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT DISTINCT displayobject.displayobjectpath 
			FROM pagecomponent INNER JOIN displayhandler ON pagecomponent.displayhandlerid = displayhandler.displayhandlerid 
							   INNER JOIN displayobject ON displayhandler.displayobjectid = displayobject.displayobjectid 
			WHERE (pagecomponent.pageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.thispageid#">) AND pagecomponent.displayhandlerid <> 100 AND pagecomponent.displayhandlerid <> 102
		</cfquery>
		<cfloop query="q_getDHcss">
			<cfset cssfile="#listLast(q_getDHcss.displayobjectpath,'.')#.css">
			<cfset arrayAppend(cssFileArray, "/css/#cssfile#")>
		</cfloop>
		<cfif isDefined("SESSION.usetempcssfile") AND SESSION.usetempcssfile EQ true>
			<cfset cssFileArray = arrayNew(1)>
			<cfset arrayAppend(cssFileArray, "/css/temp.css")>
		</cfif>
		<cfreturn cssFileArray>
	</cffunction>

<!--- GETTER/SETTERS --->
	<cffunction name='getPageid' displayname='numeric getPageid()' hint='get the value of the pageid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.pageid />
	</cffunction>
	<cffunction name='setPageid' displayname='setPageid(numeric newPageid)' hint='set the value of the pageid property' access='public' output='false' returntype='void'>
		<cfargument name='newPageid' displayname='numeric newPageid' hint='new value for the pageid property' type='numeric' required='yes' />
		<cfset variables.instance.pageid = arguments.newPageid />
	</cffunction>
	<cffunction name='getsitesectionid' displayname='numeric getsitesectionid()' hint='get the value of the sitesectionid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.sitesectionid />
	</cffunction>
	<cffunction name='setsitesectionid' displayname='setsitesectionid(numeric newsitesectionid)' hint='set the value of the sitesectionid property' access='public' output='false' returntype='void'>
		<cfargument name='newsitesectionid' displayname='numeric newsitesectionid' hint='new value for the sitesectionid property' type='numeric' required='yes' />
		<cfset variables.instance.sitesectionid = arguments.newsitesectionid />
	</cffunction>
	<cffunction name='getthispage' displayname='string getthispage()' hint='get the value of the thispage property' access='public' output='false' returntype='string'>
		<cfreturn variables.instance.thispage />
	</cffunction>
	<cffunction name='setthispage' displayname='setthispage(string newthispage)' hint='set the value of the thispage property' access='public' output='false' returntype='void'>
		<cfargument name='newthispage' displayname='string newthispage' hint='new value for the thispage property' type='string' required='yes' />
		<cfset variables.instance.thispage = arguments.newthispage />
	</cffunction>
	<cffunction name='getfilepath' displayname='string getfilepath()' hint='get the value of the filepath property' access='public' output='false' returntype='string'>
		<cfreturn variables.instance.filepath />
	</cffunction>
	<cffunction name='setfilepath' displayname='setfilepath(string newfilepath)' hint='set the value of the filepath property' access='public' output='false' returntype='void'>
		<cfargument name='newfilepath' displayname='string newfilepath' hint='new value for the filepath property' type='string' required='yes' />
		<cfset variables.instance.filepath = arguments.newfilepath />
	</cffunction>
	<!--- if ISAPI or straight URL variables passed for detail item, swap out title element for page SEO --->
	<!--- tests for existance of table, assumes that sekeyname is valid field name in table --->
	<cffunction name='swapHTMLPageTitle' displayname='setfilepath(string newfilepath)' hint='set the value of the filepath property' access='public' output='false' returntype='string'>
		<cfargument name='table' type='string' required='yes' />
		<cfargument name='key' type='string' required='yes' />
		<cfargument name='defaulttitle' type='string' required='yes' />
		<cfset var returnString="">
		<cftry>
			<!--- test existance of table --->
			<cfquery name="q_getTableExistance" datasource="#application.datasource#">
				SELECT name
				FROM sysobjects
				WHERE name = <cfqueryparam value="#ARGUMENTS.table#" cfsqltype="CF_SQL_VARCHAR" >
			</cfquery>
			<cfif q_getTableExistance.recordcount GT 0>
            	<!--- Check to see if our BS_pageTitle column exists --->
                <cfquery name="q_getSEOTitle" datasource="#application.datasource#">
	                sp_columns @table_name = '#ARGUMENTS.table#', @column_name = 'BS_pageTitle'
                </cfquery>
				<!--- match key to fetch name --->
				<cfquery name="q_getSEOTitle" datasource="#application.datasource#">
					<cfif q_getSEOTitle.RecordCount EQ 1>
						SELECT BS_pageTitle as thisSEOTitle
					<cfelse>
	                    SELECT #ARGUMENTS.table#name as thisSEOTitle
					</cfif>
					FROM #ARGUMENTS.table#
					WHERE sekeyname = <cfqueryparam value="#ARGUMENTS.key#" cfsqltype="CF_SQL_VARCHAR" >
				</cfquery>
				<!--- assign name or default to page title --->
				<cfif q_getSEOTitle.recordcount GT 0 AND Len(Trim(q_getSEOTitle.thisSEOTitle))>
					<cfset returnString = q_getSEOTitle.thisSEOTitle>
				<cfelse>
					<cfset returnString=ARGUMENTS.defaulttitle>
				</cfif>
			<!--- default to page title --->
			<cfelse>
				<cfset returnString=ARGUMENTS.defaulttitle>
			</cfif>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn returnString>
	</cffunction>
</cfcomponent>