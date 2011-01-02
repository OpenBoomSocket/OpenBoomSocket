<cfscript>
	// Send the error data to our CFC so it can be recorded, and staff notified. This will return a boolean if you care.
	//thiserrorDP = createobject('component','#application.sitemapping#.components.globalError');
	recorded = application.globalError.recordError(error);
</cfscript>
<cfoutput>
	<h2>Database Error</h2>
	<cfif FindNoCase('Login fails',error.rootCause.Detail)>
		<p>We apologize for the inconvenience but our web site is currently under going database maintenance, which should only last an hour.</p>
	</cfif>
	<cfif FindNoCase('Connection reset by peer: socket write error',error.rootCause.Detail)>
		<p>We apologize for the inconvenience but our web site is currently under going a database refresh, which should only last a few minutes.</p>
	</cfif>
    <p>We have automatically notified our support team that you received this error
      and if it's not related to our maintenance we will begin work on a resolution
      shortly. You can either contact us for more information or check back later.</p>
</cfoutput>