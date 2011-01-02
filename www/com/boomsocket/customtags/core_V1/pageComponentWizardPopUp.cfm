<cfif thisTag.executionmode EQ "start">
	<cfswitch expression="#attributes.showPop#">
		<cfcase value="contentElement">
			<cfinclude template="#application.globalPath#/admintools/includes/pageComponentWizard/contentpopup.cfm">
		</cfcase>
		<cfcase value="displayHandler">
			<cfinclude template="#application.globalPath#/admintools/includes/pageComponentWizard/dhpopup.cfm">		
		</cfcase>
	</cfswitch>
</cfif>