<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern id="ISM-ID-00238" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
    	[ISM-ID-00238][Error] If ISM-CAPCO-RESOURCE, if any element specifies
    	attribute noticeType containing one of the tokens [DoD-Dist-B], 
    	[DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X],
    	then an element in the document must specify attribute pocType with
    	the same value as attribute noticeType.
    	
        Human Readable: DoD distribution statements B, C, D ,E ,F, and X all 
        require a corresponding point of contact.
    </sch:p>
    <sch:p id="codeDesc">
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:noticeType specified with a value containing the token
        [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], 
        or [DoD-Dist-X], we make sure that some element in the document 
        specifies attribute ism:pocType with the same value as ism:noticeType.
    </sch:p>
    <sch:rule context="*[$ISM_CAPCO_RESOURCE
				    	and util:containsAnyOfTheTokens(@ism:noticeType, 
				    		('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))]">
        <sch:let name="foundNoticeTokens" value="
          for $noticeToken in tokenize(normalize-space(string(@ism:noticeType)), ' ') return 
              if(matches($noticeToken, '^DoD-Dist-[BCDEFX]'))
              then $noticeToken
              else null"/>
        <sch:assert
        	test="every $noticeToken in $foundNoticeTokens satisfies
        	        index-of($partPocType_tok, $noticeToken)>0"
            flag="error"> 
        	[ISM-ID-00238][Error] DoD distribution statements B, C, D ,E ,F, and X all 
        	require a corresponding point of contact.
        </sch:assert>
    </sch:rule>
</sch:pattern>