<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern id="ISM-ID-00237" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00237][Error] If ISM-CAPCO-RESOURCE, any element which specifies
        attribute noticeType containing one of the tokens [DoD-Dist-B], 
       	[DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
       	must also specify attribute noticeDate.
       	
        Human Readable: DoD distribution statements B, C, D ,E ,F, and X all require a date.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:noticeType specified with a value containing the token
        [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], 
        or [DoD-Dist-X], we make sure that attribute ism:noticeDate is specified.
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
				    	and util:containsAnyOfTheTokens(@ism:noticeType, 
				    		('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))]">
        <sch:assert test="@ism:noticeDate"
            flag="error"> 
            [ISM-ID-00237][Error] DoD distribution statements B, C, D ,E ,F, and X all require a date.
        </sch:assert>
    </sch:rule>
</sch:pattern>