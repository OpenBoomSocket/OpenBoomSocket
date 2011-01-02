<!--- ------------------------ This creates the scheduled task ------------------ --->
<!--- ------------------------------------------------------------------------ --->

<CFSCHEDULE ACTION="UPDATE"
		TASK="tskSQLInjection" 
		OPERATION="HTTPRequest" 
		URL="***** enter path to file *****/tskSQLInjection.cfm"
		STARTDATE="#dateFormat(NOW(), 'mm/dd/yyyy')#" 
		STARTTIME="23:59:59" 
		INTERVAL="3600" 
		PUBLISH="No"
		REQUESTTIMEOUT="8000">

Scheduled task was created/updated