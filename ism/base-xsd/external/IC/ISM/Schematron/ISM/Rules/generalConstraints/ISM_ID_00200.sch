<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00200" is-a="AttributeValueDeprecatedWarning"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
    	[ISM-ID-00200][Warning] Attribute displayOnlyTo should not contain any
    	values which will be deprecated.
    </sch:p>
    <sch:p id="codeDesc">
    	For each element which specifies attribute ism:displayOnlyTo, we 
    	make sure that the value of ism:displayOnlyTo has not been deprecated. 
    	This is indicated in the CVE file by an attribute (@deprecated) 
    	on the term element for that displayOnlyTo value. 
    	If the date value in @deprecated is in the future, then a 
    	deprecation warning will be given. If the date value has 
    	already occurred, then a deprecation error will be given. 
	</sch:p>
	
	<sch:param name="ruleId" value="'ISM-ID-00200'"/>
	<sch:param name="context" value="*[@ism:displayOnlyTo]"/>
	<sch:param name="attrName" value="displayOnlyTo"/>
	<sch:param name="cveName" value="CVEnumISMRelTo"/>
</sch:pattern>