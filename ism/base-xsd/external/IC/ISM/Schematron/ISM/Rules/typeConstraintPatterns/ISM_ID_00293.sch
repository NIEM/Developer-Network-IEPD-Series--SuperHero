<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00293" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00293][Error] All releasableTo attributes must be of type NmTokens. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an releasableTo attribute, we 
		make sure that the releasableTo value matches the pattern
		defined for type NmTokens. 
	</sch:p>
	<sch:rule context="*[@ism:releasableTo]">
		<sch:assert  
			test="util:meetsType(@ism:releasableTo, $NmTokensPattern)"
			flag="error">
			[ISM-ID-00293][Error] All releasableTo attributes values must be of type NmTokens. 
		</sch:assert>
	</sch:rule>
</sch:pattern>
