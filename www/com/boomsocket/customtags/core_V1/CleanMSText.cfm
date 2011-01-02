<!--- ****************************************************************************************
*
*	CleanMSText.cfm
*
*	Authors: Chris Tazewell - Taz Media Ltd - http://www.tazmedia.co.uk
*			 Stephen Moretti - Evolution B Information - http://www.evbi.co.uk
*
*	Version: 1.5
*	Last Update: 27 November 2003
*
*	This tag cleans up html source code from strings containing microsoft office xml/html.
*	This is often found in content added using a wysiwyg editor like soEditor, Activedit etc.
*	Text which has been copied and pasted from MSWord may contain special xml and html tags
*	which have no use in a web page and can cause display problems.
*	Use the attribute: "replacequotes" to replace ms smart-quotes with normal single quotes.
*	Takes a boolean value, default = true
*	** NEW **  Use the attribute "quotestype" to choose whether to replace quotes with
*	symbol quotes ( "" '' ) or their html ascii codes ( &lsquo; etc ).
*	Values taken are 'text' or 'code'
*	** NEW ** More quotes codes found and replaced, plus removal of "lang" attributes
*
*	Example of use.
*	variable containing ms string: Variables.MyVariable
*	<cf_cleanmstext mstext="Variables.MyVariable" replacequotes="true" quotestype="code">
*
******************************************************************************************--->
<cfparam name="Attributes.MSText" default="">
<cfparam name="Attributes.ReplaceQuotes" default="true">
<cfparam name="Attributes.QuotesType" default="text">

<cftry>
	<cfset MSRubbish = Evaluate("caller."&Attributes.MSText)>
	<cfcatch type="Any">
		<p><b>CleanMSText</b></p>
		<p>Error: You must specify the name of the variable which contains the MS text.</p>
		<p><i>&lt;cf_cleanmsrubbish mstext="MyString"&gt;</i></p>
		<cfabort>
	</cfcatch>
</cftry>

