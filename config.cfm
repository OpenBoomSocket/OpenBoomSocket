<cfsetting enablecfoutputonly="Yes">
<cfsilent>
<cfinclude template="/i_dataSourceInfo.cfm">
<cflock timeout="8" throwontimeout="No" type="EXCLUSIVE" scope="APPLICATION">
<cfset APPLICATION.datasource="#thisClientCode#">
<!--- Query for site settings --->
<cfquery datasource="#APPLICATION.datasource#" name="q_getSiteSettings" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT *
	FROM sitesettings
</cfquery>
<!--- Query for tool IDs and set vars --->
<cfquery datasource="#APPLICATION.datasource#" name="q_getToolIDs" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT formname, formobjectid
	FROM formobject
	WHERE formobjectid = parentid
	ORDER BY formname ASC
</cfquery>
<cfset APPLICATION.tool=structNew()>
<cfloop query="q_getToolIDs">
	<cfset "APPLICATION.tool.#q_getToolIDs.formname#"=q_getToolIDs.formobjectid>
</cfloop>
	<cfscript>
		//Set up Site Level Vars
		APPLICATION.missingPagePath="";
		APPLICATION.usescontentmapping=false;
		APPLICATION.customTagPath="/com/boomsocket/customtags/core_V1";
		APPLICATION.CFCPath="com.boomsocket.components.core_V1";
		APPLICATION.globalPath="/com/boomsocket/global/core_V1";
		// APPLICATION.globalMapping="/BS_Global/core_V1";
		APPLICATION.siteMapObj = CreateObject('component','#APPLICATION.CFCpath#.sitemap');
		APPLICATION.udfPath="#APPLICATION.globalPath#/udf/global.cfm";
		APPLICATION.fckVersion="2_6_1";
		APPLICATION.contentObjectDH=100;
		APPLICATION.sitemapping="#thisClientCode#";
		APPLICATION.useStrongEncryption = true;
		APPLICATION.saltEncrypt = '';
		fileObj = createObject("java", "java.io.File");
     	APPLICATION.slash = fileObj.separator;
		APPLICATION.installpath=left(expandPath('/index.cfm'),len(expandPath('/index.cfm'))-10); // Experimental. works on apache/win need to test on iis/win as well
		APPLICATION.imagedirectory="#APPLICATION.installpath#\media\images";
		APPLICATION.imageURL="/media/images";
		APPLICATION.adminEmail=q_getSiteSettings.adminEmail;
		APPLICATION.clientAdminEmail=q_getSiteSettings.clientAdminEmail;
		APPLICATION.supervisorid=q_getSiteSettings.supervisorid;
		APPLICATION.defaultHomepage=q_getSiteSettings.defaultHomepage;
		APPLICATION.cssIncludes=q_getSiteSettings.cssIncludes;
		APPLICATION.sitename=q_getSiteSettings.sitename;
		APPLICATION.sitemode=q_getSiteSettings.sitemode;
		if (isDefined("q_getSiteSettings.analyticscode")) {
			application.analyticscode=q_getSiteSettings.analyticscode;
		}
		if (isDefined("q_getSiteSettings.analyticstype")) {
			application.analyticstype=q_getSiteSettings.analyticstype;
		}
		APPLICATION.templatepath="#APPLICATION.installpath#\templates";
		if (isDefined("q_getSiteSettings.wysiwyg")) {
			APPLICATION.wysiwyg=q_getSiteSettings.wysiwyg;
		} else {
			APPLICATION.wysiwyg="";
		}
	//Set Up operating environment vars
		if (APPLICATION.slash eq "/"){
			APPLICATION.movecommand="/sbin/mv";// *nix OS
			APPLICATION.tempdirpath="/temp";
		}else{
			APPLICATION.movecommand="move"; // win OS
			APPLICATION.tempdirpath="#APPLICATION.installpath#\temp";
		}
</cfscript>
<cftry>
	<cfset APPLICATION.sitemapIgnoreList = APPLICATION.siteMapObj.getIgnorePages()>
	<cfcatch type="database"></cfcatch>
</cftry>
</cflock>
</cfsilent>
<cfsetting enablecfoutputonly="No">