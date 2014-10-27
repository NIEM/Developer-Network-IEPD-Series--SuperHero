<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00143" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00143][Error] If ISM_CAPCO_RESOURCE and attribute 
        derivativelyClassifiedBy is specified, then attribute derivedFrom must
        be specified. 
        
        Human Readable: Derivatively Classified data including DOE data requires
        a derived from value to be identified.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which 
    	specifies attribute ism:derivativelyClassifiedBy we make sure that
    	attribute ism:derivedFrom is specified.
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE and @ism:derivativelyClassifiedBy]">
        <sch:assert  
            test="@ism:derivedFrom" 
            flag="error">
        	[ISM-ID-00143][Error] If ISM_CAPCO_RESOURCE and attribute 
        	derivativelyClassifiedBy is specified, then attribute derivedFrom must
        	be specified. 
        	
        	Human Readable: Derivatively Classified data including DOE data requires
        	a derived from value to be identified.
        </sch:assert>
    </sch:rule>
</sch:pattern>