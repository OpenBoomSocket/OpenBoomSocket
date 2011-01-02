<cfif thistag.executionmode is "START">
<script type="text/javascript">
	function pageStatusUpdate(){
		document.pageStatus.submit();
		//document.getElementById('prototypeblock').style.backgroundColor = '#ff0000';
	}
</script>
<cfscript>
	prototype = CreateObject('component','#application.cfcpath#.prototyping');
	//CMC Mod 7/12/06: only show sitewidenotes on home page
	if(request.pagepath eq '/home/index.cfm'){
		q_getNotes = prototype.getNotes(pageid=REQUEST.thisPageID);
	}else{
		q_getNotes = prototype.getNotes(pageid=REQUEST.thisPageID,pageSpecificOnly=1);
	}
	SitePlanFolder = prototype.getSitePlanFolder();
	FlowChartFileName = prototype.getFlowChartName(REQUEST.thisPageID);
</cfscript>
<!--- if page status form submitted, update --->
<cfif isDefined('form.prototypepagestatusid') AND Trim(form.prototypepagestatusid)>
	<!--- Check to see if the new prototyping page status feature exists or not. --->
	<cfif IsDefined('application.tool.prototypepagestatus')>
		<cfset updateStatus = prototype.updatePageStatus(prototypepagestatusid=Trim(form.prototypepagestatusid), pageid=REQUEST.thisPageID)>
	</cfif> 
</cfif>
<cfif isDefined("session.user.liveEdit") AND session.user.accesslevel EQ 1>
	<!--- Check to see if the new prototyping page status feature exists or not. --->
	<cfif IsDefined('application.tool.prototypepagestatus')>
		<cfset q_getPageStatusItems = prototype.getPageStatus()>
		<cfset q_getThisPageStatus = prototype.getPageStatus(pageid=REQUEST.thispageid)>
	</cfif>
