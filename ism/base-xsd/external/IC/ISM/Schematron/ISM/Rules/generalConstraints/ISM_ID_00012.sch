<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00012" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00012][Error] If any of the attributes defined in 
        this DES other than DESVersion, unregisteredNoticeType, or pocType 
        are specified for an element, then attributes classification and 
        ownerProducer must be specified for the element.
    </sch:p>
    <sch:p id="codeDesc">
    	For each element which defines an attribute in the ISM namespace other
    	than ism:pocTyp, ism:DESVersion, or ism:unregisteredNoticeType we make
    	sure that attributes ism:classification and ism:ownerProducer are
    	specified.
    </sch:p>
    <sch:rule context="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType)]">
        <sch:assert  
            test="@ism:ownerProducer and @ism:classification" 
            flag="error">
        	[ISM-ID-00012][Error] If any of the attributes defined in 
        	this DES other than DESVersion, unregisteredNoticeType, or pocType 
        	are specified for an element, then attributes classification and 
        	ownerProducer must be specified for the element.
        </sch:assert>
    </sch:rule>
</sch:pattern>