<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00123" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00123][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
        contains the name token [KDK], then attribute disseminationControls
        must contain the name token [NF].
        
        Human Readable: A USA document containing KLONDIKE data must also be
        marked for NO FOREIGN dissemination.
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [KDK] we make sure that attribute ism:disseminationControls is 
        specified with a value containing the token [NF].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK'))]">  
          <sch:assert  
            test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))" 
            flag="error">
            [ISM-ID-00123][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
            contains the name token [KDK], then attribute disseminationControls
            must contain the name token [NF].
            
            Human Readable: A USA document containing KLONDIKE data must also be
            marked for NO FOREIGN dissemination.
        </sch:assert>
    </sch:rule>
</sch:pattern>