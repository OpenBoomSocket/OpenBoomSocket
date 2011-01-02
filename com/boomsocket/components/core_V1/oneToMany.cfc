<cfcomponent>
	<cffunction name="init" access="public" returntype="string" output="false">
		<cfargument name="tablename" hint="The name of the many to many table. Ex: javascript_page" type="string" required="true">
		<cfargument name="instanceid" hint="The ID for the instance being modified." type="string" required="true">
		<cfargument name="keylist" hint="The formfield containing a list of IDs to be inserted." type="string" required="false" default="">
		<cfargument name="keytable" hint="The data table name the keylist is associatied with. Ex: page" type="string" required="false" default="">
		<cfargument name="keyfield" hint="The data field name (column) used to figure out which rows to delete" type="string" required="false" default="">

		<cfset var insertIntoTable = "">
		<cfset var message = "">
		<cfset var clearTheTable = "">
		
		<cfset variables.instance = StructNew()>
		<cfset variables.instance.tableName = arguments.tableName>
		<cfset variables.instance.instanceid = arguments.instanceid>
		<cfif IsDefined('arguments.keylist') AND Len(Trim(arguments.keylist))>
			<cfset variables.instance.keylist = arguments.keylist>
		</cfif>
		<cfif IsDefined('arguments.keytable') AND Len(Trim(arguments.keytable))>
			<cfset variables.instance.keytable = arguments.keytable>
		</cfif>
		<cfif IsDefined('arguments.keyfield') AND Len(Trim(arguments.keyfield))>
			<cfset variables.instance.keyfield = arguments.keyfield>
		<cfelse>
			<cfset variables.instance.keyfield = arguments.tableName&"ID">
		</cfif>
		
		<!--- If all of the arguments have been passed, proceed --->
		<cfset clearTheTable = clearTable()>
		<cfif clearTheTable EQ "true">
			<cfif IsDefined('variables.instance.keylist')>
				<cfset insertIntoTable = insertData()>
			</cfif>
		<cfelse>
			<cfset message = message & clearTheTable>
		</cfif>
		<cfif insertIntoTable EQ 'true'>
			<cfset message = "true">
		<cfelse>
			<cfset message = message & insertIntoTable>
		</cfif>
		<cfsavecontent variable="instancestuff">
			<cfoutput>
				<cfdump var="#variables.instance#">
			</cfoutput>
		</cfsavecontent>
		<cfreturn message & instancestuff>
	</cffunction>
	<cffunction name="clearTable" access="private" returntype="string" output="false">
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_clear" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE FROM #variables.instance.tablename#
				WHERE #variables.instance.keyfield# IN (#variables.instance.instanceid#)
			</cfquery>
			<cfreturn "true">
			<cfcatch type="database">
				<cfrethrow>				
			</cfcatch>
		</cftry>		
	</cffunction>
	<cffunction name="insertData" access="private" returntype="string" output="false">
		<cfset var thisSql ="">
		<cftry>
			<cfloop list="#variables.instance.keylist#" index="i">
				<cfset thisSql = thisSql & "INSERT INTO #variables.instance.tablename# (#variables.instance.tablename#id, #variables.instance.keytable#id) VALUES (#variables.instance.instanceid#,#listFirst(i,"~")#)<br>">
				<cfquery datasource="#application.datasource#" name="q_populate" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO #variables.instance.tablename# (#variables.instance.keyfield#, #variables.instance.keytable#id)
					VALUES (#variables.instance.instanceid#,#listFirst(i,"~")#)
				</cfquery>
			</cfloop>
			<cfreturn "true">
		<cfcatch>
			<cfrethrow>				
		</cfcatch>
		</cftry>
	</cffunction>
	<cffunction access="public" name="getLookupValues" output="false" returntype="string" displayname="Get Lookup Values" hint="Gets lookup values from a lookup table and populates a string which can be used in preshowforms">
		<cfargument name="tablename" hint="The name of the many to many table. Ex: javascript_page" type="string" required="true">
		<cfargument name="instanceid" hint="The ID for the instance being modified." type="string" required="true">
		<cfargument name="keytable" hint="The data table name the keylist is associatied with. Ex: page" type="string" required="true">
		<cfargument name="keyfield" hint="The data field name (column) used to figure out which rows to delete" type="string" required="true">
		<cfset var returnValueList = "">
		<cftry>
			<cfquery name="q_getlookupValues" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT #arguments.keytable#ID
				FROM #arguments.tablename#
				WHERE #arguments.keyfield# = #arguments.instanceid#
			</cfquery>
				<cfloop query="q_getlookupValues">
					<cfset thisColumn = evaluate("q_getlookupValues."&arguments.keytable&"ID")>
					<cfset returnValueList = returnValueList & "#thisColumn#,">
				</cfloop>
			<cfcatch type="database">
				<cfrethrow>				
			</cfcatch>
		</cftry>
		<cfreturn returnValueList>
	</cffunction>
</cfcomponent>