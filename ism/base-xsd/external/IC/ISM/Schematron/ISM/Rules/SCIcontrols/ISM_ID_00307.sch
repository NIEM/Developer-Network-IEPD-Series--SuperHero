<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00307" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00307][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains a token matching [KDK-BLFH-XXXXXX],
        where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
        name token [KDK-BLFH].
        
        Human Readable: A USA document that contains KLONDIKE (KDK) BLUEFISH sub-compartments must
        also specify that it contains KDK -BLUEFISH compartment data.
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing a token
        matching [KDK-BLFH-XXXXXX], where X is represented by the regular expression
        character class [A-Z]{1,6}, we make sure that attribute ism:SCIcontrols is 
        specified with a value containing the token [KDK-BLFH].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
        and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^KDK-BLFH-[A-Z]{1,6}$'))]">
        <sch:assert test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-BLFH'))"
            flag="error">
            [ISM-ID-00307][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains a token matching [KDK-BLFH-XXXXXX],
            where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
            name token [KDK-BLFH].
            
            Human Readable: A USA document that contains KLONDIKE (KDK) BLUEFISH sub-compartments must
            also specify that it contains KDK -BLUEFISH compartment data.
        </sch:assert>
    </sch:rule>
</sch:pattern>