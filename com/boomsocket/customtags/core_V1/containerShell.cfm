<cfsilent><cfparam name="attributes.width" default="250">
<cfparam name="attributes.padding" default="5">
<cfparam name="attributes.align" default="">
<cfparam name="request.containerTop" default="1">
<cfparam name="request.containerBottom" default="1"></cfsilent>
<cfoutput>
<cfif thistag.executionmode is "START">
<table width="#attributes.width#" border="0" cellspacing="0" cellpadding="0"<cfif len(attributes.align)> align="#attributes.align#"</cfif>>
<tr>
	<td style="background-image: url('/admintools/media/images/corner_topLeft.gif'); height:13px;">
	<td style="background-image: url('/admintools/media/images/side_top.gif'); height:13px;"></td>
	<td style="background-image: url('/admintools/media/images/corner_topRight.gif'); height:13px;"></td>
</tr>
<tr>
	<td style="background-image: url('/admintools/media/images/side_left.gif')" width="13"></td>
	<td bgcolor="##f4f4f4"><table cellpadding="#attributes.padding#" width="100%"><tr><td bgcolor="##f4f4f4" width="100%">
<cfelseif thistag.executionmode is "END"><!---content goes here---></td></tr></table></td>
	<td style="background-image: url('/admintools/media/images/side_right.gif')" width="13"></td>
</tr>
<tr>
	<td style="background-image: url('/admintools/media/images/corner_bottomLeft.gif'); height:13px;"></td>
	<td style="background-image: url('/admintools/media/images/side_bottom.gif'); height:13px;"></td>
	<td style="background-image: url('/admintools/media/images/corner_bottomRight.gif'); height:13px;"></td>
</tr>
</table>
</cfif>
</cfoutput>