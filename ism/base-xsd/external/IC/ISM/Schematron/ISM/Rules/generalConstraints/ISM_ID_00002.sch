<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00002" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00002][Error] For every attribute in the ISM namespace that is
        used in a document a non-null value must be present.
    </sch:p>
    <sch:p id="codeDesc">
        For each element which defines an attribute in the ISM namespace, we 
        make sure that each attribute in the ISM namespace is specified with 
        a non-whitespace value.
    </sch:p>
    <sch:rule context="*[@ism:*]">
        <sch:assert  
            test="every $attribute in @ism:* satisfies
                    normalize-space(string($attribute))"
            flag="error">
        	[ISM-ID-00002][Error] For every attribute that is used in a 
        	document a non-null value must be present.
        </sch:assert>
    </sch:rule>
</sch:pattern>