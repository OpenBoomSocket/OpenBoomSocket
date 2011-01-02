<!---Session Check functionality not working so commented out of code
	- Jamie Lynn --->

<!--- <cfset currentTime = CreateTimeSpan(0,2,0,0)>

<cfif 1 EQ 1>
	<cfset variable = true>
<cfelse>
	<cfset variable = false>
</cfif>
<cfsavecontent variable="responseXml">
<?xml version="1.0"?>
<root>
    <timeout>
		<cfoutput>#variable#</cfoutput>
	<timeout>
</root>
</cfsavecontent>
<cfscript>
        getPageContext().getOut().clearBuffer();
        writeOutput(responseXml);
</cfscript> --->