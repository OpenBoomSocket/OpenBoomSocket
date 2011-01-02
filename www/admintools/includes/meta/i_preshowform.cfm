<!--- i_preshowform.cfm --->
<cfset defaultSiteName="Name this site.">
<cfparam name="request.metaneedheader" default="1">
<cfparam name="request.metaneedfooter" default="1">
<!--- this is for the cf_location tag --->
<cfif NOT isDefined("session.debug")>
	<cflock timeout="10" throwontimeout="no" scope="session"><cfset session.debug=1></cflock>
</cfif>
<cfset showMetaForm=1>
<cfset isMetaError=0>
<cfset metaErrorMsg="">
<cfset isEdit=0>
<cfparam name="instanceid" default="">

<cfset defaultMetaAction="showMap">
<cfparam name="form.metaAction" default="#defaultMetaAction#">
<cfparam name="metaAction" default="#form.metaAction#">

<cfif request.metaNeedHeader>
<cfoutput><table border="#q_getForm.tableborder#" cellspacing="#q_getForm.tablespacing#" cellpadding="#q_getForm.tablepadding#" width="100%" align="#q_getForm.tablealign#" class="#q_getForm.tableclass#"></cfoutput>	
	<tr valign="top">
		<td class="toolheader" colspan="2">
			<table width="100%" border="0" cellspacing="0">
				<tr>
					<td width="50%" class="toolheader" nowrap><strong>Meta Data</strong></td>
					<td align="right" width="50%" class="toolheader"><cfif isDefined('url.instanceid')><a href="index.cfm?i3currentTool=113" style="font-size:11px;color:#ffffff;">&lt; Meta Data Index</a></cfif></td>
				</tr>
			</table>
		</td>
	</tr>
<cfset request.metaNeedHeader=0>
</cfif>

