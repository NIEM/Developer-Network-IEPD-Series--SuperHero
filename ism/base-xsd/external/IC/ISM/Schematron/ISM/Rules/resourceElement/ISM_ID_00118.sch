<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00118" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00118][Error] The first element in document order having 
        resourceElement true must have createDate specified.
    </sch:p>
    <sch:p id="codeDesc">
        We make sure that the resourceElement has attribute createDate specified.
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][1]">
        <sch:assert  
            test="@ism:createDate"
            flag="error">
            [ISM-ID-00118][Error] The first element in document order having 
            resourceElement true must have createDate specified.
        </sch:assert>
    </sch:rule>
</sch:pattern>