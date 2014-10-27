<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00301" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:p id="ruleText">
    [ISM-ID-00301][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains any of the name tokens [EL],
    [EL-EU], or [EL-NK], then it must also contain the name token [SI].
    
    Human Readable: A USA document that contains ENDSEAL (EL), -ECRU (EK), or -NONBOOK (NK) compartment data must also specify that 
    it contains SI data. 
  </sch:p>
  <sch:p id="codeDesc">
    If the document is an ISM_CAPCO_RESOURCE, for each element which specifies
    attribute ism:SCIcontrols with a value containing any of the tokens [EL], 
    [EL-EU], or [EL-NK], we make sure that attribute ism:SCIcontrols is 
    specified with a value containing the token [SI].
    
    If CAPCO rules do not apply to the document then the rule does not apply
    and we return true. 
  </sch:p>
  <sch:rule context="*[$ISM_CAPCO_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL', 'EL-EU', 'EL-NK'))]">
    <sch:assert  
      test="util:containsAnyTokenMatching(@ism:SCIcontrols, ('SI'))"
      flag="error">
      [ISM-ID-00301][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains any of the name tokens [EL],
      [EL-EU], or [EL-NK], then it must also contain the name token [SI].
      
      Human Readable: A USA document that contains ENDSEAL (EL), -ECRU (EK), or -NONBOOK (NK) compartment data must also specify that 
      it contains SI data. 
    </sch:assert>
  </sch:rule>
</sch:pattern>