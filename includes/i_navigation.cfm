<!--- generate dynamic navigation --->
<!--- available arguments: *required
	navigationID*: numeric; navigation id that holds nav items you wish to display
	editmode: boolean; identifies if in nav edit mode; default=0
	returnType: string; used for dhtml nav only; default=""
	wraplevel: numeric; identifies the current recursion level; default=0
	thisPageID: numeric; current page; default="0"
	topOnly: boolean; topOnly - turn on/off recursion; default=0
	classBase: the base naming scheme for the class type; default=""
	showSingleSection: numeric; dynamic navigation id of section nav to pull; default=""
	
	Note: to use the navWrapper (list format) custom tag, the navigation group must be "Listing"
--->
<cfmodule template="#application.customTagPath#/i3navigation.cfm" navigationid="100000" editmode="0" wraplevel="0" thisPageID="#REQUEST.thispageid#">