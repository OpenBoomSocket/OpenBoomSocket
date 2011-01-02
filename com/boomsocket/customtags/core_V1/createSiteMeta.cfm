<cfsetting enablecfoutputonly="Yes">

<cfquery name="q_getAllPages" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT sitesectionid,pageid,pagename 
	FROM page 
	ORDER BY sitesectionid ASC, pageid ASC, pagename ASC
</cfquery>

<cfset SiteMetaID="100000">
<cfset siteMetaDir="#application.installPath##APPLICATION.slash#meta">

<!--- make sure the siteMetaDir is there --->
<cfif NOT DirectoryExists("#siteMetaDir#")>
	<cfdirectory action="CREATE" directory="#siteMetaDir#">
</cfif>

<cfif q_getAllPages.recordcount>

<!--- delete all meta files in siteMetaDir --->s
<cfdirectory action="LIST"
             directory="#siteMetaDir#"
             name="metaDirList"
             filter="*.cfm">
<cfloop query="metaDirList">
	<cfset thisMetaFile="#siteMetaDir##APPLICATION.slash##metaDirList.name#">
	<cfif fileExists("#thisMetaFile#")>
		<cftry>
			<cffile action="delete" file="#thisMetaFile#">
			<cfcatch type="any">
				<cfmail to="#application.adminemail#" from="#application.adminemail#" subject="Error Creating Meta Files">There was an error trying to create the meta files for #CGI.SERVER_NAME#.
The error received was #CFCATCH.Detail#</cfmail>
			</cfcatch>
		</cftry>
	</cfif>
</cfloop>

<cfloop query="q_getAllPages">
<cfset pageid=q_getAllPages.pageid>
<cfset sitesectionid=q_getAllPages.sitesectionid>
<cfset pagename=q_getAllPages.pagename>
<cfset thisNewMetaFileName="#siteMetaDir##APPLICATION.slash##sitesectionid#_#pageid#_#pagename#">

<!--- query for meta data --->
<cfquery name="q_getPageMetaData" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT *
	FROM meta 
	WHERE pageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#pageid#">
</cfquery>
<cfif q_getPageMetaData.recordcount>
	<cfset hasPageMeta=1>
<cfelse>
	<cfset hasPageMeta=0>
</cfif>
<cfquery name="q_getSectionMetaData" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT *
	FROM meta 
	WHERE sitesectionid = <cfqueryparam cfsqltype="cf_sql_integer" value="#sitesectionid#">
</cfquery>
<cfif q_getSectionMetaData.recordcount>
	<cfset hasSectionMeta=1>
<cfelse>
	<cfset hasSectionMeta=0>
</cfif>
<cfquery name="q_getSiteMetaData" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT *
	FROM meta 
	WHERE metaid = <cfqueryparam cfsqltype="cf_sql_integer" value="#SiteMetaID#">
</cfquery>
<cfif q_getSiteMetaData.recordcount>
	<cfset hasSiteMeta=1>
<cfelse>
	<cfset hasSiteMeta=0>
</cfif>

<cfscript>
// [DESCRIPTION]
	thisPageMetaDescription="";
//page
if (hasPageMeta EQ 1){
	if (len(q_getPageMetaData.metaDescription)){
		thisPageMetaDescription=thisPageMetaDescription&" "&q_getPageMetaData.metaDescription;
	}
	// and section
	if (q_getPageMetaData.metaIncludeSection EQ 1 AND hasSectionMeta EQ 1){
		if (len(q_getSectionMetaData.metaDescription)){
			thisPageMetaDescription=thisPageMetaDescription&" "&q_getSectionMetaData.metaDescription;
		}
	}
	// and site
	if (q_getPageMetaData.metaIncludeSite EQ 1 AND hasSiteMeta EQ 1){
		if (len(q_getSiteMetaData.metaDescription)){
			thisPageMetaDescription=thisPageMetaDescription&" "&q_getSiteMetaData.metaDescription;
		}
	}

// section
} else if (hasSectionMeta EQ 1 AND q_getPageMetaData.metaIncludeSection EQ 1){
	if (len(q_getSectionMetaData.metaDescription)){
		thisPageMetaDescription=thisPageMetaDescription&" "&q_getSectionMetaData.metaDescription;
	}
	// and site
	if (q_getSectionMetaData.metaIncludeSite EQ 1 AND hasSiteMeta EQ 1){
		if (len(q_getSiteMetaData.metaDescription)){
			thisPageMetaDescription=thisPageMetaDescription&" "&q_getSiteMetaData.metaDescription;
		}
	}

// site
} else if (hasSiteMeta EQ 1 AND q_getPageMetaData.metaIncludeSite EQ 1){
	if (len(q_getSiteMetaData.metaDescription)){
		thisPageMetaDescription=thisPageMetaDescription&" "&q_getSiteMetaData.metaDescription;
	}

}
thisPageMetaDescription=replaceNoCase(thisPageMetaDescription,Chr(10),"","ALL");
thisPageMetaDescription=replaceNoCase(trim(thisPageMetaDescription),Chr(13),"","ALL");

