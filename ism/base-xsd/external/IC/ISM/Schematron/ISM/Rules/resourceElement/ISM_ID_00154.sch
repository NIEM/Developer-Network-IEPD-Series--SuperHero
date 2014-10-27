<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00154" is-a="NonCompilationDocumentRollup" 
  xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:p id="ruleText">
    [ISM-ID-00154][Error] If ISM_CAPCO_RESOURCE and 
    1. Attribute disseminationControls of ISM_RESOURCE_ELEMENT contains [FOUO]
    AND
    2. Attribute compilationReason does not have a value then at least one element meeting ISM_CONTRIBUTES
    in the document must have a disseminationControls attribute contain [FOUO].
    
    Human Readable: USA FOUO documents not using compilation must have FOUO data.
  </sch:p>
  <sch:p id="codeDesc">
    This rule uses an abstract pattern to consolidate logic. If the document
    is an ISM_CAPCO_RESOURCE and attribute $attrLocalName of ISM_RESOURCE_ELEMENT 
    has a value of [$value] and attribute ism:compilationReason does not have a 
    value, then we make sure that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute $attrLocalName with a value of [$value].
  </sch:p>
  <sch:param name="attrLocalName" value="disseminationControls"/>
  <sch:param name="value" value="FOUO"/>
  <sch:param name="errorMessage" value="'[ISM-ID-00154][Error] USA FOUO documents not using compilation must have FOUO data.'"/>
</sch:pattern>
