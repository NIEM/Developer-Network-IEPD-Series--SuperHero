<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00268" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00268][Error] All atomicEnergyMarkings attributes must be of type NmTokens. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an atomicEnergyMarkings attribute, we 
		make sure that the atomicEnergyMarkings value matches the pattern
		defined for type NmTokens. 
	</sch:p>
	<sch:rule context="*[@ism:atomicEnergyMarkings]">
		<sch:assert  
			test="util:meetsType(@ism:atomicEnergyMarkings, $NmTokensPattern)"
			flag="error">
			[ISM-ID-00268][Error] All atomicEnergyMarkings attributes values must be of type NmTokens. 
		</sch:assert>
	</sch:rule>
</sch:pattern>
