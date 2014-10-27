<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00271" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00271][Error] All classifiedBy attributes must be a string with less than 1024 characters. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an classifiedBy attribute, we 
		make sure that the classifiedBy value is a string with less
		than 1024 characters.   
	</sch:p>
	<sch:rule context="*[@ism:classifiedBy]">
		<sch:assert  
			test="string-length(@ism:classifiedBy) &lt;= 1024"
			flag="error">
			[ISM-ID-00271][Error] All classifiedBy attributes must be a string with less than 1024 characters. 
		</sch:assert>
	</sch:rule>
</sch:pattern>

