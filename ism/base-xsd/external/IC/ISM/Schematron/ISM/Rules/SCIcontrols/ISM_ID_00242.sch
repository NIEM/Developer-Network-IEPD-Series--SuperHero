<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00242" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00242][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [RSV],
        then it must also have attribute classificatoin with a value of [S] or [TS].
        
        Human Readalbe: A USA document that contains RESERVE data must be classified SECRET or TOP SECRET.
    </sch:p>
    <sch:p id="codeDesc">
      If the document is an ISM_CAPCO_RESOURCE, for each element which specifies
      attribute ism:SCIcontrols with a value containing the token [RSV], we make
      sure that attribute ism:classification is specified with a value containing
      the token [TS] or [S].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))]">
        <sch:assert  
            test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))"
            flag="error">
            [ISM-ID-00242][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [RSV],
            then it must also have attribute classificatoin with a value of [S] or [TS].
            
            Human Readalbe: A USA document that contains RESERVE data must be classified SECRET or TOP SECRET. 
        </sch:assert>
    </sch:rule>
</sch:pattern>