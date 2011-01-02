<!--- 
This custom tag's purpose is to construct pages by including the appropriate
files and template.
 --->
<cfif thisTag.executionMode EQ "start">
<cfsilent>
	<!--- USE JS to determine if in admintools (can't use cgi.http_referrer b/c when navigate w/in iframe, referrer is no longer liveEditMain.cfm (need to finish) 
	<script type="text/javascript">
		
	</script>
	
	<!--- Turn live edit off (only on in /admintools/liveEditMain.cfm) ---> 
	<cfif NOT FindNoCase('liveEditMain.cfm',#CGI.HTTP_REFERER#)>
		<cflock scope="SESSION" timeout="5" type="EXCLUSIVE">
			<cfset session.user.liveEdit=0>
		</cflock>
	</cfif>--->
	
	<cfscript>
	SiteMetaID="100000";
	// Set request scope vars for this page (thispage, pagepath)
	if (isDefined("attributes.pagepath")){
		request.thispage=listLast(attributes.pagepath,'/');
		request.pagepath=attributes.pagepath;
	}else{
		request.thispage=listLast(CGI.SCRIPT_NAME,'/');
		request.pagepath=CGI.SCRIPT_NAME;
	}
	// init pageConstructor cfc
	pageConstructor=createObject('component','#APPLICATION.cfcpath#.pageconstructor').init(thispage=request.thispage,filepath=request.pagepath);
	// pageConstructor cfc auto-inits pageid, set it to request scope
	request.thispageid = pageConstructor.getPageid();
	// Build application query for all page construction data
	if (NOT isDefined("application.q_getpageInfoload") OR isDefined("URL.initializeApp")){
		application.q_getpageInfoload = pageConstructor.getAllPageInfo();	
	}
	// get construction info for this page
	q_getpageInfo=pageConstructor.getThisPageInfo(application.q_getpageInfoload);
	//CMC MOD 05/22/06- add sitesectionid to request scope
	if (isDefined('q_getpageInfo.sitesectionid') AND isNumeric(q_getpageInfo.sitesectionid)){
		request.sitesectionid = q_getpageInfo.sitesectionid;
	}
	// Determine what template to use
	if (len(q_getpageInfo.templateid)){
		thisTemplateid=q_getpageInfo.templateid;
	}else if(len(q_getpageInfo.sectiontemplateid)){
		thisTemplateid=q_getpageInfo.sectiontemplateid;
	}else{
		thisTemplateid=0;
	}
	</cfscript>	
	<!--- CMC MOD 10/30/2007: If no page was found and APPLICATION.missingPagePath has a value, redirect --->
	<cfif q_getpageInfo.recordcount eq 0 AND isDefined('APPLICATION.missingPagePath') AND Len(APPLICATION.missingPagePath)>
		<cflocation url="#APPLICATION.missingPagePath#">
	</cfif>
	<!--- Read in template file --->
	<cfsavecontent variable="templatefile">
		<cfoutput>
			<cfif q_getpageInfo.recordcount>
				<cfinclude template="/#application.sitemapping#/templates/#q_getpageInfo.templatefilename#">
			<cfelse>
				<cfinclude template="/#application.sitemapping#/templates/default.cfm">
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<!--- Grab Page Components --->	
	<!--- loop thru and get the var for each container for this page --->
	<cfloop query="q_getpageInfo">
    	<!--- Initialze the includeHandler to blank to prevent it from duplicating --->
    	<cfset includeHandler="">
		<cfset request.thisObjectid=q_getpageInfo.contentobjectid>
		<cfset session.containerid=q_getpageInfo.containerid>
		<cfsavecontent variable="thisContainerOutput"><cfsetting enablecfoutputonly="Yes">
			<!--- include based display --->
			<cfif len(q_getpageInfo.customInclude)>
            	<cfset includeHandler="includes/#q_getpageInfo.customInclude#">
			<!--- cfc based display (also content elements and front end forms) --->
			<cfelse>
				<cfif q_getpageInfo.displayObjectID EQ 100>
                    <cfinvoke component="#application.CFCPath#.getContentObject" 
                        method="getContent" 
                        returnvariable="rtn_getContent">
                    </cfinvoke>
                    <cfoutput>#rtn_getContent#</cfoutput>
				<cfelseif q_getpageInfo.displayObjectID EQ 102>
                    <cfinvoke component="#application.CFCPath#.invokeFormProcess" method="getFormObject" returnvariable="rtn_getFormObject">
                        <cfinvokeargument name="formObjectID" value="#q_getpageInfo.formObjectID#">
                    </cfinvoke>
                    <cfoutput>#rtn_getFormObject#</cfoutput> 
				<cfelse>
	                <cfset includeHandler="displayhandlers/#q_getpageInfo.invokefilename#">
				</cfif>
			</cfif>
			<cfif IsDefined('includeHandler') AND Len(Trim(includeHandler)) AND fileExists("#application.installpath#\#includeHandler#")>
				<cfinclude template="/#application.sitemapping#/#includeHandler#">
			<cfelse>
				<cfif request.debug><h3>Data Driven Display /#application.sitemapping#/#includeHandler# NOT found!</h3></cfif>
			</cfif>
		</cfsavecontent>
		<!--- init content object --->
		<cfset ContentObject = createObject('component','#APPLICATION.cfcpath#.getContentObject')>
	<!--- if we are in edit mode, call the CFC and add the edit form to the page --->
		<!--- if this container has a contentobject, does its parent match the one in the url? --->
		<cfset parentsMatch = false>
		<cfif isDefined('url.contentobjectid') AND request.thisObjectid NEQ ''>
			<cfset parentsMatch = pageConstructor.parentsMatch(url.contentobjectid,request.thisObjectid)>
		</cfif>
		<!--- we are editing content and this is the container it is assigned to --->
		<cfif isDefined("editInPlace") AND parentsMatch EQ true>
			<!--- Determine which flavor of WYSIWYG editor to use --->
			<cfif isDefined("application.wysiwyg") AND application.wysiwyg EQ "ewebeditpro">
				<cfset getContentObjectMethod="editInPlaceEWE">
			<cfelseif isDefined("application.wysiwyg") AND application.wysiwyg EQ "fckeditor">
				<cfset getContentObjectMethod="editInPlaceFCK">
			<cfelse>
				<cfset getContentObjectMethod="editInPlace">
			</cfif>
			<cfset thisContainerOutput=evaluate("ContentObject.#getContentObjectMethod#(contentobjectid=url.contentobjectid)")>
		</cfif>
	<!--- if we are in preview mode, call the CFC and add the previewContent to the page --->
		<cfif isDefined("previewContent") AND parentsMatch EQ true>
			<cfset thisContainerOutput=ContentObject.previewContent(contentobjectid=url.contentobjectid)>
		</cfif>
		<!---Check to see if this user has permission to edit this component--->
		<cfif isDefined("session.user") AND session.user.liveEdit>
			<!--- yes, this is a content object --->
			<cfif q_getpageInfo.objectid EQ application.tool.contentobject>
				<cfset warningMessage = ''>
				<cfif parentsMatch EQ true>
					<cfset outputId = url.contentobjectid>
					<!--- this is not the live content, find out its status and display a message --->
					<cfif url.contentobjectid NEQ request.thisObjectid>
						<cfquery name="q_getVersionStatus" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT status, colorcode 
                            FROM version 
                            	INNER JOIN versionstatus 
                                	ON version.versionstatusid = versionstatus.versionstatusid 
                            WHERE instanceitemid = <cfqueryparam cfsqltype="cf_sql_integer" value="#outputId#"> AND formobjectitemid = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_getpageInfo.objectid#">
						</cfquery>
						<cfset warningMessage = '<b>The content you are viewing is <font color="#q_getVersionStatus.colorcode#">#q_getVersionStatus.status#</font>.<br><a href="#request.page#?previewContent=yes&contentobjectid=#request.thisObjectid#">View the live content</a>.</b>'>
					</cfif>
				<cfelse>
					<cfset outputId = request.thisObjectid>
				</cfif>
				<!--- Check user rights to edit content in this section --->
				<cfquery datasource="#application.datasource#" name="q_checkSectionRights" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT * FROM Users_Sections 
                    WHERE userid=<cfqueryparam cfsqltype="cf_sql_integer" value="#session.user.id#"> AND sitesectionid = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_getpageInfo.sitesectionid#">
				</cfquery>
				<!--- this is being edited right now or they don't have permission so don't show edit button --->
				<cfif (isDefined('editInPlace')) OR (q_checkSectionRights.recordcount EQ 0)>
					<cfset thisContainerOutput = trim(thisContainerOutput)>
				<!--- they have permission but have not yet selected content to edit so show button --->
				<cfelse>
					<cfif isNumeric(outputId)>
						<cfset thisContainerOutput = '<div onMouseOver="turnOn(#outputId#)" onMouseOut="turnOff(#outputId#)" class="divOff" id="le#outputId#"><div id="editbutton#outputId#" class="editbutton">'&application.showEditInstanceButton(application.tool.contentobject,outputId, "Edit Content")&' #warningMessage#</div>#trim(thisContainerOutput)#</div>'>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		<!--- Replace the [[containers]] with the associated content var called above unless xobj override is used to skip it --->
		<cfif NOT (isDefined("xobj") AND listfindnocase(xobj,q_getpageInfo.containerid))>
			<cfset templatefile=REReplaceNoCase(templatefile,'\[\[[[:alnum:]_^ ]*#q_getpageInfo.containerid#\]\]',"#trim(thisContainerOutput)#","ALL")>
		</cfif>
	</cfloop>
	<!---Clean up any components not found so they can't see our underpants --->
	<cfset templatefile=REReplaceNoCase(templatefile,'\[\[[[:alnum:]_^ ]*\]\]',"<!--&nbsp;You are missing this component -->","ALL")>
	<!---build meta data block--->
	<cfset siteMetaDir="/#application.sitemapping#/meta">
	<cfset thisNewMetaFileName="#siteMetaDir#/#pageConstructor.getsitesectionid()#_#request.thispageid#_#request.thispage#">
	<cfif FileExists(ExpandPath(thisNewMetaFileName))>
		<cfsavecontent variable="thisMetaBlock">
			<cfoutput>
				<cfinclude template="#thisNewMetaFileName#">
			</cfoutput>
		</cfsavecontent>    
	<cfelse>
	    <cfset thisMetaBlock="">
	</cfif>
    <!--- <cftry>
		<cfcatch type="MissingInclude">
			
		</cfcatch>
	</cftry> --->
	<!--- Store all javascripts used on this site in an app query var --->
	<cfif NOT isDefined('application.q_getjavascript') OR isDefined("URL.initializeApp")>
		<cfset application.q_getjavascript = pageConstructor.getAllJS()>
	</cfif>
	<!--- get scripts for this page --->
	<cfset q_getpagejavascript = pageConstructor.getPageJS(application.q_getjavascript)>
	<cfset onloadCall="">
	<cfsavecontent variable="javascriptBlock">
		<cfoutput>
			<!--- Prototyping JavaScript include for sitemode = prototyping or development (still want to use discussion when in development--->
			<!--- <cfif application.sitemode EQ "prototyping" OR application.sitemode eq "development">
				<script type="text/javascript" src="#application.globalPath#/javascript/prototyping.js"></script>
			</cfif> --->
			<!---Live Edit JS--->
			<cfif isDefined("session.user") AND session.user.liveEdit>
				<script type="text/javascript">
				function turnOn(thisId){
					document.getElementById('le'+thisId).className='divOn';
					document.getElementById('editbutton'+thisId).style.display = 'inline';
				}
				function turnOff(thisId){
					document.getElementById('le'+thisId).className='divOff';
					document.getElementById('editbutton'+thisId).style.display = 'none';
				}
				</script>
			</cfif>
			<cfif q_getpagejavascript.recordcount>
				<cfloop query="q_getpagejavascript">
					<cfif q_getpagejavascript.includemethod EQ "javascript">
						<script type="text/javascript" src="/javascript/#q_getpagejavascript.javascriptfile#"></script>
					<cfelse>
						<script type="text/javascript">
							<cfinclude template="/#application.sitemapping#/javascript/#q_getpagejavascript.javascriptfile#">		
						</script>
					</cfif>
					<cfif len(q_getpagejavascript.onload)>
						<cfset onloadCall=onloadCall&q_getpagejavascript.onload>
					</cfif>
				</cfloop>
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfsetting enablecfoutputonly="No">
	
	<cfset DocTypes=StructNew()>
	<cfset DocTypes.HTML401Transitional='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'>
	<cfset DocTypes.HTML401Strict='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'>
	<cfset DocTypes.XHTML10Transitional='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'>
	<cfset DocTypes.XHTML10Strict='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'>
	<cfset DocTypes.XHTML11='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'>
	<cfset DocTypes.XHTMLMobile10='<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.0//EN" "http://www.wapforum.org/DTD/xhtml-mobile10.dtd">'>
    <!--- HTML Tags for each doc type --->
	<cfset HTMLTag.HTML401Transitional='<html>'>
	<cfset HTMLTag.HTML401Strict='<html>'>
	<cfset HTMLTag.XHTML10Transitional='<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'>
	<cfset HTMLTag.XHTML10Strict='<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'>
	<cfset HTMLTag.XHTML11='<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'>
	<cfset HTMLTag.XHTMLMobile10='<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'>
	<!--- query for sitesettings doctype --->
	<cfif NOT isDefined('session.siteDocType')>
		<cfquery datasource="#application.datasource#" name="q_siteSettings" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT * FROM SiteSettings
		</cfquery>
		<cfif isDefined('q_siteSettings.doctype') AND Len(q_siteSettings.doctype)>
			<cfset session.siteDocType = q_siteSettings.doctype>
		</cfif>	
	</cfif>
</cfsilent>
	<cfoutput>
	<cfif NOT isDefined('session.siteDocType')>
		<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<cfelse>
		#evaluate("Doctypes."&session.siteDocType)#
	</cfif>
	<cfif NOT isDefined('session.siteDocType')>
    	<html>
	<cfelse>
		#evaluate("HTMLTag."&session.siteDocType)#
	</cfif>
		<head>

		<!--- EOM :: 05.19.2009 :: Put in a fix for modifying HTML page title of a page.
											Effectively, I'm telling page constructor not to add it because it will be added Manually --->
		<cfif isDefined('URL.bsPageTitle')>
			<!--- No Page Title :: unlike other condtitionals which will right the page title --->
			<!--- Developer will have to remember to add this query string. A better approach will be determined. --->
			<cfset REQUEST.pagetitle = q_getpageInfo.pagetitle>

		<cfelseif isDefined('URL.table') AND len(trim(URL.table)) AND isDefined('URL.key') AND len(trim(URL.key))>
			<!--- if ISAPI or straight URL variables passed for detail item, swap out title element for page SEO --->
			<!--- tests for existance of table, assumes that sekeyname is valid field name in table --->
			<title>#application.stripHTML(pageConstructor.swapHTMLPageTitle(table=URL.table,key=URL.key,defaulttitle=q_getpageInfo.pagetitle))#</title>
		<!--- default to page title --->
		<cfelse>
			<title>#q_getpageInfo.pagetitle#</title>
		</cfif>

		<!--- Dynamic Meta Data to go here --->
		<cfif len(trim(thisMetaBlock))>#thisMetaBlock#</cfif>
		<!--- Dynamic Javascript to go here --->
		<cfif len(trim(javascriptBlock))>#javascriptBlock#</cfif>
		<!--- Dynamic StyleSheet to go here --->
		<cfset pageCSS = pageConstructor.getPageCSS()>
		<cfloop from="1" to="#arrayLen(pageCSS)#" index="i"><link rel="stylesheet" href="#pageCSS[i]#" type="text/css"></cfloop>
		<!--- <cfif application.sitemode EQ "prototyping" OR application.sitemode eq "development">
			<link rel="stylesheet" href="#application.globalPath#/css/prototyping.css" type="text/css">
		</cfif> --->
		<!--- sIFR js & css goes here --->
		<cfif FileExists('#ExpandPath(application.globalPath)#/sifr/sIFR-screen.css')>
			<link rel="stylesheet" href="#APPLICATION.globalpath#/sifr/sIFR-screen.css" type="text/css" media="screen" />
		</cfif>
		<cfif FileExists('#ExpandPath(application.globalPath)#/sifr/sIFR-print.css')>
			<link rel="stylesheet" href="#APPLICATION.globalpath#/sifr/sIFR-print.css" type="text/css" media="print" />
		</cfif>
		<cfif FileExists('#application.installpath#/sifr/sifr.css')>
			<link rel="stylesheet" href="/sifr/sifr.css" type="text/css" media="screen" />
		</cfif>
		<cfif FileExists('#application.installpath#/sifr/sifr-replaceElements.js')>
			<script src="/sifr/sifr-replaceElements.js" type="text/javascript"></script>
		</cfif>
		<cfif FileExists('#ExpandPath(application.globalPath)#/sifr/sifr.js')>
			<script src="#APPLICATION.globalpath#/sifr/sifr.js" type="text/javascript"></script>
		</cfif>		
		</head>
		<body style="margin: 0px"<cfif len(onloadCall)> onload="#onloadCall#"</cfif>><!--- Prototyping Display<cfif application.sitemode EQ "prototyping"><cfmodule template="#application.customTagPath#/prototyping.cfm" /></cfif><!--- output the file --->#trim(templatefile)#--->
		<!--- CONTENT MAPPPING button also added test to PROTOTYPEBLOCK in prototyping.cfm to shift location --->
		<cfif isDefined("session.user") AND session.user.liveEdit AND isDefined('APPLICATION.usescontentmapping') AND APPLICATION.usescontentmapping >
			<cfinclude template="/admintools/includes/i_ContentMappingLink.cfm">
		</cfif>
		<!--- Prototyping Display --->
		<!--- <cfif application.sitemode EQ "prototyping"><cfmodule template="#application.customtagpath#/prototyping.cfm" /></cfif>--->
		<!--- output the file --->#trim(templatefile)#
		<!--- CMC MOD 3/6/07: Analytics Code --->
		<cfif isDefined('application.analyticscode') AND Len(application.analyticscode) AND isDefined('application.analyticstype') AND Len(application.analyticstype)>
			<cfswitch expression="#LCase(application.analyticstype)#">
				<cfcase value="google">
					<script type="text/javascript">
						var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
						document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
					</script>
					<script type="text/javascript">
						var pageTracker = _gat._getTracker("#application.analyticscode#");
						pageTracker._initData();
						pageTracker._trackPageview();
					</script>
				</cfcase>
			</cfswitch>
		</cfif>
		<cfsavecontent variable="womOnCall"><script type="text/javascript">womOn();</script></cfsavecontent>
		<cfhtmlhead text="#womOnCall#">
		</body>
	</html>
	</cfoutput>
</cfif>