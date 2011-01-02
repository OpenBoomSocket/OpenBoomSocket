<!--- Filename: getDayofWeekFromDate.cfc --->
<!--- Set up the CFC. --->
<cfcomponent displayname="Content Object"
	             hint="This tag is used to return the content object when passed any valid contentobjectid." 
				 name="getContentObject">
<cfsetting enablecfoutputonly="Yes">
  <!--- Define the getContent method for the CFC . --->
  <cffunction name="getContent"
             access="remote"
             returntype="any"
             displayname="Content Object">
	 <!--- Get pages associated with this page name --->
	 <cfif NOT isDefined("request.thispageid")>
		<cfset thispage=listLast(CGI.SCRIPT_NAME,"/")>
		<cfquery datasource="#application.datasource#" name="q_getpagesbyname" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT pageid,sitesectionid 
            FROM page 
            WHERE page.pagename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thispage#">
		</cfquery>
		<cfset request.thispageid=q_getpagesbyname.pageid>
		<!--- if there is more than one with this name, loop and compare to filepaths --->
		<cfif q_getpagesbyname.recordcount GT 1>
			<cfloop query="q_getpagesbyname">
				<cfif CGI.SCRIPT_NAME EQ "/#application.getSectionPath(q_getpagesbyname.sitesectionid,"true")#/#thispage#">
					<cfset request.thispageid=q_getpagesbyname.pageid>
				</cfif>
			</cfloop>
		</cfif>
	</cfif>
    <!--- Get the content object.  This is getting the id of the object associated with the pagecomponent table--there can only
	be one which is the equivalent of the "parentid" in the version table. --->
	<cfquery name="q_getContentObject" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT version.parentid
		FROM contentobject 
        	INNER JOIN pagecomponent ON contentobject.contentobjectid = pagecomponent.contentobjectid
			INNER JOIN version ON contentobject.contentobjectid = version.instanceitemid
		WHERE pagecomponent.pageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.thispageid#">
        	AND pagecomponent.containerid = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.containerid#">
            AND version.formobjectitemid = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.tool.contentobject#">
	</cfquery>
	<!---Get the live version--check for the version set to live which is associated with the parentid found above--->
<cfif q_getContentObject.recordcount>
	<cfset thisParentID=q_getContentObject.parentid>
<cfelse>
	<cfset thisParentID=0>
