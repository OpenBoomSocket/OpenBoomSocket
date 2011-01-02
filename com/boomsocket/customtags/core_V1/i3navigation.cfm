<cfsetting enablecfoutputonly="Yes">
<cfif thisTag.executionmode EQ "start">
	<cfparam name="attributes.navigationID" default="0">
	<cfparam name="attributes.editmode" default="0">
	<cfparam name="attributes.returnType" default="">
	<cfparam name="attributes.wraplevel" default="0">
	<cfparam name="attributes.thisPageID" default="0">
	<cfparam name="attributes.topOnly" default="0">
	<cfparam name="attributes.classBase" default="">
	<cfparam name="attributes.showSingleSection" default="0">
	<cfparam name="attributes.alphaordering" default="0">
	<cfparam name="attributes.active" default="1">
	<cfparam name="attributes.textOnly" default="0">
	<cfparam name="attributes.subsOnly" default="0">
	<cfparam name="attributes.showAllSubs" default="0">
	<cfparam name="attributes.currentNavID" default="0">
	<cfif NOT attributes.navigationID>
		<h3>Error</h3>
		You must provide a navigationID when calling this custom tag!
		<cfexit method="EXITTAG">
	</cfif>
	<cfset NavObj = createObject("component","#APPLICATION.CFCPath#.navigation")>	
	<cfif NOT isDefined('application.allNavSettings') OR isDefined("URL.initializeApp")>
		<cfset application.allNavSettings = NavObj.getAllNavSettings()>
	</cfif>
	<cfset q_getNavSettings = NavObj.getNavSettings(q_allNavSettings=application.allNavSettings,navigationID=attributes.navigationID)>
	<cfif NOT q_getNavSettings.recordcount>
		<h3>Error</h3>
		The NAVIGATIONID you passed does not find a match in the database.
		<cfexit method="EXITTAG">
	</cfif>
