<cftry>

<cfparam name="ATTRIBUTES.Version" default="3.1">
<cfparam name="ATTRIBUTES.Login" default="">
<cfparam name="ATTRIBUTES.Password" default="">
<cfparam name="ATTRIBUTES.TransactionKey" default="">
<cfparam name="ATTRIBUTES.hashValue" default="">
<cfparam name="ATTRIBUTES.DelimReturnData" default="True">
<cfparam name="ATTRIBUTES.DelimChar" default=",">
<cfparam name="ATTRIBUTES.EmailReceiptToCustomer" default="True"> <!--- [True | False] --->
<cfparam name="ATTRIBUTES.AdditionalMerchantEmail" default=""> <!--- Additional email address to send merchant email confirmation to --->
<cfparam name="ATTRIBUTES.ReccurringBilling" default="NO"> <!--- [YES | NO] --->
<cfparam name="ATTRIBUTES.InvoiceNum" default="">
<cfparam name="ATTRIBUTES.InvoiceAmt" default="">
<cfparam name="ATTRIBUTES.CurrencyCode" default="USD">
<cfparam name="ATTRIBUTES.Description" default="">
<cfparam name="ATTRIBUTES.CustID" default="001">
<cfparam name="ATTRIBUTES.CustIP" default="#CGI.REMOTE_ADDR#">
<cfparam name="ATTRIBUTES.FName" default="">
<cfparam name="ATTRIBUTES.LName" default="">
<cfparam name="ATTRIBUTES.Email" default="">
<cfparam name="ATTRIBUTES.Company" default="">
<cfparam name="ATTRIBUTES.StreetAddress" default=""> <!--- 1 line only accepted --->
<cfparam name="ATTRIBUTES.City" default="">
<cfparam name="ATTRIBUTES.State" default="">
<cfparam name="ATTRIBUTES.Zip" default="">
<cfparam name="ATTRIBUTES.Country" default=""> <!--- 2 letter abbreviation --->
<cfparam name="ATTRIBUTES.ShipToFName" default="">
<cfparam name="ATTRIBUTES.ShipToLName" default="">
<cfparam name="ATTRIBUTES.ShipToCompany" default="">
<cfparam name="ATTRIBUTES.ShipToStreetAddress" default=""> <!--- 1 line only accepted --->
<cfparam name="ATTRIBUTES.ShipToCity" default="">
<cfparam name="ATTRIBUTES.ShipToState" default="">
<cfparam name="ATTRIBUTES.ShipToZip" default="">
<cfparam name="ATTRIBUTES.ShipToCountry" default=""> <!--- 2 letter abbreviation --->
<cfparam name="ATTRIBUTES.Phone" default=""> <!--- Recommended format is (123)123-1234 --->
<cfparam name="ATTRIBUTES.Fax" default=""> <!--- Recommended format is (123)123-1234 --->
<cfparam name="ATTRIBUTES.CardNumber" default="">
	<!--- 	Valid Test Card numbers
	370000000000002 - American Express
	6011000000000012 - Discover
	5424000000000015 - MasterCard
	4007000000027 - Visa --->
<cfparam name="ATTRIBUTES.CardExpiration" default="">
	<!--- MMYY, MM/YY, MM-YY, MMYYYY, MM/YYYY, MM-YYYY, YYYY-MM-DD, YYYY/MM/DD --->
<cfparam name="ATTRIBUTES.CardCode" default=""> <!--- 3 or 4 digit number only - valid cvv --->
<cfparam name="ATTRIBUTES.ChargeMethod" default="CC">
<!--- [CC | ECHECK] --->
<cfparam name="ATTRIBUTES.ChargeType" default="AUTH_CAPTURE">
<!--- [AUTH_CAPTURE | AUTH_ONLY | CAPTURE_ONLY | CREDIT | VOID | PRIOR_AUTH_CAPTURE] --->
<cfparam name="ATTRIBUTES.ChargeID" default="">
	<!--- ID of a transaction previously authorized by the gateway if ChargeType
	is CREDIT, VOID, or PRIOR_AUTH_CAPTURE --->
<cfparam name="ATTRIBUTES.ChargeAuthCode" default="">
<!--- Authorization code for a previous transaction not authorized on the gateway 
that is being submitted for capture. if ChargeType is CAPTURE_ONLY --->
	
