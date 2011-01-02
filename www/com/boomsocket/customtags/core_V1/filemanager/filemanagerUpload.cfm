<cfif thisTag.executionmode EQ 'start'>
<cfset defaultaction="fileform">
<cfparam name="formaction" default="#defaultaction#">
<cfparam name="request.formaction" default="#formaction#">
<cfparam name="request.variablepass" default="#CGI.QUERY_STRING#">

<cfif NOT findNoCase("formaction",request.variablepass,1)>
	<cfset request.variablepass=request.variablepass&"&formaction=#formaction#">
</cfif>
<cfif NOT findNoCase("callingfield",request.variablepass,1)>
	<cfset request.variablepass=request.variablepass&"&callingfield=0">
</cfif>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Upload Manager</title>

</head>
<cfoutput>
<!-- frames -->
<frameset  cols="55%,*">

    <frame name="left" src="/admintools/core/filemanager/filemanager.cfm?<cfif len(request.variablepass)>#request.variablepass#"<cfelse>formaction=#formaction#</cfif>" marginwidth="0" marginheight="0" scrolling="No" frameborder="0">
<cfif len(request.variablepass) AND formaction NEQ "browse">
	<cfset request.variablepass=ReplaceNoCase(request.variablepass,"#formaction#","browse","all")>
<cfelse>
	<cfset request.variablepass="formaction=browse">
</cfif>
    <frame src="/admintools/core/filemanager/filemanager.cfm?#request.variablepass#" name="right" id="right" frameborder="0" scrolling="Auto" marginwidth="0" marginheight="0">
</frameset><noframes></noframes>
</cfoutput>

</html>
</cfif>