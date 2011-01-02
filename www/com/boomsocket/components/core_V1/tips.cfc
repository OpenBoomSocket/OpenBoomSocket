<!---Edited to search xml instead of database--->
<cfcomponent>
<cffunction name="getItems" returntype="array">
	<cfargument name="searchString" required="yes" type="string">
	<cfargument name="tipFileURL1" required="yes" type="string">
	<cfargument name="tipFileURL2" required="yes" type="string">
		<cfscript>
			tipDataArray = ArrayNew(1);
			newItemArray = ArrayNew(1);
		</cfscript>
		<cfif FileExists(tipFileURL1)>
			<cffile action="read" file="#(tipFileURL1)#" variable="tipDataRAW">
			<cfset arrayAppend(tipDataArray, xmlParse(tipDataRAW))>
		</cfif>
		<cfif FileExists(tipFileURL2)>
			<cffile action="read" file="#(tipFileURL2)#" variable="tipDataRAW2">
			<cfset arrayAppend(tipDataArray, xmlParse(tipDataRAW2))>
		</cfif>
		
		<cfloop index="k" from="1" to="#arrayLen(tipDataArray)#">
			<cfset tipItemArray = XMLSearch(tipDataArray[k],'/rss/channel/item')>
			<cfloop index="item" from="1" to="#arrayLen(tipItemArray)#">
				<cfif findnocase(searchString,tipItemArray[item].title.xmlText) NEQ 0 ><cfset arrayappend(newItemArray,tipItemArray[item])></cfif>
			</cfloop>
			<cfloop index="item2" from="1" to="#arrayLen(tipItemArray)#">
				<cfif findnocase(searchString,tipItemArray[item2].title.xmlText) EQ 0  AND findnocase(searchString,tipItemArray[item2].description.xmlText) NEQ 0><cfset arrayappend(newItemArray,tipItemArray[item2])></cfif>
			</cfloop>
		</cfloop>
		<cfreturn newItemArray>
	</cffunction>
</cfcomponent>