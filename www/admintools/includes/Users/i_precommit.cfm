<!--- i_precommit.cfm --->
<cfif IsDefined('FORM.password') and Len(Trim(FORM.password))>
	<cfif isdefined('application.useStrongEncryption') AND application.useStrongEncryption>
		<cfset useThisPass = trim(form.password)&application.saltEncrypt>
		<cfset FORM.password = hash(useThisPass,'SHA-512')>
	<cfelse>
		<cfset useThisPass = trim(form.password)>
		<cfset FORM.password = hash(useThisPass)>
	</cfif>
</cfif>