<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00227" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00227][Error] Attribute @noticeType may only appear on the 
        resource node when it contains the values [DoD-Dist-A], [DoD-Dist-B], 
        [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X].
        
        Human Readable: Documents may only specify a document-level notice if
        it pertains to DoD Distribution.
    </sch:p>
    <sch:p id="codeDesc">
        For every resource element with the ism:noticeType attribute specified,
        we make sure that attribute's value is one of [DoD-Dist-A], [DoD-Dist-B], 
        [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
        by using a regular expression.
        
    </sch:p> 
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) 
		                    and @ism:noticeType]">       
        <sch:assert 
            test="every $noticeToken in tokenize(normalize-space(string(@ism:noticeType)), ' ') satisfies
                    matches($noticeToken, '^DoD-Dist-[ABCDEFX]')"
            flag="error">
            [ISM-ID-00227][Error] Attribute @noticeType may only appear on the 
            resource node when it contains the values [DoD-Dist-A], [DoD-Dist-B], 
            [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X].
            
            Human Readable: Documents may only specify a document-level notice if
            it pertains to DoD Distribution.
        </sch:assert>
    </sch:rule>
</sch:pattern>