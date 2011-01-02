<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Error Encountered on >#application.sitename#</title>
</head>

<body>
	<cfif FileExists('#application.installpath#\admintools\media\images\clientLogo2.jpg')>
		<img src="/admintools/media/images/clientLogo.jpg">
	<cfelse>
		<h1><cfoutput>#application.sitename#</cfoutput></h1>
	</cfif>
<cfinclude template="/#application.sitemapping#/includes/i_error.cfm">
</body>
</html>
