<!---
AUTHORS: George McLin, Ben Wakeman, Carla
Date: 01/21/2003
Purpose: This tag works in conjunction with the FormBuilder admintool set.
Designed to read XML definition of form inputs and data information then
display a user-defined formatted self-posting form.
--->

<!--- **********SET GLOBAL VARS FOR USE INSIDE TAG********** --->
<cfif thisTag.executionmode EQ 'start'>
<!--- set default action for this template --->
<cfset dontShow="hidden,submit,button,reset,formatonly,cancel,image,custominclude">
<cfset defaultaction="preform">
<cfparam name="formstep" default="#defaultaction#">
<cfparam name="request.formstep" default="#formstep#">
<!--- set default vars for everything that could/should come into this template --->
<cfparam name="attributes.formobjectid" default="">
<cfparam name="attributes.ordinal" default="">
<cfparam name="form.displayform" default="1">
<cfparam name="relocate" default="0">
<cfparam name="request.stopprocess" default="">
<cfparam name="session.i3currenttool" default="0">

				<!--- Kill App Scope Variable include here --->
				<!--- Kill App Scope Variable include here --->
				<cfinclude template="#application.globalPath#/appScopeKiller.cfm">
				<!--- Kill App Scope Variable include here --->
				<!--- Kill App Scope Variable include here --->
				
<!--- **********TRAP FOR FATAL ERRORS********** --->
<!--- abort template if no form id --->

<cfif NOT len(trim(attributes.formobjectid))>ERROR: You have called this page without a formobjectid!
	<cfabort>
</cfif>
<cfset formProcessObj = CreateObject('component','#application.cfcpath#.formprocess')>
<cfif NOT isDefined("SESSION.ReviewQueue")>
	<cfset SESSION.ReviewQueue = createObject("component","#APPLICATION.CFCPath#.reviewQueue")>	
</cfif>
<!--- Query for all info about this form if not already queried--->
<cfif NOT isDefined("q_getForm.recordcount")>
	<cfset q_getForm = formProcessObj.getForm(attributes.formobjectid)>
	<cfset request.q_getForm=q_getForm>
</cfif>
<!--- Test authentication --->
<cfif q_getForm.useWorkFlow EQ 1>
	<cfif  NOT APPLICATION.getPermissions("access",attributes.formobjectid)>
		<h3>Access Denied...</h3>
		<p>You do not have the correct permissions to access this tool.</p>
		<cfexit method="EXITTAG">
	</cfif>
</cfif>
<!--- unwrap the datadef. xml and set it to a local array --->
	<cfif len(trim(q_getform.datadefinition)) AND len(trim(q_getform.tabledefinition))>
		<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML" input="#q_getform.datadefinition#" output="a_formelements">
		<cfmodule template="#APPLICATION.customTagPath#/xmlConvert.cfm" action="XML2CFML" input="#q_getform.tabledefinition#" output="a_tableelements">
	<cfelse>
		<cfset a_formelements = "">
		<cfset a_tableelements = "">
	</cfif>
	<cfif IsDefined('a_formelements')>
		<cfset request.a_formelements=a_formelements>
	<cfelse>
		<cfmail to="support@d-p.com" replyto="support@d-p.com" from="support@d-p.com" subject="#application.sitemapping# A_FormElements Tracker" type="html">
			<cfoutput>
				XMLConvert of a_formelements for #application.sitemapping#<br>
				Record Count: #q_getForm.recordcount#<br>
				Data def: #q_getform.datadefinition#<br>
				Attributes.formobjectid: #attributes.formobjectid#<br>
			</cfoutput>
		</cfmail>
	</cfif>
	<cfif IsDefined('a_tableelements')>
		<cfset request.a_tableelements=a_tableelements>
	<cfelse>
		<cfmail to="support@d-p.com" replyto="support@d-p.com" from="support@d-p.com" subject="#application.sitemapping# A_FormElements Tracker" type="html">
			<cfoutput>
				XMLConvert of a_tableelements for #application.sitemapping#<br>
				tabledef: #q_getform.tabledefinition#<br>
				attributes.formobjectid: #attributes.formobjectid#<br>
			</cfoutput>
		</cfmail>
	</cfif>
<!--- abort template if no records for given form id --->
<cfif NOT q_getForm.recordcount>ERROR: No matching formobjectid in the database.
	<cfabort>
</cfif>
<!--- If we are in workflow mode and they are making a copy of an instance, reset the formstep --->
<cfif isDefined("form.makeCopy") AND form.makeCopy EQ 1>
	<cfset request.formstep="createcopy">
</cfif>

<cfif isDefined('form.clone') AND Len(Trim(form.clone))>
	<cfset request.formstep="cloneRecord">
