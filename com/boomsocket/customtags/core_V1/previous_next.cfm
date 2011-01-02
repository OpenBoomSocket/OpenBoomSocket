	
	<!---
		Author   : Vikram Singh Vaid
		Email  : vikramvaid@yahoo.com, 
				
		Description: It is used for displaying particular no. of records on a page. For the rest of records
		previous neext links along with page is generated. There is another file 'previous_next2.cfm' which 
		should be in the same directory as previous_next.cfm.The tag requires three attributes
		query(Sql Query) and  query_name(Name of Sql Query), page_size (No of records to be dispalyed on single page default is 5).All the other attributes are optional. The tag returns
		Six parameters pages_link(Contains the links of pages), prev_link(containins previous link), next_link(contains next link),
		page_count(Total number of pages),page_no(Current Page Number), query(query containig required number of records)
		
		Attributes:
		
		Required
			query      : Sql Query
			query_name : Name of query
			page_size  : No of records to be dispalyed on single page (default 5)
			
		Optional
			prev_img_path   : path for image of previous link
			next_img_path   : path for image of next link
			pages_link_var  : If you want to have diffrent name for return variable 'pages_link', specify the new name to this parameter.
			prev_link_var  	: If you want to have diffrent name for return variable 'prev_link', specify the new name to this parameter.
			next_link_var  	: If you want to have diffrent name for return variable 'next_link', specify the new name to this parameter.
			page_no 		: If you want to have diffrent name for return variable 'pages_no', specify the new name to this parameter.
			page_count_var	: If you want to have diffrent name for return variable 'pages_count', specify the new name to this parameter.
			style           : Style to ne used 
			cssclass           : class in the style sheet  
			
		Return Parameters
			pages_link         :Contains pages links
			prev_link          :Contains previous link
			next_link          :Contains next links
			page_count         : Total number of pages generated
			page_no            : current page number
			query              : query containg required number of records  
			
		Usage
					
		Minimum		
			<cf_previous_next query="#query_name#" query_name="query_name" page_size="5" >	
		Optional
			<cf_previous_next query="#query_name#" query_name="query_name"  page_size="3" pages_link_var="myvar" prev_var="myvar1" next_var="myvar2" page_no="my_no_var" page_count_var="my_cnt_var" prev_img_path="c:\prev.gif"  next_img_path="c:\next.gif" style="text-decoration:none"  cssclass="myclass">		
	--->
	
	
	<cfsetting enablecfoutputonly="yes">
	<cfparam name="attributes.query" default="">
	<cfparam name="attributes.query_name" default="">
	<cfparam name="attributes.page_size" default="5">
	<cfparam name="attributes.pages_link_var" default="pages_link">
	<cfparam name="attributes.prev_link_var" default="prev_link">
	<cfparam name="attributes.next_link_var" default="next_link">
	<cfparam name="attributes.page_no_var" default="page_no">
	<cfparam name="attributes.page_count_var" default="page_count">
	<cfparam name="attributes.prev_img_path" default="">
	<cfparam name="attributes.next_img_path" default="">
	<cfparam name="attributes.previous_next" default="yes">
	<cfparam name="attributes.style" default="text-decoration:none">
	<cfparam name="attributes.cssclass" default="">
	<cfparam name="attributes.item_Str" default="Page">
	<cfparam name="attributes.useISAPI" default="false">
	<cfparam name="attributes.ISAPIURL" default="/">
	<cfparam name="start" default="1">
	<cfparam name="page_no" default="1">
	<cfparam name="next_start" default="1">
	<cfparam name="myfield_list" default="">
	<cfparam name="myvalue_list" default="">
	<cfparam name="value_str" default="">
	<cfparam name="errmsg" default="" >
	<cfparam name="next_link" default="">
	<cfparam name="prev_link" default="">
	
	
	<cfif not isquery(attributes.query)>
		<cfset errmsg=errmsg & "<br>Invalid SQL Query.Parameter 'query' should refer to valid SQL Query ">
	</cfif>	
	<cfif attributes.query_name is ''>
		<cfset errmsg=errmsg & "<br>Name of Query is required parameter.">
	</cfif>
	<cfif errmsg is not "">
		<cfset errmsg="Error in Custom Tag 'previous_next'. Following errors(s) detected." & errmsg>
		<cfoutput>
			<font face="arial" size="-1" color="red">
				#errmsg#
			</font>	
		</cfoutput>
		<cfexit method="EXITTAG">
	</cfif>
	<cfscript>
		temp_query=attributes.query;
		query_name=attributes.query_name;
		records=temp_query.recordcount;
		page_size=attributes.page_size;
		page_no_var=attributes.page_no_var;
		page_count_var=attributes.page_count_var;
		pages_link_var=attributes.pages_link_var;
		prev_link_var=attributes.prev_link_var;
		next_link_var=attributes.next_link_var;
		previous_next=attributes.previous_next;
		prev_img_path=attributes.prev_img_path;
		next_img_path=attributes.next_img_path;
		style=attributes.style;
		cssclass=attributes.cssclass;
	</cfscript>
	<cfif val(records)  gt 0>
		<cfif records gt page_size>
			<cfset page_count=ceiling(val(records)/val(page_size))>
		<cfelse>
			<cfset page_count=1>			
		</cfif>	
	<cfelse>
		<cfset page_count=0>	
	</cfif>
	
	<cfset myfield_list = "">
	<cfset myvalue_list = "">
	<cfif isdefined("form.fieldnames")>
		<cfloop list="#form.fieldnames#" index="i">
			<cfif listfindnocase(myfield_list,i) EQ 0 and trim(evaluate("form." &i)) NEQ ''>
				<cfset myfield_list=listappend(myfield_list,i)>
				<cfset myvalue_list=listappend(myvalue_list,evaluate("form." &i))>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfif isdefined("cgi.querystring")>
		<cfloop list="#cgi.query_string#" delimiters="&" index="i">
		<cfif listLen(i,"=") EQ 2>
			<cfif listfindnocase(myfield_list,i) EQ 0 and trim(listgetat(i,2, "=")) NEQ '' >
				<cfset url_name=listgetat(i,1, "=")>
				<cfset myfield_list=listappend(myfield_list,url_name)>
				<cfset myvalue_list=listappend(myvalue_list,evaluate("url."& url_name))>
			</cfif>
		</cfif>	
		</cfloop>	
	</cfif>
	
	<!---Remove 'start' and 'page_no' variables which are to be include later--->
	<cfif listfindnocase(myfield_list,'start')>
		<cfset pos=listfindnocase(myfield_list,'start')>
		<cfset myfield_list=listdeleteat(myfield_list,pos)>
		<cfset myvalue_list=listdeleteat(myvalue_list,pos)>
	</cfif>
	<cfif listfindnocase(myfield_list,'page_no')>
		<cfset pos=listfindnocase(myfield_list,'page_no')>
		<cfset myfield_list=listdeleteat(myfield_list,pos)>
		<cfset myvalue_list=listdeleteat(myvalue_list,pos)>
	</cfif>
	<cfset value_str = "">
	<cfloop list="#myfield_list#" index="i" delimiters=",">
		<cfif value_str is "">
			<cfset value_str= i & "=" & urlencodedformat(trim(listgetat(myvalue_list,listfind(myfield_list,i))))>
		<cfelse>
			<cfset value_str= value_str & "&" & i & "=" & urlencodedformat(trim(listgetat(myvalue_list,listfind(myfield_list,i))))>
		</cfif>
	</cfloop>