</cfif>

	<cfoutput>
		<div id="prototypeblock" <cfif isDefined('APPLICATION.usescontentmapping') AND APPLICATION.usescontentmapping AND isDefined("session.user.liveEdit") AND isDefined('SESSION.showMappingButton') AND SESSION.showMappingButton> style="top: 30px;" </cfif><cfif isDefined('q_getThisPageStatus') AND q_getThisPageStatus.recordcount>style="background-color:###q_getThisPageStatus.highlightcolor#"</cfif>>
			<div id="prototypebar"><a href="javascript:void(0);" onclick="showHide();" name="showHideButton"><img src="/i3Global/media/images/prototypingNoteLeft.gif" width="211" height="18" border="0"></a><a href="javascript:void(0);"><img src="/i3Global/media/images/prototypingNoteGloss.gif" width="26" height="18" border="0" onclick="javascript:window.open('/admintools/help.cfm','helpwin','toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=700,height=600')"></a><a href="javascript:void(0);" onclick="showHide();" name="showHideButton"><img src="/i3Global/media/images/prototypingShowArrow.gif" width="33" height="18" border="0" id="showArrow"><img src="/i3Global/media/images/prototypingHideArrow.gif" width="33" height="18" border="0" id="hideArrow" style="display:none;"></a></div>
			<div id="prototypecontent"> 
		<table width="100%" id="noteTable" border="0">
			<tr>
			<cfif isDefined("session.user.liveEdit") AND session.user.accesslevel EQ 1>				
				<cfif isDefined('q_getPageStatusItems') AND q_getPageStatusItems.recordcount>
				<form name="pageStatus" method="post" action="#request.thispage#?#cgi.QUERY_STRING#">
					<td valign="top">
						<select name="prototypepagestatusid" onchange="javascript:pageStatusUpdate();" class="prototypeinput">
							<cfloop query="q_getPageStatusItems"> 
								<option value="#q_getPageStatusItems.prototypepagestatusid#" <cfif isDefined('q_getThisPageStatus') AND q_getThisPageStatus.prototypepagestatusid eq q_getPageStatusItems.prototypepagestatusid>selected</cfif>>#Left(q_getPageStatusItems.prototypepagestatusname,16)#</option>
							</cfloop>
						</select>
					</td>
				</form>
				</cfif>
			</cfif>
				<td class="addNote"><cfif isDefined("session.user.liveEdit") AND session.user.accesslevel EQ 1><a href="/admintools/main.cfm?&displayForm=1&targetPageID=#request.thispageid#&targetPage=#CGI.server_name##CGI.script_name#&i3currenttool=#application.tool.prototypeNote#&DISPLAYFORM=1&formstep=showform" target="_blank" onclick="javascript: window.open('/admintools/main.cfm?&displayForm=1&targetPageID=#request.thispageid#&targetPage=#CGI.server_name##CGI.script_name#&i3currenttool=#application.tool.prototypeNote#&DISPLAYFORM=1&formstep=showform','editWindow', 'width=600,height=625,scrollbars=yes,resizable=yes'); return false;">Add A Note</a> | </cfif><a href="/home/prototypePrint.cfm" target="_blank" onclick="javascript: window.open('/home/prototypePrint.cfm','printWindow', 'width=600,height=625,scrollbars=yes,resizable=yes,menubar=1'); return false;">Printable</a>
				<cfif FlowChartFileName neq "" AND FileExists("#application.installPath#\uploads\#SitePlanFolder#\#FlowChartFileName#")>
					<div><strong><a href="/uploads/#SitePlanFolder#/#FlowChartFileName#" target="_blank">Planning Attachment</a></strong></div>
				</cfif>
				</td>
			</tr>
		</table>
	</cfoutput>
	<table width="100%" id="noteTable" border="0">
		<cfoutput query="q_getNotes" group="prototypenotecategoryname">
			<cfif isDefined("q_getNotes.highlightcolor") AND len(q_getNotes.highlightcolor)>
				<cfset hlColor = q_getNotes.highlightcolor>
			<cfelse>
				<cfset hlColor = "">
			</cfif>
			<cfif isDefined("q_getNotes.displaymethod") AND len(q_getNotes.displaymethod)>
				<cfset displaymethod = q_getNotes.displaymethod>
			<cfelse>
				<cfset displaymethod = "">
			</cfif>
		  <tr>
			<td colspan="2" style="background-color:#hlColor#" class="<cfif q_getNotes.class neq "">#q_getNotes.class#<cfelse>categoryHeading</cfif>">#q_getNotes.prototypenotecategoryname#</td>
		  </tr>
		  <cfoutput>
		  	<cfset TestScriptFileName = "">
			<cfif q_getNotes.testscriptPDF neq "">
				<cfset TestScriptFileName = prototype.getTestScriptName(q_getNotes.prototypenoteid)>
			</cfif>
			<cfif displaymethod EQ "bulleted">
			  <tr>
				<td class="noteTableCol1">
					&##8226;
				</td>
				<cfelse>
				<tr id="note_#q_getNotes.currentrow#" onmouseover="javascript:showContext(true,this.id);" onmouseout="javascript:showContext(false,this.id);">
				<td class="noteTableCol1">
					#q_getNotes.currentrow#.
				</td>
				</cfif>
				<td class="noteTableCol2">#q_getNotes.noteBody# <div class="dateMod">#dateFormat(q_getNotes.datemodified,"mm/dd/yyyy")#</div></td>
			  </tr>
				<cfif isDefined("session.user.liveEdit")> 
					<tr>
						<td colspan="2" class="editNoteBar">
							#application.showEditInstanceButton(application.tool.prototypenote,q_getNotes.prototypenoteid,"Edit This Note","note_#q_getNotes.prototypenoteid#")# 
						<cfif TestScriptFileName neq "" AND FileExists("#application.installPath#\uploads\#SitePlanFolder#\#TestScriptFileName#")>
							<br />
							<strong><a href="/uploads/#SitePlanFolder#/#TestScriptFileName#" target="_blank">Test Script</a></strong><br />
							<strong>Tested:</strong> <cfif q_getNotes.testphase neq "" AND q_getNotes.testphase><img src="#application.globalPath#/media/images/icon_complete.gif" width="11" height="12" border="0"><cfelse><img src="#application.globalPath#/media/images/icon_incomplete.gif" width="12" height="11" border="0"></cfif> 
							<cfif q_getNotes.testphase neq "" AND q_getNotes.testphase>
								<br  /><strong>Tested By:</strong> #q_getNotes.testedby#
							</cfif>
						</cfif>
						</td>
					</tr>
				</cfif>
			</cfoutput>
			<cfif isDefined("session.user.name") AND q_getNotes.prototypenotecategoryname eq "Questions for Client">
				<tr>
					<td colspan="2" align="center"><a href="javascript:void(0);" onclick="showHideDevNotes();" style="text-decoration:none"><strong>[ Respond in Open Discussion ]</strong></a></td>
				</tr>
			</cfif>
		</cfoutput>
		<cfoutput>
		</table>
		</div></cfoutput>
		<cfset ignorePageList = "error404.cfm,prototypePrint.cfm,friendlyDownload.cfm">
		<!--- Check to see if the new prototyping page status feature exists or not. --->
		<cfif IsDefined('application.tool.prototypepagestatus')>
			<cfset q_getPTNav = prototype.getPagesForPTNav(ignorepages=ignorePageList)>
		</cfif>
		<cfif isDefined('q_getPTNav') AND q_getPTNav.recordcount>		
			<cfoutput><div id="prototypeNavDD">
				<select name="prototypeNavSelect" id="prototypeNavSelect" class="prototypeinput" onchange="javascript:window.location = this.value;"></cfoutput>
					<cfoutput query="q_getPTNav" group="sitesectionname">
						<option value="##"><strong>#Left(q_getPTNav.sitesectionlabel,50)#</strong></option>
						<cfoutput>
							<cfset fontColor = "000">
							<cfif q_getPTNav.highlightcolor eq "000" OR q_getPTNav.highlightcolor eq "000000" OR q_getPTNav.highlightcolor eq "990000" OR q_getPTNav.highlightcolor eq "900" OR q_getPTNav.highlightcolor eq "660066">
								<cfset fontColor = "fff">
							</cfif>
							<option value="/#q_getPTNav.sitesectionname#/#q_getPTNav.pagename#" style="background-color: ###q_getPTNav.highlightcolor#; color: ###fontColor#" <cfif request.thispageid eq q_getPTNav.pageid>selected</cfif>>&nbsp;&nbsp;&nbsp;#Left(q_getPTNav.pagetitle,47)#</option>
						</cfoutput>
					</cfoutput>
				<cfoutput></select>
			</div></cfoutput>
		</cfif>
	<cfoutput></div></cfoutput>
</cfif>