<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00097" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00097][Warning] If ISM_CAPCO_RESOURCE and attribute FGIsourceProtected is 
        specified with a value other than [FGI] then the value(s) must not be discoverable in IC shared spaces.
        
        Human Readable: FGI Protected should rarely if ever be seen outside of an agency's internal systems.    
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which specifies
    	the attribute ism:FGIsourceProtected, we make sure that attribute
    	ism:FGIsourceProtected contains only the token [FGI].
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE and @ism:FGIsourceProtected]">
        <sch:assert  
            test="normalize-space(string(./@ism:FGIsourceProtected))='FGI'"
            flag="warning">
        	[ISM-ID-00097][Warning] If ISM_CAPCO_RESOURCE and attribute FGIsourceProtected is 
        	specified with a value other than [FGI] then the value(s) must not be discoverable in IC shared spaces.
        	
        	Human Readable: FGI Protected should rarely if ever be seen outside of an agency's internal systems.  
        </sch:assert>
    </sch:rule>
</sch:pattern>