//update status/owner alerts & confirmations
function showColorKey(){
	document.getElementById('colorkey').style.visibility="visible";
}
function hideColorKey(){
	document.getElementById('colorkey').style.visibility="hidden";
}

function reAssign(formname,updateItem){
	var canUpdate = 1;
	var isOwner = 0;
	var isSup = 0;
	//if changing status to published, make sure they have rights
	if (updateItem == 'status'){
		var statusid = eval('document.'+formname+'.versionstatusid.value');
		if (statusid == '100002'){
			var versionid = eval('document.'+formname+'.versionid.value');
			var canPublish = document.getElementById(versionid+'_canPublish').value;
			if (canPublish != 1){
				canUpdate = 0;
				alert("Sorry, you do not have permissions to publish this item.");
				return false;
			}
		//if changing to rejected make sure they have rights
		}else if (statusid == '100003'){
			var versionid = eval('document.'+formname+'.versionid.value');
			var canReject = document.getElementById(versionid+'_canReject').value;
			if (canReject != 1){
				canUpdate = 0;
				alert("Sorry, you do not have permissions to reject this item.");
				return false;
			}
		//if approved or approved & scheduled, make sure they have rights
		}else if (statusid == '100001' || statusid == '100004'){
			var versionid = eval('document.'+formname+'.versionid.value');
			var canApprove = document.getElementById(versionid+'_canApprove').value;
			if (canApprove != 1){
				canUpdate = 0;
				alert("Sorry, you do not have permissions to approve this item.");
				return false;
			}
		}
	}else if (updateItem == 'owner'){
		//if they are the owner but not the supervisor, alert
		var versionid = eval('document.'+formname+'.versionid.value');
		isOwner = document.getElementById(versionid+'_isOwner').value;
		isSup = document.getElementById(versionid+'_isSupervisor').value;
		if (isOwner == 1 && isSup != 1){
			alert("Note: If you change the ownernship of this item, you may no longer be able to modify this item.");	
		}
	}
	if (canUpdate == 1){
		var agree=confirm("Are you certain you wish to change the "+updateItem+" of this item?");
		if (agree) {
			eval('document.'+formname+'.submit()');
		}else {
			return false;
		}
	}
}