<!--- Query for navigation images --->
	<cfif NOT isDefined('application.allNavigation') OR isDefined("URL.initializeApp")>
		<cfset application.allNavigation = NavObj.getAllNavigation()>
	</cfif>
	<cfif (q_getNavSettings.groupType EQ 'Image Rollovers') AND (attributes.editmode EQ 1)>
		You are in image rollover edit more. You will need to use the nav manager to add pages and subsections<br>
	</cfif>
	<cfif isDefined('attributes.grouptype')>
		<cfset q_getNavSettings.groupType = attributes.grouptype>
	</cfif>
	<cfswitch expression="#q_getNavSettings.groupType#">
		<cfcase value="DHTML">
			<!--- OS_Issue
				This is where the opencube stuff lived but we had to remove it.
				It called the custom tag dhtmlmenu.cfm which has been removed.
			 --->
		</cfcase>
		<cfcase value="Image Rollovers">
			<cfset q_getNavigation = NavObj.getNavigation(navigationID=attributes.navigationID,navType="Image Rollovers",active=attributes.active)>
			<cfsavecontent variable="FcnRollOver">
			<script type="text/javaScript">
				function RollOver(imgSrc,name,over)
				{
					if(window.document.images) 
					{
						if (over)
							window.document.images[name].src=imgSrc;
						else
							window.document.images[name].src=imgSrc;
					}
				}
			</script></cfsavecontent><cfhtmlhead text="#FcnRollOver#"><cfsilent><cfset thisNavString="">
				<cfloop query="q_getNavigation">
					<cfif attributes.editmode>
						<cfset thisLink = "#request.page#?instanceid=#q_getNavigation.dynamicnavigationid#">
					<cfelseif len(trim(q_getNavigation.href))>
						<cfset thisLink = q_getNavigation.href>
					<cfelseif len(trim(q_getNavigation.sitesectionid))>
						<cfset thisLink = "/#application.getSectionPath(q_getNavigation.sitesectionid,"true","/")#/"&q_getNavigation.pagename><cfelse><cfset thisLink = "##">
					</cfif>
					<cfif isDefined("request.thispageid") AND ((request.thispageid EQ q_getNavigation.pageid) OR (isDefined('q_getNavigation.siteSectionname') AND request.section EQ q_getNavigation.siteSectionname)) AND isDefined('q_getNavigation.imageAT') AND len(q_getNavigation.imageAT)>
						<cfset thisOffState=q_getNavigation.atState>
						<cfset thisOnState=q_getNavigation.atState>
					<cfelse>
						<cfset thisOffState=q_getNavigation.offState>
						<cfset thisOnState=q_getNavigation.onState>
					</cfif>
					<cfset linkTarget="">
					<cfset thisName="img#createUUID()#">
					<cfif len(q_getNavigation.target)><cfset linkTarget=' target="#q_getNavigation.target#"'></cfif>
			<cfset thisNavString=trim(thisNavString)&"<a#linkTarget# href=""#thisLink#"" onmouseover=""RollOver('#thisOnState#','#thisName#',true);"" onmouseout=""RollOver('#thisOffState#','#thisName#',false);""><img src=""#thisOffState#"" border=""0"" title=""#q_getNavigation.name#"" alt=""#q_getNavigation.name#"" name=""#thisName#""></a>"></cfloop></cfsilent><cfoutput>#trim(thisNavString)#</cfoutput>
		</cfcase>
		<cfcase value="Text Only">
			<cfset q_getNavigation = NavObj.getNavigation(navigationID=attributes.navigationID, navType="Text Only",active=attributes.active)>
			<cfset thisNavString="">
			<cfloop query="q_getNavigation">
				<cfset atstring="">
				<!--- test for at state --->
				<cfif (isDefined("request.thispageid") AND (request.thispageid EQ q_getNavigation.pageid)) OR (isDefined('q_getNavigation.siteSectionname') AND request.section EQ q_getNavigation.siteSectionname)>
					<cfset atstring="_at">
				</cfif>
				<cfif attributes.editmode>
					<cfset thisLink = "#request.page#?instanceid=#q_getNavigation.dynamicnavigationid#">
				<cfelseif len(trim(q_getNavigation.href))>
					<cfset thisLink = q_getNavigation.href>
				<cfelseif len(trim(q_getNavigation.sitesectionid))>
					<cfset thisLink = "/#application.getSectionPath(q_getNavigation.sitesectionid,"true","/")#/"&q_getNavigation.pagename>
				<cfelse>
					<cfset thisLink = "##">
				</cfif>
				<cfif len(q_getNavigation.target)>
					<cfset thisTarget=q_getNavigation.target>
				<cfelse>
					<cfset thisTarget="">
				</cfif>
				<cfif findNoCase('<img',q_getNavSettings.textDelimeter)>
					<cfset thisDelimiter="#repeatString(q_getNavSettings.textDelimeter,q_getNavSettings.delimeterCount)#">
				<cfelseif q_getNavSettings.textDelimeter NEQ "">
					<cfif q_getNavSettings.vertical eq 1>
						<cfset thisDelimiter="<br/>&#repeatString(q_getNavSettings.textDelimeter,q_getNavSettings.delimeterCount)#;<br/>">
					<cfelse>
						<cfset thisDelimiter="&nbsp;&#repeatString(q_getNavSettings.textDelimeter,q_getNavSettings.delimeterCount)#;&nbsp;">
					</cfif>
				<cfelse>
					<cfif q_getNavSettings.vertical eq 1>
						<cfset thisDelimiter="<br/>">
					<cfelse>
						<cfset thisDelimiter="&nbsp;&nbsp;&nbsp;">
					</cfif>
				</cfif>
				<cfsavecontent variable="thisStyle"><cfoutput><cfif len(q_getNavSettings.settingclass)> class="#q_getNavSettings.settingclass##atstring#"<cfelse> style="<cfif len(q_getNavSettings.fontsize)>font-size: #q_getNavSettings.fontsize#;</cfif><cfif len(q_getNavSettings.fontfamily)>font-family: #q_getNavSettings.fontfamily#;</cfif><cfif len(q_getNavSettings.fontweight)>font-weight: #q_getNavSettings.fontweight#;</cfif><cfif len(q_getNavSettings.fontstyle)>font-style: #q_getNavSettings.fontstyle#;</cfif><cfif len(q_getNavSettings.textdecoration)>text-decoration: #q_getNavSettings.textdecoration#;</cfif><cfif len(q_getNavSettings.fontcolor)>color: #q_getNavSettings.fontcolor#;</cfif>"</cfif></cfoutput></cfsavecontent>
				<cfif len(thisTarget)>
					<cfset thisNavString=thisNavString&"<a href=""#thisLink#"" target=""#thisTarget#""#thisStyle#>#q_getNavigation.name#</a>">
				<cfelse>
					<cfset thisNavString=thisNavString&"<a href=""#thisLink#""#thisStyle#>#q_getNavigation.name#</a>">
				</cfif>
				<cfif q_getNavigation.currentrow NEQ q_getNavigation.recordcount>
					<cfset thisNavString=thisNavString&thisDelimiter>
				</cfif>
			</cfloop>
			<cfoutput><div<cfif len(q_getNavSettings.textmenualignment)> align="#q_getNavSettings.textmenualignment#"</cfif><cfif len(q_getNavSettings.settingclass)> class="#q_getNavSettings.settingclass#" test="erj"<cfelseif isDefined('thisStyle')>#thisStyle# test="bdw"</cfif>>#thisNavString#</div></cfoutput>			
		</cfcase>
		<cfcase value="Listing">
			<cfif NOT attributes.editmode AND isDefined("session.user.liveEdit")> 
				<cfoutput><div id="#attributes.classBase#_PTnavContainer" <cfif session.user.liveEdit>onmouseover="getElementById('#attributes.classBase#_navEditBtn').style.display='block';getElementById('#attributes.classBase#_PTnavContainer').style.border='1px dashed ##999999';getElementById('#attributes.classBase#_PTnavContainer').style.backgroundColor ='##dddddd';" onmouseout="getElementById('#attributes.classBase#_navEditBtn').style.display='none';getElementById('#attributes.classBase#_PTnavContainer').style.border='none';getElementById('#attributes.classBase#_PTnavContainer').style.backgroundColor='transparent';"</cfif>><div id="#attributes.classBase#_navEditBtn" style="display:none;">#application.showEditInstanceButton(application.tool.navManager,attributes.navigationID,"Edit This navigation","pageID=#attributes.thisPageID#")#</div></cfoutput>
			</cfif>
			<cfscript>
				navObj = CreateObject('component','#application.cfcpath#.navigation');
				navWrapperObj = CreateObject('component','#application.cfcpath#.util.navwrapper');
				thisNavQuery = navObj.getNavigation(navType='Listing',navigationID=attributes.navigationID,alphaordering=attributes.alphaordering,active=attributes.active);
				if(attributes.currentNavID){
					thisNavId = attributes.currentNavID;
				}else{
					thisNavId = navObj.getNavIdFromPageID(currentpageid=attributes.thisPageID,q_data=thisNavQuery);
				}
				if(attributes.navigationID){
					thisNavParent = navObj.getParentFromPageID(attributes.thisPageID,attributes.navigationID);
				}else{
					thisNavParent = navObj.getParentFromPageID(attributes.thisPageID);
				}
				if(attributes.showSingleSection){
					if(thisNavId){
						thisNavOutput = navWrapperObj.doWrapUL(q_querydata=thisNavQuery,wraplevel=attributes.wraplevel,groupID=attributes.navigationID, currentParentID=thisNavParent, currentNavID=thisNavId, topOnly=attributes.topOnly,classBase=attributes.classBase,singleSectionID=navObj.getSectionID(attributes.thisPageID), editmode=#attributes.editmode#,alphaordering=attributes.alphaordering, textOnly=#attributes.textOnly#, subsOnly=#attributes.subsOnly#, showAllSubs=#attributes.showAllSubs#);	
					}else{
						thisNavOutput = navWrapperObj.doWrapUL(q_querydata=thisNavQuery,wraplevel=attributes.wraplevel,groupID=attributes.navigationID, currentParentID=thisNavParent, currentPageID=attributes.thisPageID, topOnly=attributes.topOnly,classBase=attributes.classBase,singleSectionID=navObj.getSectionID(attributes.thisPageID), editmode=#attributes.editmode#,alphaordering=attributes.alphaordering, textOnly=#attributes.textOnly#, subsOnly=#attributes.subsOnly#, showAllSubs=#attributes.showAllSubs#);
					}
				}else{
					if(thisNavId){
						thisNavOutput = navWrapperObj.doWrapUL(q_querydata=thisNavQuery, wraplevel=attributes.wraplevel, groupID=attributes.navigationID, currentParentID=thisNavParent, currentNavID=thisNavId, topOnly=attributes.topOnly, classBase=attributes.classBase, editmode=#attributes.editmode#,alphaordering=attributes.alphaordering, textOnly=#attributes.textOnly#, subsOnly=#attributes.subsOnly#, showAllSubs=#attributes.showAllSubs#);
					}else{
						thisNavOutput = navWrapperObj.doWrapUL(q_querydata=thisNavQuery, wraplevel=attributes.wraplevel, groupID=attributes.navigationID, currentParentID=thisNavParent, currentPageID=attributes.thisPageID, topOnly=attributes.topOnly, classBase=attributes.classBase, editmode=#attributes.editmode#,alphaordering=attributes.alphaordering, textOnly=#attributes.textOnly#, subsOnly=#attributes.subsOnly#, showAllSubs=#attributes.showAllSubs#);
					}
				}
			</cfscript>
			<cfoutput><div id="#attributes.classBase#">#thisNavOutput#</div><cfif NOT attributes.editmode AND isDefined("session.user.liveEdit")></div></cfif></cfoutput>
		</cfcase>
	</cfswitch>
</cfif>