<cfcomponent>
	<cffunction name="runCard" access="public" returntype="struct">
		<cfargument name="login" required="yes" type="string" default="">
		<cfargument name="password" required="yes" type="string" default="">
		<cfargument name="transactionKey" required="yes" type="string" default="">
		<cfargument name="hashValue" required="yes" type="string" default="">
		<cfargument name="invoiceNum" required="yes" type="string" default="#CreateUUID()#">
		<cfargument name="invoiceAmt" required="yes" type="string" default="">
		<cfargument name="description" required="yes" type="string" default="">
		<cfargument name="chargeMethod" required="yes" type="string" default="CC">
		<cfargument name="chargeType" required="yes" type="string" default="AUTH_ONLY">
		<cfargument name="cardNumber" required="yes" type="string" default="">
		<cfargument name="cardExpiration" required="yes" type="string" default="">
		<cfargument name="cardCode" required="yes" type="string" default="">
		<cfargument name="custID" required="yes" type="string" default="">
		<cfargument name="fName" required="yes" type="string" default="">
		<cfargument name="lName" required="yes" type="string" default="">
		<cfargument name="streetAddress" required="yes" type="string" default="">
		<cfargument name="city" required="yes" type="string" default="">
		<cfargument name="state" required="yes" type="string" default="">
		<cfargument name="zip" required="yes" type="string" default="">
		<cfargument name="country" required="yes" type="string" default="">
		<cfargument name="chargeauthcode" required="no" type="string" default="false">
		<cfargument name="testRequest" required="yes" type="string" default="false">
			<cfscript>
				var returnThis = StructNew();
				var q_getAccessData = getAuthorizeAccessData();
				var thisLogin ='';
				var thisPassword ='';
				var thisTransactionkey ='';
				var thisHashvalue ='';
			</cfscript>
				<cfif IsDefined('arguments.login') AND Len(Trim(arguments.login))>
					<cfset thisLogin="#arguments.login#">
				<cfelseif isDefined('q_getAccessData.gatewaylogin') AND Len(trim(q_getAccessData.gatewaylogin))>
					<cfset thisLogin="#q_getAccessData.gatewaylogin#">
				<cfelse>
					<cfset thisLogin = "">
				</cfif>
				<cfif IsDefined('arguments.password') AND Len(Trim(arguments.password))>
					<cfset thisPassword="#arguments.password#">
				<cfelseif isDefined('q_getAccessData.gatewaypassword') AND Len(trim(q_getAccessData.gatewaypassword))>
					<cfset thisPassword="#q_getAccessData.gatewaypassword#">
				<cfelse>
					<cfset thisPassword = "">
				</cfif>
				<cfif IsDefined('arguments.transactionKey') AND Len(Trim(arguments.transactionKey))>
					<cfset thisTransactionkey="#arguments.transactionKey#">
				<cfelseif isDefined('q_getAccessData.gatewaykey') AND Len(trim(q_getAccessData.gatewaykey))>
					<cfset thisTransactionkey="#q_getAccessData.gatewaykey#">
				<cfelse>
					<cfset thisTransactionkey = "">
				</cfif>
				<cfif IsDefined('arguments.hashValue') AND Len(Trim(arguments.hashValue))>
					<cfset thisHashvalue="#arguments.hashValue#">
				<cfelseif isDefined('q_getAccessData.gatewaysecurity') AND Len(trim(q_getAccessData.gatewaysecurity))>
					<cfset thisHashvalue="#q_getAccessData.gatewaysecurity#">
				<cfelse>
					<cfset thisHashvalue = "">
				</cfif>
		<cfsavecontent variable="dumpLog">
			<cfoutput>
				<cfdump var="#arguments#">
			</cfoutput>
		</cfsavecontent>
		<!--- <cflog log="application" text="#dumpLog# <br /> login #thisLogin# <br /> password #thisPassword# <br /> trans #thisTransactionkey# <br /> hash #thisHashvalue#"> --->
			<cfmodule name="#application.customTagPath#.gateways.authorizenet.adminpro_AIM"
				login = "#thisLogin#"
				password = "#thisPassword#"
				transactionkey = "#thisTransactionkey#"
				hashvalue = "#thisHashvalue#"
				invoicenum="#arguments.invoiceNum#" 
				invoiceamt="#arguments.invoiceAmt#"
				description="#arguments.description#" 
				chargemethod="#arguments.chargeMethod#"
				chargetype="#arguments.chargeType#"
				cardnumber="#arguments.cardNumber#"				
				cardexpiration="#arguments.cardExpiration#"
				cardcode="#arguments.cardCode#" 
				custid="#arguments.custID#"
				fname="#arguments.fName#"
				lname="#arguments.lName#" 
				streetaddress="#arguments.streetAddress#"
				city="#arguments.city#"
				state="#arguments.state#" 
				zip="#arguments.zip#"
				country="#arguments.country#" 
				chargeauthcode="#arguments.chargeauthcode#"
				testrequest="#arguments.testRequest#">
				<cfscript>
					returnThis.FullResponse = FullResponse;  // This is the full string response from gateway (comma delimited list)
					returnThis.ResponseCode = ResponseCode;  // Response from gateway [1 = Approved, 2 = Declined, 3 = Error]
					returnThis.ResponseSubCode = ResponseSubCode;  // A code used by the system for internal transaction tracking (see AIM docs for more info)
					returnThis.ResponseReasonCode = ResponseReasonCode;  // A code representing more details about the result of the transaction.
					returnThis.ResponseReasonText = ResponseReasonText;  // Brief description of the result, which corresponds with the Response Reason Code.
					returnThis.ApprovalCode = ApprovalCode;  // The six-digit alphanumeric authorization or approval code.
					returnThis.AVSResultCode = AVSResultCode;  // Indicates the result of Address Verification System (AVS) see example switch statement below showing each code
					returnThis.CardCodeResponse = CardCodeResponse;  // Indicates the results of Card Code verification [M = Match, N = No Match, P = Not Processed, S = Should have been present, U = Issuer unable to process request]
					returnThis.TransactionID = TransactionID;  // This number identifies the transaction in the system and can be used to submit a modification of this transaction at a later time, such as voiding, crediting or capturing the transaction.
					returnThis.md5original = md5original;  // This is your original MD5 hash as generated from your login and has value set in merchant settings
					returnThis.MD5HashCode = MD5HashCode;  // This is the has code generated by the gateway which can be used to validate against your hash code above
				</cfscript>
			<cfreturn returnThis>
	</cffunction>
	<cffunction access="public" name="getAuthorizeAccessData" output="false" returntype="query" displayname="Get Authorize Access Data">	
		<cftry>
			<cfquery name="q_getAuthorizeAccessData" datasource="#APPLICATION.datasource#">
			SELECT gatewaylogin, gatewaypassword, gatewaykey, gatewaysecurity, gatewaycode
			FROM storepaymentgateway
			WHERE gatewaycode = 'authorizenet'
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getAuthorizeAccessData>
	</cffunction>
</cfcomponent>