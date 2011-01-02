<cfscript>
	i3faqsObj = CreateObject('component','#application.CFCPath#.i3faqs');
	if(IsDefined('URL.i3faqsid') AND Len(Trim(URL.i3faqsid))){
		q_getSingle = i3faqsObj.geti3FAQs(i3faqsID=URL.i3faqsid);
	}else{
		q_getall = i3faqsObj.geti3FAQs();
	}
</cfscript>

<cfif IsDefined('URL.i3faqsid')>
	<cfif q_getSingle.recordCount>
		<cfoutput>
			<div class="i3faqsBlock"><h2>i3SiteTools FAQs</h2>
				<div style="padding-bottom:5px;"><strong>Q:</strong> #q_getSingle.i3faqsname#</div>
				<div style="padding-bottom:5px;"><strong>A:</strong> #q_getSingle.i3faqsanswer#</</div>
				<div style="text-align:right;">
					<a href="#request.page#?view=i3FAQs">< Return to i3FAQs Home</a>
				</div>
			</div>
		</cfoutput>
	<cfelse>
		<cfheader statuscode="404" statustext="File not found">
		<cfoutput>
			<h1>404</h1>
			<p>We're sorry but the faq you are looking for does not exist. Please return to the <a href="#request.page#?view=i3FAQs">i3FAQs main page</a> and try your request again.</p>
		</cfoutput>
	</cfif>
<cfelse>
	<div class="i3faqsBlock"><h2>i3SiteTools FAQs</h2>
		<cfoutput query="q_getall" group="i3faqscategoryname">
			<strong>#q_getall.i3faqscategoryname#</strong>
			<ol><cfoutput>					
				<li><a href="#request.page#?view=i3FAQs&i3faqsID=#q_getall.i3faqsID#">#q_getall.i3faqsname#</a></li>				
			</cfoutput></ol>
		</cfoutput>
	</div>
	
</cfif>