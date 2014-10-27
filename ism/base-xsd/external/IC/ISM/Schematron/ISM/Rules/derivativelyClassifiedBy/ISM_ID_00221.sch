<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00221" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00221][Error] If ISM_CAPCO_RESOURCE and attribute 
        derivativelyClassifiedBy is specified, then attribute classificationReason
        must not be specified.
        
        Human Readable: USA documents that are derivatively classified must not
        specify a classification reason.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which 
    	specifies attribute ism:derivativelyClassifiedBy we make sure that
    	attribute ism:classificationReason is NOT specified.
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE and @ism:derivativelyClassifiedBy]">
        <sch:assert  
            test="not(@ism:classificationReason)" 
            flag="error">
        	[ISM-ID-00221][Error] If ISM_CAPCO_RESOURCE and attribute 
        	derivativelyClassifiedBy is specified, then attribute classificationReason
        	must not be specified.
        	
        	Human Readable: USA documents that are derivatively classified must not
        	specify a classification reason.
        </sch:assert>
    </sch:rule>
</sch:pattern>