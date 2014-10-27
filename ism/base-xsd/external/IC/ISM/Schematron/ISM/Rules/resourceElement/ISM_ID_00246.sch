<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00246" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00246][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [RD], [FRD], or [TFNI] then the ISM_RESOURCE_ELEMENT must have a declassException of [AEA] or [NATO-AEA].
        
        Human Readable: USA documents containing [RD], [FRD], or [TFNI] data must have declassException containing [AEA] or [NATO-AEA] at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
      If the document is an ISM_CAPCO_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing a token matching [RD], [FRD], or [TFNI], then we make sure that the 
      ISM_RESOURCE_ELEMENT has a declassException of [AEA] or [NATO-AEA].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD','FRD', 'TFNI'))]">
      
      <sch:assert test="util:containsAnyOfTheTokens(@ism:declassException, ('AEA', 'NATO-AEA'))" 
        flag="error">
          [ISM-ID-00246][Error] USA documents containing [RD], [FRD], or [TFNI] data must have declassException containing [AEA] or [NATO-AEA] at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>