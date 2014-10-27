<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00320" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        
    </sch:p>
    <sch:p id="codeDesc">
    	
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and
                            (@ism:releasableTo or @ism:displayOnlyTo)]">
        <sch:let name="result" value="util:checkDisplayToPortionsAgainstBannerAndGetCommonCountries(util:getDisplayToCountries(.), $partTags)"/>
        <sch:assert  
            test="if($result[1]='BANNER_NOT_A_SUBSET_OF_A_PORTION')
                then false()
                else true()"
            flag="error">
            [ISM-ID-00320][Error] There exists a portion with the combination of @ism:releasableTo and @ism:displayOnlyTo in this document for which 
            this banner @ism:releasableTo combined with the banner @ism:releasableTo is not a subset
        </sch:assert>
        <sch:assert  
            test="if(count(tokenize(string($result), ' '))=0)
                then false()
                else true()"
            flag="error">
            [ISM-ID-00320][Error] The banner cannot have @ism:displayOnlyTo because
            there is no common country in the contributing portions.
        </sch:assert>
        <sch:assert  
            test="if(not(util:containsSpecialTetra(util:getDisplayToCountries(.))) and @ism:compilationReason)
                    then util:bannerIsSubset(util:getDisplayToCountries(.), $result)
                    else true()"
            flag="error">
            [ISM-ID-00320][Error] The banner @ism:releasableTo and @ism:displayOnlyTo must be a subset 
            of the common countries for contributing portions because @ism:compilationReason
            is specified. Common countries: [<sch:value-of select="$result"/>].
        </sch:assert>
        <sch:assert  
            test="if(not(util:containsSpecialTetra(util:getDisplayToCountries(.))) and not(@ism:compilationReason))
                    then util:bannerIsSubset(util:getDisplayToCountries(.), $result) and util:bannerIsSubset($result, util:getDisplayToCountries(.))
                    else true()"
            flag="error">
            [ISM-ID-00320][Error] The banner @ism:releasableTo and @ism:displayOnlyTo must be 
            equal to the set of common countries for contributing portions because @ism:compilationReason
            is not specified. Common countries: [<sch:value-of select="$result"/>].
        </sch:assert>
    </sch:rule>
</sch:pattern>
