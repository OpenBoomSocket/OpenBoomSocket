<!--- Display all Tip content driven from the RSS feed --->
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
<div id="dashboardPageShell">
	<div id="dashboardPageLeft">
		<h1>Tips &amp; Tricks</h1>
		<cfloop index="k" from="1" to="#arrayLen(tipDataArray)#">
			<cfset siteContentList= "Site.cfm,Content.cfm,Sockets.cfm,Developer.cfm,Admin.cfm">
			<cfset tipItemArray = XMLSearch(tipDataArray[k],'/rss/channel/item')>
			<cfset tipCategoryArray = XMLSearch(tipDataArray[k],'/rss/channel/item/category')>
			<cfset tipItemList = "">
			<cfset tipCategoryList = "">
			<cfloop index="category" from="1" to="#ArrayLen(tipCategoryArray)#">
				<cfif NOT listcontains(tipCategoryList,tipCategoryArray[category]) AND listcontains(siteContentList,tipCategoryArray[category].xmlText)>
					<h3>#left(tipCategoryArray[category].xmlText,len(trim(tipCategoryArray[category].xmlText))-4)#</h3>
					<cfset tipCategoryList = listappend(tipCategoryList,tipCategoryArray[category])>
					<cfloop index="item" from="1" to="#ArrayLen(tipItemArray)#">
						<cfif NOT listfindnocase(tipItemList,tipItemArray[item].title.xmlText,',')>
							<cfset tipItemCategoryArray = XMLSearch(tipItemArray[item],'/rss/channel/item[#item#]/category')>
							<cfloop index="itemCat" from="1" to="#ArrayLen(tipItemCategoryArray)#">
								<cfif tipItemCategoryArray[itemCat].xmlText EQ tipCategoryArray[category].xmlText>
									<cfset tipItemList = listappend(tipItemList,tipItemArray[item].title.xmlText)>								
									<a name="#tipItemArray[item].title.xmlText#"><div class="tipTitle"><b>#tipItemArray[item].title.xmlText#</b></div></a>
									<div class="tipBody">#tipItemArray[item].description.xmlText#</div>
								</cfif>
							</cfloop>
						
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfloop>
		
		
	</div>
	<div id="dashboardPageRight">
		<cfinclude template="#APPLICATION.globalPath#/admintools/includes/widgets/i_userinfo.cfm">
		<cfinclude template="#APPLICATION.globalPath#/admintools/includes/widgets/i_faq.cfm">
		<cfinclude template="/#APPLICATION.globalPath#/admintools/includes/widgets/i_glossary.cfm">
	</div>
	<div style="clear:both">
</div>
</cfoutput>
