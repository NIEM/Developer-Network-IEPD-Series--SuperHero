<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00279" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00279][Error] All derivedFrom attributes must be a string with less than 1024 characters. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an derivedFrom attribute, we 
		make sure that the derivedFrom value is a string with less
		than 1024 characters.   
	</sch:p>
	<sch:rule context="*[@ism:derivedFrom]">
		<sch:assert  
			test="string-length(@ism:derivedFrom) &lt;= 1024"
			flag="error">
			[ISM-ID-00279][Error] All derivedFrom attributes must be a string with less than 1024 characters. 
		</sch:assert>
	</sch:rule>
</sch:pattern>

