<cfsilent>
<cfparam name="form.username" default="">
<cfparam name="form.password" default="">
<cfparam name="URL.return" default="/admintools/index.cfm">
<cfparam name="URL.q" default="i3displayMode=welcome&initializeApp=yes">		
			
<cfif findnocase("welcome",URL.q) eq 0>
	<cfset count=1>
	<cfloop list="#CGI.QUERY_STRING#" delimiters="&" index="rest">
		<cfif count GTE 3>
			<cfset URL.q = URL.q&"&"&rest>
		</cfif>
		<cfset count = count+1>
	</cfloop>
</cfif>
<!--- Check if password has been chagned --->
<cfif isdefined("form.newPassword") AND len(trim(form.newPassword)) AND isdefined("form.username") AND len(trim(form.username))>
	<cftry>
		<cfquery datasource="#application.datasource#" name="q_authenticate" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			UPDATE users
			<cfif isdefined('application.useStrongEncryption') AND application.useStrongEncryption>
				<cfset useThisPass = trim(form.newPassword)&application.saltEncrypt>
				SET password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(useThisPass,'SHA-512')#" maxlength="500">
			<cfelse>
				<cfset useThisPass = trim(form.newPassword)>
				SET password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(useThisPass)#" maxlength="500">
			</cfif>
			WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.username#" maxlength="500">
		</cfquery>
		<cfset passwordChanged = true>
	<cfcatch type="database">
		<cfset passwordChanged = false>
		<cfrethrow>
	</cfcatch>
	</cftry>
</cfif>
<!--- Logout this user --->
<cfif isDefined("logout")>
	<cflock scope="SESSION" timeout="5" type="EXCLUSIVE">
		<cfset structClear(session)>
	</cflock>
</cfif>
<!--- User is already logged in, redirect them home --->
<cfif isDefined("session.user")>
	<cflocation url="index.cfm" addtoken="No">
</cfif>

<!--- Switch live edit mode toggle if var is present --->
<cfif isDefined("liveEdit")>
	<cfif session.user.liveedit>
		<cflock scope="SESSION" timeout="5" type="EXCLUSIVE">
			<cfset session.user.liveEdit=0>
		</cflock>
		<cflocation url="/admintools/" addtoken="No">
	<cfelse>
		<cflock scope="SESSION" timeout="5" type="EXCLUSIVE">
			<cfset session.user.liveEdit=1>
		</cflock>
		<cflocation url="/" addtoken="No">
	</cfif>
</cfif>
<cfif left(CGI.SERVER_NAME,3) EQ "dp0">
	<cfparam name="launchWindow" default="1">
<cfelse>
	<cfparam name="launchWindow" default="0">
</cfif>

<cfif len(trim(form.password)) AND len(trim(form.username))>
<!--- query for this users tool permissions --->
	<cfquery datasource="#application.datasource#" name="q_authenticate" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT Users.Usersid, userpermission.access, userpermission.addEdit, userpermission.approve, userpermission.remove, userpermission.formobjectid, Users.firstName, UserType.roleid
			FROM Users 
				LEFT OUTER JOIN UserType 
					ON Users.usertypeid = UserType.UserTypeid 
				LEFT OUTER JOIN userpermission 
					ON Users.Usersid = userpermission.userid
			WHERE
			(Users.username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(form.username)#" maxlength="500"> 
			<cfif isdefined('application.useStrongEncryption') AND application.useStrongEncryption>
				<cfset useThisPass = trim(form.password)&application.saltEncrypt>
				AND users.password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(useThisPass,'SHA-512')#" maxlength="500">
			<cfelse>
				<cfset useThisPass = trim(form.password)>
				AND users.password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(useThisPass)#" maxlength="500">
			</cfif>
			)
	</cfquery>
