<!--- 
	** CMC: this has to be an include rather than a .css file due to the conditional browser testing ("if gt IE 6", etc.)	
	** "adminnavlist" to be updated everywhere (including file name) with the class that is being used
	
	** Need to better document what customizable styles are for
	
	** Eventually this document should be auto gen'ed upon INITAL creation of new nav- NOT to be updated as nav is updated
	b/c this will overwrite any customization changes client may have made
--->

<cfsavecontent variable="navStyles">
<cfoutput>
<!--[if gt IE 6]> 
  <style type="text/css">
	.button .dropdown li, .adminnavlist a {{zoom: 1;}
  </style>
<![endif]-->
<!-- This CC feeds a modified Holly hack to IE7 and up. The old star-html hack is
ignored by IE7, and IE7 correctly obeys the "height: 1%" layout-triggering fix, so 
use a targeted CC and change the fix to "zoom: 1;" to achieve the same layout fix. -->
<script type="text/javascript">
function setChildNavIndicator(){
	if(document.getElementById('adminnavlist0') != null){
		var navArray = document.getElementById('adminnavlist0').childNodes;
		var subnavArray;
		var targetNode;
		
		for(j=0 ; j<navArray.length ; j++){
			subnavArray = new Array();
			if(navArray[j].childNodes[0].childNodes[1] != null && navArray[j].childNodes[0].childNodes[1].childNodes[0] != null){
				subnavArray = navArray[j].childNodes[0].childNodes[1].childNodes[0].childNodes;
				for(i=0 ; i<subnavArray.length ; i++){
					if(subnavArray[i].getElementsByTagName('ul').length){
						targetNode = subnavArray[i].getElementsByTagName('a')[0];
						targetNode.className = targetNode.className+" subsubs";
					}//if
				}//for
			}//if
		}//for
	}//if
}//func
womAdd('setChildNavIndicator()');
</script>
    
<style type="text/css">

/* Styles that WILL NOT CHANGE ****************************************************************************************/
/* NOTE!: "adminnavlist" WILL change to match inavigation attribute "basenavclass" so its unique for each flyout menu **/

	/*XXXXXXXXXXXX Primary top nav rules XXXXXXXXXXX*/
	
	.adminnavlist ul, li { padding: 0; margin: 0; list-style: none;} /* clear margins, padding, bullets from lists in nav */
	.adminnavlist {position: relative;}
	.adminnavlist .parent {position: relative;}
	/* this parent div does not provide "sticky hovering", but instead fixes a 
	strange bug in Op7. When an element serves as a hovered popup "parent" element, 
	that element must not also be floated or all heck breaks loose in Opera 7. 
	To prevent this, we have floated the top level list items, while nesting 
	hoverable parent divs inside that are then hovered to generate the dropdowns. 
	Thus the ugly (but interesting) Op7 bug is defeated. */
	
	/*XXXXXXXXXXXX Primary dropdown/flyout rules XXXXXXXXXXX*/

	.adminnavlist .dropdown { /* rules for dropdown div */
		position: absolute;		
		left: -3000px;
		top: auto; /* puts dropdowns directly under top nav */	
		background: url(images/flyoutbgfix.gif);
	}
	.adminnavlist .dropdown div {
		position: absolute;		
		left: -3000px;
		top: -5;  /* CMC: move to customization?? */
		background: url(images/flyoutbgfix.gif);
		/* The margins on the ULs replace the div paddings to create "sticky hovering"
		zones,  and the margins should "fill" the divs, making the IE BG fix unnecessary.
		Unfortunately the BG fix is still needed, altho this method does eliminate
		possible box model problems */
	}
	.adminnavlist .dropdown ul { 
	  margin: 0 30px 30px 30px; /* creates "sticky hovering" zones for dropdowns */ 
	}
	.adminnavlist .dropdown div ul {margin: 30px 30px 30px 0;} /* creates "sticky hovering" zones for flyouts */
	.adminnavlist .dropdown li {
	  position: relative; 
	  vertical-align: bottom; /* IE5/win bugfix */
	}
	.adminnavlist .parent:hover {background-image: url(images/flyoutbgfix.gif);} 
	/* this hover calls a transparent GIF only to defeat the IE failed hover bug. Any 
	background change on hovering div.parent will make IE obey and display the dropdown.
	While the call itself will fix the bug, make sure you actually call a real image 
	file so that your site error logs will not fill with failed image calls. */
	
	/*XXXXXXXXXXX Special fixes XXXXXXXXXXX*/
	
	/* This is to hide the following from IE/Mac. \*/
	* html .adminnavlist .button .dropdown li {
		height: 1%;
		margin-left: -16px;
		margin-left: 0;
	}
	/* */
	/* The first 2 rules above fix "bullet region" problems in IE5.x/win, 
	and the 2nd is to make all links fully clickable. */ 
	
	* html .adminnavlist a{height: 1%;}

/* Styles for CUSTOMIZATION *******************************************************************************************/
	
	/*XXXXXXXXXXXX Primary top nav rules XXXXXXXXXXX*/
	
	.adminnavlist {
		/*background: ##566f89;*/
		/*border: 1px solid ##888;*/ /* borders the bottom of the top nav */
		/*border-width: 1px 0;*/
		/*width: 190px;*/
		height: 41px;
		width:751px;
		float:right;
	}
	.adminnavlist .button { /* top level items */
		/*width: 190px;*/
		float: left; /* float left for horizontal nav */
		display: inline;
	}
	* html .adminnavlist .button {
		width:1px; /* if don't set, will span 100% in IE6 */
	}
	/*XXXXXXXXXXXX Primary dropdown/flyout rules XXXXXXXXXXX*/

	.adminnavlist .dropdown { /* rules for dropdown div */
		width: 250px;
		text-align: left; /* needed because IE misapplies text centering to boxes */	
	}
	.adminnavlist .dropdown div {
		width: 159px;
		/*top: 0;   CMC: needed for customization?? */
		background: url(images/flyoutbgfix.gif);
		text-align: left; /* needed because IE misapplies text centering to boxes */
	}
	.adminnavlist .dropdown ul { 
	  width: 159px; /* tweaked so that dropdowns appear to "line up" with top links */
	  /*border: 1px solid ##888; 
	  border-width: 1px 1px 0; */
	} /* borders sides and top of the dropdowns and flyouts; links provide the bottom border */
	.adminnavlist li {
		text-align: left;
	}
	.adminnavlist a {
		display: block;
		color: ##fff;
		font-weight: bold;
		font-size: .9em;
		text-decoration: none;
		padding: 6px 0 0px; 
		/*border-right: 1px solid ##888;*/  /* makes the dividers between the top nav links */
	}
	.adminnavlist ul ul li{
		border-top: 1px solid ##fff; /* seperate top and dropdown */
	}
	.adminnavlist ul ul a {
	  color: ##fff;
	  border-right: 0; /* negates right border for dropdowns and flyouts */
	  border-bottom: 0px solid ##fff;  /* borders the bottoms of the dropdown and flyout links */
	  border-left: 1px solid ##fff;
	  padding-left: 10px;
	  padding-bottom: 7px;
	}
	.adminnavlist .parent:hover div.dropdown {left: -31px;} /* hover rule for dropdowns */ 
	/* add path ", .open .parent div.dropdown" to keep open*/
	/* extra pixel makes dropdowns "line up" with top links */ 
	/* 	CMC: subnav positioning 
		use .dropdown ul{ width } as starting point
	*/
	.adminnavlist .dropdown li:hover div{ /* hover rule for flyouts */
		/* add path ",.dropdown .open div" to keep open*/
		left: 159px; /* this value controls the amount of flyout "overlap"  */
		top: -31px; /* this value controls the amount of flyout vertical offset */
		}
	.adminnavlist .dropdown li:hover {background: ##7e96ac;} /* hover color effect on dropdown links */
	
	.adminnavlist .dropdown div li:hover {background: ##7e96ac;} /* hover color effect on flyout links */
	
	
	/*XXXXXXXXXXX Dropdown background colors & fonts XXXXXXXXXX*/
	
	.adminnavlist .parent ul{
		background: ##566f89;
	}
	.adminnavlist .dropdown div ul {background: ##566f89;} /* colors BG of flyouts */ 
	.adminnavlist .dropdown div ul a {color: ##fff;} /* colors text of  flyouts */
	/*\*/ /*/
	.adminnavlist .dropdown, .adminnavlist .dropdown div {width: 189px;}
	.adminnavlist .button .dropdown ul {margin: 0px;}
	.adminnavlist .dropdown, .adminnavlist .dropdown div {position: static;}
	.adminnavlist .dropdown ul {border: 0;}
	/* this rule block "dumbs down" the nav for IEmac - width attribute is the only thing that may need to be customized 
	also be sure to update width below in if lte IE 6 test*/
	
/* End Styles for CUSTOMIZATION ******************************************************************************************/

/* CMC- move this to installer site.css? */
	.brclear { /* Use a break with this class to clear float containers */
		clear:both;
		height:0;
		margin:0;
		font-size: 1px;
		line-height: 0;
	}
/* selected/parent classes */
ul a.adminnavlistselected, ul ul a.adminnavlistselected, .dropdown div ul a.adminnavlistselected {
	display:block;
	color:##009933;
	font-weight:bold;
}
ul a.adminnavlistparent, ul ul a.adminnavlistparent {
	display:block;
	color:##000000;
	font-weight:bold;
}
ul ul a.subsubs{
	background: url(#application.globalPath#/media/images/icon_arrow.gif);
	background-position: right;
	background-repeat: no-repeat;
}
</style>
<!--[if lte IE 6]>
  <style type="text/css">
	body {behavior: url(/css/navigation/csshover.htc);}
  </style>
  <noscript>
	<style type="text/css">
		.adminnavlist .dropdown, .adminnavlist .dropdown div {width: 189px;}
		.adminnavlist .button .dropdown ul {margin: 0px;}
		.adminnavlist .dropdown, .adminnavlist .dropdown div {position: static;}
		.adminnavlist .dropdown ul {border: 0;}
	</style>
  </noscript>
<![endif]-->
<!-- The above block calls the special .htc script that forces compliance in IE6 
and lower, and also "dumbs down" the nav when IE is set not to allow scripting. 
Only IE6 and lower can read this block. -->
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#navStyles#">
