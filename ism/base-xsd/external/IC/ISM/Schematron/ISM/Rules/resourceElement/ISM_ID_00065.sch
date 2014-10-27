<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00065" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00065][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute FGIsourceProtected containing any value then the ISM_RESOURCE_ELEMENT must have FGIsourceProtected with a value.
        
        Human Readable: USA documents having FGI Protected data must have FGI Protected at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute FGIsourceProtected specified 
        with a non-empty value and does not have attribute excludeFromRollup set to true, 
        then we make sure that the banner has attribute FGIsourceProtected specified with 
        a non-empty value.
    </sch:p>  
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
                        and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)
                        and not(empty($partFGIsourceProtected))]">
        <sch:assert  
            test="@ism:FGIsourceProtected"
            flag="error">
            [ISM-ID-00065][Error] USA documents having FGI Protected data must have FGI Protected at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>