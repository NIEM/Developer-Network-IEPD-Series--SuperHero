<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00031" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00031][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [REL] or [EYES], then 
        attribute releasableTo must be specified.
        
        Human Readable: USA documents containing REL TO or EYES ONLY 
        dissemination must specify to which countries the document is releasable.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [REL] or [EYES] we make sure that attribute ism:releasableTo
    	is specified.
    </sch:p>
	<sch:rule context="*[$ISM_CAPCO_RESOURCE
                  	  and util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES'))]">
        <sch:assert  
            test="@ism:releasableTo" 
            flag="error">
        	[ISM-ID-00031][Error] If ISM_CAPCO_RESOURCE and attribute 
        	disseminationControls contains the name token [REL] or [EYES], then 
        	attribute releasableTo must be specified.
        	
        	Human Readable: USA documents containing REL TO or EYES ONLY 
        	dissemination must specify to which countries the document is releasable.
        </sch:assert>
    </sch:rule>
</sch:pattern>