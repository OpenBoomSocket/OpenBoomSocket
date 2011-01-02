<!---

This library is part of the Common Function Library Project. An open source
collection of UDF libraries designed for ColdFusion 5.0. For more information,
please see the web site at:

http://www.cflib.org

Warning:
You may not need all the functions in this library. If speed
is _extremely_ important, you may want to consider deleting
functions you do not plan on using. Normally you should not
have to worry about the size of the library.

License:
This code may be used freely. 
You may modify this code as you see fit, however, this header, and the header
for the functions must remain intact.

This code is provided as is.  We make no warranty or guarantee.  Use of this code is at your own risk.
--->


<cffunction name="logthis" returntype="void" access="public" output="false">
	<cfargument name="thisText" type="string" required="yes">
	<cflog type="error" file="udfIssue" text="#arguments.thisText#">
</cffunction>

<cfscript>
/**
 * This function is a UDF for maketree custom tag developed by Michael Dinowitz.
 * 
 * @param query  Query to be sorted. (Required)
 * @param unique  Name of the column containing the primary key. (Required)
 * @param parent  Name of the column containing the parent. (Required)
 * @return Returns a query. 
 * @author Qasim Rasheed (qasimrasheed@hotmail.com) 
 * @version 1, February 17, 2005 
 */
function maketree( query, unique, parent ){
	var current = 0;
	var path = 0;
	var i = 0;
	var j = 0;
	var items = "";
	var parents = "";
	var position = "";
	var column = "";
	var retQuery = querynew( query.columnlist & ',sortlevel' );
	
	for (i=1;i lte query.recordcount;i=i+1){
		items = listappend( items, query[unique][i] );
	}
	
	for (i=1;i lte query.recordcount;i=i+1){
		parents = listappend( parents, query[parent][i] );
	}
	
	for (i=1;i lte query.recordcount;i=i+1){
		queryaddrow( retQuery );
		position = listfind( parents, current );

		while (not position){
			path = listrest( path );
			current = listfirst( path );
			position = listfind( parents, current );
		}
		for (j=1;j lte listlen( query.columnlist ); j=j+1){
			column = listgetat( query.columnlist, j );
			querysetcell( retQuery, column, evaluate( 'query.'&column&'[position]') );
		}
		querysetcell( retQuery, 'sortlevel', listlen( path ) );
		current = listgetat( items, position );
		parents = listsetat( parents, position, '-' );
		path = listprepend( path, current);

	}
	
	return retQuery;
}
</cfscript>