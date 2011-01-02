<cfsilent>
	<cfscript>
		tipFileURL = "#Application.globalPath#/admintools/feeds";
	    tipFileNameArray = arrayNew(1);
		tipFileNameArray[1] = '#tipFileURL#/core_tips_rss.xml';
		tipFileNameArray[2] = '#tipFileURL#/custom_tips_rss.xml';
		tipDataArray = ArrayNew(1);
	</cfscript>
    <cfloop index="i" from="1" to="#arrayLen(tipFileNameArray)#">
    	<cfif left(tipFileNameArray[i],1) EQ '/' AND FileExists(expandPath(tipFileNameArray[i]))>
            <cffile action="read" file="#expandPath(tipFileNameArray[i])#" variable="tipDataRAW">
            <cfset arrayAppend(tipDataArray, xmlParse(tipDataRAW))>
        </cfif>
    </cfloop>
</cfsilent>
<cfoutput>
	<div class="dashboardSidebarHdr">
	<div class="dashboardSidebarHdrLeft">Tips</div>
	<div class="dashboardSidebarHdrRight"><a href="/admintools/index.cfm?adminPage=tips.cfm"><b>View All</b><div class="viewAllArrow"><img src="#APPLICATION.globalpath#/media/images/icon_viewallarrow.gif" /></div></a></div>
	</div>
	<div class="dashboardSidebarBlock">
		<cfif NOT isdefined("SESSION.pageCurrentlyOn")>
			<cfset SESSION.pageCurrentlyOn = URL.adminPage>
		<cfelse>
			<cfif SESSION.pageCurrentlyOn NEQ URL.adminPage>
				<cfset structDelete(SESSION,"tipPlandomItemArray")>
				<cfset SESSION.pageCurrentlyOn = URL.adminPage> 
			</cfif>
		</cfif>
		
		<cfif NOT isdefined("SESSION.tipPlandomItemArray") OR ArrayLen(SESSION.tipPlandomItemArray) EQ 0>
			<cfset SESSION.tipPlandomItemArray = Arraynew(1)>
			<cfset plandomIndex = 1>
			<cfloop index="k" from="1" to="#arrayLen(tipDataArray)#">
				<cfset tipItemArray = XMLSearch(tipDataArray[k],"/rss/channel/item")>
				<cfloop index="item" from="1" to="#arrayLen(tipItemArray)#">
					<cfset tipCategoryArray = XMLSearch(tipItemArray[item],"/rss/channel/item[#item#]/category")>
					<cfloop index="cat" from="1" to="#arrayLen(tipCategoryArray)#">
						<cfif isDefined("URL.adminPage") AND  len(trim(URL.adminPage)) AND tipCategoryArray[cat].xmltext EQ #URL.adminPage#>
							<cfset ArrayAppend(SESSION.tipPlandomItemArray,tipItemArray[item])>
							<cfbreak>
						</cfif>
					</cfloop>
				</cfloop>
			</cfloop>			
		</cfif>
		<cfif ArrayLen(SESSION.tipPlandomItemArray) EQ 0>
			<cfset SESSION.tipPlandomItemArray = XMLSearch(tipDataArray[1],"/rss/channel/item")>
		</cfif>
		
		<cfset randNum = randrange(1,ArrayLen(SESSION.tipPlandomItemArray))>
		<div class="tipTitle"><b>#SESSION.tipPlandomItemArray[randNum].title.xmlText#</b></div>
		<div class="tipBody">#SESSION.tipPlandomItemArray[randNum].description.xmlText#</div>
		<cfset ArrayDeleteAt(SESSION.tipPlandomItemArray,randNum)>
	</div>
</cfoutput>
