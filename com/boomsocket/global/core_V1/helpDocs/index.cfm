<cfparam name="url.searchresults" default="0">
<cfif url.searchresults>
	<cfset glossaryObj = createObject("component","#APPLICATION.cfcpath#.glossary")>
	<cfset glossaryItemArray = glossaryObj.getItems(searchString=form.searchstr, glossaryFileURL=expandpath("#Application.globalPath#/admintools/feeds/glossary_rss.xml"))>
	<cfset faqObj = createObject("component","#APPLICATION.cfcpath#.faqs")>
	<cfset faqItemArray = faqObj.getItems(searchString=form.searchstr, faqFileURL1=expandpath("#Application.globalPath#/admintools/feeds/core_faqs_rss.xml"), faqFileURL2=expandpath("#Application.globalPath#/admintools/feeds/custom_faqs_rss.xml"))>
	<cfset tipObj = createObject("component","#APPLICATION.cfcpath#.tips")>
	<cfset tipItemArray = tipObj.getItems(searchString=form.searchstr, tipFileURL1=expandpath("#Application.globalPath#/admintools/feeds/core_tips_rss.xml"), tipFileURL2=expandpath("#Application.globalPath#/admintools/feeds/custom_tips_rss.xml"))>
</cfif>
<!--- Check to see if Video Help Exists in this Installation --->
<cfquery datasource="#APPLICATION.datasource#" name="q_getHelpVideos">
    SELECT  upload.uploadtitle, upload.uploaddescription, '/uploads/' + uploadcategory.foldername + '/' + upload.filename AS videoPath
    FROM uploadcategory INNER JOIN upload ON uploadcategory.uploadcategoryid = upload.uploadcategoryid
    WHERE (uploadcategory.uploadcategorytitle = 'Help Videos')
</cfquery>


<style type="text/css">
	#helpContainer{
		width:100%;
	}
	#helpDocs{
		padding-left:10px;
	}
	.helpLeftContainer{
		float:left; 
		/*width:49%; CMC 05/04/06: had to wrap in table so border would show correctly in IE*/
		/*border-right:1px solid; CMC 05/04/06: had to wrap in table so border would show correctly in IE*/
		width:50%;		
		height:100%;
		
	}
	* html .helpLeftContainer{
		min-height:100%;
	}
	.helpLeftContentContainer{	
		padding-right:100px;
		padding-top:15px;
		min-height:107px;
	}
	.helpRightContainer{
		float:left; 
		width:45%;
		/*width:50%; CMC 05/04/06: had to wrap in table so border would show correctly in IE*/
	}
	.helpRightContentContainer{
		width:auto; 
		min-height:107px;
		padding-left:100px;
		padding-top:15px;
	}
	.helpHeader{
		font-weight:bold;
		font-size:14px;
		color:#333333;
	}
	.helpContent{

		padding: 5px 0 5px 0;
	}
	.viewLink{
		width:100%;
		text-align:right;
	}
	/*CMC 05/04/06: had to wrap in table so border would show correctly in IE*/
	.cellDivide{
		border-right:1px solid #999;
	}
	.videoItem{
		padding: 4px;
		margin-bottom: 1px;
	}
	.videoItem a{
		font-weight: bold;
	}
	.oddRow{
		background-color:#C2D9EF;
	}
	.evenRow{
		background-color:#D1E0EF;
	}
</style>
<cfoutput>
<!--- Help page grid --->
<div id="helpContainer">

