<cfinclude template="i_validate.cfm"> 
<cfif len(formobjectid)>
	<cfset FORM.formobjectid = formobjectid>
	<!--- get table definition --->
	<cfquery datasource="#application.datasource#" name="q_gettabledef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT tabledefinition, tablecolumns, tablerows, datadefinition, formobjectid, parentid, useOrdinal
		FROM formobject
		WHERE formobjectid = #trim(formobjectid)#
	</cfquery>
	<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
		input="#q_gettabledef.tabledefinition#"
		output="a_tableelements">
	<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
		input="#q_gettabledef.datadefinition#"
		output="a_formelements">
	<cfset a_editFormDataList = a_formelements>
<cfelse>
	<cfset a_tableelements=arrayNew(1)>
</cfif>
<cfif isDefined('form.createfield')>
	<cfset SESSION.createfieldcount = #form.createfieldcount#>
</cfif>
<!--- BDW, DRK 2006-12-02 Mod to support Composite Forms BEGIN --->
<!--- Test to see if composite form is requested for assembly --->
<cfif isDefined('FORM.compositeForm')>
	<cfset FORM.compositeForm = 1>
</cfif>
<cfif isDefined("FORM.importFieldList") AND len(trim(FORM.importFieldList))>
	<cfset a_importFormObjects = arrayNew(1)>
	<cfset importFormObjectList = "">
	<cfset currentIndex = 0>
	<cfloop list="#FORM.importFieldList#" index="i" delimiters=",">
		<!--- Build simple list for using in SQL Select --->
		<cfif NOT findNoCase(listFirst(i,':'),importFormObjectList)>
			<cfset currentIndex = currentIndex + 1>
			<cfset importFormObjectList = listAppend(importFormObjectList,listFirst(i,':'))>
			<cfset a_importFormObjects[currentIndex] = structNew()>
			<cfset a_importFormObjects[currentIndex].formobjectid = listFirst(i,':')>
			<cfset a_importFormObjects[currentIndex].fieldnames = arrayNew(1)>
		</cfif>
	</cfloop>
	<cfloop from="1" to="#listlen(importFormObjectList)#" index="j" >
		<cfset currentIndex = 0>
		<cfloop list="#FORM.importFieldList#" index="i" delimiters=",">
		<!--- Build a structure to hold just the current objects and fields --->
			<cfif a_importFormObjects[j].formobjectid EQ listFirst(i,':')>
				<cfset currentIndex = currentIndex + 1>
				<cfset a_importFormObjects[j].fieldnames[currentIndex] = listLast(i,':')>
			</cfif>
		</cfloop>
	</cfloop>
	
	<cfset importItems = arrayNew(1)>
	<!--- retrieve data from necessary tables --->
	<cfquery name="q_importobjectforms" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT datatable, formobjectid, datadefinition, tabledefinition
		FROM formobject
		WHERE formobjectid IN (#importFormObjectList#)
	</cfquery>
	<cfset foreignKeyIDs = "">
	<!--- loop over each table --->
	<cfloop query="q_importobjectforms">
		<cfset a_currentFields = arrayNew(1)>
		<!--- get the field array that was selected for this table --->
		<cfloop index="i" from="1" to="#arrayLen(a_importFormObjects)#" >
			<cfif a_importFormObjects[i].formobjectid EQ q_importobjectforms.formobjectid>
				<cfset a_currentFields = a_importFormObjects[i].fieldnames>
			</cfif>
		</cfloop>
		<!--- Convert datadef from XML so we can grab the item structure --->
		<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
		input="#q_importobjectforms.datadefinition#"
		output="a_formelements">
		<!--- loop over each item --->
		
		<cfloop index="itemIndex" from="1" to="#arrayLen(a_formelements)#">
			<!--- loop over each items xml field listing --->
			<cfloop collection="#a_formelements[itemIndex]#" item="key">
				<cfif key EQ 'FIELDNAME'>
					<!--- compare items fieldname value to selected list --->
					<cfloop index="fieldNameIndex" from="1" to="#arrayLen(a_currentFields)#">
						<cfif a_formelements[itemIndex][key] EQ a_currentFields[fieldNameIndex]>
							<cfset a_formelements[itemIndex]['SOURCEFORMOBJECTID'] = q_importobjectforms.formobjectid>
							<cfset a_formelements[itemIndex]['COMMIT'] = 0>
							<!--- <cfset a_formelements[itemIndex]['INPUTTYPE'] =  "formatonly"> --->
							<cfset blah = ArrayAppend(importItems,a_formelements[itemIndex])>
							<!--- if not new tool add new fields to omitfield list for forms built from this tool --->
							<cfif isDefined('form.formobjectid') AND (form.formobjectid GT 0)>
								<cfquery datasource="#application.datasource#" name="q_getAllChildren" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
									SELECT *
									FROM formobject
									WHERE parentid = #form.formobjectid#
									AND formobjectid <> #form.formobjectid#
								</cfquery>
								<cfif q_getAllChildren.recordcount>
									<cfloop query="q_getAllChildren">
										<cfquery datasource="#application.datasource#" name="q_getomitList" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
											SELECT omitfieldlist, formobjectid
											FROM formobject
											WHERE formobjectid = #q_getAllChildren.formobjectid#
										</cfquery>
										<cfquery datasource="#application.datasource#" name="q_addFieldname" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
											UPDATE formobject
											SET omitfieldlist='#listAppend(q_getomitList.omitfieldlist,"#a_currentFields[fieldNameIndex]#")#'
											WHERE formobjectid = #q_getAllChildren.formobjectid#
										</cfquery>
									</cfloop>
								</cfif>
							</cfif>
						</cfif>
					</cfloop>
					<cfif a_formelements[itemIndex][key] EQ "#q_importobjectforms.datatable#id">
						<!--- add foreign key field if not already present --->
						<cfset isNewKey = true>
						<cfif isDefined('form.formobjectid') AND (form.formobjectid GT 0)>
							<cfloop from="1" to="#arrayLen(a_editFormDataList)#" index="r">
								<cfif a_editFormDataList[r].fieldname EQ "#q_importobjectforms.datatable#id">
									<cfset isNewKey = false>
								</cfif>
							</cfloop>
						</cfif>
						<cfif isNewKey>
							<cfset a_formelements[itemIndex]['SOURCEFORMOBJECTID'] = q_importobjectforms.formobjectid>
							<cfset a_formelements[itemIndex]['COMMIT'] = 1>
							<cfset a_formelements[itemIndex]['INPUTTYPE'] =  "hidden">
							<cfset a_formelements[itemIndex]['FOREIGNKEY'] =  1>
							<cfset a_formelements[itemIndex]['COMMITFOREIGNTABLE'] =  0>
							<cfset a_formelements[itemIndex]['ISMASTERTABLE'] =  0>
							<cfset blah = ArrayAppend(importItems,a_formelements[itemIndex])>
							<cfif len(trim(foreignKeyIDs))>
								<cfset foreignKeyIDs = foreignKeyIDs&",">
							</cfif>
							<cfset foreignKeyIDs = foreignKeyIDs&"#q_importobjectforms.datatable#id:int">
							<cfif isDefined('form.formobjectid') AND (form.formobjectid GT 0)>
								<cfquery datasource="#application.datasource#" name="q_getAllChildren" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
									SELECT *
									FROM formobject
									WHERE parentid = #form.formobjectid#
									AND formobjectid <> #form.formobjectid#
								</cfquery>
								<cfif q_getAllChildren.recordcount>
									<cfloop query="q_getAllChildren">
										<cfquery datasource="#application.datasource#" name="q_getomitList" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
											SELECT omitfieldlist, formobjectid
											FROM formobject
											WHERE formobjectid = #q_getAllChildren.formobjectid#
										</cfquery>
										<cfquery datasource="#application.datasource#" name="q_addFieldname" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
											UPDATE formobject 
											SET omitfieldlist='#listAppend(q_getomitList.omitfieldlist,"#q_importobjectforms.datatable#id")#'
											WHERE formobjectid = #q_getAllChildren.formobjectid#
										</cfquery>
									</cfloop>
								</cfif>
							</cfif>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
	</cfloop>
	</cfif>
<!--- BDW, DRK 2006-12-02 Mod to support Composite Forms END --->
<!--- Begin template import tool creation step --->
<cfif isDefined('FORM.templateName') AND isDefined('FORM.sourceFolder')>
	<cfinvoke component="#APPLICATION.cfcPath#.util.plugin" method="importPlugin" returnvariable="returnStruct">
		<cfinvokeargument name="pluginname" value="#FORM.templateName#">
		<cfinvokeargument name="sourceFolder" value="#FORM.sourceFolder#">
		<cfinvokeargument name="tablename" value="#FORM.newdatatable#">
		<cfinvokeargument name="tableLabel" value="#FORM.label#">
		<cfinvokeargument name="toolOnly" value="1">
	</cfinvoke>
	<cfif len(trim(returnStruct.errorMsg))>
		<cfset request.isError = 1>
		<cfif isDefined('request.errorMsg') AND len(trim(request.errorMsg))>
			<cfset request.errorMsg = request.errorMsg&'br />'&returnStruct.errorMsg>
		<cfelse>
			<cfset request.errorMsg = returnStruct.errorMsg>
		</cfif>
	<cfelse>
		<cfset formobjectid = returnStruct.toolid>
		<cfset form.formobjectid = returnStruct.toolid>
		<cfquery datasource="#application.datasource#" name="q_gettabledef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT tabledefinition, tablecolumns, tablerows, datadefinition, formobjectid, parentid, useOrdinal
			FROM formobject
			WHERE formobjectid = #trim(formobjectid)#
		</cfquery>
		<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
			input="#q_gettabledef.tabledefinition#"
			output="a_tableelements">
		<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
			input="#q_gettabledef.datadefinition#"
			output="a_formelements">
		<cfset a_editFormDataList = a_formelements>
		<cfset arrayIndex = 1>
		<cfloop from="1" to="#arrayLen(a_formelements)#" index="i">
			<cfif a_formelements[i]['FIELDNAME'] EQ "#FORM.templateName#id">
				<cfset a_formelements[i]['FIELDNAME'] = "#FORM.newdatatable#id">
			</cfif>
			<cfif a_formelements[i]['fieldname'] EQ "#FORM.templateName#name">
				<cfset a_formelements[i]['FIELDNAME'] = "#FORM.newdatatable#name">
			</cfif>
		</cfloop>
	</cfif>
	<!--- For New Tool creation, create corresponding navigation items --->
	<cfset form.navitemaddressname = form.label>
	<cfset form.formobjecttableid = form.formobjectid>
	<cfset form.urlpath = "/admintools/index.cfm?i3currenttool=#form.formobjectid#">
	<cfset form.permissionbased = 1>
	<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT" 
		tablename="navitemaddress"
		datasource="#application.datasource#"
		assignidfield="navitemaddressid">
		<cfset form.navitemname = form.label>
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
	<cfset form.parentid = form.formobjectid>
	<cfset structDelete (variables,"insertid")>
</cfif>
<!--- End template import tool creation step --->
<cfif NOT request.isError>
	<!--- test for edit, if not edit mode, set defualts --->
	<cfset isfeform = false>
	<cfif len(form.formobjectid) AND (q_gettabledef.formobjectid NEQ q_gettabledef.parentid)>
		<cfquery name="q_getEnvName" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT formEnvironmentName
			FROM formEnvironment
			WHERE formEnvironmentID = #FORM.formEnvironmentID#
		</cfquery>
		<cfif findnocase("frontend", q_getEnvName.formEnvironmentName)>
			<cfset isfeform = true>
		</cfif>
	</cfif>
	<cfloop index="i" from="1" to="#form.tablerows#">
		<cfset "row_#i#"=structNew()>
		<cfloop index="j" from="1" to="#form.tablecolumns#">			
			<cfscript>
			 if (len(form.formobjectid)) {
				if ((i GT q_gettabledef.tablerows) OR (j GT q_gettabledef.tablecolumns)) {
					"cell_#j#"=structNew();
					"cell_#j#.colspan"=0;//num
					"cell_#j#.rowspan"=0;//num
					"cell_#j#.width"=0;//num
					"cell_#j#.valign"=0;//num
					"cell_#j#.align"=0;//string
					if(j EQ 1){
						"cell_#j#.class"="formitemlabel";//string
					}else if(j EQ 2){
						"cell_#j#.class"="formiteminput";//string
					}else{
						"cell_#j#.class"="";//string
					}
					if(isfeform AND findnocase("formitem",evaluate("cell_#j#.class"))){
						"cell_#j#.class" = "frontend"&"cell_#j#.class";
					}
					"cell_#j#.nowrap"=0;//bit
					"row_#i#.cell_#j#"=evaluate("cell_#j#"); 
				 }else {
					"cell_#j#"=structNew();
					"cell_#j#.colspan"=evaluate("a_tableelements[#i#].cell_#j#.colspan");//num
					"cell_#j#.rowspan"=evaluate("a_tableelements[#i#].cell_#j#.rowspan");//num
					"cell_#j#.width"=evaluate("a_tableelements[#i#].cell_#j#.width");//num
					"cell_#j#.valign"=evaluate("a_tableelements[#i#].cell_#j#.valign");//num
					"cell_#j#.align"=evaluate("a_tableelements[#i#].cell_#j#.align");//num
					"cell_#j#.class"=evaluate("a_tableelements[#i#].cell_#j#.class");//num
					// change to frontend classes for front end forms
					if(isfeform AND findnocase("formitem",evaluate("cell_#j#.class")) AND NOT findnocase("frontend",evaluate("cell_#j#.class"))){
						"cell_#j#.class" = "frontend"&evaluate("cell_#j#.class");
					}
					if (structKeyExists(evaluate('a_tableelements[#i#].cell_#j#'),"nowrap")) {
						"cell_#j#.nowrap"=evaluate("a_tableelements[#i#].cell_#j#.nowrap");//bit
					} else {
						"cell_#j#.nowrap"=0;
					}	
					"row_#i#.cell_#j#"=evaluate("cell_#j#");
				 } 
			} else {
				"cell_#j#"=structNew();
				if(isDefined('form.useMappedContent') AND form.useMappedContent AND (i EQ 1) AND (j EQ 1)){
					"cell_#j#.colspan"=2;//num
					"cell_#j#.class"="subtoolheader";//num
					"cell_#j#.rowspan"=0;//num
					"cell_#j#.width"=0;//num
					"cell_#j#.valign"=0;//num
					"cell_#j#.align"="Right";//string
					"cell_#j#.nowrap"=0;//bit
					"row_#i#.cell_#j#"=evaluate("cell_#j#");
				}else if((i EQ 1) AND (j EQ 1)){
					"cell_#j#.colspan"=0;//num
					"cell_#j#.class"="formitemlabelreq";//num
					"cell_#j#.rowspan"=0;//num
					"cell_#j#.width"=0;//num
					"cell_#j#.valign"=0;//num
					"cell_#j#.align"=0;//string
					"cell_#j#.nowrap"=0;//bit
					"row_#i#.cell_#j#"=evaluate("cell_#j#");
				}else if(isDefined('form.useMappedContent') AND form.useMappedContent AND (i EQ 2) AND (j EQ 1)){
				"cell_#j#.colspan"=0;//num
					"cell_#j#.class"="formitemlabelreq";//num
					"cell_#j#.rowspan"=0;//num
					"cell_#j#.width"=0;//num
					"cell_#j#.valign"=0;//num
					"cell_#j#.align"=0;//string
					"cell_#j#.nowrap"=0;//bit
					"row_#i#.cell_#j#"=evaluate("cell_#j#");
				}else if(isDefined('form.useVanityURL') AND form.useVanityURL AND NOT(isDefined('form.useMappedContent') AND form.useMappedContent) AND (i EQ 2) AND (j EQ 1)){
				"cell_#j#.colspan"=0;//num
					"cell_#j#.class"="formitemlabelreq";//num
					"cell_#j#.rowspan"=0;//num
					"cell_#j#.width"=0;//num
					"cell_#j#.valign"=0;//num
					"cell_#j#.align"=0;//string
					"cell_#j#.nowrap"=0;//bit
					"row_#i#.cell_#j#"=evaluate("cell_#j#");
				}else if(isDefined('form.useVanityURL') AND form.useVanityURL AND (isDefined('form.useMappedContent') AND form.useMappedContent) AND (i EQ 3) AND (j EQ 1)){
				"cell_#j#.colspan"=0;//num
					"cell_#j#.class"="formitemlabelreq";//num
					"cell_#j#.rowspan"=0;//num
					"cell_#j#.width"=0;//num
					"cell_#j#.valign"=0;//num
					"cell_#j#.align"=0;//string
					"cell_#j#.nowrap"=0;//bit
					"row_#i#.cell_#j#"=evaluate("cell_#j#");
				}else if((i EQ val(form.tablerows)) AND (j EQ 1)){
					"cell_#j#.colspan"=2;//num
					"cell_#j#.class"="formiteminput";//string
					"cell_#j#.rowspan"=0;//num
					"cell_#j#.width"=0;//num
					"cell_#j#.valign"=0;//num
					"cell_#j#.align"="Center";//string
					"cell_#j#.nowrap"=0;//bit
					"row_#i#.cell_#j#"=evaluate("cell_#j#");
				}else{
					"cell_#j#.colspan"=0;//num
					if(j EQ 1){
						"cell_#j#.class"="formitemlabel";//string
					}else if(j EQ 2){
						"cell_#j#.class"="formiteminput";//string
					}else{
						"cell_#j#.class"="";//string
					}
					"cell_#j#.rowspan"=0;//num
					"cell_#j#.width"=0;//num
					"cell_#j#.valign"=0;//num
					"cell_#j#.align"=0;//string
					"cell_#j#.nowrap"=0;//bit
					"row_#i#.cell_#j#"=evaluate("cell_#j#");
				}
			}
			</cfscript>
			
		</cfloop>
		<cfset a_tableelements[i]=evaluate("row_#i#")>
	</cfloop>
	
	<!--- check for 'deleted rows' --->
	<cfif arrayLen(a_tableelements) GT form.tablerows>
		<cfloop from="#arrayLen(a_tableelements)#" to="#val(form.tablerows+1)#" step="-1" index="p">
			<cfset tmpDelete=arrayDeleteAt(a_tableelements,p)>
		</cfloop>
	</cfif>
	
	<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="CFML2XML"
		input="#a_tableelements#"
		output="form.tabledefinition">
	<!--- /test for edit, if not edit mode, set defualts --->
	
	<!--- INSERT/UPDATE data in formobject data --->
	<cfif len(form.newdatatable)>
		<cfset form.datatable=form.newdatatable>
	</cfif>
	<!--- trim/clean up include paths --->
	<cfscript>
		thisChar="/\";
		form.preshowform=application.smartTrim(form.preshowform,thisChar);
		form.prevalidate=application.smartTrim(form.prevalidate,thisChar);
		form.preconfirm=application.smartTrim(form.preconfirm,thisChar);
		form.postconfirm=application.smartTrim(form.postconfirm,thisChar);
		form.precommit=application.smartTrim(form.precommit,thisChar);
		form.postcommit=application.smartTrim(form.postcommit,thisChar);
	</cfscript>
	<cfset form.toolcategoryid=listFirst(form.toolcategoryid,"~")>
	<cfset form.datemodified=createODBCDateTime(now())>
	<cfif len(form.formobjectid)>
		<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE" 
			tablename="formobject"
			datasource="#application.datasource#"
			primarykeyfield="#form.formobjectid#"
			assignidfield="formobjectid">
		   <cfif FORM.formEnvironmentID EQ 109 OR FORM.formEnvironmentID EQ 100>
                <cfquery name="q_checkForDH" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
                	SELECT displayHandlerID
                    FROM displayHandler
                    WHERE formobjectID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.formObjectID#">
                </cfquery>
				<cfif isDefined('insertid') and len(trim(insertid))>
					<cfset tableInsertid = insertid>
				</cfif>
				<cfif q_checkForDH.RecordCount EQ 0>
                	<cfif IsDefined('FORM.formObjectName') AND Len(Trim(FORM.formObjectName))>
						<cfset FORM.displayhandlerName = FORM.formObjectName & ' FE Form'>
					<cfelse>
	                    <cfset FORM.displayhandlerName = FORM.formName & ' FE Form'>
					</cfif>
					
                    <cfset FORM.displayObjectID = 102>
                    <cfset FORM.dateCreated = FORM.dateModified>
                    <cfset structDelete(FORM,'parentid')>
                    <cfmodule template="#application.customTagPath#/dbaction.cfm" 
                        action="INSERT" 
                        tablename="displayHandler"
                        datasource="#application.datasource#"
                        assignidfield="displayHandlerID">
				</cfif>
				<cfif isDefined('tableInsertid') and len(trim(tableInsertid))>
					<cfset insertid = tableInsertid>
				<cfelse>
					<cfset structDelete(variables,'insertid')>
				</cfif>
           </cfif>
	<cfelse>
		<!---If this is a new tool set the prefilled row variable to 2 or if there is an sekeyname
		set it to 3--->
		<cfif isDefined('form.useVanityURL') AND form.useVanityURL EQ 1>
			<cfset SESSION.currentFieldRow = 3>
		<cfelse>
			<cfset SESSION.currentFieldRow = 2>
		</cfif>
		
		<cfif NOT isDefined('FORM.templateName') AND NOT isDefined('FORM.sourceFolder')>
			<cfset form.datecreated=createODBCDateTime(now())>
			<cfset form.archive=0>
			<cfset form.lockDataTable=0>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT" 
				tablename="formobject"
				datasource="#application.datasource#"
				assignidfield="formobjectid">
			<cfset form.formobjectid=insertid>
			<cfset form.parentid=insertid>
			<cfquery datasource="#application.datasource#" name="q_updateParentId" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE formobject 
				SET parentid = #form.formobjectid#
				WHERE formobjectid=#trim(form.formobjectid)#
			</cfquery>
			<!--- make sure permissions get set for new tables this gets skipped if the user doesn't complete all toolbbuilder steps --->
			<cfquery datasource="#application.datasource#" name="q_updatePermissions" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				INSERT INTO userpermission (userid,formobjectid,access,addedit,approve,remove)
				VALUES (100000,#FORM.formobjectid#,1,1,1,1)
			</cfquery>
		</cfif>
		<!--- For New Tool creation, create corresponding navigation items --->
		<cfset form.navitemaddressname = form.label>
		<cfset form.formobjecttableid = form.formobjectid>
		<cfset form.urlpath = "/admintools/index.cfm?i3currenttool=#form.formobjectid#">
		<cfset form.permissionbased = 1>
		<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT" 
			tablename="navitemaddress"
			datasource="#application.datasource#"
			assignidfield="navitemaddressid">
		<cfset form.navitemname = form.label>
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
		<cfset form.parentid = form.formobjectid>
		<cfset insertID = form.formobjectid>
	</cfif>
	
	<!--- Check to see if this is an HTML only form. --->
	<cfquery name="q_capture" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT  datacapture
		FROM   formobject INNER JOIN formEnvironment ON formobject.formEnvironmentID = formEnvironment.formEnvironmentID
		WHERE  (formobject.formobjectid = #formobjectid#)
	</cfquery>
	<!--- Create a new Table in the DB if necessary. --->
	<cfif len(form.newdatatable) AND q_capture.datacapture EQ 1>
		<cfquery name="q_getTables" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT name 
			FROM sysobjects 
			WHERE name = '#trim(form.newdatatable)#'
		</cfquery>
		<cfif NOT q_getTables.recordcount>
			<cfquery datasource="#application.datasource#" name="q_createTable" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				CREATE TABLE #trim(form.newdatatable)# ([#trim(form.newdatatable)#id] [int] NOT NULL) ON [PRIMARY];
				ALTER TABLE [#trim(form.newdatatable)#] WITH NOCHECK ADD 
				CONSTRAINT [PK_#trim(form.newdatatable)#] PRIMARY KEY  NONCLUSTERED 
				(
					[#trim(form.newdatatable)#id]
				)  ON [PRIMARY] 
			</cfquery>
			<cfquery datasource="#application.datasource#" name="q_addSeedObject" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				INSERT INTO tableID (TableName,ID)
				VALUES('#trim(form.newdatatable)#',100000)
			</cfquery>
			<!--- add datecreated, datemodified, and parentid columns to all new tables as well --->
			<cfset columnAddList="#trim(form.newdatatable)#name:nvarchar(500),datecreated:datetime,datemodified:datetime,parentid:int,ordinal:int">
			<!--- 12/04/2006 DRK if foriegn keys are being created add to list --->
			<cfif isDefined('foreignKeyIDs') and len(trim(foreignKeyIDs))>
				<cfset columnAddList=columnAddList&','&foreignKeyIDs>
			</cfif>
			<!--- 3/2/2007 DRK if sekey used add to list --->
			<cfif isDefined('form.useVanityURL') AND form.useVanityURL EQ 1>
				<cfset columnAddList=columnAddList&',sekeyname:nvarchar(500)'>
			</cfif>
			<!--- <cfif form.restrictByUserType EQ 1>
				<cfset columnAddList=columnAddList&",restrictByUserTypeID:int">
			</cfif> --->
			<cfloop list="#columnAddList#" index="thisColumnAdd">
				<cfquery datasource="#application.datasource#" name="q_addIDColumn" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					ALTER TABLE #trim(form.newdatatable)#
					ADD [#listFirst(thisColumnAdd,":")#] #listLast(thisColumnAdd,":")# NULL
				</cfquery>
			</cfloop>
		<cfelse>
			<!--- need to delete formobject table entry and throw an error if the table already exists --->
		</cfif>
	</cfif>
		<cfif isDefined("insertid")>
			<!--- Build XML object for first default column --->
				<cfscript>
				a_formelements=arrayNew(1);
					s_datadef=structNew();
						s_datadef.fieldname=trim(form.newdatatable)&"id";//str
						s_datadef.objectlabel=application.CapFirst(trim(form.newdatatable))&" ID";//str
						s_datadef.datatype="int";//str
						s_datadef.length=4;//num
						s_datadef.pk=1;//boolean
						s_datadef.required=0;//boolean
						s_datadef.validate="";//str
						s_datadef.inputtype="hidden";//str
						s_datadef.maxlength="20";//num
						s_datadef.height=0;//num
						s_datadef.width=0;//num
						s_datadef.lookuptype="";//str: table,query,list
						s_datadef.lookuplist="";//str
						s_datadef.lookupquery="";//str
						s_datadef.lookuptable="";//str
						s_datadef.lookupkey="";//str
						s_datadef.lookupdisplay="";//str
						s_datadef.lookupmultiple="";//num
						s_datadef.defaultvalue="";//str
						s_datadef.inputstyle="";//str
						s_datadef.gridposlabel="";//str
						s_datadef.gridposvalue="";//str
						s_datadef.formatonly="";//str
						s_datadef.uploadcategoryid="";//num
						s_datadef.commit=1;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.tabindex=0;//num
						s_datadef.readonly=0;//boolean
				a_formelements[1]=s_datadef;
					s_datadef=structNew();
						s_datadef.fieldname=trim(form.newdatatable)&"name";//str
						s_datadef.objectlabel=application.CapFirst(trim(form.newdatatable))&" Name";//str
						s_datadef.datatype="nvarchar";//str
						s_datadef.length=500;//num
						s_datadef.pk=0;//boolean
						s_datadef.required=1;//boolean
						s_datadef.validate="";//str
						s_datadef.inputtype="text";//str
						s_datadef.maxlength="500";//num
						s_datadef.height=20;//num
						s_datadef.width=50;//num
						s_datadef.lookuptype="";//str: table,query,list
						s_datadef.lookuplist="";//str
						s_datadef.lookupquery="";//str
						s_datadef.lookuptable="";//str
						s_datadef.lookupkey="";//str
						s_datadef.lookupdisplay="";//str
						s_datadef.lookupmultiple="";//num
						s_datadef.defaultvalue="";//str
						s_datadef.inputstyle="";//str
						if(isDefined('form.useMappedContent') AND form.useMappedContent EQ 1){
							s_datadef.gridposlabel="2_1";//str
							s_datadef.gridposvalue="2_2";//str
						}else{
							s_datadef.gridposlabel="1_1";//str
							s_datadef.gridposvalue="1_2";//str
						}
						s_datadef.formatonly="";//str
						s_datadef.uploadcategoryid="";//num
						s_datadef.commit=1;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.tabindex=0;//num
						s_datadef.readonly=0;//boolean
				a_formelements[val(arraylen(a_formelements) +1)]=s_datadef;
					s_datadef=structNew();
						s_datadef.fieldname="datecreated";//str
						s_datadef.objectlabel="Date Created";//str
						s_datadef.datatype="datetime";//str
						s_datadef.length=8;//num
						s_datadef.pk=0;//boolean
						s_datadef.required=0;//boolean
						s_datadef.validate="date";//str
						s_datadef.inputtype="hidden";//str
						s_datadef.maxlength="20";//num
						s_datadef.height=0;//num
						s_datadef.width=0;//num
						s_datadef.lookuptype="";//str: table,query,list
						s_datadef.lookuplist="";//str
						s_datadef.lookupquery="";//str
						s_datadef.lookuptable="";//str
						s_datadef.lookupkey="";//str
						s_datadef.lookupdisplay="";//str
						s_datadef.lookupmultiple="";//num
						s_datadef.defaultvalue="";//str
						s_datadef.inputstyle="";//str
						s_datadef.gridposlabel="";//str
						s_datadef.gridposvalue="";//str
						s_datadef.formatonly="";//str
						s_datadef.uploadcategoryid="";//num
						s_datadef.commit=1;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.tabindex=0;//num
						s_datadef.readonly=0;//boolean
				a_formelements[val(arraylen(a_formelements) +1)]=s_datadef;
					s_datadef=structNew();
						s_datadef.fieldname="datemodified";//str
						s_datadef.objectlabel="Date Modified";//str
						s_datadef.datatype="datetime";//str
						s_datadef.length=8;//num
						s_datadef.pk=0;//boolean
						s_datadef.required=0;//boolean
						s_datadef.validate="date";//str
						s_datadef.inputtype="hidden";//str
						s_datadef.maxlength="20";//num
						s_datadef.height=0;//num
						s_datadef.width=0;//num
						s_datadef.lookuptype="";//str: table,query,list
						s_datadef.lookuplist="";//str
						s_datadef.lookupquery="";//str
						s_datadef.lookuptable="";//str
						s_datadef.lookupkey="";//str
						s_datadef.lookupdisplay="";//str
						s_datadef.lookupmultiple="";//num
						s_datadef.defaultvalue="";//str
						s_datadef.inputstyle="";//str
						s_datadef.gridposlabel="";//str
						s_datadef.gridposvalue="";//str
						s_datadef.formatonly="";//str
						s_datadef.uploadcategoryid="";//num
						s_datadef.commit=1;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.tabindex=0;//num
						s_datadef.readonly=0;//boolean
				a_formelements[val(arraylen(a_formelements) +1)]=s_datadef;
					s_datadef=structNew();
						s_datadef.fieldname="parentid";//str
						s_datadef.objectlabel="Parent ID";//str
						s_datadef.datatype="int";//str
						s_datadef.length=4;//num
						s_datadef.pk=1;//boolean
						s_datadef.required=0;//boolean
						s_datadef.validate="";//str
						s_datadef.inputtype="hidden";//str
						s_datadef.maxlength="20";//num
						s_datadef.height=0;//num
						s_datadef.width=0;//num
						s_datadef.lookuptype="";//str: table,query,list
						s_datadef.lookuplist="";//str
						s_datadef.lookupquery="";//str
						s_datadef.lookuptable="";//str
						s_datadef.lookupkey="";//str
						s_datadef.lookupdisplay="";//str
						s_datadef.lookupmultiple="";//num
						s_datadef.defaultvalue="";//str
						s_datadef.inputstyle="";//str
						s_datadef.gridposlabel="#form.tablerows#_1";//str  
						s_datadef.gridposvalue="#form.tablerows#_1";//str 
						s_datadef.formatonly="";//str
						s_datadef.uploadcategoryid="";//num
						s_datadef.commit=1;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.tabindex=0;//num
						s_datadef.readonly=0;//boolean
				a_formelements[val(arraylen(a_formelements) +1)]=s_datadef;
					s_datadef=structNew();
						s_datadef.fieldname="Submit";//str
						s_datadef.objectlabel="Submit";//str
						s_datadef.datatype="char";//str
						s_datadef.length=4;//num
						s_datadef.pk=0;//boolean
						s_datadef.required=0;//boolean
						s_datadef.validate="";//str
						s_datadef.inputtype="submit";//str
						s_datadef.maxlength="";//num
						s_datadef.height="";//num
						s_datadef.width="";//num
						s_datadef.lookuptype="";//str: table,query,list
						s_datadef.lookuplist="";//str
						s_datadef.lookupquery="";//str
						s_datadef.lookuptable="";//str
						s_datadef.lookupkey="";//str
						s_datadef.lookupdisplay="";//str
						s_datadef.lookupmultiple="";//num
						s_datadef.defaultvalue="Submit";//str
						s_datadef.inputstyle="submitbutton";//str
						s_datadef.gridposlabel="#form.tablerows#_1";//str  #form.tablecolumns#
						s_datadef.gridposvalue="#form.tablerows#_1";//str #form.tablecolumns#
						s_datadef.commit=0;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.submitbuttonimage="";//str
						s_datadef.tabindex=0;//num
						s_datadef.readonly=0;//boolean
				a_formelements[val(arraylen(a_formelements) +1)]=s_datadef;
/*					s_datadef=structNew();
						s_datadef.fieldname="Cancel";//str
						s_datadef.objectlabel="Cancel";//str
						s_datadef.datatype="char";//str
						s_datadef.length=4;//num
						s_datadef.pk=0;//boolean
						s_datadef.required=0;//boolean
						s_datadef.validate="";//str
						s_datadef.inputtype="cancel";//str
						s_datadef.maxlength="";//num
						s_datadef.height="";//num
						s_datadef.width="";//num
						s_datadef.lookuptype="";//str: table,query,list
						s_datadef.lookuplist="";//str
						s_datadef.lookupquery="";//str
						s_datadef.lookuptable="";//str
						s_datadef.lookupkey="";//str
						s_datadef.lookupdisplay="";//str
						s_datadef.lookupmultiple="";//num
						s_datadef.defaultvalue="Cancel";//str
						s_datadef.inputstyle="submitbutton";//str
						s_datadef.gridposlabel="#form.tablerows#_1";//str #form.tablecolumns#
						s_datadef.gridposvalue="#form.tablerows#_1";//str #form.tablecolumns#
						s_datadef.commit=0;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.cancelbuttonimage="";//str
						s_datadef.tabindex=0;//num
						s_datadef.readonly=0;//boolean
				a_formelements[val(arraylen(a_formelements) +1)]=s_datadef;
*/
				if (form.useOrdinal){
					s_datadef=structNew();
						s_datadef.fieldname="Ordinal";//str
						s_datadef.objectlabel="ordinal";//str
						s_datadef.datatype="int";//str
						s_datadef.length=4;//num
						s_datadef.pk=0;//boolean
						s_datadef.required=0;//boolean
						s_datadef.validate="";//str
						s_datadef.inputtype="hidden";//str
						s_datadef.maxlength="";//num
						s_datadef.height="";//num
						s_datadef.width="";//num
						s_datadef.lookuptype="";//str: table,query,list
						s_datadef.lookuplist="";//str
						s_datadef.lookupquery="";//str
						s_datadef.lookuptable="";//str
						s_datadef.lookupkey="";//str
						s_datadef.lookupdisplay="";//str
						s_datadef.lookupmultiple="";//num
						s_datadef.defaultvalue="0";//str
						s_datadef.inputstyle="";//str
						s_datadef.gridposlabel="";//str
						s_datadef.gridposvalue="";//str
						s_datadef.commit=0;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.tabindex=0;//num
						s_datadef.readonly=0;//boolean
				a_formelements[val(arraylen(a_formelements) +1)]=s_datadef;
				}
				// 12/08/2006 DRK add content mapping placeholder
				if (isDefined('form.useMappedContent') AND form.useMappedContent EQ 1){
					s_datadef=structNew();
						s_datadef.fieldname="useMappedContent";//str
						s_datadef.objectlabel="Map Content Tool";//str
						s_datadef.datatype="int";//str
						s_datadef.length=4;//num
						s_datadef.pk=0;//boolean
						s_datadef.required=0;//boolean
						s_datadef.validate="";//str
						s_datadef.inputtype="useMappedContent";//str
						s_datadef.maxlength="";//num
						s_datadef.height="";//num
						s_datadef.width="";//num
						s_datadef.lookuptype="";//str: table,query,list
						s_datadef.lookuplist="";//str
						s_datadef.lookupquery="";//str
						s_datadef.lookuptable="";//str
						s_datadef.lookupkey="";//str
						s_datadef.lookupdisplay="";//str
						s_datadef.lookupmultiple="";//num
						s_datadef.defaultvalue="1";//str
						s_datadef.inputstyle="submitbutton";//str
						s_datadef.gridposlabel="1_1";//str
						s_datadef.gridposvalue="1_1";//str
						s_datadef.commit=0;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.formatonly="CONTENT MAPPING LINK (do not edit)"; //str
						s_datadef.useMappedContent=1;//bool
						s_datadef.tabindex=0;//
						s_datadef.readonly=0;//boolean
				a_formelements[val(arraylen(a_formelements) +1)]=s_datadef;
				}
				if (isDefined('form.useVanityURL') AND form.useVanityURL EQ 1){
					s_datadef=structNew();
						s_datadef.fieldname="sekeyname";//str
						s_datadef.objectlabel="Friendly URL";//str
						s_datadef.datatype="nvarchar";//str
						s_datadef.length=500;//num
						s_datadef.pk=0;//boolean
						s_datadef.required=1;//boolean
						s_datadef.sekeynamefield=trim(form.newdatatable)&"name";//str
						s_datadef.validate="vanityURL";//str
						s_datadef.inputtype="sekeyname";//str
						s_datadef.maxlength="500";//num
						s_datadef.height="";//num
						s_datadef.width="50";//num
						s_datadef.lookuptype="";//str: table,query,list
						s_datadef.lookuplist="";//str
						s_datadef.lookupquery="";//str
						s_datadef.lookuptable="";//str
						s_datadef.lookupkey="";//str
						s_datadef.lookupdisplay="";//str
						s_datadef.lookupmultiple="";//num
						s_datadef.defaultvalue="";//str
						s_datadef.inputstyle="";//str
						if(isDefined('form.useMappedContent') AND form.useMappedContent EQ 1){
							s_datadef.gridposlabel="3_1";//str
							s_datadef.gridposvalue="3_2";//str
						}else{
							s_datadef.gridposlabel="2_1";//str
							s_datadef.gridposvalue="2_2";//str
						}
						s_datadef.commit=1;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.formatonly=""; //str
						s_datadef.tabindex=0;//
						s_datadef.readonly=0;//boolean
				a_formelements[val(arraylen(a_formelements) +1)]=s_datadef;
				}
/*				if (form.restrictByUserType){
					if(form.useOrdinal){
						arrayCount=8;
					}else {
						arrayCount=7;
					}
					s_datadef=structNew();
						s_datadef.fieldname="restrictByUserTypeID";//str
						s_datadef.objectlabel="Restrict by User Type";//str
						s_datadef.datatype="int";//str
						s_datadef.length=4;//num
						s_datadef.pk=0;//boolean
						s_datadef.required=0;//boolean
						s_datadef.validate="";//str
						s_datadef.inputtype="hidden";//str
						s_datadef.maxlength="";//num
						s_datadef.height="";//num
						s_datadef.width="";//num
						s_datadef.lookuptype="";//str: table,query,list
						s_datadef.lookuplist="";//str
						s_datadef.lookupquery="";//str
						s_datadef.lookuptable="";//str
						s_datadef.lookupkey="";//str
						s_datadef.lookupdisplay="";//str
						s_datadef.lookupmultiple="";//num
						s_datadef.defaultvalue="0";//str
						s_datadef.inputstyle="";//str
						s_datadef.gridposlabel="";//str
						s_datadef.gridposvalue="";//str
						s_datadef.commit=0;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.tabindex=0;//num
						s_datadef.readonly=0;//boolean
				a_formelements[val(arraylen(a_formelements) +1)]=s_datadef;
				}
*/
				</cfscript>
				<!--- 12/04/2006 DRK Add imported items to basic diplay tabel listing START--->
				<cfif isDefined('importItems')>
					<cfset arrayCount = ArrayLen(a_formelements)>
					<cfset rowPlacement = form.tablerows - ArrayLen(importItems)+listLen(foreignKeyIDs)>
					<cfloop index="i" from="1" to="#ArrayLen(importItems)#">
						<cfset arrayCount = arrayCount + 1>
						<cfif right(importItems[i]['fieldname'],2) EQ 'ID'>
							<cfset importItems[i]['gridposlabel'] = "1_1">
							<cfset importItems[i]['gridposvalue'] = "1_2">
						<cfelse>
							<cfset importItems[i]['gridposlabel'] = "#rowPlacement#_1">
							<cfset importItems[i]['gridposvalue'] = "#rowPlacement#_2">
							<cfset rowPlacement = rowPlacement + 1>
						</cfif>
						<cfset a_formelements[arrayCount]=importItems[i]>
					</cfloop>
				</cfif>
				<!--- 12/04/2006 DRK Add imported items to basic display table listing END--->
					<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="CFML2XML"
						input="#a_formelements#"
						output="form.datadefinition">
			<cfelse>
				<!--- 1/18/07 toggle ordinal from form object START --->
				<cfif FORM.useOrdinal AND (NOT isDefined('q_gettabledef.useOrdinal') OR (NOT q_gettabledef.useOrdinal))>
					<cfscript>
						s_datadef=structNew();
						s_datadef.fieldname="Ordinal";//str
						s_datadef.objectlabel="ordinal";//str
						s_datadef.datatype="int";//str
						s_datadef.length=4;//num
						s_datadef.pk=0;//boolean
						s_datadef.required=0;//boolean
						s_datadef.validate="";//str
						s_datadef.inputtype="hidden";//str
						s_datadef.maxlength="";//num
						s_datadef.height="";//num
						s_datadef.width="";//num
						s_datadef.lookuptype="";//str: table,query,list
						s_datadef.lookuplist="";//str
						s_datadef.lookupquery="";//str
						s_datadef.lookuptable="";//str
						s_datadef.lookupkey="";//str
						s_datadef.lookupdisplay="";//str
						s_datadef.lookupmultiple="";//num
						s_datadef.defaultvalue="0";//str
						s_datadef.inputstyle="";//str
						s_datadef.gridposlabel="";//str
						s_datadef.gridposvalue="";//str
						s_datadef.commit=0;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.tabindex=0;//num
						s_datadef.readonly=0;//boolean
						a_formelements[val(arraylen(a_formelements) + 1)]=s_datadef;
					</cfscript>
					<!--- convert form elements back to XML and insert into form scope --->
					<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="CFML2XML"
						input="#a_formelements#"
						output="form.datadefinition">
					<!--- commit these new changes back to the form object table--->
					<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE" 
						tablename="formobject"
						datasource="#application.datasource#"
						primarykeyfield="#form.formobjectid#"
						assignidfield="formobjectid">
				<cfelseif (NOT FORM.useOrdinal) AND isDefined('q_gettabledef.useOrdinal') AND q_gettabledef.useOrdinal>
					<cfset tempArray = arrayNew(1)>
					<cfloop from="1" to="#arrayLen(a_formelements)#" index="i">
						<cfif NOT (a_formelements[i].fieldname EQ "Ordinal")>
							<cfset tempArray[val(arraylen(tempArray) + 1)]=a_formelements[i]>
						</cfif>
					</cfloop>
					<cfset a_formelements = arrayNew(1)>
					<cfset a_formelements = tempArray>
					<!--- convert form elements back to XML and insert into form scope --->
					<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="CFML2XML"
						input="#a_formelements#"
						output="form.datadefinition">
					<!--- commit these new changes back to the form object table--->
					<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE" 
						tablename="formobject"
						datasource="#application.datasource#"
						primarykeyfield="#form.formobjectid#"
						assignidfield="formobjectid">
				</cfif>
				<!--- 1/18/07 toggle ordinal from form object END --->
				<!--- 12/04/2006 DRK Add imported items to existing table listing START--->
				<cfif isDefined('importItems')>
					<cfset arrayCount = ArrayLen(a_editFormDataList)>
					<cfset rowPlacement = form.tablerows - ArrayLen(importItems)+1>
					<cfloop index="i" from="1" to="#ArrayLen(importItems)#">
						<cfset arrayCount = arrayCount + 1>
						<cfset importItems[i]['gridposlabel'] = "#rowPlacement#_1">
						<cfset importItems[i]['gridposvalue'] = "#rowPlacement#_2">
						<cfset rowPlacement = rowPlacement + 1>
						<cfset a_editFormDataList[arrayCount]=importItems[i]>
					</cfloop>
					<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="CFML2XML"
						input="#a_editFormDataList#"
						output="form.datadefinition">
				</cfif>
				<cfif isDefined('foreignKeyIDs') and len(trim(foreignKeyIDs))>
					<!--- 12/11/2006 DRK get table structure for existing table --->
					<cfquery name="q_tablestructure" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT *
						FROM #trim(form.DATATABLE)#
					</cfquery>
					<cfdump var="FKs #foreignKeyIDs# | ">
					<cfloop list="#foreignKeyIDs#" index="thisColumnAdd">
						<!--- 12/11/2006 DRK only add foreign keys if they do not already exist --->
						<cfif listfindnocase(q_tablestructure.columnlist, listFirst(thisColumnAdd,":")) EQ 0>
							<cfdump var="add">
							<cfquery datasource="#application.datasource#" name="q_addIDColumn" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
								ALTER TABLE #trim(form.DATATABLE)#
								ADD [#listFirst(thisColumnAdd,":")#] #listLast(thisColumnAdd,":")# NULL
							</cfquery>
						</cfif>
					</cfloop>
				</cfif>
				<!--- 12/04/2006 DRK Add imported items to existing tabel listing END--->
			</cfif>
			<cfset form.formobjectname=form.label>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE" 
					tablename="formobject"
					datasource="#application.datasource#"
					primarykeyfield="#form.formobjectid#"
					assignidfield="formobjectid">
			<!--- 12/11/2006 DRK manage addition/removal of content mapping element START --->
			<!--- only manage for form edit: creation handled elsewhere --->
			<cfif len(formobjectid)>
				<!--- make sure id is captured in form scope --->
				<cfset form.formobjectid = formobjectid>
				<!--- grab the up-to-date tool table information --->
				<cfquery name="q_getTableInfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT formobjectid, datadefinition, tabledefinition
					FROM formobject
					WHERE formobjectid = #trim(formobjectid)#
				</cfquery>
				<!--- convert the XML definitions to arrays --->
				<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
					input="#q_getTableInfo.tabledefinition#"
					output="a_tableelements">
				<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
					input="#q_getTableInfo.datadefinition#"
					output="a_formelements">
				<!--- is requested --->
				<cfif isDefined('form.useMappedContent') AND form.useMappedContent EQ 1>
					<!--- loop through the existing list to see if the element already exists --->
					<cfset elementExists = false>
					<cfloop from="1" to="#ArrayLen(a_formelements)#" index="i">
						<!--- test each value --->
						<cfif a_formelements[i].fieldname EQ "useMappedContent">
							<cfset elementExists = true>
						</cfif>
					</cfloop>
					<!--- did not find, so add it to form and table structure --->
					<cfif NOT elementExists>
						<cfset newRowIndex = val(form.tablerows + 1)>
						<!--- add new table element --->
						<cfset "row_#newRowIndex#"=structNew()>
						<cfloop index="j" from="1" to="#form.tablecolumns#">
							<cfscript>
								"cell_#j#"=structNew();
								"cell_#j#.colspan"=2;//num
								"cell_#j#.rowspan"=0;//num
								"cell_#j#.width"=0;//num
								"cell_#j#.valign"=0;//num
								"cell_#j#.align"="Right";//string
								"cell_#j#.class"="subtoolheader";//num
								"cell_#j#.nowrap"=0;//bit
								"row_#newRowIndex#.cell_#j#"=evaluate("cell_#j#");
							</cfscript>
						</cfloop>
						<cfset a_tableelements[newRowIndex]=evaluate("row_#newRowIndex#")>
						<!--- convert table elements back to XML and insert into form scope --->
						<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="CFML2XML"
							input="#a_tableelements#"
							output="form.tabledefinition">
						<!--- add new form element and put it in the newly created row --->
						<cfscript>
							s_datadef=structNew();
							s_datadef.fieldname="useMappedContent";//str
							s_datadef.objectlabel="Map Content Tool";//str
							s_datadef.datatype="int";//str
							s_datadef.length=4;//num
							s_datadef.pk=0;//boolean
							s_datadef.required=0;//boolean
							s_datadef.validate="";//str
							s_datadef.inputtype="useMappedContent";//str
							s_datadef.maxlength="";//num
							s_datadef.height="";//num
							s_datadef.width="";//num
							s_datadef.lookuptype="";//str: table,query,list
							s_datadef.lookuplist="";//str
							s_datadef.lookupquery="";//str
							s_datadef.lookuptable="";//str
							s_datadef.lookupkey="";//str
							s_datadef.lookupdisplay="";//str
							s_datadef.lookupmultiple="";//num
							s_datadef.defaultvalue="1";//str
							s_datadef.inputstyle="submitbutton";//str
							s_datadef.gridposlabel="#newRowIndex#_1";//str
							s_datadef.gridposvalue="#newRowIndex#_1";//str
							s_datadef.commit=0;//num
							s_datadef.javascript="";//str
							s_datadef.javascriptHandler="";//str
							s_datadef.formatonly="CONTENT MAPPING LINK (do not edit)"; //str
							s_datadef.useMappedContent=1;//bool
							s_datadef.tabindex=0;//
							s_datadef.readonly=0;//boolean
							a_formelements[val(arraylen(a_formelements) +1)]=s_datadef;
						</cfscript>
						<!--- convert form elements back to XML and insert into form scope --->
						<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="CFML2XML"
							input="#a_formelements#"
							output="form.datadefinition">
						<!--- update form scope with new row count --->
						<cfset form.tablerows = newRowIndex>
					<cfelse>
						<!--- Do nothing since it already exists --->
					</cfif>
				<!--- not requested--->
				<cfelse>
					<!--- loop through the existing list to see if the element already exists --->
					<cfset newElementArray = ArrayNew(1)>
					<cfloop from="1" to="#ArrayLen(a_formelements)#" index="i">
						<!--- test each value and skip mapped content element --->
						<cfif NOT findnocase(a_formelements[i].fieldname, "useMappedContent")>
							<cfset newElementArray[val(ArrayLen(newElementArray)+1)] = a_formelements[i]>
						</cfif>
					</cfloop>
					<!--- assigned cleaned array back to original --->
					<cfset a_formelements = newElementArray>
					<!--- convert table elements back to XML and insert into form scope --->
					<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="CFML2XML"
						input="#a_formelements#"
						output="form.datadefinition">
				</cfif>
				<!--- commit these new changes back to the form object table--->
				<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE" 
					tablename="formobject"
					datasource="#application.datasource#"
					primarykeyfield="#form.formobjectid#"
					assignidfield="formobjectid">
			</cfif>
			<!--- 12/11/2006 DRK manage addition/removal of content mapping element END --->
					
<!--- Write necessary include files, dirs, etc. --->
<cfinclude template="i_getFormobject.cfm">
	<!--- build engine code --->
	<cfsavecontent variable="engineCode">
	<cfoutput>#chr(60)#!--- Call FormProcess Tag to dynamically build "#form.label#" ---#chr(62)##chr(10)#
	#chr(60)#cfmodule template="#application.customTagPath#/formprocess.cfm"
			formobjectid="#formobjectid#"#chr(62)#</cfoutput>
	</cfsavecontent>
	
	<!---  try to create engine file directory --->
	<!--- see if there already is one --->
	<cfif NOT directoryExists("#application.installpath#\#replaceNoCase(q_getform.engineDefaultPath,'*',q_getform.formname,'all')#")>
		<cfdirectory action="CREATE"
	             directory="#application.installpath#\#replaceNoCase(q_getform.engineDefaultPath,'*',q_getform.formname,'all')#">
	</cfif>
	<!--- Create subdir in includes to hold interrupt scripts --->
	<cfif NOT directoryExists("#application.installpath#\admintools\includes\#q_getform.formname#")>
		<cfdirectory action="CREATE"
	             directory="#application.installpath#\admintools\includes\#q_getform.formname#">
	</cfif>
	<cfloop list="preshowform,prevalidate,preconfirm,postconfirm,precommit,postcommit" index="i">
		<cfif NOT fileExists("#application.installpath#\admintools\includes\#q_getform.formname#\i_#i#.cfm")>
			<cffile action="WRITE" 
				file="#application.installpath#\admintools\includes\#q_getform.formname#\i_#i#.cfm" 
				output="<!--- i_#i#.cfm --->#chr(10)##chr(13)#" 
				addnewline="No">
		</cfif>
	</cfloop>
				
<cflocation url="#request.page#?toolaction=DEShowForm&formobjectid=#trim(form.formobjectid)#">

<cfelse>
	<cfinclude template="i_DTShowForm.cfm">
</cfif>

