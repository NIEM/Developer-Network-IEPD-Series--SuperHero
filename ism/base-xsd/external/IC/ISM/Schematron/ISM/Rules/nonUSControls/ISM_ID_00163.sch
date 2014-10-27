<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00163" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00163][Error] If attribute nonUSControls exists the attribute 
        ownerProducer must equal [NATO].
        
        Human Readable: NATO is the only owner of classification markings
        for which nonUSControls are currently authorized.
    </sch:p>
    <sch:p id="codeDesc">
        For each element which specifies attribute ism:nonUSControls, we make
        sure that attribute ism:nonUSControls is specified with a value of [NATO].
    </sch:p>
    <sch:rule context="*[@ism:nonUSControls]">
        <sch:assert  
            test="normalize-space(string(@ism:ownerProducer))='NATO'"
            flag="error">
        	[ISM-ID-00163][Error] If attribute nonUSControls exists the attribute 
        	ownerProducer must equal [NATO].
        	
        	Human Readable: NATO is the only owner of classification markings
        	for which nonUSControls are currently authorized.
        </sch:assert>
    </sch:rule>
</sch:pattern>