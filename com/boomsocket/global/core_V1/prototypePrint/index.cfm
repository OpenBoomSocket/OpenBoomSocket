<!--- this code generates the printable prototype --->
<cfsavecontent variable="PTjs"><cfoutput>
<script type="text/javascript">
	window.onload=function(){
	document.getElementById('prototypeblock').style.display = 'none';
	document.getElementById('devNotesBlock').style.display = 'none';
	}
	
	/* Prototype Status links- change location of opener window */
	/*list based
	function openInWindow(pageURL){
		window.opener.location = pageURL;
	}	*/
	/*select based
	function openInWindow(formName){
		var dropdownID = formName+'_statusPages';		
		window.opener.location = document.getElementById(dropdownID).value;
	}*/
</script>
<!--- clear out any bg/font styles set in site.css --->
<style type="text/css">
	body{
		background-image:none;
		background-color:##fff;
		color:##000;
	}
</style>
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#PTjs#">

<cfset ignorePageList = "error404.cfm,prototypePrint.cfm,friendlyDownload.cfm"> 

<!--- use sitemap cfc to get sections--->
<cfscript>
	sitemap = CreateObject('component', '#APPLICATION.CFCPath#.sitemap');
	SectionPaths = sitemap.getAllSectionPaths();
	prototype = CreateObject('component', '#APPLICATION.CFCPath#.prototyping');	
</cfscript>
<cftry>
	<cfset q_getPageStatusItems = prototype.getPageStatus()>
	<cfcatch type="database"></cfcatch>
</cftry>

<cfoutput><div id="PTnotes">
<div id="PTinfo">#application.sitename#: Prototype Notes: #DateFormat(Now(),'mmmm d, yyyy')#</div></cfoutput>

<!--- Output pages by status--->
<cfif isDefined('q_getPageStatusItems') AND q_getPageStatusItems.recordcount>
	<cfoutput><h1 class="PTSection">Pages by Status</h1></cfoutput>
	<cfloop query="q_getPageStatusItems">
		<cftry>
			<cfset q_getPagesByStatus = prototype.getPagesByStatus(prototypepagestatusid=q_getPageStatusItems.prototypepagestatusid,ignorePages=ignorePageList)>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cfset thiscolor = q_getPageStatusItems.highlightcolor>
		<cfif thiscolor eq 'fff' OR thiscolor eq 'ffffff'>
			<cfset thiscolor = '333'>
		</cfif>
		<cfoutput><h2 style="color:###thiscolor#">#q_getPageStatusItems.prototypepagestatusname# 
			<cfif q_getPageStatusItems.filename neq "" AND FileExists("#application.installPath#\uploads\#q_getPageStatusItems.foldername#\#q_getPageStatusItems.filename#")>
				<img src="#q_getPageStatusItems.iconPath#" border="0" />
			</cfif></h2></cfoutput>
		<cfif isDefined('q_getPagesByStatus') AND q_getPagesByStatus.recordcount>
			<cfoutput query="q_getPagesByStatus" group="sitesectionid">
				<!--- select based 
				<form name="#q_getPagesByStatus.sitesectionname#">
				<p><div><strong>#q_getPagesByStatus.sitesectionlabel#</strong></div>
				<div>				
				<select id="#q_getPagesByStatus.sitesectionname#_statusPages" name="#q_getPagesByStatus.sitesectionname#_statusPages" onchange="javascript:openInWindow('#q_getPagesByStatus.sitesectionname#');" class="prototypeinput">
				<cfoutput>
					<option value="/#q_getPagesByStatus.sitesectionname#/#q_getPagesByStatus.pagename#">#q_getPagesByStatus.pagetitle#</option>
				</cfoutput>
				</select></div></p></form>--->
				<!--- list based --->
				<div><strong>#q_getPagesByStatus.sitesectionlabel#</strong></div>
				<ul>
				<cfoutput>
					<li><a href="###q_getPagesByStatus.pageid#">#q_getPagesByStatus.pagetitle#</a></li>
				</cfoutput>
				</ul> 
			</cfoutput>
		<cfelse>
			<cfoutput><p>There are no pages set to this status.</p></cfoutput>
		</cfif>
	</cfloop> 
