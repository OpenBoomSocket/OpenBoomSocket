<cfif thisTag.executionMode EQ "start">
<cfsavecontent variable="buttonBarCSS">
	<cfoutput>
		<cfinclude template="#application.globalPath#/css/buttonBarStyles.cfm" />
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#buttonBarCSS#">
<cfoutput>
	<cfparam name="versionstatusid" default="0">
	<cfparam name="canPublish" default="0">
	<cfparam name="canReject" default="0">
	<cfparam name="canApprove" default="0">
	<cfparam name="canEdit" default="0">
	<cfparam name="javascriptCall" default="">
	<cfparam name="attributes.javascriptCall" default="">
	<cfparam name="request.defaultCellClass" default="">
	<cfparam name="attributes.submitbuttonimage" default="">
	<cfparam name="attributes.cancelbuttonimage" default="">
	<cfparam name="attributes.useWorkflow" default="0">
	<cfparam name="attributes.editbuttonname" default="">
	<cfparam name="attributes.editbuttonid" default="">
	<cfparam name="attributes.editbuttontabindex" default="">
	<cfparam name="attributes.showDelete" default="0">
	<cfparam name="attributes.showClone" default="0">
	<cfparam name="attributes.cloneFormname" default="">
	
	<cfif NOT isDefined("request.q_getForm")>
		<cfset formobjectid=session.i3currenttool>
		<cfinclude template="formbuilder/includes/i_getFormobject.cfm">
	</cfif>
	<cfmodule template="#application.customTagPath#/xmlConvert.cfm" action="XML2CFML"
		input="#request.q_getForm.datadefinition#" 
		output="a_formelements"> 
	<cfif NOT findNocase("admintools",CGI.SCRIPT_NAME,1) AND isDefined("contentObjectid")>
		<cfset editInPlaceRedirect=urlEncodedFormat("http://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#?previewContent=yes&contentObjectid=#contentObjectid#")>
	<cfelse>
		<cfset editInPlaceRedirect=urlEncodedFormat("http://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#")>
	</cfif>
	
	<cfset submitTo="/admintools/index.cfm">
	<cfparam name="attributes.editbuttonClass" default="">
	<cfif isDefined("contentObjectid") AND NOT isDefined("request.q_getForm.useWorkFlow")>
		<cfset instanceid=contentObjectid>
		<cfset request.q_getForm.useWorkFlow=1>
	</cfif>
