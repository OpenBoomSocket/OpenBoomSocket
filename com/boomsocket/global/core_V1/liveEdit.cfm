<!--- live edit pop-up window - expects the following url vars: wysiwyg, contentobjectid, targetdiv --->
<!--- after deleting we want to redirect to new window w/out preview--->
<cfif isDefined('url.previewContent') AND url.previewContent eq 'no'>
		<cfoutput><script type="text/javascript">
		//url=window.opener.location.href.split('?')[0];
		url=window.opener.location.href;
		window.opener.location.href=url;
		window.close();
	</script></cfoutput>
<cfelseif isDefined('url.previewContent')>
	<cfoutput><script type="text/javascript">
		//url=window.opener.location.href.split('?')[0];
		//window.opener.location.href=url+'?previewContent=#url.previewContent#&contentobjectid=#url.contentobjectid#';
		/*CMC update 2/7/07: don't clear out all Query String vars*/
		url=window.opener.location.href;
		window.opener.location.href=url;
		window.close();
	</script></cfoutput>
<cfelseif NOT isDefined('form.editInPlaceRedirect')>
	<cfif isDefined("application.wysiwyg") AND isDefined("url.contentobjectid") AND isDefined("url.targetdiv")>
			<table width="100%" cellpadding="5" cellspacing="0" border="0">
				<tr>
					<td valign="top"><img src="#application.globalPath#/media/images/icon_preview.gif" border="0" style="display:inline;"></td>
					<td>Edit your content in the window below. You can preview your changes as they will appear in context on the site at any time simply by clicking the preview button. <br/>Note: The preview will appear in the live edit window that is currently open.</td>
				</tr>
				<tr>
					<td valign="top"><img src="#application.globalPath#/media/images/icon_pastefromword.gif" border="0" style="display:inline;"></td>
					<td>If copying content from Word, be sure to use the "paste from word" icon.</td>
				</tr>
			</table>
		
		<!--- init content object --->
		<cfset ContentObject = createObject('component','#APPLICATION.cfcpath#.getContentObject')>
		<!--- Determine which flavor of WYSIWYG editor to use --->
		<cfif isDefined("application.wysiwyg") AND application.wysiwyg EQ "ewebeditpro">
			<cfset getContentObjectMethod="editInPlaceEWE">
		<cfelseif isDefined("application.wysiwyg") AND application.wysiwyg EQ "fckeditor">
			<cfset getContentObjectMethod="editInPlaceFCK">
		<cfelseif isDefined("application.wysiwyg") AND application.wysiwyg EQ "ckeditor">
			<cfset getContentObjectMethod="editInPlaceckeCKE">
		<cfelse>
			<cfset getContentObjectMethod="editInPlace">
		</cfif>
		<cfoutput>#evaluate("ContentObject.#getContentObjectMethod#(contentobjectid=url.contentobjectid,width=680)")#</cfoutput>
	<cfelse>
		An error has occured!
	</cfif>
</cfif>