<cfparam name="ATTRIBUTES.ABACode" default="">
<cfparam name="ATTRIBUTES.BankACNum" default="">
<cfparam name="ATTRIBUTES.BankACType" default=""> <!--- [CHECKING | SAVINGS] defaults to CHECKING --->
<cfparam name="ATTRIBUTES.BankName" default="">
<cfparam name="ATTRIBUTES.BankACHolderName" default="">
<!--- _Bank_ABA_Code *required for x_Method = ECHECK*
Valid routing number 9 max chars
x_Bank_Acct_Num *required for x_Method = ECHECK*
20 max chars
x_Bank_Acct_Type *required for x_Method = ECHECK*
8 max chars
x_Bank_Name *required for x_Method = ECHECK*
50 max chars - Contains the name of the customer’s financial institution.
 x_Bank_Acct_Name *required for x_Method = ECHECK* --->
 

<cfparam name="ATTRIBUTES.TestRequest" default="False"> <!--- [True | False] --->
<cfif ATTRIBUTES.TestRequest eq "True">
	<!--- <cfparam name="ATTRIBUTES.AuthServer" default="https://test.authorize.net/gateway/transact.dll"> --->
	<cfparam name="ATTRIBUTES.AuthServer" default="https://certification.authorize.net/gateway/transact.dll">
<cfelse>
	<cfparam name="ATTRIBUTES.AuthServer" default="https://secure.quickcommerce.net/gateway/transact.dll">
</cfif>

