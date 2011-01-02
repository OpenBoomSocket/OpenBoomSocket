<CFIF isDefined("FORM.Save")>
	<CFSET VARIABLES.exists = "0">
	<CFIF isDefined("APPLICATION.ipBlackList")>
		<CFLOOP FROM="1" TO="#arrayLen(APPLICATION.ipBlackList)#" INDEX="currPosition">
			<CFIF APPLICATION.ipBlackList[currPosition].arrayIp EQ FORM.ipAddress>
				<CFSET VARIABLES.temp = arrayDeleteAt(APPLICATION.ipBlackList, currPosition)>
				<CFSET VARIABLES.exists = "1">
				<CFBREAK>
			</CFIF>
		</CFLOOP>
	</CFIF>
	<CFIF VARIABLES.exists EQ "1">
		<CFSET VARIABLES.message = "IP Address was removed from blacklist!">
	<CFELSE>
		<CFSET VARIABLES.message = "This IP Address isn't in the blacklist!">
	</CFIF>
</CFIF>

<HTML>
<HEAD>
	<STYLE TYPE="text/css">
		.borderColor {background-color: #555555; }
		.appTitle_Group {font-size: 18px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;color: #000000;text-decoration: none;font-weight: 100;}
		.appTitle_Minder {font-size: 18px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;color: #AA0000;text-decoration: none;	font-weight: 900;}
		.mainHeaderGradient {filter: progid:DXImageTransform.Microsoft.Gradient(gradientType=1,startColorStr=#EEF5FF,endColorStr=#ff0000);background-color: #ff0000;font: 14px sans-serif;font-weight: 100;color: #000000;}
		.mainHeaderNoGrad {background-color: #ff0000;}
		.separatorGradient {filter: progid:DXImageTransform.Microsoft.Gradient(gradientType=1,startColorStr=#777777,endColorStr=#FFFFFF);background-color: #FFFFFF; }
		.appTable {background-color: #FFFFFF;}
		.breadCrumbs {font: 10px sans-serif;color: #777777;font-weight: 100;padding: 5px 5px 5px 5px;}
		.messageArea {background-color: #FFDDDD;font: 11px sans-serif;font-weight: 100;color: #0000AA;border: 1px solid #FF0000;padding: 5px 5px 5px 5px; }
		.appContent {font: 11px sans-serif;font-weight: 100;color: #444444;padding: 2px 2px 2px 2px;}
		.appContent:link {color: #000088;text-decoration: none;}
		.appContent:visited {color: #000088;text-decoration: none;}
		.appContent:hover{color: #0000FF;}
		.appResultHeader {font-style: italic;font-weight: 100;}
		.frmFlds {background-color: #EFEFEF;font: 11px sans-serif;color: #000000;border: 1px solid #FF9900;}
		.TblRow1 {background-color: #EFEFEF;}
		.TblRow2 {background-color: #FFFFFF;}
		.frmBtn {font: 11px sans-serif;color: #000000;font-weight: 100;}
		.footer {font: 9px sans-serif;color: #FFFFFF;font-weight: 100;}
		.footer:link {color: #FF5555;text-decoration: none;}
		.footer:visited {color: #FF5555;text-decoration: none;}
		.footer:hover{color: #55FF55;text-decoration: none;}
		input {filter: progid:DXImageTransform.Microsoft.Gradient(gradientType=1,startColorStr=#C8C8C8,endColorStr=#FFFFFF);background-color: #FFFFFF;font: 11px sans-serif;font-weight: 100;color: #444444;}
		select {filter: progid:DXImageTransform.Microsoft.Gradient(gradientType=1,startColorStr=#C8C8C8,endColorStr=#FFFFFF);background-color: #FFFFFF;font: 11px sans-serif;font-weight: 800;color: #444444;}
	</STYLE>
	<TITLE>IP Unlock</TITLE>
</HEAD>
<BODY TOPMARGIN="3" LEFTMARGIN="0">

<!--- Content Table --->
<TABLE BORDER="1" WIDTH="600" ALIGN="center" CELLPADDING="1" CELLSPACING="0" CLASS="appTable">
<TR><TD><TABLE WIDTH="100%">
<!--- Page Identity Area --->
<TR><TD VALIGN="bottom" CLASS="breadCrumbs" HEIGHT="42" COLSPAN="2">
	&raquo; Malicious IP : Unlock
	<HR SIZE="0.5">
</TD></TR>

<FORM METHOD="POST" ACTION="ipBlackListUnlock.cfm" NAME="form">
<INPUT CLASS="frmFlds" TYPE="Hidden" NAME="Save" VALUE="1">
<CFIF NOT isDefined("APPLICATION.ipBlackList") OR (isDefined("APPLICATION.ipBlackList") AND arrayLen(APPLICATION.ipBlackList) EQ "0")>
	<CFSET VARIABLES.message = "The black list is empty.">
</CFIF>
<CFIF ISDEFINED("VARIABLES.message")>
	<TR><TD COLSPAN="2" CLASS="messageArea">
		<IMG SRC="../intranet/images/Misc_Information.gif" WIDTH="30" HEIGHT="30" BORDER="0" ALIGN="absmiddle">&nbsp;<CFOUTPUT>#VARIABLES.message#</CFOUTPUT>
	</TD></TR>
</CFIF>
<CFIF isDefined("APPLICATION.ipBlackList") AND arrayLen(APPLICATION.ipBlackList) GT "0">
	<CFOUTPUT>
		<TR><TD ALIGN="right">
			*&nbsp;IP Address:
		</TD><TD>
			<SELECT CLASS="frmFlds" NAME="ipAddress">
			<CFLOOP FROM="1" TO="#arrayLen(APPLICATION.ipBlackList)#" INDEX="currPosition">
				<OPTION VALUE="#APPLICATION.ipBlackList[currPosition].arrayIp#">#APPLICATION.ipBlackList[currPosition].arrayIp#</OPTION>
			</CFLOOP>
			</SELECT>
		</TD></TR>
	</CFOUTPUT>
	<TR><TD ALIGN="center" HEIGHT="10" COLSPAN="2">
		<HR SIZE="0.5">
		<INPUT TYPE="submit" CLASS="frmbtn" style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=scale src='../Intranet/images/Btn_Form_save.png');background-color: transparent;cursor: hand;margin: 0px;padding: 0px;border: 0px 0;width: 103px;height: 27px;" VALUE="&nbsp;&nbsp;&nbsp;Unlock">
	</TD></TR>
</CFIF>
</TABLE></TD></TR>
</TABLE>