//on change version from condensed/dashboard view: update contents of that row
function updateRowVersion(oldversionid,newversionid){
//hidden fields w/ vars needed for processing
	//formobject/version group specific
	var requestpage = document.getElementById("requestpage").value;
	var RQformobjectid = document.getElementById("RQformobjectid").value;
	//instance specific
	var canManageVersions = document.getElementById(newversionid+"_canAccessVersionMgt").value;
	var canAccess = document.getElementById(newversionid+"_canAccess").value;
	var formobjectitemid = document.getElementById(newversionid+"_formobject").value;
	var instanceitemid = document.getElementById(newversionid+"_instanceitemid").value;
	var parentid = document.getElementById(newversionid+"_parentid").value;
	var status = document.getElementById(newversionid+"_status").value;
	var versionstatusid = document.getElementById(newversionid+"_versionstatusid").value;
	var colorcode = document.getElementById(newversionid+"_colorcode").value;	
	var ownerid = document.getElementById(newversionid+"_ownerid").value;
	var ownerfirstname = document.getElementById(newversionid+"_ownerfirstname").value;
	var ownerlastname = document.getElementById(newversionid+"_ownerlastname").value;
	var ownerinitials = document.getElementById(newversionid+"_ownerinitials").value;	
	var creatorfirstname = document.getElementById(newversionid+"_creatorfirstname").value;
	var creatorlastname = document.getElementById(newversionid+"_creatorlastname").value;
	var creatorinitials = document.getElementById(newversionid+"_creatorinitials").value;
	var supervisorfirstname = document.getElementById(newversionid+"_supervisorfirstname").value;
	var supervisorlastname = document.getElementById(newversionid+"_supervisorlastname").value;
	var supervisorinitials = document.getElementById(newversionid+"_supervisorinitials").value;	
	var datemodified = document.getElementById(newversionid+"_datemodified").value;	
	var datecreated = document.getElementById(newversionid+"_datecreated").value;
	var canEdit = document.getElementById(newversionid+"_canEdit").value;
	var canChangeOwner = document.getElementById(newversionid+"_canChangeOwner").value;	
	
	//statusColumn bgcolor
	document.getElementById('statusCol'+oldversionid).style.background=colorcode;
	//datemodified
	document.getElementById('datemodified'+oldversionid).innerHTML = datemodified;
	//edit links
	if(canManageVersions == 0){
		if(canAccess == 1){
			document.getElementById('editLink'+oldversionid).innerHTML = '<a href="index.cfm?i3currenttool='+formobjectitemid+'&instanceid='+instanceitemid+'&displayForm=1&formstep=showform&reviewQueue=yes" class="littleLink"><img src="/#application.globalPath#/media/images/icon_editVersion.gif" border="0" title="edit" /></a>';
		}
	}else{
		document.getElementById('editLink'+oldversionid).innerHTML = '<a href="index.cfm?i3currenttool='+formobjectitemid+'&instanceid='+instanceitemid+'&displayForm=1&formstep=showform&reviewQueue=yes" class="littleLink"><img src="/#application.globalPath#/media/images/icon_editVersion.gif" border="0" title="edit" /></a> <a href="index.cfm?i3currenttool='+RQformobjectid+'&manageVersions=yes&parentid='+parentid+'&formobjectid='+formobjectitemid+'"><img src="/#application.globalPath#/media/images/icon_manageVersions.gif" border="0" title="version management" /></a>';
	}
	//version status dropdown disabled & size
	if(canEdit != 1){
		document.getElementById('versionstatusid'+oldversionid).disabled="true";
		document.getElementById('versionstatusid'+oldversionid).size='1';
	}else{
		document.getElementById('versionstatusid'+oldversionid).disabled=null;
		//set all status selects back to 1
		var allversionids = new Array();
		allversionids = document.getElementById('allversionids').value.split(',');
		for(i=1; i<allversionids.length; i++){
			if(document.getElementById('versionstatusid'+allversionids[i-1])){
				document.getElementById('versionstatusid'+allversionids[i-1]).size='1';
			}
		}
		//set this version status select size to 5
		document.getElementById('versionstatusid'+oldversionid).size='5';
	}	
	//version status dropdown select
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
	//date created	
	document.getElementById('datecreated'+oldversionid).innerHTML=datecreated;
	//creator
	document.getElementById('creator'+oldversionid).innerHTML='<a href="javascript: void(0)" title="'+creatorfirstname+' '+creatorlastname+'" class="nottalink">'+creatorinitials.toUpperCase()+'</a>';
	//supervisor
	document.getElementById('supervisor'+oldversionid).innerHTML='<a href="javascript: void(0)" title="'+supervisorfirstname+' '+supervisorlastname+'" class="nottalink">'+supervisorinitials.toUpperCase()+'</a>';
	//owner select
	if(canChangeOwner != 1){
		document.getElementById('ownerselect'+oldversionid).disabled="true";
	}else{
		document.getElementById('ownerselect'+oldversionid).disabled=null;
	}
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
	//alert('finished');
}

//05/12/06 CMC: functions for new dashboard view
function checkStatusPerm(formname,statusid){
	var alertMsg = '';
	var statusColor = '#FF9933';
	var versionid = eval('document.'+formname+'.versionid.value');
	switch(statusid){
		//Approved
		case "100001": 
			statusColor = "#00CCCC";
			if(document.getElementById(versionid+"_canApprove").value != 1){
				alertMsg = "Sorry, you do not have permission to approve this item";
			}
			break;
		//Publish
		case "100002": 
			statusColor = "#006600";
			if(document.getElementById(versionid+"_canPublish").value != 1){
				alertMsg = "Sorry, you do not have permission to publish this item";
			}
			break;
		//Reject
		case "100003": 
			statusColor = "#CC0000";
			if(document.getElementById(versionid+"_canReject").value != 1){
				alertMsg = "Sorry, you do not have permission to reject this item";
			}
			break;
		//Approved & Scheduled
		case "100004": 
			statusColor = "#993399";
			if(document.getElementById(versionid+"_canApprove").value != 1){
				alertMsg = "Sorry, you do not have permission to approve this item";
			}
			break;
	}
	//does not have permissions to choose this status
	if(alertMsg != ''){
		alert(alertMsg);
		document.getElementById("versionstatusid"+versionid).value = document.getElementById(versionid+"_currStatus").value;
		document.getElementById('statusCol'+versionid).style.background=document.getElementById(versionid+"_currStatusColor").value;
	//has permission to choose this status
	}else{ 
		//change status td color to match selection
			document.getElementById('statusCol'+versionid).style.background=statusColor;
	}	
}