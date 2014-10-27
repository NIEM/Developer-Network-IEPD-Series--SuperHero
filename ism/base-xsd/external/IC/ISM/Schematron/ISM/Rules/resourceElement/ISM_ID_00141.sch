<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00141" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00141][Error] If ISM_NSI_EO_APPLIES and 
        1. ISM_RESOURCE_ELEMENT attribute declassException does not have a value of [50X1-HUM], or [50X2-WMD]
        AND
        2. ISM_RESOURCE_ELEMENT attribute declassDate is not specified
        AND
        3. ISM_RESOURCE_ELEMENT attribute declassEvent is not specified
        AND
        4. ISM_RESOURCE_ELEMENT attribute atomicEnergyMarkings is not specified
           with a value of [RD] or [FRD]
            
        Human Readable: Documents under E.O. 13526 require declassDate or declassEvent unless 
        50X1-HUM, 50X2-WMD, RD, FRD, AEA, NATO, or NATO-AEA is specified.
    </sch:p>
    <sch:p id="codeDesc">
        If ISM_NSI_EO_APPLIES, the current element is the ISM_RESOURCE_ELEMENT,
        and attribtue ism:declassExeption is not specified with a value
        containing the token [50X1-HUM], or [50X2-WMD], [AEA], [NATO], or [NATO-AEA]
        then we make sure that attribute ism:declassDate is 
        specified or attribute ism:declassEvent is specified.
    </sch:p>
    <sch:rule context="*[$ISM_NSI_EO_APPLIES
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and not(util:containsAnyOfTheTokens(@ism:declassException, ('50X1-HUM', '50X2-WMD', 'AEA', 'NATO', 'NATO-AEA')))]">
                        <!--and not(util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD', 'FRD')))]">-->
        <sch:assert test="@ism:declassDate or @ism:declassEvent"
            flag="error">
            [ISM-ID-00141][Error] Documents under E.O. 13526 require declassDate or declassEvent unless  
            50X1-HUM, 50X2-WMD, RD, FRD, AEA, NATO, or NATO-AEA is specified.
        </sch:assert>
    </sch:rule>
</sch:pattern>