<!--- store session structure containing all permissions for user --->
	<cfif q_authenticate.recordcount>
		<cfset user=structNew()>
		<cfset user.name=q_authenticate.firstname>
		<cfset user.id=q_authenticate.usersid>
		<cfset user.liveEdit=0>
		<cfset user.accessLevel=q_authenticate.roleid>
		<cfset tools=arrayNew(2)>
		<cfloop query="q_authenticate">
			<cfset rights=structNew()>
			<cfset rights.access=q_authenticate.access>
			<cfset rights.addedit=q_authenticate.addedit>
			<cfset rights.remove=q_authenticate.remove>
			<cfset tools[q_authenticate.currentrow][1]=q_authenticate.formobjectid>
			<cfset tools[q_authenticate.currentrow][2]=rights>
		</cfloop> 
		<cfset user.tools=tools>
		<cflock scope="SESSION" timeout="5" type="EXCLUSIVE">
			<cfset session.user=user>
		</cflock>
		<cfif ISDefined('FORM.reroute') AND Len(Trim(FORM.reroute))>
			<cflocation url="#FORM.reroute#" addtoken="no">
		<cfelse>
			<cflocation url="index.cfm?i3displayMode=welcome&initializeApp=yes" addtoken="no">
		</cfif>
		
	<cfelse>
		<cfset loginError = 1>
	</cfif>
</cfif>
</cfsilent>
<cfoutput>
	<cfsavecontent variable="showLoginInfoJS">
		<script type="text/javascript">
			function showLoginInfo(){
				if(document.getElementById('loginInfoBox')){
					var state = document.getElementById('loginInfoBox').style.display;
					if(state == 'none'){
						document.getElementById('loginInfoBox').style.display = "block";
					}else{
						document.getElementById('loginInfoBox').style.display = "none";
					}
				}	
			}
		</script>
	</cfsavecontent>
	<cfhtmlhead text="#showLoginInfoJS#">
	<cfmodule template="#application.customTagPath#/adminskin.cfm" admintemplate="login" css="">
		<div id="loginBox">
			<cfif isDefined("loginError")>
				<div id="loginErrorText">Login incorrect. Please try again.</div>
			</cfif>
			<cfif isdefined("passwordChanged")>
				<cfif passwordChanged EQ true>
					<div id="loginErrorText">Password successfully changed.</div>
				<cfelse>
					<div id="loginErrorText">Error changing password.</div>
				</cfif>
			</cfif>
			<form action="#request.page#" method="post" name="login">
				<input type="hidden" name="reroute" value="#URL.return#?#URL.q#&initializeApp=yes" />
				<table border="0" cellspacing="0" cellpadding="3" id="loginFormTable">
					<tr>
					  <td align="right">Username:</td>
					  <td><input type="text" id="username" name="username" size="15"></td>
					</tr>
					<tr>
					  <td align="right">Password:</td>
					  <td><input type="Password" name="password" size="15"></td>
					</tr>
					<tr>
						<td colspan="2" align="right"><input name="login" type="image" id="loginButton" value="Launch" src="/admintools/media/images/launch_button.gif" alt="Launch!" /></td>
					</tr>
					<tr>
						<td colspan="2" valign="bottom" align="left"><br /><a href="/admintools/forgotpassword.cfm">Forgot your password?<br /> Reset it now.</a></td>
					</tr>
				</table>
				<table id="loginDisclaimerTable" cellspacing="0" cellpadding="0">
					<tr>
						<td>Supported Platform / Browser Combinations:
							<ul id="platformList">
							  <li>Windows :: Internet Explorer 7.0+</li>
							  <li>Windows :: Firefox 1.5+</li>
							  <li>Macintosh :: Firefox 1.5+</li>
							  <li>Macintosh :: Safari 2.x+</li>
							</ul>
							<p>Other platforms may cause unpredictable behavior.</p>
						</td>
					</tr>
				</table></form>
				<script type="text/javascript">document.login.username.focus();</script>
			<div id="loginInfoButton"><a href="##" onclick="showLoginInfo();" title="Click here to see your platform/browser information."><img src="/admintools/media/images/icon_loginInfo.gif" width="30" height="29" border="0" /></a></div>
			<div id="loginInfoBox" style="display:none;">
				You are using: #application.browserDetect()# on #application.osDetect()#<br>
				You are coming from: #CGI.REMOTE_ADDR#<br>
				Your Remote Host is: #CGI.REMOTE_HOST#
			</div>
		</div>
	</cfmodule>
</cfoutput>


