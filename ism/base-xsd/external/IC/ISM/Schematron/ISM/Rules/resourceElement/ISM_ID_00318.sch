<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ISM-ID-00318" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00318][Error] Rollup compiliation does not meet CAPCO guidance.
    </sch:p>
    <sch:p id="codeDesc">
    	Where an element is the resource element and contains the @ism:releasableTo attribute
    	check that the values specified meet minimum rollup conditions. Check all contributing
    	portions against the banner for the existence of common countries ensuring that the 
    	countries in the banner are the intersection of all contributing portions. The tetragraphs
    	for TEYE, ACGU, and FVEY will be decomposed into their representative countries. All other
    	tetragraphs will be treated as a wildcard of all countries since the membership is not 
    	known.
    	
    	Once the minimum possibility of intersecting countries is determined the rule checks that
    	there is not a portion for which the banner is not a subset. Then it checks for the case
    	of no common countries that can be rollup up to the resource element. There is a check that
    	if the banner countries are a subset of the common countries that a compilationReason is 
    	specified. If compilationReason is not specified then the banner releasableTo countries
    	must be the set of common countries from all contributing portions.
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and
                        @ism:releasableTo]">
        <sch:let name="msg" value="'[ISM-ID-00318][Error] Rollup compilation does not meet CAPCO guidance. '"/>
        <sch:let name="result" value="util:checkRelToPortionsAgainstBannerAndGetCommonCountries(@ism:releasableTo, $partTags)"/>
        <sch:assert  
            test="if($result[1]='BANNER_NOT_A_SUBSET_OF_A_PORTION')
                then false()
                else true()"
            flag="error">
            <sch:value-of select="$msg"/> There exists a portion with @ism:releasableTo in this document for which 
            this banner @ism:releasableTo is not a subset.
        </sch:assert>
        <sch:assert  
            test="if(count(tokenize(string($result), ' '))=0)
                then false()
                else true()"
            flag="error">
            <sch:value-of select="$msg"/> The banner cannot have @ism:releasableTo because
            there is no common country in @ism:releasableTo for the contributing portions.
        </sch:assert>
        <sch:assert  
            test="if(not(util:containsSpecialTetra(@ism:releasableTo)) and @ism:compilationReason)
                    then util:bannerIsSubset(@ism:releasableTo, $result)
                    else true()"
            flag="error">
            <sch:value-of select="$msg"/> The banner @ism:releasableTo must be a subset 
            of the common countries for contributing portions because @ism:compilationReason
            is specified. Common countries: [<sch:value-of select="$result"/>].
        </sch:assert>
        <sch:assert  
            test="if(not(util:containsSpecialTetra(@ism:releasableTo)) and not(@ism:compilationReason))
                    then util:bannerIsSubset(@ism:releasableTo, $result) and util:bannerIsSubset($result, @ism:releasableTo)
                    else true()"
            flag="error">
            <sch:value-of select="$msg"/> The banner @ism:releasableTo must be equal to 
            the set of the common countries because @ism:compilationReason is not specified.
            Common countries: [<sch:value-of select="$result"/>].
        </sch:assert>
    </sch:rule>
</sch:pattern>
