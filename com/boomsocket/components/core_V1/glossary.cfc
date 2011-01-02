<!---Edited to search xml instead of database--->
<cfcomponent>
<cffunction name="getItems" returntype="array">
	<cfargument name="searchString" required="yes" type="string">
	<cfargument name="glossaryFileURL" required="yes" type="string">
		<cfscript>
			glossaryDataArray = ArrayNew(1);
			newItemArray = ArrayNew(1);
		</cfscript>
		<cfif FileExists(glossaryFileURL)>
			<cffile action="read" file="#(glossaryFileURL)#" variable="glossaryDataRAW">
			<cfset arrayAppend(glossaryDataArray, xmlParse(glossaryDataRAW))>
		</cfif>
		<cfloop index="k" from="1" to="#arrayLen(glossaryDataArray)#">
			<cfset glossaryItemArray = XMLSearch(glossaryDataArray[k],'/rss/channel/item')>
			<cfloop index="item" from="1" to="#arrayLen(glossaryItemArray)#">
				<cfif findnocase(searchString,glossaryItemArray[item].title.xmlText) NEQ 0 ><cfset arrayappend(newItemArray,glossaryItemArray[item])></cfif>
			</cfloop>
			<cfloop index="item2" from="1" to="#arrayLen(glossaryItemArray)#">
				<cfif findnocase(searchString,glossaryItemArray[item2].title.xmlText) EQ 0  AND findnocase(searchString,glossaryItemArray[item2].description.xmlText) NEQ 0><cfset arrayappend(newItemArray,glossaryItemArray[item2])></cfif>
			</cfloop>
		</cfloop>
		<cfreturn newItemArray>
		
	</cffunction>
</cfcomponent>



	<!--- <cffunction name="queryForTerms" access="public" returntype="query">
		<cfargument name="groupBy" type="boolean" required="no" default="false">
		<cfargument name="searchStr" type="string" required="no" default="">
		<cfquery datasource="dpcorp" name="q_getTerms">
			SELECT glossaryid, category, glossaryName, definition
			FROM glossary
			WHERE active = 1
			<cfif len(arguments.searchStr)>
				AND glossaryname LIKE '%#arguments.searchStr#%' OR definition LIKE '%#arguments.searchStr#%'
			</cfif>
			ORDER BY 
			<cfif arguments.groupBy>
			
				category ASC,
			</cfif>
			 glossaryname ASC
		</cfquery>
		<cfreturn q_getTerms>
	</cffunction>
	<cffunction name="showTerms" access="public" returntype="string">
		<cfargument name="groupBy" type="boolean" required="no" default="false">
		<cfargument name="searchStr" type="string" required="no" default="">
		<cfset q_getAllTerms=queryForTerms(arguments.groupBy,arguments.searchStr)>
		<cfsavecontent variable="outputStr">
			<cfif arguments.groupBy>
				<cfoutput query="q_getAllTerms" group="category">
					<div class="glossaryCategory"><div style="float:right;"><a href="#request.page#?groupBy=true" style="color:##FFFFFF;">Top</a></div>#q_getAllTerms.category#</div>
					<cfoutput>
						<div class="glossaryDefinition">
							<a name="#q_getAllTerms.glossaryid#"><strong>#q_getAllTerms.glossaryname#</strong></a> - #q_getAllTerms.definition#
						</div>
					</cfoutput>
				</cfoutput> 
			<cfelse>
				<cfoutput query="q_getAllTerms">
					<div class="glossaryDefinition">
						<a name="#q_getAllTerms.glossaryid#"><strong>#q_getAllTerms.glossaryname#</strong></a> - #q_getAllTerms.definition#
					</div>
				</cfoutput>
			</cfif>
		</cfsavecontent>
		<cfreturn outputStr>
	</cffunction> --->
