<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00228" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00228][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [FRD] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        atomicEnergyMarking attribute containing [FRD].
        
        Human Readable: USA documents marked FRD at the resource level must have FRD data.
    </sch:p>
    <sch:p id="codeDesc">
      If the document is an ISM_CAPCO_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing the value [FRD], then we make sure that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings
      with a value containing [FRD].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))]">
        <sch:assert test="index-of($partAtomicEnergyMarkings_tok,'FRD')>0"
            flag="error">
            [ISM-ID-00228][Error] USA documents marked FRD at the resource level must have FRD data.
        </sch:assert>
    </sch:rule>
</sch:pattern>