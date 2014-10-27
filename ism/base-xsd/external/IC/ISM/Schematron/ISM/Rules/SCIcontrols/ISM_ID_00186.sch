<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00186" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00186][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains a token matching [SI-G-XXXX],
        where X is represented by the regular expression character class [A-Z]{4}, then it must also contain the
        name token [SI-G].
        
        Human Readable: A USA document that contains Special Intelligence (SI) GAMMA sub-compartments must
        also specify that it contains SI-GAMMA compartment data.
    </sch:p>
    <sch:p id="codeDesc">
      If the document is an ISM-CAPCO-RESOURCE, for each element which
      specifies attribute ism:SCIcontrols with a value containing a token
      matching [SI-G-XXXX], where X is represented by the regular expression
      character class [A-Z]{4}, we make sure that attribute ism:SCIcontrols is 
      specified with a value containing the token [SI-G].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G-[A-Z]{4}$'))]">
        <sch:assert test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))"
            flag="error">
          [ISM-ID-00186][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains a token matching [SI-G-XXXX],
          where X is represented by the regular expression character class [A-Z]{4}, then it must also contain the
          name token [SI-G].
          
          Human Readable: A USA document that contains Special Intelligence (SI) GAMMA sub-compartments must
          also specify that it contains SI-GAMMA compartment data.
        </sch:assert>
    </sch:rule>
</sch:pattern>