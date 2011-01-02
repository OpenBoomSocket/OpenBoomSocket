<cfset thisInstance="">
<cfset thisToolID="">
<cfset SESSION.showMappingButton=1>
<cfif isDefined("session.user.liveEdit")>
	<cfif isDefined('URL.solutionID')>
		<cfset thisInstance=URL.solutionID>
		<cfset thisToolID=APPLICATION.tool.solution>
	<cfelseif isDefined('URL.table') AND isDefined('URL.key') AND (URL.table EQ 'solution')>
		<cfset thisToolID=APPLICATION.tool.solution>
		<cfquery name="q_IDfromSekeyname" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT #URL.table#ID
			FROM #URL.table#
			WHERE #URL.table#.sekeyname = '#URL.key#'
		</cfquery>
		<cfset thisInstance=evaluate("q_IDfromSekeyname.#URL.table#ID")>
	<cfelseif REQUEST.thispageid EQ 100009 >
		<cfset thisInstance=REQUEST.thispageid>
		<cfset thisToolID=103>
	<cfelse>
	</cfif>
	<cfoutput>
	<cfif len(trim(thisInstance)) AND len(trim(thisToolID))>
		<a href="" class="MappingLink" onclick="javascript:window.open('/admintools/includes/i_ContentMapping.cfm?thistoolid=#thisToolID#&thisInstance=#thisInstance#','MapContent','menubar=no,statusbar=no,resizable,width=600,height=400');">Associate Content</a>
	<cfelse>
		<cfset SESSION.showMappingButton=0>
	</cfif>
	</cfoutput>
</cfif>