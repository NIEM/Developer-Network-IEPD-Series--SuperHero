<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00214" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00214][Error] If ISM_CAPCO_RESOURCE then attribute 
        releasableTo must start with [USA].
    </sch:p>
    <sch:p id="codeDesc">
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute releasableTo we make sure that attribute
        releasableTo is specified with a value that starts with the token [USA].
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE and @ism:releasableTo]">
        <sch:assert  
            test="index-of(tokenize(normalize-space(string(@ism:releasableTo)),' '),'USA')=1"
            flag="error">
            [ISM-ID-00214][Error] If ISM_CAPCO_RESOURCE then attribute 
            releasableTo must start with [USA].
        </sch:assert>
    </sch:rule>
</sch:pattern>