<form action="#request.page#" method="post">
	<cfmodule template="#application.customTagPath#/previous_next2.cfm" var_name="pages_link">
		<cfoutput>
<script language="JavaScript">
	function jumpTo(url){
		window.open(url,"_self");
	}
</script>
			<select name="jumpto" style="background-color: ##dadada; font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: 10px; border: 1px ##000000;" onchange="javascript:jumpTo(this.value);">
				<cfloop from="1" to="#page_count#" index="x">
					<cfif IsDefined('attributes.useISAPI') AND attributes.useISAPI AND IsDefined('attributes.ISAPIURL') AND Len(Trim(attributes.ISAPIURL))>
						<option value="#attributes.ISAPIURL#/start/#next_start#/page_no/#x#" <cfif x EQ page_no> SELECTED</cfif>>#attributes.item_Str# #x#
					<cfelse>
						<option value="#getfilefrompath(script_name)#?start=#next_start#&page_no=#x#<cfif len(trim(value_str))>&#value_str#</cfif>" <cfif x EQ page_no> SELECTED</cfif>>#attributes.item_Str# #x#
					</cfif>
					<cfset next_start=page_size + next_start>
				</cfloop>
			</select>
		</cfoutput>		
	</cfmodule>
	
	
	<cfmodule template="#application.customTagPath#/previous_next2.cfm" var_name="next_link">
			<cfoutput>
				<cfif evaluate(page_no) lt page_count and previous_next is 'yes'>
					<cfset temp_start=val(start) + val(page_size)>
					 <cfif IsDefined('attributes.useISAPI') AND attributes.useISAPI AND IsDefined('attributes.ISAPIURL') AND Len(Trim(attributes.ISAPIURL))>
						<a href="#attributes.ISAPIURL#/start/#temp_start#/page_no/#incrementvalue(page_no)#" style="#style#" class="#cssclass#"><cfif next_img_path is "">Next<cfelse><img src="#next_img_path#" border="0"></cfif></a>
					 <cfelse>
					 	<a href="#getfilefrompath(script_name)#?start=#temp_start#&page_no=#incrementvalue(page_no)#<cfif len(trim(value_str))>&#value_str#</cfif>" style="#style#" class="#cssclass#"><cfif next_img_path is "">Next<cfelse><img src="#next_img_path#" border="0"></cfif></a>
					 </cfif>
				</cfif>
			</cfoutput>
	</cfmodule>
	
	<cfmodule template="#application.customTagPath#/previous_next2.cfm" var_name="prev_link">
			<cfoutput>
				<cfif evaluate(page_no) gt  1 and previous_next EQ 'yes'>
					<cfset temp_start=val(start) - val(page_size)>
					<cfif IsDefined('attributes.useISAPI') AND attributes.useISAPI AND IsDefined('attributes.ISAPIURL') AND Len(Trim(attributes.ISAPIURL))>
					 	<a href="#attributes.ISAPIURL#/start/#temp_start#/page_no/#decrementvalue(page_no)#" style="#style#" class="#cssclass#" ><cfif NOT len(prev_img_path)>Previous<cfelse><img src="#prev_img_path#" border="0"></cfif></a>
					 <cfelse>
					 	<a href="#getfilefrompath(script_name)#?start=#temp_start#&page_no=#decrementvalue(page_no)#<cfif len(trim(value_str))>&#value_str#</cfif>" style="#style#" class="#cssclass#" ><cfif NOT len(prev_img_path)>Previous<cfelse><img src="#prev_img_path#" border="0"></cfif></a>
					 </cfif>
				</cfif>
			</cfoutput>
	</cfmodule>
</form>
	
	<cfset temp_query1=QueryNew(temp_query.columnlist)>
	<cfoutput query="temp_query" maxrows="#page_size#" startrow="#val(start)#" >
		<cfset temp=queryaddrow(temp_query1) >
		<cfloop list="#temp_query.columnlist#" index="i">
			<cfset temp=QuerySetCell(temp_query1,i ,evaluate("temp_query."&i))>
		</cfloop>
	</cfoutput>
	
	<cfscript>
		"caller.#page_no_var#"=page_no;
		"caller.#page_count_var#"=page_count;
		"caller.#query_name#"=temp_query1;
		"caller.#pages_link_var#"=pages_link;
		"caller.#prev_link_var#"=prev_link;
		"caller.#next_link_var#"=next_link;
	</cfscript>
	<cfsetting enablecfoutputonly="no">	  
	
	