<cfswitch expression="#attributes.useWorkFlow#">
	<cfcase value="1">
		<!--- Output button controls based on rules set above --->
		<!--- Backend forms and Live Edit --->
		<cfif (request.q_getForm.useWorkFlow eq 1 OR isDefined("editInPlace")) AND (isDefined('contentobjectid') OR isDefined('session.i3currenttool'))>
		<!-- open this -->
			<cfif isDefined("contentobjectid")>
				<cfif contentobjectid NEQ ''>
					<cfset instanceid=contentobjectid>
				</cfif>
			</cfif>
		<!--- Run Version Query if this is not a new content element --->
			<cfif isDefined('instanceid')>
				<cfquery name="q_getThisVersion" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT versionStatusId, parentid FROM version WHERE instanceitemid = #instanceid# AND formobjectitemid = #session.i3currenttool#
				</cfquery>
				<!---WHERE clauses--->
				<cfset byObject = "(version.archive IS NULL OR version.archive = 0)">
				<cfif isDefined("instanceid")>
					<cfset byObject = "(version.archive IS NULL OR version.archive = 0) AND version.parentid = #q_getThisVersion.parentid# AND version.formobjectitemid = #session.i3currenttool#">
				</cfif>
				<cfquery name="q_Status" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT * FROM versionstatus
					ORDER BY ordinal ASC
				</cfquery>
				<cfquery name="q_reviewQueue" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT     version.*, VersionStatus.status AS VersionStatus, VersionStatus.colorcode, formobject.label AS FormObjectLabel, 
								UsersOwners.lastName AS ownerLastName, UsersOwners.firstName AS ownerFirstName, UsersOwners.initials AS ownerInitials,
								UsersSupervisors.lastName AS supervisorLastName, UsersSupervisors.firstName AS supervisorFirstName, UsersSupervisors.initials AS supervisorInitials,
								UsersCreators.firstName as creatorFirstName, UsersCreators.lastName as creatorLastName, UsersCreators.initials as creatorInitials
					FROM         version INNER JOIN
								  VersionStatus ON version.versionStatusID = VersionStatus.versionstatusid INNER JOIN
								  Users UsersOwners ON UsersOwners.Usersid = version.ownerid INNER JOIN
								  Users UsersSupervisors ON UsersSupervisors.Usersid = version.supervisorid INNER JOIN
								  Users UsersCreators ON UsersCreators.usersid = version.creatorid INNER JOIN
								  formobject ON formobject.formobjectid = version.formobjectitemid
					WHERE 	#byObject#	
					ORDER BY formobject.label ASC
				</cfquery>
			</cfif>
			<!--- APPLY TO NEW OR MAKE COPY + MESSAGE FOR NO PERMISSIONS --->
			<cfparam name="canEdit" default="0">
			<cfif isDefined('instanceid')>
				<!---We wrote this custom tag to fulfill all the needs of users looking to find permissions on a version--->
				<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" instanceid="#instanceid#" formobjectid="#session.i3currentTool#">
			</cfif>
			<!--- check section rights if this is EditInPlace --->
			<cfif isDefined("editInPlace")>
				<cfquery datasource="#application.datasource#" name="q_getpageInfo" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT page.*, sitesection.sitesectionid, sitesection.templateid AS sectiontemplateid, sitesection.sitesectionname, sitesection.sitesectionlabel
					FROM  page INNER JOIN sitesection ON page.sitesectionid = sitesection.sitesectionid
					WHERE page.pageid = '#request.thispageid#'
				</cfquery>
				<!--- Check user rights to edit content in this section --->
				<cfquery datasource="#application.datasource#" name="q_checkSectionRights" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT * 
					FROM Users_Sections 
					WHERE userid=#session.user.id# AND sitesectionid = #q_getpageInfo.sitesectionid#
				</cfquery>
				<cfif q_checkSectionRights.recordcount EQ 0>
					<cfset canEdit = 0>
				</cfif>
			</cfif>
			<!--- If they do not have edit permission and this is not content creation, show copy warning --->
			<cfif NOT canEdit AND isDefined('instanceid')>
				<div style="padding-top: 3px; padding-bottom: 3px">
				<table cellpadding="0" cellspacing="0" border="0" height="31" width="100%">
					<tr height="8">
						<td valign="top" width="8"><img src="#application.globalPath#/media/images/toolbarLeftTop.gif" /></td>
						<td colspan="2" background="#application.globalPath#/media/images/toolbarTop.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
						<td valign="top" width="8"><img src="#application.globalPath#/media/images/toolbarRightTop.gif" /></td>
					</tr>
					<tr>
						<td valign="top" width="9" background="#application.globalPath#/media/images/toolbarLeft.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
						<td align="center" bgcolor="##E5E7E9"><strong>All changes will be applied to a new version of this document!</strong>
						</td>
						<td bgcolor="##E5E7E9" valign="middle" nowrap width="23"><img src="#application.globalPath#/media/images/toolbarI3.gif" /></td>
						<td valign="top" width="9" background="#application.globalPath#/media/images/toolbarRight.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
					</tr>
					<tr>
						<td valign="top" width="9"><img src="#application.globalPath#/media/images/toolbarLeftBottom.gif" /></td>
						<td colspan="2" background="#application.globalPath#/media/images/toolbarBottom.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
						<td valign="top" width="9"><img src="#application.globalPath#/media/images/toolbarRightBottom.gif" /></td>
					</tr>
				</table></div>
			</cfif>
		<!--- PUBLISH SET-UP LOGIC --->
			<cfquery name="q_getPublishDates" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT dateToPublish, DateToExpire 
				FROM version 
				WHERE instanceItemID = <cfif isDefined("instanceID")>#instanceID#<cfelse>0</cfif> AND formobjectitemid=#session.i3currentTool#
			</cfquery>
			<cfparam name="form.dateToPublish" default="#q_getPublishDates.dateToPublish#">
			<cfparam name="form.dateToExpire" default="#q_getPublishDates.dateToExpire#">
			<cfparam name="form.timeToPublish" default="#q_getPublishDates.dateToPublish#">
			<cfparam name="form.timeToExpire" default="#q_getPublishDates.dateToExpire#">
			<cfif len(form.dateToPublish) AND isDate(form.dateToPublish)>
				<cfset form.dateToPublish=dateFormat(form.dateToPublish,'mm/dd/yyyy')>
			<cfelse>
				<cfset form.dateToPublish=dateformat(now(),"mm/dd/yyyy")>
			</cfif>
			<cfif len(form.dateToExpire) AND isDate(form.dateToExpire)>
				<cfset form.dateToExpire=dateFormat(form.dateToExpire,'mm/dd/yyyy')>
			<cfelse>
				<cfset form.dateToExpire="mm/dd/yyyy">
			</cfif>
			<cfif len(form.timeToPublish) AND isDate(form.timeToPublish)>
				<cfset form.timeToPublish=timeFormat(form.timeToPublish,'h:mm TT')>
			<cfelse>
				<cfset form.timeToPublish=timeformat(now(),"h")&":00 "&timeformat(now(),"TT")>
			</cfif>
			<cfif len(form.timeToExpire) AND isDate(form.timeToExpire)>
				<cfset form.timeToExpire=timeFormat(form.timeToExpire,'h:mm TT')>
			<cfelse>
				<cfset form.timeToExpire="">
			</cfif>
		<!--- PUBLISH JS --->
			<script type="text/JavaScript">
			<cfif isDefined('q_getForm.formName')>
				var thisForm = document.#q_getForm.formName#;
			<cfelseif isDefined('url.formobjectid')>
				<cfset session.i3currenttool = url.formobjectid>
				<cfquery name="q_getForm" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT formname FROM formobject WHERE formobjectid = #url.formobjectid#
				</cfquery>
				var thisForm = document.#q_getForm.formname#;
			<cfelse>
				<cfquery name="q_getForm" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT formname FROM formobject WHERE formobjectid = #session.i3currenttool#
				</cfquery>
				var thisForm = document.#q_getForm.formname#;
			</cfif>
			function blankField(fieldName) {
				if (eval('thisForm.'+fieldName+'.value') == 'mm/dd/yyyy') {
					eval("thisForm."+fieldName+".value=''");
				}
				else if (eval('thisForm.'+fieldName+'.value') == 'hh:mm AM') {
					eval("thisForm."+fieldName+".value=''");
				}
			}
			// CMC i3SiteTools Revision 12/20/05- added reset expire checkbox
			function resetExpire() {
				if (document.getElementById('resetExp').checked == true){
					eval("thisForm.dateToExpire.value = 'mm/dd/yyyy'");
					eval("thisForm.timeToExpire.value=''");
				}
				else{
					eval("thisForm.dateToExpire.value = '#form.dateToExpire#'");
					eval("thisForm.timeToExpire.value='#form.timeToExpire#'");
				}
			}
			function fpSubmit() {
				var processForm = 1;
				if(thisForm.workflowAction && thisForm.makeCopy.value != 1){
					if(thisForm.workflowAction.value!='makeLive'){
						for (var k=0, l=thisForm.workflowAction.options.length; k<l; k++) {
							if (thisForm.workflowAction.options[k].defaultSelected && (thisForm.workflowAction.options[k].value == 'makeLive')) {
								if(confirm('You have set live content to no longer be live. This will result in the page showing "Content Pending". Are you sure you want to do this?')){
									processForm = 1;
								}
								else{
									processForm = 0;
								}
							}
						}
					}
				}
				if(processForm==1){
					//CMC i3SiteTools Revision 12/21 - added var okToSubmit and if stmt around thisform.submit()
					var okToSubmit = 1;
					if(navigator.userAgent.toLowerCase().indexOf('win') > 1){
						if (document.getElementById('ae_tx_content1')){
							ae_onSubmit(); //activeEdit workaround
						}
					}
				//validate date time field combinations
					//if dateToPublish is the mask, set it to null
					if (thisForm.dateToPublish.value == 'mm/dd/yyyy') {
						thisForm.dateToPublish.value='';
					}
					//if dateToPublish is null but timeToPublish has been specified throw an exception
					if (thisForm.dateToPublish.value == '' && thisForm.timeToPublish.value != '') {
						alert("You cannot specify a publish time without supplying a publish date!");
						okToSubmit = 0;
						//return false;
					}
					//if dateToExpire is the mask, set it to null
					if (thisForm.dateToExpire.value == 'mm/dd/yyyy') {
						thisForm.dateToExpire.value='';
					}
				
					//if dateToExpire is null but timeToExpire has been specified throw an exception
					if (thisForm.dateToExpire.value == '' && thisForm.timeToExpire.value != '') {
						alert("You cannot specify an expiration time without supplying an expiration date!");
						okToSubmit = 0;
						//return false;
					}
					if (okToSubmit == 1){
						thisForm.submit();
					}
				}
			}
			function setCopy(){
				thisForm.makeCopy.value=1;
			}
			
			function previewChanges(){
				<cfif isDefined('url.targetdiv')>
					window.opener.document.getElementById('#url.targetdiv#').innerHTML=FCKeditorAPI.GetInstance("contentobjectbody").GetXHTML();	
				</cfif>
			}
			
			function changeVersion(versionObj){
				if(versionObj.value != ''){
					<cfif isDefined('url.targetdiv')>
						<cfset newURLvars = "targetdiv=#url.targetdiv#&contentobjectid='+versionObj.value">
					<cfelseif isDefined('editInPlace')>
						<cfset newURLvars = "editInPlace=yes&contentobjectid='+versionObj.value">
					<cfelse>
						<cfset newURLvars = "instanceid='+versionObj.value+'&displayForm=1&formstep=showform'">
					</cfif>
					location.href='#request.page#?#newURLvars#;
				}
			}
			//'
			
			function deleteVersion(){
				var processForm = 1;
				if(thisForm.workflowAction){
					for (var k=0, l=thisForm.workflowAction.options.length; k<l; k++) {
						if (thisForm.workflowAction.options[k].defaultSelected && (thisForm.workflowAction.options[k].value == 'makeLive')) {
							if(confirm('You are trying to delete published content. This will result in the page showing "Content Pending". Are you sure you want to do this?')){
								processForm = 1;
							}
							else{
								processForm = 0;
							}
						}
					}
				}
				if(processForm==1){
					document.getElementById('delete').submit();
				}
			}
			function toggleCalendar(){
				if (document.getElementById('leCalendarBar').style.display == 'none'){
					document.getElementById('leCalendarBar').style.display = 'block';
				}
				else{
					document.getElementById('leCalendarBar').style.display = 'none';
				}
			}
			</script>
		<!--- PUBLISH DISPLAY --->
		<div id="leCalendarBar" style="padding-bottom: 3px; font-size: 10px; display:none">
			<input type="Hidden" name="validateScheduler" value="1">
		<table cellpadding="0" cellspacing="0" border="0" height="31" width="100%">
				<tr height="8">
					<td valign="top" width="8"><img src="#application.globalPath#/media/images/toolbarLeftTop.gif" /></td>
					<td colspan="3" background="#application.globalPath#/media/images/toolbarTop.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
					<td valign="top" width="8"><img src="#application.globalPath#/media/images/toolbarRightTop.gif" /></td>
				</tr>
				<tr>
					<td valign="top" width="9" background="#application.globalPath#/media/images/toolbarLeft.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
					<td bgcolor="##E5E7E9" valign="middle">
						<nobr>Publish&nbsp;<input type="Text" size="9" maxlength="10" name="dateToPublish" value="#form.dateToPublish#" onfocus="javascript:blankField(this.name);" class="LEselectMenu">&nbsp;<select name="timeToPublish" class="LEselectMenu">
							<option value="">Time
							<cfloop from="1" to="12" index="i">
								<option value="#i#:00 AM"<cfif form.timeToPublish eq "#i#:00 AM"> SELECTED</cfif>>#i#:00 AM</option>
							</cfloop>
							<cfloop from="1" to="12" index="j">
								<option value="#j#:00 PM"<cfif form.timeToPublish eq "#j#:00 PM"> SELECTED</cfif>>#j#:00 PM</option>
							</cfloop>
						</select></nobr>
					</td>
					<td bgcolor="##E5E7E9" valign="middle">
						<nobr>Expire&nbsp;<input type="Text" size="10" maxlength="10" name="dateToExpire" id="dateToExpire" value="#form.dateToExpire#" onfocus="javascript:blankField(this.name);" class="LEselectMenu">&nbsp;<select name="timeToExpire" id="timeToExpire" class="LEselectMenu">
							<option value="">Time
							<cfloop from="1" to="12" index="i">
								<option value="#i#:00 AM"<cfif form.timeToExpire eq "#i#:00 AM"> SELECTED</cfif>>#i#:00 AM</option>
							</cfloop>
							<cfloop from="1" to="12" index="j">
								<option value="#j#:00 PM"<cfif form.timeToExpire eq "#j#:00 PM"> SELECTED</cfif>>#j#:00 PM</option>
							</cfloop>
						</select> </nobr>
					</td>
					<td bgcolor="##E5E7E9" valign="middle" nowrap width="23"><img src="#application.globalPath#/media/images/toolbarI3.gif" /></td>
					<td valign="top" width="9" background="#application.globalPath#/media/images/toolbarRight.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
				</tr>
				<tr>
					<td valign="top" width="9" background="#application.globalPath#/media/images/toolbarLeft.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
					<td bgcolor="##E5E7E9" valign="middle">&nbsp;</td>
					<td bgcolor="##E5E7E9" valign="middle">
						reset expire <input name="resetExp" id="resetExp" type="checkbox" onchange="javascript:resetExpire();"/>
					</td>
					<td bgcolor="##E5E7E9" valign="middle" nowrap width="23"></td>
					<td valign="top" width="9" background="#application.globalPath#/media/images/toolbarRight.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
				</tr> 
				<tr>
					<td valign="top" width="9"><img src="#application.globalPath#/media/images/toolbarLeftBottom.gif" /></td>
					<td colspan="3" background="#application.globalPath#/media/images/toolbarBottom.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
					<td valign="top" width="9"><img src="#application.globalPath#/media/images/toolbarRightBottom.gif" /></td>
				</tr>
			</table>
			<input type="hidden" name="useWorkFlow" value="1">
		</div>
		<!--- VERSIONING AND SAVE AREA --->
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
				<tr height="8">
					<td valign="top" width="8"><img src="#application.globalPath#/media/images/toolbarLeftTop.gif" /></td>
					<td colspan="3" background="#application.globalPath#/media/images/toolbarTop.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
					<td valign="top" width="8"><img src="#application.globalPath#/media/images/toolbarRightTop.gif" /></td>
				</tr>
				<tr>
					<td valign="top" width="9" background="#application.globalPath#/media/images/toolbarLeft.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
					<td valign="middle" bgcolor="##E5E7E9">
						<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#session.i3currentTool#">
						<cfif isDefined("reviewQueue")>
							<input type="Hidden" name="reviewQueue" value="#reviewQueue#">
						</cfif>
						<cfif canEdit>
							<select name="workflowAction" style="font-size: 11px;" onchange="if((this.value=='scheduleLive')&&(document.getElementById('leCalendarBar').style.display == 'none')){toggleCalendar()};">
								<option value="">Change Status</option>
								<option value="pending" style="color: white; background-color: ##FF9933"<cfif isDefined('q_getThisVersion')><cfif q_getThisVersion.versionstatusid eq 100000> SELECTED</cfif></cfif>>Pending
							<cfif canReject>
								<option value="reject" style="color: white; background-color: ##CC0000"<cfif isDefined('q_getThisVersion')><cfif q_getThisVersion.versionstatusid eq 100003> SELECTED</cfif></cfif>>Revisions Required
							</cfif>
							<cfif canApprove>
								<option value="approve" style="color: white; background-color: ##00CCCC"<cfif isDefined('q_getThisVersion')><cfif q_getThisVersion.versionstatusid eq 100001> SELECTED</cfif></cfif>>Approved
							</cfif>
							<cfif canPublish>
								<option value="scheduleLive" style="color: white; background-color: ##993399"<cfif isDefined('q_getThisVersion')><cfif q_getThisVersion.versionstatusid eq 100004> SELECTED</cfif></cfif>>Scheduled
								<option value="makeLive" style="color: white; background-color: ##006600"<cfif isDefined('q_getThisVersion')><cfif q_getThisVersion.versionstatusid eq 100002> SELECTED</cfif></cfif>>Published
							</cfif>
							</select>
							<cfif NOT isDefined("SESSION.ReviewQueue")>
								<cfset SESSION.ReviewQueue = createObject("component","#APPLICATION.CFCPath#.reviewQueue")>	
							</cfif>
							<cfset ReviewQueue = SESSION.ReviewQueue>					
							<cftry>
								<cfif isDefined('instanceid')>
									<cfquery name="q_getThisVersionDirective" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
										SELECT versiondirectiveid
										FROM version
										WHERE instanceitemid = #instanceid# 
										AND formobjectitemid = #session.i3currenttool#
									</cfquery>
								</cfif>
								<cfset q_getVersionDirective = ReviewQueue.getDirectives()>
								<cfcatch type="database"></cfcatch>
							</cftry>
								<cfif isDefined('q_getVersionDirective')>
								<select id="versiondirectiveid" name="versiondirectiveid" style="font-size: 11px;">
									<option value="0">--Change directive --</option>
									<cfloop query="q_getVersionDirective">
										<option value="#q_getVersionDirective.versiondirectiveid#"<cfif isDefined('q_getThisVersionDirective') AND q_getThisVersionDirective.versiondirectiveid eq q_getVersionDirective.versiondirectiveid> selected</cfif>>#q_getVersionDirective.versiondirectivename#</option>
									</cfloop>
								</select>
								</cfif>
						</cfif>
						<!--- don't show if this is a new content element --->
						<cfif isDefined('instanceid')>
							<select name="version" class="LEselectMenu" onchange="changeVersion(this)">
								<option value="">View Version</option>
								<cfloop query="q_reviewQueue">
								<option title="#q_reviewQueue.label#" value="#q_reviewQueue.instanceitemid#" style="color: white; background-color: #q_reviewQueue.colorcode#;"<cfif isDefined('instanceid')><cfif q_reviewQueue.instanceitemid EQ instanceid> selected</cfif></cfif>><cfif Len(Trim(q_reviewQueue.label)) GT 50>#left(q_reviewQueue.label, 50)#...<cfelse>#q_reviewQueue.label#</cfif> #q_reviewQueue.version#</option>
								</cfloop>
							</select>
						</cfif>
						<input name="makeCopy" type="hidden" value="<cfif canEdit OR NOT isDefined('instanceid')>0<cfelse>1</cfif>">
					</td>
					<td valign="middle" bgcolor="##E5E7E9" width="190">
						<div id="LEbutton">
							<ul>
								<!--- Show save if user has permission or this is a new entry --->
								<cfif canEdit OR NOT isDefined('instanceid')><li><a href="javascript: fpSubmit();" style="background-image: url(#application.globalPath#/media/images/icon_save.gif);" title="Save">&nbsp;</a></li></cfif>
								<!--- Show copy if this is a not new entry --->
								<cfif isDefined('instanceid')><li><a href="javascript: setCopy();fpSubmit();" style="background-image: url(#application.globalPath#/media/images/icon_copy.gif);" title="Save as a new version">&nbsp;</a></li></cfif>
								<!--- Show publish toggle if user has permission or this is a new entry --->
								<cfif canPublish><li><a href="javascript: toggleCalendar();" style="background-image: url(#application.globalPath#/media/images/icon_schedule.gif);" title="Schedule this content to publish and/or expire at a future date">&nbsp;</a></li></cfif>
								<!--- Show cancel always --->
								<li><a href="javascript:<cfif isDefined('url.targetdiv')>window.opener.location=window.opener.location;window.close();<cfelse>location.href='#request.page#';</cfif>" style="background-image: url(#application.globalPath#/media/images/icon_cancel.gif);" title="Cancel this dialog and return to the previous screen without saving">&nbsp;</a></li>
								<!--- Show preview if we're in a pop-up --->
								<cfif isDefined('url.targetdiv') AND isDefined("application.wysiwyg") AND application.wysiwyg EQ "fckeditor"><li><a href="javascript: previewChanges();" style="background-image: url(#application.globalPath#/media/images/icon_preview.gif);" title="Preview">&nbsp;</a></li></cfif>
								<cfif  NOT isDefined("editInPlace") AND isDefined('instanceid')>					
									<cfset canAccessVersionMgt=0>
									<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#session.i3currenttool#" instanceid="#instanceid#">
									<cfif canDelete>
										<cfset canAccessVersionMgt = 1>
									</cfif>
									<cfif canAccessVersionMgt><li><a href="javascript:location.href='index.cfm?i3currenttool=119&manageVersions=yes&parentid=#q_getThisVersion.parentid#&formobjectid=#session.i3currenttool#';" style="background-image: url(#application.globalPath#/media/images/icon_manageVersions.gif);" title="Version Management">&nbsp;</a></li></cfif>
								</cfif>
							</ul>
						</div>
					</td>
					<td bgcolor="##E5E7E9" valign="middle" nowrap width="23"><img src="#application.globalPath#/media/images/rocketBug.gif" /></td>
					<td valign="top" width="9" background="#application.globalPath#/media/images/toolbarRight.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
				</tr>
				<tr>
					<td valign="top" width="9"><img src="#application.globalPath#/media/images/toolbarLeftBottom.gif" /></td>
					<td colspan="3" background="#application.globalPath#/media/images/toolbarBottom.gif"><img src="/media/images/spacer.gif" width="1" height="1" /></td>
					<td valign="top" width="9"><img src="#application.globalPath#/media/images/toolbarRightBottom.gif" /></td>
				</tr>
			</table>
		<cfelse>
			<cfif isDefined('REQUEST.admintemplate')><!--- ADMIN Buttonbar --->
				<div class="buttonBar"><cfif attributes.showClone AND request.q_getForm.singleRecord EQ false><input type="image" src="#application.globalPath#/media/images/btn_formCopy_off.png" name="Clone" id="Clone" value="Clone"></cfif><input type="image" src="#application.globalPath#/media/images/btn_formSave_off.png" name="#attributes.editbuttonname#" id="#attributes.editbuttonid#" #attributes.javascriptCall# <cfif len(attributes.editbuttontabindex)> tabindex="#attributes.editbuttontabindex#"</cfif> title="#attributes.editbuttonname#"<cfif len(attributes.javascriptCall)> #attributes.javascriptCall#</cfif>></div>
			<cfelse><!--- FRONTEND Buttonbar --->
				<cfif len(trim(attributes.submitbuttonimage))>
					<input type="image" class="#attributes.editbuttonClass#" src="/#attributes.submitbuttonimage#"<cfif len(attributes.javascriptCall)> #attributes.javascriptCall#</cfif>>
				<cfelseif len(attributes.javascriptCall)>
					<input type="button" value="#attributes.editbuttonValue#" class="#attributes.editbuttonClass#" #attributes.javascriptCall#>
				<cfelse>
					<input type="submit" value="#attributes.editbuttonValue#" class="#attributes.editbuttonClass#">
				</cfif>
			</cfif>
		</cfif>
	</cfcase>
	<cfcase value="0">
		<cfif isDefined('REQUEST.admintemplate')><!--- ADMIN Buttonbar --->
			<div class="buttonBar"><cfif attributes.showDelete><a href="##" onclick="document.getElementById('delete').submit();"><img src="#application.globalPath#/media/images/btn_formDelete_off.png" value="Delete this item" border="0" title="Delete this item" /></a><!--- <input type="image" src="#application.globalPath#/media/images/btn_formDelete_off.png" value="Delete this item" onclick="document.getElementById('delete').submit();"/> ---></cfif><cfif attributes.showClone AND request.q_getForm.singleRecord EQ false><input type="image" src="#application.globalPath#/media/images/btn_formCopy_off.png" name="Clone" id="Clone" value="Clone"></cfif><input type="image" src="#application.globalPath#/media/images/btn_formSave_off.png" name="#attributes.editbuttonname#" id="#attributes.editbuttonid#" #attributes.javascriptCall# <cfif len(attributes.editbuttontabindex)> tabindex="#attributes.editbuttontabindex#"</cfif> title="#attributes.editbuttonname#"></div>
		<cfelse><!--- FRONTEND Buttonbar --->
			<input type="submit" name="#attributes.editbuttonname#" id="#attributes.editbuttonid#" title="#attributes.editbuttonname#"  class="#attributes.editbuttonclass#" #attributes.javascriptCall# value="#attributes.editbuttonvalue#"<cfif len(attributes.editbuttontabindex)> tabindex="#attributes.editbuttontabindex#"</cfif>>		
		</cfif>
	</cfcase>
</cfswitch>
</cfoutput>
</cfif>
