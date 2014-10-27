<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00298" is-a="AttributeContributesToRollup" 
  xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:p id="ruleText">
    [ISM-ID-00298][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the 
    document specifies attribute atomicEnergyMarkings with a value containing [TFNI],
    then the ISM_RESOURCE_ELEMENT must specify attribute atomicEnergyMarkings with a value containing [TFNI].
    
    Human Readable: USA documents having Transclassified Foreign Nuclear Information (TFNI) must have TFNI at the resource level.
  </sch:p>
  <sch:p id="codeDesc">
    This rule uses an abstract pattern to consolidate logic. If the document
    is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies $attrLocalName with a value containing the token $value, then 
    we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    $attrLocalName with a value containing the token $value.
  </sch:p>
  <sch:param name="attrLocalName" value="atomicEnergyMarkings"/>
  <sch:param name="value" value="TFNI"/>
  <sch:param name="errorMessage" value="'[ISM-ID-00298][Error] USA documents having Transclassified Foreign Nuclear Information (TFNI) must have TFNI at the resource level.'"/>
</sch:pattern>