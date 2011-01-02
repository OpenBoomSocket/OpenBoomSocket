<!--- 
Author: Ben Wakeman
Date: Oct. 17, 2002
Purpose: This tag is designed to handle simple INSERT UPDATE and DELETE actions
in a SQL Server database, taking in either URL or FORM scope variables that match 
column names in the target db table. 

ATTRIBUTES:
action: INSERT,UPDATE or DELETE ---required
datasource: name of datasource ---required
tablename: name of database table ---required
primarykeyfield: name of form field containing primary key ---required on UPDATE and DELETE
				 actions when 'whereclause' attribute is not specified
whereclause: SQL statement used if 'primarykeyfield' is not specified ---required on UPDATE and DELETE
			 action when 'primarykeyfield is not provided
assignIDfield: Required if target table does not have an "identity" seed field.

RETURNS:
insertID
EXAMPLES:
<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE"
			 datasource="#application.datasource#"
			 tablename="customer"
			 whereclause="lastname LIKE 'W%'">
<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
			 datasource="#application.datasource#"
			 tablename="customer"
			 assignIDfield="customerid">	
<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE"
			 datasource="#application.datasource#"
			 tablename="customer"
			 primarykeyfield="customerid">	
			 
MODIFICATIONS HISTORY:
	 7/23/2008 - BDW Re-wrote the INSERT case, adding in CFQUERYPARAM tags to prevent SQL Injections
 --->
<cfparam name="APPLICATION.dbUserName" default="">
<cfparam name="APPLICATION.dbpassword" default="">
 
<cfif thistag.executionmode is "START">
<cfif not isDefined("attributes.datasource") OR attributes.datasource eq "">
	<h3>ERROR: You must supply a data source name to call this tag.</h3>
	<cfexit method="EXITTAG">
</cfif>
<cfif not isDefined("attributes.tablename") OR attributes.tablename eq "">
	<h3>ERROR: You must supply a table name to call this tag.</h3>
	<cfexit method="EXITTAG">
</cfif>
<cfif not isDefined("attributes.action") OR attributes.tablename eq "">
	<h3>ERROR: You must supply an action for this tag such as: UPDATE, INSERT or DELETE.</h3>
	<cfexit method="EXITTAG">
</cfif>
<!--- Query for column list and datatypes --->
<cfquery datasource="#attributes.datasource#" name="q_getdefinition" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
     exec sp_columns @table_name = '#attributes.tablename#'
</cfquery>

<!--- SET incoming vars to local --->
<cfloop query="q_getdefinition">
	<cfif structKeyExists(URL,q_getdefinition.column_name)>
		<cfset "#q_getdefinition.column_name#" = URL['#q_getdefinition.column_name#']>
	</cfif>
	<cfif structKeyExists(FORM,q_getdefinition.column_name)>
		<cfset "#q_getdefinition.column_name#" = trim(FORM['#q_getdefinition.column_name#'])>
	</cfif>
</cfloop>

<cfparam name="attributes.primarykeyfield" default="">
<cfparam name="attributes.assignIDfield" default="">


