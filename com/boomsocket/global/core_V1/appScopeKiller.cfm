<cfif IsDefined('session.i3CurrentTool') AND Len(Trim(session.i3CurrentTool)) AND IsDefined('Application.tool')>
	<cfset magicKey = StructFindValue(Application.tool, session.i3CurrentTool)>
	<cfif IsDefined('magicKey') AND ISArray(magicKey) AND ArrayLen(magicKey) AND Len(Trim(magicKey[1].key))>
		<cfswitch expression="#magicKey[1].key#">
			<cfcase value="dynamicnavigation">
				<cfset StructDelete(application, 'allnavigation')>
			</cfcase>
			<cfcase value="dynamicnavigationgroup">
				<cfset StructDelete(application, 'allnavsettings')>
				<cfset StructDelete(application, 'allnavigation')>
			</cfcase>
			<cfcase value="javascript">
				<cfset StructDelete(application, 'q_getjavascript')>
			</cfcase>
			<cfcase value="page">
				<cfset StructDelete(application, 'q_getpageinfoload')>
			</cfcase>
			<cfcase value="pageComponentWizard">
				<cfset StructDelete(application, 'q_getpageinfoload')>
			</cfcase>
			<cfcase value="sitesection">
				<cfset StructDelete(application, 'q_getpageinfoload')>
			</cfcase>
			<cfcase value="template">
				<cfset StructDelete(application, 'q_getpageinfoload')>
			</cfcase>
		</cfswitch>
	</cfif>
</cfif>