<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00295" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00295][Error] All SARIdentifier attributes must be of type NmTokens. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an SARIdentifier attribute, we 
		make sure that the SARIdentifier value matches the pattern
		defined for type NmTokens. 
	</sch:p>
	<sch:rule context="*[@ism:SARIdentifier]">
		<sch:assert  
			test="util:meetsType(@ism:SARIdentifier, $NmTokensPattern)"
			flag="error">
			[ISM-ID-00295][Error] All SARIdentifier attributes values must be of type NmTokens. 
		</sch:assert>
	</sch:rule>
</sch:pattern>
