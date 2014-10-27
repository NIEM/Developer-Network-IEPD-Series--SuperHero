<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00270" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00270][Error] All classificationReason attributes must be a string with less than 4096 characters. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an classificationReason attribute, we 
		make sure that the classificationReason value is a string with less
		than 4096 characters.   
	</sch:p>
	<sch:rule context="*[@ism:classificationReason]">
		<sch:assert  
			test="string-length(@ism:classificationReason) &lt;= 4096"
			flag="error">
			[ISM-ID-00270][Error] All classificationReason attributes must be a string with less than 4096 characters. 
		</sch:assert>
	</sch:rule>
</sch:pattern>
