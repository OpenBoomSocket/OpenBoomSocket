<cfcomponent>
	<cffunction name="geti3FAQs" access="public" returntype="query">
		<cfargument name="i3faqsID" displayname="i3FAQs ID" required="no" type="numeric">
		<cfargument name="searchStr" displayname="Search String" required="no" type="string">
		<cfset var q_getFAQs = ''>
		<cftry>
			<cfquery name="q_getFAQs" datasource="dpcorp" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT i3faqsID, i3faqsname, i3faqsanswer, i3faqscategoryname
				FROM i3faqs
					INNER JOIN i3faqscategory ON i3faqscategory.i3faqscategoryid = i3faqs.i3faqscategoryid
				WHERE i3faqs.active = 1
				AND i3faqscategory.active = 1
				<cfif IsDefined('arguments.i3faqsID') AND IsNumeric(arguments.i3faqsID)>
					AND i3faqsID = #arguments.i3faqsID#
				</cfif>
				<cfif isDefined('arguments.searchStr') AND len(arguments.searchStr)>
					AND (i3faqsname LIKE '%#arguments.searchStr#%' OR i3faqsanswer LIKE '%#arguments.searchStr#%')
				</cfif>
				ORDER BY i3faqscategory.ordinal,i3faqs.ordinal
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getFAQs>
	</cffunction>
</cfcomponent>