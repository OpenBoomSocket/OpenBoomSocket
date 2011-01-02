<cfset request.q_getForm=q_getForm>
<cfparam name="request.selectaction" default="search">
<cfmodule template="#application.customTagPath#/formInstanceFilterSiteSection.cfm" selectaction="#request.selectaction#">