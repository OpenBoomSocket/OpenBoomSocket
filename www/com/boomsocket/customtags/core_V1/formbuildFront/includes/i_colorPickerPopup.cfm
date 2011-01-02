<cfsavecontent variable="jsInsertCP">
	<cfoutput>
        <script type="text/javascript" src="#application.GlobalPath#/javascript/prototype.js"></script>
		<script type="text/javascript" src="#application.GlobalPath#/javascript/JSColorPickerAll.js"></script>
    </cfoutput>
</cfsavecontent>
<cfhtmlhead text="#jsInsertCP#">
<cfoutput>
    <script type="text/javascript">
		Event.observe(window,'load',function() {
			cp1_#a_formelements[a].fieldname# = new Refresh.Web.ColorPicker('cp1_#a_formelements[a].fieldname#');
		});
    </script>
	<cfset thisFormVal=URL.value>
	<cfset thisFormField=URL.field>
	<div id="pickerPane" name="pickerPane" style="position:absolute;display:block ;background-color:white;">
		<!--
		Copyright (c) 2007 John Dyer (http://johndyer.name)
		
		Permission is hereby granted, free of charge, to any person
		obtaining a copy of this software and associated documentation
		files (the "Software"), to deal in the Software without
		restriction, including without limitation the rights to use,
		copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the
		Software is furnished to do so, subject to the following
		conditions:
		
		The above copyright notice and this permission notice shall be
		included in all copies or substantial portions of the Software.
		
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
		OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
		NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
		HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
		WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
		FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
		OTHER DEALINGS IN THE SOFTWARE.
		-->
		<table>
			<!---<tr><td colspan="3">Previous Color:<div id="previousColor" style="background-color: ###listfirst(thisFormVal,'~')#; width: 60px; height: 20px; padding: 0; margin: 0; border: solid 1px ##000;"/></td></tr>--->
		  <tr>
			<td valign="top"><div id="cp1_ColorMap"></div></td>
			<td valign="top"><div id="cp1_ColorBar"></div></td>
			<td valign="top"><table>
				<tr>
				  <td colspan="3"><div id="cp1_Preview" style="background-color: ###thisFormVal#; width: 60px; height: 60px; padding: 0; margin: 0; border: solid 1px ##000;"> <br />
					</div></td>
				</tr>
				<tr>
				  <td><input type="radio" id="cp1_HueRadio" name="cp1_Mode" value="0" />
				  </td>
				  <td><label for="cp1_HueRadio">H:</label>
				  </td>
				  <td><input type="text" id="cp1_Hue" value="0" style="width: 40px;" />
					&deg; </td>
				</tr>
				<tr>
				  <td><input type="radio" id="cp1_SaturationRadio" name="cp1_Mode" value="1" />
				  </td>
				  <td><label for="cp1_SaturationRadio">S:</label>
				  </td>
				  <td><input type="text" id="cp1_Saturation" value="100" style="width: 40px;" />
					% </td>
				</tr>
				<tr>
				  <td><input type="radio" id="cp1_BrightnessRadio" name="cp1_Mode" value="2" />
				  </td>
				  <td><label for="cp1_BrightnessRadio">B:</label>
				  </td>
				  <td><input type="text" id="cp1_Brightness" value="100" style="width: 40px;" />
					% </td>
				</tr>
				<tr>
				  <td colspan="3" height="5"></td>
				</tr>
				<tr>
				  <td><input type="radio" id="cp1_RedRadio" name="cp1_Mode" value="r" />
				  </td>
				  <td><label for="cp1_RedRadio">R:</label>
				  </td>
				  <td><input type="text" id="cp1_Red" value="255" style="width: 40px;" />
				  </td>
				</tr>
				<tr>
				  <td><input type="radio" id="cp1_GreenRadio" name="cp1_Mode" value="g" />
				  </td>
				  <td><label for="cp1_GreenRadio">G:</label>
				  </td>
				  <td><input type="text" id="cp1_Green" value="0" style="width: 40px;" />
				  </td>
				</tr>
				<tr>
				  <td><input type="radio" id="cp1_BlueRadio" name="cp1_Mode" value="b" />
				  </td>
				  <td><label for="cp1_BlueRadio">B:</label>
				  </td>
				  <td><input type="text" id="cp1_Blue" value="0" style="width: 40px;" />
				  </td>
				</tr>
				<tr>
				  <td> ##: </td>
				  <td colspan="2"><input type="text" id="cp1_Hex" value="FF0000" style="width: 60px;" />
				  </td>
				</tr>
			  </table></td>
		  </tr>
		  <tr><td colspan="3"><input type="button" value="Set Color" onclick="javascript:window.opener.document.getElementById('#a_formelements[a].fieldname#').value=document.getElementById('cp1_Hex').value;this.close();window.opener.document.getElementById('#a_formelements[a].fieldname#Color').style.backgroundColor=document.getElementById('cp1_Preview').style.backgroundColor;" /><input type="button" value="Cancel" onclick="javascript:this.close();" /></td></tr>
		</table>
		<div style="display:none;"> <img src="#APPLICATION.globalpath#/media/images/rangearrows.gif" /> <img src="#APPLICATION.globalpath#/media/images/mappoint.gif" /> <img src="#APPLICATION.globalpath#/media/images/bar-saturation.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-brightness.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-blue-tl.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-blue-tr.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-blue-bl.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-blue-br.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-red-tl.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-red-tr.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-red-bl.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-red-br.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-green-tl.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-green-tr.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-green-bl.png" /> <img src="#APPLICATION.globalpath#/media/images/bar-green-br.png" /> <img src="#APPLICATION.globalpath#/media/images/map-red-max.png" /> <img src="#APPLICATION.globalpath#/media/images/map-red-min.png" /> <img src="#APPLICATION.globalpath#/media/images/map-green-max.png" /> <img src="#APPLICATION.globalpath#/media/images/map-green-min.png" /> <img src="#APPLICATION.globalpath#/media/images/map-blue-max.png" /> <img src="#APPLICATION.globalpath#/media/images/map-blue-min.png" /> <img src="#APPLICATION.globalpath#/media/images/map-saturation.png" /> <img src="#APPLICATION.globalpath#/media/images/map-saturation-overlay.png" /> <img src="#APPLICATION.globalpath#/media/images/map-brightness.png" /> <img src="#APPLICATION.globalpath#/media/images/map-hue.png" /> </div><br style="clear:both" />
	</div>
</cfoutput>