<cfsetting showdebugoutput="no">
<table width="100%" border="0" cellspacing="1" cellpadding="3">
  <tr>
    <td>Your Name </td>
    <td><input name="senderName" type="text" id="senderName" size="40"></td>
  </tr>
  <tr>
    <td>Your Email </td>
    <td><input name="senderEmail" type="text" id="senderEmail" size="40"></td>
  </tr>
  <tr>
    <td>Friends Name </td>
    <td><input name="friendName" type="text" id="friendName" size="40"></td>
  </tr>
  <tr>
    <td>Friend Email </td>
    <td><input name="friendEmail" type="text" id="friendEmail" size="40"></td>
  </tr>
  <tr>
    <td>URL sending: </td>
    <td><cfoutput>http://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#</cfoutput></td>
  </tr>
  <tr>
    <td>Your comments </td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2"><textarea name="textfield6" cols="50" rows="5"></textarea></td>
  </tr>
  <tr>
    <td colspan="2" align="center"><input type="submit" name="Submit" value="Submit">
    <input name="Reset" type="reset" id="Reset" value="Reset"></td>
  </tr>
</table>