<cfparam name="CALLER.Error" default="0">
<!--- certification https://certification.authorize.net/gateway/transact.dll --->
<!--- live https://secure.quickcommerce.net/gateway/transact.dll --->
<cfhttp method="post" port="443" url="#ATTRIBUTES.AuthServer#">
   <cfhttpparam name="x_Version" type="formfield" value="#ATTRIBUTES.Version#">
   <cfhttpparam name="x_Login" type="formfield" value="#ATTRIBUTES.Login#">
   <cfhttpparam name="x_relay_response" type="formfield" value="False">
   <cfhttpparam name="x_tran_key" type="formfield" value="#ATTRIBUTES.TransactionKey#">
   <cfhttpparam name="x_Password" type="formfield" value="#ATTRIBUTES.Password#">
   <cfhttpparam name="x_Email_Customer" type="formfield" value="#ATTRIBUTES.EmailReceiptToCustomer#">
   <cfhttpparam name="x_email" type="formfield" value="#ATTRIBUTES.Email#">
   <cfhttpparam name="x_Test_Request" type="formfield" value="#ATTRIBUTES.TestRequest#">
   <cfhttpparam name="x_Delim_Data" type="formfield" value="#ATTRIBUTES.DelimReturnData#">
   <cfhttpparam name="x_Delim_Char" type="formfield" value="#ATTRIBUTES.DelimChar#">
   <cfhttpparam name="x_Method" type="formfield" value="#ATTRIBUTES.ChargeMethod#">
   <cfhttpparam name="x_Type" type="formfield" value="#ATTRIBUTES.ChargeType#">
   <cfhttpparam name="x_Recurring_Billing" type="formfield" value="#ATTRIBUTES.ReccurringBilling#">
   <cfhttpparam name="x_Amount" type="formfield" value="#ATTRIBUTES.invoiceAmt#">
   <cfhttpparam name="x_Currency_Code" type="formfield" value="#ATTRIBUTES.currencyCode#">
   <cfhttpparam name="x_Invoice_Num" type="formfield" value="#ATTRIBUTES.invoiceNum#">
   <cfhttpparam name="x_Description" type="formfield" value="#ATTRIBUTES.description#">
   <cfhttpparam name="x_Cust_ID" type="formfield" value="#ATTRIBUTES.CustID#">
   <cfhttpparam name="x_First_Name" type="formfield" value="#ATTRIBUTES.FName#">
   <cfhttpparam name="x_Last_Name" type="formfield" value="#ATTRIBUTES.LName#">
   <cfhttpparam name="x_Company" type="formfield" value="#ATTRIBUTES.Company#">
   <cfhttpparam name="x_Address" type="formfield" value="#ATTRIBUTES.StreetAddress#">
   <cfhttpparam name="x_City" type="formfield" value="#ATTRIBUTES.City#">
   <cfhttpparam name="x_State" type="formfield" value="#ATTRIBUTES.State#">
   <cfhttpparam name="x_Zip" type="formfield" value="#ATTRIBUTES.Zip#">
   <cfhttpparam name="x_Country" type="formfield" value="#ATTRIBUTES.Country#">
   <cfhttpparam name="x_Ship_To_First_Name" type="formfield" value="#ATTRIBUTES.ShipToFName#">
   <cfhttpparam name="x_Ship_To_Last_Name" type="formfield" value="#ATTRIBUTES.ShipToLName#">
   <cfhttpparam name="x_Ship_To_Company" type="formfield" value="#ATTRIBUTES.ShipToCompany#">
   <cfhttpparam name="x_Ship_To_Address" type="formfield" value="#ATTRIBUTES.ShipToStreetAddress#">
   <cfhttpparam name="x_Ship_To_City" type="formfield" value="#ATTRIBUTES.ShipToCity#">
   <cfhttpparam name="x_Ship_To_State" type="formfield" value="#ATTRIBUTES.ShipToState#">
   <cfhttpparam name="x_Ship_To_Zip" type="formfield" value="#ATTRIBUTES.ShipToZip#">
   <cfhttpparam name="x_Ship_To_Country" type="formfield" value="#ATTRIBUTES.ShipToCountry#">
   <cfhttpparam name="x_Phone" type="formfield" value="#ATTRIBUTES.Phone#">
   <cfhttpparam name="x_Fax" type="formfield" value="#ATTRIBUTES.Fax#">
  <cfif ATTRIBUTES.ChargeMethod eq "CC">
   <cfhttpparam name="x_Card_Num" type="formfield" value="#ATTRIBUTES.CardNumber#">
   <cfhttpparam name="x_Exp_Date" type="formfield" value="#ATTRIBUTES.CardExpiration#">
   <cfif ATTRIBUTES.ChargeType eq "CREDIT" OR ATTRIBUTES.ChargeType eq "VOID" OR ATTRIBUTES.ChargeType eq "PRIOR_AUTH_CAPTURE" OR ATTRIBUTES.ChargeType eq "CAPTURE_ONLY">
   	<cfhttpparam name="x_trans_id" type="formfield" value="#ATTRIBUTES.ChargeID#"> 	
   </cfif>
   <cfif ATTRIBUTES.ChargeType eq "CAPTURE_ONLY">
   	<cfhttpparam name="x_auth_code" type="formfield" value="#ATTRIBUTES.ChargeAuthCode#">
   </cfif>
   <cfif (Len(ATTRIBUTES.CardCode) eq 3) OR (Len(ATTRIBUTES.CardCode) eq 4)>	
	<cfhttpparam name="x_Card_Code" type="formfield" value="#ATTRIBUTES.CardCode#">
   </cfif>  
  <cfelseif ATTRIBUTES.ChargeMethod eq "ECHECK">
  	<cfhttpparam name="x_Bank_ABA_Code" type="formfield" value="#ATTRIBUTES.ABACode#">
	<cfhttpparam name="x_Bank_Acct_Num" type="formfield" value="#ATTRIBUTES.BankACNum#">
	<cfhttpparam name="x_Bank_Acct_Type" type="formfield" value="#ATTRIBUTES.BankACType#">
	<cfhttpparam name="x_Bank_Name" type="formfield" value="#ATTRIBUTES.BankName#">
	<cfhttpparam name="x_Bank_Acct_Name" type="formfield" value="#ATTRIBUTES.BankACHolderName#">
  <cfelse>
  </cfif>
   <cfhttpparam name="x_Customer_IP" type="formfield" value="#ATTRIBUTES.CustIP#">
  </cfhttp>

