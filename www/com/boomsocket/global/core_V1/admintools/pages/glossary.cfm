<cfsilent>
	<cfscript>
		glossaryFileURL = "#Application.globalPath#/admintools/feeds";
	    glossaryFileNameArray = arrayNew(1);
		glossaryFileNameArray[1] = '#glossaryFileURL#/glossary_rss.xml';
		glossaryDataArray = ArrayNew(1);
	</cfscript>
    <cfloop index="i" from="1" to="#arrayLen(glossaryFileNameArray)#">
    	<cfif left(glossaryFileNameArray[i],1) EQ '/' AND FileExists(expandPath(glossaryFileNameArray[i]))>
            <cffile action="read" file="#expandPath(glossaryFileNameArray[i])#" variable="glossaryDataRAW">
            <cfset arrayAppend(glossaryDataArray, xmlParse(glossaryDataRAW))>
        </cfif>
    </cfloop>
</cfsilent>
<cfoutput>
<div id="dashboardPageShell">
	<div id="dashboardPageLeft">
		
			<h1>Glossary of Terms</h1>
			<cfloop index="k" from="1" to="#arrayLen(glossaryDataArray)#">
				<cfset glossaryItemArray = alphabetize(XMLSearch(glossaryDataArray[k],'/rss/channel/item'))>
				<cfloop index="item" from="1" to="#arrayLen(glossaryItemArray)#">
					<a name="#glossaryItemArray[item].title.xmlText#"><div class="glossaryTitle"><b>#glossaryItemArray[item].title.xmlText#</b>- </div></a>
					<div class="glossaryDescription">#glossaryItemArray[item].description.xmlText#</div>
				</cfloop>
			</cfloop>
	</div>

	<div id="dashboardPageRight">
			<cfinclude template="/#APPLICATION.globalPath#/admintools/includes/widgets/i_userinfo.cfm">
			<cfinclude template="/#APPLICATION.globalPath#/admintools/includes/widgets/i_tip.cfm">
			<cfinclude template="/#APPLICATION.globalPath#/admintools/includes/widgets/i_faq.cfm">
	</div>
	<div style="clear:both">
</div>

</cfoutput>

<cffunction name="alphabetize" returntype="array">
	<cfargument name="itemArray" type="array" required="yes">
	<cfset newItemArray = arraynew(1)>
	<cfloop index="i" from="1" to="#arrayLen(itemArray)#">
		<cfset itemTitle = itemArray[i].title.xmlText>
		<cfset j = 1>
		<cfif j GT arraylen(newItemArray)>
			<cfset ArrayAppend(newItemArray,itemArray[i])>
		<cfelseif compare(newItemArray[j].title.xmlText,itemTitle) EQ 1>
			<cfset ArrayInsertAt(newItemArray,j,itemArray[i])>
		<cfelse>
			<cfset j = j+1>
			<cfset inserted = false>
			<cfloop condition="j LTE #arraylen(newItemArray)#">
				<cfif compare(newItemArray[j].title.xmlText,itemTitle) EQ 1>
					<cfset ArrayInsertAt(newItemArray,j,itemArray[i])>
					<cfset inserted = true>
					<cfbreak>
				</cfif>
				<cfset j = j+1>
			</cfloop>
			<cfif NOT inserted>
				<cfset ArrayAppend(newItemArray,itemArray[i])>
			</cfif>
		</cfif>
	</cfloop>
	<cfreturn newItemArray>
</cffunction>

