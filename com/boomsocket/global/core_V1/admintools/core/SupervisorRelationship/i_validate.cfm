<cfparam name="form.supervisorid" default="">
<cfparam name="form.userid" default="">
<cfparam name="form.formobject" default="">

<cfparam name="request.isError" default="0">
<cfparam name="request.errorMsg" default="">

<cfif NOT len(trim(form.supervisorid))>
	<cfset request.isError=1>
	<cfset request.errorMsg=request.errorMsg&"<li>Supervisor is Required.</li>">
</cfif>
<cfif NOT len(trim(form.userid))>
	<cfset request.isError=1>
	<cfset request.errorMsg=request.errorMsg&"<li>Users are Required.</li>">
</cfif>
<cfif NOT len(trim(form.formobject))>
	<cfset request.isError=1>
	<cfset request.errorMsg=request.errorMsg&"<li>Tools are Required.</li>">
</cfif>

<cfif request.isError>
	<cfinclude template="i_killLabels.cfm">
	<cfset SRstep="add">
<cfelse>
	<cfset SRstep="confirmAdd">
</cfif>
