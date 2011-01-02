<!--- i_preshowform.cfm --->
<cfif isDefined("session.debug")>
	<cfset form.debugging=session.debug>
</cfif>
<!--- q_customQuery_cssIncludes --->
<cfdirectory action="LIST"
             directory="#application.installpath##application.slash#css"
             name="tmpQuery" 
			 filter="*.css">
<cfset q_customQuery_cssIncludes=queryNew("lookupkey,lookupdisplay")>
<cfloop query="tmpQuery">
	<cfset tmpRow=QueryAddRow(q_customQuery_cssIncludes)>
	<cfset tmpCell=QuerySetCell(q_customQuery_cssIncludes,"lookupkey",tmpQuery.Name)>
	<cfset tmpCell=QuerySetCell(q_customQuery_cssIncludes,"lookupdisplay",tmpQuery.Name)>
</cfloop>
<cfset request.q_customQuery_cssIncludes=q_customQuery_cssIncludes>