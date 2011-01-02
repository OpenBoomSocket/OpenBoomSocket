<!--- i_precommit.cfm --->
<!--- Delete the Data Driven Display file if we are on a delete --->
<cfif isDefined("deleteinstance")>
	<cfloop list="#form.deleteinstance#" index="w">
		<cfif fileExists("#application.installpath#\displayhandlers\d_#w#.cfm")>
			<cffile action="DELETE" file="#application.installpath#\displayhandlers\d_#w#.cfm">
		</cfif>
		<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE"
				 datasource="#application.datasource#"
				 tablename="displayhandler"
				 whereclause="displayhandlerid=#trim(w)#">
		<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE"
				 datasource="#application.datasource#"
				 tablename="pagecomponent"
				 whereclause="displayhandlerid=#trim(w)#">
	</cfloop>
	<cfset request.stopprocess="commit">
	<cflocation url="#request.page#" addtoken="No">
</cfif>
<!--- if we aren't editing--->
	<cfif NOT isDefined("form.instanceid")>
		<cfset form.displayobjectid=listFirst(form.displayobjectid,"~")>
		<cfset form.datecreated=createODBCDate(now())>
		<cfset form.datemodified=createODBCDate(now())>
		<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
				 datasource="#application.datasource#"
				 tablename="displayhandler"
				 assignidfield="displayhandlerid">
		<cfset form.displayhandlerid=insertid>
		<!--- if cfc --->
		<cfif NOT len(form.custominclude)>
			<!--- Rename temp invoke file with it's new ID --->
			<cfset form.invokefilename="d_#insertid#.cfm">
			<cfif isDefined('form.tempfilename') AND fileExists("#application.installpath#\displayhandlers\#trim(form.tempfilename)#")>
			<cffile action="RENAME"
			        source="#application.installpath#\displayhandlers\#trim(form.tempfilename)#"
			        destination="#application.installpath#\displayhandlers\#form.invokefilename#">
			</cfif>
			<cfset form.datemodified=createODBCDate(now())>
			<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE"
				 datasource="#application.datasource#"
				 tablename="displayhandler"
				 whereclause="displayhandlerid=#form.displayhandlerid#">
		</cfif>
<cfelse>
	<cfset form.displayobjectid=listFirst(form.displayobjectid,"~")>
	<cfset form.datemodified=createODBCDate(now())>
	<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE"
		 datasource="#application.datasource#"
		 tablename="displayhandler"
		 whereclause="displayhandlerid=#form.instanceid#">
	</cfif>	
	<cfset request.stopprocess="commit">
	<!--- if not in page component wiz --->
	<cfif NOT isDefined("form.containerid") OR NOT len(form.containerid)>
		<cflocation url="#request.page#" addtoken="No">
	<cfelse>
<!--- we are creating page components --->
<!--- clear out this record first in case the displayhandlerid is changing --->
	<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE"
			 datasource="#application.datasource#"
			 tablename="pagecomponent"
			 whereclause="containerid=#trim(form.containerid)# AND pageid=#trim(form.pageid)#">
<!--- write new record to pagecomponent table--->
	<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
			 datasource="#application.datasource#"
			 tablename="pagecomponent"
			 assignidfield="pagecomponentid">
	<!--- Stop before going to commit and redirect --->
	<cfset request.stopprocess="commit">
		<cfset session.i3currentTool=application.tool.pagecomponentwizard>
		<cflocation url="/admintools/core/pagecomponentwizard/dhpopup.cfm?editpageid=#pageid#&containerid=#form.containerid#" addtoken="No">
</cfif>
