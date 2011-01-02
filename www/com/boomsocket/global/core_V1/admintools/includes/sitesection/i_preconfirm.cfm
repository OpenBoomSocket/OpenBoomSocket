<!--- i_preconfirm.cfm --->
<!--- Block delete of section dir if there are any children --->
<cfif isDefined("form.deleteinstance")>
	<cfloop list="#deleteinstance#" index="X">
		<cfquery datasource="#application.datasource#" name="q_check4pages" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT pageid
			FROM page
			WHERE sitesectionid = #trim(X)#
		</cfquery>
		<cfquery datasource="#application.datasource#" name="q_check4dirs" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT sitesectionid
			FROM sitesection
			WHERE sitesectionparent = #trim(X)# 
			AND sitesectionparent <> sitesectionid
		</cfquery>
		<cfif val(q_check4dirs.recordcount + q_check4pages.recordcount)>
			<cfset request.isError=1>
			<cfset request.errorMsg="You cannot delete this section until you have removed all pages and/or sub-sections which reside within it.">
			<cfset request.formstep="validate">
			<cfset form.validatelist="">
			<cfset request.stopProcess="confirm">
			<cfset form.instanceid=deleteinstance>
			<cfinclude template="/#application.sitemapping#/admintools/core/sitesection/index.cfm">
		</cfif>		
	</cfloop>
	
</cfif>
<cfif isDefined("instanceid")>
<!--- Create directory path for old section --->
	<cfset dirPath="#application.installpath##application.slash##application.getSectionPath(sitesectionid,"true")#">
	<cfset structInsert(form,"olddirPath","#dirPath#")>
</cfif>
