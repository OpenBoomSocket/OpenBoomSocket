// JavaScript Document

function showHide(){
	if (document.getElementById('prototypecontent').style.display == 'none'){
		document.getElementById('prototypecontent').style.display = 'block';
		document.getElementById('showArrow').style.display = 'inline';
		document.getElementById('hideArrow').style.display = 'none';
	}else{
		document.getElementById('prototypecontent').style.display = 'none';
		document.getElementById('showArrow').style.display = 'none';
		document.getElementById('hideArrow').style.display = 'inline';
	}
}

function designModeOn(){
	var editor = FCKeditorAPI.GetInstance('noteText');
	editor.EditorDocument.designMode = "on";
	editor.EditorDocument.body.innerHTML = ""
}
function designModeOff(){
	var editor = FCKeditorAPI.GetInstance('noteText');
	editor.EditorDocument.designMode = "off";
}

function showHideDevNotes(){
	if (document.getElementById('devnotesbody').style.display == 'none'){
		document.getElementById('devnotesbody').style.display = 'block';
		document.getElementById('showArrow2').style.display = 'inline';
		document.getElementById('hideArrow2').style.display = 'none';
		designModeOn();
		//set a cookie to remember dev notes is open (expires in 30min: 3600000*hrs)
		document.cookie = "devNotesOpen=1;expires=3600000*.5";
	}else{
		document.getElementById('devnotesbody').style.display = 'none';
		document.getElementById('showArrow2').style.display = 'none';
		document.getElementById('hideArrow2').style.display = 'inline';
		//set a cookie to remember dev notes is open (expires in 30min: 3600000*hrs)
		document.cookie = "devNotesOpen=0;expires=3600000*.5";
	}
}

function viewNote(viewThis,callingDiv){
	if(document.getElementById('detailBlock') == null || document.getElementById('detailBlock').style.display == 'none'){
		tempDiv = document.createElement('div');
		tempDiv.id = "detailBlock";
		callingDiv.parentNode.appendChild(tempDiv);
		tempDiv.innerHTML = document.getElementById(viewThis).innerHTML;
		document.getElementById('detailBlock').style.display = 'block';
	}else{
		document.getElementById('detailBlock').style.display = 'none';
		tempDiv = document.getElementById('detailBlock');
	}
}

var currentHTML;

function showContext(state,targetID){
	var targetArray = targetID.split("_");
	var targetNum = targetArray[1];
	var targetDiv = "target_"+targetNum;
	var displayDiv = "divtarget_"+targetNum;
	
	//<div class="annotateNumber" name="divtarget_1" id="divtarget_1" style="display: none;">1</div>
	if(document.getElementById(targetDiv)){
		if(state){
			if(!document.getElementById(displayDiv)){
				var newDiv=document.createElement('div');
				newDiv.className="annotateNumber";  
				newDiv.id=displayDiv; 
				newDiv.name=displayDiv;
				newDiv.style.display="block";
				document.getElementById(targetDiv).parentNode.insertBefore(newDiv,document.getElementById(targetDiv)); 
				newDiv.innerHTML=targetNum;
			}
			document.getElementById(targetDiv).style.backgroundColor = '#cacaca';
			document.getElementById(displayDiv).style.display="block";
	 
		}else{
			document.getElementById(targetDiv).style.backgroundColor = '';
			document.getElementById(displayDiv).style.display="none"; 
		}
	}
}