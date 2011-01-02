<CFLOOP FROM="1" TO="#arrayLen(APPLICATION.ipBlackList)#" INDEX="currPosition">
	<CFIF dateDiff("n", APPLICATION.ipBlackList[currPosition].arrayTime, NOW()) GT "60">
		<CFSET VARIABLES.temp = arrayDeleteAt(APPLICATION.ipBlackList, currPosition)>
	</CFIF>
</CFLOOP>

