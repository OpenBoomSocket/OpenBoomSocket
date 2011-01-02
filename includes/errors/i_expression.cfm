<cfscript>
	// Send the error data to our CFC so it can be recorded, and staff notified. This will return a boolean if you care.
	//thiserrorDP = createobject('component','#application.sitemapping#.components.globalError');
	recorded = application.globalError.recordError(error);
</cfscript>
<cfoutput>
	<h2>Expression Error</h2>
	<p>You have encountered an exception error while using our site. An exception error
	  canbe caused by one of the following:</p>
	<ul>
		<li>A programming error in our website</li>
		<li>The page you are accessing doesn't exist
		  <ul>
		    <li>Sounds confusing but our site is dynamically generated using ColdFusion
		      and a database. Not all of our pages exist the same way, some are actual
		      files on our server, while others are dynamically generated when you
		      request them. It's these dynamically generated pages which can throw this
		      error..</li>
          </ul>
		</li>
    </ul>
    <p>Some possible ways to fix this error you can try</p>
    <ul>
      <li>First check your URL and make sure everything is spelled correctly. If
        someone gave you this URL then check with them to make sure it's the correct
        one.</li>
      <li>If you visited this site from another page within our site
        <ul>
          <li>click the back
            button in your browser, </li>
          <li>once on the previous page Hold down the shift key and click the refresh
            button</li>
          <li>click the link again.</li>
        </ul>
      </li>
    </ul>
    <p>If you are still getting this error don't worry. We have automatically notified
      our support team and we will work on it shortly. You can either contact us
      for more information, or check back in a few hours. </p>
</cfoutput>