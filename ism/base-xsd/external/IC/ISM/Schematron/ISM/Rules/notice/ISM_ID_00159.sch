<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00159" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00159][Error] If ISM_CAPCO_RESOURCE and:
        1. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        AND
        2. The attribute notice does contain [DoD-Dist-A] 
        or has attribute externalNotice with a value of [true].
        
        Human Readable: Distribution statement A (Public Release) is forbidden on classified documents.
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM-CAPCO-RESOURCE and the attribute
        classification of ISM_RESOURCE_ELEMENT is not [U], for each element
        which specifies attribute ism:noticeType we make sure that attribute
        ism:noticeType is not specified with a value containing the token
        [DoD-Dist-A] unless it is an external notice with attribute ism:externalNotice is [true].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE 
                        and not($ISM_RESOURCE_ELEMENT/@ism:classification = 'U')]">
        <sch:assert 
            test="not(util:containsAnyOfTheTokens(@ism:noticeType, ('DoD-Dist-A')))
                or (@ism:externalNotice=true())"
            flag="error"> 
            [ISM-ID-00159][Error] If ISM_CAPCO_RESOURCE and:
        1. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        AND
        2. The attribute notice does contains [DoD-Dist-A]
        or has attribute externalNotice with a value of [true].
        Human Readable: Distribution statement A (Public Release) is forbidden on classified documents.
        </sch:assert>
    </sch:rule>
</sch:pattern>
