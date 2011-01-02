<cfinclude template="i_validateCustom.cfm">
<cfinclude template="i_validate.cfm">
<cfif NOT request.isError>
	<cfparam name="form.pk" default="0">
	<cfparam name="form.required" default="0">
	<cfparam name="form.commit" default="0">
	
	<cfquery datasource="#application.datasource#" name="q_getDataDef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT  *
		FROM   formobject INNER JOIN formEnvironment ON formobject.formEnvironmentID = formEnvironment.formEnvironmentID
		WHERE  (formobject.formobjectid = #form.formobjectid#)
	</cfquery>
	<!--- Query and deserialize form data definition --->
	<cftry>
		<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
			input="#q_getdatadef.datadefinition#"
			output="a_formelements">
		<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML"
			input="#q_getdatadef.tabledefinition#"
			output="a_tableelements">
		<cfcatch type="Any">
			<h1>Invalid XML Object</h1>The object you are trying to reference is not recognizable XML. Check the database.
			<cfdump var="#q_getDataDef.datadefinition#">
			<cfabort>
		</cfcatch>		
	</cftry>
	
	<!--- set an array position, form. if we're editing, otherwise we're adding --->
	<cfif isDefined("form.arrayposition") AND NOT isDefined("form.addChildField")>
		<cfset arrayposition = trim(form.arrayposition)>
	<cfelse>
		<cfset arrayposition = arrayLen(a_formelements)+1>
	</cfif>
	<!--- ****** DATA STRUCTURE MANIPULATION (FOR PARENTS ONLY) ***** --->			 
	<!--- Test to see if data definition of column has changed, 
	if so set flags to overwrite and/or rename --->
	
	<cfif len(trim(form.edit)) AND NOT isDefined("form.addChildField")>
		<cfif (a_formelements[arrayposition].datatype NEQ trim(form.datatype)) OR (a_formelements[arrayposition].length NEQ trim(form.length)) OR ((a_formelements[arrayposition].commit EQ 0) AND (form.commit EQ 1))>
				<cfset overwritefield=1>
		</cfif>
		<!--- If only column name has been changed set flag for rename only --->
		<cfif (a_formelements[arrayposition].fieldname NEQ trim(form.fieldname))>
			<cfset renamefield=1>
			<cfset oldfieldname=a_formelements[arrayposition].fieldname>
		</cfif>
	</cfif>
	
	<cfparam name="overwritefield" default=0>
	<cfparam name="renamefield" default=0>

<!--- UPDATE xml structure --->
	<cfscript>
			s_datadef=structNew();
			s_datadef.fieldname=form.fieldname;//str
			s_datadef.objectlabel=form.objectlabel;//str
			s_datadef.datatype=form.datatype;//str
			s_datadef.length=form.length;//num
			s_datadef.pk=form.pk;//boolean
			s_datadef.required=form.required;//boolean
			s_datadef.validate=form.validate;//str
			s_datadef.inputtype=form.inputtype;//str
			s_datadef.maxlength=form.maxlength;//num
			s_datadef.height=form.height;//num
			s_datadef.width=form.width;//num
			s_datadef.lookuptype=form.lookuptype;//str: table,query,list
			s_datadef.lookuplist=form.lookuplist;//str
			s_datadef.lookupquery=form.lookupquery;//str
			s_datadef.lookuptable=form.lookuptable;//str
			s_datadef.lookupkey=form.lookupkey;//str
			s_datadef.lookupdisplay=form.lookupdisplay;//str
			s_datadef.lookupmultiple=form.lookupmultiple;//num
			s_datadef.defaultvalue=form.defaultvalue;//str
			s_datadef.inputstyle=form.inputstyle;//str
			s_datadef.gridposlabel=listchangedelims(form.gridposlabel,"_",",");//str
			s_datadef.gridposvalue=listchangedelims(form.gridposvalue,"_",",");//str
			s_datadef.commit=form.commit;//int
			s_datadef.javascript=form.javascript;//str
			s_datadef.javascriptHandler=form.javascriptHandler;//str
			s_datadef.tabindex=form.tabindex;//num
			if (not isDefined("form.readonly")){
				s_datadef.readonly=0;//boolean
			}else {
				s_datadef.readonly=form.readonly;//boolean
			}
			if (not isDefined("form.uploadcategoryid")){
				s_datadef.uploadcategoryid=0;//int
			}else {
				s_datadef.uploadcategoryid=listfirst(form.uploadcategoryid,'|');//int
			}
			if (not isDefined("form.formatonly")){
				s_datadef.formatonly="";//str
			}else {
				s_datadef.formatonly=form.formatonly;//str
			}
			if (not isDefined("form.custominclude")){
				s_datadef.custominclude="";//str
			}else {
				s_datadef.custominclude=form.custominclude;//str
			}
			if (not isDefined("form.sekeynamefield")){
				s_datadef.sekeynamefield="";//str
			}else {
				s_datadef.sekeynamefield=form.sekeynamefield;//str
			}
			if (not isDefined("form.calendarPopUp")){
				s_datadef.calendarPopUp="";//str
			}else {
				s_datadef.calendarPopUp=form.calendarPopUp;//str
			}
			if (not isDefined("form.colorPicker")){
				s_datadef.colorPicker="";//str
			}else {
				s_datadef.colorPicker=form.colorPicker;//str
			}
			if (not isDefined("form.bs_pageTitlefield")){
				s_datadef.bs_pageTitlefield="";//str
			}else {
				s_datadef.bs_pageTitlefield=form.bs_pageTitlefield;//str
			}
			if (not isDefined("form.imagebuttonpath")){
				s_datadef.imagebuttonpath="";//str
			}else {
				s_datadef.imagebuttonpath=form.imagebuttonpath;//str
			}
			if (not isDefined("form.cancelbuttonimage")){
				s_datadef.cancelbuttonimage="";//str
			}else {
				s_datadef.cancelbuttonimage=form.cancelbuttonimage;//str
			}
			if (not isDefined("form.submitbuttonimage")){
				s_datadef.submitbuttonimage="";//str
			}else {
				s_datadef.submitbuttonimage=form.submitbuttonimage;//str
			}
			// 12/04/2006 DRK add test for imported form fields
			if (isDefined("form.SOURCEFORMOBJECTID") AND form.SOURCEFORMOBJECTID NEQ 0){
				s_datadef.SOURCEFORMOBJECTID=form.SOURCEFORMOBJECTID;//int
			}
			// 12/05/2006 DRK add test for imported form fields editable
			if (isDefined("form.COMMITFOREIGNTABLE")){
				s_datadef.COMMITFOREIGNTABLE=listLast(form.COMMITFOREIGNTABLE);//int
			}
			// 12/14/2006 DRK master key flag for update/insert ordering
			if (isDefined("form.ISMASTERTABLE")){
				s_datadef.ISMASTERTABLE=listLast(form.ISMASTERTABLE);//int
			}
			if (isDefined("form.FOREIGNKEY")){
				s_datadef.FOREIGNKEY=1;//int
				if (isDefined("form.COMMITFOREIGNTABLE")){
					s_datadef.COMMITFOREIGNTABLE=1;//int
				}else{
					s_datadef.COMMITFOREIGNTABLE=0;//int
				}
				if (isDefined("form.ISMASTERTABLE")){
					s_datadef.ISMASTERTABLE=1;//int
				}else{
					s_datadef.ISMASTERTABLE=0;//int
				}
			}
			a_formelements[arrayposition]=s_datadef;
	</cfscript>
	<!--- check for required field and update table class --->
	<cfset thisRow=a_tableelements[listfirst(s_datadef.gridposlabel,'_')]>
	
	<cfif NOT overwritefield>
		<cfset SESSION.currentFieldRow = listfirst(s_datadef.gridposlabel,'_')+1>
	</cfif>
	
	<cfif s_datadef.required>
		<cfset "thisRow.cell_#listlast(s_datadef.gridposlabel,'_')#.class" = "formitemlabelreq">
	<cfelse>
		<cfset "thisRow.cell_#listlast(s_datadef.gridposlabel,'_')#.class" = "formitemlabel">
	</cfif>
	<cfset a_tableelements[listfirst(s_datadef.gridposlabel,'_')] = thisRow>
<!--- serialize CF array structure and update database definition --->
	<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="CFML2XML"
        input="#a_formelements#"
        output="form.datadefinition">
	<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="CFML2XML"
        input="#a_tableelements#"
        output="form.tabledefinition">
		
	<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE" 
			tablename="formobject"
			datasource="#application.datasource#"
			whereclause="formobjectid=#trim(form.formobjectid)#"
			assignidfield="formobjectid">

<!--- ONLY run this code if we are dealing with a field which is committing to the db --->
	<cfif q_getDataDef.datacapture>
		<cftransaction>
			<cfif len(trim(form.edit))><!--- Edit column mode  --->
				<cfif listlast(form.commit)><!--- determine how to commit changes to column --->
					<cfif overwritefield>
						<!--- drop this column --->
						<cfquery name="q_getTables" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT TOP 1 *
							FROM #q_getDataDef.datatable# 
						</cfquery>
						<cfif listFindNoCase(q_getTables.columnlist,trim(form.edit))>
							<cfquery datasource="#application.datasource#" name="q_dropField" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
								ALTER TABLE #q_getDataDef.datatable# DROP COLUMN #trim(form.edit)#
							</cfquery>
						</cfif>
						<!--- add column back with new attributes --->
						<cfquery datasource="#application.datasource#" name="q_createColumn" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							ALTER TABLE #q_getDataDef.datatable#
								ADD #form.fieldname# #form.datatype#<cfif form.datatype EQ "nvarchar" OR form.datatype EQ "varchar"> (#form.length#)</cfif> NULL; 
							<cfif form.pk>
							ALTER TABLE [#q_getDataDef.datatable#] WITH NOCHECK ADD 
								CONSTRAINT [PK_#q_getDataDef.fieldname#] PRIMARY KEY  CLUSTERED 
								(
									[#form.fieldname#]
								)  ON [PRIMARY];
							</cfif>
						</cfquery>
					<cfelseif renamefield>
						<cfquery datasource="#application.datasource#" name="q_renameColumn" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SP_RENAME '#q_getDataDef.datatable#.#oldfieldname#','#trim(form.fieldname)#'
						</cfquery>
					</cfif>
				<cfelse><!--- drop this column --->
					<cfquery name="q_getTables" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT TOP 1 *
						FROM #q_getDataDef.datatable# 
					</cfquery>
					<cfif listFindNoCase(q_getTables.columnlist,trim(form.edit))>
						<cfquery datasource="#application.datasource#" name="q_dropField" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							ALTER TABLE #q_getDataDef.datatable# DROP COLUMN #trim(form.edit)#
						</cfquery>
					</cfif>
				 </cfif>
		<cfelse><!--- add this new column --->
			<!--- add column back with new attributes if it is to be committed--->
			<cfif form.commit>
				<cfquery datasource="#application.datasource#" name="q_createColumn" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					ALTER TABLE #q_getDataDef.datatable#
						ADD #form.fieldname# #form.datatype#<cfif form.datatype EQ "nvarchar" OR form.datatype EQ "varchar"> (#form.length#)</cfif> NULL; 
					<cfif form.pk>
					ALTER TABLE [#q_getDataDef.datatable#] WITH NOCHECK ADD 
						CONSTRAINT [PK_#q_getDataDef.fieldname#] PRIMARY KEY  CLUSTERED 
						(
							[#form.fieldname#]
						)  ON [PRIMARY];
					</cfif>
				</cfquery>
			</cfif>
		</cfif>
			
			
			<!--- If this is a child form --->
			<cfif NOT q_getDataDef.parentid EQ formobjectid>
				<cfif listFindNoCase(q_getDataDef.omitfieldlist,"#form.fieldname#")>
					<cfset thisListPos=listFindNoCase(q_getDataDef.omitfieldlist,"#form.fieldname#")>
					<cfquery datasource="#application.datasource#" name="q_updateOmits" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						UPDATE formobject
						SET omitfieldlist = '#listDeleteAt(q_getDataDef.omitfieldlist,thisListPos)#'
						WHERE formobjectid = #formobjectid#
					</cfquery>
				</cfif>
			</cfif>
			<!--- get all children of this form --->
			<cfquery datasource="#application.datasource#" name="q_getAllChildren" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT *
				FROM formobject
				WHERE parentid = #formobjectid#
				AND formobjectid <> #formobjectid#
			</cfquery>
			<cfif q_getAllChildren.recordcount>
				<cfloop query="q_getAllChildren">
				<!--- if it has 'edit', change to 'fieldname' --->
					<cfif listFindNoCase(q_getAllChildren.omitfieldlist,trim(form.edit))>
						<cfquery datasource="#application.datasource#" name="q_dropFieldname" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							UPDATE formobject
							SET omitfieldlist='#listDeleteAt(q_getAllChildren.omitfieldlist,listFindNoCase(q_getAllChildren.omitfieldlist,trim(form.edit)))#'
							WHERE formobjectid = #q_getAllChildren.formobjectid#
						</cfquery>
						<cfquery datasource="#application.datasource#" name="q_getomitList" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT omitfieldlist, formobjectid
							FROM formobject
							WHERE formobjectid = #formobjectid#
						</cfquery>
						<cfquery datasource="#application.datasource#" name="q_addFieldname" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							UPDATE formobject
							SET omitfieldlist='#listAppend(q_getomitList.omitfieldlist,"#form.fieldname#")#'
							WHERE formobjectid = #q_getAllChildren.formobjectid#
						</cfquery>
					<cfelse>
				<!--- If this is a new field, add to child omitfieldlists --->
						<cfif NOT len(trim(form.edit))>
							<cfquery datasource="#application.datasource#" name="q_getomitList" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
								SELECT omitfieldlist, formobjectid
								FROM formobject
								WHERE formobjectid = #formobjectid#
							</cfquery>
							<cfquery datasource="#application.datasource#" name="q_addFieldname" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
								UPDATE formobject
								SET omitfieldlist='#listAppend(q_getomitList.omitfieldlist,"#form.fieldname#")#'
								WHERE formobjectid = #q_getAllChildren.formobjectid#
							</cfquery>
						<cfelse>
				<!--- Recursively update xml for all children already using old field info --->
							<cfinclude template="i_updateChildXML.cfm">
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cftransaction> 
	</cfif>
		
	 <cflocation url="#request.page#?formobjectid=#formobjectid#&toolaction=DEShowForm">
<cfelse>
	<cfinclude template="i_DEShowForm.cfm">
</cfif>