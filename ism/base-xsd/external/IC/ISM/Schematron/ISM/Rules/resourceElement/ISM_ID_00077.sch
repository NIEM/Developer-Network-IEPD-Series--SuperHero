<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00077" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00077][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the 
        document has the attribute atomicEnergyMarkings containing [FRD-SG-##] then the ISM_RESOURCE_ELEMENT must have 
        atomicEnergyMarkings containing [FRD-SG-##]. ## represent digits 1 through 99 the ## must match.
        
        Human Readable: USA documents having Formerly Restricted SIGMA-## Data must have the same Formerly Restricted SIGMA-## Data at 
        the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute atomicEnergyMarkings specified
        with a value containing [FRD-SG-##], where ## is represented by a regular expression matching
        numbers 1 through 99, unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [FRD-SG-##].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:let name="matchingTokens" value="
          for $token in $partAtomicEnergyMarkings_tok return
            if(matches($token,'^FRD-SG-[1-9][0-9]?$'))
            then $token
            else null
          "/>
      <sch:assert  
            test="every $token in $matchingTokens satisfies
                    index-of($bannerAtomicEnergyMarkings_tok, $token) > 0"
            flag="error">
            [ISM-ID-00077][Error] USA documents having Formerly Restricted SIGMA-## Data must have the same Formerly Restricted SIGMA-## Data at 
            the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>