// [KEYWORDS]
	thisPageMetaKeywords="";
//page
if (hasPageMeta EQ 1){
	if (len(q_getPageMetaData.metaKeywords)){
		thisPageMetaKeywords=thisPageMetaKeywords&","&q_getPageMetaData.metaKeywords;
	}
	// and section
	if (q_getPageMetaData.metaIncludeSection EQ 1 AND hasSectionMeta EQ 1){
		if (len(q_getSectionMetaData.metaKeywords)){
			thisPageMetaKeywords=thisPageMetaKeywords&","&q_getSectionMetaData.metaKeywords;
		}
	}
	// and site
	if (q_getPageMetaData.metaIncludeSite EQ 1 AND hasSiteMeta EQ 1){
		if (len(q_getSiteMetaData.metaKeywords)){
			thisPageMetaKeywords=thisPageMetaKeywords&","&q_getSiteMetaData.metaKeywords;
		}
	}

// section
} else if (hasSectionMeta EQ 1 AND q_getPageMetaData.metaIncludeSection EQ 1){
	if (len(q_getSectionMetaData.metaKeywords)){
		thisPageMetaKeywords=thisPageMetaKeywords&","&q_getSectionMetaData.metaKeywords;
	}
	// and site
	if (q_getSectionMetaData.metaIncludeSite EQ 1 AND hasSiteMeta EQ 1){
		if (len(q_getSiteMetaData.metaKeywords)){
			thisPageMetaKeywords=thisPageMetaKeywords&","&q_getSiteMetaData.metaKeywords;
		}
	}

// site
} else if (hasSiteMeta EQ 1 AND q_getPageMetaData.metaIncludeSite EQ 1){
	if (len(q_getSiteMetaData.metaKeywords)){
		thisPageMetaKeywords=thisPageMetaKeywords&","&q_getSiteMetaData.metaKeywords;
	}

}
if (left(thisPageMetaKeywords,1) EQ ",") {
	thisPageMetaKeywords=removeChars(thisPageMetaKeywords,1,1);
}
thisPageMetaKeywords=replaceNoCase(thisPageMetaKeywords,Chr(10),"","ALL");
thisPageMetaKeywords=replaceNoCase(trim(thisPageMetaKeywords),Chr(13),"","ALL");

// [COPYRIGHT]
	thisPageMetaCopyRight="";
//page
if ((hasPageMeta EQ 1) AND (len(q_getPageMetaData.MetaCopyRight))){
	thisPageMetaCopyRight=q_getPageMetaData.MetaCopyRight;

// section
} else if ((hasSectionMeta EQ 1) AND (len(q_getSectionMetaData.MetaCopyRight))){
		thisPageMetaCopyRight=q_getSectionMetaData.MetaCopyRight;

// site
} else if ((hasSiteMeta EQ 1) AND (len(q_getSiteMetaData.MetaCopyRight))){
		thisPageMetaCopyRight=q_getSiteMetaData.MetaCopyRight;

}

// [ROBOTSINDEX]
	thisPageMetaRobotsIndex=0;
//page
if ((hasPageMeta EQ 1) AND isDefined('q_getPageMetaData.MetaRobotsIndex')){
	thisPageMetaRobotsIndex=q_getPageMetaData.MetaRobotsIndex;

// section
} else if ((hasSectionMeta EQ 1) AND isDefined('q_getSectionMetaData.MetaRobotsIndex')){
		thisPageMetaRobotsIndex=q_getSectionMetaData.MetaRobotsIndex;

// site
} else if ((hasSiteMeta EQ 1) AND isDefined('q_getSiteMetaData.MetaRobotsIndex')){
		thisPageMetaRobotsIndex=q_getSiteMetaData.MetaRobotsIndex;

}

