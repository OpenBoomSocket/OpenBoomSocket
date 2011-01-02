<cfsilent><cfparam name="request.defaultCall" default="1">
<cfparam name="request.chromeTop" default="#request.defaultCall#">
<cfparam name="request.chromeBottom" default="#request.defaultCall#">
<cfparam name="attributes.textTopLeft" default="&nbsp;">
<cfparam name="attributes.textTopRight" default="&nbsp;">
<cfparam name="attributes.textTopMiddle" default="&nbsp;">
<cfparam name="attributes.textBottomLeft" default="&nbsp;">
<cfparam name="attributes.textBottomRight" default="&nbsp;">
<cfparam name="attributes.textBottomMiddle" default="&nbsp;">
<cfparam name="attributes.spacerMiddle" default="<img src='#application.globalPath#/media/images/i3container_body2.gif'>">
<cfparam name="attributes.forceHeight" default="false">
</cfsilent>
<cfoutput>
<cfif thistag.executionmode is "START">
<cfif request.chromeTop>
<div class="chromeWrapper">
	<div class="chromeHeaderWrapper">
		<div class="chromeHeaderLeft">#attributes.textTopLeft#</div>
		<div class="chromeHeaderMiddle">#attributes.textTopMiddle#</div>
		<div class="chromeHeaderRight">&nbsp;#attributes.textTopRight#</div>
	</div><!-- end Header Wrapper -->
	<div class="chromeMiddle"><cfset request.chromeTop=0></cfif>
<cfelseif thistag.executionmode is "END">
<cfif request.chromeBottom>
	<cfif #attributes.forceHeight#>#attributes.spacerMiddle#</cfif><div style="clear:both"></div></div> <!-- close middle section div after content added -->
	<div class="chromeFooterWrapper">
		<div class="chromeFooterLeft">#attributes.textBottomLeft#</div>
		<div class="chromeFooterMiddle">#attributes.textBottomMiddle#</div>
		<div class="chromeFooterRight">&nbsp;#attributes.textBottomRight#</div>
	</div> <!-- end footer wrapper -->
</div> <!-- end outer wrapper -->
<cfset request.chromeBottom=0>
</cfif>
</cfif>
</cfoutput>