</cfif>


<!--- Output pages w/ notes --->
<!--- loop through each section --->
<cfloop list="#SectionPaths#" index="i">
	<cfset thisSectionPath="#listFirst(i,":")#">
	<cfset thisSectionLabel="#listGetAt(i,2,":")#">
	<cfset thisSectionId="#listLast(i,":")#">
	<cfset isTopLevelSection = 0>
	<cfif #ListLen(thisSectionPath, "\")# LTE 1><cfset isTopLevelSection = 1></cfif>
	<cfif isTopLevelSection neq 1>
		<cfset parentInfo = sitemap.getParentSection(sectionid=thisSectionId)>
		<cfset thisSectionLabel=parentInfo.sitesectionname & ": #listGetAt(i,2,":")#">
	</cfif>
	<cfoutput><h1 class="PTSection">#thisSectionLabel#</h1></cfoutput>
	<!--- loop through each page--->
	<cfset pages = sitemap.getPages(sectionid=thisSectionId)>
	<cfloop query="pages">
		<cfoutput><div class="PTPageBlock"></cfoutput>
		<cfset q_getNotes = prototype.getNotes(pageid=pages.pageid,pageSpecificOnly=true)>
		<cfif NOT listFindNoCase(ignorePageList,pages.pagename)>
			<cftry>
				<cfset q_getThisPageStatus = prototype.getPageStatus(pageid=pages.pageid)>
				<cfcatch type="database"></cfcatch>
			</cftry>
			<cfoutput><h2 class="PTpage"><a name="#pages.pageid#"></a>#pages.pagetitle#
			<cfif isDefined('q_getThisPageStatus') AND q_getThisPageStatus.recordcount AND q_getThisPageStatus.filename neq "" AND FileExists("#application.installPath#\uploads\#q_getThisPageStatus.foldername#\#q_getThisPageStatus.filename#")>
				<img src="#q_getThisPageStatus.iconPath#" border="0" />
			</cfif>
			</h2></cfoutput>
			<!--- output PT Notes for this page--->
			<cfif NOT q_getNotes.recordcount>
				<cfoutput><div class="PTnoteContainer">Currently there are no prototype notes associated with this page.</div></cfoutput>
			</cfif>
			<cfset counter=1>
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
				<div class="PTcategory" <cfif Len(hlColor)>style="font-size:14px;border-bottom:1px solid;"></cfif>#q_getNotes.prototypenotecategoryname#</div>
				<cfoutput>
				<div class="PTnoteContainer"><table border="0" cellpadding="0" cellspacing="5"><tr><td valign="top"><span class="PTnoteNum"><cfif displaymethod EQ "bulleted">&##8226;<cfelse>#counter#.</cfif></span></td><td valign="top"><span class="PTnote">#q_getNotes.noteBody#</span> <div class="dateMod">#dateFormat(q_getNotes.datemodified,"mm/dd/yyyy")#</div></td></tr></table></div>
				<cfset counter=counter+1>
				</cfoutput>
			</cfoutput>
		</cfif>
		<cfoutput></div></cfoutput>
	</cfloop>
</cfloop>
<!--- output sitewide only--->
<cfset q_getSitewideNotes = prototype.getNotes(pageid=pages.pageid,sitewideOnly=true)>
<cfoutput>
<h1 class="PTSection">Sitewide Notes</h1>
<cfset counter=1>
<cfloop query="q_getSitewideNotes">
	<div class="PTnoteContainer"><table border="0" cellpadding="0" cellspacing="5"><tr><td valign="top"><span class="PTnoteNum">#counter#.</span></td><td valign="top"><span class="PTnote">#q_getSitewideNotes.noteBody#</span> <div class="dateMod">#dateFormat(q_getSitewideNotes.datemodified,"mm/dd/yyyy")#</div></td></tr></table></div><cfset counter=counter+1>
</cfloop>
</div>
<div id="ClientNoteContainer"><h3>Client Notes:</h3></div>
<div style="clear:both;">&nbsp;</div>
</cfoutput>
		
	
