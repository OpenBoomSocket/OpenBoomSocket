// In this section we set up the content to be placed dynamically on the page.
// Customize movie tags and alternate html content below.

if (!useRedirect) {    // if dynamic embedding is turned on
  if(hasRightVersion) {  // if we've detected an acceptable version
    var oeTags = '<OBJECT CLASSID="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"'
    + 'WIDTH="550" HEIGHT="400"'
    + 'CODEBASE="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab">'
    + '<PARAM NAME="MOVIE" VALUE="movie.swf">'
    + '<PARAM NAME="PLAY" VALUE="true">'
    + '<PARAM NAME="LOOP" VALUE="false">'
    + '<PARAM NAME="QUALITY" VALUE="high">'
    + '<PARAM NAME="MENU" VALUE="false">'
    + '<EMBED SRC="movie.swf"'
    + 'WIDTH="550" HEIGHT="400"'
    + 'PLAY="true"'
    + 'LOOP="false"'
    + 'QUALITY="high"'
    + 'MENU="false"'
    + 'TYPE="application/x-shockwave-flash"'
    + 'PLUGINSPAGE="http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash">'
    + '<\/EMBED>'
    + '<\/OBJECT>';

    document.write(oeTags);   // embed the flash movie
  } else {  // flash is too old or we can't detect the plugin
    // NOTE: height, width are required!
    var alternateContent = '<IMG SRC="altimage.gif" HEIGHT="400" WIDTH="550">' 
      + '<BR>any desired alternate html code goes here';

    document.write(alternateContent);  // insert non-flash content
  }
}