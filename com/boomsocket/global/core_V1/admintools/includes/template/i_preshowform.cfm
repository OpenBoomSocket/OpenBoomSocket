<!--- i_preshowform.cfm --->
<cfif isDefined("instanceid")>
	<cfset thisIntanceid=instanceid>
<cfelse>
	<cfset thisIntanceid=0>
</cfif>
<cfquery datasource="#application.datasource#" name="q_gettemplate" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT templatefilename
	FROM #q_getform.datatable#
	WHERE #q_getform.datatable#ID = #thisIntanceid#
</cfquery>

<cfif fileExists("#application.templatepath#\#q_gettemplate.templatefilename#")>
	<cffile action="READ"
        file="#application.templatepath#\#q_gettemplate.templatefilename#"
        variable="form.html">
<cfelse>
	<cfif NOT IsDefined('form.html') OR Len(Trim(form.html)) EQ 0>
		<cfsavecontent variable="form.html">
<!-- Replace with your HTML template code here. -->
<table width="600" border="1" cellspacing="0" cellpadding="3" align="center">
<tr>
	<td colspan="2">[[Header^0]]</td>
</tr>
<tr>
	<td width="200">[[leftnav^0]]</td>
	<td width="400">[[Body^0]]</td>
</tr>
</table>
		</cfsavecontent>
	</cfif>
	<cfif NOT IsDefined('form.wireframe') OR Len(Trim(form.wireframe)) EQ 0>
		<cfsavecontent variable="form.wireframe">
<!-- WIREFRAME TEMPLATE -->
<table width="600" border="0" cellspacing="5" cellpadding="8">
	<tr>
		<td colspan="2" bgcolor="#FFFFFF" class="wireFrame" valign="top">[[Header^0]]</td>
	</tr>
	<tr>
		<td width="200" bgcolor="#ffffff" class="wireFrame" valign="top">[[leftnav^0]]</td>
		<td width="400" bgcolor="#ffffff" class="wireFrame" valign="top">[[Body^0]]</td>
	</tr>
</table>
	
		</cfsavecontent>	
	</cfif>	
</cfif>
