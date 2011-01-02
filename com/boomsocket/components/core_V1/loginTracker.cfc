<cfcomponent displayname="Login Tracker" hint="Tracks a loggedin users activity in i3ST">
	<cffunction access="public" name="insertActivity" output="false" returntype="void" displayname="insertActivity">
		<cfargument name="loginTrackerName" required="yes" type="string" displayname="login Tracker Name">
		<cfargument name="httpRemoteAddr" required="yes" default="Unable to determine Remote Addr" type="string" displayname="http Remote Addr">
		<cfargument name="httpRemoteHost" required="yes" default="Unable to determine Remote Host" type="string" displayname="http Remote Host">
		<cfargument name="httpUserAgent" required="yes" default="Unable to determine User Agent" type="string" displayname="http User Agent">
		<cfargument name="activity" required="yes" default="Unable to determine Activity" type="string" displayname="activity">
		<cfargument name="httpReferrer" required="yes" default="No Referrer" type="string" displayname="http Referrer">
		<cftry>
			<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="loginTracker" datasource="#APPLICATION.datasource#">
			<cfquery name="q_insertActivity" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				INSERT into loginTracker
					(loginTrackerID,loginTrackerName,httpRemoteAddr,httpRemoteHost,httpUserAgent,activity,httpReferrer)
				VALUES
					(#newID#,'#arguments.loginTrackerName#','#arguments.httpRemoteAddr#','#arguments.httpRemoteHost#','#arguments.httpUserAgent#','#arguments.activity#','#arguments.httpReferrer#')
			</cfquery>
				<cfcatch type="database">
					<cflog text="Failed to write Tracker Information: #newID#,'#arguments.loginTrackerName#','#arguments.httpRemoteAddr#','#arguments.httpRemoteHost#','#arguments.httpUserAgent#','#arguments.activity#','#arguments.httpReferrer#'" type="Error" file="LoginTracker" application="yes">
				</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>