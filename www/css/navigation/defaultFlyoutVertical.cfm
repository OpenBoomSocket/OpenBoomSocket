<!--- 
	** CMC: this has to be an include rather than a .css file due to the conditional browser testing ("if gt IE 6", etc.)	
	** "basenavlist" to be updated everywhere (including file name) with the class that is being used
	
	** Need to better document what customizable styles are for
	
	** Eventually this document should be auto gen'ed upon INITAL creation of new nav- NOT to be updated as nav is updated
	b/c this will overwrite any customization changes client may have made
--->

<cfsavecontent variable="navStyles">
<cfoutput>
<!--[if gt IE 6]> 
  <style type="text/css">
	.button .dropdown li, .defaultFlyoutVertical a {{zoom: 1;}
  </style>
<![endif]-->
<!-- This CC feeds a modified Holly hack to IE7 and up. The old star-html hack is
ignored by IE7, and IE7 correctly obeys the "height: 1%" layout-triggering fix, so 
use a targeted CC and change the fix to "zoom: 1;" to achieve the same layout fix. -->
    
<style type="text/css">

/* Styles that WILL NOT CHANGE ****************************************************************************************/
/* NOTE!: "basenavlist" WILL change to match inavigation attribute "basenavclass" so its unique for each flyout menu **/

	/*XXXXXXXXXXXX Primary top nav rules XXXXXXXXXXX*/
	
	.defaultFlyoutVertical ul, .defaultFlyoutVertical li { padding: 0; margin: 0; list-style: none;} /* clear margins, padding, bullets from lists in nav */
	.defaultFlyoutVertical {position: relative;}
	.defaultFlyoutVertical .parent {position: relative;}
	/* this parent div does not provide "sticky hovering", but instead fixes a 
	strange bug in Op7. When an element serves as a hovered popup "parent" element, 
	that element must not also be floated or all heck breaks loose in Opera 7. 
	To prevent this, we have floated the top level list items, while nesting 
	hoverable parent divs inside that are then hovered to generate the dropdowns. 
	Thus the ugly (but interesting) Op7 bug is defeated. */
	
	/*XXXXXXXXXXXX Primary dropdown/flyout rules XXXXXXXXXXX*/

	.defaultFlyoutVertical .dropdown { /* rules for dropdown div */
		position: absolute;		
		left: -3000px;
		top: auto; /* puts dropdowns directly under top nav */	
		background: url(images/flyoutbgfix.gif);
	}
	.defaultFlyoutVertical .dropdown div {
		position: absolute;		
		left: -3000px;
		top: 0;  /* CMC: move to customization?? */
		background: url(images/flyoutbgfix.gif);
		/* The margins on the ULs replace the div paddings to create "sticky hovering"
		zones,  and the margins should "fill" the divs, making the IE BG fix unnecessary.
		Unfortunately the BG fix is still needed, altho this method does eliminate
		possible box model problems */
	}
	.defaultFlyoutVertical .dropdown ul { 
	  margin: 0 30px 30px 30px; /* creates "sticky hovering" zones for dropdowns */ 
	}
	.defaultFlyoutVertical .dropdown div ul {margin: 30px 30px 30px 0;} /* creates "sticky hovering" zones for flyouts */
	.defaultFlyoutVertical .dropdown li {
	  position: relative; 
	  vertical-align: bottom; /* IE5/win bugfix */
	}
	.defaultFlyoutVertical .parent:hover {background-image: url(images/flyoutbgfix.gif);} 
	/* this hover calls a transparent GIF only to defeat the IE failed hover bug. Any 
	background change on hovering div.parent will make IE obey and display the dropdown.
	While the call itself will fix the bug, make sure you actually call a real image 
	file so that your site error logs will not fill with failed image calls. */
	
	/*XXXXXXXXXXX Special fixes XXXXXXXXXXX*/
	
	/* This is to hide the following from IE/Mac. \*/
	* html .defaultFlyoutVertical .button .dropdown li {
		height: 1%;
		margin-left: -16px;
		mar\gin-left: 0;
	}
	/* */
	/* The first 2 rules above fix "bullet region" problems in IE5.x/win, 
	and the 2nd is to make all links fully clickable. */ 
	
	* html .defaultFlyoutVertical a{height: 1%;}

/* Styles for CUSTOMIZATION *******************************************************************************************/
	
	/*XXXXXXXXXXXX Primary top nav rules XXXXXXXXXXX*/
	
	.defaultFlyoutVertical {
		width: 170px;
	}
	.defaultFlyoutVertical ul{
		width:170px;
		background: ##def;
		border: 1px solid ##888; 
	  	border-width: 1px 1px 0 1px; /* borders sides and top of the dropdowns and flyouts; links provide the bottom border */
	}
	.defaultFlyoutVertical .parent { /* top level items */
		width: 170px;		
		/*float: left; /* float left for horizontal nav */
	}
	/*XXXXXXXXXXXX Primary dropdown/flyout rules XXXXXXXXXXX*/

	.defaultFlyoutVertical .dropdown { /* rules for dropdown div */
		width: 250px;
		text-align: left; /* needed because IE misapplies text centering to boxes */	
	}
	.defaultFlyoutVertical .dropdown div {
		width: 220px;
		/*top: 0;   CMC: needed for customization?? */
		background: url(images/flyoutbgfix.gif);
		text-align: left; /* needed because IE misapplies text centering to boxes */
	}
	.defaultFlyoutVertical .dropdown ul { 
	  margin:-25px 0 0 200px; /*dropdown positioning- make sure there is some overlap (even if 1px) so subs don't disappear when roll off parent items*/
	  width: 189px;
	} 
	.defaultFlyoutVertical li {text-align: center;}
	.defaultFlyoutVertical a {
		display: block;
		color: ##800;
		font-weight: bold;
		font-size: .9em;
		text-decoration: none;
		padding: 6px 0 5px; 
		border-bottom: 1px solid ##888;  /* makes the dividers between the top nav links */
	}
	.defaultFlyoutVertical ul ul a {
	  color: ##fff;
	  border-right: 0; /* negates right border for dropdowns and flyouts */
	  border-bottom: 1px solid ##888;  /* borders the bottoms of the dropdown and flyout links */
	}
	.defaultFlyoutVertical .parent:hover div.dropdown {left: -31px;} /* hover rule for dropdowns */ 
	/* add path ", .open .parent div.dropdown" to keep open*/
	/* extra pixel makes dropdowns "line up" with top links */ 
	/* 	CMC: subnav positioning 
		use .dropdown ul{ width } as starting point
	*/
	.defaultFlyoutVertical .dropdown li:hover {background: ##235;} /* hover color effect on dropdown links */	
	.defaultFlyoutVertical .dropdown div li:hover {background: ##ff7;} /* hover color effect on flyout links */
	
	
	/*XXXXXXXXXXX Dropdown background colors & fonts XXXXXXXXXX*/
	
	.defaultFlyoutVertical .parent ul{
		background: ##459;
	}
	* html .defaultFlyoutVertical .dropdown ul li{ /* IE6 fix - top list item wasnt getting bg  color*/
		background: ##459;
	} 
	.defaultFlyoutVertical .dropdown div ul {background: ##d79b00;} /* colors BG of flyouts */ 
	.defaultFlyoutVertical .dropdown div ul a {color: ##666666;} /* colors text of  flyouts */
	/*\*/ /*/
	.defaultFlyoutVertical .dropdown, .defaultFlyoutVertical .dropdown div {width: 189px;}
	.defaultFlyoutVertical .button .dropdown ul {margin: 0px;}
	.defaultFlyoutVertical .dropdown, .defaultFlyoutVertical .dropdown div {position: static;}
	.defaultFlyoutVertical .dropdown ul {border: 0;}
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
ul a.defaultFlyoutVerticalselected, ul ul a.defaultFlyoutVerticalselected, .dropdown div ul a.defaultFlyoutVerticalselected {
	display:block;
	color:##009933;
	font-weight:bold;
}
ul a.defaultFlyoutVerticalparent, ul ul a.defaultFlyoutVerticalparent {
	display:block;
	color:##000000;
	font-weight:bold;
}
</style>
<!--[if lte IE 6]>
  <style type="text/css">
	body {behavior: url(/css/navigation/csshover.htc);}
  </style>
  <noscript>
	<style type="text/css">
		.defaultFlyoutVertical .dropdown, .defaultFlyoutVertical .dropdown div {width: 189px;}
		.defaultFlyoutVertical .button .dropdown ul {margin: 0px;}
		.defaultFlyoutVertical .dropdown, .defaultFlyoutVertical .dropdown div {position: static;}
		.defaultFlyoutVertical .dropdown ul {border: 0;}
	</style>
  </noscript>
<![endif]-->
<!-- The above block calls the special .htc script that forces compliance in IE6 
and lower, and also "dumbs down" the nav when IE is set not to allow scripting. 
Only IE6 and lower can read this block. -->
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#navStyles#">
