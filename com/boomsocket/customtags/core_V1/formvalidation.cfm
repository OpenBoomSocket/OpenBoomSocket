<cfparam name="request.isError" default="0">
<cfparam name="request.errorMsg" default="">
<cfif isDefined("formobjectid") AND len(trim(formobjectid))>
	<!--- get formobject for form id --->
	<cfquery datasource="#application.datasource#" name="q_getdatadef" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT datadefinition
		FROM formobject
		WHERE formobjectid=<cfqueryparam cfsqltype="cf_sql_integer" value="#formobjectid#">
	</cfquery>
	<!--- unwrap the datadef. xml and set it to a local array --->
	<cftry>
	<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
		input="#q_getdatadef.datadefinition#"
		output="a_formelements">	
	<cfcatch>Non XML object</cfcatch>
	</cftry>
	<!--- create label list --->
	<cfset fieldList="">
	<cfloop index="j" list="#attributes.validatelist#" delimiters=";">
		<cfset fieldList=listAppend(fieldList,listFirst(j))>
	</cfloop>	
	<cfloop from="1" to="#arrayLen(a_formelements)#" index="k">
		<cfif listFindNoCase(fieldList,structFind(a_formelements[k],"fieldname"))>
			<cfset "#Trim(a_formelements[k].fieldname)#label"=application.stripHTML(Trim(a_formelements[k].objectlabel))>
		</cfif>
		<cfif structFind(a_formelements[k],"required") EQ 1>
			<cfset "#Trim(a_formelements[k].fieldname)#req"=application.stripHTML(Trim(a_formelements[k].objectlabel))>
		</cfif>
	</cfloop>
</cfif>

<cfloop index="thisField" list="#attributes.validatelist#" delimiters=";">
	<cfparam name="#listFirst(thisField,',')&'label'#" default="#listFirst(thisField,",")#">
