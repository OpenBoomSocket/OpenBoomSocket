<cfscript>
	sm_path = CGI.CF_TEMPLATE_PATH;
	sm_path_RegEx = '\\([a-zA-Z0-9]{1,})\\BS_Global\\';
	sm_path_Pull_Data = reFindNoCase(sm_path_RegEx,sm_path,1,true);
	this_sm = mid(sm_path,sm_path_Pull_Data.pos[2],sm_path_Pull_Data.len[2]);
</cfscript>
<cfinclude template="\#this_sm#\application.cfm">