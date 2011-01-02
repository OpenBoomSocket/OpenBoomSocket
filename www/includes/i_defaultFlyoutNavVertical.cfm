<cfinclude template="/css/navigation/defaultFlyoutVertical.cfm">
<cfsavecontent variable="defaultFlyoutVertical"><cfoutput><cfmodule template="#APPLICATION.customTagPath#/nav.cfm" navgroupid="100000" classbase="defaultFlyoutVertical"></cfoutput></cfsavecontent>
<cfoutput>#defaultFlyoutVertical#</cfoutput>