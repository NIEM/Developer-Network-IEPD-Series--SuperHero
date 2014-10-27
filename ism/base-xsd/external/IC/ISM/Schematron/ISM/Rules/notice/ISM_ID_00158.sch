<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00158" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00158][Error] If ISM_CAPCO_RESOURCE and:
        1. ISM_DoD5230_24_Applies
        AND
        2. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        AND
        3. A resource attribute notice does not contain one of [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], or [DoD-Dist-F].
       
        
        Human Readable: All classified documents that claim compliance with DoD5230.24 must use one of DoD 
        distribution statements B, C, D, E, or F.
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM-CAPCO-RESOURCE and ISM_DOD5230_24_APPLIES and
        the attribute classification of ISM_RESOURCE_ELEMENT is not [U], then
        we make sure that the resource element specifies attribute
        ism:noticeType with a value containing the token [DoD-Dist-B],
        [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], or [DoD-Dist-F].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and $ISM_DOD5230_24_APPLIES
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and not(@ism:classification='U')]">
        <sch:assert 
            test="
            util:containsAnyOfTheTokens(@ism:noticeType, 
            	('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F'))"
            flag="error"> 
        	[ISM-ID-00158][Error] If ISM_CAPCO_RESOURCE and:
        	1. ISM_DoD5230_24_Applies
        	AND
        	2. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        	AND
        	3. The resource attribute notice does not contain one of [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], or [DoD-Dist-F].
        	
        	Human Readable: All classified documents that claim compliance with DoD5230.24 must use one of DoD 
        	distribution statements B, C, D, E, or F.
        </sch:assert>
    </sch:rule>
</sch:pattern>
