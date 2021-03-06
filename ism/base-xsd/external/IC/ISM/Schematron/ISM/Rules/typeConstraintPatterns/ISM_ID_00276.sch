<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00276" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:p id="ruleText">
		[ISM-ID-00276][Error] All declassEvent attributes must be a string with less than 1024 characters. 
	</sch:p>
	<sch:p id="codeDesc">
		For all elements which contain an declassEvent attribute, we 
		make sure that the declassEvent value is a string with less
		than 1024 characters.   
	</sch:p>
	<sch:rule context="*[@ism:declassEvent]">
		<sch:assert  
			test="string-length(@ism:declassEvent) &lt;= 1024"
			flag="error">
			[ISM-ID-00276][Error] All declassEvent attributes must be a string with less than 1024 characters. 
		</sch:assert>
	</sch:rule>
</sch:pattern>

