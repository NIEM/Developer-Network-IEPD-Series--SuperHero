<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00061" is-a="AttributeContributesToRollup" 
  xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:p id="ruleText">
    [ISM-ID-00061][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
    have the attribute SCIcontrols containing a value of [SI-G] then the ISM_RESOURCE_ELEMENT element's SCIcontrols must contain [SI-G].
    
    Human Readable: USA documents having SI-G data must have SI-G at the resource level.
  </sch:p>
  <sch:p id="codeDesc">
    This rule uses an abstract pattern to consolidate logic. If the document
    is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies $attrLocalName with a value containing the token $value, then 
    we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    $attrLocalName with a value containing the token $value.
  </sch:p>
  <sch:param name="attrLocalName" value="SCIcontrols"/>
  <sch:param name="value" value="SI-G"/>
  <sch:param name="errorMessage" value="'[ISM-ID-00061][Error] USA documents having SI-G data must have SI-G at the resource level.'"/>
</sch:pattern>