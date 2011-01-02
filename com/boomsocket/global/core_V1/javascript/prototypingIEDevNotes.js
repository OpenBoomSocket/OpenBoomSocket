// JavaScript Document
function wrapFish() { 
	var devNotesBlock = document.getElementById('devNotesBlock');  
	// pick the devNotesBlock out of the tree 
	var subelements = []; 
	for (var i = 0; i < document.body.childNodes.length; i++) { 
		subelements[i] = document.body.childNodes[i];  
	}  
	// write everything else to an array 
	var zip = document.createElement('div');     
	// Create the outer-most div (zip) 
	zip.id = 'zip';                      
	// give it an ID of  'zip' 
	for (var i = 0; i < subelements.length; i++) { 
		zip.appendChild(subelements[i]);   
	// pop everything else inside the new DIV 
	} 
	document.body.appendChild(zip);  
	// add the major div back to the doc 
	document.body.appendChild(devNotesBlock);  
	// add the devNotesBlock after the div#zip 
} 
	window.onload = wrapFish;   
	// run that function! 