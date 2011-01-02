<cfcomponent displayname='sitesection' hint='sitesection CFC Bean' >
	<!--- init method --->
	<cffunction name='init' displayname='sitesectionBean init()' hint='initialze the bean' access='public' returntype='sitesectionBean' output='false'>
		<cfargument name='sitesectionid' displayname='Section ID' hint='ID of the section' type='numeric' required='no' default='' />
		<cfargument name='sitesectionname' displayname='Name' hint='Name of the directory' type='string' required='no' default='' />
		<cfargument name='sitesectiondesc' displayname='Description' hint='Description of the section' type='string' required='no' default='' />
		<cfargument name='sitesectionparent' displayname='Parent section' hint='ID of the section above this one' type='string' required='no' default='' />
		<cfargument name='sitesectionlabel' displayname='Label' hint='Friendly label of the section' type='string' required='no' default='' />
		<cfargument name='templateid' displayname='Template ID' hint='ID of the default template used in the section' type='numeric' required='no' default='' />
		<cfscript>
			variables.instance = structNew();
			variables.instance.sitesectionid = arguments.sitesectionid;
			variables.instance.sitesectionname = arguments.sitesectionname;
			variables.instance.sitesectiondesc = arguments.sitesectiondesc;
			variables.instance.sitesectionparent = arguments.sitesectionparent;
			variables.instance.sitesectionlabel = arguments.sitesectionlabel;
			variables.instance.templateid = arguments.templateid;
		</cfscript>
		<cfreturn this />
	</cffunction>

<!--- GETTER/SETTERS --->
	<cffunction name='getSitesectionid' displayname='numeric getSitesectionid()' hint='get the value of the sitesectionid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.sitesectionid />
	</cffunction>
	<cffunction name='setSitesectionid' displayname='setSitesectionid(numeric newSitesectionid)' hint='set the value of the sitesectionid property' access='public' output='false' returntype='void'>
		<cfargument name='newSitesectionid' displayname='numeric newSitesectionid' hint='new value for the sitesectionid property' type='numeric' required='yes' />
		<cfset variables.instance.sitesectionid = arguments.newSitesectionid />
	</cffunction>
	<cffunction name='getSitesectionname' displayname='string getSitesectionname()' hint='get the value of the sitesectionname property' access='public' output='false' returntype='string'>
		<cfreturn variables.instance.sitesectionname />
	</cffunction>
	<cffunction name='setSitesectionname' displayname='setSitesectionname(string newSitesectionname)' hint='set the value of the sitesectionname property' access='public' output='false' returntype='void'>
		<cfargument name='newSitesectionname' displayname='string newSitesectionname' hint='new value for the sitesectionname property' type='string' required='yes' />
		<cfset variables.instance.sitesectionname = arguments.newSitesectionname />
	</cffunction>
	<cffunction name='getSitesectiondesc' displayname='string getSitesectiondesc()' hint='get the value of the sitesectiondesc property' access='public' output='false' returntype='string'>
		<cfreturn variables.instance.sitesectiondesc />
	</cffunction>
	<cffunction name='setSitesectiondesc' displayname='setSitesectiondesc(string newSitesectiondesc)' hint='set the value of the sitesectiondesc property' access='public' output='false' returntype='void'>
		<cfargument name='newSitesectiondesc' displayname='string newSitesectiondesc' hint='new value for the sitesectiondesc property' type='string' required='yes' />
		<cfset variables.instance.sitesectiondesc = arguments.newSitesectiondesc />
	</cffunction>
	<cffunction name='getSitesectionparent' displayname='string getSitesectionparent()' hint='get the value of the sitesectionparent property' access='public' output='false' returntype='string'>
		<cfreturn variables.instance.sitesectionparent />
	</cffunction>
	<cffunction name='setSitesectionparent' displayname='setSitesectionparent(string newSitesectionparent)' hint='set the value of the sitesectionparent property' access='public' output='false' returntype='void'>
		<cfargument name='newSitesectionparent' displayname='string newSitesectionparent' hint='new value for the sitesectionparent property' type='string' required='yes' />
		<cfset variables.instance.sitesectionparent = arguments.newSitesectionparent />
	</cffunction>
	<cffunction name='getSitesectionlabel' displayname='string getSitesectionlabel()' hint='get the value of the sitesectionlabel property' access='public' output='false' returntype='string'>
		<cfreturn variables.instance.sitesectionlabel />
	</cffunction>
	<cffunction name='setSitesectionlabel' displayname='setSitesectionlabel(string newSitesectionlabel)' hint='set the value of the sitesectionlabel property' access='public' output='false' returntype='void'>
		<cfargument name='newSitesectionlabel' displayname='string newSitesectionlabel' hint='new value for the sitesectionlabel property' type='string' required='yes' />
		<cfset variables.instance.sitesectionlabel = arguments.newSitesectionlabel />
	</cffunction>
	<cffunction name='getTemplateid' displayname='numeric getTemplateid()' hint='get the value of the templateid property' access='public' output='false' returntype='numeric'>
		<cfreturn variables.instance.templateid />
	</cffunction>
	<cffunction name='setTemplateid' displayname='setTemplateid(numeric newTemplateid)' hint='set the value of the templateid property' access='public' output='false' returntype='void'>
		<cfargument name='newTemplateid' displayname='numeric newTemplateid' hint='new value for the templateid property' type='numeric' required='yes' />
		<cfset variables.instance.templateid = arguments.newTemplateid />
	</cffunction>
	<!--- standard get instance method --->
	<cffunction name='getInstance' displayname='struct getInstance()' hint='get struct instance of the bean' access='public' returntype='struct' output='false'>
		<cfreturn variables.instance />
	</cffunction>
	<!--- standard set instance method --->
	<cffunction name='setInstance' displayname='setInstance(struct newInstance)' hint='set struct instance of the bean' access='public' returntype='void' output='false'>
		<cfargument name='newInstance' displayname='struct newInstance' hint='new instance for the bean' type='struct' required='yes' />
		<cfset variables.instance = arguments.newInstance />
	</cffunction>

