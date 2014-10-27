<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00187" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00187][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G],
        then it must also contain the name token [SI].
        
        Human Readable: A USA document that contains Special Intelligence (SI) -GAMMA compartment data must also specify that 
        it contains SI data. 
    </sch:p>
    <sch:p id="codeDesc">
      If the document is an ISM-CAPCO-RESOURCE, for each element which
      specifies attribute ism:SCIcontrols with a value containing the token
      [SI-G] we make sure that attribute ism:SCIcontrols is 
      specified with a value containing the token [SI].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))]">
        <sch:assert test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))"
          flag="error">
          [ISM-ID-00187][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G],
          then it must also contain the name token [SI].
          
          Human Readable: A USA document that contains Special Intelligence (SI) -GAMMA compartment data must also specify that 
          it contains SI data. 
        </sch:assert>
    </sch:rule>
</sch:pattern>