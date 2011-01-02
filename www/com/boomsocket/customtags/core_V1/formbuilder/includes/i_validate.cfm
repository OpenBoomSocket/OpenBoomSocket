<cfloop list="#form.fieldnames#" index="i">
	<cfset "request.FORM#i#"=evaluate("form."&i)>
</cfloop>
<cfmodule template="#application.customTagPath#/formvalidation.cfm"
		 validatelist="#trim(form.validatelist)#">