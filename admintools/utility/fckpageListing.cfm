<cfsilent><cfsetting showdebugoutput="no">
<cfquery name="q_fckGetPages" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT page.pagename, page.sitesectionid, sitesection.sitesectionname
	FROM page 
		INNER JOIN sitesection 
			ON page.sitesectionid = sitesection.sitesectionid
	Order BY sitesection.sitesectionname ASC
</cfquery>
<cfsavecontent variable="headerstuff">
	<cfoutput>
		<script type="text/javascript">
			function pushLink(myVal){
				self.parent.document.getElementById('txtUrl').value = myVal.value;
				self.parent.document.getElementById('cmbLinkProtocol').value = '';
			}
		</script>
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#headerstuff#"></cfsilent><body style="background-color:#e6e6e6; margin:0;">
<span style="font-size:11px; font-family:Arial, Helvetica, sans-serif;">or select a page: </span><br>
<select name="i3PageList" id="i3PageList" onChange="pushLink(this)">
	<option><--- Select One ---></option>
<cfoutput query="q_fckGetPages">
	<cfset thisPath = application.getSectionPath(q_fckGetPages.sitesectionid,true,'/')>
	<option value="/#thisPath#/#q_fckGetPages.pagename#" id="i3PageListItem">/#thisPath#/#q_fckGetPages.pagename#</option>
</cfoutput>
</select>
</body>