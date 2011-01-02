<cfset q_getSections = application.getSectionList()>
<cfparam name="form.sitesectionid" default="">
<cfoutput>
	<select name="sitesectionID" id="sitesectionID" onchange="javascript:changeTemplate(this.value);">
		<cfloop query="q_getSections">
			<option value="#q_getSections.id#~#q_getSections.sectionpath#"<cfif trim(form.sitesectionID) EQ q_getSections.id> SELECTED</cfif>>#q_getSections.sectionpath#
		</cfloop>
	</select>
</cfoutput>