<div id="helpDocs"><a href="#application.globalPath#/helpDocs/boomsocket_user_docs.pdf" target="_blank"><img src="#application.globalPath#/media/images/icon_pdf.gif" border="0" width="14" height="15"/></a> Download the <a href="#application.globalPath#/helpDocs/boomsocket_user_docs.pdf" target="_blank">Open BoomSocket help docs</a></div>
<cfmodule template="#application.customTagPath#/containerShell.cfm" padding="6" width="100%">
<div>
	<div class="helpLeftContainer">	
    	<cfif q_getHelpVideos.recordcount>
			<div class="helpLeftContentContainer">
                <div class="helpHeader">Video Tutorials</div>
                <div class="helpContent">Video tutorials are a great way to learn to use the Open BoomSocket site management system in a fast visual medium. Click on any of the links below to open the tutorial.</div>
               <cfloop query="q_getHelpVideos">
               		<cfif q_getHelpVideos.currentrow MOD 2>
						<cfset thisClass = "evenRow">
                    <cfelse>
                    	<cfset thisClass = "oddRow">
					</cfif>
                    <div class="videoItem #thisClass#"><a href="/admintools/videoTutorials.cfm?video=#q_getHelpVideos.videoPath#" target="_blank">#q_getHelpVideos.uploadtitle#</a><cfif len(trim(q_getHelpVideos.uploaddescription))> - #q_getHelpVideos.uploaddescription#</cfif></div>
               </cfloop>
            </div>
		</cfif>
        <div class="helpLeftContentContainer">
            <div class="helpHeader">Glossary</div>
            <div class="helpContent">Browse the glossary to familiarize yourself with terms and concepts central to understanding Open BoomSocket, Content Management and web sites in general.</div>
            <div class="viewLink"><a href="#request.page#?adminPage=glossary.cfm">View Glossary </a></div>
        </div>	
        <div class="helpLeftContentContainer">
            <div class="helpHeader">Open BoomSocket FAQs</div>
            <div class="helpContent">Got questions? We are quickly building a knowledge base to better answer any questions that you may have as you begin to use Open BoomSocket. Soon you will have the ability to submit a question if you cannot find it here.</div>
            <div class="viewLink"><a href="#request.page#?adminpage=faqs.cfm">View FAQs</a></div>
        </div>
        <cfif url.searchresults>
            <div class="helpLeftContentContainer">
                <div class="helpHeader">Tips</div>
                <div class="helpContent">Want to get some tips on tricks on how to use Open BoomSocket quickly and effectively?  Head over to our tips section which is always growing.</div>
                <div class="viewLink"><a href="#request.page#?adminpage=tips.cfm">View Tips</a></div>
            </div>
        </cfif>
</div>
<div class="helpRightContainer">

    <cfif url.searchresults><!--- search results--->
        <div class="helpRightContentContainer">
            <div class="helpHeader" style="margin-bottom:0px;"><cfif url.searchresults>Search Results for: "#form.searchstr#"</cfif></div>
            <div style="margin-bottom:10px; text-align:right;"><a href="#request.page#?i3displayMode=help"><b>Search Again</b></a></div>
                    <div class="helpContent"><strong>Glossary:</strong><br />
                    <cfif arraylen(glossaryItemArray)>
                        <cfloop index="item" from="1" to="#arraylen(glossaryItemArray)#">
                                <div class="glossaryTitle"><a href="#request.page#?adminpage=glossary.cfm###glossaryItemArray[item].title.xmlText#"><b>#glossaryItemArray[item].title.xmlText#</b></a></div>
                        </cfloop>
                    <cfelse>
                        No results were found.
                    </cfif>
                    </div>
                    <div class="helpContent"><strong>Open BoomSocket FAQs:</strong><br />
                    <cfif arraylen(faqItemArray)>
                        <cfloop index="item" from="1" to="#arraylen(faqItemArray)#">
                                <div class="glossaryTitle"><a href="#request.page#?adminpage=faqs.cfm&faqid=#faqItemArray[item].guid.xmlText####faqItemArray[item].title.xmlText#"><b>#faqItemArray[item].title.xmlText#</b></a></div>
                        </cfloop>
                    <cfelse>
                        No results were found.
                    </cfif>
                    </div>	
                    <div class="helpContent"><strong>Tips</strong><br />
                    <cfif arraylen(tipItemArray)>
                        <cfloop index="item" from="1" to="#arraylen(tipItemArray)#">
                                <div class="tipTitle"><a href="#request.page#?adminpage=tips.cfm###tipItemArray[item].title.xmlText#"><b>#tipItemArray[item].title.xmlText#</b></a></div>
                        </cfloop>
                    <cfelse>
                        No results were found.
                    </cfif>
            </div>
        </div>		
    <cfelse><!--- search form--->
        <div class="helpRightContentContainer">
            <div class="helpHeader">Search</div>
            <div class="helpContent">
                <div id="searchinst" style="margin-bottom:10px">To search the glossary, Open BoomSocket FAQS, and tips submit the form below:</div>
                <div style="text-align:center;"><form name="i3helpSearch" method="post" action="#request.page#?i3displayMode=help&searchresults=1">
                Search for: <input name="searchstr" id="searchstr" type="text" size="20"> <input name="submit" type="submit" value="Find">
                </form></div>
            </div>
        </div>

        <div class="helpRightContentContainer">
            <div class="helpHeader">Tips</div>
            <div class="helpContent">Want to get some tips on tricks on how to use Open BoomSocket quickly and effectively?  Head over to our tips section which is alwayg growing.<br /><br /></div>
            <div class="viewLink"><a href="#request.page#?adminpage=tips.cfm">View Tips</a></div>
        </div>
    </cfif>
    </div>

</div>
</cfmodule>

</div>



</cfoutput>