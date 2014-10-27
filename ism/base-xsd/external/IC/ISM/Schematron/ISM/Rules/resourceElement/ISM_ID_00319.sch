<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00319" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00319][Error] If attribute releasableTo is specified, then it must
        contain more than a single token.
    </sch:p>
    <sch:p id="codeDesc">
    	If a portion specifies attribute releasableTo, then we make sure the 
    	token count is greater than 1.
    </sch:p>
    <sch:rule context="*[@ism:releasableTo and $ISM_CAPCO_RESOURCE]">
        <sch:assert test="count(tokenize(normalize-space(string(@ism:releasableTo)), ' ')) > 1"
            flag="error">
            [ISM-ID-00319][Error] If attribute releasableTo is specified, then it must
            contain more than a single token.
        </sch:assert>
    </sch:rule>
</sch:pattern>
