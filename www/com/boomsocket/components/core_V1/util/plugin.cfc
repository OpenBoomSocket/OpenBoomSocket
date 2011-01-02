<cfcomponent>
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
				<cfif NOT directoryExists("#APPLICATION.installpath#\admintools\sockets")>
					<cfdirectory action="create" directory="#APPLICATION.installpath#\admintools\sockets">
				</cfif>
				<!--- not found - proceed --->
				<cfif NOT directoryExists("#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#")>
					<cfdirectory action="create" directory="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#">
					<cfdirectory action="create" directory="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\component">
					<cfdirectory action="create" directory="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes">
					<cfdirectory action="create" directory="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\data">
					<cfdirectory action="create" directory="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\displayhandler">
					<cfdirectory action="create" directory="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\css">
					<cfdirectory action="create" directory="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\info">
				<cfelse>
					<cfset errorMsg = "File Structure Already Exists.<br> Building: #APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#">
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
			<cffile action="write" file="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\data\objectdefinition.xml" output="#toString(newXML)#">
			<cffile action="write" file="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\data\datadefinition.xml" output="#arguments.formobjectdata.datadefinition#">
			<cffile action="write" file="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\data\tabledefinition.xml" output="#arguments.formobjectdata.tabledefinition#">
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
				<cffile action="copy" source="#APPLICATION.installpath#\#arguments.formobjectdata.preshowform#" destination="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.preshowform,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.prevalidate)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.prevalidate#")>
				<cffile action="copy" source="#APPLICATION.installpath#\#arguments.formobjectdata.prevalidate#" destination="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.prevalidate,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.preconfirm)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.preconfirm#")>
				<cffile action="copy" source="#APPLICATION.installpath#\#arguments.formobjectdata.preconfirm#" destination="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.preconfirm,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.postconfirm)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.postconfirm#")>
				<cffile action="copy" source="#APPLICATION.installpath#\#arguments.formobjectdata.postconfirm#" destination="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.postconfirm,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.precommit)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.precommit#")>
				<cffile action="copy" source="#APPLICATION.installpath#\#arguments.formobjectdata.precommit#" destination="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.precommit,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.postcommit)) AND fileExists("#APPLICATION.installpath#\#arguments.formobjectdata.postcommit#")>
				<cffile action="copy" source="#APPLICATION.installpath#\#arguments.formobjectdata.postcommit#" destination="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.postcommit,'/')#">
			</cfif>
			<!--- cfc --->
			<cfif fileExists("#APPLICATION.installpath#\components\#arguments.formobjectdata.datatable#.cfc")>
				<cffile action="copy" source="#APPLICATION.installpath#\components\#arguments.formobjectdata.datatable#.cfc" destination="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\component\#arguments.formobjectdata.datatable#.cfc">
			</cfif>
			<!--- dh include files --->
			<cfif fileExists("#APPLICATION.installpath#\includes\dh_#arguments.formobjectdata.datatable#.cfm")>
				<cffile action="copy" source="#APPLICATION.installpath#\includes\dh_#arguments.formobjectdata.datatable#.cfm" destination="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\displayhandler\dh_#arguments.formobjectdata.datatable#.cfm">
			</cfif>
			<cfif fileExists("#APPLICATION.installpath#\includes\i_#arguments.formobjectdata.datatable#.cfm")>
				<cffile action="copy" source="#APPLICATION.installpath#\includes\i_#arguments.formobjectdata.datatable#.cfm" destination="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\displayhandler\i_#arguments.formobjectdata.datatable#.cfm">
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
			<cffile action="write" file="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\info\info.xml" output="#toString(newXML)#">
		
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn errorMsg>
	</cffunction>
	<cffunction name="importPlugin" access="public" returntype="struct">
		<cfargument name="pluginname" type="string" required="yes">
		<cfargument name="sourceFolder" type="string" required="no" default="sockets">
		<cfargument name="toolOnly" type="boolean" required="no" default="0">
		<cfargument name="tablename" type="string" required="no">
		<cfargument name="tableLabel" type="string" required="no">
		<cfset var returnVar = structNew()>
		<cfset var errorMsg = "">
		<cfset toolID = 0>
		<cfif NOT isDefined('ARGUMENTS.tablename') OR len(trim(ARGUMENTS.tablename)) EQ 0>
			<cfset ARGUMENTS.tablename = ARGUMENTS.pluginname>
		</cfif>
		<cftry>
			<cfquery name="q_usageCheck" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT datatable
				FROM formobject
				WHERE datatable = '#trim(ARGUMENTS.tablename)#'
			</cfquery>
			<!--- check for existence of plugin and installation state --->
			<cfif (q_usageCheck.recordcount EQ 0) AND directoryExists("#APPLICATION.installpath#\admintools\#ARGUMENTS.sourceFolder#\#ARGUMENTS.pluginname#")>
				<!--- read objectdefinition file and load into FORM scope --->
				<cffile action="read" file="#APPLICATION.installpath#\admintools\#ARGUMENTS.sourceFolder#\#ARGUMENTS.pluginname#\data\objectdefinition.xml" variable="objectXML">
				<cfset objectXML = xmlParse(objectXML)>
				<cfset objectData = objectXML.xmlRoot.xmlChildren>
				<cfloop from="1" to="#arrayLen(objectData)#" index="i">
					<cfset "FORM.#objectData[i].xmlName#" = objectData[i].xmlText>
				</cfloop>
				<cfif isDefined('ARGUMENTS.tablename')>
					<cfset FORM.datatable = #ARGUMENTS.tablename#>
				</cfif>
				<cfif isDefined('ARGUMENTS.tableLabel')>
					<cfset FORM.label = #ARGUMENTS.tableLabel#>
					<cfset FORM.formobjectname = #ARGUMENTS.tableLabel#>
				</cfif>
				<!--- append definition parts --->
				<cffile action="read" file="#APPLICATION.installpath#\admintools\#ARGUMENTS.sourceFolder#\#ARGUMENTS.pluginname#\data\datadefinition.xml" variable="dataXML">
				<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
					input="#dataXML#"
					output="a_formelements">
				<cfloop from="1" to="#arrayLen(a_formelements)#" index="i">
					<cfif a_formelements[i]['FIELDNAME'] EQ "#ARGUMENTS.pluginname#id">
						<cfset a_formelements[i]['FIELDNAME'] = "#ARGUMENTS.tablename#id">
					</cfif>
					<cfif a_formelements[i]['fieldname'] EQ "#ARGUMENTS.pluginname#name">
						<cfset a_formelements[i]['FIELDNAME'] = "#ARGUMENTS.tablename#name">
					</cfif>
				</cfloop>
				<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="CFML2XML"
					input="#a_formelements#"
					output="form.datadefinition">
				<cffile action="read" file="#APPLICATION.installpath#\admintools\#ARGUMENTS.sourceFolder#\#ARGUMENTS.pluginname#\data\tabledefinition.xml" variable="tableXML">
				<cfset FORM.tabledefinition = tableXML>
				<!--- add description from info.xml, if available --->
				<cffile action="read" file="#APPLICATION.installpath#\admintools\sockets\#ARGUMENTS.pluginname#\info\info.xml" variable="infoXML">
				<cfset infoXML = xmlParse(infoXML)>
				<cfif isDefined('infoXML.xmlRoot.description') AND len(trim(infoXML.xmlRoot.description.xmlText))>
					<cfset form.description = infoXML.xmlRoot.defaultDDD.xmlText>
				</cfif>
				<!--- use dbaction to insert objects instance --->	
				<cfset FORM.datemodified = createODBCDateTime(Now())>
				<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
					datasource="#application.datasource#"
					tablename="formobject"
					assignidfield="formobjectid">
				<cfset FORM.formobjectid=insertid>
				<cfset FORM.parentid=insertid>
				<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE"
					datasource="#application.datasource#"
					tablename="formobject"
					primarykeyfield="formobjectid"
					assignidfield="formobjectid">
				<!--- add seed table entry --->
				<cfquery name="q_appendID" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO tableID (tableName,ID) VALUES ('<cfif isDefined('ARGUMENTS.tablename')>#ARGUMENTS.tablename#<cfelse>#ARGUMENTS.pluginname#</cfif>',100000)
				</cfquery>
				<!--- add userpermissions --->
				<cfquery name="q_addPerms" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO userpermission (userid, formobjectid, addedit, access, remove, approve)
					VALUES (100000, #FORM.formobjectid#, 1, 1, 1, 1)
				</cfquery>
				<cfset errorMsg = createTable(formobjectdata=FORM)>
				<cfif NOT ARGUMENTS.toolOnly>
					<cfset errorMsg = errorMsg&"<br>"&importFiles(formobjectdata=FORM)>
					<cfset errorMsg = errorMsg&"<br>"&registerDisplayHandler(formobjectdata=FORM)>
				</cfif>
				<cfset "Application.tool.#ARGUMENTS.tablename#" = FORM.formobjectid>
				<cfset blah = addNavItem(toolID=FORM.formobjectid,toolName=form.FORMOBJECTNAME)>
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
			<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
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
	<!--- copy files from plugin directory --->
	<!--- TABLENAME.cfc, dh_TABLENAME.cfm, i_TABLENAME.cfm[, TABLENAME.css] --->
	<cffunction name="importFiles" access="public" returntype="string">
		<cfargument name="formobjectdata" type="struct" required="yes">
		<cfset var errorMsg="">
		<cftry>
			<!--- create include directory --->
			<cfdirectory action="create" directory="#APPLICATION.installpath#\admintools\includes\#arguments.formobjectdata.datatable#">
			<!--- include files --->
			<cfif len(trim(arguments.formobjectdata.preshowform)) AND fileExists("#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.preshowform,'/')#")>
				<cffile action="copy" destination="#APPLICATION.installpath#\#arguments.formobjectdata.preshowform#" source="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.preshowform,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.prevalidate)) AND fileExists("#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.prevalidate,'/')#")>
				<cffile action="copy" destination="#APPLICATION.installpath#\#arguments.formobjectdata.prevalidate#" source="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.prevalidate,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.preconfirm)) AND fileExists("#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.preconfirm,'/')#")>
				<cffile action="copy" destination="#APPLICATION.installpath#\#arguments.formobjectdata.preconfirm#" source="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.preconfirm,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.postconfirm)) AND fileExists("#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.postconfirm,'/')#")>
				<cffile action="copy" destination="#APPLICATION.installpath#\#arguments.formobjectdata.postconfirm#" source="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.postconfirm,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.precommit)) AND fileExists("#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.precommit,'/')#")>
				<cffile action="copy" destination="#APPLICATION.installpath#\#arguments.formobjectdata.precommit#" source="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.precommit,'/')#">
			</cfif>
			<cfif len(trim(arguments.formobjectdata.postcommit)) AND fileExists("#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.postcommit,'/')#")>
				<cffile action="copy" destination="#APPLICATION.installpath#\#arguments.formobjectdata.postcommit#" source="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\includes\#listlast(arguments.formobjectdata.postcommit,'/')#">
			</cfif>
			<!--- cfc --->
			<cfif fileExists("#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\component\#arguments.formobjectdata.datatable#.cfc")>
				<cffile action="copy" destination="#APPLICATION.installpath#\components\#arguments.formobjectdata.datatable#.cfc" source="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\component\#arguments.formobjectdata.datatable#.cfc">
			</cfif>
			<!--- dh include files --->
			<cfif fileExists("#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\displayhandler\dh_#arguments.formobjectdata.datatable#.cfm")>
				<cffile action="copy" destination="#APPLICATION.installpath#\includes\dh_#arguments.formobjectdata.datatable#.cfm" source="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\displayhandler\dh_#arguments.formobjectdata.datatable#.cfm">
			</cfif>
			<cfif fileExists("#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\displayhandler\i_#arguments.formobjectdata.datatable#.cfm")>
				<cffile action="copy" destination="#APPLICATION.installpath#\includes\i_#arguments.formobjectdata.datatable#.cfm" source="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\displayhandler\i_#arguments.formobjectdata.datatable#.cfm">
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
			<cffile action="read" file="#APPLICATION.installpath#\admintools\sockets\#arguments.formobjectdata.datatable#\info\info.xml" variable="infoXML">
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
	<cffunction name="getPluginStatus" access="public" returntype="query">
		<cfargument name="directory" type="string" default="sockets" required="no">
		<cftry>
			<cfdirectory action="list" directory="#APPLICATION.installpath#\admintools\#ARGUMENTS.directory#" name="pluginlist">
			<cfset status = arrayNew(1)>
			<cfset index = 0>
			<cfloop query="pluginlist">
				<cfif pluginlist.type EQ "dir">
					<cfset index = val(index+1)>
					<cfquery name="q_findTable" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT datatable
						FROM formobject
						WHERE datatable = '#trim(pluginlist.name)#'
					</cfquery>
					<cfif q_findTable.recordcount>
						<cfset status[index] = 1>
					<cfelse>
						<cfset status[index] = 0>
					</cfif>
				</cfif>
			</cfloop>
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
</cfcomponent>