<cfswitch expression="#attributes.action#">
	<cfcase value="INSERT">
		<cfset columns="">
        <!--- Loop over all columns defined in this table --->
		<cfloop query="q_getdefinition">
			<!--- SET INSERT LIST --->
				<cfif NOT findnocase('identity',q_getdefinition.type_name,1) AND q_getdefinition.column_name NEQ attributes.assignIDfield>
					<cfparam name="#q_getdefinition.column_name#" default="">
     
					<cfif len(trim(evaluate(q_getdefinition.column_name))) GT 0>
						<cfset columns = listAppend(columns, q_getdefinition.column_name)>
					</cfif>
				</cfif>
		</cfloop>
        
		<!--- If this is not an autonumber PK, then append PK field to insert list --->
		<cfif len(attributes.assignIDfield)>
            <!--- Call custom tag in increment id and get new one --->
            <cfmodule template="#application.customTagPath#/assignID.cfm" 
                      tablename="#attributes.tablename#" 
                      datasource="#attributes.datasource#">
            <cfset pkValue = newID>
        </cfif>

		<!--- DO DATABASE INSERT--->
        <cftry>
            <cftransaction>
                <cfquery datasource="#attributes.datasource#" name="q_insertdata" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
                    INSERT INTO #attributes.tablename# ( 
                    <cfif isDefined("pkValue")>
                        #ATTRIBUTES.assignIDfield#, 
                    </cfif>
                    #columns# 
                    )
                    VALUES (
                        <cfif isDefined("pkValue")>
                            #pkValue#
                        </cfif>
                        <cfloop query="q_getdefinition">
                            <cfif listFindNoCase(columns, q_getdefinition.column_name, ',')>
                                <!--- Clean up content pasted from MS Word --->
                                <cfif findnocase('urn:schemas-microsoft',evaluate(q_getdefinition.column_name),1) OR findnocase('class=MsoNormal',evaluate(q_getdefinition.column_name),1)>
                                    <cfmodule 	template="#application.customTagPath#/cleanmstext.cfm" 
                                                mstext="#q_getdefinition.column_name#" 
                                                replacequotes="true" 
                                                quotestype="text">
                                </cfif>
                                <cfif q_getdefinition.currentRow GT 1>
                                    ,
                                </cfif>
                               <cfset thisValue = evaluate(q_getdefinition.column_name)>
                                <cfswitch expression="#q_getdefinition.type_name#">
                                    <cfcase value="nvarchar,varchar,char" delimiters=",">
                                        <cfqueryparam value="#thisValue#" cfsqltype="CF_SQL_VARCHAR" maxlength="#q_getdefinition.precision#">
                                    </cfcase>
                                    <cfcase value="ntext,text" delimiters=",">
                                        <cfqueryparam value="#thisValue#" cfsqltype="CF_SQL_LONGVARCHAR" maxlength="#q_getdefinition.precision#">
                                    </cfcase>
                                    <cfcase value="datetime">
                                        <cfqueryparam value="#createODBCDateTime(thisValue)#" cfsqltype="CF_SQL_TIMESTAMP">
                                    </cfcase>
                                    <cfcase value="int">
                                        <cfqueryparam value="#thisValue#" cfsqltype="CF_SQL_INTEGER">
                                    </cfcase>
                                    <cfcase value="bit">
                                        <cfqueryparam value="#thisValue#" cfsqltype="CF_SQL_BIT">
                                    </cfcase>
                                    <cfcase value="float">
                                        <cfqueryparam value="#thisValue#" cfsqltype="CF_SQL_FLOAT">
                                    </cfcase>
                                </cfswitch>
                            </cfif>
                        </cfloop>
                      )
                </cfquery>
                <!--- query for inserted ID --->
                <cfquery datasource="#attributes.datasource#" name="q_getID" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
                    SELECT MAX(#ATTRIBUTES.assignIDfield#) AS insertID
                    FROM #attributes.tablename#
                </cfquery>
                <cfset CALLER.insertID=q_getID.insertID>
            </cftransaction>
            <cfcatch type="database">
            	<cfmodule template="#application.customTagPath#/errorHandler.cfm" cfcatchstruct="#cfcatch#">
            	<cfset REQUEST.dbactionsuccess = 0>
            </cfcatch>
        </cftry>
		<cfset REQUEST.dbactionsuccess = 1>

	</cfcase>
	<cfcase value="UPDATE">
		<cfparam name="attributes.whereclause" default="">
		<cfif NOT len(attributes.primarykeyfield)+len(attributes.whereclause)>
			<h3>ERROR: You must supply a <strong>primarykeyfield</strong> or <strong>whereclause</strong> 
			attribute to call this tag using the UPDATE action.</h3>
			<cfexit method="EXITTAG">
		</cfif>
		<cfset updatelist="">
		<cfloop query="q_getdefinition">
			<cfif listLen(updatelist,",")>
				<cfset comma=", ">
			<cfelse>
				<cfset comma="">
			</cfif>
			<!--- SET UPDATE LIST --->
			<cfif NOT findnocase('identity',q_getdefinition.type_name,1) AND q_getdefinition.column_name NEQ attributes.assignIDfield>
			<cfparam name="#q_getdefinition.column_name#" default="">
				<cfif len(trim(evaluate(q_getdefinition.column_name)))><!--- if variable holds a value --->
					<cfif findnocase('char',q_getdefinition.type_name,1) OR findnocase('text',q_getdefinition.type_name,1)>
							<cfif left(q_getdefinition.type_name,1) EQ "n">
								<cfset thisN="N">
							<cfelse>
								<cfset thisN="">
							</cfif>
							<cfif findnocase('urn:schemas-microsoft',evaluate(q_getdefinition.column_name),1) OR findnocase('class=MsoNormal',evaluate(q_getdefinition.column_name),1)>
								<cfmodule template="#application.customTagPath#/cleanmstext.cfm" mstext="#q_getdefinition.column_name#" replacequotes="true" quotestype="text">
							</cfif>
						<cfset escapeStr=replaceNoCase(evaluate(q_getdefinition.column_name),"'","''","all")>
						<cfset updatelist=updatelist&comma&q_getdefinition.column_name&"="&thisN&"'"&escapeStr&"'">
					<cfelseif findnocase('date',q_getdefinition.type_name,1) AND len(evaluate(q_getdefinition.column_name)) GT 0>
						<cfset updatelist=updatelist&comma&q_getdefinition.column_name&"="&createODBCDateTime(evaluate(q_getdefinition.column_name))>
					<cfelse>
						<cfif NOT isDefined("#q_getdefinition.column_name#") OR len(evaluate(q_getdefinition.column_name)) EQ 0>
							<cfset thisValue="NULL">
						<cfelse>
							<cfset thisValue=evaluate(q_getdefinition.column_name)>
						</cfif>
						<cfset updatelist=updatelist&comma&q_getdefinition.column_name&"="&thisValue>
					</cfif>
			 	<cfelseif structkeyexists(form,q_getdefinition.column_name) OR structkeyexists(url,q_getdefinition.column_name)>
					<cfif findnocase('char',q_getdefinition.type_name,1) OR findnocase('text',q_getdefinition.type_name,1)>
						<cfset updatelist=updatelist&comma&q_getdefinition.column_name&"=''">
					<cfelse>
						<cfset updatelist=updatelist&comma&q_getdefinition.column_name&"=NULL">
					</cfif> 
				</cfif>
			<cfelse>
				<cfset pk=q_getdefinition.column_name>
			</cfif>
		</cfloop>
		<!--- if this is not an auto number, set PK to the specified field name --->
		<cfif len(attributes.assignIDfield)>
			<cfset pk=attributes.assignIDfield>
			<cfset attributes.primarykeyfield=attributes.assignIDfield>
		</cfif>
		<!--- DO DATABASE UPDATE --->
		<cftry>
		<cftransaction>
			<cfquery datasource="#attributes.datasource#" name="q_updatedata" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE #attributes.tablename#
				SET #preserveSingleQuotes(updatelist)#
				WHERE 
				<cfif len(attributes.primarykeyfield)>
					#pk#=#evaluate(attributes.primarykeyfield)#
				<cfelse>
					#preserveSingleQuotes(attributes.whereclause)#
				</cfif>
			</cfquery>
		</cftransaction>
		<cfset request.dbactionsuccess=1>
		<cfcatch type="Any"><!--- Handle any errors --->
			<cfmodule template="#application.customTagPath#/errorHandler.cfm" cfcatchstruct="#cfcatch#">
			<cfset request.dbactionsuccess=0>
		</cfcatch>
		</cftry> 
	</cfcase>
	<cfcase value="DELETE">
		<cfparam name="attributes.whereclause" default="">
		<cfloop query="q_getdefinition">
			<cfif findnocase('identity',q_getdefinition.type_name,1)>
				<cfset pk=q_getdefinition.column_name>
			</cfif>
		</cfloop>
		<cfif NOT isDefined("pk")>
			<cfset pk=attributes.assignIDfield>
		</cfif>

		<cfif NOT len(attributes.primarykeyfield)+len(attributes.whereclause)+len(attributes.assignIDfield)>
			<h3>ERROR: You must supply a <strong>primarykeyfield</strong>, <strong>whereclause</strong>  or an <strong>assignIDfield</strong> attribute to call this tag using the DELETE action.</h3>
			<cfexit method="EXITTAG">
		</cfif>
	<!--- DO DATABASE DELETE --->
		<cftry>
		<cflock type="EXCLUSIVE" timeout="10">
			<cfquery datasource="#attributes.datasource#" name="q_deletedata" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE FROM #attributes.tablename#
				WHERE 
				<cfif len(attributes.primarykeyfield)>
					#pk#=#evaluate(attributes.primarykeyfield)#
				<cfelse>
					#preserveSingleQuotes(attributes.whereclause)#
				</cfif>
			</cfquery>
		</cflock>
		<cfset request.dbactionsuccess=1>
		<cfcatch type="Any"><!--- Handle any errors --->
			<cfmodule template="#application.customTagPath#/errorHandler.cfm" cfcatchstruct="#cfcatch#">
			<cfset request.dbactionsuccess=0>
		</cfcatch>
		</cftry>
	</cfcase>
</cfswitch>
</cfif>