<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00102" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00102][Error] The attribute 
        DESVersion in the namespace urn:us:gov:ic:ism must be specified.
        
        Human Readable: The data encoding specification version must
        be specified.
    </sch:p>
    <sch:p id="codeDesc">
        Make sure that the attribute edh:DESVersion 
        is specified.
    </sch:p>
    <sch:rule context="/">
        <sch:assert  
            test="some $element in descendant-or-self::node() satisfies $element/@ism:DESVersion"
            flag="error">
            [ISM-ID-00102][Error] The attribute 
            DESVersion in the namespace urn:us:gov:ic:ism must be specified.
            
            Human Readable: The data encoding specification version must 
            be specified.
        </sch:assert>
    </sch:rule>
</sch:pattern>