<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00282" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00282][Error] All resourceElement attributes must be of type Boolean. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an resourceElement attribute, we 
		make sure that the resourceElement value matches the pattern
		defined for type Boolean. 
		
		Note: this rule is not able to be failed. If the resourceElement does
		not confirm to type Boolean, schematron fails when defining global
		variables before any rules are fired. 
	</sch:p>
	<sch:rule context="*[@ism:resourceElement]">
		<sch:assert  
			test="util:meetsType(@ism:resourceElement, $BooleanPattern)"
			flag="error">
			[ISM-ID-00282][Error] All resourceElement attributes values must be of type Boolean. 
		</sch:assert>
	</sch:rule>
</sch:pattern>
