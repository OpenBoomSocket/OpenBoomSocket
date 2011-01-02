<cfcomponent output="false">

	<!---
		Portcullis is a CFC based url,form,cookie filter to help protect against 
		SQL Injection and XSS scripting atacks. This project has been inspired by  
		Shawn Gorrel's popular cf_xssblock tag (http://www.illumineti.com/documents/xssblock.txt).
		
		Author: John Mason, mason@fusionlink.com
		Blog: www.codfusion.com
		Public Version: 1.0.6
		Release Date: 4/23/2008
		Last Updated: 8/26/2008
		
		WARNING: URL, SQL Injection and XSS attacks are an ever evolving threats. Though this 
		CFC will filter many types of attacks. There are no warranties, expressed or implied, 
		with using this filter. It is YOUR responsibility to monitor/modify/update/alter this code 
		to properly protect your application now and in the future. It is also highly encourage to 
		implement a hardware Web Application Firewall (WAF) to obtain the best protection. In fact, 
		PCI-DSS requires WAF when handling credit card information.

		1.0.2 (4/23/2008) - First public release
		1.0.3 (5/10/2008) - Added CRLF defense, HttpOnly for cookies, remove individual IPs from the log and a new escapeChars function that replaces htmlEditFormat()
		1.0.4 (6/19/2008) - Fixed item naming with a regex scan to allow just alphanumeric and underscore characters
		1.0.5 (7/21/2008) - Added some key words to block the popular CAST()/ASCII injection attack. Also, fixed a bug reported if ampersands are in the url string it sometimes mixes up the variable naming
		1.0.6 (8/26/2008) - Exception field corrections, fixed a couple missing var scopes, querynew bug in CF6, bug fix for checkReferer
	--->
	 
	<!---Some basic settings--->
	<cfset variables.instance.log = true/>	
	<cfset variables.instance.ipBlock = true/>										<!---Requires variables.instance.log set to true--->
	<cfset variables.instance.allowedAttempts = 10/>
	<cfset variables.instance.blockTime = 86400/> 									<!--- In Seconds, 86400 seconds equals 1 day--->
	<cfset variables.instance.keepInnerText = false/> 								<!---Keep any text within a blocked tag--->
	<cfset variables.instance.invalidMarker = "[INVALID]"/>							<!---Strongly encouraged to replace stripped items with some type of marker, otherwise the attacker can rebuild a bad string from the stripping---> 								
	<cfset variables.instance.escapeChars = true/>									<!---So HtmlEditFormat and XMLFormat does not catch everything - we have a better method here--->
	<cfset variables.instance.checkReferer = true/> 								<!---For form variables only--->
	<cfset variables.instance.safeReferers = ""> 									<!---Comma delimited list of sites that can send submit form variables to this site--->
	<cfset variables.instance.exceptionFields = "">								 	<!---Comma delimited list of fields not to scan--->
	<cfset variables.instance.allowJSAccessCookies = false/>						<!---Turn off Javascript access to cookies with the HttpOnly attribute - supported by only some browsers--->					<cfset variables.instance.blockCRLF = true/>									<!---Block CRLF (carriage return line feed) hacks, this particular hack has limited abilities so this could be overkill--->
	
	<cfset variables.instance.sqlFilter = "select,insert,update,delete,drop,--,alter,xp_,information_schema,execute,table_cursor,cast\(,exec\(,declare">
	<cfset variables.instance.tagFilter = "script,object,applet,embed,form,input,layer,ilayer,frame,iframe,frameset,param,meta">
	<cfset variables.instance.wordFilter = "onLoad,onClick,onDblClick,onKeyDown,onKeyPress,onKeyUp,onMouseDown,onMouseOut,onMouseUp,onMouseOver,onBlur,onChange,onFocus,onSelect,javascript:">
	<cfset variables.instance.thisServer = lcase(CGI.SERVER_NAME)/>
	<cfif structkeyexists(variables.instance,"iplog") eq false>
		<cfif left(server.coldfusion.productversion,1) eq 6>
			<cfset variables.instance.iplog = QueryNew("IP, Attempts, Blocked, DateBlocked, VarChar, Integer, Bit, Date")/>
		<cfelse>
			<cfset variables.instance.iplog = QueryNew("IP, Attempts, Blocked, DateBlocked", "VarChar, Integer, Bit, Date")/>
		</cfif>
	</cfif>	
	
	<cffunction name="init" output="false" access="public" returntype="Portcullis">
		<cfreturn this/>
	</cffunction>

	<cffunction name="scan" output="false" access="public" returntype="Void">
		<cfargument name="object" required="true" type="Struct"/>
		<cfargument name="objectname" required="true" type="String"/>
		<cfargument name="ipAddress" required="true" type="String"/>
		<cfargument name="exceptionFields" required="false" type="String"/> 		<!---Comma delimited list of fields not to scan--->
		<cfset var object2 = StructNew()/>
		<cfset var result = StructNew()/>
		<cfset var item= ""/>
		<cfset var itemname= ""/>
		<cfset var exFF= variables.instance.exceptionFields/>
		<cfset var detected= 0/>
		<cfset var temp= StructNew()/>
		<cfset var newitem = ""/>
		<cfset var contents = ""/>
				
		<!---Clean up Ampersands that may mess up variable naming later on--->
		<cfloop collection="#object#" item="item">
			<cfset newitem = replaceNoCase(item,"&amp;","","ALL")/>
			<cfset newitem = replaceNoCase(newitem,"amp;","","ALL")/>
			<cfset contents = "#object[item]#"/>
			<cfset structdelete(object,item,false)/>
			<cfset StructInsert(object,"#newitem#",contents,true)/>
		</cfloop>
		
		<cfif structkeyexists(arguments,"exceptionFields") and len(arguments.exceptionFields)>
			<cfset exFF = exFF & "," & arguments.exceptionFields/>
		</cfif>
		
		<!---Filter Tags--->
		<cfloop collection="#object#" item="item">
			<cfif ListContainsNoCase(exFF,item,',') eq false>
				<cfset temp = filterTags(object[item])/>
				<cfset itemname = REReplaceNoCase(item,"[^a-zA-Z0-9_]","","All")>
				<cfif temp.detected eq true><cfset detected = detected + 1/></cfif>
				<cfif objectname eq "cookie" and variables.instance.allowJSAccessCookies eq false>
					<cfheader name="Set-Cookie" value="#itemname#=#temp.cleanText#;HttpOnly">
				<cfelse>
					<cfset "#objectname#.#itemname#" = temp.cleanText/>
				</cfif>
			</cfif>
		</cfloop>

		<!---Filter Words--->
		<cfloop collection="#object#" item="item">
			<cfif ListContainsNoCase(exFF,item,',') eq false>
				<cfset temp = filterWords(object[item])/>
				<cfset itemname = REReplaceNoCase(item,"[^a-zA-Z0-9_]","","All")>
				<cfif temp.detected eq true><cfset detected = detected + 1/></cfif>
				<cfif objectname eq "cookie" and variables.instance.allowJSAccessCookies eq false>
					<cfheader name="Set-Cookie" value="#itemname#=#temp.cleanText#;HttpOnly">
				<cfelse>
					<cfset "#objectname#.#itemname#" = temp.cleanText/>
				</cfif>
			</cfif>
		</cfloop>

		<!---Filter CRLF--->
		<cfif variables.instance.blockCRLF eq true>
		<cfloop collection="#object#" item="item">
			<cfif ListContainsNoCase(exFF,item,',') eq false>
				<cfset temp = filterCRLF(object[item])/>
				<cfset itemname = REReplaceNoCase(item,"[^a-zA-Z0-9_]","","All")>
				<!---<cfif temp.detected eq true><cfset detected = detected + 1/></cfif>  // We're not going to take note of CRLFs since it's very likely benign--->
				<cfif objectname eq "cookie" and variables.instance.allowJSAccessCookies eq false>
					<cfheader name="Set-Cookie" value="#itemname#=#temp.cleanText#;HttpOnly">
				<cfelse>
					<cfset "#objectname#.#itemname#" = temp.cleanText/>
				</cfif>
			</cfif>
		</cfloop>
		</cfif>

		<!---Filter SQL--->
		<cfloop collection="#object#" item="item">
			<cfif ListContainsNoCase(exFF,item,',') eq false>
				<cfset temp = filterSQL(object[item])/>
				<cfset itemname = REReplaceNoCase(item,"[^a-zA-Z0-9_]","","All")>
				<cfif temp.detected eq true><cfset detected = detected + 1/></cfif>
				<cfif objectname eq "cookie" and variables.instance.allowJSAccessCookies eq false>
					<cfheader name="Set-Cookie" value="#itemname#=#temp.cleanText#;HttpOnly">
				<cfelse>
					<cfset "#objectname#.#itemname#" = temp.cleanText/>
				</cfif>
			</cfif>
		</cfloop>

		<!---Escape Special Characters--->
		<cfif variables.instance.escapeChars eq true>
			<cfloop collection="#object#" item="item">
			<cfif ListContainsNoCase(exFF,item,',') eq false>
				<cfif isNumeric(object[item]) eq false>
					<cfset itemname = REReplaceNoCase(item,"[^a-zA-Z0-9_]","","All")>
					<cfset temp = escapeChars(object[item])/>
					<cfset "#objectname#.#itemname#" = temp/>
				</cfif>
			</cfif>
			</cfloop>
		</cfif>
		
		<cfif variables.instance.log eq true and detected gt 0>
			<cfset setLog(arguments.ipAddress)/>
			<cfset cleanLog()/>
		</cfif>

	</cffunction>

	<cffunction name="setlog" output="false" access="public" returntype="Void">
		<cfargument name="ipAddress" required="true" type="String">
		<cfif isLogged(cgi.REMOTE_ADDR) eq 1>
			<cfset updateLog(arguments.ipAddress)/>
			<cfelse>
			<cfset insertLog(arguments.ipAddress)/>
		</cfif>

	</cffunction>

	<cffunction name="getLog" output="false" access="public" returntype="Any">
		<cfreturn variables.instance.iplog/>
	</cffunction>

	<cffunction name="isLogged" output="false" access="public" returntype="Any">
		<cfargument name="ipAddress" required="true" type="String">
		<cfset var find = ""/>
		
		<cfquery dbtype="query" name="find">
		select IP from variables.instance.iplog
		where IP = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="20" value="#arguments.ipAddress#">
		</cfquery>
		
		<cfreturn YesNoFormat(find.recordcount)/>
	</cffunction>

	<cffunction name="isBlocked" output="false" access="public" returntype="Any">
		<cfargument name="ipAddress" required="true" type="String">
		<cfset var blocked = false/>
		<cfset var find = ""/>
		
		<cfif structkeyexists(form,"fieldnames") and variables.instance.checkReferer eq true and isSafeReferer() eq false>
			<cfset blocked = true/>
 		<cfelse>
			<cfquery dbtype="query" name="find">
			SELECT blocked 
			FROM variables.instance.iplog
			WHERE IP = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="20" value="#arguments.ipAddress#">
			</cfquery>
			<cfif find.blocked eq 1>
				<cfset blocked = true/>
			</cfif>
		</cfif>

		<cfreturn blocked/>
	</cffunction>

	<cffunction name="cleanLog" output="false" access="public" returntype="Any">
		<cfset var cutoff = 0 - variables.instance.blockTime/>
		
		<cfquery dbtype="query" name="variables.instance.iplog">
		SELECT IP, Attempts, Blocked, DateBlocked
		FROM variables.instance.iplog
		WHERE DateBlocked > <cfqueryparam cfsqltype="cf_sql_datetime" maxlength="50" value="#dateadd("s",cutoff,now())#">
		</cfquery>

		<cfreturn true/>
	</cffunction>

	<cffunction name="updateLog" output="false" access="public" returntype="Any">
		<cfargument name="ipAddress" required="true" type="String">
		<cfset var attempts = 0/>
		<cfset var find = ""/>
		
		<cfquery dbtype="query" name="find">
		SELECT attempts 
		FROM variables.instance.iplog
		WHERE IP = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="20" value="#arguments.ipAddress#">
		</cfquery>
		<cfset attempts = find.attempts + 1/>
		
		<cfquery dbtype="query" name="variables.instance.iplog">
		<cfif variables.instance.ipBlock eq true and variables.instance.allowedAttempts lte attempts>
		SELECT IP, #attempts# AS Attempts, 1 AS Blocked, #now()# as DateBlocked
		<cfelse>
		SELECT IP, #attempts# AS Attempts, Blocked, #now()# as DateBlocked
		</cfif> 
		FROM variables.instance.iplog
		WHERE IP = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="20" value="#arguments.ipAddress#">
		UNION
		SELECT IP, Attempts, Blocked, DateBlocked 
		FROM variables.instance.iplog
		WHERE NOT IP = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="20" value="#arguments.ipAddress#">
		</cfquery>
		
		<cfreturn true/>
	</cffunction>

	<cffunction name="removeIPfromLog" output="false" access="public" returntype="Any">
		<cfargument name="ipAddress" required="true" type="String">
		
		<cfquery dbtype="query" name="variables.instance.iplog">
		SELECT *
		FROM variables.instance.iplog
		WHERE IP <> <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="20" value="#arguments.ipAddress#">
		</cfquery>
		
		<cfreturn true/>
	</cffunction>

	<cffunction name="insertLog" output="false" access="public" returntype="Any">
		<cfargument name="ipAddress" required="true" type="String">

		<cfset QueryAddRow(variables.instance.iplog, 1)>
		<cfset QuerySetCell(variables.instance.iplog, "IP", "#arguments.ipAddress#")/> 
		<cfset QuerySetCell(variables.instance.iplog, "Attempts", 1)/> 
		<cfset QuerySetCell(variables.instance.iplog, "Blocked", 0)/> 
		<cfset QuerySetCell(variables.instance.iplog, "DateBlocked", now())/> 

		<cfreturn true/>
	</cffunction>

	<cffunction name="filterTags" output="false" access="public" returntype="Any">
		<cfargument name="text" required="true" type="String">
		<cfset var result = StructNew()/>
		<cfset var tag = ""/>
		<cfset var tcount = 0/>
		<cfset var lcount = 0/>
		<cfset result.originalText = trim(REReplace(arguments.text,"(’|‘)", "'", "ALL"))/>	<!---trim white space and deal with "smart quotes" from MS Word, etc.--->
		<cfset result.detected = true/>
		<cfset result.cleanText = result.originalText/>
		
		<cfloop index="tag" list="#variables.instance.tagFilter#">
			<cfif REFindNoCase(("<#tag#.*?>|<#tag#.*?/>"),result.cleanText) eq 0>
				<cfset tcount = tcount + 1/>
			<cfelse>
				<cfif variables.instance.keepInnerText eq true>
					<cfset result.cleanText = ReReplaceNoCase(result.cleanText, "<#tag#.*?>(.*?)</#tag#>", "\1", "All")>
					<cfset result.cleanText = ReReplaceNoCase(result.cleanText, "<#tag#.*?>|<#tag#.*?/>", variables.instance.invalidMarker, "All")>
				<cfelse>
					<cfset result.cleanText = ReReplaceNoCase(result.cleanText, "<#tag#.*?>.*?</#tag#>|<#tag#.*?/>", variables.instance.invalidMarker, "All")>
				</cfif>
			</cfif>
			<cfset lcount = lcount + 1/>
		</cfloop>

		<cfif tcount eq lcount>
			<cfset result.detected = false/>
		</cfif>
			
		<cfreturn result/>
	</cffunction>

	<cffunction name="filterWords" output="false" access="public" returntype="Any">
		<cfargument name="text" required="true" type="String">
		<cfset var result = StructNew()/>
		<cfset result.detected = true/>
		<cfset result.originalText = trim(REReplace(arguments.text,"(’|‘)", "'", "ALL"))/>	<!---trim white space and deal with "smart quotes" from MS Word, etc.--->

		<cfif REFindNoCase((ListChangeDelims(variables.instance.wordFilter,"|")),arguments.text) eq 0>
			<cfset result.detected = false/>
			<cfset result.cleanText = result.originalText/>
		<cfelse>
			<cfset result.cleanText = REReplaceNoCase(result.originalText,(ListChangeDelims(variables.instance.wordFilter,"|")),variables.instance.invalidMarker,"ALL")>
		</cfif>

		<cfreturn result/>
	</cffunction>

	<cffunction name="filterSQL" output="false" access="public" returntype="Any">
		<cfargument name="text" required="true" type="String">
		<cfset var result = StructNew()/>
		<cfset result.detected = true/>
		<cfset result.originalText = arguments.text/>
		
		<cfif REFindNoCase((ListChangeDelims(variables.instance.sqlFilter,"|")),arguments.text) eq 0>
			<cfset result.detected = false/>
			<cfset result.cleanText = result.originalText/>
		<cfelse>
			<cfset result.cleanText = REReplaceNoCase(text,(ListChangeDelims(variables.instance.sqlFilter,"|")),variables.instance.invalidMarker,"ALL")>
		</cfif>
		<cfreturn result/>
	</cffunction>

	<cffunction name="filterCRLF" output="false" access="public" returntype="Any">
		<cfargument name="text" required="true" type="String">
		<cfset var result = StructNew()/>
		<cfset result.detected = true/>
		<cfset result.originalText = arguments.text/>
		
		<cfif REFindNoCase(chr(13),arguments.text) eq 0 and REFindNoCase(chr(10),arguments.text) eq 0>
			<cfset result.detected = false/>
			<cfset result.cleanText = result.originalText/>
		<cfelse>
			<cfset result.cleanText = REReplaceNoCase(arguments.text,chr(13),"","ALL")>
			<cfset result.cleanText = REReplaceNoCase(result.cleanText,chr(10)," ","ALL")>
		</cfif>
		<cfreturn result/>
	</cffunction>

	<cffunction name="escapeChars" output="false" access="public" returntype="Any">
		<cfargument name="text" required="true" type="String">
		<cfset var result = arguments.text/>

		<cfset result = ReplaceNoCase(result,";","[semicolon]","ALL")>
		<cfset result = ReplaceNoCase(result,"##","&##35;","ALL")>
		<cfset result = ReplaceNoCase(result,"(","&##40;","ALL")>
		<cfset result = ReplaceNoCase(result,")","&##41;","ALL")>
		<cfset result = ReplaceNoCase(result,"<","&lt;","ALL")>
		<cfset result = ReplaceNoCase(result,">","&gt;","ALL")>
		<cfset result = ReplaceNoCase(result,"'","&##39;","ALL")>
		<cfset result = ReplaceNoCase(result,"""","&quot;","ALL")>
		<cfset result = ReplaceNoCase(result,"[semicolon]","&##59;","ALL")>

		<cfreturn result/>
	</cffunction>

	<cffunction name="isSafeReferer" output="false" access="public" returntype="Any">
		<cfset var thisserver = lcase(CGI.SERVER_NAME)/>
		<cfset var thisreferer = "none"/>
		<cfset var isSafe = false/> <!---We assume false until it's verified--->
		
		<cfif structkeyexists(cgi,"HTTP_REFERER") and len(cgi.HTTP_REFERER)>
			<cfset thisreferer = replace(lcase(CGI.HTTP_REFERER),'http://','','all')/>
			<cfset thisreferer = replace(thisreferer,'https://','','all')/>
			<cfset thisreferer = listgetat(thisreferer,1,'/')/>
		<cfelse>	
			<cfset thisreferer = "none"/>
		</cfif>	

		<cfif thisreferer eq "none" or thisreferer eq thisserver>
			<cfset isSafe = true/>
		<cfelse>
			<cfif ListContainsNoCase(variables.instance.safeReferers,thisreferer,',')>
				<cfset isSafe = true/>
			</cfif>		
		</cfif>	

		<cfreturn isSafe/>
	</cffunction>
	
</cfcomponent>