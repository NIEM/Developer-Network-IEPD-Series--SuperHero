<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00016" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00016][Error] If ISM_CAPCO_RESOURCE and attribute 
        classification has a value of [U], then attributes classificationReason,
        classifiedBy, derivativelyClassifiedBy, declassDate, declassEvent, 
        declassException, derivedFrom, SARIdentifier, or 
        SCIcontrols must not be specified.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:classification specified with a value of [U] we make
    	sure that NONE of the following attributes are specified:
    	ism:classifiedBy, ism:declassDate, ism:declassEvent, ism:declassException,
    	ism:derivativelyClassifiedBy, ism:derivedFrom, 
    	ism:SARIdentifier, or ism:SCIcontrols. 
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE and @ism:classification='U']">
        <sch:assert  
            test="not(
                    @ism:classificationReason 
            		  or @ism:classifiedBy 
		              or @ism:declassDate 
		              or @ism:declassEvent 
		              or @ism:declassException 
		              or @ism:derivativelyClassifiedBy 
		              or @ism:derivedFrom 
		              or @ism:SARIdentifier
		              or @ism:SCIcontrols
		              )" 
            flag="error">
          [ISM-ID-00016][Error] If ISM_CAPCO_RESOURCE and attribute 
          classification has a value of [U], then attributes classificationReason,
          classifiedBy, derivativelyClassifiedBy, declassDate, declassEvent, 
          declassException, derivedFrom, SARIdentifier, or 
          SCIcontrols must not be specified.
        </sch:assert>
    </sch:rule>
</sch:pattern>