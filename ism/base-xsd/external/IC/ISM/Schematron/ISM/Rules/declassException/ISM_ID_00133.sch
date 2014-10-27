<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00133" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00133][Error] If ISM_NSI_EO_APPLIES and attribute 
        declassException is specified and contains the tokens 
        [50X1-HUM], or [50X2-WMD], then attribute declassDate or declassEvent must NOT be specified.
        
        Human Readable: Documents under E.O. 13526 must not specify declassDate or declassEvent if 
        a declassException of 50X1-HUM or 50X2-WMD is specified.
    </sch:p>
    <sch:p id="codeDesc">
    	If ISM_NSI_EO_APPLIES, for each element which specifies 
    	ism:declassException with a value containing token 
    	[50X1-HUM], or [50X2-WMD] we make sure that attributes ism:declassDate
    	and ism:declassEvent are NOT specified.
    </sch:p>
	<sch:rule context="*[$ISM_NSI_EO_APPLIES
	                    and util:containsAnyOfTheTokens(@ism:declassException, ('50X1-HUM', '50X2-WMD'))]">
        <sch:assert 
            test="not(@ism:declassDate or @ism:declassEvent)" 
            flag="error">
        	[ISM-ID-00133][Error] If ISM_NSI_EO_APPLIES and attribute 
        	declassException is specified and contains the tokens 
        	[50X1-HUM], or [50X2-WMD], then attribute declassDate or declassEvent 
        	must NOT be specified.
        	
        	Human Readable: Documents under E.O. 13526 must not specify declassDate
        	or declassEvent if a declassException of 50X1-HUM or 50X2-WMD is specified.
        </sch:assert>
    </sch:rule>
</sch:pattern>