<cfswitch expression="#metaAction#">

	<cfcase value="showMap">
		<!--- query for map info --->
		<!--- set up sections --->
		<cfquery datasource="#application.datasource#" name="q_getSections" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#"> 
		  SELECT sitesectionname,sitesectionid FROM sitesection 
		</cfquery> 
		<cfquery datasource="#application.datasource#" name="q_getSitename" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#"> 
		  SELECT sitename FROM sitesettings 
		</cfquery>
		<cfif q_getSitename.recordcount>
			<cfset thisSiteName=q_getSitename.sitename>
		<cfelse>
			<cfset thisSiteName=defaultSiteName>
		</cfif>
		<cfparam name="sectionPathList" default=""> 
		<cfloop query="q_getSections"> 
		  <!---Get the path of the section---> 
		  <cfset thisPath = #application.getSectionPath(q_getSections.sitesectionid,"true")#> 
		  <cfif sectionPathList EQ ""> 
			   <cfset sectionPathList = "#thisPath#:#q_getSections.sitesectionid#"> 
		  <cfelse> 
			   <cfset sectionPathList = listAppend(sectionPathList,"#thisPath#:#q_getSections.sitesectionid#")> 
		  </cfif> 
		</cfloop> 
		<cfset listAsc = ListSort(#sectionPathList#, "textnocase", "asc")> 
		<!--- loop through sections, get pages --->
		<cfoutput>
	<tr valign="top">
		<td class="formiteminput" colspan="2">
		<ul><!--- site level --->
			<li style="list-style:square;"><a href="#request.page#?metaAction=editType&editType=site&instanceid=100000">#thisSiteName#</a></li>
			<ul><!--- section level --->
			<cfloop list="#listAsc#" index="i"> 
				<cfset thisSectionId="#listLast(ListLast(i, "\"),":")#">				
				<cfif #ListLen(i, "\")# GT 1><ul></cfif>
					<li style="list-style:disc;" <cfif #ListLen(i, "\")# GT 2>style="margin-left:#(ListLen(i, "\")-2) * 10#px;"</cfif>><a href="#request.page#?metaAction=editType&editType=sitesection&instanceid=#listLast(ListLast(i, "\"),":")#">#listFirst(ListLast(i, "\"),":")#</a></li>				
				<!--- get this section's pages --->
				<cfquery datasource="#application.datasource#" name="q_getPages" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#"> 
				  SELECT pagename,pageid FROM page WHERE sitesectionid = #thisSectionId# ORDER BY pagename
				</cfquery>
				<cfif q_getPages.recordcount>
					<ul><!--- page level --->
					<cfloop query="q_getPages">
						<li style="list-style:circle;"><a href="#request.page#?metaAction=editType&editType=page&instanceid=#q_getPages.pageid#">#q_getPages.pagename#</a></li>
					</cfloop>
					</ul>
				</cfif>
				<cfif #ListLen(i, "\")# GT 1></ul></cfif>
			</cfloop> 
			</ul> 
		</ul>
		</td>
	</tr>
	</cfoutput>
	</cfcase>
	
	<cfcase value="editType">
	<cfif len(editType) AND (isDefined("instanceid") AND len(trim(instanceid)))><!--- edit --->
		<!--- param all the form vars --->
		<cfif editType EQ "site">
			<cfquery name="q_getThisMeta" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT * FROM meta WHERE metaID = 100000
			</cfquery>
		<cfelse>
			<cfquery name="q_getThisMeta" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT meta.* 
				FROM meta 
				WHERE #editType#ID = #instanceid#
			</cfquery>
		</cfif>
		<cfif isNumeric(q_getThisMeta.pageid)>
			<cfquery name="q_getPageTitle" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT pagetitle FROM page WHERE pageid=#q_getThisMeta.pageid#
			</cfquery>
			<cfparam name="form.pageTitle" default="#q_getPageTitle.pagetitle#">
		</cfif>
		<!--- param the query vars here --->
		<cfif NOT IsDefined("form.submit") AND q_getThisMeta.recordCount NEQ 0>
			<cfparam name="form.metaID" default="#q_getThisMeta.metaID#">
			<cfparam name="form.metaIncludeSite" default="#q_getThisMeta.metaIncludeSite#">
			<cfparam name="form.metaIncludeSection" default="#q_getThisMeta.metaIncludeSection#">
			<cfparam name="form.metaKeywords" default="#q_getThisMeta.metaKeywords#">
			<cfparam name="form.metaDescription" default="#q_getThisMeta.metaDescription#">
			<cfparam name="form.metaRobotsIndex" default="#q_getThisMeta.metaRobotsIndex#">
			<cfparam name="form.metaRobotsFollow" default="#q_getThisMeta.metaRobotsFollow#">
			<cfparam name="form.metaCopyright" default="#q_getThisMeta.metaCopyright#">
			<cfparam name="form.metaExpires" default="#q_getThisMeta.metaExpires#">
			<cfparam name="form.metaRefreshTime" default="#q_getThisMeta.metaRefreshTime#">
			<cfparam name="form.metaRefreshURL" default="#q_getThisMeta.metaRefreshURL#">
			<cfparam name="form.metaPragma" default="#q_getThisMeta.metaPragma#">
			<cfparam name="form.metaCustom" default="#q_getThisMeta.metaCustom#">
		</cfif>
		<cfif q_getThisMeta.recordcount>
			<cfset isEdit=1>
		</cfif>
	</cfif>
		
		<cfif editType NEQ "site">
			<cfif NOT isDefined("form.submit")>
				<cfparam name="form.metaIncludeSite" default="1">
			</cfif>
			<cfif editType EQ "page">
				<cfif NOT isDefined("form.submit")>
					<cfparam name="form.metaIncludeSection" default="0">
				</cfif>
				<!--- query page title --->
				<cfif NOT isDefined("form.pageTitle")>
					<cfquery name="q_getPageName" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT pagetitle FROM page WHERE pageid=#instanceid#
					</cfquery>
					<cfset form.pageTitle=q_getPageName.pagetitle>
				</cfif>
			</cfif>
		</cfif>
		<cfif NOT isDefined("form.submit")><!--- these values will be set below if form submitted --->
			<cfparam name="form.metaIncludeSite" default="0">
			<cfparam name="form.metaIncludeSection" default="1">
			<cfparam name="form.metaRobotsIndex" default="1">
			<cfparam name="form.metaRobotsFollow" default="1">
		</cfif>
		<cfparam name="form.pageTitle" default="">
		<cfparam name="form.metaKeywords" default="">
		<cfparam name="form.metaDescription" default="">
		<cfparam name="form.metaCopyright" default="#application.sitename#">
		<cfparam name="form.metaExpires" default="">
		<cfparam name="form.metaRefreshTime" default="">
		<cfparam name="form.metaRefreshURL" default="">
		<cfparam name="form.metaPragma" default="0">
		<cfparam name="form.metaCustom" default="">
		
		<!--- validate submitted form --->
		<cfif isDefined("form.submit")>
			<cfif len(trim(form.metaRefreshTime)) AND NOT isNumber(form.metaRefreshTime)>
				<cfset isMetaError=1>
				<cfset metaErrorMsg="<li>Refresh Time must be an integer</li>">
			</cfif>
			<cfif len(trim(form.metaExpires)) AND NOT isDate(form.metaRefreshTime)>
				<cfset isMetaError=1>
				<cfset metaErrorMsg="<li>Expire value must be a valid date</li>">
			</cfif>
			<!--- set checkboxes to No --->
			<cfif NOT isDefined("form.metaIncludeSite") OR form.metaIncludeSite NEQ 1>
				<cfset form.metaIncludeSite=0>
			</cfif>
			<cfif NOT isDefined("form.metaIncludeSection") OR form.metaIncludeSection NEQ 1>
				<cfset form.metaIncludeSection=0>
			</cfif>
			<cfif NOT isDefined("form.metaRobotsIndex") OR form.metaRobotsIndex NEQ 1>
				<cfset form.metaRobotsIndex=0>
			</cfif>
			<cfif NOT isDefined("form.metaRobotsFollow") OR form.metaRobotsFollow NEQ 1>
				<cfset form.metaRobotsFollow=0>
			</cfif>
			<cfif NOT isMetaError>
				<cfset showMetaForm=0>
			</cfif>
		</cfif>
		
		<cfif showMetaForm>
		<!--- create the form --->
		<cfsavecontent variable="theMetaForm">
				<cfoutput>
				<form name="meta" method="post" action="#request.page#">
				<input type="hidden" name="formstep" value="showform">
				<input type="hidden" name="formobjectid" value="#session.i3currenttool#">
				<cfif isDefined("instanceid")>
					<input type="hidden" name="instanceid" value="#instanceid#">
				</cfif>
				<input type="hidden" name="metaAction" value="#metaAction#">
				<input type="hidden" name="editType" value="#editType#">
				<cfif editType NEQ "site">
					<input type="hidden" name="#editType#ID" value="#instanceid#">
				</cfif>
				<cfif isDefined("form.metaID")>
					<input type="hidden" name="metaID" value="#form.metaID#">
				</cfif>
					<cfif isMetaError>
						<tr align="left" valign="top">
								<td colspan="2" class="errormessage">#metaErrorMsg#</td>
						</tr>
					</cfif>
					<cfif isDefined("request.metaSuccessMsg")>
						<tr align="left" valign="top">
								<td colspan="2" class="errormessage">#request.metaSuccessMsg#</td>
						</tr>
					</cfif>
					<cfset thisSectionName = "">
					<cfset thisPageName = "">
					<cfif editType EQ "page">
                        <cfquery name="q_getSectionPath" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
                            SELECT sitesection.sitesectionname FROM page INNER JOIN sitesection ON page.sitesectionid = sitesection.sitesectionid WHERE page.pageid=#instanceid#
                        </cfquery>
						<cfset thisSectionName=q_getSectionPath.sitesectionname>
					<cfelse>
                        <cfset thisSectionName=APPLICATION.getSectionPath(instanceID,true,'/')>
					</cfif>
                    
					
					<cfif editType EQ "page">
						<cfquery name="q_getPagePath" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT pagename FROM page WHERE pageid=#instanceid#
						</cfquery>
						<cfset thisPageName=q_getPagePath.pagename>
					</cfif>
						<tr align="left" valign="top">
								<td colspan="2" class="formiteminput">/#thisSectionName#/#thisPageName#</td>
						</tr>
					<cfif editType EQ "page">
						<tr align="left" valign="top">
								<td class="formiteminput">Page Title </td>
								<td class="formiteminput">
									<input name="pageTitle" type="text" size="50" maxlength="255" value="#form.pageTitle#">						
								</td>
						</tr>
					<cfelse>
						<input name="pageTitle" type="hidden" value="">
					</cfif>
						<cfif editType NEQ "site">
						<tr align="left" valign="top">
								<td class="formiteminput">Include</td>
								<td class="formiteminput">
										<input name="metaIncludeSite" type="checkbox" id="metaIncludeSite" value="1"<cfif form.metaIncludeSite EQ 1> checked</cfif>> Site Meta<cfif editType EQ "page"><br><input name="metaIncludeSection" type="checkbox" id="metaIncludeSection" value="1"<cfif form.metaIncludeSection EQ 1> checked</cfif>> Section Meta</cfif>
								</td>
						</tr>
						</cfif>
						<tr align="left" valign="top">
								<td class="formiteminput">Description </td>
								<td class="formiteminput">
									<input name="metaDescription" type="text" size="50" maxlength="255" value="#form.metaDescription#">						
								</td>
						</tr>
						<tr align="left" valign="top">
								<td class="formiteminput">Keywords </td>
								<td class="formiteminput">
										<textarea name="metaKeywords" cols="44" rows="5">#form.metaKeywords#</textarea>
								</td>
						</tr>
						<tr align="left" valign="top">
								<td class="formiteminput">Copyright </td>
								<td class="formiteminput">
										<input name="metaCopyright" type="text" size="50" maxlength="255" value="#form.metaCopyright#">
								</td>
						</tr>
						<tr align="left" valign="top">
								<td class="formiteminput">Robots </td>
								<td class="formiteminput">
										<strong>index:</strong>&nbsp; <input type="radio" name="metaRobotsIndex" value="1"<cfif form.metaRobotsIndex EQ 1> checked</cfif>> yes <input type="radio" name="metaRobotsIndex" value="0"<cfif form.metaRobotsIndex NEQ 1> checked</cfif>> no
										<br/><strong>follow:</strong> <input type="radio" name="metaRobotsFollow" value="1"<cfif form.metaRobotsFollow EQ 1> checked</cfif>> yes <input type="radio" name="metaRobotsFollow" value="0"<cfif form.metaRobotsFollow NEQ 1> checked</cfif>> no
										
								</td>
						</tr>
						<tr align="left" valign="top">
								<td class="formiteminput">Cache (Pragma) </td>
								<td class="formiteminput">
										<input name="metaPragma" type="radio" value="1"<cfif form.metaPragma EQ 1> checked</cfif>>
										Yes 
										<input name="metaPragma" type="radio" value="0"<cfif form.metaPragma EQ 0> checked</cfif>> 
										No 
								</td>
						</tr>
						<tr align="left" valign="top">
								<td class="formiteminput">Expires </td>
								<td class="formiteminput">
										<input name="metaExpires" type="text" size="10" maxlength="10" value="#form.metaExpires#">
								</td>
						</tr>
						<tr align="left" valign="top">
								<td class="formiteminput">Refresh Page </td>
								<td class="formiteminput">
										<input name="metaRefreshTime" type="text" id="refreshTime" title="this is a test" size="3" maxlength="3" value="#form.metaRefreshTime#"> 
								Time in seconds to refresh this page, or the following url:</td>
						</tr>
						<tr align="left" valign="top">
								<td class="formiteminput">&nbsp;</td>
								<td class="formiteminput">
										<input name="metaRefreshURL" type="text" id="refreshURL" size="50" maxlength="255" value="#form.metaRefreshURL#">
								</td>
						</tr>
						<tr align="left" valign="top">
								<td class="formiteminput">Custom </td>
								<td class="formiteminput">
										<textarea name="metaCustom" cols="44" rows="5">#form.metaCustom#</textarea>
								</td>
						</tr>
						<tr align="left" valign="top">
								<td colspan="2" class="formiteminput" align="center">
										<input name="submit" type="submit" id="submit" value="Submit" class="submitbuttonsmall">
								</td>
						</tr>
				</form>
				</cfoutput>
			</cfsavecontent>
			<cfswitch expression="#editType#">
			
				<cfcase value="site">
					<cfoutput>#theMetaForm#</cfoutput>
				</cfcase>
			
				<cfcase value="sitesection">
					<cfoutput>#theMetaForm#</cfoutput>
				</cfcase>
			
				<cfcase value="page">
					<cfoutput>#theMetaForm#</cfoutput>
				</cfcase>
				
				<cfdefaultcase>
					<cfmodule template="#application.customTagPath#/location.cfm" url="#request.page#" addtoken="no">
				</cfdefaultcase>
			
			</cfswitch>
		<cfelse>
			<cfif isEdit>
				<cfmodule template="#application.customTagPath#/dbaction.cfm" action="UPDATE"
					 datasource="#application.datasource#"
					 tablename="meta" 
					 assignidfield="metaID" 
					 primarykeyfield="metaID">
					 <cfmodule template="#application.customTagPath#/createSiteMeta.cfm">
				<cfset request.metaSuccessMsg="Meta for #metaID# has been updated">
			<cfelse>
				<cfmodule template="#application.customTagPath#/dbaction.cfm" action="INSERT"
					 datasource="#application.datasource#"
					 tablename="meta"
					 assignidfield="metaID">
				 <cfmodule template="#application.customTagPath#/createSiteMeta.cfm">
				<cfset request.metaSuccessMsg="Meta for #insertID# has been inserted">				
			</cfif>
			<cfif isDefined("form.pageTitle") AND isDefined("form.pageID")>
				<cfquery name="q_modifyPageTitle" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE 
						page 
					SET 
						pageTitle='#form.pageTitle#'
					WHERE 
						pageid=#form.pageID#
				</cfquery>
			</cfif>
			<cfset metaAction="showMap">
			<cfinclude template="i_preshowform.cfm">
		</cfif>

	</cfcase>

</cfswitch>
<cfset request.stopprocess="showform">
<cfif request.metaNeedFooter>
	</tr>
</table>
<cfset request.metaNeedFooter=0>
</cfif>