<cfoutput>
	<cfset CALLER.FullResponse = #cfhttp.fileContent#>
	<cfset strDelimCharDash = ATTRIBUTES.DelimChar & "-">
	<cfset CALLER.FullResponse = Replace(CALLER.FullResponse, ATTRIBUTES.DelimChar, strDelimCharDash,"ALL")>
	<!--- Response Code --->
	<cfif ListLen(CALLER.FullResponse, ATTRIBUTES.DelimChar) gte 1>
		<cfset CALLER.ResponseCode = "#ListGetAt(CALLER.FullResponse, 1, ATTRIBUTES.DelimChar)#">  <!--- 1 = Approved | 2 = Declined | 3 = Error --->
		<cfif Left(CALLER.ResponseCode, 1) eq "-">
			<cfset CALLER.ResponseCode = Replace(CALLER.ResponseCode, "-", "")>
		</cfif>
	</cfif>
	<!--- Response Sub Code --->
	<cfif ListLen(CALLER.FullResponse, ATTRIBUTES.DelimChar) gte 2>
		<cfset CALLER.ResponseSubCode = "#ListGetAt(CALLER.FullResponse, 2, ATTRIBUTES.DelimChar)#">
		<cfif Left(CALLER.ResponseSubCode, 1) eq "-">
			<cfset CALLER.ResponseSubCode = Replace(CALLER.ResponseSubCode, "-", "")>
		</cfif>
	</cfif>
	<!--- Response Reason Code --->
	<cfif ListLen(CALLER.FullResponse, ATTRIBUTES.DelimChar) gte 3>
		<cfset CALLER.ResponseReasonCode = "#ListGetAt(CALLER.FullResponse, 3, ATTRIBUTES.DelimChar)#">
		<cfif Left(CALLER.ResponseReasonCode, 1) eq "-">
			<cfset CALLER.ResponseReasonCode = Replace(CALLER.ResponseReasonCode, "-", "")>
		</cfif>
	</cfif>
	<!--- Response Reason Text --->
	<cfif ListLen(CALLER.FullResponse, ATTRIBUTES.DelimChar) gte 4>
		<cfset CALLER.ResponseReasonText = "#ListGetAt(CALLER.FullResponse, 4, ATTRIBUTES.DelimChar)#">
		<cfif Left(CALLER.ResponseReasonText, 1) eq "-">
			<cfset CALLER.ResponseReasonText = Replace(CALLER.ResponseReasonText, "-", "")>
		</cfif>
	</cfif>
	<!--- Apporoval Code --->
	<cfif ListLen(CALLER.FullResponse, ATTRIBUTES.DelimChar) gte 5>
		<cfset CALLER.ApprovalCode = "#ListGetAt(CALLER.FullResponse, 5, ATTRIBUTES.DelimChar)#">
		<cfif Left(CALLER.ApprovalCode, 1) eq "-">
			<cfset CALLER.ApprovalCode = Replace(CALLER.ApprovalCode, "-", "")>
		</cfif>
	</cfif>
	<!--- AVS Result Code --->
	<cfif ListLen(CALLER.FullResponse, ATTRIBUTES.DelimChar) gte 6>
		<cfset CALLER.AVSResultCode = "#ListGetAt(CALLER.FullResponse, 6, ATTRIBUTES.DelimChar)#"> 
		<cfif Left(CALLER.AVSResultCode, 1) eq "-">
			<cfset CALLER.AVSResultCode = Replace(CALLER.AVSResultCode, "-", "")>
		</cfif>
	</cfif>
	<!--- Transaction ID --->
	<cfif ListLen(CALLER.FullResponse, ATTRIBUTES.DelimChar) gte 7>
		<cfset CALLER.TransactionID = "#ListGetAt(CALLER.FullResponse, 7, ATTRIBUTES.DelimChar)#">
		<cfif Left(CALLER.TransactionID, 1) eq "-">
			<cfset CALLER.TransactionID = Replace(CALLER.TransactionID, "-", "")>
		</cfif>
	</cfif>
	<!--- Hash Code --->
	<cfif ListLen(CALLER.FullResponse, ATTRIBUTES.DelimChar) gte 38>
		<cfset CALLER.MD5HashCode = "#ListGetAt(CALLER.FullResponse, 38, ATTRIBUTES.DelimChar)#">
		<cfif Left(CALLER.MD5HashCode, 1) eq "-">
			<cfset CALLER.MD5HashCode = Replace(CALLER.MD5HashCode, "-", "")>
		</cfif>
	</cfif>
	<!--- Card Code Response --->
	<cfif ListLen(CALLER.FullResponse, ATTRIBUTES.DelimChar) gte 39>
		<cfset CALLER.CardCodeResponse = "#ListGetAt(CALLER.FullResponse, 39, ATTRIBUTES.DelimChar)#">
		<cfif Left(CALLER.CardCodeResponse, 1) eq "-">
			<cfset CALLER.CardCodeResponse = Replace(CALLER.CardCodeResponse, "-", "")>
		</cfif>
	</cfif>
	<!--- Actual md5 hash used to authenticate md5 hash returned by server --->
	<cfset CALLER.md5original = #hash(ATTRIBUTES.hashValue&ATTRIBUTES.Login&CALLER.TransactionID&DecimalFormat(ATTRIBUTES.invoiceAmt))#>
</cfoutput>

<cfcatch type="any">
	There has been an error...
</cfcatch>

</cftry>