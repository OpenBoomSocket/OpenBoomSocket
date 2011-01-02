<cfsavecontent variable="jsInsertCal">
	<cfoutput>
        <script type="text/javascript" src="#application.GlobalPath#/javascript/CalendarPopup.js"></script>
    </cfoutput>
</cfsavecontent>
<cfhtmlhead text="#jsInsertCal#">
<cfoutput>
    <script type="text/javascript">
		var cal_#a_formelements[a].fieldname# = new CalendarPopup("bsCaldiv_#a_formelements[a].fieldname#");
		cal_#a_formelements[a].fieldname#.setCssPrefix("BSCal");
    </script>
	<input name="#a_formelements[a].fieldname#" id="#a_formelements[a].fieldname#" type="text" size="#a_formelements[a].width#" class="#a_formelements[a].inputstyle#" maxlength="#a_formelements[a].maxlength#" value="<cfif isDefined('form.#a_formelements[a].fieldname#')>#dateformat(evaluate('form.#a_formelements[a].fieldname#'),'mm/dd/yyyy')#</cfif>" <cfif a_formelements[a].readonly EQ 1> readonly="readonly"</cfif><cfif len(a_formelements[a].tabindex)> tabindex="#a_formelements[a].tabindex#"</cfif>>
	<a href="##" onclick="cal_#a_formelements[a].fieldname#.select(document.getElementById('#a_formelements[a].fieldname#'),'anchor_#a_formelements[a].fieldname#','MM/dd/yyyy'); return false;" title="Click To Open Calendar" name="anchor_#a_formelements[a].fieldname#" id="anchor_#a_formelements[a].fieldname#">Select Date</a><div id="bsCaldiv_#a_formelements[a].fieldname#" style="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></div>
</cfoutput>