<CFCOMPONENT DISPLAYNAME="SQL injection CFC" HINT="This is the CFC for the SQL Injection problem">
	<CFFUNCTION NAME="SQL_injection" HINT="sendEmails" RETURNTYPE="string" ACCESS="remote">
		<CFARGUMENT NAME="FORM" TYPE="any">
		<CFARGUMENT NAME="URL" TYPE="any">
		<CFARGUMENT NAME="ipAddress" TYPE="string">
		<!--- initialize variables --->
		<CFSET VARIABLES.messageError = "">
		<CFSET VARIABLES.errorFound="0">
		<CFSET VARIABLES.insSql = "insert|delete|select|update|create|alter|drop|truncate|grant|revoke|declare|exec|backup|restore|sp_|xp_|set|execute|dbcc|deny|union|Cast|Char|Varchar|nChar|nVarchar">
		<CFSET VARIABLES.regEx="((or)+[[:space:]]*\(*'?[[:print:]]+'?([[:space:]]*[\+\-\/\*][[:space:]]*'?[[:print:]]+'?)*\)*[[:space:]]*(([=><!]{1,2}|(like))[[:space:]]*\(*'?[[:print:]]+'?([[:space:]]*[\+\-\/\*][[:space:]]*'?[[:print:]]+'?)*\)*)|((in)[[:space:]]*\(+[[:space:]]*'?[[:print:]]+'?(\,[[:space:]]*'?[[:print:]]+'?)*\)+)|((between)[[:space:]]*\(*[[:space:]]*'?[[:print:]]+'?(\,[[:space:]]*'?[[:print:]]+'?)*\)*(and)[[:space:]]+\(*[[:space:]]*'?[[:print:]]+'?(\,[[:space:]]*'?[[:print:]]+'?)*\)*)|((;)([^a-z>]*)(#VARIABLES.insSql#)([^a-z]+|$))|(union[^a-z]+(all|select))|(\/\*)|(--$))">
		
		<!--- Loop through all existing FORM fields --->
		<CFLOOP COLLECTION=#FORM# ITEM="FORMParameter">
			<!--- Detect a SQL with the Regular expression --->
			<CFIF FORMParameter NEQ "FIELDNAMES" AND ReFindNoCase(VARIABLES.regEx, FORM[FORMParameter]) NEQ "0">
				<CFSET VARIABLES.errorFound="1">
				<CFSET VARIABLES.offendingString="#FORMParameter#: #FORM[FORMParameter]#">
				<CFBREAK>
			</CFIF>
		</CFLOOP>
		
		<!--- If there was not an SQL injection attemp in the FORM fields, look at the URL --->
		<CFIF VARIABLES.errorFound IS "0">
			<!--- Loop through all existing URL parameters --->
			<CFLOOP COLLECTION=#URL# ITEM="URLParameter">
				<!--- If there was a SQL injection --->
				<CFIF ReFindNoCase(VARIABLES.regEx, URL[URLParameter]) NEQ "0">
					<CFSET VARIABLES.errorFound="1">
					<CFSET VARIABLES.offendingString="#URLParameter#: #URL[URLParameter]#; QUERY_STRING: #CGI.QUERY_STRING#">
					<CFBREAK>
				</CFIF>
			</CFLOOP>
		</CFIF>
		
		<CFIF VARIABLES.errorFound IS "1">
			<!--- Get isp, and other information for the SQL injector --->
			<CFHTTP METHOD="POST" URL="http://ws.arin.net/whois/">
				<CFHTTPPARAM TYPE="URL" NAME="queryinput" VALUE="#ipAddress#">
			</CFHTTP>
			
			<!--- Get ISP's abuse email address --->
			<CFSET VARIABLES.abuseStartPos=(len(CFHTTP.filecontent) - (find('OrgAbuseEmail:', CFHTTP.filecontent) + 15))>
			<CFSET VARIABLES.tempString = right(CFHTTP.filecontent, VARIABLES.abuseStartPos)>
			<CFSET VARIABLES.abuseEndPos=find('OrgTechHandle:', VARIABLES.tempString)>
			<CFIF VARIABLES.abuseEndPos GT "2">
				<CFSET VARIABLES.abuseEmailString = left(VARIABLES.tempString, VARIABLES.abuseEndPos - 2)>
			<CFELSE>
				<CFSET VARIABLES.abuseEmailString = "">
			</CFIF>
			
			<!--- Get ISP's Name --->
			<CFSET VARIABLES.orgStartPos=(len(CFHTTP.filecontent) - (find('OrgName:', CFHTTP.filecontent) + 9))>
			<CFSET VARIABLES.tempString = right(CFHTTP.filecontent, VARIABLES.orgStartPos)>
			<CFSET VARIABLES.orgEndPos=find('OrgID:', VARIABLES.tempString)>
			<CFIF VARIABLES.orgEndPos GT "2">
				<CFSET VARIABLES.orgString = left(VARIABLES.tempString, VARIABLES.orgEndPos - 2)>
			<CFELSE>
				<CFSET VARIABLES.orgString = "">
			</CFIF>
			
			<!--- Get ISP's City --->
			<CFSET VARIABLES.cityStartPos=(len(CFHTTP.filecontent) - (find('City:', CFHTTP.filecontent) + 6))>
			<CFSET VARIABLES.tempString = right(CFHTTP.filecontent, VARIABLES.cityStartPos)>
			<CFSET VARIABLES.cityEndPos=find('StateProv:', VARIABLES.tempString)>
			<CFIF VARIABLES.cityEndPos GT "2">
				<CFSET VARIABLES.cityString = left(VARIABLES.tempString, VARIABLES.cityEndPos - 2)>
			<CFELSE>
				<CFSET VARIABLES.cityString = "">
			</CFIF>
			
			<!--- Get ISP's State --->
			<CFSET VARIABLES.stateStartPos=(len(CFHTTP.filecontent) - (find('StateProv:', CFHTTP.filecontent) + 11))>
			<CFSET VARIABLES.tempString = right(CFHTTP.filecontent, VARIABLES.stateStartPos)>
			<CFSET VARIABLES.stateEndPos=find('PostalCode:', VARIABLES.tempString)>
			<CFIF VARIABLES.stateEndPos GT "2">
				<CFSET VARIABLES.stateString = left(VARIABLES.tempString, VARIABLES.stateEndPos - 2)>
			<CFELSE>
				<CFSET VARIABLES.stateString = "">
			</CFIF>
			
			<!--- Produce error message --->
			<!--- <CFSET VARIABLES.messageError = "Your actions violate the Federal computer crime law (18 U.S.C. 1030, Computer Fraud and Abuse Act). The entire text of the Act can be viewed at: http://www.usdoj.gov/criminal/cybercrime/1030_new.html. Your IP address (#ipAddress#) and actions have also been reported to your ISP (#VARIABLES.orgString#"> --->
			<CFSET VARIABLES.messageError = "Your actions have been identified as possible spam. As a result, the data you have attempted to upload has been rejected. <br>
