<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00142" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00142][Error] If ISM_NSI_EO_APPLIES and attribute classification
        has a value other than [U], then attribute classifiedBy or 
        derivativelyClassifiedBy must be specified on the ISM_RESOURCE_ELEMENT.
        
        Human Readable: Classified data including DOE data requires either an 
        original classifier or a derivative classifier be identified.
    </sch:p>
    <sch:p id="codeDesc">
    	If ISM_NSI_EO_APPLIES, for each element which specified attribute
    	ism:classification with a value other than [U], we make sure that
    	the ISM_RESOURCE_ELEMENT specifies attribute ism:classifiedBy or 
    	ism:derivativelyClassifiedBy.
    </sch:p>
	<sch:rule context="*[$ISM_NSI_EO_APPLIES and @ism:classification!='U']">
        <sch:assert  
            test="$ISM_RESOURCE_ELEMENT/@ism:classifiedBy 
            	or $ISM_RESOURCE_ELEMENT/@ism:derivativelyClassifiedBy"
            flag="error">
            [ISM-ID-00142][Error] Classified data including DOE data requires 
            either an original classifier or a derivative classifier be identified.
        </sch:assert>
    </sch:rule>
</sch:pattern>