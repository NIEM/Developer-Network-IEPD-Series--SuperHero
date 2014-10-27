<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00126" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00126][Error] Attributes with namespace urn:us:gov:ic:ism must 
        not appear with attribute @xs:any. 
        
        Human Readable: Ensure that no attributes that appear to be in the 
        ISM namespace, but are not defined by ISM.XML, are used in a schema
        that might have an xs:any.
    </sch:p>
    <sch:p id="codeDesc">
        For any element which specifies an attribute in the ISM namespace, we
        make sure that the attribute xs:any is NOT specified.
    </sch:p>
    <sch:rule context="*[@ism:*]">
        <sch:assert  
            test="not(./@xs:any)"
            flag="error">
        	[ISM-ID-00126][Error] Attributes with namespace urn:us:gov:ic:ism must 
        	not appear with attribute @xs:any. 
        	
        	Human Readable: Ensure that no attributes that appear to be in the 
        	ISM namespace, but are not defined by ISM.XML, are used in a schema
        	that might have an xs:any.
        </sch:assert>
    </sch:rule>
</sch:pattern>