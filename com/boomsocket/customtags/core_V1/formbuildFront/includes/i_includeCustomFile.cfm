<cfoutput><!--- include custom file --->
<cftry>
     <cfif FileExists('#application.installpath#/#a_formelements[a].custominclude#')>
       <cfinclude template="/#application.sitemapping#/#a_formelements[a].custominclude#">
     <cfelseif FileExists('#ExpandPath(application.globalPath)#/#a_formelements[a].custominclude#')>
      <cfinclude template="#application.globalPath#/#a_formelements[a].custominclude#">
     <cfelse>
      <cfthrow type="i3SiteTools.error" message="Missing Include" detail="Could not find a working or global copy of the /#application.installpath#/#a_formelements[a].custominclude#">
     </cfif>
     <cfcatch type="Any">
      <h3 style="color:##cc0000;">ERROR! Something blew up in your custom include:<br> #a_formelements[a].custominclude#</h3><p>#cfcatch.Message# - #cfcatch.Detail#</p>
     </cfcatch>
    </cftry>
</cfoutput>