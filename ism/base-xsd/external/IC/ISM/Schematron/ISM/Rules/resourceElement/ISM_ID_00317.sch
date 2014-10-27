<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00317" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00317][Error] If ISM_CAPCO_RESOURCE and attribute declassExemption of ISM_RESOURCE_ELEMENT contains 
        [NATO-AEA] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        ownerProducer attribute containing [NATO] and one portion containing ism:atomicEnergyMarkings.
        
        Human Readable: USA documents marked with a NATO-AEA declass exemption must have at lease one NATO portion 
        and one portion that contains Atomic Energy Markings.
    </sch:p>
    <sch:p id="codeDesc">
      If the document is an ISM_CAPCO_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:declassExemption is specified
      with a value containing the value [NATO-AEA], then we make sure that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:ownerProducer
      with a value containing [NATO] and ism:atomicEnergyMarkings.
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and util:containsAnyOfTheTokens(@ism:declassException, ('NATO-AEA'))]">
        <sch:assert test="index-of($partOwnerProducer_tok,'NATO')>0 and count($partAtomicEnergyMarkings_tok)>0"
            flag="error">
            [ISM-ID-00317][Error] USA documents marked with a NATO-AEA declass exemption must have at lease one NATO portion 
            and one portion that contains Atomic Energy Markings.
        </sch:assert>
    </sch:rule>
</sch:pattern>