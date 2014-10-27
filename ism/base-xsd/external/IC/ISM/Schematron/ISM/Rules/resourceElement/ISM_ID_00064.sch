<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00064" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00064][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute FGIsourceOpen containing any value then the ISM_RESOURCE_ELEMENT must have either 
        FGIsourceOpen or FGIsourceProtected with a value. 
        
        Human Readable: USA documents having FGI Open data must have FGI Open or FGI Protected at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute 
        FGIsourceOpen specified and does not have attribute excludeFromRollup set to true, 
        then we make sure that the resourceElement has one of the following attributes 
        specified: FGIsourceOpen or FGIsourceProtected.
    </sch:p>   
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert  
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(not(empty($partFGIsourceOpen))) 
                then ($bannerFGIsourceOpen 
                      or $bannerFGIsourceProtected) 
                else true()
            " 
            flag="error">
            [ISM-ID-00064][Error] USA documents having FGI Open data must have FGI Open or FGI Protected at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>