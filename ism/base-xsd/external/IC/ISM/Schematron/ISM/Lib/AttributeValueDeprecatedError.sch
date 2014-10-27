<?xml version="1.0" encoding="UTF-8"?>

<sch:pattern abstract="true" id="AttributeValueDeprecatedError" xmlns:sch="http://purl.oclc.org/dsdl/schematron">	
	<sch:rule context="$context">
		<sch:assert test="count(
			dvf:deprecated(
			string(@ism:$attrName),
			document('../../CVE/ISM/$cveName.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],
			$ISM_RESOURCE_CREATE_DATE,
			true())
			)=0"
			flag="error">
			[<sch:value-of select="$ruleId"/>][Error] For attribute 
			<sch:value-of select="$attrName"/>, value(s)
			<sch:value-of select="
				dvf:deprecated(
				string(@ism:$attrName),
				document('../../CVE/ISM/$cveName.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],
				$ISM_RESOURCE_CREATE_DATE,
				true())"/>
		</sch:assert>
	</sch:rule>
</sch:pattern>