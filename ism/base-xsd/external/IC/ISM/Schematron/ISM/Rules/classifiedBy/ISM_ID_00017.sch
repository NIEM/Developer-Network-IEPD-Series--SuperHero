<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00017" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00017][Error] If ISM_NSI_EO_APPLIES and attribute 
        classifiedBy is specified, then attribute classificationReason must 
        be specified. 
        
        Human Readable: Documents under E.O. 13526 containing 
        Originally Classified data require a classification reason to be
        identified.
    </sch:p>
    <sch:p id="codeDesc">
    	If ISM_NSI_EO_APPLIES, for each element which specifies attribute
    	ism:classifiedBy we make sure that attribute ism:classificationReason
    	is specified.
    </sch:p>
	<sch:rule context="*[$ISM_NSI_EO_APPLIES and @ism:classifiedBy]">
        <sch:assert  
            test="@ism:classificationReason" 
            flag="error">
        	[ISM-ID-00017][Error] If ISM_NSI_EO_APPLIES and attribute 
        	classifiedBy is specified, then attribute classificationReason must 
        	be specified. 
        	
        	Human Readable: Documents under E.O. 13526 containing 
        	Originally Classified data require a classification reason to be
        	identified.
        </sch:assert>
    </sch:rule>
</sch:pattern>