// [ROBOTSFOLLOW]
	thisPageMetaRobotsFollow=0;
//page
if ((hasPageMeta EQ 1) AND isDefined('q_getPageMetaData.MetaRobotsFollow')){
	thisPageMetaRobotsFollow=q_getPageMetaData.MetaRobotsFollow;

// section
} else if ((hasSectionMeta EQ 1) AND isDefined('q_getSectionMetaData.MetaRobotsFollow')){
		thisPageMetaRobotsFollow=q_getSectionMetaData.MetaRobotsFollow;

// site
} else if ((hasSiteMeta EQ 1) AND isDefined('q_getSiteMetaData.MetaRobotsFollow')){
		thisPageMetaRobotsFollow=q_getSiteMetaData.MetaRobotsFollow;

}

// [CACHEPRAGMA]
	thisPageMetaPragma=0;
//page
if ((hasPageMeta EQ 1) AND isDefined('q_getPageMetaData.MetaPragma')){
	thisPageMetaPragma=q_getPageMetaData.MetaPragma;

// section
} else if ((hasSectionMeta EQ 1) AND isDefined('q_getSectionMetaData.MetaPragma')){
		thisPageMetaPragma=q_getSectionMetaData.MetaPragma;

// site
} else if ((hasSiteMeta EQ 1) AND isDefined('q_getSiteMetaData.MetaPragma')){
		thisPageMetaPragma=q_getSiteMetaData.MetaPragma;

}

// [EXPIRES]
	thisPageMetaExpires="";
//page
if (hasPageMeta EQ 1){
	if (len(q_getPageMetaData.metaExpires)){
		thisPageMetaExpires=q_getPageMetaData.metaExpires;
	}

// section
} else if (hasSectionMeta EQ 1){
	if (len(q_getSectionMetaData.metaExpires)){
		thisPageMetaExpires=q_getSectionMetaData.metaExpires;
	}

// site
} else if (hasSiteMeta EQ 1){
	if (len(q_getSiteMetaData.metaExpires)){
		thisPageMetaExpires=q_getSiteMetaData.metaExpires;
	}

}

// [REFRESH]
	thisPageMetaRefreshTime="";
	thisPageMetaRefreshURL="";
//page
if (hasPageMeta EQ 1){
	if (len(q_getPageMetaData.metaRefreshTime)){
		thisPageMetaRefreshTime=q_getPageMetaData.metaRefreshTime;
		thisPageMetaRefreshURL=q_getPageMetaData.metaRefreshURL;
	}

// section
} else if (hasSectionMeta EQ 1){
	if (len(q_getSectionMetaData.metaRefreshTime)){
		thisPageMetaRefreshTime=q_getSectionMetaData.metaRefreshTime;
		thisPageMetaRefreshURL=q_getSectionMetaData.metaRefreshURL;
	}

// site
} else if (hasSiteMeta EQ 1){
	if (len(q_getSiteMetaData.metaRefreshTime)){
		thisPageMetaRefreshTime=q_getSiteMetaData.metaRefreshTime;
		thisPageMetaRefreshURL=q_getSiteMetaData.metaRefreshURL;
	}

}

// [CHARSET]
	thisPageMetaCharset="";
//page
if ((hasPageMeta EQ 1) AND (len(q_getPageMetaData.MetaCharset))){
	thisPageMetaCharset=q_getPageMetaData.MetaCharset;

// section
} else if ((hasSectionMeta EQ 1) AND (len(q_getSectionMetaData.MetaCharset))){
		thisPageMetaCharset=q_getSectionMetaData.MetaCharset;

// site
} else if ((hasSiteMeta EQ 1) AND (len(q_getSiteMetaData.MetaCharset))){
		thisPageMetaCharset=q_getSiteMetaData.MetaCharset;

}

// [CUSTOM]
	thisPageMetaCustom="";