</cfif>
	<!--- make this query use the versioncheck customtag to accomodate multi-lingual support --->
	<cfmodule template="#APPLICATION.customtagpath#/versioncheck.cfm" formobjectname="contentobject">
	<cfquery name="q_getLiveContentObject"  datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT contentobject.contentobjectbody, contentobject.contentobjectid
		FROM contentobject #joinclause#
		WHERE version.parentid = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisParentID#"> AND #whereclause#
	</cfquery>
	<!---Make sure there IS a live version, if not, say the content is pending--->
	<cfif q_getLiveContentObject.recordcount>
		<cfset thisContent = q_getLiveContentObject.contentobjectbody>
		<cfset request.currentContentObjectID=q_getLiveContentObject.contentobjectid>
	<cfelse>
		<cfset thisContent = "Content Pending">
	</cfif>
    <cfreturn thisContent>
  </cffunction>
 
 <!--- *** This is the inline editor method *** FCKEditior *** --->
  <cffunction name="editInPlaceFCK"
             access="remote"
             returntype="any"
             displayname="Edit in Place (FCKeditor)"
             hint="Edit body content items inline.">
	<cfargument name="contentObjectid" type="numeric" required="yes">
	<cfargument name="width" type="string" default="400">
	<!--- Query for this instance --->
	<cfquery name="q_getContent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT  *
		FROM  contentobject 
		WHERE (contentobjectid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contentobjectid#">)
	</cfquery>
	<cflock type="EXCLUSIVE" scope="SESSION" timeout="5">
		<cfset session.i3currentTool=application.tool.contentobject>
	</cflock>
	<cfsavecontent variable="rtn_editForm">
		<cfoutput>
			<form action="/admintools/main.cfm" method="post" name="contentobject">
			<input type="hidden" name="instanceid" value="#arguments.contentobjectid#">
			<cfloop list="#q_getContent.columnList#" index="thisField">
				<cfif findNoCase("body",thisfield,1) EQ 0>
					<cfif findNoCase("parentid",thisfield,1) EQ 0>
						<input type="hidden" name="#thisField#" value="#evaluate('q_getContent.'&thisfield)#">
					</cfif>
				</cfif>
			</cfloop>
			<input type="hidden" name="i3currentTool" value="#application.tool.contentobject#">
			<input type="hidden" name="formstep" value="commit">
			<input type="hidden" name="editInPlaceRedirect" value="http://#CGI.server_name##CGI.script_name#?previewContent=yes&contentobjectid=#arguments.contentobjectid#">
			<input type="hidden" name="tablename" value="contentobject">			
			<cfscript>
                fckEditor = createObject("component", "#application.globalPath#/fckeditor/#application.fckVersion#/fckeditor");								
                fckEditor.basePath		= "#application.globalPath#/fckeditor/#application.fckVersion#/";
                fckEditor.instanceName	= "contentobjectbody";
                fckEditor.value			= q_getContent.contentobjectbody;
                fckEditor.width			= '100%';
				fckEditor.height		= '450';
                fckEditor.toolbarSet	= "Default";
                fckEditor.create(); // create the editor.
            </cfscript>	
			<cfif isDefined("application.customTagPath")>
				<cfmodule template="#application.customTagPath#/showButtonBar.cfm" editbuttonvalue="Update Content"
							editbuttonclass="submitbutton"
							useworkflow="1"	>
			<cfelse>
				<cfmodule template="#application.customTagPath#/showButtonBar.cfm" 
							editbuttonvalue="Update Content"
							editbuttonclass="submitbutton"
							useworkflow="1"	>
			</cfif>
			</form>
		</cfoutput>
	</cfsavecontent>
	<cfreturn rtn_editForm>
  </cffunction>
  
 <!--- *** This is the inline editor method *** CKEditor *** --->
  <cffunction name="editInPlaceckeCKE"
             access="remote"
             returntype="any"
             displayname="Edit in Place (FCKeditor)"
             hint="Edit body content items inline.">
	<cfargument name="contentObjectid" type="numeric" required="yes">
	<cfargument name="width" type="string" default="400">
	<!--- Query for this instance --->
	<cfquery name="q_getContent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT  *
		FROM  contentobject 
		WHERE (contentobjectid = #arguments.contentobjectid#)
	</cfquery>
	<cflock type="EXCLUSIVE" scope="SESSION" timeout="5">
		<cfset session.i3currentTool=application.tool.contentobject>
	</cflock>
	<cfsavecontent variable="rtn_editForm">
		<cfoutput>
			<form action="/admintools/main.cfm" method="post" name="contentobject">
			<input type="hidden" name="instanceid" value="#arguments.contentobjectid#">
			<cfloop list="#q_getContent.columnList#" index="thisField">
				<cfif findNoCase("body",thisfield,1) EQ 0>
					<cfif findNoCase("parentid",thisfield,1) EQ 0>
						<input type="hidden" name="#thisField#" value="#evaluate('q_getContent.'&thisfield)#">
					</cfif>
				</cfif>
			</cfloop>
			<input type="hidden" name="i3currentTool" value="#application.tool.contentobject#">
			<input type="hidden" name="formstep" value="commit">
			<input type="hidden" name="editInPlaceRedirect" value="http://#CGI.server_name##CGI.script_name#?previewContent=yes&contentobjectid=#arguments.contentobjectid#">
			<input type="hidden" name="tablename" value="contentobject">			
			<!---<cfscript>
                fckEditor = createObject("component", "#application.globalPath#/fckeditor/#application.fckVersion#/fckeditor");								
                fckEditor.basePath		= "#application.globalPath#/fckeditor/#application.fckVersion#/";
                fckEditor.instanceName	= "contentobjectbody";
                fckEditor.value			= q_getContent.contentobjectbody;
                fckEditor.width			= '100%';
				fckEditor.height		= '450';
                fckEditor.toolbarSet	= "Default";
                fckEditor.create(); // create the editor.
            </cfscript>	--->
				<cf_ckeditor
					id="contentobjectbody"
					value="#q_getContent.contentobjectbody#" 
					CKEditorToolbar="standard" />
			<cfif isDefined("application.customTagPath")>
				<cfmodule template="#application.customTagPath#/showButtonBar.cfm" editbuttonvalue="Update Content"
							editbuttonclass="submitbutton"
							useWorkFlow="1"	>
			<cfelse>
				<cfmodule template="#application.customTagPath#/showButtonBar.cfm" 
							editbuttonvalue="Update Content"
							editbuttonclass="submitbutton"
							useWorkFlow="1"	>
			</cfif>
			</form>
		</cfoutput>
	</cfsavecontent>
	<cfreturn rtn_editForm>
  </cffunction>
  
   <!--- *** This is the preview (live or not) editor method *** --->
    <cffunction name="previewContent"
             access="remote"
             returntype="any"
             displayname="Preview Content"
             hint="Preview body content items inline, live or not.">
	<cfargument name="contentObjectid" type="numeric" required="yes">
	<cfargument name="width" type="string" default="400">
	<!--- Query for this intance --->
	<cfquery name="q_getContent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT  contentobjectid, contentobjectbody
		FROM  contentobject 
		WHERE (contentobjectid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contentobjectid#">)
	</cfquery>
	<cfreturn q_getContent.contentobjectbody>
  </cffunction>
<!--- *** Get a specific content object *** --->
    <cffunction name="showThisContent"
             access="remote"
             returntype="any"
             displayname="Show Specific Content"
             hint="Force a particular content element to display.">
	<cfargument name="contentObjectid" type="numeric" required="yes">
	<!--- Query for this intance --->
	<cfquery name="q_getContent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT  contentobjectid, contentobjectbody
		FROM  contentobject 
		WHERE (contentobjectid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contentobjectid#">)
	</cfquery>
	<cfsavecontent variable="rtn_previewContent">
		<cfoutput>
			#q_getContent.contentobjectbody#
		</cfoutput>
	</cfsavecontent>
	<cfreturn rtn_previewContent>
  </cffunction>
</cfcomponent>
