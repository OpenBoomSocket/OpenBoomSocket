<!--- i_postcommit.cfm --->

<!--- if user has selected a prebuilt content object, skip insert --->
<cfif NOT isDefined("deleteinstance")>
	<cfif isDefined("form.pageid") AND isDefined("form.contentid")>
		<cfset form.contentobjectid=listFirst(form.contentid,"~")>
	</cfif>	 
	
	<!--- if we are currently looping through containers on a page update and go back --->
	<cfif isDefined("pageid") AND len(trim(pageid))><!--- if we are coming from a page create --->
	<!--- clear out this record first in case the displayhandlerid is changing --->
		<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE"
				 datasource="#application.datasource#"
				 tablename="pagecomponent"
				 whereclause="containerid=#trim(form.containerid)# AND pageid=#trim(form.pageid)#">
	<!--- write new record to pagecomponent table--->
		<cfset form.datemodified=createODBCdateTime(now())>
		<cfset form.datecreated=createODBCdateTime(now())>
		<cfif isDefined("insertid")>
			<cfset form.contentobjectid=insertid>
		</cfif>
		<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
				 datasource="#application.datasource#"
				 tablename="pagecomponent"
				 assignidfield="pagecomponentid">
		<cfset session.i3currentTool=application.tool.pagecomponentwizard>
		<cflocation url="/admintools/core/pagecomponentwizard/contentpopup.cfm?editpageid=#pageid#&containerid=#form.containerid#" addtoken="No">
	</cfif>
<cfelse>
	<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE"
				 datasource="#application.datasource#"
				 tablename="pagecomponent"
				 whereclause="contentobjectid IN (#deleteinstance#)">
</cfif>