//page
if (hasPageMeta EQ 1){
	if (len(q_getPageMetaData.metaCustom)){
		thisPagemetaCustom=thisPagemetaCustom&" "&q_getPageMetaData.metaCustom;
	}
	// and section
	if (q_getPageMetaData.metaIncludeSection EQ 1 AND hasSectionMeta EQ 1){
		if (len(q_getSectionMetaData.metaCustom)){
			thisPagemetaCustom=thisPagemetaCustom&" "&q_getSectionMetaData.metaCustom;
		}
	}
	// and site
	if (q_getPageMetaData.metaIncludeSite EQ 1 AND hasSiteMeta EQ 1){
		if (len(q_getSiteMetaData.metaCustom)){
			thisPagemetaCustom=thisPagemetaCustom&" "&q_getSiteMetaData.metaCustom;
		}
	}

// section
} else if (hasSectionMeta EQ 1){
	if (len(q_getSectionMetaData.metaCustom)){
		thisPagemetaCustom=thisPagemetaCustom&" "&q_getSectionMetaData.metaCustom;
	}
	// and site
	if (q_getSectionMetaData.metaIncludeSite EQ 1 AND hasSiteMeta EQ 1){
		if (len(q_getSiteMetaData.metaCustom)){
			thisPagemetaCustom=thisPagemetaCustom&" "&q_getSiteMetaData.metaCustom;
		}
	}

// site
} else if (hasSiteMeta EQ 1){
	if (isDefined('q_getSiteMetaData.metaCustom') AND len(q_getSiteMetaData.metaCustom)){
		thisPagemetaCustom=thisPagemetaCustom&" "&q_getSiteMetaData.metaCustom;
	}

}
//thisPagemetaCustom=replaceNoCase(thisPagemetaCustom,Chr(10),"","ALL");
//thisPagemetaCustom=replaceNoCase(trim(thisPagemetaCustom),Chr(13),"","ALL");

</cfscript>

<cfsetting enablecfoutputonly="No">
<cfsavecontent variable="thisPageMeta">
<cfoutput><meta http-equiv="Content-Type" content="text/html; charset=<cfif len(thisPageMetaCharset)>#thisPageMetaCharset#<cfelse>UTF-8</cfif>">

<meta name="Code-Copyright" content="#dateFormat(Now(),"yyyy")#, Open BoomSocket" />
<meta name="System" content="Powered by Open BoomSocket : http://www.openboomsocket.com" />
<meta name="resource-type" content="document" />
<cfif len(thisPageMetaDescription)>
<meta name="Description" content="#thisPageMetaDescription#" /></cfif>
<cfif len(thisPageMetaKeywords)>
<meta name="Keywords" content="#thisPageMetaKeywords#" /></cfif>
<cfif len(thisPageMetaCopyRight)>
<meta name="Copyright" content="#thisPageMetaCopyRight#" /></cfif>
<meta name="robots" content="<cfif NOT thisPageMetaRobotsIndex>no</cfif>index,<cfif NOT thisPageMetaRobotsFollow>no</cfif>follow" />
<meta name="GOOGLEBOT" content="<cfif NOT thisPageMetaRobotsIndex>no</cfif>index,<cfif NOT thisPageMetaRobotsFollow>no</cfif>follow" />
<meta name="last_updated" content="#DateFormat(Now(),"yyyy-mm-dd")#" />
<cfif thisPageMetaPragma NEQ 1>
<meta http-equiv="pragma" content="no-cache" /></cfif>

<cfif len(thisPageMetaExpires) AND isDate(thisPageMetaExpires)><meta http-equiv="expires" content="#DateFormat(thisPageMetaExpires,"ddd, dd mmm yyyy")# #timeFormat(thisPageMetaExpires,"HH:mm:ss")# EST" /></cfif>

<cfif len(thisPageMetaRefreshTime)>
	<cfif len(thisPageMetaRefreshURL)>
<meta http-equiv="refresh" content="#thisPageMetaRefreshTime#;url=#thisPageMetaRefreshURL#" />
<cfelse>
<meta http-equiv="refresh" content="#thisPageMetaRefreshTime#" />
	</cfif>
</cfif>
<cfif len(thisPageMetaCustom)>#thisPageMetaCustom#</cfif>
</cfoutput>
</cfsavecontent>
<cftry>
	<cffile action="WRITE"
			file="#thisNewMetaFileName#"
			output="#thisPageMeta#"
			attributes="Normal"
			addnewline="No" nameconflict="overwrite">
	<cfcatch type="any">
		<cfmail to="#application.adminemail#" from="#application.adminemail#" subject="Error Creating Meta Files">There was an error trying to create the meta files for #CGI.SERVER_NAME#.
		The error received was #CFCATCH.Detail#</cfmail>
	</cfcatch>
</cftry>
</cfloop>
</cfif>