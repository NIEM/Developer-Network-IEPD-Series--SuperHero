<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00103" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00103][Error] At least one element must have attribute 
        resourceElement specified with a value of [true].
    </sch:p>
    <sch:p id="codeDesc">
        For the document, we make sure that at least one element specifies 
        attribute ism:resourceElement with a value of [true].
    </sch:p>
    <sch:rule context="/*">
        <sch:assert  
            test="some $token in //*[(@ism:*)] satisfies
            		$token/@ism:resourceElement=true()"
            flag="error">
        	[ISM-ID-00103][Error] At least one element must have attribute 
        	resourceElement specified with a value of [true].
        </sch:assert>
    </sch:rule>
</sch:pattern>