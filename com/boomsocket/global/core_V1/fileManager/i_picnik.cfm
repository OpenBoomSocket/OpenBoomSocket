<!--- Saves a returned picnik file over the orginal file --->
<cfoutput> 
<cfmodule template="#application.customTagPath#/adminskin.cfm" admintemplate="popup" css="" headertext="Picnik Image Editor" <!--- onload="setTimeout(window.close, 3000)" --->>
<cfif isdefined("COOKIE.picnikFilePath")>

	<cfif isdefined("URL.file")>
		<cfset imagePath = #APPLICATION.INSTALLPATH#&'\'&listgetat(COOKIE.picnikFilePath,1,'/')&'\'&listgetat(COOKIE.picnikFilePath,2,'/')&'\'>
		<cfset imageName = listlast(COOKIE.picnikFilePath,'/')>

		
		<cftry>
			<cfhttp url="#url.file#" method="put" resolveurl="no" throwonerror="yes" getasbinary="yes" path="#imagePath#" file="#imageName#" /> 
			<p><h2>Image Has Been Successfully Edited</h2></p>
		<cfcatch>
			<h2>Error Overwriting File</h2>
		</cfcatch>
		</cftry>
	<cfelse>
		<h2>Picnik URL Not Found</h2>
	</cfif>	
<cfcookie name="picnikFilePath" expires="now">
<cfelse>
	<h2>Cookie Timed Out or Cookies Are Diabled, Make Sure Cookies Are Enabled To Edit Picture</h2>
</cfif>
</cfmodule>
</cfoutput>