<cfcomponent displayname="Global Error Handeling CFC">
	<cffunction name="notifyStaff" access="private" returntype="boolean" output="false" displayname="Notfify Staff">
		<cfargument name="notifyemail" required="yes" type="string" displayname="Notify Email">
		<cfargument name="fileToAttach" required="yes" type="string" displayname="File To Attach">.
		<cfargument name="fileRefName" required="yes" type="string" displayname="File Referance Name">
		<cfargument name="errorTypeName" required="no" type="string" displayname="Error Type Name" default="Unknown type">
		<cfset var returnThis = true>
			<cftry>
				<cfmail to="#arguments.notifyemail#" from="#application.adminemail#" subject="Server Automated: #arguments.errorTypeName# Error on #APPLICATION.sitemapping#" mimeattach="#arguments.fileToAttach#">
Attached is the HTML output of this error Dump.
You can also view this and all other errors at:
#APPLICATION.installurl#\admintools\errorTraps\#arguments.fileRefName#

Global Error Handler
				</cfmail>
				<cfcatch type="any">
					<cfset returnThis = false>
				</cfcatch>
			</cftry>
		<cfreturn returnThis>
	</cffunction>
	
	<cffunction name="writeErrorFile" access="private" returntype="boolean" output="false" displayname="Write thisError File">
		<cfargument name="thisError" type="struct" required="yes" displayname="thisError Struct">
			<cfset var directory = "#APPLICATION.installpath#\admintools\errorTraps\">
			<cfset var ErrorDate = DateFormat(now(),'mm_dd_yyyy')>
			<cfset var ErrorTime = TimeFormat(now(),'HH_mm_ss_l')>
			<cfset var filename = "#arguments.thisError.rootcause.type#-error-#ErrorDate#-#ErrorTime#.html">
			<cfset var returnThis = true>
			<cfsavecontent variable="ErrorTrapDump">
				<cfoutput>
					<cfdump var="#arguments.thisError#">
				</cfoutput>
			</cfsavecontent>
			<cftry>
				<cfif NOT DirectoryExists(directory)>
					<cfdirectory directory="#directory#" action="create">
				</cfif>
				<cffile action="write" addnewline="yes" file="#directory##filename#" output="<div align='center'><a href='/admintools/errorTraps/'>Return to Error Trap List for #APPLICATION.sitemapping#</a></div>#ErrorTrapDump#">				
				<cfset notifyDP = notifyStaff(notifyemail=arguments.thisError.mailto,fileToAttach=directory & filename,fileRefName=filename,errorTypeName=arguments.thisError.rootcause.type)>
					<cfcatch type="any">
						<cfset returnThis = false>
					</cfcatch>
			</cftry>
		<cfreturn returnThis>
	</cffunction>
	
	<cffunction name="createTicket" access="private" returntype="boolean" output="false" displayname="Create Ticket">
		<cfargument name="thisError" type="struct" required="yes" displayname="thisError Struct">
		<cfset var returnThis = true>
		<cfset var thisproblem = "">
		<cfsavecontent variable="thisProblem">
			<cfoutput>
				Error Message: #thisError.Message#<br>
				Diagnostics: #thisError.Diagnostics#<br>
				Template: #thisError.Template#<br>
				Query String: #thisError.QueryString#<br>
				Suspected Error URL: <a href="#application.installURL##thisError.Template#?#thisError.QueryString#&dpViewIt=1" target="_blank">#application.installURL##thisError.Template#?#thisError.QueryString#</a><br>
				HTTP Referer: #thisError.HTTPReferer#<br>
				Error Type: #thisError.RootCause.type#<br>
			</cfoutput>
		</cfsavecontent>
			<cftry>
				<cfquery name="q_insertTicket" datasource="dp03dpTime" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT into troubleTicket
						(tool, problem, dateSubmitted, dateCompleted, resolution, status, browser, clientCode, userEmail, debug, subject)
					VALUES
						('#thisError.Template#', '#Trim(thisProblem)#', #CreateODBCDateTime(now())#, #CreateODBCDateTime(now())#, '', 'New', '#thisError.browser#', '#Application.sitemapping#', '#application.adminemail#', '', 'Error Recorded On #Application.sitemapping#')
				</cfquery>
					<cfcatch type="any">
						<cfset returnThis = false>
					</cfcatch>
			</cftry>
		<cfreturn returnThis>
	</cffunction>
	
	<cffunction name="recordError" access="public" returntype="boolean" output="false" displayname="Record thisError">
		<cfargument name="thisError" type="struct" required="yes" displayname="thisError Struct">
		<cfargument name="createTicket" type="boolean" required="yes" default="yes">
		<cfset var returnThis = true>
			<cftry>
				<cfset writeFile = writeErrorFile(arguments.thisError)>
				<cfif arguments.createTicket>
					<cfset createTroubleTicket = createTicket(arguments.thisError)>
				</cfif>
					<cfcatch type="any">
						<cfset returnThis = false>
					</cfcatch>
			</cftry>
		<cfreturn returnThis>
	</cffunction>
</cfcomponent>