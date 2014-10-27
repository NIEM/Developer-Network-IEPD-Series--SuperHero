<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00231" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00231][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [RD-SG-##] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        atomicEnergyMarking attribute containing the same [RD-SG-##].
        
        Human Readable: USA documents marked RD-SG-## at the resource level must have RD-SG-## data, where ## is the same.
    </sch:p>
    <sch:p id="codeDesc">
      If the document is an ISM_CAPCO_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing a token matching [RD-SG-##], then we make sure that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings
      with a value containing a token matching the same [RD-SG-##].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
      <sch:let name="matchingTokens" value="
        for $token in tokenize(normalize-space(string(@ism:atomicEnergyMarkings)), ' ') return
          if(matches($token,'^RD-SG-[1-9][0-9]?$'))
          then $token
          else null
        "/>  
      <sch:assert test="every $token in $matchingTokens satisfies
                          index-of($partAtomicEnergyMarkings_tok, $token) > 0"
        flag="error">
          [ISM-ID-00231][Error] USA documents marked RD-SG-## at the resource level must have RD-SG-## data, where ## is the same.
        </sch:assert>
    </sch:rule>
</sch:pattern>