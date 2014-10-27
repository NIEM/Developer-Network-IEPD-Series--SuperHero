<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00038" is-a="MutuallyExclusiveAttributeValues"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00038][Error] If ISM_CAPCO_RESOURCE, then Name tokens [XD] and [ND] are mutually 
        exclusive for attribute nonICmarkings.
        
        Human Readable: USA documents must not specify both XD and ND on a single element.
    </sch:p>
    <sch:p id="codeDesc">
    	This rule uses an abstract pattern to consolidate logic.
    	If the document is an ISM-CAPCO-RESOURCE, for each element which 
    	has attribute ism:nonICmarkings specified with a value containing
    	the token [XD] or [ND], we make sure that attribute ism:nonICmarkings
    	is not specified with a value containing both tokens [XD] and [ND].
    </sch:p>
	
	<sch:param name="context" value="*[$ISM_CAPCO_RESOURCE
										and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD', 'ND'))]"/>
	<sch:param name="attrValue" value="@ism:nonICmarkings"/>
	<sch:param name="mutuallyExclusiveTokenList" value="('XD', 'ND')"/>
	<sch:param name="errMsg" value="'
		[ISM-ID-00038][Error] If ISM_CAPCO_RESOURCE, then Name tokens 
		[XD] and [ND] are mutually exclusive for attribute nonICmarkings.
		
		Human Readable: USA documents must not specify both XD and ND on a 
		single element.
		'"/>
</sch:pattern>