<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00209" is-a="AttributeValueDeprecatedError" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
    	[ISM-ID-00209][Error] Attribute atomicEnergyMarkings must not contain 
    	values which have passed their deprecation date.
    </sch:p>
    <sch:p id="codeDesc">
    	For each element which specifies attribute ism:atomicEnergyMarkings, we 
    	make sure that the value of ism:atomicEnergyMarkings has not been deprecated.
    	This is indicated in the CVE file by an attribute (@deprecated) 
    	on the term element for that atomicEnergyMarkings value. 
    	If the date value in @deprecated is in the future, then a 
    	deprecation warning will be given. If the date value has 
    	already occurred, then a deprecation error will be given.
	</sch:p>
	
	<sch:param name="ruleId" value="'ISM-ID-00209'"/>
	<sch:param name="context" value="*[@ism:atomicEnergyMarkings]"/>
	<sch:param name="attrName" value="atomicEnergyMarkings"/>
	<sch:param name="cveName" value="CVEnumISMAtomicEnergyMarkings"/>
</sch:pattern>