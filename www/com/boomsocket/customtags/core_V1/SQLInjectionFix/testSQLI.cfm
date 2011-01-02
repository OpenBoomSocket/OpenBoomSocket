<!--- ------------------------ CSS and Header ------------------------------ --->
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
	textarea {filter: progid:DXImageTransform.Microsoft.Gradient(gradientType=1,startColorStr=#C8C8C8,endColorStr=#FFFFFF);background-color: #FFFFFF;font: 11px sans-serif;font-weight: 100;color: #444444;}
	select {filter: progid:DXImageTransform.Microsoft.Gradient(gradientType=1,startColorStr=#C8C8C8,endColorStr=#FFFFFF);background-color: #FFFFFF;font: 11px sans-serif;font-weight: 800;color: #444444;}
</STYLE>

<HEAD>
<TITLE>GroupTravelTech - SQL Injection tester</TITLE>
</HEAD>
<BODY>
<TABLE WIDTH="700" CELLPADDING="0" CELLSPACING="1" CLASS="borderColor" ALIGN="center" ID="borderTable"><TR><TD WIDTH="50%" CLASS="mainHeaderGradient"><TABLE BORDER="0" WIDTH="100%" CELLPADDING="0" CELLSPACING="0"><TR><TD WIDTH="50%" CLASS="mainHeaderGradient"><SPAN CLASS="appTitle_Group">&nbsp;&nbsp;group</SPAN><SPAN CLASS="appTitle_Minder">travel</SPAN><SPAN CLASS="appTitle_Group">tech</SPAN></TD><TD WIDTH="50%" CLASS="mainHeaderNoGrad" ALIGN="right" STYLE="PADDING-RIGHT: 5px;"></TD></TR><TR><TD COLSPAN="2" HEIGHT="1" CLASS="borderColor"></TR><TR><TD COLSPAN="2" HEIGHT="3" CLASS="separatorGradient"></TD></TR><TR><TD COLSPAN="2" HEIGHT="1" CLASS="borderColor"></TD></TR><TR><TD COLSPAN="2"><TABLE BORDER="0" WIDTH="100%" ALIGN="center" CELLPADDING="0" CELLSPACING="6" CLASS="appTable"><TR><!--- Page Identity Area ---><TD VALIGN="bottom" CLASS="breadCrumbs" HEIGHT="42" COLSPAN="4">&raquo; Scripts for SQL Injection tests<HR SIZE="0.5"></TD></TR><TR><TD><TR><TD CLASS="appContent" ALIGN="left">

<!--- ------------------------ Enf of the Header ------------------------------ --->
<!--- Luis, 01 Aug 2008
--------- OR paterns to catch
--------- =><! like -------------
((or)+[[:space:]]*\(*'?[[:print:]]+'?([[:space:]]*[\+\-\/\*][[:space:]]*'?[[:print:]]+'?)*\)*[[:space:]]*([=><!]{1,2}|(like))[[:space:]]*\(*'?[[:print:]]+'?([[:space:]]*[\+\-\/\*][[:space:]]*'?[[:print:]]+'?)*\)*)
Cathes:
	' or (1 = 1)
	 or 1+2 < 1+3
	 or 'a' = 'a'
	 or 'a'+'b' = 'ab'
	' or 'a'+'b' != 'cb'
	' or 'a '+'b' != 'c b'
	 or 123-100 <> 14
	or 1.1=1.1
	OR 1=1 --
	or (1 = 1)
	or 1 like 1
	or 'ab' like '%abcd%'
	or 'a'+'b' like 'ab'
	 or    'aaa   ' like '%ad'
	 or    1     like		'select 1'
------------ in -----------------
((or)+[[:space:]]*\(*'?[[:print:]]+'?([[:space:]]*[\+\-\/\*][[:space:]]*'?[[:print:]]+'?)*\)*[[:space:]]+(in)[[:space:]]*\(+[[:space:]]*'?[[:print:]]+'?(\,[[:space:]]*'?[[:print:]]+'?)*\)+)
Cathes:
	' or (1 IN (1,2,3,4))
	' or ('c' IN ('a','b','c','d','e'))
	/or ('c' IN ('a','b','c','d','e'))
	' or 1 IN (1,2,3,4)
	or (1 IN (1,2,3,4))
	or 'a'+'b' IN (('a'+'b'))
	 or 'a'+'b' IN (( SELECT 'a'+'b'))
--------- Between --------------
((or)+[[:space:]]*\(*'?[[:print:]]+'?([[:space:]]*[\+\-\/\*][[:space:]]*'?[[:print:]]+'?)*\)*[[:space:]]*(between)[[:space:]]*\(*[[:space:]]*'?[[:print:]]+'?(\,[[:space:]]*'?[[:print:]]+'?)*\)*(and)[[:space:]]+\(*[[:space:]]*'?[[:print:]]+'?(\,[[:space:]]*'?[[:print:]]+'?)*\)*)
Cathes:
	' OR 'c' between 'a' AND 'e'
	or 'a'+'b' between (( SELECT 'a'+'b')) AND 'ab'
	or'a'+'b'between(( SELECT 'a'+'b')) AND 'ab'
	OR 2between 1 AND 3
	OR 1 between 0 AND 2
	OR 'c' between 'a' AND 'e'
	1230oR '1.1' between '0.0' and '2.2'
	123OR 'a1.1' between 'b0.0' and '2.2'
	123OR a1.1' between b0.0' and '2.2'
--------- Combined OR paterns  ---------------
((or)+[[:space:]]*\(*'?[[:print:]]+'?([[:space:]]*[\+\-\/\*][[:space:]]*'?[[:print:]]+'?)*\)*[[:space:]]*(([=><!]{1,2}|(like))[[:space:]]*\(*'?[[:print:]]+'?([[:space:]]*[\+\-\/\*][[:space:]]*'?[[:print:]]+'?)*\)*)|((in)[[:space:]]*\(+[[:space:]]*'?[[:print:]]+'?(\,[[:space:]]*'?[[:print:]]+'?)*\)+)|((between)[[:space:]]*\(*[[:space:]]*'?[[:print:]]+'?(\,[[:space:]]*'?[[:print:]]+'?)*\)*(and)[[:space:]]+\(*[[:space:]]*'?[[:print:]]+'?(\,[[:space:]]*'?[[:print:]]+'?)*\)*))
 --->
 
<!--- Regular Expression by Luis --->
<CFIF isDefined("FORM.regEx") AND FORM.regEx IS "">
	<CFSET VARIABLES.insSql = "insert|delete|select|update|create|alter|drop|truncate|grant|revoke|declare|exec|backup|restore|sp_|xp_|set|execute|dbcc|deny|union|Cast|Char|Varchar|nChar|nVarchar">
	<CFSET FORM.regEx="((or)+[[:space:]]*\(*'?[[:print:]]+'?([[:space:]]*[\+\-\/\*][[:space:]]*'?[[:print:]]+'?)*\)*[[:space:]]*(([=><!]{1,2}|(like))[[:space:]]*\(*'?[[:print:]]+'?([[:space:]]*[\+\-\/\*][[:space:]]*'?[[:print:]]+'?)*\)*)|((in)[[:space:]]*\(+[[:space:]]*'?[[:print:]]+'?(\,[[:space:]]*'?[[:print:]]+'?)*\)+)|((between)[[:space:]]*\(*[[:space:]]*'?[[:print:]]+'?(\,[[:space:]]*'?[[:print:]]+'?)*\)*(and)[[:space:]]+\(*[[:space:]]*'?[[:print:]]+'?(\,[[:space:]]*'?[[:print:]]+'?)*\)*)|((;)([^a-z>]*)(#VARIABLES.insSql#)([^a-z]+|$))|(union[^a-z]+(all|select))|(\/\*)|(--$))">
</CFIF>

<!--- Regular Expression by Ortho
<CFIF isDefined("FORM.regEx") AND FORM.regEx IS "">
	<cfset insSql = "insert|delete|select|update|create|alter|drop|truncate|grant|revoke|declare|exec|backup|restore|sp_|xp_|set|execute|dbcc|deny|union|Cast|convert|Char|Varchar|nChar|nVarchar">
	<cfset insFunc = "convert|cast|abs|acos|ascii|asin|atan\atan2|ave|ceiling|char|charindex|coalesce|cos|cot|count|count_big|datediff|day|degrees|difference|exp|floor|isnull|isnumeric|left|len|log|log10|lower|ltrim|month|nchar|nullif|nvarchar|parsename|patindex|pi|power|radians|quotename|replace|replicate|reverse|right|round|rowcount_big|rtrim|sign|sin|sqrt|square|soundex|space|str|stuff|substring|tan|unicode|upper|varchar|year">
	<cfscript>
		//regExFunctionPart = '';
		//regExOrPart = '';
		//regexSQLwords = '';
		//spdelims = '';
		spdelims = "\^;\}\{\\\+\]-"; // string is: ^;}{\+]-
		regExFunctionPart = "([0-9.,]+|[^a-z#spdelims#])or[[:print:]]+(#insFunc#)[^a-z]*\([[:print:]]{1,20}\)|";
		regExOrPart = "([0-9.,]+|[^a-z#spdelims#])or[^a-z]+(('[[:print:]]+)|[0-9.,]+)(([^a-z]*[=><!\+\-\/\*]+[^a-z]*)|([^a-z]+((between)|(like)|(in))[^a-z]+))(('[[:print:]]+)|[0-9.,]+)|";
		regexSQLwords = "(;)([^a-z>]*)(#insSql#)([^a-z]+|$)|";
		charSq = "#regExFunctionPart##regExOrPart##regexSQLwords#union[^a-z]+(all|select)|(\/\*)|(--$)";
	</cfscript>
	<CFSET FORM.regEx= charSq>
</CFIF> --->

<CFIF IsDefined("FORM.textToTest")>

	<CFSET VARIABLES.knownInjections = "caster or converter
cast the hook
convert this to that
Instructor'(412-834-5645)
Core or ders for 123-123
Sue Gross 937 433 3432 or 937 554-8904
; twin or double - two
Select
Please 'Select' the button to the left
New York or Washinton
duck, or get between two buildings
duck, or 'get between two buildings
duck, or get between 'two buildings
duck, or 'get between 'two buildings
duck, or 'get between'two buildings
flush it or dump in the garbage
'Select
' /*obfuscate*/ Select
; declare 
;declare 
 union all union select
 union select all
union select
 un/* */ion all union 
 se/* this is code*/lect
' OR 1=1
' or (1 = 1)
 or 1+2 < 1+3
 or 'a' = 'a'
 or 'a'+'b' = 'ab'
' or 'a'+'b' != 'cb'
' or 'a '+'b' != 'c b'
 or 123-100 <> 14
or 1.1=1.1
OR 1=1 --
or (1 = 1)
OR ((1) + (1) = (3) - (1))
 or char(49)=1
or atan(0)=0
 or atan(0)=0
or  CAST ( 1 AS smallint) = 1
 or  CONVERT ( smallint, 1)  = 1
 or  CONVERT (12)  = 1
 or  CONVERT (123)  = 1
 or  CONVERT (123456789012345678901)  = 1
 or  CONVERT (12345678901234567890)  = 1
 or  CONVERT this (1234567)  = 1
 or  1 = CONVERT ( smallint, 1)
 or  'a' + 1  = CAST ( 1 AS smallint)
or  'a' + 1  = CAST ( 1 AS smallint)
or 1 like 1
or 'ab' like '%abcd%'
or 'a'+'b' like 'ab'
 or    'aaa   ' like '%ad'
 or    1     like		'select 1'
' or (1 IN (1,2,3,4))
' or ('c' IN ('a','b','c','d','e'))
/or ('c' IN ('a','b','c','d','e'))
' or 1 IN (1,2,3,4)
or (1 IN (1,2,3,4))
or 'a'+'b' IN (('a'+'b'))
 or 'a'+'b' IN (( SELECT 'a'+'b'))
' OR 'c' between 'a' AND 'e'
or 'a'+'b' between (( SELECT 'a'+'b')) AND 'ab'
or'a'+'b'between(( SELECT 'a'+'b')) AND 'ab'
OR 2between 1 AND 3
OR 1 between 0 AND 2
OR 'c' between 'a' AND 'e'
1230oR '1.1' between '0.0' and '2.2'
123OR 'a1.1' between 'b0.0' and '2.2'
123OR a1.1' between b0.0' and '2.2'">

	<H3>Test Results:</H3>
	<!--- If we should test the standard strings --->
	<CFIF IsDefined("FORM.testStdStr")>
		<H4>Standard Strings:</H4>
		<UL>
		<!--- Test standard SQL Injection strings --->
		<CFLOOP list="#knownInjections#" index = "KI" delimiters="#chr(10)#">
			<CFIF ReFindNoCase("#FORM.regEx#", KI) NEQ "0">
				<LI><FONT COLOR="#008000"><B>CAUGHT:</B> {<CFOUTPUT>#KI#</CFOUTPUT>}</FONT></LI>
			<CFELSE>
				<LI><FONT COLOR="#800000"><B>PASSED:</B> {<CFOUTPUT>#KI#</CFOUTPUT>}</FONT></LI>
			</CFIF>
		</CFLOOP>
		</UL>
	</CFIF>
	<!--- Test custom SQL Injection strings --->
	<CFIF FORM.textToTest NEQ "">
		<H4>Custom String:</H4>
		<UL>
		<CFIF ReFindNoCase("#FORM.regEx#", FORM.textToTest) NEQ "0">
			<LI><FONT COLOR="#008000"><B>CAUGHT:</B> {<CFOUTPUT>#FORM.textToTest#</CFOUTPUT>}</FONT></LI>
		<CFELSE>
			<LI><FONT COLOR="#800000"><B>PASSED:</B> {<CFOUTPUT>#FORM.textToTest#</CFOUTPUT>}</FONT></LI>
		</CFIF>
		</UL>
	</CFIF>
	<HR SIZE="0.5">
</CFIF>
<TABLE WIDTH="695" CELLPADDING="0" CELLSPACING="1" ALIGN="center" CLASS="appContent"><TR><TD>
<FORM ACTION="testSQLI.cfm" METHOD="post" NAME="form">
<TR><TD ALIGN="right">
	Test standard strings: 
</TD><TD>
	<INPUT TYPE="Checkbox" NAME="testStdStr" VALUE="1">
</TD></TR><TR><TD ALIGN="right">
	Use This RegEx:
</TD><TD>
	<INPUT TYPE="Text" NAME="regEx" SIZE="100">
</TD></TR><TR><TD ALIGN="right" VALIGN="top">
	String to test:
</TD><TD>
	<TEXTAREA NAME="textToTest" ROWS="5" COLS="102"></TEXTAREA>
</TD></TR><TR><TD COLSPAN="2" ALIGN="center">
	<INPUT TYPE="Submit" VALUE="Test Text">
</TD></TR>
</FORM>
</TABLE>

<!--- ------------------------------------------------------------------------ --->

<!--- ------------------------ This is The Footer ------------------------ --->
</TD></TR></TABLE></TD></TR><TR><TD COLSPAN="2" HEIGHT="1" CLASS="borderColor"></TR><TR><TD COLSPAN="2" HEIGHT="3" CLASS="separatorGradient"></TD></TR><TR><TD COLSPAN="2" HEIGHT="1" CLASS="borderColor"></TD></TR><TR><TD WIDTH="20%" CLASS="mainHeaderGradient" STYLE="padding-right: 5px; padding-left: 5px;" VALIGN="bottom"></TD><TD WIDTH="80%" CLASS="mainHeaderNoGrad" ALIGN="right"><SPAN CLASS="footer" STYLE="padding-right: 5px;">&copy; Group Travel Technologies 2000-<CFOUTPUT>#dateFormat(now(), "yyyy")#</CFOUTPUT> - Time:<CFOUTPUT>#hour(now())#:#minute(now())#</CFOUTPUT></SPAN></TD></TR></TABLE></TD></TR></TABLE></BODY></HTML>
<!--- ------------------------ This is The Footer ------------------------ --->
