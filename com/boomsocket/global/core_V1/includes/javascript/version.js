function reAssign(formname,updateItem){
var agree=confirm("Are you certain you wish to change the "+updateItem+" of this item?");
	if (agree) {
		eval('document.'+formname+'.submit()');
	}else {
		return false;
	}
}

function updateRowVersion(oldversionid,newversionid){
	//hidden fields Both Homepage and ReviewQueue
	var colorcode = document.getElementById(newversionid+"_colorcode").value;
	var versionstatusid = document.getElementById(newversionid+"_versionstatusid").value;
	var ownerfirstname = document.getElementById(newversionid+"_ownerfirstname").value;
	var ownerlastname = document.getElementById(newversionid+"_ownerlastname").value;
	var ownerinitials = document.getElementById(newversionid+"_ownerinitials").value;
	var datemodified = document.getElementById(newversionid+"_datemodified").value;
	var formobjectitemid = document.getElementById("formobject").value;
	var instanceitemid = document.getElementById(newversionid+"_instanceitemid").value;
	var canManageVersions = 0;
	var parentid = document.getElementById("parentid").value;
	//hidden fields ReviewQueue Only
	if(document.getElementById('pageview').value == "reviewqueue"){
		var ownerid = document.getElementById(newversionid+"_ownerid").value;
		var creatorfirstname = document.getElementById(newversionid+"_creatorfirstname").value;
		var creatorlastname = document.getElementById(newversionid+"_creatorlastname").value;
		var creatorinitials = document.getElementById(newversionid+"_creatorinitials").value;
		var supervisorfirstname = document.getElementById(newversionid+"_supervisorfirstname").value;
		var supervisorlastname = document.getElementById(newversionid+"_supervisorlastname").value;
		var supervisorinitials = document.getElementById(newversionid+"_supervisorinitials").value;
		var datecreated = document.getElementById(newversionid+"_datecreated").value;
		var canManageVersions = document.getElementById(newversionid+"_canManageVersions").value;
		var requestpage = document.getElementById("requestpage").value;
	}
//Both HomePage View & ReviewQueue View
	document.getElementById('statusCol'+oldversionid).style.background=colorcode;
	document.getElementById('datemodified'+oldversionid).innerHTML = datemodified;
	if(canManageVersions == 0){
		document.getElementById('editLink'+oldversionid).innerHTML = '<a href="index.cfm?i3currenttool='+formobjectitemid+'&instanceid='+instanceitemid+'&displayForm=1&formstep=showform&reviewQueue=yes" class="littleLink">edit</a>';
	}else{
		document.getElementById('editLink'+oldversionid).innerHTML = '<a href="index.cfm?i3currenttool='+formobjectitemid+'&instanceid='+instanceitemid+'&displayForm=1&formstep=showform&reviewQueue=yes" class="littleLink">edit</a> | <a href="'+requestpage+'?manageVersions=yes&parentid='+parentid+'&formobjectid='+formobjectitemid+'">version mgt</a>';
	}
	//versionstatus select
	var indexcount = 0;
	var indextoselect = -1;
	for(i=0; i<document.getElementById('versionstatusid'+oldversionid).length; i++){
		if(document.getElementById('versionstatusid'+oldversionid)[indexcount].value == versionstatusid){
			indextoselect = indexcount;
		}
		indexcount+=1;
	}
	if(indextoselect != -1){
		document.getElementById('versionstatusid'+oldversionid).selectedIndex=indextoselect
	}			
//Homepage View Only
	if(document.getElementById('pageview').value == "homepage"){
		//owner innerhtml
		document.getElementById('owner'+oldversionid).innerHTML = '<a href="javascript: void(0)" title="'+ownerfirstname+' '+ownerlastname+'" class="nottalink">'+ownerinitials.toUpperCase()+'</a>';
	}			
//Review Queue Only
	if(document.getElementById('pageview').value == "reviewqueue"){			
		document.getElementById('datecreated'+oldversionid).innerHTML=datecreated;
		document.getElementById('creator'+oldversionid).innerHTML='<a href="javascript: void(0)" title="'+creatorfirstname+' '+creatorlastname+'" class="nottalink">'+creatorinitials.toUpperCase()+'</a>';
		document.getElementById('supervisor'+oldversionid).innerHTML='<a href="javascript: void(0)" title="'+supervisorfirstname+' '+supervisorlastname+'" class="nottalink">'+supervisorinitials.toUpperCase()+'</a>';
		//owner select
		var indexcount = 0;
		var indextoselect = -1;
		for(i=0; i<document.getElementById('ownerselect'+oldversionid).length; i++){
			if(document.getElementById('ownerselect'+oldversionid)[indexcount].value == ownerid){
				indextoselect = indexcount;
			}
			indexcount+=1;
		}
		if(indextoselect != -1){
			document.getElementById('ownerselect'+oldversionid).selectedIndex=indextoselect
		}
	}
	//alert('finished');
}