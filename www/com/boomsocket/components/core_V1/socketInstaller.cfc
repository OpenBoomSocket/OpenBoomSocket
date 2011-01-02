<!------------------------------------------------- >

	ORIGINAL AUTHOR ::::::::: Darin Kohles (DRK)
	CREATION DATE ::::::::::: 
	LAST MODIFIED AUTHOR :::: Emile Melbourne (EOM)
	LAST MODIFIED DATE :::::: 6/24/2008
	EDIT HISTORY :::::::::::: 
		:: unknown DRK Initial Creation 
		:: 6/24/2008 EOM took code logic from \BS_Global\core_V1a\admintools\core\socketIntstaller\index.cfm and placed into this component.
		:: 6/27/2008 EOM Commented code. Refactored method names. Basically, changed "plugin" to "socket". 
	FILENAME :::::::::::::::: socketInstaller.cfc
	DESCRIPTION ::::::::::::: 
----------------------------------------------------->

<!--- EOM :: NOTE :: Remove "output" attribute from component and methods on component deployement.  Its there for the sole purpose of debugging and code learning. --->
<cfcomponent output="yes">
	<cfproperty name="sourceFolder" default="#APPLICATION.installpath#\admintools\sockets" hint="Source folder location for socket library">
	
	<!--- master function for exporting existing table into a plugin architecture --->
	<cffunction name="createPluginFromTool" access="public" returntype="string">
		<cfargument name="formobjectid" type="numeric" required="yes">
		<cfset var errorMsg="">
		<cftry>
			<cfquery name="q_ToolData" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT formobject.*, parentFormobject.formobjectname AS ParentFormObjectName
				FROM formobject 
					INNER JOIN formobject parentFormobject 
						ON formobject.parentid = parentFormobject.formobjectid
				WHERE (formobject.formobjectid = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.formobjectid#">)
			</cfquery>
			<!--- create file structure --->
			<cfif q_ToolData.formobjectid NEQ q_ToolData.parentid>
				<cfset errorMsg = "This is a Front End Form - Export the underlying tool: #q_ToolData.ParentFormObjectName# (#q_ToolData.parentid#)">
			</cfif>
			<cfif NOT len(trim(errorMsg))>
				<cfset errorMsg = createFileStructure(formobjectdata=q_ToolData)>
				<!--- export data to xml files --->
				<cfif NOT len(trim(errorMsg))>
					<cfset errorMsg = exportDataStructure(formobjectdata=q_ToolData)>
					<!--- copy files: component, dh, includes, css (if defined) --->
					<cfif NOT len(trim(errorMsg))>
						<cfset errorMsg = exportFiles(formobjectdata=q_ToolData)>
					</cfif>
				</cfif>
			</cfif>
			<cfcatch type="any">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn errorMsg>
	</cffunction>
	<!--- Create file structure to house plugin files --->
	<cffunction name="createFileStructure" access="public" returntype="string">
		<cfargument name="formobjectdata" type="query" required="yes">
		<cfset var errorMsg="">
		<cfif IsDefined('arguments.formobjectdata.datatable') AND Len(Trim(arguments.formobjectdata.datatable))>
			<cftry>
				<!--- make sure plugin directory exists --->
				<cfif NOT directoryExists("#THIS.socketFolder#")>
					<cfdirectory action="create" directory="#THIS.socketFolder#">
				</cfif>
				<!--- not found - proceed --->
				<cfif NOT directoryExists("#THIS.sourceFolder#\#arguments.formobjectdata.datatable#")>
					<cfdirectory action="create" directory="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#">
					<cfdirectory action="create" directory="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\component">
					<cfdirectory action="create" directory="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\includes">
					<cfdirectory action="create" directory="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\data">
					<cfdirectory action="create" directory="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\displayhandler">
					<cfdirectory action="create" directory="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\css">
					<cfdirectory action="create" directory="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\info">
				<cfelse>
					<cfset errorMsg = "File Structure Already Exists.<br> Building: #THIS.sourceFolder#\#arguments.formobjectdata.datatable#">
				</cfif>
				<cfcatch type="any">
					<cfrethrow>
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset errorMsg = "This tool does not have a table associated with. It it probably a Custom Custom tool and will require a manual export / import.">		
		</cfif>
		<cfreturn errorMsg>
	</cffunction>
	<!--- create xml files from data in form object table --->
	<cffunction name="exportDataStructure" access="public" returntype="string">
		<cfargument name="formobjectdata" type="query" required="yes">
		<cfset var errorMsg="">
		<cfset var index=0>
		<cfset skipList = "formobjectid,parentid,datadefinition,tabledefinition,datemodified">
		<cftry>
			<!--- build and write formobject xml file --->
			<cfset newXML = xmlNew()>
			<cfset formNode = xmlElemNew(newXML,"formobject")>
			<cfloop list="#arguments.formobjectdata.columnlist#" index="colName">
				<cfif NOT listFindNoCase(skipList,colName)>
					<cfset index=val(index+1)>
					<cfset newNode = xmlElemNew(newXML,colName)>
					<cfset newNode.xmlText = evaluate("arguments.formobjectdata.#colName#")>
					<cfset formNode.xmlChildren[index] = newNode>
				</cfif>
			</cfloop>
			<cfset newXML.xmlRoot = formNode>
			<cffile action="write" file="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\data\objectdefinition.xml" output="#toString(newXML)#">
			<cffile action="write" file="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\data\datadefinition.xml" output="#arguments.formobjectdata.datadefinition#">
			<cffile action="write" file="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\data\tabledefinition.xml" output="#arguments.formobjectdata.tabledefinition#">
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn errorMsg>
	</cffunction>
	<!--- copy files into plugin directory --->
	<!--- TABLENAME.cfc, dh_TABLENAME.cfm, i_TABLENAME.cfm[, TABLENAME.css] --->
	<cffunction name="exportFiles" access="public" returntype="string">
		<cfargument name="formobjectdata" type="query" required="yes">
		<cfset var errorMsg="">
		<cftry>
			<!--- include files --->
			<cfif len(trim(arguments.formobjectdata.preshowform)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.preshowform#")>
				<cffile action="copy" source="#APPLICATION.installpath#\#arguments.formobjectdata.preshowform#" destination="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.preshowform,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.prevalidate)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.prevalidate#")>
				<cffile action="copy" source="#APPLICATION.installpath#\#arguments.formobjectdata.prevalidate#" destination="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.prevalidate,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.preconfirm)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.preconfirm#")>
				<cffile action="copy" source="#APPLICATION.installpath#\#arguments.formobjectdata.preconfirm#" destination="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.preconfirm,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.postconfirm)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.postconfirm#")>
				<cffile action="copy" source="#APPLICATION.installpath#\#arguments.formobjectdata.postconfirm#" destination="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.postconfirm,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.precommit)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.precommit#")>
				<cffile action="copy" source="#APPLICATION.installpath#\#arguments.formobjectdata.precommit#" destination="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.precommit,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.postcommit)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.postcommit#")>
				<cffile action="copy" source="#APPLICATION.installpath#\#arguments.formobjectdata.postcommit#" destination="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.postcommit,'/')#">
			</cfif>
			<!--- cfc --->
			<cfif fileExists("#APPLICATION.installpath#\components\#arguments.formobjectdata.datatable#.cfc")>
				<cffile action="copy" source="#APPLICATION.installpath#\components\#arguments.formobjectdata.datatable#.cfc" destination="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\component\#arguments.formobjectdata.datatable#.cfc">
			</cfif>
			<!--- dh include files --->
			<cfif fileExists("#APPLICATION.installpath#\includes\dh_#arguments.formobjectdata.datatable#.cfm")>
				<cffile action="copy" source="#APPLICATION.installpath#\includes\dh_#arguments.formobjectdata.datatable#.cfm" destination="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\displayhandler\dh_#arguments.formobjectdata.datatable#.cfm">
			</cfif>
			<cfif fileExists("#APPLICATION.installpath#\includes\i_#arguments.formobjectdata.datatable#.cfm")>
				<cffile action="copy" source="#APPLICATION.installpath#\includes\i_#arguments.formobjectdata.datatable#.cfm" destination="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\displayhandler\i_#arguments.formobjectdata.datatable#.cfm">
			</cfif>
			<!--- write default info structure --->
			<cfset newXML =xmlNew()>
			<cfset infoRoot = xmlElemNew(newXML,"info")>
			<cfset nameNode = xmlElemNew(newXML,"toolname")>
			<cfset nameNode.xmlText = arguments.formobjectdata.formobjectname>
			<cfset infoRoot.xmlChildren[1] = nameNode>
			<cfset tableNode = xmlElemNew(newXML,"tablename")>
			<cfset tableNode.xmlText = arguments.formobjectdata.datatable>
			<cfset infoRoot.xmlChildren[2] = tableNode>
			<cfset dddNode = xmlElemNew(newXML,"defaultDDD")>
			<cfset dddNode.xmlText = "dh_#arguments.formobjectdata.datatable#.cfm">
			<cfset infoRoot.xmlChildren[3] = dddNode>
			<cfset versionNode = xmlElemNew(newXML,"version")>
			<cfset versionNode.xmlText = "0.1">
			<cfset infoRoot.xmlChildren[4] = versionNode>
			<cfset creatorNode = xmlElemNew(newXML,"creator")>
			<cfset creatorNode.xmlText = "Digital Positions">
			<cfset infoRoot.xmlChildren[5] = creatorNode>
			<cfset descriptionNode = xmlElemNew(newXML,"description")>
			<cfset descriptionNode.xmlText = xmlformat(#arguments.formobjectdata.description#)>
			<cfset infoRoot.xmlChildren[6] = descriptionNode>
			<cfset newXML.xmlRoot = infoRoot>
			<cffile action="write" file="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\info\info.xml" output="#toString(newXML)#">
		
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn errorMsg>
	</cffunction>

	<!--- Install a socket. --->
	<!--- EOM :: NOTE ::  This needs to be an atomic process.  If failure, site needs to be restored to the last GOOD state prior to tool install. Not atomic yet--->
	<!--- EOM :: NOTE ::  Pass in additional unrequired arguments which will be for a custom tool install --->
	<cffunction name="importPlugin" access="public" returntype="struct" output="yes">
		<cfargument name="pluginname" type="string" required="yes">
		<cfargument name="sourceFolder" type="string" required="no" default="sockets">
		<cfargument name="toolOnly" type="boolean" required="no" default="0">
		
		<cfargument name="tablename" type="string" required="no">
		<cfargument name="tableLabel" type="string" required="no">
		<cfargument name="formEnvironmentID" type="string" required="no">
		<cfargument name="toolcategoryid" type="string" required="no">
		<cfargument name="useWorkFlow" type="string" required="no">
		<cfargument name="useOrdinal" type="string" required="no">
		<cfargument name="bulkdelete" type="string" required="no">
		<cfargument name="singleRecord" type="string" required="no">
		<cfargument name="useVanityURL" type="string" required="no">
		<cfargument name="isNavigable" type="string" required="no">
		
		<cfset var returnVar = structNew()>
		<cfset var errorMsg = "">
		<cfset toolID = 0>

		<cfif isDefined("ARGUMENTS.sourceFolder") AND len(ARGUMENTS.sourceFolder)>
			<cfset THIS.sourceFolder = ARGUMENTS.sourceFolder>
		</cfif>
		
		<cfif NOT isDefined('ARGUMENTS.tablename') OR len(trim(ARGUMENTS.tablename)) EQ 0>
			<cfset ARGUMENTS.tablename = ARGUMENTS.pluginname>
		</cfif>
		<cftry>
			<cfquery name="q_usageCheck" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT datatable
				FROM formobject
				WHERE datatable = '#trim(ARGUMENTS.tablename)#'
			</cfquery>
			<!--- check for existence of socket and its installation state :: Two critereia determine this a socket is installed. 1. sockets has a record in formobject table. 2. There is a folder with same name and the table name in the /admintools/sockets/folder --->
			<cfif (q_usageCheck.recordcount EQ 0) AND directoryExists("#APPLICATION.installpath#\admintools\#ARGUMENTS.sourceFolder#\#ARGUMENTS.pluginname#")>
				<!--- read objectdefinition file and load into FORM scope --->
				<cffile action="read" 
						  file="#APPLICATION.installpath#\admintools\#ARGUMENTS.sourceFolder#\#ARGUMENTS.pluginname#\data\objectdefinition.xml" 
						  variable="objectXML">
				<cfset objectXML = xmlParse(objectXML)>
				<cfset objectData = objectXML.xmlRoot.xmlChildren>
				<cfloop from="1" to="#arrayLen(objectData)#" index="i">
					<cfset "FORM.#objectData[i].xmlName#" = objectData[i].xmlText>
				</cfloop>
				<!--- If this is a custom socket install. Use ARGUMENTS to set properties of socket rather than using the socket properties stored in the objectdefinition.xml file ---->
				<cfif isDefined('ARGUMENTS.tablename')>
					<cfset FORM.datatable = ARGUMENTS.tablename>
				</cfif>
				<cfif isDefined('ARGUMENTS.tableLabel')>
					<cfset FORM.label = ARGUMENTS.tableLabel>
					<cfset FORM.formobjectname = ARGUMENTS.tableLabel>
				</cfif>
				<!--- Read in the data definition from the XML file --->
				<cffile action="read" 
						file="#APPLICATION.installpath#\admintools\#ARGUMENTS.sourceFolder#\#ARGUMENTS.pluginname#\data\datadefinition.xml" 
						variable="dataXML">
				<!--- get an array of structs. Each struct holds all properties pertaining to a socket dataField. This information comes from the sockets/{socket name}/datadefinition.xml file --->
				<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" 
						action="XML2CFML"
						input="#dataXML#"
						output="a_formelements">

				<!--- if custom tool install Change {socket}id and {socket}name data field names to reflect new socket --->
				<cfloop from="1" to="#arrayLen(a_formelements)#" index="i">
					<cfif a_formelements[i]['FIELDNAME'] EQ "#ARGUMENTS.pluginname#id">
						<cfset a_formelements[i]['FIELDNAME'] = "#ARGUMENTS.tablename#id">
					</cfif>
					<cfif a_formelements[i]['fieldname'] EQ "#ARGUMENTS.pluginname#name">
						<cfset a_formelements[i]['FIELDNAME'] = "#ARGUMENTS.tablename#name">
					</cfif>
					<cfif a_formelements[i]['fieldname'] EQ "formname">
						<cfset a_formelements[i]['FIELDNAME'] = ARGUMENTS.tablename>
					</cfif>
				</cfloop>
				<!--- Convert CF Object back into XML and Set as a Form Scope Variable --->
				<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="CFML2XML"
					input="#a_formelements#"
					output="FORM.datadefinition">
				
				<cffile action="read" 
						  file="#APPLICATION.installpath#\admintools\#ARGUMENTS.sourceFolder#\#ARGUMENTS.pluginname#\data\tabledefinition.xml" 
				        variable="FORM.tabledefinition">

				<!--- add description from info.xml, if available --->
				<!--- EOM :: Changed the following <cffile > "file" attribute from a partially hard coded value to the variable #ARGUMENTS.sourceFolder# --->
				<cffile action="read" 
						  file="#APPLICATION.installpath#\admintools\#ARGUMENTS.sourceFolder#\#ARGUMENTS.pluginname#\info\info.xml" 
						  variable="infoXML">
				<!---<cffile action="read" file="#THIS.sourceFolder#\#ARGUMENTS.pluginname#\info\info.xml" variable="infoXML">--->
				<cfset infoXML = xmlParse(infoXML)>
				<cfif isDefined('infoXML.xmlRoot.description') AND len(trim(infoXML.xmlRoot.description.xmlText))>
					<cfset FORM.description = infoXML.xmlRoot.defaultDDD.xmlText>
				</cfif>
				
				<!--- EOM :: NOTE ::  Where did the insertid variable come from/ get set --->
				<!--- EOM :: REMOVE LINE :: ---> <cfdump var="#FORM#">
				
				<!--- EOM :: NOTE :: Update sockets properties custom fields Declared in ARGUMENTS Scope HERE --->

				<cfset FORM.pluginname = ARGUMENTS.pluginname><!--- Keep a copy of initial socket name --->

				<cfset FORM.tableLabel = ARGUMENTS.tableLabel>
				<cfset FORM.formEnvironmentID = ARGUMENTS.formEnvironmentID>
				<cfset FORM.toolcategoryid = ARGUMENTS.toolcategoryid>
				<cfset FORM.useWorkFlow = ARGUMENTS.useWorkFlow>
				<cfset FORM.useOrdinal = ARGUMENTS.useOrdinal>
				<cfset FORM.bulkdelete = ARGUMENTS.bulkdelete>
				<cfset FORM.singleRecord = ARGUMENTS.singleRecord>
				<cfset FORM.useVanityURL = ARGUMENTS.useVanityURL>
				<cfset FORM.isNavigable = ARGUMENTS.isNavigable>

				<cfset FORM.preshowform = ReplaceNoCase(FORM.preshowform,ARGUMENTS.pluginName,FORM.datatable)>
				<cfset FORM.prevalidate = ReplaceNoCase(FORM.prevalidate,ARGUMENTS.pluginName,FORM.datatable)>
				<cfset FORM.preconfirm = ReplaceNoCase(FORM.preconfirm,ARGUMENTS.pluginName,FORM.datatable)>
				<cfset FORM.precommit = ReplaceNoCase(FORM.precommit,ARGUMENTS.pluginName,FORM.datatable)>
				<cfset FORM.postcommit = ReplaceNoCase(FORM.postcommit,ARGUMENTS.pluginName,FORM.datatable)>

				<!--- use dbaction to insert objects instance --->	
				<cfset FORM.datemodified = createODBCDateTime(Now())>
				<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
						    datasource="#application.datasource#"
						    tablename="formobject"
						    assignidfield="formobjectid">
				<cfset FORM.formobjectid=insertid>
				
				<!--- Update new formobject to set it's parentID to itself which indicates to the system that it's a TOOL not a FE Form --->
				<cfquery name="q_updateParentid" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE #ARGUMENTS.tablename#
					SET parentid = insertID
					WHERE #ARGUMENTS.tablename#id = insertID
				</cfquery>
				<!--- add seed table entry --->
				<cfquery name="q_appendID" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO tableID (tableName,ID) 
					VALUES ('<cfif isDefined('ARGUMENTS.tablename')>#ARGUMENTS.tablename#<cfelse>#ARGUMENTS.pluginname#</cfif>',100000)
				</cfquery>
				<!--- add userpermissions --->
				<cfquery name="q_addPerms" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO userpermission (userid, formobjectid, addedit, access, remove, approve)
					VALUES (100000, #FORM.formobjectid#, 1, 1, 1, 1)
				</cfquery>
				
				<cfset errorMsg = createTable(formobjectdata=FORM)>
				<cfif NOT ARGUMENTS.toolOnly>
					<cfset errorMsg = errorMsg & "<br>" & importFiles(formobjectdata=FORM)>
					<cfset errorMsg = errorMsg & "<br>" & registerDisplayHandler(formobjectdata=FORM)>
				</cfif>
				<cfset "Application.tool.#ARGUMENTS.tablename#" = FORM.formobjectid>
				<cfset blah = addNavItem(toolID=FORM.formobjectid, toolName=form.FORMOBJECTNAME)>
			<!--- We cannot proceed in the installation, so return an error--->
			<cfelse>
				<cfif NOT directoryExists("#APPLICATION.installpath#\admintools\#ARGUMENTS.sourceFolder#\#ARGUMENTS.pluginname#")>
					<cfset errorMsg = errorMsg&"<br>"&"No such plugin exists: "&#ARGUMENTS.pluginname#>
				<cfelseif (q_usageCheck.recordcount NEQ 0)>
					<cfset errorMsg = errorMsg&"<br>"&"Table already exists: "&#ARGUMENTS.tablename#>
				</cfif>
			</cfif>
			<cfset returnVar['errorMsg']=errorMsg>
			<cfset returnVar['toolID']=FORM.formobjectid>
			<cfcatch type="any">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn returnVar>
	</cffunction>
	
	<cffunction name="createTable" access="public" returntype="string">
		<cfargument name="formobjectdata" type="struct" required="yes">
		<cfargument name="currentName" type="string" required="no">
		<cfset var errorMsg="">
		<cftry>
			<!--- convert datadefinition xml to array structure --->
			<cfset oldName = arguments.formobjectdata.datatable>
			<cfif isDefined('ARGUMENTS.currentName')>
				<cfset oldName = ARGUMENTS.currentName>
			</cfif>
			<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" 
				       action="XML2CFML"
				    	 input="#arguments.formobjectdata.datadefinition#"
					  	 output="a_formelements">
						 
			<!--- create table --->
			<cfquery datasource="#application.datasource#" name="q_createTable" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				CREATE TABLE #trim(arguments.formobjectdata.datatable)# ([#trim(arguments.formobjectdata.datatable)#id] [int] NOT NULL) ON [PRIMARY];
				ALTER TABLE [#trim(arguments.formobjectdata.datatable)#] WITH NOCHECK ADD 
				CONSTRAINT [PK_#trim(arguments.formobjectdata.datatable)#] PRIMARY KEY  NONCLUSTERED 
				(
					[#trim(arguments.formobjectdata.datatable)#id]
				)  ON [PRIMARY] 
			</cfquery>
			<!--- add fields --->
			<cfquery datasource="#application.datasource#" name="q_addIDColumn" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				ALTER TABLE #trim(arguments.formobjectdata.datatable)#
				ADD [#trim(arguments.formobjectdata.datatable)#name] nvarchar(500) NULL
			</cfquery>
			<cfloop from="1" to="#arrayLen(a_formelements)#" index="j">
				<cfif (a_formelements[j]['FIELDNAME'] NEQ "#oldName#id") AND (a_formelements[j]['FIELDNAME'] NEQ "#oldName#name") AND (a_formelements[j]['COMMIT'] EQ 1)>
					<cfif (trim(a_formelements[j]['DATATYPE']) EQ "nvarchar") OR (trim(a_formelements[j]['DATATYPE'] EQ "varchar"))>
						<cfset datatype =  trim(a_formelements[j]['DATATYPE'])&" ("&trim(a_formelements[j]['LENGTH'])&")">
					<cfelse>
						<cfset datatype = trim(a_formelements[j]['DATATYPE'])>
					</cfif>
					<cfquery datasource="#application.datasource#" name="q_addIDColumn" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						ALTER TABLE #trim(arguments.formobjectdata.datatable)#
						ADD [#trim(a_formelements[j]['FIELDNAME'])#] #datatype# NULL
					</cfquery>
				</cfif>
			</cfloop>
			<cfquery datasource="#application.datasource#" name="q_addIDColumn" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				ALTER TABLE #trim(arguments.formobjectdata.datatable)#
				ADD [ordinal] int NULL
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn errorMsg>
	</cffunction>
	<!--- copy files from plugin directory ---><!--- EOM :: NOTE :: This function is reponsible for the copying (and renamin) of files in socket folder into the local boomsocket site instiallion.--->
	<!--- TABLENAME.cfc, dh_TABLENAME.cfm, i_TABLENAME.cfm[, TABLENAME.css] --->
	<cffunction name="importFiles" access="public" returntype="string">
		<cfargument name="formobjectdata" type="struct" required="yes">
		<cfset var errorMsg="">
		<cftry>
			<!--- create include directory --->
			<cfdirectory action="create" directory="#APPLICATION.installpath#\admintools\includes\#arguments.formobjectdata.datatable#">
			<!--- include files --->
			<cfif len(trim(arguments.formobjectdata.preshowform)) AND fileExists("#THIS.sourceFolder#\#arguments.formobjectdata.pluginname#\includes\#listlast(arguments.formobjectdata.preshowform,'/')#")>
				<cffile action="copy" 
						  destination="#APPLICATION.installpath#\#arguments.formobjectdata.preshowform#" 
						  source="#THIS.sourceFolder#\#arguments.formobjectdata.pluginname#\includes\#listlast(arguments.formobjectdata.preshowform,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.prevalidate)) AND fileExists("#THIS.sourceFolder#\#arguments.formobjectdata.pluginname#\includes\#listlast(arguments.formobjectdata.prevalidate,'/')#")>
				<cffile action="copy" 
						  destination="#APPLICATION.installpath#\#arguments.formobjectdata.prevalidate#" 
						  source="#THIS.sourceFolder#\#arguments.formobjectdata.pluginname#\includes\#listlast(arguments.formobjectdata.prevalidate,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.preconfirm)) AND fileExists("#THIS.sourceFolder#\#arguments.formobjectdata.pluginname#\includes\#listlast(arguments.formobjectdata.preconfirm,'/')#")>
				<cffile action="copy" 
						  destination="#APPLICATION.installpath#\#arguments.formobjectdata.preconfirm#" 
						  source="#THIS.sourceFolder#\#arguments.formobjectdata.pluginname#\includes\#listlast(arguments.formobjectdata.preconfirm,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.postconfirm)) AND fileExists("#THIS.sourceFolder#\#arguments.formobjectdata.pluginname#\includes\#listlast(arguments.formobjectdata.postconfirm,'/')#")>
				<cffile action="copy" 
					  	  destination="#APPLICATION.installpath#\#arguments.formobjectdata.postconfirm#" 
						  source="#THIS.sourceFolder#\#arguments.formobjectdata.pluginname#\includes\#listlast(arguments.formobjectdata.postconfirm,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.precommit)) AND fileExists("#THIS.sourceFolder#\#arguments.formobjectdata.pluginname#\includes\#listlast(arguments.formobjectdata.precommit,'/')#")>
				<cffile action="copy" 
						  destination="#APPLICATION.installpath#\#arguments.formobjectdata.precommit#" 
				 		  source="#THIS.sourceFolder#\#arguments.formobjectdata.pluginname#\includes\#listlast(arguments.formobjectdata.precommit,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.postcommit)) AND fileExists("#THIS.sourceFolder#\#arguments.formobjectdata.pluginname#\includes\#listlast(arguments.formobjectdata.postcommit,'/')#")>
				<cffile action="copy" 
						  destination="#APPLICATION.installpath#\#arguments.formobjectdata.postcommit#" 
						  source="#THIS.sourceFolder#\#arguments.formobjectdata.pluginname#\includes\#listlast(arguments.formobjectdata.postcommit,'/')#">
			</cfif>
			<!--- cfc --->
			<cfif fileExists("#THIS.sourceFolder#\#arguments.formobjectdata.plugginname#\component\#arguments.formobjectdata.pluginname#.cfc")>
				<cffile action="copy" 
						  source="#THIS.sourceFolder#\#arguments.formobjectdata.plugginname#\component\#arguments.formobjectdata.pluginname#.cfc"
						  destination="#APPLICATION.installpath#\admintools\components\#arguments.formobjectdata.datatable#.cfc" >
			</cfif>
			<!--- dh include files --->
			<cfif fileExists("#THIS.sourceFolder#\#arguments.formobjectdata.plugginname#\displayhandler\dh_#arguments.formobjectdata.plugginname#.cfm")>
				<cffile action="copy" 
						  source="#THIS.sourceFolder#\#arguments.formobjectdata.plugginname#\displayhandler\dh_#arguments.formobjectdata.plugginname#.cfm"
						  destination="#APPLICATION.installpath#\includes\dh_#arguments.formobjectdata.datatable#.cfm" >
			</cfif>
			<cfif fileExists("#THIS.sourceFolder#\#arguments.formobjectdata.plugginname#\displayhandler\i_#arguments.formobjectdata.plugginname#.cfm")>
				<cffile action="copy" 
						  source="#THIS.sourceFolder#\#arguments.formobjectdata.plugginname#\displayhandler\i_#arguments.formobjectdata.plugginname#.cfm"
						  destination="#APPLICATION.installpath#\includes\i_#arguments.formobjectdata.datatable#.cfm" >
			</cfif>
			
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn errorMsg>
	</cffunction>
	<cffunction name="registerDisplayHandler" access="public" returntype="string">
		<cfargument name="formobjectdata" type="struct" required="yes">
		<cfset var errorMsg="">
		<cftry>
			<!--- add displayhandler registartions --->
			<cffile action="read" file="#THIS.sourceFolder#\#arguments.formobjectdata.datatable#\info\info.xml" variable="infoXML">
			<cfset infoXML = xmlParse(infoXML)>
			<cfif isDefined('infoXML.xmlRoot.defaultDDD') AND len(trim(infoXML.xmlRoot.defaultDDD.xmlText))>
				<cfset dddName = infoXML.xmlRoot.defaultDDD.xmlText>
			<cfelse>
				<cfset dddName = "dh_#arguments.formobjectdata.datatable#.cfm">
			</cfif>
			<cfset FORM.datecreated = createODBCDateTime(Now())>
			<cfset FORM.datemodified = createODBCDateTime(Now())>
			<cfset FORM.displayhandlername = arguments.formobjectdata.formobjectname>
			<cfset FORM.custominclude = dddName>
			<cfset FORM.toolid = arguments.formobjectdata.formobjectid>
			<!--- skip actual registration if file doesn't exist --->
			<cfif fileExists('#APPLICATION.installpath#/includes/#dddName#')>
				<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
					datasource="#application.datasource#"
					tablename="displayhandler"
					assignidfield="displayhandlerid">
			</cfif>
			<!--- write entry into socket table to show registration --->
			<cfif isDefined('infoXML.xmlRoot.version') AND len(trim(infoXML.xmlRoot.version.xmlText))>
				<cfset version = infoXML.xmlRoot.version.xmlText>
			<cfelse>
				<cfset version = "Unknown">
			</cfif>
			<cfset FORM.version = version>
			<cfif isDefined('infoXML.xmlRoot.creator') AND len(trim(infoXML.xmlRoot.creator.xmlText))>
				<cfset creator = infoXML.xmlRoot.creator.xmlText>
			<cfelse>
				<cfset creator = "Anonymous">
			</cfif>
			<cfset FORM.creator = creator>
			<cfset FORM.formobjectid = arguments.formobjectdata.formobjectid>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
				datasource="#application.datasource#"
				tablename="socket"
				assignidfield="socketid">
			<cfcatch type="any">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn errorMsg>
	</cffunction>
	<cffunction name="uninstallPlugin" access="public" returntype="string">
		<cfargument name="formObjectID" type="string">
		<cfset var errorMsg="">
		<cftry>
			<cfquery name="q_toolInfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT *
				FROM formobject
				WHERE formobjectid = #ARGUMENTS.formObjectID#
			</cfquery>
			<!--- remove db entries --->
			<cfset errorMsg = cleanDB(formobjectdata=q_toolInfo)>
			<!--- remove files --->
			<cfset errorMsg = cleanFiles(formobjectdata=q_toolInfo)>
			<cfcatch type="any">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn errorMsg>
	</cffunction>
	<cffunction name="cleanDB" access="public" returntype="string">
		<cfargument name="formobjectdata" type="query" required="yes">
		<cfset var errorMsg="">
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_droptable" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DROP TABLE #trim(arguments.formobjectdata.datatable)#
			</cfquery>
			<cfquery datasource="#application.datasource#" name="q_dropSeedObject" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE FROM formobject
				WHERE formobjectid = '#trim(arguments.formobjectdata.formobjectid)#'
			</cfquery>
			<cfquery datasource="#application.datasource#" name="q_dropSeedObject" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE FROM tableID
				WHERE TableName = '#trim(arguments.formobjectdata.datatable)#'
			</cfquery>
			<cfquery datasource="#application.datasource#" name="q_dropPermissions" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE FROM userpermission
				WHERE formobjectid = '#arguments.formobjectdata.formobjectid#'
			</cfquery>
			<cfquery datasource="#application.datasource#" name="q_dropDisplayhandler" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE FROM displayhandler
				WHERE toolid = '#arguments.formobjectdata.formobjectid#'
			</cfquery>
			<cfcatch type="any">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn errorMsg>
	</cffunction>
	<cffunction name="cleanFiles" access="public" returntype="string">
		<cfargument name="formobjectdata" type="query" required="yes">
		<cfset var errorMsg="">
		<cftry>
			<!--- include files --->
			<cfif len(trim(arguments.formobjectdata.preshowform)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.preshowform#")>
				<cffile action="delete" file="#APPLICATION.installpath#\#arguments.formobjectdata.preshowform#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.prevalidate)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.prevalidate#")>
				<cffile action="delete" file="#APPLICATION.installpath#\#arguments.formobjectdata.prevalidate#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.preconfirm)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.preconfirm#")>
				<cffile action="delete" file="#APPLICATION.installpath#\#arguments.formobjectdata.preconfirm#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.postconfirm)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.postconfirm#")>
				<cffile action="delete" file="#APPLICATION.installpath#\#arguments.formobjectdata.postconfirm#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.precommit)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.precommit#")>
				<cffile action="delete" file="#APPLICATION.installpath#\#arguments.formobjectdata.precommit#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.postcommit)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.postcommit#")>
				<cffile action="delete" file="#APPLICATION.installpath#\#arguments.formobjectdata.postcommit#">
			</cfif>
			<!--- delete include directory --->
			<cfdirectory action="delete" directory="#APPLICATION.installpath#\admintools\includes\#arguments.formobjectdata.datatable#">
			<!--- delete cfc --->
			<cfif fileExists("#APPLICATION.installpath#\components\#arguments.formobjectdata.datatable#.cfc")>
				<cffile action="delete" file="#APPLICATION.installpath#\components\#arguments.formobjectdata.datatable#.cfc">
			</cfif>
			<!--- delete dh include files --->
			<cfif fileExists("#APPLICATION.installpath#\includes\dh_#arguments.formobjectdata.datatable#.cfm")>
				<cffile action="delete" file="#APPLICATION.installpath#\includes\dh_#arguments.formobjectdata.datatable#.cfm">
			</cfif>
			<cfif fileExists("#APPLICATION.installpath#\includes\i_#arguments.formobjectdata.datatable#.cfm")>
				<cffile action="delete" file="#APPLICATION.installpath#\includes\i_#arguments.formobjectdata.datatable#.cfm">
			</cfif>
			<cfcatch type="any">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn errorMsg>
	</cffunction>
	<!--- Gets a list of all the sockets found in the Installed sites ./admintools/socket folder or the folder specified in the directory argument. This is a list of external sockets that are installed or can be installed. As it parses through the list, it determines whether or not the socket has been installed by checking if it has been added to formobject Table --->
	<!--- EOM :: NOTE ::  This code needs try catch block for directory not found exceptions --->
	<cffunction name="getSocketDirectoryList" access="public" returntype="query">
		<cfargument name="directory" type="string" default="sockets" required="no">
		<cftry>
			<!--- Get a list of sockets by getting a list folders in the ARUMENTS.directory folder. Each socket is in its own folder in the ARUMENTS.directory folder so filter out the directorys. --->
			<cfdirectory action="list" directory="#APPLICATION.installpath#\admintools\#ARGUMENTS.directory#" name="pluginlist">
			<cfset status = arrayNew(1)> <!--- Array tracks if tool has been added to formobject table or not.  (i.e if tool is installed or not) --->
			<cfset index = 0>
			<cfloop query="pluginlist">
				<!--- Only take note of directorys because each socket will be in its own self labeled directory --->
				<cfif pluginlist.type EQ "dir"> <!--- EOM :: Is this neccessary, Does ColdFusion < cfdirectory >return both files and directories or just directories? --->
					<cfset index = val(index+1)>
					<cfquery name="q_findTable" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT datatable
						FROM formobject
						WHERE datatable = '#trim(pluginlist.name)#'
					</cfquery>
					<!--- if record return, (socket is in formobject table and subsequently installed), notate this fact. --->
					<cfif q_findTable.recordcount>
						<cfset status[index] = 1>
					<cfelse>
						<cfset status[index] = 0>
					</cfif>
				</cfif>
			</cfloop>
			<!--- Add the installed/uninstalled status of each socket to the pluginlist and return --->
			<cfset blah = queryAddColumn(pluginlist,"Status",status)>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn pluginlist>
	</cffunction>
	<cffunction name="addNavItem" access="public" output="false" returntype="void">
		<cfargument name="toolID" type="numeric" required="yes">
		<cfargument name="toolName" type="string" required="yes">
		<cftry>
			<!--- For New Tool creation, create corresponding navigation items --->
			<cfset form.navitemaddressname = "#ARGUMENTS.toolName#">
			<cfset form.formobjecttableid = ARGUMENTS.toolID>
			<cfset form.urlpath = "/admintools/index.cfm?i3currenttool=#ARGUMENTS.toolID#">
			<cfset form.permissionbased = 1>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT" 
				tablename="navitemaddress"
				datasource="#application.datasource#"
				assignidfield="navitemaddressid">
				<cfset form.navitemname = ARGUMENTS.toolName>
			<cfset form.navitemaddressid = insertid>
			<cfset form.parentid = 1005>
			<cfquery name="q_nextOrdinal" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT TOP 1 ordinal
				FROM navitem
				ORDER BY ordinal DESC
			</cfquery>
			<cfset form.ordinal = val(q_nextOrdinal.ordinal)+1>
			<cfset form.navgroupid = 1000>
			<cfset form.target = "_self">
			<cfset form.active = 1>
			<cfset form.pageid = 0>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT" 
				tablename="navitem"
				datasource="#application.datasource#"
				assignidfield="navitemid">
			<cfcatch type="any">
				<cfrethrow>
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="removeNavItem" output="false" returntype="void">
		<cfargument name="toolID" type="numeric" required="yes">
		<cftry>
			<!--- Delete admin navigation elements to clean up after removal, this includes 
			dynamic nav items that are based on instances in the tool --->
			<cfquery name="q_getAddressItems" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT navitemaddressid
				FROM navitemaddress
				WHERE formobjecttableid IN (#ARGUMENTS.toolID#)
			</cfquery>
			<cfset addressdeletelist = valueList(q_getAddressItems.navitemaddressid)>
			<cfquery name="q_deleteAddressItems" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE FROM navitemaddress
				WHERE formobjecttableid IN (#ARGUMENTS.toolID#)
			</cfquery>
			<cfif IsDefined('addressdeletelist') AND ListLen(addressdeletelist) GTE 1>
				<cfquery name="q_deleteNavItems" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					DELETE FROM navitem
					WHERE navitemaddressid IN (#addressdeletelist#)
				</cfquery>
			</cfif>
			<!--- reset nav based on permissions --->
			<cfset session.allNavigation = APPLICATION.navObj.getAllNavigation(usePermissions=1)>
			<cfset session.navXML_1000 = APPLICATION.navUtilObj.getNavXML(alphaordering=0,groupid=1000,q_querydata=session.allNavigation)>
			<cfset session.navData_1000 = APPLICATION.navUtilObj.buildListingNav(navDataSource=XMLParse(SESSION.navXML_1000).XMLRoot.XMLChildren,textOnly=0,classBase="adminnavlist",topOnly=0,editmode=0)>
			<cfcatch type="any">
				<cfrethrow>
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction access="public" name="getTableInfo" output="false" returntype="query" displayname="getTableInfo">
    	<cfargument name="formObjectID" required="no" type="numeric">
		<cftry>
			<cfquery name="q_getTableInfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
                SELECT formobjectid, formobjectname
                FROM formobject
                WHERE 
                <cfif IsDefined('arguments.formObjectID') AND arguments.formObjectID GTE 100000>
                	formobjectid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formObjectID#">
				<cfelse>
                	(formobjectid >= 100000) AND (formobjectid = parentid) AND (isNull(externalTool,0) = 0)
				</cfif>
            </cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getTableInfo>
	</cffunction>


	<!--- If found, returns a record from the socket table on a particular socket. --->
	<cffunction name="getSocketData" access="public" returntype="query" output="yes">
		<cfargument name="socketName" type="string" required="yes">
		<cftry>
			<cfquery name="q_socketData" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT socketid,socketname,datemodified,creator,version,formobjectid
			FROM socket
			WHERE tablename = '#ARGUMENTS.socketName#'
		</cfquery>
			<cfset myResult="#q_socketData#">
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn myResult>
	</cffunction>
	<!--- If found, returns data record on a particular socket from the the formobject table. --->
	<cffunction name="getSocketDataFromFormObjectTable" access="public" returntype="query" output="yes">
		<cfargument name="socketName" type="string" required="yes">
		<cftry>
			<cfquery name="q_socketData" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT formobjectname AS socketname, datemodified, formobjectid
			FROM formobject
			WHERE datatable = '#ARGUMENTS.socketName#'	
		</cfquery>
			<cfset myResult="#q_socketData#">
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn myResult>
	</cffunction>
	
	<!---- This method returns in an xml format the socket object data for a specified file. The xml for this is located in admintools/sockets/{socket name}/data/objectdefinition.xml for the boom site installation folder. ---->
	<!--- EOM :: NOTE ::  This code needs try catch block for file not found exceptions --->
	<cffunction name="getSocketObjectDefinition_xml" access="public" returntype="xml" output="no">
		<cfargument name="socketName" type="string" required="yes">
		<cfset xmlData = xmlNew()>
		
		<!--- Retrieve the xml file from the specified URL --->
		<cfset sitePath= expandPath('/')>
		<cffile action="read" file="#sitePath#/admintools/sockets/#ARGUMENTS.socketName#/data/objectdefinition.xml"  variable="xmlDocument">
		<cfset xmlData = XMLParse(xmlDocument, "yes")>
		<cfreturn xmlData>
	</cffunction>
</cfcomponent>
