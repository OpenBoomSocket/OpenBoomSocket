<!--- ****************************************************** --->
<!--- Note the scriptProtect="all" parameter at the end of 
	  the CFAPPLICATION TAG. This prevents most XSS attacks  --->
<!--- ****************************************************** --->
<CFAPPLICATION NAME="gttCst" SESSIONMANAGEMENT="Yes" SESSIONTIMEOUT="#CreateTimeSpan(0,2,30,0)#" CLIENTMANAGEMENT="yes" SCRIPTPROTECT="all">

<!--- ****************************************************** --->
<!--- Stop processing if the current IP is in the blacklist.
	  IP automatically gets put in the blacklist when it 
	  attempts a SQL injection attack. It does not execute 
	  this code if the file that is being executed is called
	  ipBlackListUnlock.cfm (needed to remove IPs out of the 
	  blacklist [in case you lock yourself out]) --->
<!--- ****************************************************** --->
<CFIF ISDEFINED("APPLICATION.ipBlackList") AND CGI.PATH_INFO NEQ "/ipBlackListUnlock.cfm">
	<CFLOOP FROM="1" TO="#arrayLen(APPLICATION.ipBlackList)#" INDEX="currPosition">
		<CFIF APPLICATION.IPBLACKLIST[CURRPOSITION].ARRAYIP EQ CGI.REMOTE_ADDR>
			<CFABORT>
		</CFIF>
	</CFLOOP>
</CFIF>

<!--- ****************************************************** --->
<!--- Call CFC function to validate if there is any SQL 
	  Injection --->
<!--- ****************************************************** --->
<CFINVOKE COMPONENT="CFC.SQLInjection" METHOD="SQL_injection" RETURNVARIABLE="messageError" FORM="#FORM#" URL="#URL#" IPADDRESS="#CGI.REMOTE_ADDR#"/>

<!--- ****************************************************** --->
<!--- If the CFC returned an error message, place the hacker's 
	  IP Address in the blacklist, display the error message
	  and abort the processing of the page  --->
<!--- ****************************************************** --->
<CFIF ISDEFINED("messageError") AND MESSAGEERROR NEQ "">
	<!--- Create a new application array to allocate ip's where injection came from --->
	<CFPARAM NAME="APPLICATION.ipBlackList" TYPE="array" DEFAULT="#ArrayNew( 1 )#"/>
	<CFSET VARIABLES.COUNTER = INCREMENTVALUE(ARRAYLEN(APPLICATION.IPBLACKLIST))>
	<CFSET APPLICATION.IPBLACKLIST[VARIABLES.COUNTER] = STRUCTNEW()>
	<CFSET APPLICATION.IPBLACKLIST[VARIABLES.COUNTER].ARRAYIP = CGI.REMOTE_ADDR>
	<CFSET APPLICATION.IPBLACKLIST[VARIABLES.COUNTER].ARRAYTIME = NOW()>
	<!--- Display the error message --->
	<HTML>
	<HEAD>
		<TITLE>There was a problem with the page request.</TITLE>
	</HEAD>	
	<BODY>	
	<CFOUTPUT>#VARIABLES.messageError#</CFOUTPUT>
	</BODY>
	</HTML>
	<!--- Abort page processing --->
	<CFABORT>
</CFIF>

<!--- ****************************************************** --->
<!--- Your other application.cfm code should be included after 
	  this point --->
<!--- ****************************************************** --->