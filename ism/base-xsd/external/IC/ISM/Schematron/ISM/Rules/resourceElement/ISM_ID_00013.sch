<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00013" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00013][Error] If ISM_NSI_EO_APPLIES then either attribute classifiedBy or 
        derivedFrom must be specified on the ISM_RESOURCE_ELEMENT. 
        
        Human Readable: Documents under E.O. 13526 must have classification authority block information.
    </sch:p>
    <sch:p id="codeDesc">
      If ISM_NSI_EO_APPLIES, we make sure that the ISM_RESOURCE_ELEMENT specifies
      attribute ism:classifiedBy or attribute ism:derivedFrom.
    </sch:p>
    <sch:rule context="*[$ISM_NSI_EO_APPLIES
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert  
            test="@ism:classifiedBy or @ism:derivedFrom"
            flag="error">
            [ISM-ID-00013][Error] Documents under E.O. 13526 must have classification authority block information.
        </sch:assert>
    </sch:rule>
</sch:pattern>