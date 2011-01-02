<cfscript>
	// Send the error data to our CFC so it can be recorded, and staff notified. This will return a boolean if you care.
	//thiserrorDP = createobject('component','#application.sitemapping#.components.globalError');
	recorded = application.globalError.recordError(error);
</cfscript>
<cfoutput>
	<h2>#error.rootcause.type# Error</h2>
	<p>We are sorry you are getting this error. A member of our staff has been notified and we will begin working on it shortly.</p>
</cfoutput>