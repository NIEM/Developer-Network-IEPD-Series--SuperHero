<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00155" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00155][Error] If ISM_CAPCO_RESOURCE and 
        1. ISM_DoD5230_24_Applies
        AND
        2. Attribute noticeType of ISM_RESOURCE_ELEMENT does not contain one of 
        [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
        
        Human Readable: All USA documents that claim compliance with DoD5230.24 must have a distribution statement
        for the entire document.
    </sch:p>
    <sch:p id="codeDesc">
      If the document is an ISM_CAPCO_RESOURCE, ISM_DOD5230_24_APPLIES, and
      the current element is the ISM_RESOURCE_ELEMENT, we make sure that 
      attribute ism:noticeType is specified with a value containing one of the
      tokens: [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D],
      [DoD-Dist-E], [DoD-Dist-F], [DoD-Dist-X].
    </sch:p>
  <sch:rule context="*[$ISM_CAPCO_RESOURCE
                      and $ISM_DOD5230_24_APPLIES
                      and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert  
            test="util:containsAnyOfTheTokens(@ism:noticeType, 
                    ('DoD-Dist-A', 'DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))"
            flag="error">
            [ISM-ID-00155][Error] All USA documents that claim compliance with DoD5230.24 must have a distribution statement
            for the entire document.
        </sch:assert>
    </sch:rule>
</sch:pattern>