</cfif>
<!--- **********BEGIN MASTER SWITCH********** --->
		<!--- setup switch for form processes --->
		<cfswitch expression="#request.formstep#">
			<cfcase value="preform">
				<!--- try and include if there is one for preshowform and envpreshowform --->
				<cfif len(trim(q_getForm.envpreshowform)) AND q_getForm.singleRecord NEQ 1>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="envpreshowform">
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				<cfelse>
					<cfset relocate=relocate+1>
				</cfif>
				<!--- if both inclusions above fail, relocate to 'showform' --->
				<cfif relocate>
					<cfset request.formstep="showform">
					<cfinclude template="formprocess.cfm">
				</cfif>
			</cfcase>
			<!--- Clones an instance of a record to a new instance --->
			<cfcase value="cloneRecord">
				<!--- Clean up Form / Request Scope --->
				<cfset StructDelete(FORM,'clone')>
				<cfset StructDelete(REQUEST,'Clone')>
				<cfset StructDelete(FORM,'formStep')>
				<cfset StructDelete(REQUEST,'formStep')>
				<cfset StructDelete(FORM,'ordinal')>
				<cfset StructDelete(FORM,'parentID')>
				<cfset FORM.CloneThisRecord = true>
				
				<!--- reset instance ID's so formprocess thinks it's a new record --->
				<cfif IsDefined('FORM.instanceID') AND FORM.instanceID GTE 1>
					<cfset StructDelete(FORM,'instanceID')>
					<cfset StructDelete(REQUEST,'instanceID')>
				</cfif>
				
				<!--- reset <tableName>ID's so formprocess thinks it's a new record --->
				<cfif IsDefined('FORM.#q_getform.dataTable#ID') AND 'FORM.#q_getform.dataTable#ID' GTE 1>
					<cfset StructDelete(FORM,'#q_getform.dataTable#ID')>
					<cfset StructDelete(REQUEST,'#q_getform.dataTable#ID')>
				</cfif>
				
				<cfif IsDefined('FORM.sekeyName') AND Len(Trim(FORM.sekeyname))>
					<cfset FORM.sekeyname = '#FORM.sekeyname#-CLONE'>
				</cfif>
				
				<!--- Need to makesure we reset all foreign key references AKA composite forms --->
				<cfif isDefined('q_getForm.compositeForm') and q_getForm.compositeForm EQ 1>
					<!--- Initialize joinTableList variable --->
					<cfset cloneForeignTableIdList = "">
					<!--- loop through a_formelements to grap foreign keys --->
					<cfloop index="itemIndex" from="1" to="#ArrayLen(a_formelements)#">
						<!--- If FOREIGNKEY exists deal with it --->
						<cfif arrayLen(structFindKey(#a_formelements[itemIndex]#,"FOREIGNKEY"))>
							<!--- This is a foreign key field so we need to delete it from the form scope. --->
							<cfset StructDelete(FORM,a_formelements[itemIndex]['fieldName'])>
						</cfif>
					</cfloop>
				</cfif>
				<!--- include Formprocess code so the form can be populated --->
				<cfset FORM.FORMSTEP = 'showForm'>
				<cfinclude template="formprocess.cfm">
			</cfcase>
			<cfcase value="showform">	
			<!--- If this tool restricts viewing by user type, then set the form var in prep to insert usertypeid into this tool's table --->
				<cfif q_getForm.restrictByUserType EQ 1>
					<cfset form.restrictByUserTypeID=session.user.usertypeid>
				</cfif>
			<!--- query for custom include to run before displaying the form --->
				<cfif len(trim(q_getForm.preshowform))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="preshowform">
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<!--- Check to see if a request has been made to abort before showing the form --->
				<cfif len(request.stopProcess) AND request.stopProcess eq "showform">
					<cfexit method="EXITTAG">
				</cfif>
					<!--- loop over validation/requirements, set var to be used in a hidden field in form below --->
					<cfset validatelist="">
					<cfloop from="1" to="#arrayLen(a_formelements)#" index="x">
					<cfset a=x>
					<cfif structfind(a_formelements[x],"required")>
						<cfif a_formelements[x].required>
							<cfset validatelist=validatelist&"#a_formelements[x].fieldname#,required;">
						</cfif>
					</cfif>
					<cfif len(structfind(a_formelements[x],"validate"))>
						<cfset validatelist=validatelist&"#a_formelements[x].fieldname#,#a_formelements[x].validate#;">
					</cfif>
					</cfloop>
					<!--- We are using workflow so we need to validate publishing dates --->
					<cfif q_getform.useWorkFlow EQ 1>
						<cfset validatelist=validatelist&"dateToPublish,date;dateToExpire,date;timeToPublish,date;timeToExpire,date">
					</cfif>
                    <!--- Changed below FORMaction to pagePath to help is ISAPI and other routing issues--->
					<cfif len(q_getform.formaction)>
						<cfset formaction=q_getform.formaction>
					<cfelse>
                    	<cfif IsDefined('CGI.QUERY_STRING') AND Len(Trim(CGI.QUERY_STRING)) AND ISDefined('REQUEST.pagepath') AND ListFindNoCase(REQUEST.pagepath,'admintools','/') EQ 0>
							<cfset formaction=request.pagepath&'?'&CGI.QUERY_STRING>						
						<cfelse>
							<cfset formaction=request.pagepath>                        
						</cfif>
					</cfif>
					<cfoutput>
						<form action="#formaction#" method="#q_getform.formmethod#" name="#q_getform.formname#" enctype="multipart/form-data">
					<!--- If we have come here from the review queue, pass the var on --->
					<cfif isDefined("url.reviewQueue")>
						<input type="Hidden" name="reviewQueue" value="yes">
					</cfif>
					
                    <!--- BDW 07/23/2008: Add hidden 'decoy' field to prevent Spamming this Form --->
                    	<cfsavecontent variable="spamBotScript">
                        	<style type="text/css">
                            	##spambotdecoy{
									position:absolute;	
									visibility:hidden;
								}
                            </style>
                        </cfsavecontent>
                        <cfhtmlhead text="#spamBotScript#">
                    	<input type="text" id="spambotdecoy" name="icu_#randRange(100,999)#" value="">
                    <!--- End BDW Mod --->  
                    
					<!--- Are we in a liveEdit window? --->
					<!--- CMC 12/4/06: what are we using these hidden fields for? --->
					<script type="text/JavaScript">
						if (window.name == "editWindow"){
							var isWindow = 1;
							<cfif NOT IsDefined('SESSION.i3previousTool')>
								document.write("<input type=Hidden name=editInPlaceRedirect value=liveEdit.cfm?previewContent=no>");
							</cfif>
						}else{
							var isWindow = 0;
						}
						document.write("<input type=Hidden name=liveEditWindow value="+isWindow+">");
					</script>
						<input type="Hidden" name="validatelist" value="#validatelist#">
						<input type="Hidden" name="formstep" value="validate">
						<input type="hidden" value="#q_getForm.datatable#" name="tablename">
						<!--- Create the form automagically from the formobject --->
						<cfinclude template="formbuild.cfm">
						
						<!--- moved to showbuttonbar
						<!--- Clone Button portion --->
						<cfif IsDefined('instanceID') AND instanceID GTE 1 AND isDefined('q_getForm.parentID') AND IsDefined('q_getForm.formobjectID') AND q_getForm.formobjectID EQ q_getForm.parentID>
							<input name="Clone" type="submit" id="Clone" value="Clone" class="submitbutton">
						</cfif> --->
						<cfif IsDefined('FORM.CloneThisRecord')>
							<input type="hidden" value="true" name="CloneThisRecord">
						</cfif>
						</form>
						
						<cfif isDefined("instanceid") AND APPLICATION.getPermissions("remove",attributes.formobjectid) AND q_getForm.singleRecord NEQ 1>
						<cfif q_getForm.useWorkFlow>
							<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" instanceid="#instanceid#" formobjectid="#session.i3currentTool#">
						</cfif>  
						<cfparam name="canDelete" default="1">
							<cfif canDelete>
									<form action="#formaction#" method="#q_getform.formmethod#" name="delete" id="delete">
										<input type="Hidden" name="deleteInstance" value="#trim(instanceid)#">
										<input type="Hidden" name="formstep" value="confirm">
										<input type="hidden" value="#q_getForm.datatable#" name="tablename">
										<!--- form now submitted from showButtonBar
										<cfif q_getform.useWorkFlow NEQ 1>
											<table width="#q_getform.tablewidth#" align="#q_getform.tablealign#"><tr><td align="center"><input type="Submit" value="Delete this Item" class="deletebutton"></td></tr></table>
										</cfif> --->
									</form>
							</cfif>
						</cfif>
					</cfoutput>
			</cfcase>
			<cfcase value="validate">
<!--- try and include if there is one for validate and envvalidate --->
				<cfif len(trim(q_getForm.envprevalidate))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="envprevalidate">
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm" >
				</cfif>
				<cfif len(trim(q_getForm.prevalidate))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="prevalidate">
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<!--- Check to see if a request has been made to abort before running validation step --->
				<cfif len(request.stopProcess) AND request.stopProcess eq "validate">
					<cfexit method="EXITTAG">
				</cfif>
				<!--- convert form vars to request --->
				<cfloop list="#form.fieldnames#" index="i">
					<cfset "request.FORM#i#"=evaluate("form."&i)>
				</cfloop>
				<cfmodule template="#application.customTagPath#/formvalidation.cfm"
		 				  validatelist="#trim(form.validatelist)#">
				<!--- If the scheduled publication module is in play, validate dates --->
				<cfif isDefined("form.timeToPublish") AND form.validateScheduler EQ 1>
					<cfparam name="request.errorMsg" default="">
					<cfset publishStruct = formprocessObj.setPublishDates(dateToPublish=form.dateToPublish,dateToExpire=form.dateToExpire,timeToPublish=form.timeToPublish,timeToExpire=form.timeToExpire,thisErrorMsg=request.errorMsg)>
					<cfset form.dateToPublish = publishStruct.dateToPublish>
					<cfset form.dateToExpire = publishStruct.dateToExpire>
					<cfif publishStruct.hasError>
						<cfset request.isError=1>
						<cfset request.errorMsg=publishStruct.ErrorMsg>
					</cfif>
				</cfif>
                
                <!--- BDW 07/23/2008: Add hidden 'decoy' field to prevent Spamming this Form --->
                <cfloop list="#FORM.fieldnames#" index="thisField">
                	<cfif listFirst(thisField,"_") EQ "icu" AND len(trim(FORM[thisField]))>
						<cfset request.isError=1>
						<cfset request.errorMsg="So sorry.">
					</cfif>
                </cfloop>
                <!--- End BDW Mod ---> 
                
                <!--- ERJ 08/05/2008: Added check to make sure the form is being submitted by the same domain. --->
                <cfif IsDefined('CGI.HTTP_REFERER') AND ISDefined('application.installURL') AND IsDefined('application.installurlsecure')>
                	<cfif NOT FindNoCase(application.installURL,CGI.HTTP_REFERER) AND NOT FindNoCase(application.installurlsecure,CGI.HTTP_REFERER)>
						<cfset request.isError=1>
                        <cfset request.errorMsg="Invalid Submission. URL is Malformed.">
					</cfif>
				</cfif>
                <!--- END ERJ MOD --->
                
				<!--- If there are errors, show them and include form again --->
				<cfif request.isError>
					<cfsavecontent variable="errorMsgBlock">
						<cfoutput>
							<div id="errorBlock">
								<h2>Form Submission Errors</h2>
								<ul>
									<cfloop list="#request.errorMsg#" index="thisError" delimiters="||">
										<li>#thisError#</li>
									</cfloop>
								</ul>
							</div>
						</cfoutput>
					</cfsavecontent>
					<cfset request.formstep="showform">
				<cfelse>
					<cfif q_getForm.showconfirm>
						<cfset request.formstep="confirm">
					<cfelse>
						<cfset request.formstep="commit">
					</cfif>
				</cfif>
				<cfinclude template="formprocess.cfm">
			</cfcase>
			<cfcase value="confirm">
<!--- try and include if there is one for preconfirm and envpreconfirm --->
				<cfif len(trim(q_getForm.envpreconfirm))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="envpreconfirm">
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<cfif len(trim(q_getForm.preconfirm))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="preconfirm">
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<!--- Check to see if a request has been made to abort before showing confirmation --->
				<cfif len(request.stopProcess) AND request.stopProcess eq "confirm">
					<cfexit method="EXITTAG">
				</cfif>
				<cfif len(q_getform.formaction)>
					<cfset formaction=q_getform.formaction>
				<cfelse>
					<cfset formaction="0">
				</cfif>
				<!--- If this is a delete show confirmation --->
				<cfif isDefined("deleteInstance") AND listLen(deleteInstance)>
					<!--- 12/06/2006 DRK pull composite form edit keys START --->
					<!--- get data definitions in array format --->
					<cfset editfieldkeyvalue=q_getForm.editfieldkeyvalue>
					<cfif isDefined('q_getForm.compositeForm') AND (q_getForm.compositeForm EQ 1)>
						<cfset compositekey = structNew()>
						<cfset compositetablelist = "">
						<!--- loop through all form elements including foreign table fields --->
						<cfloop from="1" to="#arrayLen(a_formelements)#" index="i">
							<!--- is this a foreign table field? --->
							<cfif ArrayLen(structFindKey(a_formelements[i],'SOURCEFORMOBJECTID'))>
								<!--- add a listing entry for this table id --->
								<cfif NOT listfindnocase(compositetablelist,a_formelements[i]['SOURCEFORMOBJECTID'])>
									<cfset compositetablelist = listAppend(compositetablelist,a_formelements[i]['SOURCEFORMOBJECTID'])>
									<!--- set up hash table entry for this table --->
									<cfset compositekey[a_formelements[i]['SOURCEFORMOBJECTID']] = "">
								</cfif>
								<!--- check to see if this field has been selected ---->
								<cfloop list="#editfieldkeyvalue#" index="key">
									<cfif listfindnocase(a_formelements[i]['FIELDNAME'],key)>
										<!--- remove composite field from 'normal' field key list --->
										<cfset editfieldkeyvalue = listDeleteAt(editfieldkeyvalue,listfindnocase(editfieldkeyvalue,key))>
									</cfif>
								</cfloop>
							</cfif>
						</cfloop>
					</cfif>
					<!--- 12/06/2006 DRK pull composite form edit keys END --->
					<cfset q_getName = formProcessObj.getName(editfieldkeyvalue=editfieldkeyvalue,datatable=q_getForm.datatable,instanceString=trim(deleteInstance))>
					<cfoutput>
					<cfif q_getForm.adminonly EQ 1>
					<div id="socketformheader"><h2>#q_getForm.label#: Confirm Item Deletion</h2></div><div style="clear: both;"></div>
					</cfif>
					
						<table border="0" cellpadding="5" cellspacing="0" width="550" style="margin: 10px;">
							<tr>
								<td><p><strong>Are you sure you wish to delete the following items from the database?</strong></p>
								<ul>
									<cfloop query="q_getName">
										<li>#q_getName.thisName#</li>
									</cfloop>
								 </ul>
								</td>
							</tr>
							<tr>
								<td align="center">
									<table>
										<tr>
											<td align="center"><form action="<cfif formaction EQ 0>#request.page#<cfelse>#q_getform.formaction#</cfif>" method="#q_getform.formmethod#" name="canceldet">
						<input type="hidden" value="showForm" name="formstep">
						<input type="hidden" value="<!--- #deleteInstance# --->" name="instanceid">
						<input type="hidden" value="#q_getForm.datatable#" name="tablename">
						<input type="submit" value="Back to Form" class="submitbutton" style="width:120px;">
										</form></td>
											<td align="center"><form action="<cfif formaction EQ 0>#request.page#<cfelse>#q_getform.formaction#</cfif>" method="#q_getform.formmethod#" name="delete">
										<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="tablename,fieldnames,formstep,deleteinstance,displayform">
										<input type="Hidden" name="deleteInstance" value="#trim(deleteInstance)#">
										<input type="Hidden" name="instanceName" value="#q_getName.thisName#">
										<input type="Hidden" name="formstep" value="commit">
										<input type="hidden" value="#q_getForm.datatable#" name="tablename">
										<input type="Submit" value="Yes, Delete Now" class="deletebutton" style="width:120px;">
									</form></td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</cfoutput>
				<cfelseif isDefined("deleteInstance") AND NOT listLen(deleteInstance)>
				<!---if the delete button is pressed, but nothing is checked, ignore it, and go back to the list - if this cfelseif gets removed, please remove the isDefined wrapped around formstep on 267 of formInstanceFilter.cfm --->
					<cfset request.formstep="preForm">
					<cfinclude template="formprocess.cfm">
				<cfelse><!--- show standard confirmation --->
					<cfoutput>
					<cfif q_getForm.adminonly EQ 1>
					<div id="socketformheader"><h2>#q_getForm.label#: Confirm Changes</h2></div><div style="clear: both;"></div>
					</cfif>
						<table border="0" cellpadding="3" cellspacing="0" width="90%" style="margin:10px;">
							<tr>
								<td colspan="2"><p>Review your changes below and click "Submit Data" below to save.</p></td>
							</tr>
						<cfloop index="x" from="1" to="#arrayLen(a_formelements)#">
							<cfif NOT listFindNoCase(dontShow,a_formelements[x].inputtype) AND structKeyExists(form,a_formelements[x].fieldname)>
							<tr>
								<td class="toolConfirmLabel" width="25%">#a_formelements[x].objectlabel#:</td>
								<td class="toolConfirmData" width="75%"><cfif findNoCase("~",evaluate('form.#a_formelements[x].fieldname#'))><cfloop list="#evaluate('form.#a_formelements[x].fieldname#')#" index="thisItem">#listLast(thisItem,"~")#<br /></cfloop><cfelse><cfif a_formelements[x].inputtype EQ "password"><cfloop from="1" to="#Len(listLast(evaluate('form.#a_formelements[x].fieldname#'),'~'))#" index="p">*</cfloop><cfelse>#listLast(evaluate("form.#a_formelements[x].fieldname#"),"~")#</cfif></cfif></td>
							</tr>
							</cfif>
						</cfloop>
							<tr>
								<td colspan="2" valign="middle">
									<table width="400" border="0" cellspacing="0" cellpadding="5">
										<tr>
											<td align="center"><form action="<cfif formaction EQ 0>#request.page#<cfelse>#q_getform.formaction#</cfif>" method="#q_getform.formmethod#">
						<input type="hidden" value="showForm" name="formstep">
						<input type="hidden" value="#q_getForm.datatable#" name="tablename">
						<input type="submit" value="Back to Form" class="submitbutton" style="width:115px;">
							<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="formstep,submit,validatelist,tablename">
										</form></td>
											<td align="center"><form action="<cfif formaction EQ 0>#request.page#<cfelse>#q_getform.formaction#</cfif>" method="#q_getform.formmethod#">
							<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="formstep,submit,validatelist,tablename">
							<input type="hidden" value="commit" name="formstep">
							<input type="hidden" value="#q_getForm.datatable#" name="tablename">
							<input type="Submit" value="Submit Data" class="submitbutton" style="width:115px;">
							</form></td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</cfoutput>
				</cfif>
<!--- try and include if there is one for preconfirm and envpreconfirm --->
				<cfif len(trim(q_getForm.envpostconfirm))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="envpostconfirm">
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<cfif len(trim(q_getForm.postconfirm))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="postconfirm">
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
			</cfcase>
			<cfcase value="commit">
			<!--- Set all form vars to trim out ~\ delimeters --->
			<cfloop list="#form.fieldnames#" index="j">
			<!--- Fix issue with using commas in string values for multi-select form inputs --->
				<!--- if there is a tilde, use list parsing --->
				<cfif findNoCase('~',evaluate("form.#j#"))>
					<cfset keylist = "">
					<cfloop list="#evaluate("form.#j#")#" delimiters="~" index="k">
						<cfset keylist = listAppend(keylist, listLast(k))>
					</cfloop>
					<cfset keylist = listDeleteAt(keylist, listLen(keylist))>
					<cfset "form.#j#"=keylist>
				</cfif>
			</cfloop>
			<!--- set publish/expire times to ODBC datetime values (this is happening in formstep=validate for backend but liveedit does not reach validate step) --->
				<!--- If the scheduled publication module is in play, validate dates --->
				<cfif isDefined("form.timeToPublish") AND form.validateScheduler EQ 1>
					<cfparam name="request.errorMsg" default="">
					<cfset publishStruct = formprocessObj.setPublishDates(dateToPublish=form.dateToPublish,dateToExpire=form.dateToExpire,timeToPublish=form.timeToPublish,timeToExpire=form.timeToExpire,thisErrorMsg=request.errorMsg)>
					<cfset form.dateToPublish = publishStruct.dateToPublish>
					<cfset form.dateToExpire = publishStruct.dateToExpire>
					<cfif publishStruct.hasError>
						<cfset reqeust.isError=1>
						<cfset request.errorMsg=publishStruct.ErrorMsg>
					</cfif>
				</cfif>	
<!--- try and include if there is one for preconfirm and envpreconfirm --->
				<cfif len(trim(q_getForm.envprecommit))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="envprecommit">
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<cfif len(trim(q_getForm.precommit))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="precommit">
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<!--- Check to see if a request has been made to abort before commiting --->
				<cfif len(request.stopProcess) AND request.stopProcess eq "commit">
					<cfexit method="EXITTAG">
				</cfif>
				<!--- if there are any password fields passed that are empty, remove them from the form struct --->
				<cfif isStruct(form) AND NOT isDefined("deleteinstance")>
					<cfloop index="x" from="1" to="#arrayLen(a_formelements)#">
						<cfif NOT findNoCase("confirm",a_formelements[x].fieldname,1) AND a_formelements[x].inputtype EQ "password" AND StructKeyExists(FORM,a_formelements[x].fieldname) AND len(trim(form["#a_formelements[x].fieldname#"])) EQ 0>
							<cfset thisBlankPassword=a_formelements[x].fieldname>
							<cfset tmp=structdelete(form,"#thisBlankPassword#")>
						</cfif>
					</cfloop>
				</cfif>
				<cfif q_getForm.datacapture>
					<cfif isDefined("form.instanceid") AND NOT isDefined("deleteInstance")>
						<!--- UPDATE --->
						<!--- handle workflow versioning of content before adding --->
						<cfif q_getForm.useWorkFlow EQ 1 AND NOT isDefined("skipWorkflow")>
						<!--- determine supervisor, versionstatus id for this item --->
						<cfset supervisorStruct = formprocessObj.determineSupervisor(userid=session.user.id,formobjectid=session.i3CurrentTool)>
						<cfset thisSupervisor = supervisorStruct.supervisorid>
						<cfset thisVersionStatus = supervisorStruct.versionstatusid>													
							<!---if directive set to 0, default directive to be set automatically --->
							<cfif isDefined("form.versiondirectiveid") AND Trim(form.versiondirectiveid) eq 0>
								<!--- get default directive for this status --->
								<cftry>
									<cfset q_getDefaultDirective = SESSION.ReviewQueue.getDirectives(versionstatusid=thisVersionStatus,isDefault=true)>
									<cfif q_getDefaultDirective.recordcount>
										<cfset form.versiondirectiveid = q_getDefaultDirective.versiondirectiveid>
									</cfif>
									<cfcatch type="database"></cfcatch>
								</cftry> 			
							</cfif>
							<!---Perform the update; always update the version label in case the instance name was edited--->
							<!--- query for the datatable --->
							<cfset q_FormObjectDataTable  = formprocessObj.getFormObjectTable(formobjectid=session.i3CurrentTool)>
							<!--- hidden field name should be datatable + 'name'--->
							<cfset instanceName = q_formObjectDataTable.datatable & 'name'>
							
							<!--- CMC, ERJ: reevaluate lines 634-637 --->
							<cfif isDefined("form.#instanceName#") AND len(evaluate("form."&instanceName))>
								<cfset thisLabel = replaceNoCase(evaluate("form."&instancename),"'","''")>
							<cfelse>
								<cfset thisLabel = "">
							</cfif>
							<cfif isDefined("form.dateToPublish") AND len(form.dateToPublish)>
								<cfset thisDateToPublish = form.dateToPublish>
							<cfelse>
								<cfset thisDateToPublish = "">
							</cfif>
							<cfif isDefined("form.dateToExpire") AND len(form.dateToExpire)>
								<cfset thisDateToExpire = form.dateToExpire>
							<cfelse>
								<cfset thisDateToExpire = "">
							</cfif>
							<cfif isDefined("form.versiondirectiveid") AND isNumeric(Trim(form.versiondirectiveid)) AND Trim(form.versiondirectiveid) neq 0>
								<cfset thisVersiondirectiveid = Trim(form.versiondirectiveid)>
							<cfelse>
								<cfset thisVersiondirectiveid = 'NULL'>
							</cfif>
							<!--- CMC 12/18/06, added formobjectitemid & instanceitemid for where clause --->
							<cfset q_UpdateVersion = Session.ReviewQueue.UpdateVersion(ownerid=session.user.id,supervisorid=thisSupervisor,versionstatusid=thisVersionStatus,label=thisLabel,dateToPublish=thisDateToPublish,dateToExpire=thisDateToExpire,versiondirectiveid=thisVersiondirectiveid,formobjectitemid=session.i3CurrentTool,instanceitemid=instanceid)>
						<!--- versioning complete, now insert --->
						</cfif>
							<cfset form.datemodified=createODBCdateTime(now())>
							<!--- 12/05/2006 DRK composite form mishmash BEGIN --->
							<!--- If compositeform flag in formobject table is true --->
							<cfif isDefined('q_getform.compositeForm') AND q_getform.compositeForm EQ 1>
								<!--- Initialize joinTableList variable --->
								<cfset foreignTableIdList = "">
								<cfset foreignTableMasterIdList = "">
								<!--- Loop over a_formelements Array to find all items with a value in the sourceformobjectid attribute --->
								<cfloop index="itemIndex" from="1" to="#ArrayLen(a_formelements)#">
									<!--- If sourceformobjectid exists grab value --->
									<cfif arrayLen(structFindKey(#a_formelements[itemIndex]#,"FOREIGNKEY")) AND (a_formelements[itemIndex]['COMMITFOREIGNTABLE'] EQ 1)>
										<cfif a_formelements[itemIndex]['ISMASTERTABLE'] EQ 1>
										<!--- only add unique ids for master tables--->
											<cfif Not findnocase(a_formelements[itemIndex]['SOURCEFORMOBJECTID'], foreignTableMasterIdList)>
												<!--- append new value to current list --->
												<cfset foreignTableMasterIdList = listAppend(foreignTableMasterIdList,a_formelements[itemIndex]['sourceformobjectid'],",")>
											</cfif>
										<cfelse>
											<!--- only add unique ids --->
											<cfif Not findnocase(a_formelements[itemIndex]['SOURCEFORMOBJECTID'], foreignTableIdList)>
												<!--- append new value to current list --->
												<cfset foreignTableIdList = listAppend(foreignTableIdList,a_formelements[itemIndex]['sourceformobjectid'],",")>
											</cfif>
										</cfif>
									</cfif>
								</cfloop>
								<!--- arrange list in numeric order --->
								<cfif listLen(foreignTableMasterIdList)>
									<cfset foreignTableMasterIdList = listSort(foreignTableMasterIdList,"Numeric", "ASC")>
									<!--- Lookup datatable name in formobject table using sourceformobjectid --->
									<cfset q_tableList = formProcessObj.getTablesFromIDs(formObjectIds=foreignTableMasterIdList)>
									<!--- Loop over joinTableList variable --->
									<cfloop query="q_tableList">
										<!--- check to see if foreign key value is already set--->
										<cfif FORM["#trim(q_tableList.datatable)#id"] GT 0>
										<!--- Update new value to foreign table using FORM data and [table]ID --->
											<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE" tablename="#trim(q_tableList.datatable)#" datasource="#application.datasource#" primarykeyfield="#trim(q_tableList.datatable)#id" assignidfield="#trim(q_tableList.datatable)#id">
										<cfelse>
											<!--- clear form scope of id so dbaction doesn't get confused --->
											<cfset structDelete(FORM,"#trim(q_tableList.datatable)#id")>
											<!--- Insert new value to foreign table using FORM data and [table]ID --->
											<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT" tablename="#trim(q_tableList.datatable)#" datasource="#application.datasource#" assignidfield="#trim(q_tableList.datatable)#id">
											<!--- Add new key to FORM with [table]ID as key and insertID (returned from DBAction) as value --->
											<cfset FORM["#trim(q_tableList.datatable)#id"] = insertid>
										</cfif>
									</cfloop>
								</cfif>
								<!--- arrange list in numeric order --->
								<cfif listLen(foreignTableIdList)>
									<cfset foreignTableIdList = listSort(foreignTableIdList,"Numeric", "ASC")>
									<!--- Lookup datatable name in formobject table using sourceformobjectid --->
									<cfset q_tableList = formProcessObj.getTablesFromIDs(formObjectIds=foreignTableIdList)>
									<!--- Loop over joinTableList variable --->
									<cfloop query="q_tableList">
										<!--- check to see if foreign key value is already set--->
										<cfif FORM["#trim(q_tableList.datatable)#id"] GT 0>
										<!--- Update new value to foreign table using FORM data and [table]ID --->
											<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE" tablename="#trim(q_tableList.datatable)#" datasource="#application.datasource#" primarykeyfield="#trim(q_tableList.datatable)#id" assignidfield="#trim(q_tableList.datatable)#id">
										<cfelse>
											<!--- clear form scope of id so dbaction doesn't get confused --->
											<cfset structDelete(FORM,"#trim(q_tableList.datatable)#id")>
											<!--- Insert new value to foreign table using FORM data and [table]ID --->
											<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT" tablename="#trim(q_tableList.datatable)#" datasource="#application.datasource#" assignidfield="#trim(q_tableList.datatable)#id">
											<!--- Add new key to FORM with [table]ID as key and insertID (returned from DBAction) as value --->
											<cfset FORM["#trim(q_tableList.datatable)#id"] = insertid>
										</cfif>
									</cfloop>
								</cfif>
 							</cfif>
							<!--- Allow normal Formprocess DBAction update to proceed --->
							<!--- 12/05/2006 DRK composite form mishmash END--->
							<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE" tablename="#trim(form.tablename)#" datasource="#application.datasource#" whereclause="#q_getform.datatable#id=#trim(form.instanceid)#" assignidfield="#q_getform.datatable#id">
					<!--- DELETE --->
					<cfelseif isDefined("deleteInstance")>
						<cfif q_getForm.useWorkFlow EQ 1>
							<cfset q_deleteVersions = Session.ReviewQueue.deleteVersions(deleteInstanceIDList=deleteInstance,formobjectitemid=session.i3CurrentTool)>					
							<cfset request.dbactionsuccess=1>
						<cfelse>
							<!--- 12/05/2006 DRK composite form mishmash BEGIN --->
							<!--- If compositeform flag in formobject table is true --->
							<cfif isDefined('q_getform.compositeForm') AND q_getform.compositeForm EQ 1>
								<!--- Initialize joinTableList variable --->
								<cfset foreignTableIdList = "">
								<!--- Loop over a_formelements Array to find all items with a value in the sourceformobjectid attribute --->
								<cfloop index="itemIndex" from="1" to="#ArrayLen(a_formelements)#">
									<!--- If sourceformobjectid exists grab value --->
									<cfif arrayLen(structFindKey(#a_formelements[itemIndex]#,"FOREIGNKEY")) AND (a_formelements[itemIndex]['COMMITFOREIGNTABLE'] EQ 1)>
										<!--- only add unique ids --->
										<cfif Not findnocase(a_formelements[itemIndex]['SOURCEFORMOBJECTID'], foreignTableIdList)>
											<!--- append new value to current list --->
											<cfset foreignTableIdList = listAppend(foreignTableIdList,a_formelements[itemIndex]['sourceformobjectid'],",")>
										</cfif>
									</cfif>
								</cfloop>
								<cfif listLen(foreignTableIdList)>
									<!--- arrange list in numeric order --->
									<cfset foreignTableIdList = listSort(foreignTableIdList,"Numeric", "ASC")>
									<!--- Lookup datatable name in formobject table using sourceformobjectid --->
									<cfset q_tableList = formProcessObj.getTablesFromIDs(formObjectIds=foreignTableIdList)>
									<cfset q_instanceData = formProcessObj.getFormData(selectClause="*",fromClause="#q_getForm.datatable#",whereClause="#FORM.TABLENAME#id IN (#FORM.DELETEINSTANCE#)")>
									<!--- Loop over joinTableList variable --->
									<cfloop query="q_tableList">
										<!--- check to see if foreign key value is already set--->
										<cfif evaluate('q_instanceData.'&#trim(q_tableList.datatable)#&'id') GT 0>
											<cfset thisID = evaluate('q_instanceData.'&#trim(q_tableList.datatable)#&'id')>
										<!--- Update new value to foreign table using FORM data and [table]ID --->
											<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE" tablename="#trim(q_tableList.datatable)#" datasource="#application.datasource#" whereclause="#q_tableList.datatable#id IN (#thisID#)">
										</cfif>
									</cfloop>
								</cfif>
 							</cfif>
							<!--- Allow normal Formprocess DBAction update to proceed --->
							<!--- 12/05/2006 DRK composite form mishmash END--->
							<cfmodule template="#application.customTagPath#/dbaction.cfm" action="DELETE" tablename="#trim(form.tablename)#" datasource="#application.datasource#" whereclause="#q_getform.datatable#id IN (#deleteInstance#)">
						</cfif>
						<!--- CMC 12/18/06: delete any content mappings for this instance --->
						<cfif isDefined('APPLICATION.tool.contentmappingrule')>
							<cfset contentMappingObj=createObject("component","#APPLICATION.cfcpath#.contentmapping")>
							<cfset deleteMappings=contentMappingObj.deleteMappingsForInstances(instanceidList=deleteInstance,formobjectid=session.i3CurrentTool)>
						</cfif>			
					<cfelse>
						<!--- INSERT --->
						<!--- handle workflow versioning of content before adding --->
						<cfif q_getForm.useWorkFlow EQ 1>
						<!---Get the id that is about to be assigned to this content object--->
							<cfset q_getNextID = formprocessObj.getNextID(TableName=trim(form.tablename))>
							<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="version" datasource="#application.datasource#" returnvar="thisNextVersionID">
								<!--- determine supervisor, versionstatus id for this item --->	  
								<cfset supervisorStruct = formprocessObj.determineSupervisor(userid=session.user.id,formobjectid=session.i3CurrentTool)>
								<cfset thisSupervisor = supervisorStruct.supervisorid>
								<cfset thisVersionStatus = supervisorStruct.versionstatusid>
							<!--- if directive set to 0, default directive to be set automatically --->
							<cfif isDefined("form.versiondirectiveid") AND Trim(form.versiondirectiveid) eq 0>
								<!--- get default directive for this status --->
								<cftry>
									<cfset q_getDefaultDirective = SESSION.ReviewQueue.getDirectives(versionstatusid=thisVersionStatus,isDefault=true)>
									<cfif q_getDefaultDirective.recordcount>
										<cfset form.versiondirectiveid = q_getDefaultDirective.versiondirectiveid>
									</cfif>
									<cfcatch type="database"></cfcatch>
								</cftry>		
							</cfif>
							<!--- create a label for the version --->
							<cfset thisLabel="">
							<cfloop list="#q_getform.editFieldKeyValue#" index="item">
								<cfset thisLabel=listAppend(thisLabel,evaluate("form.#item#")," ")>
							</cfloop>
							<!---Perform the insert--->
								<cfif ISDefined('form.dateToPublish') AND len(Trim(form.dateToPublish))>
									<cfset thisDateToPublish = form.dateToPublish>
								<cfelse>
									<cfset thisDateToPublish = ''>
								</cfif>
								<cfif ISDefined('form.dateToExpire') AND len(Trim(form.dateToExpire))>
									<cfset thisDateToExpire = form.dateToExpire>
								<cfelse>
									<cfset thisDateToExpire = ''>
								</cfif>
								<!--- update version directive --->
								<cfif isDefined("form.versiondirectiveid") AND isNumeric(Trim(form.versiondirectiveid)) AND Trim(form.versiondirectiveid) neq 0>
									<cfset thisVersiondirectiveid = Trim(form.versiondirectiveid)>
								<cfelse>
									<cfset thisVersiondirectiveid = 'NULL'>
								</cfif>
								<cfset q_InsertVersion = SESSION.reviewqueue.insertVersion(versionid=thisNextVersionID,instanceitemid=q_getNextID.thisNextID,label=thisLabel,formobjectitemid=session.i3CurrentTool,ownerid=session.user.id,supervisorid=thisSupervisor,versionstatusid=thisVersionStatus,parentid=q_getNextID.thisNextID,creatorid=session.user.id,dateToPublish=thisDateToPublish,dateToExpire=thisDateToExpire,versiondirectiveid=thisVersiondirectiveid)>
						<!--- versioning complete, now insert --->
						</cfif>
							<cfset form.datecreated=createODBCdateTime(now())>
							<cfset form.datemodified=createODBCdateTime(now())>
							<cfif q_getForm.useOrdinal>
								<cfset q_getOrdinal = formprocessobj.getOrdinal(datatable=q_getForm.datatable)>
								<cfset form.ordinal = q_getOrdinal.lastIn+1>
							</cfif>
							<!--- 12/04/2006 DRK BDW composite form mishmash BEGIN--->
							<!--- If compositeform flag in formobject table is true --->
							<cfif isDefined('q_getform.compositeForm') AND q_getform.compositeForm EQ 1>
								<!--- Initialize joinTableList variable --->
								<cfset foreignTableIdList = "">
								<cfset foreignTableMasterIdList = "">
								<!--- Loop over a_formelements Array to find all items with a value in the sourceformobjectid attribute --->
								<cfloop index="itemIndex" from="1" to="#ArrayLen(a_formelements)#">
									<!--- If sourceformobjectid exists grab value --->
									<cfif arrayLen(structFindKey(#a_formelements[itemIndex]#,"FOREIGNKEY")) AND (a_formelements[itemIndex]['COMMITFOREIGNTABLE'] EQ 1)>
										<cfif a_formelements[itemIndex]['ISMASTERTABLE'] EQ 1>
										<!--- only add unique ids for master tables--->
											<cfif Not findnocase(a_formelements[itemIndex]['SOURCEFORMOBJECTID'], foreignTableMasterIdList)>
												<!--- append new value to current list --->
												<cfset foreignTableMasterIdList = listAppend(foreignTableMasterIdList,a_formelements[itemIndex]['sourceformobjectid'],",")>
											</cfif>
										<cfelse>
										<!--- only add unique ids for other tables --->
											<cfif Not findnocase(a_formelements[itemIndex]['SOURCEFORMOBJECTID'], foreignTableIdList)>
												<!--- append new value to current list --->
												<cfset foreignTableIdList = listAppend(foreignTableIdList,a_formelements[itemIndex]['sourceformobjectid'],",")>
											</cfif>
										</cfif>
									</cfif>
								</cfloop>
								<cfif listLen(foreignTableMasterIdList)>
									<!--- arrange list in numeric order --->
									<cfset foreignTableMasterIdList = listSort(foreignTableMasterIdList,"Numeric", "ASC")>
									<!--- Lookup datatable name in formobject table using sourceformobjectid --->
									<cfset q_tableList = formProcessObj.getTablesFromIDs(formObjectIds=foreignTableMasterIdList)>
									<!--- Loop over joinTableList variable --->
									<cfloop query="q_tableList">
										<!--- check to see if foreign key value is already set--->
										<cfif FORM["#trim(q_tableList.datatable)#id"] GT 0>
											<!--- Update new value to foreign table using FORM data and [table]ID --->
											<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE" tablename="#trim(q_tableList.datatable)#" datasource="#application.datasource#" primarykeyfield="instanceid" assignidfield="#trim(q_tableList.datatable)#id">
										<cfelse>
											<!--- clear form scope of id so dbaction doesn't get confused --->
											<cfset structDelete(FORM,"#trim(q_tableList.datatable)#id")>
											<!--- Insert new value to foreign table using FORM data and [table]ID --->
											<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT" tablename="#trim(q_tableList.datatable)#" datasource="#application.datasource#" assignidfield="#trim(q_tableList.datatable)#id">
											<!--- Add new key to FORM with [table]ID as key and insertID (returned from DBAction) as value --->
											<cfset FORM["#trim(q_tableList.datatable)#id"] = insertid>
										</cfif>
									</cfloop>
								</cfif>
								<cfif listLen(foreignTableIdList)>
									<!--- arrange list in numeric order --->
									<cfset foreignTableIdList = listSort(foreignTableIdList,"Numeric", "ASC")>
									<!--- Lookup datatable name in formobject table using sourceformobjectid --->
									<cfset q_tableList = formProcessObj.getTablesFromIDs(formObjectIds=foreignTableIdList)>
									<!--- Loop over joinTableList variable --->
									<cfloop query="q_tableList">
										<!--- check to see if foreign key value is already set--->
										<cfif FORM["#trim(q_tableList.datatable)#id"] GT 0>
											<!--- Update new value to foreign table using FORM data and [table]ID --->
											<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE" tablename="#trim(q_tableList.datatable)#" datasource="#application.datasource#" primarykeyfield="instanceid" assignidfield="#trim(q_tableList.datatable)#id">
										<cfelse>
											<!--- clear form scope of id so dbaction doesn't get confused --->
											<cfset structDelete(FORM,"#trim(q_tableList.datatable)#id")>
											<!--- Insert new value to foreign table using FORM data and [table]ID --->
											<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT" tablename="#trim(q_tableList.datatable)#" datasource="#application.datasource#" assignidfield="#trim(q_tableList.datatable)#id">
											<!--- Add new key to FORM with [table]ID as key and insertID (returned from DBAction) as value --->
											<cfset FORM["#trim(q_tableList.datatable)#id"] = insertid>
										</cfif>
									</cfloop>
								</cfif>
 							</cfif>
							<!--- Allow normal Formprocess DBAction commit to proceed --->
							<!--- 12/04/2006 DRK BDW composite form mishmash END--->
							<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT" tablename="#trim(form.tablename)#" datasource="#application.datasource#" assignidfield="#q_getform.datatable#id">
							<cfset instanceid=insertid>
							<!--- 12/12/2006 DRK update mapped id for content mapping done during form item creation START --->
							<cfif isDefined('q_getForm.useMappedContent') AND q_getForm.useMappedContent EQ 1>
								<cfif isDefined('SESSION.tempinstanceid') AND SESSION.tempinstanceid>
									<cfset contentMappingObj=createObject("component","#APPLICATION.cfcpath#.contentmapping")>
									<cfset idschanged=contentMappingObj.updateID(tempID=SESSION.tempinstanceid,realID=instanceid)>
								</cfif>
								<cfset structDelete(SESSION,"tempinstanceid")>
							</cfif>
							<!--- 12/12/2006 DRK update mapped id for content mapping done during form item creation END --->
							<!--- 3/21/2007 DRK generate nav address entry if navigation set for this table START --->
							<cfif isDefined('q_getForm.isNavigable') AND q_getForm.isNavigable EQ 1>
								<cfset form.navitemaddressname = form['#trim(form.tablename)#name']>
								<cfset form.formobjecttableid = application.tool['#trim(form.tablename)#']>
								<cfset form.objectinstanceid = instanceid>
								<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
									 datasource="#application.datasource#"
									 tablename="navitemaddress"
									 assignidfield="navitemaddressid">
							</cfif>
							<!--- 3/21/2007 DRK generate nav address entry if navigation set for this table END --->
					</cfif>
				<cfelse><!--- this is a form with no datatable, so set var to prevent breakage --->
					<cfset request.dbactionsuccess=1>
				</cfif>
				<!--- try and include if there is one for postcommit and envpostcommit --->
				<cfif len(trim(q_getForm.envpostcommit))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="envpostcommit">
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<!--- if using not workflow or pending, include postcommit here, otherwise include in workflow cases --->
				<cfif NOT isDefined("form.workflowAction") OR form.workflowAction EQ "pending"> 
					<!--- if coming from page component popup- redirects inside postcommit so never resets version status--->
					<cfif len(trim(q_getForm.postcommit))>
						<!--- determine proper include (local vs global) for this processing step --->
						<cfset includeFile="postcommit" >
						<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
					</cfif>
				</cfif>
				<cfif request.dbactionsuccess>
				<!--- Send Email if specified --->
					<cfif (len(q_getForm.successEmail) OR (isDefined('REQUEST.emaillist') AND len(REQUEST.emaillist))) AND NOT isDefined('form.DELETEINSTANCE')>
						<cfsavecontent variable="dataBlob">
							<cfoutput>
							<p>The following data was collected from the #q_getForm.formobjectname# form on #application.installurl# on #dateFormat(now(),"mmmm d, yyyy")# at #timeFormat(now(),"h:mm tt")#:</p>
								<table width="100%" cellspacing="0" cellpadding="0">
									<cfloop index="x" from="1" to="#arrayLen(a_formelements)#">							
											
										<cfif NOT listFindNoCase(dontShow,a_formelements[x].inputtype) AND isDefined('form.#a_formelements[x].fieldname#')>
										<tr>
											<td class="labelCell" width="30%" valign="top">#a_formelements[x].objectlabel#</td>
											<td class="inputCell" width="70%" valign="top"><cfif findNoCase("~",evaluate('form.#a_formelements[x].fieldname#'))><cfloop list="#evaluate('form.#a_formelements[x].fieldname#')#" index="thisItem">#listLast(thisItem,"~")#<br /></cfloop><cfelse><cfif a_formelements[x].inputtype EQ "password"><cfloop from="1" to="#Len(listLast(evaluate('form.#a_formelements[x].fieldname#'),'~'))#" index="p">*</cfloop>
											<cfelseif (a_formelements[x].inputtype EQ "checkbox")AND((NOT len(trim(a_formelements[x].objectlabel))) OR (trim(a_formelements[x].objectlabel) EQ "&nbsp;"))>
											
											
											
											
											<cfif len(trim(listLast(evaluate("form.#a_formelements[x].fieldname#"),"~")))>Yes
											<cfelse>No</cfif> - #listLast(listFirst(a_formelements[x].lookuplist,';'))#
											<cfelseif (a_formelements[x].datatype EQ "bit")>
											<cfif len(trim(listLast(evaluate("form.#a_formelements[x].fieldname#"),"~")))>Yes<cfelse>NO</cfif>
											<!--- 10/29/2008 JPL Added a check that in the case of a table lookup that is not a checkbox, to not enter this loop.  This was preventing checkbox items from appearing in the email.--->
											<cfelseif findnocase(a_formelements[x].LOOKUPTYPE,"table") AND len(trim(a_formelements[x].LOOKUPTABLE)) AND a_formelements[x].inputtype NEQ "checkbox">
											
											<cfset thisTable=a_formelements[x].LOOKUPTABLE>
											<cfif len(trim(a_formelements[x].LOOKUPKEY))>
												<cfset thisKey=a_formelements[x].LOOKUPKEY>
											</cfif>
											<cfif len(trim(a_formelements[x].LOOKUPDISPLAY))>
												<cfset thisDisplay="[#thisTable#].#a_formelements[x].LOOKUPDISPLAY#">
												<cfset thisDisplayField="#a_formelements[x].LOOKUPDISPLAY#">
											</cfif>
											<cfif findnocase('char',a_formelements[x].datatype,1) OR findnocase('text',a_formelements[x].datatype,1)>
												<cfset whereRHS = "'#listLast(evaluate("form.#a_formelements[x].fieldname#"),"~")#'">
											<cfelse>
												<cfset whereRHS = #listLast(evaluate("form.#a_formelements[x].fieldname#"),"~")#>
											</cfif>
											<cfif len(trim(whereRHS))>
												<cfquery name="q_friendlyName" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
													SELECT #thisDisplay#
													FROM #thisTable#
													WHERE #thisKey# = #preservesinglequotes(whereRHS)#
												</cfquery>
												<cfif q_friendlyName.recordcount>
													#evaluate("q_friendlyName.#thisDisplayField#")#
												</cfif>
											</cfif>
										<cfelse>#listLast(evaluate("form.#a_formelements[x].fieldname#"),"~")#</cfif></cfif>&nbsp;</td>
										</tr>
										</cfif>
									</cfloop>

								</table>
							</cfoutput>
						</cfsavecontent>
						<cfparam name="REQUEST.emailSubject" default="Data Collected From Web Form: #q_getForm.formobjectname#">
						<cfparam name="REQUEST.emailFrom" default="#application.clientadminemail#">
						<cfif isDefined('REQUEST.emaillist') AND len(REQUEST.emaillist)>
							<cfset thisEmailList = REQUEST.emaillist>
							<cfif len(q_getForm.successEmail)>
								<cfset thisEmailList = thisEmailList & ',' & q_getForm.successEmail>
							</cfif>
						<cfelse>
							<cfset thisEmailList = q_getForm.successEmail>
						</cfif>
						<cfloop list="#thisEmailList#" index="mailItem">
							<cfmail to="#mailItem#"
									from="#REQUEST.emailFrom#"
									subject="#REQUEST.emailSubject#"
									type="HTML">
								<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
								<html>
								<head>
									<title>Data Collected From Web Form: #q_getForm.formobjectname#</title>
										<style type="text/css">
											body{
												background-color:##FFFFFF;
												font-family:Verdana, Arial, Helvetica, sans-serif;
												font-size: 11px;
											}
											td{
												border-width: 0 1px 1px 0;
												border-color:##666666;
												border-style:solid;
												padding:2px;
												font-size: 11px;
											}
											td.labelCell{
												font-weight:bold;
												font-size: 11px;
												padding: 2px 8px;
												background-color:##f1f1f1;
											}
										</style>
								</head>
	
								<body>
								#dataBlob#
								</body>
								</html>
							</cfmail>
						</cfloop>
					</cfif>
				<!--- Completed Send Email function --->
				<!--- If version status variable has been passed, redirect to appropriate case below --->
				<cfif isDefined("form.workflowAction") AND form.workflowAction NEQ "pending">
					<cfset request.formstep="#workflowAction#">
					<cfinclude template="formprocess.cfm">
				</cfif>
				<!--- Check to see if a request has been made to stop after committing --->
				<cfif len(request.stopProcess) AND request.stopProcess eq "postCommit">
					<cfexit method="EXITTAG">
				</cfif>
					<!--- if successmsg, show it --->
					<cfif isDefined("editInPlaceRedirect")>
						<cflocation addtoken="No" url="#trim(editInPlaceRedirect)#">
					<cfelseif len(trim(q_getform.successmsg))>
						<cfoutput>
						<table border="#q_getform.tableborder#" cellpadding="#q_getform.tablepadding#" cellspacing="#q_getform.tablespacing#" width="#q_getform.tablewidth#" align="#q_getform.tablealign#">
						<tr>
							<td valign="top"<cfif len(trim(a_tableelements[2].cell_1.class))> class="#a_tableelements[2].cell_1.class#"</cfif>>
						<cfif isDefined("deleteInstance")>
							<strong>#form.instanceName# has been removed from the database.</strong><br>
						</cfif>
						#q_getform.successmsg#
							</td>
						</tr>
						</table>
						</cfoutput>
						<!--- if also redirect, do it --->
						<cfif len(trim(q_getform.successRedirect))>
							<cfoutput><meta http-equiv="REFRESH" content="15; url=#q_getform.successRedirect#"></cfoutput>
						</cfif>
					<!--- else check on redirect and do it --->
					<cfelseif len(trim(q_getform.successRedirect))>
						<cflocation url="#q_getform.successRedirect#" addtoken="No">
					<!--- all else fails, go back to the beginning --->
					<cfelse>
						<cfif (isDefined("form.liveEditWindow") AND form.liveEditWindow EQ 1)>
							<cfif isDefined("session.i3previoustool")>
								<cfset session.i3currenttool=session.i3previoustool>
							</cfif>
							<cflocation url="#request.page#?closeWindow=yes" addtoken="No">
						<cfelseif isDefined("reviewQueue")>
							<cflocation addtoken="No" url="index.cfm?i3currentTool=#application.tool.version#">
						<cfelseif NOT isDefined("currentContainer") OR len(trim(currentContainer)) EQ 0><!---Not inside Page Wizard so redirect --->
							<cflocation addtoken="No" url="#request.page#">
						</cfif>
					</cfif>
				</cfif>
			</cfcase>
			<!--- CMC 12/13/06- for guest form environment, need seperate case for success that does no processing --->
			<cfcase value="showsuccess">
				<cfoutput>
				<table border="#q_getform.tableborder#" cellpadding="#q_getform.tablepadding#" cellspacing="#q_getform.tablespacing#" width="#q_getform.tablewidth#" align="#q_getform.tablealign#">
				<tr>
					<td valign="top"<cfif len(trim(a_tableelements[2].cell_1.class))> class="#a_tableelements[2].cell_1.class#"</cfif>>
				<cfif isDefined("deleteInstance")>
					<strong>#form.instanceName# has been removed from the database.</strong><br>
				</cfif>
				#q_getform.successmsg#
					</td>
				</tr>
				</table>
				</cfoutput>
				<!--- if also redirect, do it --->
				<cfif len(trim(q_getform.successRedirect))>
					<cfoutput><meta http-equiv="REFRESH" content="15; url=#q_getform.successRedirect#"></cfoutput>
				</cfif>			
			</cfcase>
<!---******** Display Ordinal form ******** --->
			<cfcase value="ordinalForm">
				<cfset displayField="">
				<cfset displayFieldnames="">
				<cfloop list="#request.q_getForm.editFieldKeyValue#" index="j">
					<cfset displayFieldnames=ListAppend(displayFieldnames,j)>
					<cfset displayField=displayField&"ISNULL(convert(varchar(255),#j#), '')">
					<cfif j neq listLast(request.q_getForm.editFieldKeyValue)>
						<cfset displayField=displayField&"+' | '+">
					</cfif>
				</cfloop>
				<cfset ordinalWhereClause="">
				<cfif q_getform.useWorkFlow EQ 1>
					<cfset ordinalWhereClause="#request.q_getForm.datatable#id NOT IN (SELECT #request.q_getForm.datatable#.#request.q_getForm.datatable#id FROM version INNER JOIN #request.q_getForm.datatable# ON version.instanceItemID = #request.q_getForm.datatable#.#request.q_getForm.datatable#id WHERE formobjectitemid = #session.i3currenttool# AND version.archive = 1)">
				</cfif>
				<cfset q_getElements = formprocessObj.getElements(displayField=preserveSingleQuotes(displayField),datatable=request.q_getForm.datatable,whereClause=ordinalWhereClause,displayFieldnames=displayFieldnames)>
				<cfif q_getElements.recordcount GT 25>
					<cfset selectSize=25>
				<cfelse>
					<cfset selectSize=q_getElements.recordcount>
				</cfif>
				<!--- This include provides an interface for sorting the order of table rows --->
				<script>
					// This is for the change sort order functionality
					function Field_up(lst)
					{
						var i = lst.selectedIndex;
						if (i>0) Field_swap(lst,i,i-1);
					}
					function Field_down(lst)
					{
						var i = lst.selectedIndex;
						if (i<lst.length-1) Field_swap(lst,i+1,i);
					}
					function Field_swap(lst,i,j)
					{
						var t = '';
						t = lst.options[i].text; lst.options[i].text = lst.options[j].text; lst.options[j].text = t;
						t = lst.options[i].value; lst.options[i].value = lst.options[j].value; lst.options[j].value = t;
						t = lst.options[i].selected; lst.options[i].selected = lst.options[j].selected; lst.options[j].selected = t;
						t = lst.options[i].defaultSelected; lst.options[i].defaultSelected = lst.options[j].defaultSelected; lst.options[j].defaultSelected = t;
					}
					function SetFields(lst,lstSave)
					{
						var t;
						lstSave.value=""
						for (t=0;t<=lst.length-1;t++)
							lstSave.value+=String(lst.options[t].value)+",";
						if (lstSave.value.length>0)
							lstSave.value=lstSave.value.slice(0,-1);
					}
				</script>
				<cfoutput>
				<div id="socketformheader"><h2>Order Elements</h2></div><div style="clear:both;"></div>
				<form name="orderRows" action="#request.page#" method="post"  onsubmit="SetFields(document.orderRows.sort);">
					<input type="hidden" name="formobjectid" value="#formobjectid#">
					<input type="hidden" name="formstep" value="ordinalPost">
				<!--- 	<input type="hidden" name="totalItems" value="#q_getDataDef.tablerows#"> --->
					<input type="hidden" name="FieldsSave">
						<table cellpadding="3" cellspacing="1" border="0"  class="toolTable">
							<td valign="top" colspan="2" class="formitemlabelreq">Use the directional buttons below to modify the display order of the records in this table.</td>
						</tr>
						<tr valign="top">
							<td class="formitemlabel" align="center">
								<select name="sort" size="#selectSize#" multiple="multiple" class="ordinalSelect">
								 	<cfloop query="q_getElements">
										<!--- Added check for active so we can tell people which ordinal items aren't active. --->
										<option value="#q_getElements.thisID#">#q_getElements.thisValue#<cfif IsDefined('q_getElements.active') AND NOT q_getElements.active> -- (Inactive Item)</cfif></option>
									</cfloop>
								</select>
							</td>
							<td class="formitemlabel">
							<input type="button" name="up" class="submitbutton" value="up" style="width: 60;" onClick="javascript:Field_up(document.orderRows.sort)">
							<p>
							<input type="button" name="down" class="submitbutton" value="down" style="width: 60;" onClick="javascript:Field_down(document.orderRows.sort)">
							<p>
							<input type="button" name="mode" value="Update Order" class="submitbutton"  style="width: 120;" onClick="javascript:SetFields(document.orderRows.sort,document.orderRows.FieldsSave);document.orderRows.submit()"></td>
						</tr>
						</table>
					</form>
				</cfoutput>
			</cfcase>
<!---******** Update ordinal values in this table object ********--->
			<cfcase value="ordinalPost">
				<cfset position=1>
				<cfloop list="#form.fieldssave#" index="x">
					<cfset q_updateElements = formProcessObj.updateOrdinal(datatable=request.q_getForm.datatable,datatableid=x,position=position)>
					<cfset position=position+1>
				</cfloop>
				<cfset msg=URLEncodedFormat("You have successfully updated the order of the elements in this content object.")>
				<cflocation url="#request.page#?successMsg=#msg#" addtoken="No">
			</cfcase>
<!--- ************ WORKFLOW PROCESSES ************** --->
			<cfcase value="approve"><!--- Approve this version of the content item --->
			<!--- determine supervisorid for this item --->
			<cfset supervisorStruct = formprocessObj.determineSupervisor(userid=session.user.id,formobjectid=session.i3CurrentTool,limit=1)>
			<cfset supervisorid = supervisorStruct.supervisorid>
				<cfset q_updateVersion = Session.ReviewQueue.UpdateVersion(versionstatusid=100001,ownerid=session.user.id,supervisorid=supervisorid,formobjectitemid=session.i3CurrentTool,instanceitemid=trim(instanceid))>
				<!--- if coming from page component popup- redirects inside postcommit so never resets version status--->
				<cfif len(trim(q_getForm.postcommit))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="postcommit" >
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<cfset msg=URLEncodedFormat("You have successfully approved this content item.")>
				<cfset attributeList = "msg = " & msg>
				<cfif IsDefined("editInPlaceRedirect")>
					<cflocation addtoken="No" url="#URLDecode(editInPlaceRedirect)#">
				<cfelseif isDefined("reviewQueue")>
					<cflocation addtoken="No" url="index.cfm?i3currentTool=#application.tool.version#">
				<cfelseif NOT isDefined("currentContainer") OR len(trim(currentContainer)) EQ 0><!---Not inside Page Wizard so redirect --->
					<cflocation addtoken="No" url="#request.page#?successMsg=#msg#">
				</cfif>
			</cfcase>
			<cfcase value="reject"><!--- Reject this version of the content item --->
				<cfset q_updateVersion = Session.ReviewQueue.UpdateVersion(versionstatusid=100003,formobjectitemid=session.i3CurrentTool,instanceitemid=trim(instanceid))>
				<!--- if coming from page component popup- redirects inside postcommit so never resets version status--->
				<cfif len(trim(q_getForm.postcommit))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="postcommit" >
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<cfset msg=URLEncodedFormat("You have successfully requested revisions required for this content item.")>
				<cfif IsDefined("editInPlaceRedirect")>
					<cflocation addtoken="No" url="#URLDecode(editInPlaceRedirect)#">
				<cfelseif isDefined("reviewQueue")>
					<cflocation addtoken="No" url="index.cfm?i3currentTool=#application.tool.version#">
				<cfelseif NOT isDefined("currentContainer") OR len(trim(currentContainer)) EQ 0><!---Not inside Page Wizard so redirect --->
					<cflocation addtoken="No" url="#request.page#?successMsg=#msg#">
				</cfif>
			</cfcase>
			<cfcase value="pending"><!--- Make this version of the content item Pending --->
				<cfset q_updateVersion = Session.ReviewQueue.UpdateVersion(versionstatusid=100000,formobjectitemid=session.i3CurrentTool,instanceitemid=trim(instanceid))>
				<!--- if coming from page component popup- redirects inside postcommit so never resets version status--->
				<cfif len(trim(q_getForm.postcommit))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="postcommit" >
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<cfset msg=URLEncodedFormat("You have successfully made this content item pending.")>
				<cfif IsDefined("editInPlaceRedirect")>
					<cflocation addtoken="No" url="#URLDecode(editInPlaceRedirect)#">
				<cfelseif isDefined("reviewQueue")>
					<cflocation addtoken="No" url="index.cfm?i3currentTool=#application.tool.version#">
				<cfelseif NOT isDefined("currentContainer") OR len(trim(currentContainer)) EQ 0><!---Not inside Page Wizard so redirect --->
					<cflocation addtoken="No" url="#request.page#?successMsg=#msg#">
				</cfif>
			</cfcase>
			<cfcase value="scheduleLive"><!--- Reject this version of the content item --->
				<cfset q_updateVersion = Session.ReviewQueue.UpdateVersion(versionstatusid=100004,formobjectitemid=session.i3CurrentTool,instanceitemid=trim(instanceid))>
				<!--- if coming from page component popup- redirects inside postcommit so never resets version status--->
				<cfif len(trim(q_getForm.postcommit))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="postcommit" >
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<cfset msg=URLEncodedFormat("You have successfully scheduled this content item.")>
				<cfif IsDefined("editInPlaceRedirect")>
					<cflocation addtoken="No" url="#URLDecode(editInPlaceRedirect)#">
				<cfelseif isDefined("reviewQueue")>
					<cflocation addtoken="No" url="index.cfm?i3currentTool=#application.tool.version#">
				<cfelseif NOT isDefined("currentContainer") OR len(trim(currentContainer)) EQ 0><!---Not inside Page Wizard so redirect --->
					<cflocation addtoken="No" url="#request.page#?successMsg=#msg#">
				</cfif>
			</cfcase>
			<cfcase value="makeLive"><!--- Approve this version of the content item and publish--->	
				<cfset q_getVersion = Session.ReviewQueue.getVersionRecord(formobjectitemid=session.i3CurrentTool,instanceItemID=trim(instanceid),selectClause="parentid")>
				<!--- determine supervisorid for this item --->
				<cfset supervisorStruct = formprocessObj.determineSupervisor(userid=session.user.id,formobjectid=session.i3CurrentTool,limit=1)>
				<cfset supervisorid = supervisorStruct.supervisorid>
				<!--- Set current live instance to be approved only --->
				<cfif q_getVersion.parentid NEQ ''>
					<cfset q_updateVersion = Session.ReviewQueue.UpdateVersion(versionstatusid=100001,formobjectitemid=session.i3CurrentTool,parentid=q_getVersion.parentid,alreadyPublished=1)>
				</cfif>
				<!--- Set this instance to be the live copy --->
				<cfset q_updateVersion = Session.ReviewQueue.UpdateVersion(versionstatusid=100002,ownerid=session.user.id,supervisorid=supervisorid,formobjectitemid=session.i3CurrentTool,instanceitemid=trim(instanceid))>
				<!--- update all versions with this parentid and formobject that have been assigned to the front-end to use live version --->
				<cfif q_getVersion.parentid NEQ '' AND application.tool.contentObject EQ session.i3CurrentTool>
					<cfset q_updateLiveVersion= formprocessObj.updatePageComponent(contentObjectId=trim(instanceid),formobjectitemid=session.i3CurrentTool,parentid=q_getVersion.parentid)>
				</cfif>
				<!--- if coming from page component popup- redirects inside postcommit so never resets version status--->
				<cfif len(trim(q_getForm.postcommit))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="postcommit" >
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<cfset msg=URLEncodedFormat("You have successfully published this content item.")>
				<cfif IsDefined("editInPlaceRedirect")>
					<cflocation addtoken="No" url="#URLDecode(editInPlaceRedirect)#">
				<cfelseif isDefined("reviewQueue")>
					<cflocation addtoken="No" url="index.cfm?i3currentTool=#application.tool.version#">
				<cfelseif NOT isDefined("currentContainer") OR len(trim(currentContainer)) EQ 0><!---Not inside Page Wizard so redirect --->
					<cflocation addtoken="No" url="#request.page#?successMsg=#msg#">
				</cfif>
			</cfcase>
			<cfcase value="createCopy">
				<!--- Create a new version of content item based on this one --->
				<!--- Insert new modified version --->
				<cfset form.datecreated=createODBCdateTime(now())>
				<cfset form.datemodified=createODBCdateTime(now())>
				
				<cfloop list="#form.fieldnames#" index="x">
					<cfset "form.#x#" = listFirst(evaluate(x), "~")>
				</cfloop>
				<cftransaction>
					<cfset q_getTable = formprocessObj.getFormObjectTable(formobjectid=session.i3CurrentTool)>
					<cfset q_getVersionInfo = Session.ReviewQueue.getVersionRecord(formobjectitemid=session.i3CurrentTool,instanceItemID=trim(instanceid))>
					<cfset q_getVersionMax = Session.ReviewQueue.getVersionRecord(parentid=q_getVersionInfo.parentid,selectClause="MAX(version) AS maxVersion")>
					<cfset q_getVersion = Session.ReviewQueue.getVersionRecord(formobjectitemid=session.i3CurrentTool,instanceItemID=trim(instanceid),selectClause="parentid")>
					<!--- determine supervisor, versionstatus id for this item --->
                    <cfset supervisorStruct = formprocessObj.determineSupervisor(userid=session.user.id,formobjectid=session.i3CurrentTool)>
                    <cfset thisSupervisor = supervisorStruct.supervisorid>
					<!--- Based on the user select workflow action set the version status for this version --->
                    <cfif ISDefined('FORM.WORKFLOWACTION') AND len(Trim(FORM.WORKFLOWACTION))>
						<cfswitch expression="#FORM.WORKFLOWACTION#">
                        	<cfcase value="pending">
								<cfset thisVersionStatus = 100000>
                            </cfcase>
                        	<cfcase value="approve">
								<cfset thisVersionStatus = 100001>
                            </cfcase>
                        	<cfcase value="makeLive">
								<cfset thisVersionStatus = 100002>
                            </cfcase>
                        	<cfcase value="reject">
								<cfset thisVersionStatus = 100003>
                            </cfcase>
                        	<cfcase value="scheduleLive">
								<cfset thisVersionStatus = 100004>
                            </cfcase>
                        </cfswitch>
					<cfelse>
                    	<cfset thisVersionStatus = supervisorStruct.versionstatusid>
					</cfif>					
					<!--- If we are making this copy live, demote current live version to approved status --->
					<cfif thisVersionStatus eq 100002>
						<cfset q_updateVersion = Session.ReviewQueue.UpdateVersion(versionStatusid=100001,parentid=q_getVersionInfo.parentid,formobjectitemid=session.i3CurrentTool,alreadyPublished=1)>
					</cfif>					
					<!--- implement AssignID call --->
					<cfset q_getNewID = formprocessObj.getNextID(tableName=q_getTable.datatable)>
					<cfset nextInstanceID=q_getNewID.ID>
					<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="version" datasource="#application.datasource#" returnvar="nextVersionID">
					<cfset q_insertCopy = Session.ReviewQueue.insertVersion(versionid=nextVersionID,label=q_getVersionInfo.label,parentid=q_getVersionInfo.parentid,instanceItemID=nextInstanceID,version=val(q_getVersionMax.maxVersion+1),ownerid=session.user.id,supervisorid=thisSupervisor,versionStatusID=thisVersionStatus,formobjectitemid=session.i3CurrentTool,creatorid=q_getVersionInfo.creatorid)>
					<!--- update all versions with this parentid and formobject that have been assigned to the front-end to use live version if this is live --->
					<cfif thisVersionStatus EQ 100002>
						<cfset q_updateLiveVersion = formprocessObj.UpdatePageComponent(contentObjectId=trim(nextInstanceID),formobjectitemid=session.i3CurrentTool,parentid=q_getVersionInfo.parentid)>
					</cfif>
				</cftransaction>
				<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT" tablename="#trim(form.tablename)#" datasource="#application.datasource#" assignidfield="#q_getform.datatable#id">
				<!--- if coming from page component popup- redirects inside postcommit so never resets version status--->
				<cfif len(trim(q_getForm.postcommit))>
					<!--- determine proper include (local vs global) for this processing step --->
					<cfset includeFile="postcommit" >
					<cfinclude template="#application.customTagPath#/formprocess/formprocessInclude.cfm">
				</cfif>
				<cfset msg=URLEncodedFormat("You have successfully created a new copy of this content item.")>
				<cfif IsDefined("editInPlaceRedirect")>
					<cflocation addtoken="No" url="#replaceNoCase(URLDecode(editInPlaceRedirect),form.contentobjectid,trim(nextInstanceID))#">
				<cfelseif isDefined("reviewQueue")>
					<cflocation addtoken="No" url="index.cfm?i3currentTool=#application.tool.version#">
				<cfelseif NOT isDefined("currentContainer") OR len(trim(currentContainer)) EQ 0><!---Not inside Page Wizard so redirect --->
					<cflocation addtoken="No" url="#request.page#?successMsg=#msg#">
				</cfif>
			</cfcase>
		</cfswitch>
</cfif>