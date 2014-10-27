<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00300" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00300][Error] DESVersion attributes must be specified as version 10.
    </sch:p>
    <sch:p id="codeDesc">
        DESVersion attributes must be specified as version 10.
    </sch:p>
    <sch:rule context="*[@ism:DESVersion]">
        <sch:assert  
            test="@ism:DESVersion='10'"
            flag="error">
            [ISM-ID-00300][Error] DESVersion attributes must be specified as version 10.
        </sch:assert>
    </sch:rule>
</sch:pattern>