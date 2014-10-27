<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00229" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00229][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [RD] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        atomicEnergyMarking attribute containing [RD].
        
        Human Readable: USA documents marked RD at the resource level must have RD data.
    </sch:p>
    <sch:p id="codeDesc">
      If the document is an ISM_CAPCO_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing the value [RD], then we make sure that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings
      with a value containing [RD].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))]">
        <sch:assert test="index-of($partAtomicEnergyMarkings_tok,'RD')>0" 
            flag="error">
            [ISM-ID-00229][Error] USA documents marked RD at the resource level must have RD data.
        </sch:assert>
    </sch:rule>
</sch:pattern>