<!--- QUERIES --->	

<!--- POPULATE FROM DBers --->
<!--- Set section info from DB to section instance using its id --->
	<cffunction name="popSectionById" displayname="Populate Section By ID" hint="Populate the section instance from the DB using sitesectionid" access="public" returntype="void" output="false">
		<cfargument name='sitesectionid' displayname='numeric sitesectionid' hint='Id of the section to retrieve' type='numeric' required='no' default="0" />
		<cfset sectionQuery = "">
		<cfif arguments.sitesectionid NEQ 0><cfset setSiteSectionid(arguments.sitesectionid)></cfif>
		<cfif len(getSiteSectionid()) EQ 0><cfthrow message="You must supply a site section id." detail="The function popSectionById requires a sitesectionid. You can supply one by passing it in as an argument or setting a sitesectionid at the instance level."></cfif>
		<cfset sectionQuery = querySectionById()>
		<cfif sectionQuery.recordcount NEQ 0>
			<cfset setSiteSectionId(sectionQuery.sitesectionid)>
		<cfelse>
			<cfthrow message="The sitesectionid #getSiteSectionid()# does not exist" detail="You have attempted to call the function popSectionById with a sitesectionid that does not exist in the system.">
		</cfif>
	</cffunction>

<!--- EXISTANCE CHECKS --->
<!--- Check to see if section exists in system by sitesectionid --->
	<cffunction name="existsSectionById" displayname="Exists Section By ID" hint="Check to see if Section exists in system by SiteSectionid" access="public" returntype="boolean" output="false">
		<cfargument name='sitesectionid' displayname='numeric sitesection' hint='Id of the Section to retrieve' type='numeric' required='no' default="0" />
		<cfset pageQuery = "">
		<cfif arguments.sitesectionid NEQ 0><cfset setSiteSectionid(arguments.sitesectionid)></cfif>
		<cfif len(getSiteSectionid()) EQ 0><cfthrow message="You must supply a section id." detail="The function existsSectionById requires a sitesectionid. You can supply one by passing it in as an argument or setting a sitesectionid at the instance level."></cfif>
		<cfset pageQuery = querySectionById()>
		<cfreturn pageQuery.recordCount>
	</cffunction>
</cfcomponent>