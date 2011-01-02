<!--- Display all FAQ content driven from the RSS feed --->
<cfsilent>
	<cfscript>
		faqFileURL = "#Application.globalPath#/admintools/feeds";
	    faqFileNameArray = arrayNew(1);
		faqFileNameArray[1] = '#faqFileURL#/core_faqs_rss.xml';
		faqFileNameArray[2] = '#faqFileURL#/custom_faqs_rss.xml';
		faqDataArray = ArrayNew(1);
	</cfscript>
    <cfloop index="i" from="1" to="#arrayLen(faqFileNameArray)#">
    	<cfif left(faqFileNameArray[i],1) EQ '/' AND FileExists(expandPath(faqFileNameArray[i]))>
            <cffile action="read" file="#expandPath(faqFileNameArray[i])#" variable="faqDataRAW">
            <cfset arrayAppend(faqDataArray, xmlParse(faqDataRAW))>
        </cfif>
    </cfloop>
</cfsilent>
<cfoutput>

<script type="text/javascript">
		
	currentFAQ = null;
	underlined = false;
		
	function displayAnswer(itemid)
	{
		if (currentFAQ != itemid)
		{
			if (currentFAQ != null)
				document.getElementById('faqAnswer_'+currentFAQ).style.display='none';
			document.getElementById('faqAnswer_'+itemid).style.display='block';

		}
		else
		{
			if (document.getElementById('faqAnswer_'+itemid).style.display == 'none')
				document.getElementById('faqAnswer_'+itemid).style.display='block';
			else
				document.getElementById('faqAnswer_'+itemid).style.display='none'
		}
		currentFAQ = itemid;
	}
	
	function underlineDiv(itemid)
	{
		var initialColor = "##196CCF";
		if(!underlined)
		{
			document.getElementById('faqQuestion_'+itemid).style.textDecoration ="underline";
			underlined = true;
		}
		else
		{
			document.getElementById('faqQuestion_'+itemid).style.color = initialColor;
			document.getElementById('faqQuestion_'+itemid).style.textDecoration ="none"
			underlined = false;
		}
	}	
</script>



<div id="dashboardPageShell">
	<div id="dashboardPageLeft">
		<h1>FAQs</h1>
		<cfloop index="k" from="1" to="#arrayLen(faqDataArray)#">
			<cfset siteContentList= "Site.cfm,Content.cfm,Sockets.cfm,Developer.cfm,Admin.cfm">
			<cfset faqItemArray = XMLSearch(faqDataArray[k],'/rss/channel/item')>
			<cfset faqCategoryArray = XMLSearch(faqDataArray[k],'/rss/channel/item/category')>
			<cfset faqItemList = "">
			<cfset faqCategoryList = "">
			<cfloop index="category" from="1" to="#ArrayLen(faqCategoryArray)#">
				<cfif NOT listcontains(faqCategoryList,faqCategoryArray[category]) AND listcontains(siteContentList,faqCategoryArray[category].xmlText)>
					<h3>#left(faqCategoryArray[category].xmlText,len(trim(faqCategoryArray[category].xmlText))-4)#</h3>
					<div class="faqQuestionBlock">
						<cfset faqCategoryList = listappend(faqCategoryList,faqCategoryArray[category])>
						<cfloop index="item" from="1" to="#ArrayLen(faqItemArray)#">
							<cfif NOT listfindnocase(faqItemList,faqItemArray[item].title.xmlText,',')>
								<cfset faqItemCategoryArray = XMLSearch(faqItemArray[item],'/rss/channel/item[#item#]/category')>
								<cfloop index="itemCat" from="1" to="#ArrayLen(faqItemCategoryArray)#">
									<cfif faqItemCategoryArray[itemCat].xmlText EQ faqCategoryArray[category].xmlText>
										<cfset faqItemList = listappend(faqItemList,faqItemArray[item].title.xmlText)>								
										<a name="#faqItemArray[item].title.xmlText#"><div id='faqQuestion_#faqItemArray[item].guid.xmlText#'class="faqQuestion" title="Click here to get answer" style="cursor:pointer" onclick="displayAnswer('#faqItemArray[item].guid.xmlText#')" onmouseover="underlineDiv('#faqItemArray[item].guid.xmlText#')" onmouseout="underlineDiv('#faqItemArray[item].guid.xmlText#') "><b>#faqItemArray[item].title.xmlText#</b></div></a>
										<div id='faqAnswer_#faqItemArray[item].guid.xmlText#' class="faqAnswer" style="display:none;">#faqItemArray[item].description.xmlText#</div>
									</cfif>
								</cfloop>
							
							</cfif>
						</cfloop>
					</div>
				</cfif>
			</cfloop>
		</cfloop>
		
		
	</div>
	<div id="dashboardPageRight">
		<cfinclude template="#APPLICATION.globalPath#/admintools/includes/widgets/i_userinfo.cfm">
		<cfinclude template="#APPLICATION.globalPath#/admintools/includes/widgets/i_tip.cfm">
		<cfinclude template="/#APPLICATION.globalPath#/admintools/includes/widgets/i_glossary.cfm">

	</div>
	<div style="clear:both">
</div>
<cfif isdefined("URL.faqid") AND len(trim(URL.faqid))>
	<script type="text/javascript">
		displayAnswer('#URL.faqid#');
	</script>
</cfif>

</cfoutput>
