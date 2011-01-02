<cfinclude template="i_validate.cfm"> 
<h1>hello</h1><cfabort>
<cfif len(formobjectid)>
	<!--- get table definition --->
	<cfquery datasource="#application.datasource#" name="q_gettabledef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT tabledefinition, tablecolumns, tablerows
		FROM formobject
		WHERE formobjectid = #trim(formobjectid)#
	</cfquery>
	<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
		input="#q_gettabledef.tabledefinition#"
		output="a_tableelements">
<cfelse>
	<cfset a_tableelements=arrayNew(1)>
</cfif>

<cfif NOT request.isError>
	<!--- test for edit, if not edit mode, set defualts --->
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
						"cell_#j#.align"=0;//num
						"cell_#j#.class"="";//num
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
						if (isDefined("a_tableelements[#i#].cell_#j#.nowrap")) {
							"cell_#j#.class"=evaluate("a_tableelements[#i#].cell_#j#.nowrap");//bit
						} else {
							"cell_#j#.class"=0;
						}	
						"row_#i#.cell_#j#"=evaluate("cell_#j#");
						writeOutput("bleh");
					 } 
					 } else {
					 	"cell_#j#"=structNew();
						"cell_#j#.colspan"=0;//num
						"cell_#j#.rowspan"=0;//num
						"cell_#j#.width"=0;//num
						"cell_#j#.valign"=0;//num
						"cell_#j#.align"=0;//num
						"cell_#j#.class"="";//num
						"cell_#j#.nowrap"=0;//bit
						"row_#i#.cell_#j#"=evaluate("cell_#j#");
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
	
	<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="CFML2XML"
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
		  <cfmodule template="#application.customTagPath#/dbaction.cfm" 
					action="UPDATE" 
					tablename="formobject"
					datasource="#application.datasource#"
					primarykeyfield="#form.formobjectid#"
					assignidfield="formobjectid">
	<cfelse>
	<cfset form.datecreated=createODBCDateTime(now())>
		<cfset form.archive=0>
		<cfset form.lockDataTable=0>
		  <cfmodule template="#application.customTagPath#/dbaction.cfm" 
					action="INSERT" 
					tablename="formobject"
					datasource="#application.datasource#"
					assignidfield="formobjectid">
			<cfset form.formobjectid=insertid>
			<cfset form.parentid=insertid>
			<cfquery datasource="#application.datasource#" name="q_updateParentId" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE formobject 
				SET parentid = #insertid#
				WHERE formobjectid=#trim(form.formobjectid)#
			</cfquery>
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
			<cfset columnAddList="datecreated:datetime,datemodified:datetime,parentid:int,ordinal:int">
			<cfif form.restrictByUserType EQ 1>
				<cfset columnAddList=columnAddList&",restrictByUserTypeID:int">
			</cfif>
			<cfloop list="#columnAddList#" index="thisColumnAdd">
				<cfquery datasource="#application.datasource#" name="q_addIDColumn" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					ALTER TABLE #trim(form.newdatatable)#
					ADD [#listFirst(thisColumnAdd,":")#] #listLast(thisColumnAdd,":")# NULL
				</cfquery>
			</cfloop>
		</cfif>
	</cfif>
		<cfif isDefined("insertid")>
			<!--- Build XML object for first default column --->
				<cfscript>
				a_formelements=arrayNew(1);
					s_datadef=structNew();
						s_datadef.fieldname=trim(form.newdatatable)&"id";//str
						s_datadef.objectlabel=trim(form.newdatatable)&" ID";//str
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
				a_formelements[1]=s_datadef;
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
				a_formelements[2]=s_datadef;
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
				a_formelements[3]=s_datadef;
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
						s_datadef.gridposlabel="";//str
						s_datadef.gridposvalue="";//str
						s_datadef.formatonly="";//str
						s_datadef.uploadcategoryid="";//num
						s_datadef.commit=1;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
				a_formelements[4]=s_datadef;
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
						s_datadef.inputstyle="";//str
						s_datadef.gridposlabel="#form.tablerows#_#form.tablecolumns#";//str
						s_datadef.gridposvalue="#form.tablerows#_#form.tablecolumns#";//str
						s_datadef.commit=0;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.submitbuttonimage="";//str
				a_formelements[5]=s_datadef;
					s_datadef=structNew();
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
						s_datadef.inputstyle="";//str
						s_datadef.gridposlabel="#form.tablerows#_#form.tablecolumns#";//str
						s_datadef.gridposvalue="#form.tablerows#_#form.tablecolumns#";//str
						s_datadef.commit=0;//num
						s_datadef.javascript="";//str
						s_datadef.javascriptHandler="";//str
						s_datadef.cancelbuttonimage="";//str
				a_formelements[6]=s_datadef;
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
				a_formelements[7]=s_datadef;
				}
				if (form.restrictByUserType){
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
				a_formelements[arrayCount]=s_datadef;
				}
				</cfscript>
					<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="CFML2XML"
        input="#a_formelements#"
        output="form.datadefinition">
			</cfif>
			<cfset form.formobjectname=form.label>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" 
					action="UPDATE" 
					tablename="formobject"
					datasource="#application.datasource#"
					primarykeyfield="#form.formobjectid#"
					assignidfield="formobjectid">	
					
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
	
	<!---  write engine file --->
		<cffile action="WRITE"
		        file="#application.installpath#\#replaceNoCase(q_getform.engineDefaultPath,'*',q_getform.formname,'all')#\#replaceNoCase(q_getform.engineDefaultName,'*',q_getform.formname,'all')#"
		        output="#application.HtmlCompressFormat(engineCode)#">

<cfabort>
<cflocation url="#request.page#?toolaction=DEShowForm&formobjectid=#trim(form.formobjectid)#">
<cfelse>
	<cfinclude template="i_DTShowForm.cfm">
</cfif>

