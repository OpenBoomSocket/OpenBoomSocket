<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
<cfheader name="pragma" value="no-cache">
<cfheader name="expires" value="#getHttpTimeString(now())#">
<cfinvoke component="#application.CFCPath#.topNav" method="Init"></cfinvoke>