<!--- declare which pages are tool-based.  will need: pageid, dbtable, fields, link format --->
<cfscript>
//V1: this info is hardcoded
//	will need to repeat this block for as many tool based pages want to display in sitemap	
	allTBpages = ArrayNew(1);
	
	/* Left this in as example
	TBpage = StructNew();
	TBpage.pageid = 100027;
	TBpage.dbtable = "services";
	TBpage.fields = "servicename,vanityurl";
	TBpage.linkpage = "/services/index.cfm";
	TBpage.linkqs = "key=[vanityurl";//	note: all variables must be prepended with [
	TBpage.linklabel = "servicename";
	TBpage.where = ""; //do not include "WHERE" in this string
	TBpage.orderby = "";
	TBpage.hasWorkflow = 1;		
	ArrayAppend(allTBpages, TBpage);
	
	/*TBpage2 = StructNew(); //	note: will need to create a unique structure for each tb item before appending to array */
</cfscript>

<cfset numCols = 2>
<cfset contentwidth = "650">
<cfmodule template="#application.customTagPath#/sitemap.cfm" alltbpages="#allTBpages#" numcols="#numCols#" contentwidth="#contentwidth#">


