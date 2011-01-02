<!--- i_preconfirm.cfm --->
<!--- If user has chosen to define a new Data Driven Display, retrieve the CFC --->
<cfparam name="innerstep" default="pickMethod">
<cfparam name="form.displayobjectid" default="">
<cfparam name="form.customInclude" default="">
<!--- Create a new Data Driven Display... --->
<cfif len(trim(form.displayobjectid))>
	<cfquery datasource="#application.datasource#" name="q_getdhobject" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT * FROM displayobject	WHERE displayobjectid = #listFirst(form.displayobjectid,"~")#
	</cfquery>
	<!--- Below we check to see if the displayobjectpath is more than one dot notated path. ie clients.dp04dp.something or is is just something --->
	<cfif ListLen(#q_getdhobject.displayobjectpath#, "." GT 1)>
		<cfscript>
			//this routine retrieves the array/structure which defines the CFC methods and arguments
			instance = CreateObject( "component", "#q_getdhobject.displayobjectpath#" ) ;
			metadata = getMetaData(instance);
			request.stopprocess="confirm";//stop formprocess at confirm.
		</cfscript>	
	<cfelse>
		<cfscript>
			//this routine retrieves the array/structure which defines the CFC methods and arguments
			instance = CreateObject( "component", "#application.CFCPath#.#q_getdhobject.displayobjectpath#" ) ;
			metadata = getMetaData(instance);
			request.stopprocess="confirm";//stop formprocess at confirm.
		</cfscript>
	</cfif>
	<cfswitch expression="#innerstep#">
		<cfcase value="pickMethod"><!--- query for display object --->
			<cfif arraylen(metadata.functions) GT 1><!--- if more than one method exists --->
				<cfoutput>
				<table width="550" border="0" cellspacing="1" cellpadding="4" align="center">
					<tr>
						<td>Select a method to use for this Data Driven Display:<br>
				<form action="#request.page#" method="post">
				<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="innerstep,instanceid">
				<input type="Hidden" name="innerstep" value="defineArgs">
				<input type="Hidden" name="validatelist" value="">
				<cfif isDefined("form.instanceid")>
					<input type="Hidden" name="instanceid" value="#trim(form.instanceid)#">
				</cfif>
					<select name="cfcMethods">
						<cfloop from="1" to="#arraylen(metadata.functions)#" index="x">
							<option value="#x#"><cftry>#metadata.functions[x].displayname#<cfcatch type="Any">#metadata.functions[x].name#</cfcatch></cftry>
						</cfloop>
					</select>
				<input type="Submit" value="Define Arguments" class="submitbutton">
				</form>
						</td>
					</tr>
				</table>
				</cfoutput>
			<cfelse><!--- redirect to defineArgs for the only method --->
				<cfset innerstep="defineArgs">
				<cfset form.cfcMethods=1>
				<cfinclude template="i_preconfirm.cfm">
			</cfif>
		</cfcase>
<!--- ********* Build a dynamic form for inputting this method's arguments ******** --->
		<cfcase value="defineArgs">
			<cfoutput>
				<form action="#request.page#" method="post">
				<input type="Hidden" name="formstep" value="confirm">
				<input type="Hidden" name="innerstep" value="validateArgs">
					<cfif isDefined("form.instanceid")>
						<input type="Hidden" name="instanceid" value="#trim(form.instanceid)#">
					</cfif>
					<table width="550" border="0" cellspacing="1" cellpadding="3">
					<tr>
						<td colspan="2" class="toolheader">Define Arguments</td>
					</tr>
					<!--- loop over argument list --->
					<cfset j=trim(form.cfcmethods)>
						<cfset reqList="">
						<cfset argList="">
						<cfif isDefined("instanceid")>
							<cfif fileExists("#application.installpath#\displayhandlers\d_#instanceid#.cfm")>
								<cffile action="READ"
								        file="#application.installpath#\displayhandlers\d_#instanceid#.cfm"
								        variable="invokefiledata">
							</cfif>
						</cfif>
						<cfloop from="1" to="#arraylen(metadata.functions[j].parameters)#" index="y">
						<!--- if we are editing, read current arg values from file --->
						<cfif isDefined("invokefiledata")>
							<cfscript>
								pos1=findnocase('name="#metadata.functions[j].parameters[y].name#',invokefiledata,1);
								pos2=findnocase('value="',invokefiledata,pos1);
								pos3=findnocase('"',invokefiledata,(pos2+7));
								"form.#metadata.functions[j].parameters[y].name#"=mid(invokefiledata,(pos2+7),(pos3-(pos2+7)));
							</cfscript>
						</cfif>
						<!--- param all argument values --->
						<cfparam name="form.#metadata.functions[j].parameters[y].name#" default="">
						<cfset keyList=structKeyList(metadata.functions[j].parameters[y])>
						<!--- set required field list --->
						 <cfif listFindNoCase(keyList,"required") AND metadata.functions[j].parameters[y].required EQ "yes">
							<cfset reqList=listAppend(reqList,"#metadata.functions[j].parameters[y].name#,required",";")>
						</cfif>
						<!--- set fields to validate --->
						<cfif listFindNoCase(keyList,"type") AND len(metadata.functions[j].parameters[y].type)>
							<cfif metadata.functions[j].parameters[y].type eq "numeric">
								<cfset reqList=listAppend(reqList,"#metadata.functions[j].parameters[y].name#,int",";")>
							<cfelseif metadata.functions[j].parameters[y].type eq "date">
								<cfset reqList=listAppend(reqList,"#metadata.functions[j].parameters[y].name#,date",";")>
							</cfif>
						</cfif>
						<cfset argList=listAppend(argList,metadata.functions[j].parameters[y].name)>
						<tr>
							<td class="formitemlabelreq"><strong>#metadata.functions[j].parameters[y].name#</strong></td>
							<td class="formiteminput">
							<cfif metadata.functions[j].parameters[y].type eq "boolean">
								<input type="radio" name="#metadata.functions[j].parameters[y].name#" value="1">Yes
								<input type="radio" name="#metadata.functions[j].parameters[y].name#" value="0">No
							<cfelseif metadata.functions[j].parameters[y].type eq "numeric" AND right(metadata.functions[j].parameters[y].name,2) eq "id">
							<cfset argID=metadata.functions[j].parameters[y].name>
							<cfset argName=removeChars(metadata.functions[j].parameters[y].name,(len(argID)-1),2)>
								<cfquery datasource="#application.datasource#" name="q_getList" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
									SELECT #argName#name,#argID# 
									FROM #argName#		
									ORDER BY #argName#name ASC
								</cfquery>
								<select name="#argID#">
									<cfloop query="q_getList">
										<option value="#evaluate('q_getList.#argID#')#">#evaluate('q_getList.#argName#name')#
									</cfloop>
								</select>
							<cfelse>
								<input type="Text" size="50" name="#metadata.functions[j].parameters[y].name#" value="#evaluate('form.#metadata.functions[j].parameters[y].name#')#">
							</cfif>
							</td>
						</tr>
					</cfloop>
					<tr>
						<td colspan="2" align="center"><input type="Submit" value="Create Data Driven Display" class="submitbutton"></td>
					</tr>
					</table>
				<input type="Hidden" name="validatelist" value="#reqList#">
				<cfmodule template="#application.customtagpath#/embedfields .cfm" ignore="instanceid,formstep,innerstep,validatelist,#argList#">
				</form>
			</cfoutput>
		</cfcase>
		<cfcase value="validateArgs">
			<cfset request.stopprocess="confirm">
			<!--- convert form vars to request --->
				<cfloop list="#form.fieldnames#" index="i">
					<cfset "request.FORM#i#"=evaluate("form."&i)>
				</cfloop>
			<cfmodule template="#application.customTagPath#/formvalidation.cfm" validatelist="#trim(form.validatelist)#">
			<cfif request.isError>
				<cfoutput>
				<div class="errorText" style="width:550;">
					<cfloop list="#request.errorMsg#" delimiters="|" index="m">
						<strong>!</strong> #m#<br>
					</cfloop>
				</div>
				</cfoutput>
				<cfset innerstep="defineArgs">
				<cfinclude template="i_preconfirm.cfm">
			<cfelse>
			<!--- No errors with argument defs, proceed --->	
				<cfscript>
					open=chr(60);
					close=chr(62);
					structUpdate(request,"stopprocess","");
				</cfscript>		
				<!--- build tagcall for invoke script --->
				<cfsavecontent variable="tagCall">
				<cfoutput>
					#open#cfinvoke component="##application.CFCPath##.#q_getdhobject.displayobjectpath#" 
					    method="#metadata.functions[trim(form.cfcmethods)].name#"
					    returnVariable="rtn_#metadata.functions[trim(form.cfcmethods)].name#"#close#
					<cfloop from="1" to="#arraylen(metadata.functions[trim(form.cfcmethods)].parameters)#" index="p">
					 	#open#cfinvokeargument name="#metadata.functions[trim(form.cfcmethods)].parameters[p].name#" value="<cfif isDefined("form.#metadata.functions[trim(form.cfcmethods)].parameters[p].name#")>#evaluate('form.#metadata.functions[trim(form.cfcmethods)].parameters[p].name#')#</cfif>"#close#
					 </cfloop>
					#open#/cfinvoke#close#
					#open#cfoutput#close###rtn_#metadata.functions[trim(form.cfcmethods)].name####open#/cfoutput#close#
				</cfoutput>
				</cfsavecontent>
				<cfif isDefined("form.instanceid")>
					<cfset thisFilename="d_#trim(form.instanceid)#.cfm">
				<cfelse>
					<cfset form.tempfilename="temp#randRange(100,999)#.cfm">
					<cfset thisFilename=form.tempfilename>
				</cfif>
				<cffile action="WRITE"
				        file="#application.installpath#\displayhandlers\#thisFilename#"
				        output="#tagCall#"
				        addnewline="No">
			</cfif>
		</cfcase>
	</cfswitch>
<cfelseif NOT isDefined("deleteinstance") AND isDefined("form.displayid")>
	<cfset form.displayhandlername=listLast(form.displayID,"~")>
</cfif>
