<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00282" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00282][Error] All excludeFromRollup attributes must be of type Boolean. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an excludeFromRollup attribute, we 
		make sure that the excludeFromRollup value matches the pattern
		defined for type Boolean. 
	</sch:p>
	<sch:rule context="*[@ism:excludeFromRollup]">
		<sch:assert  
			test="util:meetsType(@ism:excludeFromRollup, $BooleanPattern)"
			flag="error">
			[ISM-ID-00282][Error] All excludeFromRollup attributes values must be of type Boolean. 
		</sch:assert>
	</sch:rule>
</sch:pattern>
