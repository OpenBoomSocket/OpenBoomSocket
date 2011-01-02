<!---Edited to search xml instead of database--->
<cfcomponent>
<cffunction name="getItems" returntype="array">
	<cfargument name="searchString" required="yes" type="string">
	<cfargument name="faqFileURL1" required="yes" type="string">
	<cfargument name="faqFileURL2" required="yes" type="string">
		<cfscript>
			faqDataArray = ArrayNew(1);
			newItemArray = ArrayNew(1);
		</cfscript>
		<cfif FileExists(faqFileURL1)>
			<cffile action="read" file="#(faqFileURL1)#" variable="faqDataRAW">
			<cfset arrayAppend(faqDataArray, xmlParse(faqDataRAW))>
		</cfif>
		<cfif FileExists(faqFileURL2)>
			<cffile action="read" file="#(faqFileURL2)#" variable="faqDataRAW2">
			<cfset arrayAppend(faqDataArray, xmlParse(faqDataRAW2))>
		</cfif>
		
		<cfloop index="k" from="1" to="#arrayLen(faqDataArray)#">
			<cfset faqItemArray = XMLSearch(faqDataArray[k],'/rss/channel/item')>
			<cfloop index="item" from="1" to="#arrayLen(faqItemArray)#">
				<cfif findnocase(searchString,faqItemArray[item].title.xmlText) NEQ 0 ><cfset arrayappend(newItemArray,faqItemArray[item])></cfif>
			</cfloop>
			<cfloop index="item2" from="1" to="#arrayLen(faqItemArray)#">
				<cfif findnocase(searchString,faqItemArray[item2].title.xmlText) EQ 0  AND findnocase(searchString,faqItemArray[item2].description.xmlText) NEQ 0><cfset arrayappend(newItemArray,faqItemArray[item2])></cfif>
			</cfloop>
		</cfloop>
		<cfreturn newItemArray>
	</cffunction>
</cfcomponent>

<!--- 
<cfcomponent>
	<cffunction name="geti3FAQs" access="public" returntype="query">
		<cfargument name="i3faqsID" displayname="i3FAQs ID" required="no" type="numeric">
		<cfargument name="searchStr" displayname="Search String" required="no" type="string">
		<cfset var q_getFAQs = ''>
		<cftry>
			<cfquery name="q_getFAQs" datasource="dpcorp">
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
</cfcomponent> --->