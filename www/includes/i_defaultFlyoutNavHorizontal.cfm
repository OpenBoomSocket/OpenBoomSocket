<cfinclude template="/css/navigation/defaultFlyoutHorizontal.cfm">
<cfsavecontent variable="defaultFlyoutHorizontal"><cfoutput><cfmodule template="#APPLICATION.customTagPath#/nav.cfm" navgroupid="100000" classbase="defaultFlyoutHorizontal"></cfoutput></cfsavecontent>
<cfoutput>#defaultFlyoutHorizontal#</cfoutput>
