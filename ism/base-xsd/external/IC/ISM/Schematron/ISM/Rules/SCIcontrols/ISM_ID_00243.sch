<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00243" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:p id="ruleText">
    [ISM-ID-00243][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [RSV],
    then it must also contain a compartment [RSV-XXX].
    
    Human Readable: RESERVE is not permitted as a stand-alone value and a compartment must be expressed.
  </sch:p>
  <sch:p id="codeDesc">
    If the document is an ISM_CAPCO_RESOURCE, for each element which specifies
    attribute ism:SCIcontrols with a value containing the token [RSV], we make
    sure that attribute ism:SCIcontrols is specified with a value containing
    a token maching the regular expression "RSV-[A-Z0-9]{3}".
    
    If CAPCO rules do not apply to the document then the rule does not apply
    and we return true. If the current element has attribute SCIcontrols specified
    with a value containing [RSV], then we make sure that attribute SCIcontrols also contains the value [RSV-XXX].
  </sch:p>
  <sch:rule context="*[$ISM_CAPCO_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))]">
    <sch:assert  
      test="util:containsAnyTokenMatching(@ism:SCIcontrols, ('RSV-[A-Z0-9]{3}'))"
      flag="error">
      [ISM-ID-00243][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [RSV],
      then it must also contain a compartment [RSV-XXX].
      
      Human Readable: RESERVE is not permitted as a stand-alone value and a compartment must be expressed.
    </sch:assert>
  </sch:rule>
</sch:pattern>