<br>
If you feel this message has been reached in error and the data you submited is in fact valid, please contact us at: support [at] d [dash] p [dot] com.">
			<CFIF VARIABLES.cityString NEQ "">
				<CFSET VARIABLES.messageError = "#VARIABLES.messageError#, #VARIABLES.cityString#">
			</CFIF>
			<CFIF VARIABLES.stateString NEQ "">
				<CFSET VARIABLES.messageError = "#VARIABLES.messageError#, #VARIABLES.stateString#">
			</CFIF>
			<CFSET VARIABLES.messageError = "#VARIABLES.messageError#) with a request for service interruption.">
			<CFSET VARIABLES.injectionId=ListLast(createUUID(), "-")>
			
			<!--- If the ISP has an abuse email address, send an email reporting hacking
				  Remember to fill in your email address in the CFMAIL form and in the 
				  message body 
			<CFIF VARIABLES.abuseEmailString NEQ "" AND ReFind("[_a-zA-Z0-9-]+(\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.(([0-9]{1,3})|([a-zA-Z]{2,3})|(aero|coop|info|museum|name))", VARIABLES.abuseEmailString) NEQ "0">
				<CFMAIL FROM="#APPLICATION.adminEmail#" TO="#VARIABLES.abuseEmailString#" SUBJECT="SQL Injection Details - #VARIABLES.injectionId#" TYPE="HTML">
					<HTML>
					<BODY>
					We would like to report that an individual using the IP #ipAddress# has been trying to do SQL injections into the following web site: #CGI.server_name#.<P>
					The last attempted injection was at #DateFormat(NOW(), "mm/dd/yyyy")# #TimeFormat(NOW(), "h:mm tt")#.<P>
					Please take immediate action to prevent this user from accessing our and other Web sites.<P>
					If you require more information please contact:
					
					<p>
					#APPLICATION.adminEmail#<br>
					</p>
					</BODY>
					</HTML>
				</CFMAIL>
			</CFIF>
			--->
			
			<!--- Send yourself an email with error details. Remember to fill in the 
				  TO and FROM parameters in the CFMAIL tag
			<CFMAIL FROM="#APPLICATION.adminEmail#" TO="#APPLICATION.adminEmail#" SUBJECT="SQL Injection Details - #VARIABLES.injectionId#" TYPE="HTML">
				<HTML>
				<BODY>					
				<STRONG>Date: </STRONG>#DateFormat(NOW(), "mm/dd/yyyy")# #TimeFormat(NOW(), "h:mm tt")#<BR><BR>
				<STRONG>Referring Page: </STRONG>http://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#<BR><BR>
				<STRONG>IP: </STRONG>#ipAddress#<BR><BR>
				<STRONG>Offending String: </STRONG>#VARIABLES.offendingString#
				</BODY>
				</HTML>
			</CFMAIL> --->
            <cfsavecontent variable="logOutput">
            	<cfoutput>
					Referring Page: http://#CGI.SERVER_NAME##CGI.SCRIPT_NAME##chr(10)#
                    IP Address: #ipAddress# #chr(10)#
                    Offending String: #left(VARIABLES.offendingString,200)##chr(10)#
                    *****************************************************************#chr(10)#
				</cfoutput>
            </cfsavecontent>
            <cflog text="#logOutput#" type="Warning" file="sql_injection" application="yes">
		</CFIF>
		
		<CFRETURN VARIABLES.messageError>
	</CFFUNCTION>
</CFCOMPONENT>