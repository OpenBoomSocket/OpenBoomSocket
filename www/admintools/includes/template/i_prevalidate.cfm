<!--- i_prevalidate.cfm --->

<cfscript>
	regexString = '\[{1,1}\[{1,1}[a-zA-Z0-9 _]{1,}\^[0-9]{1,}\]{1,1}\]{1,1}';
	start=1;
	templateList="";
	str=form.html;
	while (start GT 0) {
		thiscontainer=REFindNoCase(regexString,str,start,1);
		if (thiscontainer.pos[1]) {
			templateList=listAppend(templateList,trim(mid(str,thiscontainer.pos[1]+2,thiscontainer.len[1]-4)));
			start=val(thiscontainer.pos[1]+thiscontainer.len[1]);
		} else {
			start=0;
		}
	}
	templateList=listSort(templateList,"Text","ASC");
</cfscript>
<cfscript>
	start=1;
	wireframeList="";
	str=form.wireframe;
	while (start GT 0) {
		thiscontainer=REFindNoCase(regexString,str,start,1);
		if (thiscontainer.pos[1]) {
			wireframeList=listAppend(wireframeList,trim(mid(str,thiscontainer.pos[1]+2,thiscontainer.len[1]-4)));
			start=val(thiscontainer.pos[1]+thiscontainer.len[1]);
		} else {
			start=0;
		}
	}
	wireframeList=listSort(wireframeList,"Text","ASC");
</cfscript>
<cfif compareNoCase(wireframeList,templateList) NEQ 0>
	<cfset request.errorMsg="Wire frame and HTML do not have matching containers!">
	<cfset request.isError=1>
</cfif>