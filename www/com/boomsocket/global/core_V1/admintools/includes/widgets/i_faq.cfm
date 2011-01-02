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
		currentFAQ = 0;
		underlined = false;
		function displayAnswer(itemid)
		{
			if (currentFAQ != itemid)
			{
				if (currentFAQ > 0)
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
	
	<div class="dashboardSidebarHdr">
	<div class="dashboardSidebarHdrLeft">FAQ</div>
	<div class="dashboardSidebarHdrRight"><a href="/admintools/index.cfm?adminPage=faqs.cfm"><b>View All</b><div class="viewAllArrow"><img onclick="" src="#APPLICATION.globalpath#/media/images/icon_viewallarrow.gif" /></div></a></div>
	</div>
	<div class="dashboardSidebarBlock">
		<cfset atleastone = false>
		<cfloop index="k" from="1" to="#arrayLen(faqDataArray)#">
			<cfset faqItemArray = XMLSearch(faqDataArray[k],'/rss/channel/item')>
			<cfloop index="item" from="1" to="#ArrayLen(faqItemArray)#">
				<cfset faqItemCategoryArray = XMLSearch(faqItemArray[item],'/rss/channel/item[#item#]/category')>
				<cfset faqItemCategoryList = "">
				<cfloop index="cat" from="1" to="#arrayLen(faqItemCategoryArray)#">
					<cfset faqItemCategoryList = listAppend(faqItemCategoryList,faqItemCategoryArray[cat].xmltext)>
				</cfloop>
				<cfif isDefined("URL.adminPage") AND  len(trim(URL.adminPage)) AND listFindNoCase(faqItemCategoryList,URL.adminpage,',') GTE 1>
					<div id='faqQuestion_#item#'class="faqQuestion" title="Click here to get answer" style="cursor:pointer" onclick="displayAnswer(#item#)" onmouseover="underlineDiv(#item#)" onmouseout="underlineDiv(#item#)"><b>#faqItemArray[item].title.xmlText#</b></div> 
					<div id='faqAnswer_#item#' class="faqAnswer" style="display:none;">#faqItemArray[item].description.xmlText#</div>
					<cfset atleastone = true>
				</cfif>
			</cfloop>
		</cfloop>
		<cfif NOT atleastone>
			<cfset faqItemArray = XMLSearch(faqDataArray[1],'/rss/channel/item')>
			<cfset item = randrange(1,arrayLen(faqItemArray))>
			<div id='faqQuestion_#item#'class="faqQuestion" title="Click here to get answer" style="cursor:pointer" onclick="displayAnswer(#item#)" onmouseover="underlineDiv(#item#)" onmouseout="underlineDiv(#item#)"><b>#faqItemArray[item].title.xmlText#</b></div> 
			<div id='faqAnswer_#item#' class="faqAnswer" style="display:none;">#faqItemArray[item].description.xmlText#</div>
		</cfif>					
	</div>
</cfoutput>