<!--- If there is a value in this field --->
	<cfif len(trim(evaluate("request.FORM#listFirst(thisField,',')#")))>
	<!--- Loop over list of errors -- write delimited (||) list of error messages --->
		<cfswitch expression="#listLast(thisField,",")#">
			<cfcase value="int">
				<cfif NOT isNumeric(evaluate("request.FORM#listFirst(thisField,',')#"))>
					<cfset request.isError=1>
					<cfset thisLabel=evaluate(listFirst(thisField,',')&"label")>
					<cfset request.errorMsg=request.errorMsg&"#thisLabel# must be an integer value.||">
				</cfif>
			</cfcase>
			<cfcase value="filename">
				<cfif NOT application.filename(evaluate("request.FORM#listFirst(thisField,',')#"))>
					<cfset request.isError=1>
					<cfset thisLabel=evaluate(listFirst(thisField,',')&"label")>
					<cfset request.errorMsg=request.errorMsg&"#thisLabel# is not valid because it contains special characters or spaces.||">
				</cfif>
			</cfcase>
			<cfcase value="email">
				<cfif NOT application.email(evaluate("request.FORM#listFirst(thisField,',')#"))>
					<cfset request.isError=1>
					<cfset thisLabel=evaluate(listFirst(thisField,',')&"label")>
					<cfset request.errorMsg=request.errorMsg&"#thisLabel# must be a valid e-mail address format.||">
				</cfif>
			</cfcase>
			<cfcase value="IsZipUS">
				<cfif NOT application.IsZipUS(evaluate("request.FORM#listFirst(thisField,',')#"))>
					<cfset request.isError=1>
					<cfset thisLabel=evaluate(listFirst(thisField,',')&"label")>
					<cfset request.errorMsg=request.errorMsg&"#thisLabel# must be a valid U.S. Zip Code.||">
				</cfif>
			</cfcase>
			<cfcase value="urlsafestring">
				<cfquery datasource="#application.datasource#" name="q_validateuniquevalue" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT #form.tablename#id
					FROM #form.tablename#
                    <!--- TODO: Need to figure out how to secure this code --->
					WHERE #listFirst(thisField,',')# ='#evaluate("request.FORM#listFirst(thisField,',')#")#'
					<cfif isDefined('instanceid')>
                    	AND #form.tablename#id != <cfqueryparam cfsqltype="cf_sql_integer" value="#instanceid#">
					</cfif>
				</cfquery>
				<cfif q_validateuniquevalue.recordcount>
					<cfset request.isError=1>
					<cfset thisLabel=evaluate(listFirst(thisField,',')&"label")>
					<cfset request.errorMsg=request.errorMsg&"#thisLabel# is not unique to this data table.||">
				</cfif>
				<cfif NOT application.filename(evaluate("request.FORM#listFirst(thisField,',')#"))>
					<cfset request.isError=1>
					<cfset thisLabel=evaluate(listFirst(thisField,',')&"label")>
					<cfset request.errorMsg=request.errorMsg&"#thisLabel# is not valid because it contains special characters or spaces.||">
				</cfif>
			</cfcase>
			<cfcase value="telephone">
				<cfif NOT application.phone(evaluate("request.FORM#listFirst(thisField,',')#"))>
					<cfset request.isError=1>
					<cfset thisLabel=evaluate(listFirst(thisField,',')&"label")>
					<cfset request.errorMsg=request.errorMsg&"#thisLabel# must be a valid phone number format (xxx-xxx-xxxx).||">
				</cfif>
			</cfcase>
			<cfcase value="date">
				<cfif NOT isDate(evaluate("request.FORM#listFirst(thisField,',')#"))>
					<cfset request.isError=1>
					<cfset thisLabel=evaluate(listFirst(thisField,',')&"label")>
					<cfset request.errorMsg=request.errorMsg&"#thislabel# must be a valid date.||">
				</cfif>
			</cfcase>
			<cfcase value="creditcard">
				<cfif NOT application.creditcard(evaluate("request.FORM#listFirst(thisField,',')#"))>
					<cfset request.isError=1>
					<cfset thisLabel=evaluate(listFirst(thisField,',')&"label")>
					<cfset request.errorMsg=request.errorMsg&"#thislabel# must be a valid credit card number.||">
				</cfif>
			</cfcase>
			<cfcase value="reservedword">
				<cfsavecontent variable="reservelist">
					<cfinclude template="reservedwords.txt">
				</cfsavecontent>
				<cfif listfindnocase(reservelist,evaluate("request.FORM#listFirst(thisField,',')#"),",")>
					<cfset request.isError=1>
					<cfset thisLabel=evaluate(listFirst(thisField,',')&"label")>
					<cfset request.errorMsg=request.errorMsg&"#thislabel# cannot be an SQL reserved word.||">
				</cfif>
			</cfcase>
			<cfcase value="vanityURL">
				<cfset isUnique = 1>
				<cfset thisValue = evaluate("request.FORM#listFirst(thisField,',')#")>
				<!--- Query Table to see if vanityURL was already used--->
				<cftry>
					<cfif IsDefined('REQUEST.q_getForm') AND REQUEST.q_getForm.UseWorkFlow>				
						<!--- get formobjectid we are dealing with --->
						<cfquery name="q_getFO" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT formobjectid
							FROM formobject
							WHERE datatable = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.tablename#">
						</cfquery>
						<!--- if editing, query for current instanceid and version.parentid --->
						<cfif isDefined('instanceid') AND isNumeric(instanceid)>
							<cfquery name="q_getInstanceInfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
								SELECT version.parentid
								FROM #form.tablename# 
									INNER JOIN version ON #form.tablename#.#form.tablename#id = version.instanceItemID
								WHERE #form.tablename#ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#instanceid#">
								AND (version.formobjectitemid = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_getFO.formobjectid#">)
							</cfquery>
						</cfif>						
						<!--- query for other versions with same formobject & sekeyname (even unpublished) --->
						<cfquery name="q_getVanityURL" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT #form.tablename#id, #listFirst(thisField,',')#, version.instanceitemid, version.parentid, version.label, version.version, version.formobjectitemid
							FROM #form.tablename# 
								INNER JOIN version ON #form.tablename#.#form.tablename#id = version.instanceItemID
							WHERE (version.archive IS NULL OR version.archive = 0) 
							AND (version.formobjectitemid = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_getFO.formobjectid#">)
		                    <!--- TODO: Need to figure out how to secure this code --->
                            AND #listFirst(thisField,',')# = '#thisValue#' 
							<cfif isDefined('instanceid') AND isNumeric(instanceid)>
								AND #form.tablename#ID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#instanceid#">
							</cfif>
						</cfquery>						
						<!--- if editing and records pull back do not share same version.parentid, they are not the same version so not unique --->
						<cfif isDefined('q_getInstanceInfo') AND q_getInstanceInfo.parentid neq q_getVanityURL.parentid>
							<cfloop query="q_getVanityURL">
								<cfset isUnique = 0>
							</cfloop>
						</cfif>						
						<!--- if adding, make sure not being added as a new version ---> 
						<cfif NOT isDefined('q_getInstanceInfo') AND form.formstep neq "createCopy">
							<cfif q_getVanityURL.recordcount>
								<cfset isUnique = 0>
							</cfif>
						</cfif>																
					<cfelse>
						<cfquery name="q_getVanityURL" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT #listFirst(thisField,',')#
							FROM #form.tablename#
							WHERE #listFirst(thisField,',')# = '#thisValue#'
							<!--- if editing, don't select the current one--->
							<cfif isDefined('instanceid') AND isNumeric(instanceid)>
								AND #form.tablename#ID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#instanceid#">
							</cfif>
						</cfquery>
						<cfif q_getVanityURL.recordcount>
							<cfset isUnique = 0>
						</cfif>
					</cfif>
					<cfcatch type="database">
						<cfrethrow>
					</cfcatch>
				</cftry>
				<cfif NOT isUnique>
					<cfset request.isError=1>
					<cfset thisLabel=evaluate(listFirst(thisField,',')&"label")>
					<cfset request.errorMsg=request.errorMsg&"This #thisLabel# is already being used.  Please use another value.||">
				</cfif>				
				<cfif reFindNoCase('[^abcdefghijklmnopqrstuvwxyz0123456789-]',thisValue)>
					<cfset request.isError=1>
					<cfset thisLabel=evaluate(listFirst(thisField,',')&"label")>
					<cfset request.errorMsg=request.errorMsg&"This #thisLabel# cannot contain any Special Characters, Punctuation or Spaces.<br> Please remove the Special Character or Punction and replace all spaces with a hypen '-' to continue.||">
				</cfif>
			</cfcase>
		</cfswitch>
	<cfelse>
	<!--- Catch required fields --->
		<cfif listLast(thisField,",") EQ "required">
			<cfif NOT isDefined("#listFirst(thisField)#req")>
				<cfset "#listFirst(thisField)#req"=listFirst(thisField,",")>
			</cfif>
			<cfparam name="label" default="#listFirst(thisField,",")#">
			<cfset request.isError=1>
			<cfset request.errorMsg=request.errorMsg&"#evaluate(listFirst(thisField,',')&'req')# is required.||">
		</cfif>
	</cfif>
</cfloop>
