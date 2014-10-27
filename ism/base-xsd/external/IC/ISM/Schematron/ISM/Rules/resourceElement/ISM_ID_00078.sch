<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00078" is-a="AttributeContributesToRollupWithClassification" 
  xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:p id="ruleText">
    [ISM-ID-00078][Error] If ISM_CAPCO_RESOURCE and the ISM_RESOURCE_ELEMENT node's 
    classification has the value of [U] and any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings 
    containing [DCNI] then the ISM_RESOURCE_ELEMENT must have atomicEnergyMarkings containing [DCNI].
    
    Human Readable: Unclassified USA documents having DCNI Data must have DCNI at the resource level.
  </sch:p>
  <sch:p id="codeDesc">
    This rule uses an abstract pattern to consolidate logic. If the document
    is an ISM_CAPCO_RESOURCE, the ISM_RESOURCE_ELEMENT spcifies attribute 
    ism:classification with a value of $resourceElementClassification, and an 
    element meeting ISM_CONTRIBUTES specifies $attrLocalName with a value
    containing the token $value, then we make sure that the ISM_RESOURCE_ELEMENT
    specifies the attribute $attrLocalName with a value containing the token $value.
  </sch:p>
  <sch:param name="attrLocalName" value="atomicEnergyMarkings"/>
  <sch:param name="value" value="DCNI"/>
  <sch:param name="resourceElementClassification" value="U"/>
  <sch:param name="errorMessage" value="'[ISM-ID-00078][Error] Unclassified USA documents having DCNI Data must have DCNI at the resource level.'"/>
</sch:pattern>