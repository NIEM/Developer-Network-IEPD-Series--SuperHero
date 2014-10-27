<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00032" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00032][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls is not specified, or is specified and does not 
        contain the name token [REL] or [EYES], then attribute releasableTo 
        must not be specified.
        
        Human Readable: USA documents must only specify to which countries it is 
        authorized for release if dissemination information contains 
        REL TO or EYES ONLY data. 
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        does not specify attribute disseminationControls or specifies attribute
        ism:disseminationControls with a value containing the token 
        [REL] or [EYES] we make sure that attribute ism:releasableTo is not 
        specified.
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES')))]">
        <sch:assert  
            test="not(@ism:releasableTo)"
            flag="error">
            [ISM-ID-00032][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls is not specified, or is specified and does not 
            contain the name token [REL] or [EYES], then attribute releasableTo 
            must not be specified.
            
            Human Readable: USA documents must only specify to which countries it is 
            authorized for release if dissemination information contains 
            REL TO or EYES ONLY data. 
        </sch:assert>
    </sch:rule>
</sch:pattern>