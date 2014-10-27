<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00226" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    
    <sch:p id="ruleText">
        [ISM-ID-00226][Error] Attributes @ism:noticeType and @ism:unregisteredNoticeType
        may not both be used on the same element. 
        
        Human Readable: Ensure that the ISM attributes noticeType and
        unregisteredNoticeType are not used on the same element.
    </sch:p>
    <sch:p id="codeDesc">
        For each element which has attribute ism:noticeType specified, we
        make sure that ism:unregisteredNoticeType is not specified. 
    </sch:p>

    <sch:rule context="*[@ism:noticeType]">
        <sch:assert  flag="error"
            test="not(@ism:unregisteredNoticeType)">
            [ISM-ID-00226][Error]
            @ism:noticeType and @ism:unregisteredNoticeType may not both be 
            applied to the same element.
            
            Human Readable: The ISM attributes noticeType and unregisteredNoticeType 
            are mutually exclusive and cannot both be applied to the same element. 
        </sch:assert>
    </sch:rule>
</sch:pattern>