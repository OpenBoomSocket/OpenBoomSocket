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

	<div class="dashboardSidebarHdr">
	<div class="dashboardSidebarHdrLeft">Glossary</div>
	<div class="dashboardSidebarHdrRight"><a href="/admintools/index.cfm?adminPage=glossary.cfm"><b>View All</b><div class="viewAllArrow"><img onclick="" src="#APPLICATION.globalpath#/media/images/icon_viewallarrow.gif" /></div></a></div>
	</div>
	<div class="dashboardSidebarBlock">
		<cfif NOT isdefined("SESSION.pageCurrentlyOn")>
			<cfset SESSION.pageCurrentlyOn = URL.adminPage>
		<cfelse>
			<cfif SESSION.pageCurrentlyOn NEQ URL.adminPage>
				<cfset structDelete(SESSION,"glossaryPlandomItemArray")>
				<cfset SESSION.pageCurrentlyOn = URL.adminPage>
			</cfif>
		</cfif>
		<cfif NOT isdefined("SESSION.glossaryPlandomItemArray") OR ArrayLen(SESSION.glossaryPlandomItemArray) EQ 0>
			<cfset SESSION.glossaryPlandomItemArray = Arraynew(1)>
			<cfset plandomIndex = 1>
			<cfloop index="k" from="1" to="#arrayLen(glossaryDataArray)#">
				<cfset glossaryItemArray = XMLSearch(glossaryDataArray[k],'/rss/channel/item')>
				<cfloop index="item" from="1" to="#ArrayLen(glossaryItemArray)#">
					<cfset glossaryItemCategoryArray = XMLSearch(glossaryItemArray[item],'/rss/channel/item[#item#]/category')>
					<cfset glossaryItemCategoryList = "">
					<cfloop index="cat" from="1" to="#arrayLen(glossaryItemCategoryArray)#">
						<cfset glossaryItemCategoryList = listAppend(glossaryItemCategoryList,glossaryItemCategoryArray[cat].xmltext)>
					</cfloop>
					<cfif isDefined("URL.adminPage") AND  len(trim(URL.adminPage)) AND listFindNoCase(glossaryItemCategoryList,URL.adminpage,',') GTE 1>
						<cfset ArrayAppend(SESSION.glossaryPlandomItemArray,glossaryItemArray[item])>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		
		<cfif ArrayLen(SESSION.glossaryPlandomItemArray) EQ 0>
			<cfset SESSION.glossaryPlandomItemArray = XMLSearch(glossaryDataArray[1],"/rss/channel/item")>
		</cfif>

				
		<cfset randNum = randrange(1,ArrayLen(SESSION.glossaryPlandomItemArray))>
		<div class="glossaryTitle"><b>#SESSION.glossaryPlandomItemArray[randNum].title.xmlText#</b></div>
		<div class="glossaryDescription">#SESSION.glossaryPlandomItemArray[randNum].description.xmlText#</div>
		<cfset ArrayDeleteAt(SESSION.glossaryPlandomItemArray,randNum)>		
	</div>
</cfoutput>