<cfif request.debug>
	<cfoutput>
		#attributes.message#<br />
		#attributes.detail#<br />
	</cfoutput>
	<cfabort>
<cfelse>
<cfmail to="#application.adminemail#" from="#application.adminemail#" subject="ERROR on :#application.installurl#/#cgi.script_name#">
#attributes.message#<br />
#attributes.detail#<br />
</cfmail>
</cfif>