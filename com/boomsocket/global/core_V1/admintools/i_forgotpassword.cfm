<cfmodule template="#application.customTagPath#/adminskin.cfm" admintemplate="login" css="">
<cfset resetPassword = false>
<cfif isdefined("form.secretAnswer") AND len(trim(form.secretAnswer))>
	<cfquery datasource="#application.datasource#" name="q_getSecretAnswer" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT secretAnswer
	FROM users
	WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(form.username)#" maxlength="500">
	</cfquery>
	<cfif isdefined('application.useStrongEncryption') AND application.useStrongEncryption>
		<cfset hashedGivenAnswer = hash(trim(LCASE(form.secretAnswer))&application.saltEncrypt,'SHA-512')>
		<cfset hashedActualAnswer = hash(trim(LCASE(q_getSecretAnswer.secretAnswer))&application.saltEncrypt,'SHA-512')>
	<cfelse>
		<cfset hashedGivenAnswer = hash(trim(LCASE(form.secretAnswer)))>
		<cfset hashedActualAnswer = hash(trim(LCASE(q_getSecretAnswer.secretAnswer)))>
	</cfif>
	<cfif compareNoCase(hashedGivenAnswer,hashedActualAnswer) EQ 0>
		<cfset resetPassword = true>
	<cfelse>
		<cfset errorMessage = "Incorrect Answer">
	</cfif>
</cfif>
<cfif isdefined("form.username") AND len(trim(form.username)) AND resetPassword EQ false>
	<cfquery datasource="#application.datasource#" name="q_getUserInfo" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT email, username, secretQuestion
	FROM users
	WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(form.username)#" maxlength="500">
	</cfquery>
</cfif>

<cfoutput>
<div id="loginBox">
<cfif resetPassword>
	<div id="passwordForm">
		<form action="/admintools/login.cfm" method="post" name="reset">
			<input type="hidden" name="username" id="username" value="#form.username#" />
			New Password:&nbsp;&nbsp;<input type="password" name="newPassword" id="newPassword" size="15"/>
			<input name="submit" type="submit" value="Submit" class="submitbutton" style="margin-left:15px; margin-bottom:1px;">
		</form>	
	</div>
<cfelseif isdefined("form.username") AND isdefined("q_getUserInfo")>
	<div id="passwordForm">
		<form action="#request.page#" method="post" name="emailer">
			<input type="hidden" id="username" name="username" value="#form.username#" />
			<cfif isdefined("q_getUserInfo.secretQuestion") AND len(trim(q_getUserInfo.secretQuestion))>
				#q_getUserInfo.secretQuestion# <br /><br />
				<b>Answer:</b>&nbsp;&nbsp;<input type="text" id="secretAnswer" name="secretAnswer" size="40"/><br /><br />
				<input name="submit" type="submit" value="Submit" class="submitbutton" style="margin-left:150px;">	
				<cfif isdefined("errorMessage") AND len(trim(errorMessage))>
					<br /><font color="##FF0000">Incorrect Answer</font>
				</cfif>
			<cfelse>
				<font color="##FF0000">We're sorry we do not have a validation question on file for User: <b>#form.username#</b>. Please contact your CMS Administrator.</font><br /><br />
				<a href="/admintools/login.cfm">Return to login</a>
			</cfif>
		</form>
	</div>
<cfelse>
<div id="passwordForm">
	<form action="#request.page#" method="post" name="user">
		Enter Username:&nbsp;&nbsp;
		<input type="text" id="username" name="username" size="15">
		<input name="submit" type="submit" value="Submit" class="submitbutton" style="margin-left:15px; margin-bottom:1px;">
	</form>
</div>
</cfif>
</div>
</cfoutput>
	