<cfscript>
	FoundFlag = 1;

	// these ones are easy
	MSRubbish = ReplaceNoCase(MSRubbish, '<o:p>', '', 'all');
	MSRubbish = ReplaceNoCase(MSRubbish, '</o:p>', '', 'all');
	MSRubbish = ReplaceNoCase(MSRubbish, ' class=MsoNormalTable', '', 'all');
	MSRubbish = ReplaceNoCase(MSRubbish, ' class="MsoNormalTable"', '', 'all');
	MSRubbish = ReplaceNoCase(MSRubbish, ' class=MsoNormal', '', 'all');
	MSRubbish = ReplaceNoCase(MSRubbish, ' class="MsoNormal"', '', 'all');
	MSRubbish = ReplaceNoCase(MSRubbish, ' lang=EN-US', '', 'all');
	MSRubbish = ReplaceNoCase(MSRubbish, ' lang="EN-US"', '', 'all');
	// stops it ditching the bold markups when throwing away smart tags
	MSRubbish = ReplaceNoCase(MSRubbish, '<strong>', '<b>', 'all');
	MSRubbish = ReplaceNoCase(MSRubbish, '</strong>', '</b>', 'all');
	//MSRubbish = ReplaceNoCase(MSRubbish, '<b style=', '<b><style=', 'all');
	if (Attributes.ReplaceQuotes EQ true OR NOT IsBoolean(Attributes.ReplaceQuotes)) {
		// replace MS smart quotes
		if (Attributes.QuotesType EQ 'code') {
			// single quotes
			MSRubbish = Replace(MSRubbish, Chr(145), '&lsquo;', 'all');
			MSRubbish = Replace(MSRubbish, Chr(146), '&rsquo;', 'all');
			MSRubbish = Replace(MSRubbish, Chr(24), '&lsquo;', 'all');
			MSRubbish = Replace(MSRubbish, Chr(25), '&rsquo;', 'all');
			// double quotes
			MSRubbish = Replace(MSRubbish, Chr(147), '&ldquo;', 'all');
			MSRubbish = Replace(MSRubbish, Chr(148), '&rdquo;', 'all');
			MSRubbish = Replace(MSRubbish, Chr(28), '&ldquo;', 'all');
			MSRubbish = Replace(MSRubbish, Chr(29), '&rdquo;', 'all');
		} else {
			// single quotes
			MSRubbish = Replace(MSRubbish, Chr(145), Chr(39), 'all');
			MSRubbish = Replace(MSRubbish, Chr(146), Chr(39), 'all');
			MSRubbish = Replace(MSRubbish, Chr(24), Chr(39), 'all');
			MSRubbish = Replace(MSRubbish, Chr(25), Chr(39), 'all');
			// double quotes
			MSRubbish = Replace(MSRubbish, Chr(147), Chr(34), 'all');
			MSRubbish = Replace(MSRubbish, Chr(148), Chr(34), 'all');
			MSRubbish = Replace(MSRubbish, Chr(28), Chr(34), 'all');
			MSRubbish = Replace(MSRubbish, Chr(29), Chr(34), 'all');
		}
			MSRubbish = Replace(MSRubbish, Chr(19), "-", 'all');
			MSRubbish = Replace(MSRubbish, Chr(150), "-", 'all');
	}

	// next ones are style="blah blah blah", class=MSo...
	While (FoundFlag EQ 1) {
		if (FindNoCase(' class=mso', MSRubbish)) {
			// these are mso default stylesheets... useless in your html output
			StartIndex = FindNoCase(' class=mso', MSRubbish);
			NextSpace = Find(' ', MSRubbish, StartIndex + 10);
			NextClose = Find('>', MSRubbish, StartIndex + 10);
			if (NextSpace LT NextClose) {
				EndIndex = NextSpace;
			} else {
				EndIndex = NextClose;
			}
			RemoveString = Mid(MSRubbish, StartIndex, EndIndex-StartIndex);
			MSRubbish = ReplaceNoCase(MSRubbish, RemoveString, '', 'all');
		} else if (FindNoCase(' style="', MSRubbish)) {
			// more stylesheets...
			StartIndex = FindNoCase(' style="', MSRubbish);
			EndIndex = Find('"', MSRubbish, StartIndex + 9) + 1;
			RemoveString = Mid(MSRubbish, StartIndex, EndIndex-StartIndex);
			MSRubbish = ReplaceNoCase(MSRubbish, RemoveString, '', 'all');
		} else if ( FindNoCase('<st', MSRubbish) and FindNoCase('<strong>', MSRubbish) EQ 0) {
			// this one's interesting... mso "smart tags",
			// xml jubblies which seem to attach themselves to place names etc.
			StartIndex = FindNoCase('<st', MSRubbish);
			EndIndex = Find('>', MSRubbish, StartIndex) + 1;
			RemoveString = Mid(MSRubbish, StartIndex, EndIndex-StartIndex);
			MSRubbish = ReplaceNoCase(MSRubbish, RemoveString, '', 'all');
		} else if (FindNoCase('<?xml', MSRubbish)) {
			// now look for the xml tag at the top of the text
			StartIndex = FindNoCase('<?xml', MSRubbish);
			EndIndex = Find('>', MSRubbish, StartIndex) + 1;
			RemoveString = Mid(MSRubbish, StartIndex, EndIndex-StartIndex);

			// only want to remove it if it is an mso thing
			if (FindNoCase('microsoft', RemoveString)) {
				MSRubbish = ReplaceNoCase(MSRubbish, RemoveString, '', 'all');
			}
		} else if ( FindNoCase('</st', MSRubbish) and FindNoCase('</strong>', MSRubbish) EQ 0) {
			// closing smart tags
			StartIndex = FindNoCase('</st', MSRubbish);
			EndIndex = Find('>', MSRubbish, StartIndex) + 1;
			RemoveString = Mid(MSRubbish, StartIndex, EndIndex-StartIndex);
			MSRubbish = ReplaceNoCase(MSRubbish, RemoveString, '', 'all');
		} else {
			// none of the above... probably ought to stop unless you
			// feel really nasty and want to knacker somebody's server
			// ... on second thoughts...
			FoundFlag = 0;
		}
	// the B tag is not W3C compliant especially when combined with Section 508, so we convert all our b's to strong's.
	MSRubbish = ReplaceNoCase(MSRubbish, '<b>', '<strong>', 'all');
	MSRubbish = ReplaceNoCase(MSRubbish, '</b>', '</strong>', 'all');
	MSRubbish = ReplaceNoCase(MSRubbish, '<span>', '', 'all');
	MSRubbish = ReplaceNoCase(MSRubbish, '</span>', '', 'all');
	}

	// Send it back, bring it back, sing it back... etc. Gotta love Moloko
	"Caller.#Attributes.MSText#" = Trim(MSRubbish);
</cfscript>