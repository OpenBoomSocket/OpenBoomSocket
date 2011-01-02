<cfsetting enablecfoutputonly="yes">
<!--- 
<cf_i3breadcrumb>

	thispageid 		REQUIRED
	thisDivider		OPTIONAL	DEFAULTS TO " " (SPACE)
	thisPageClass	OPTIONAL
	thisTrailClass	OPTIONAL

 --->

<cfparam name="attributes.thispageid" default="">
<cfparam name="attributes.thisDivider" default="&nbsp;">
<cfparam name="attributes.thisPageClass" default="">
<cfparam name="attributes.thisTrailClass" default="">
<cfparam name="attributes.thisPageStyle" default="">
<cfparam name="attributes.thisTrailStyle" default="">

<cfset thispageid=trim(attributes.thispageid)>
<cfset thisDivider=trim(attributes.thisDivider)>
<cfset thisPageClass=trim(attributes.thisPageClass)>
<cfset thisTrailClass=trim(attributes.thisTrailClass)>
<cfset thisPageStyle=trim(attributes.thisPageStyle)>
<cfset thisTrailStyle=trim(attributes.thisTrailStyle)>

<cfif thispageid>

	<cfset thisSectionParent="">
	<cfset thisBreadCrumb="">
	
	<!--- get this pages section --->
	<cfquery name="q_getThisSection" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT 
			page.sitesectionid, 
			page.pagetitle, 
			sitesection.sitesectionlabel, 
			sitesection.sitesectionparent
		FROM 
			page INNER JOIN 
				sitesection ON page.sitesectionid = sitesection.sitesectionid
		WHERE 
			pageid = #thispageid#
	</cfquery>
	
	<cfset thisPageName=q_getThisSection.pagetitle>
	<cfset thisBClink=application.getSectionPath(q_getThisSection.sitesectionid,"true","/")>
	<cfset thisBreadCrumb="<a href=""/#thisBClink#"" title=""Go to #q_getThisSection.sitesectionlabel#"" class=""#thisTrailClass#"" style=""#thisTrailStyle#"">#q_getThisSection.sitesectionlabel#</a>">

	<cfset thisFirstSection=q_getThisSection.sitesectionid>
	<cfset thisSection=q_getThisSection.sitesectionid>
	<cfset thisSectionParent=q_getThisSection.sitesectionparent>

	<cfloop condition="thisSection NEQ thisSectionParent">
		<!--- get this section's parent --->
		<cfquery name="q_getThisSection" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT 
				sitesection.sitesectionid, 
				sitesection.sitesectionlabel, 
				sitesection.sitesectionparent
			FROM 
				sitesection 
			WHERE 
				sitesectionid = #thisSectionParent#
		</cfquery>
		<cfset thisSection=q_getThisSection.sitesectionid>
		<cfset thisSectionParent=q_getThisSection.sitesectionparent>
		<cfset thisBClink=application.getSectionPath(q_getThisSection.sitesectionid,"true","/")>
		<cfset listPrepend("<a href=""/#thisBClink#"" title=""Go to #q_getThisSection.sitesectionlabel#"" class=""#thisTrailClass#"" style=""#thisTrailStyle#"">#q_getThisSection.sitesectionlabel#</a>",q_getThisSection.sitesectionlabel,thisDivider)>
	</cfloop>
	
	<cfif len(thisPageClass)>
		<cfset thisPageName="<span class=""#thisPageClass#"" style=""#thisPageStyle#"">#thisPageName#</span>">
	</cfif>

	<cfset thisBreadCrumb=thisBreadCrumb&thisDivider&thisPageName>
	
	<cfoutput>#thisBreadCrumb#</cfoutput>

<cfelse>
	
	<cfoutput>[no pageid]<!-- thispageid is required --></cfoutput>

</cfif>
<cfsetting enablecfoutputonly="no">