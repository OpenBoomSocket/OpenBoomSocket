<cfcomponent displayname="i3 Bread Crumbs" hint="This component is used to create a linkable bread crumb style navigation." name="i3breadcrumbs">

	<cffunction name="showBC"
             access="remote"
             returntype="string"
             displayname="Bread Crumb Nav"
             hint="Shows current nav list determined by current page.">

		<cfargument name="thispageid" type="numeric" required="yes">
    	<cfargument name="thisDivider" type="string" default="&nbsp;">
		<cfargument name="thisPageClass" type="string" default="">
		<cfargument name="thisTrailClass" type="string" default="">
		<cfargument name="thisPageStyle" type="string" default="">
		<cfargument name="thisTrailStyle" type="string" default="">
		<cfargument name="thisHomeText" type="string" default="Home">
		
		<cfif thispageid>
		
			<cfset thisSectionParent="">
			<cfset thisBreadCrumb="">
			
			<!--- get this pages section --->
			<cfquery name="q_getThisSection" datasource="#application.datasource#">
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
				<cfquery name="q_getThisSection" datasource="#application.datasource#">
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
				<cfset thisBreadCrumb=listPrepend(thisBreadCrumb,"<a href=""/#thisBClink#"" title=""Go to #q_getThisSection.sitesectionlabel#"" class=""#thisTrailClass#"" style=""#thisTrailStyle#"">#q_getThisSection.sitesectionlabel#</a>","~")>
			</cfloop>
			
			<cfif len(thisPageClass) or len(thisPageStyle)>
				<cfset thisPageName="<span class=""#thisPageClass#"" style=""#thisPageStyle#"">#thisPageName#</span>">
			</cfif>
		
			<cfset thisBreadCrumb=thisBreadCrumb&"~"&thisPageName>
			
			<cfset thisBreadCrumb=listPrepend(thisBreadCrumb,"<a href=""#application.installurl#"" title=""Go to #thisHomeText#"" class=""#thisTrailClass#"" style=""#thisTrailStyle#"">#thisHomeText#</a>","~")>

			<cfset thisBreadCrumb=replace(thisBreadCrumb,"~",thisDivider,"ALL")>
		<cfelse>
			<cfset thisBreadCrumb="[no pageid]<!-- thispageid is required -->">
		</cfif>

		
		<cfreturn thisBreadCrumb>
	</cffunction>
	
</cfcomponent>