<?xml version="1.0" encoding="UTF-8"?>
<?ICEA master?><!-- UNCLASSIFIED -->
<!-- Notices - Distribution Notice:
            This document is being made available by the Intelligence Community Chief Information Officer
            to Federal, State, Local, Tribal, and Foreign Partners and associated contractors. Approval for
            any further distribution must be coordinated via the Intelligence Community Chief Information 
            Officer, Mission Engagement Division at standardssupport@dni.gov-->
<!-- WARNING: 
    Once compiled into an XSLT the result will 
    be the aggregate classification of all the CVES 
    and included .sch files
-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:cve="urn:us:gov:ic:cve"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            queryBinding="xslt2">
        <sch:ns uri="urn:us:gov:ic:ism" prefix="ism"/>
        <sch:ns uri="urn:us:gov:ic:cve" prefix="cve"/>
        <sch:ns uri="deprecated:value:function" prefix="dvf"/>
        <sch:ns uri="urn:us:gov:ic:ism:xsl:util" prefix="util"/>
        <sch:p id="codeDesc">This is the root file for the ISM Schematron rule set. It loads all of
                the required CVEs declares some variables and includes all of the Rule .sch files. </sch:p>

        <!-- (U) Abstract Patterns -->
        <sch:include href="Lib/AttributeContributesToRollup.sch"/>
        <sch:include href="Lib/AttributeContributesToRollupWithClassification.sch"/>
        <sch:include href="Lib/AttributeValueDeprecatedError.sch"/>
        <sch:include href="Lib/AttributeValueDeprecatedWarning.sch"/>
        <sch:include href="Lib/DataHasCorrespondingNotice.sch"/>
        <sch:include href="Lib/MutuallyExclusiveAttributeValues.sch"/>
        <sch:include href="Lib/NonCompilationDocumentRollup.sch"/>
        <sch:include href="Lib/NoticeHasCorrespondingData.sch"/>
        <sch:include href="Lib/TypeConstraintPatterns.sch"/>
        <sch:include href="Lib/ValidateValueExistenceInList.sch"/>
        <sch:include href="Lib/ValidateTokenValuesExistenceInList.sch"/>
        <sch:include href="Lib/ValuesOrderedAccordingToCve.sch"/>

        <!-- (U) Resources  -->
        <sch:let name="countriesList"
            value="document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="classificationAllList"
            value="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="classificationUSList"
            value="document('../../CVE/ISM/CVEnumISMClassificationUS.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="ownerProducerList"
            value="document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="declassExceptionList"
            value="document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="FGIsourceOpenList"
            value="document('../../CVE/ISM/CVEnumISMFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="FGIsourceProtectedList"
            value="document('../../CVE/ISM/CVEnumISMFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="nonICmarkingsList"
            value="document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="releasableToList"
            value="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="SCIcontrolsList"
            value="document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="SARIdentifierList"
            value="document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="validAttributeList"
            value="document('../../CVE/ISM/CVEnumISMAttributes.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="validElementList"
            value="document('../../CVE/ISM/CVEnumISMElements.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="noticeList"
            value="document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="nonUSControlsList"
            value="document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="compliesWithList"
            value="document('../../CVE/ISM/CVEnumISMCompliesWith.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="atomicEnergyMarkingsList"
            value="document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="displayOnlyToList"
            value="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
        <sch:let name="pocTypeList"
            value="document('../../CVE/ISM/CVEnumISMPocType.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>


        <!-- (U) Resources that may include FOUO values -->
        <sch:let name="disseminationControlsList"
            value="document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>

        <!--====================-->
        <!-- (U) Universal Lets -->
        <!--====================-->
        <!-- ISM_RESOURCE_ELEMENT (node): The first element with attribute ism:resourceElement='true' -->
        <sch:let name="ISM_RESOURCE_ELEMENT"
            value="(for $each in (//*) return if($each/@ism:resourceElement=true()) then $each else null)[1]"/>

        <!-- (U) ISM_RESOURCE_CREATE_DATE (date): The date a Resource was created, or the ism:createDate attribute on the
         ISM_RESOURCE_ELEMENT node. -->
        <sch:let name="ISM_RESOURCE_CREATE_DATE" value="$ISM_RESOURCE_ELEMENT/@ism:createDate"/>

        <!-- (U) ISM_CAPCO_RESOURCE (boolean): True if the resource is a CAPCO-applicable resource, or the ism:ownerProducer attribute on the
         ISM_RESOURCE_ELEMENT node contains [USA]. False otherwise. -->
        <sch:let name="ISM_CAPCO_RESOURCE"
            value="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:ownerProducer)), ' '),'USA') &gt; 0"/>

        <!-- (U) ISM_ICDOCUMENT_APPLIES (boolean): True if the document claims compliance rules for an IC Document, or if the 
         ism:compliesWith attribute of the ISM_RESOURCE_ELEMENT node contains [ICDocument]. False otherwise. -->
        <sch:let name="ISM_ICDOCUMENT_APPLIES"
            value="(index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:compliesWith)), ' '),'ICDocument' ) &gt; 0) or              index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:compliesWith)), ' '),'IntelReport' ) &gt; 0"/>

        <sch:let name="ISM_INTELREPORT_APPLIES"
            value="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:compliesWith)), ' '),'IntelReport') &gt; 0"/>

        <!-- (U) ISM_DOD5230_24_APPLIES (boolean): True if the document claims compliance with DoD5230.24, or if the 
         ism:compliesWith attribute of the ISM_RESOURCE_ELEMENT node contains [DoD5230.24]. False otherwise. -->
        <sch:let name="ISM_DOD5230_24_APPLIES"
            value="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:compliesWith)), ' '),'DoD5230.24') &gt; 0"/>

        <!-- (U) ISM_ORCON_POC_DATE (date): The date after which a point-of-contact is required for all documents containing ORCON data -->
        <sch:let name="ISM_ORCON_POC_DATE" value="xs:date('2011-03-11')"/>

        <!-- (U) Get Banner Attributes -->
        <sch:let name="bannerClassification"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:classification))"/>
        <sch:let name="bannerDisseminationControls"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:disseminationControls))"/>
        <sch:let name="bannerDisplayOnlyTo"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:displayOnlyTo))"/>
        <sch:let name="bannerNonICmarkings"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:nonICmarkings))"/>
        <sch:let name="bannerFGIsourceOpen"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:FGIsourceOpen))"/>
        <sch:let name="bannerFGIsourceProtected"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:FGIsourceProtected))"/>
        <sch:let name="bannerReleasableTo"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:releasableTo))"/>
        <sch:let name="bannerSCIcontrols"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:SCIcontrols))"/>
        <sch:let name="bannerNotice"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:noticeType))"/>
        <sch:let name="bannerAtomicEnergyMarkings"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings))"/>

        <!-- (U) Tokenize Banner Attributes -->
        <sch:let name="bannerDisseminationControls_tok"
            value="tokenize(normalize-space(string($bannerDisseminationControls)), ' ')"/>
        <sch:let name="bannerDisplayOnlyTo_tok"
            value="tokenize(normalize-space(string($bannerDisplayOnlyTo)), ' ')"/>
        <sch:let name="bannerNonICmarkings_tok"
            value="tokenize(normalize-space(string($bannerNonICmarkings)), ' ')"/>
        <sch:let name="bannerFGIsourceOpen_tok"
            value="tokenize(normalize-space(string($bannerFGIsourceOpen)), ' ')"/>
        <sch:let name="bannerFGIsourceProtected_tok"
            value="tokenize(normalize-space(string($bannerFGIsourceProtected)), ' ')"/>
        <sch:let name="bannerReleasableTo_tok"
            value="tokenize(normalize-space(string($bannerReleasableTo)), ' ')"/>
        <sch:let name="bannerSCIcontrols_tok"
            value="tokenize(normalize-space(string($bannerSCIcontrols)), ' ')"/>
        <sch:let name="bannerNotice_tok"
            value="tokenize(normalize-space(string($bannerNotice)), ' ')"/>
        <sch:let name="bannerAtomicEnergyMarkings_tok"
            value="tokenize(normalize-space(string($bannerAtomicEnergyMarkings)), ' ')"/>

        <!-- (U) Get all portions that meet ISM_CONTRIBUTES, or all non-resource nodes that do not specify ism:excludeFromRollup='true' -->
        <!-- (U) Similar portion classifications include ISM_CONTRIBUTES_CLASSIFIED, or all portions meeting ISM_CONTRIBUTES that 
          also have an ism:classification attribute not equal to [U], and ISM_CONTRIBUTES_USA, or all portions meeting ISM_CONTRIBUTES
          that also have an ism:ownerProducer containing [USA]. -->
        <sch:let name="partTags"
            value="/descendant-or-self::node()[@ism:* and util:contributesToRollup(.) and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))]"/>

        <!-- (U) Get Part Attributes -->
        <sch:let name="partClassification"
            value="for $token in $partTags/@ism:classification return tokenize(normalize-space(string($token)),' ')"/>
        <sch:let name="partOwnerProducer"
            value="for $token in $partTags/@ism:ownerProducer return tokenize(normalize-space(string($token)),' ')"/>
        <sch:let name="partDisseminationControls"
            value="for $token in $partTags/@ism:disseminationControls return tokenize(normalize-space(string($token)),' ')"/>
        <sch:let name="partDisplayOnlyTo"
            value="for $token in $partTags/@ism:displayOnlyTo return tokenize(normalize-space(string($token)),' ')"/>
        <sch:let name="partAtomicEnergyMarkings"
            value="for $token in $partTags/@ism:atomicEnergyMarkings return tokenize(normalize-space(string($token)),' ')"/>
        <sch:let name="partNonICmarkings"
            value="for $token in $partTags/@ism:nonICmarkings return tokenize(normalize-space(string($token)),' ')"/>
        <sch:let name="partFGIsourceOpen"
            value="for $token in $partTags/@ism:FGIsourceOpen return tokenize(normalize-space(string($token)),' ')"/>
        <sch:let name="partFGIsourceProtected"
            value="for $token in $partTags/@ism:FGIsourceProtected return tokenize(normalize-space(string($token)),' ')"/>
        <sch:let name="partSCIcontrols"
            value="for $token in $partTags/@ism:SCIcontrols return tokenize(normalize-space(string($token)),' ')"/>
        <sch:let name="partNoticeType"
            value="for $token in $partTags/@ism:noticeType return tokenize(normalize-space(string($token)),' ')"/>

        <sch:let name="partPocType"
            value="for $token in $partTags/@ism:pocType return tokenize(normalize-space(string($token)),' ')"/>

        <!-- (U) Tokenize portion Attributes -->
        <sch:let name="partClassification_tok"
            value="for $token in $partClassification return tokenize(normalize-space(string($token)), ' ')"/>
        <sch:let name="partOwnerProducer_tok"
            value="for $token in $partOwnerProducer return tokenize(normalize-space(string($token)), ' ')"/>
        <sch:let name="partDisseminationControls_tok"
            value="for $token in $partDisseminationControls return tokenize(normalize-space(string($token)), ' ')"/>
        <sch:let name="partDisplayOnlyTo_tok"
            value="for $token in $partDisplayOnlyTo return tokenize(normalize-space(string($token)), ' ')"/>
        <sch:let name="partAtomicEnergyMarkings_tok"
            value="for $token in $partAtomicEnergyMarkings return tokenize(normalize-space(string($token)), ' ')"/>
        <sch:let name="partNonICmarkings_tok"
            value="for $token in $partNonICmarkings return tokenize(normalize-space(string($token)), ' ')"/>
        <sch:let name="partSCIcontrols_tok"
            value="for $token in $partSCIcontrols return tokenize(normalize-space(string($token)), ' ')"/>
        <sch:let name="partNoticeType_tok"
            value="for $token in $partNoticeType return tokenize(normalize-space(string($token)), ' ')"/>
        <sch:let name="partPocType_tok"
            value="for $token in $partPocType return tokenize(normalize-space(string($token)), ' ')"/>

        <!-- (U) Tokenize Notice Nodes -->
        <sch:let name="partNoticeNodeType"
            value="for $token in $partTags/@ism:noticeType return tokenize(normalize-space(string($token)),' ')"/>

        <!-- 
          (U) ISM_NSI_EO_APPLIES (boolean): 
          True if the current Classified National Security Information Executive 
          Order applies to this resource. This variable will be true if all of the following 4 conditions are satisfied:
          1) The document is a ISM_CAPCO_RESOURCE
          AND 
          2) The ISM_RESOURCE_ELEMENT node has attribute ism:classification with a value other than [U]
          AND
          3) The ISM_RESOURCE_CREATE_DATE is on or after 11 April 1996  (180 days after 14 October 1995 signature of E.O. 12958)
          AND
          4) At least one element meeting ISM_CONTRIBUTES_CLASSIFIED does not have the attribute ism:atomicEnergyMarkings 
        -->
        <sch:let name="ISM_NSI_EO_APPLIES"
            value="$ISM_CAPCO_RESOURCE and                     not($ISM_RESOURCE_ELEMENT/@ism:classification='U') and                     $ISM_RESOURCE_CREATE_DATE &gt;= xs:date('1996-04-11') and                     (some $element in $partTags satisfies                             not($element/@ism:classification='U') and not($element/@ism:atomicEnergyMarkings))"/>

        <!-- (U) Define countries that are included in the THREE-, FOUR- and FIVE-EYES designations -->
        <sch:let name="TEYE_tok" value="tokenize(string('USA CAN GBR'), ' ')"/>
        <sch:let name="ACGU_tok" value="tokenize(string('USA AUS CAN GBR'), ' ')"/>
        <sch:let name="FVEY_tok" value="tokenize(string('USA AUS CAN GBR NZL'), ' ')"/>

        <!-- (U) Check roll-up of attributes in portions to the banner   -->
        <sch:let name="dcTags"
            value="for $piece in $disseminationControlsList return $piece/text()"/>
        <sch:let name="dcTagsFound"
            value="for $token in $dcTags return if ( index-of($partDisseminationControls_tok,$token) &gt; 0 and (not(index-of($bannerDisseminationControls_tok,$token) &gt; 0))) then $token else null"/>
        <sch:let name="aeaTags"
            value="for $piece in $atomicEnergyMarkingsList return $piece/text()"/>
        <sch:let name="aeaTagsFound"
            value="for $token in $aeaTags return if ( index-of($partAtomicEnergyMarkings_tok,$token) &gt; 0 and (not(index-of($bannerAtomicEnergyMarkings_tok,$token) &gt; 0))) then $token else null"/>


        <!--****************************-->
        <!-- (U) Custom XSLT functions   -->
        <!--****************************-->

        <!--
    Returns true if the attribute @ism:excludeFromRollup is present and evaluates to 'true'
      -->
        <xsl:function name="util:contributesToRollup" as="xs:boolean">
                <xsl:param name="context"/>
                <xsl:value-of select="not(string($context/@ism:excludeFromRollup)='true')"/>
        </xsl:function>

        <!-- Evaluate the attribute value tokens to determine whether any values 
            have been deprecated by comparing deprecation dates against $curDate. 
            If the value is deprecated, return either an ERROR or WARNING message, 
            depending on the isError flag. -->
        <xsl:function name="dvf:deprecated" as="xs:string*">
                <xsl:param name="attribute" as="xs:string"/>
                <xsl:param name="depTerms" as="element()*"/>
                <xsl:param name="curDate" as="xs:date?"/>
                <xsl:param name="isError" as="xs:boolean"/>
                <!--$curDate param is optional in order to prevent compiled XSLT from breaking 
                    when otherwise invalid documents are executed against the rules 
                    (e.g. missing @ism:createDate). 
                    
                    Only execute if we have a date to compare against. -->
                <xsl:if test="count($curDate)=1">
                        <xsl:for-each select="$depTerms[cve:Value=tokenize($attribute,' ')]">
                                <xsl:if test="($isError and $curDate gt xs:date(@deprecated)) or (not($isError) and $curDate le xs:date(@deprecated))">
                                        <xsl:sequence select="concat('[',string(current()/cve:Value),'] has been deprecated and is not authorized for use after  ', current()/@deprecated)"/>
                                </xsl:if>
                        </xsl:for-each>
                </xsl:if>
        </xsl:function>

        <!--
    Returns true if any token in the attribute value matches one of the provided regular expressions. 
  -->
        <xsl:function name="util:containsAnyTokenMatching" as="xs:boolean">
                <xsl:param name="attribute"/>
                <xsl:param name="regexList" as="xs:string+"/>
                <xsl:value-of select="       some $attrToken in tokenize(normalize-space(string($attribute)), ' ') satisfies         (some $regex in $regexList satisfies           matches($attrToken, $regex))       "/>
        </xsl:function>

        <!--
    Returns true if any token in the attribute value matches at least one token in the provided list.
  -->
        <xsl:function name="util:containsAnyOfTheTokens" as="xs:boolean">
                <xsl:param name="attribute"/>
                <xsl:param name="tokenList" as="xs:string+"/>
                <xsl:value-of select="       some $attrToken in tokenize(normalize-space(string($attribute)), ' ') satisfies         $attrToken = $tokenList       "/>
        </xsl:function>

        <!--
        Determines if values in an attribute are in sorted order based on a master list
    -->
        <xsl:function name="util:unsortedValues" as="xs:string">
                <xsl:param name="attribute"/>
                <xsl:param name="tokenList" as="xs:string+"/>
                <xsl:variable name="attrValues" select="tokenize(normalize-space(string($attribute)), ' ')"/>

                <xsl:variable name="badValues">
                        <xsl:for-each select="$attrValues">
                                <!-- iterate over each attribute value, except the last one because we compare i to i+1 so the last one gets incorporated -->
                                <xsl:if test="not(index-of($attrValues, current())[last()] = count($attrValues))">

                                        <!-- calculate the indicies of attrValues[i] and attrValues[i+1] within the TokenList -->
                                        <xsl:variable name="indexOfValue" select="util:getIndexFromListMatch(current(), $tokenList)"/>
                                        <xsl:variable name="indexOfNextValue"
                             select="util:getIndexFromListMatch($attrValues[index-of($attrValues,current())+1], $tokenList)"/>


                                        <xsl:choose>
                                                <xsl:when test="$indexOfValue = $indexOfNextValue">
                                                  <!-- if same index in tokenList, make sure that attrValues[i] < attrValues[i+1] -->
                                                  <!-- this comparison is required because of regular expressions in the list. Two tokens
                                 may have the same index in the list, but then they must be in order between themselves -->
                                                  <xsl:if test="compare(current(), $attrValues[index-of($attrValues,current())+1]) = 1">
                                                  <xsl:value-of select="$attrValues[index-of($attrValues,current())+1]"/>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="$indexOfValue &gt; $indexOfNextValue">
                                                  <!-- if index of i > index of i+1, then i+1 is out of order so return it -->
                                                  <xsl:value-of select="$attrValues[index-of($attrValues,current())+1]"/>
                                                </xsl:when>
                                        </xsl:choose>
                                </xsl:if>
                        </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="normalize-space(string($badValues))"/>
        </xsl:function>


        <!-- Return the index position in the list that matches the value. -1 if no match -->
        <xsl:function name="util:getIndexFromListMatch" as="xs:integer">
                <xsl:param name="value" as="xs:string"/>
                <xsl:param name="list" as="xs:string+"/>

                <xsl:variable name="index">
                        <xsl:for-each select="$list">
                                <xsl:if test="matches($value,concat('^',current(),'$'))">
                                        <xsl:value-of select="index-of($list,current())[1]"/>
                                </xsl:if>
                        </xsl:for-each>
                </xsl:variable>

                <xsl:choose>
                        <xsl:when test="$index = ''">
                                <xsl:value-of select="-1"/>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:value-of select="number($index[1])"/>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:function>

        <!--
     Returns true if the value match the provided regular expressions. 
   -->
        <xsl:function name="util:meetsType" as="xs:boolean">
                <xsl:param name="value"/>
                <xsl:param name="typePattern" as="xs:string"/>
                <xsl:value-of select="matches(normalize-space(string($value)), concat('^(', $typePattern, ')$'))"/>
   </xsl:function>


    <!-- Functions to support FD&R roll-up constraints -->
    
    <!-- Returns true if the provided tetragraph is an EYES tetragaph (3,4,5-EYES); false otherwise -->
    <xsl:function name="util:isEyesTetragraph" as="xs:boolean">
        <xsl:param name="unknownTetra"/>
        <xsl:value-of select="$unknownTetra = ('FVEY', 'ACGU', 'TEYE')"/>
    </xsl:function>
    
    <!--
    Accepts a list of tokens (trigraphs and tetragraphs)
    Returns the same list of tokens with 3,4,5-EYES decomposed into trigraphs
    Note: this may introduce duplicates (ie, "USA FVEY" will become "USA USA GBR CAN AUS NZL")
    -->
    <xsl:function name="util:decomposeTetragraphs" as="xs:string*">
        <xsl:param name="releasableTo" as="xs:string"/>
        <xsl:value-of select="for $token in tokenize(normalize-space($releasableTo),' ') return             if($token = 'FVEY')             then tokenize('USA GBR CAN AUS NZL', ' ')             else if($token = 'ACGU')             then tokenize('USA GBR CAN AUS', ' ')             else if($token = 'TEYE')             then tokenize('USA GBR CAN', ' ')             else $token"/>
    </xsl:function>
    
    <!-- Returns true if the input contains any tetragraph other than 3,4,5-EYES; false otherwise -->
    <xsl:function name="util:containsSpecialTetra" as="xs:boolean">
        <xsl:param name="releasableTo" as="xs:string"/>
        <xsl:value-of select="some $token in tokenize(normalize-space($releasableTo), ' ') satisfies             string-length($token) = 4 and not(util:isEyesTetragraph($token))"/>
    </xsl:function>
    
    <!-- 
    Accepts a list of tokens (trigraphs and tetragraphs)
    Returns the same list with EYES tokens decomposed into trigraphs and other tetra graphs removed
    Example: "AAA FVEY ABCD" becomes "AAA USA GBR CAN AUS NZL"
    -->
    <xsl:function name="util:extractTrigraphs" as="xs:string*">
        <xsl:param name="toExtractFrom" as="xs:string"/>
        <xsl:value-of select="for $token in tokenize(normalize-space($toExtractFrom), ' ') return             if(string-length($token) = 3)             then $token             else if(util:isEyesTetragraph($token))             then util:decomposeTetragraphs($token)             else ()"/>
    </xsl:function>
    
    <!-- Accepts the banner and portion @ism:releasableTo, decomposes them and   
        Returns true if the banner contains a special tetragraph OR  
        every token in the banner (except USA) is also in the portion; false otherwise -->
    <xsl:function name="util:bannerIsSubset" as="xs:boolean">
        <xsl:param name="bannerRelTo" as="xs:string"/>
        <xsl:param name="portionRelTo" as="xs:string"/>
        <xsl:variable name="bannerRelToDecomposed"
                    select="tokenize(normalize-space(util:decomposeTetragraphs($bannerRelTo)), ' ')"/>
        <xsl:variable name="portionRelToDecomposed"
                    select="tokenize(normalize-space(util:decomposeTetragraphs($portionRelTo)), ' ')"/>
        <xsl:value-of select="util:containsSpecialTetra($bannerRelTo) or             (every $bannerToken in $bannerRelToDecomposed satisfies             (some $portionToken in $portionRelToDecomposed satisfies             if($bannerToken = 'USA')             then true()             else $bannerToken = $portionToken))"/>
    </xsl:function>
    
    <!--
        Accepts an element.
        Returns true if the element contains any Foreign Disclosure & Release (FD&R) markings; false otherwise.
    -->
    <xsl:function name="util:containsFDR" as="xs:boolean">
        <xsl:param name="elementNode" as="node()"/>
        <xsl:value-of select="$elementNode/@ism:releasableTo or             $elementNode/@ism:displayOnlyTo or             util:containsAnyOfTheTokens($elementNode/@ism:disseminationControls, ('NF', 'RELIDO')) or             util:containsAnyOfTheTokens($elementNode/@ism:nonICmarkings, ('LES-NF', 'SBU-NF'))"/>
    </xsl:function>
    
    <!-- Returns all of the tokens (except USA) in the first list that are also in the second list. -->
    <xsl:function name="util:intersectionOfCountries" as="xs:string*">
        <xsl:param name="commonCountries" as="xs:string"/>
        <xsl:param name="portionRelTo" as="xs:string"/>
        <xsl:variable name="portionRelToDecomposed"
                    select="tokenize(normalize-space(util:decomposeTetragraphs($portionRelTo)), ' ')"/>
        <xsl:value-of select="for $token in tokenize(normalize-space($commonCountries), ' ') return             if($token = $portionRelToDecomposed and not($token='USA'))             then $token             else ()"/>
    </xsl:function>
    
    <!-- Recursively iterates over the contributing portions in a document and makes sure that the releasability markings
    are consistent with the banner. Returns the list of common countries if no portion fails constraint checking -->
    <xsl:function name="util:recursivelyCheckRelTo" as="xs:string*">
        <xsl:param name="bannerRelTo" as="xs:string"/>
        <xsl:param name="commonCountries" as="xs:string"/>
        <xsl:param name="remainingPartTags" as="node()*"/>
        
        <xsl:variable name="portion" select="$remainingPartTags[1]"/>
        
        <xsl:choose>
            <xsl:when test="count(tokenize($commonCountries, ' ')) = 0">
                <!-- base case, if commonCountries is the empty set, then there 
                    is no common country to release to and the document is NF -->
                <xsl:value-of select="()"/>
            </xsl:when>
            <xsl:when test="count($remainingPartTags) = 0">
                <!-- base case, no more portions to look at, return commonCountries -->
                <xsl:value-of select="$commonCountries"/>
            </xsl:when>
            <xsl:when test="not(util:containsFDR($portion)) and $portion/@ism:classification='U'">
                <!-- normal unclass portion without FRD markings does not impact releasability, iterate over this portion -->
                <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, $commonCountries, subsequence($remainingPartTags, 2))"/>
            </xsl:when>
            <xsl:when test="not($portion/@ism:releasableTo)">
                <!-- this portion contributes and is not releasable, so it means there are no common countries -->
                <xsl:value-of select="()"/>
            </xsl:when>
            <xsl:when test="util:containsSpecialTetra($portion/@ism:releasableTo)">
                <!-- this portion has special tetras. We cannot handle special tetras, so iterate over this portion -->
                <xsl:value-of select="util:recursivelyCheckRelToRecurseHelper($bannerRelTo, $commonCountries, $remainingPartTags)"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- this portion has no special tetras, check it -->
                <xsl:choose>
                    <xsl:when test="util:bannerIsSubset($bannerRelTo, $portion/@ism:releasableTo)">
                        <!-- banner releasableTo is correctly a subset of this portion releasableTo, iterate to next portion -->
                        <xsl:value-of select="util:recursivelyCheckRelToRecurseHelper($bannerRelTo, $commonCountries, $remainingPartTags)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- banner says releasableTo a country that this portion is not releasableTo, so we know it is wrong -->
                        <xsl:value-of select="('BANNER_NOT_A_SUBSET_OF_A_PORTION')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- convenience function for iterating to the next portion and updating the common countries list -->
    <xsl:function name="util:recursivelyCheckRelToRecurseHelper" as="xs:string*">
        <xsl:param name="bannerRelTo" as="xs:string"/>
        <xsl:param name="commonCountries" as="xs:string"/>
        <xsl:param name="remainingPartTags" as="node()*"/>
        
        <xsl:variable name="portion" select="$remainingPartTags[1]"/>
        
        <xsl:choose>
            <xsl:when test="count($remainingPartTags) = 1">
                <!-- we just checked the last item in the list, give empty list to kill recursion -->
                <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, util:intersectionOfCountries($commonCountries, $portion/@ism:releasableTo), ())"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- remove the first portion in the list (the one we just checked) -->
                <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, util:intersectionOfCountries($commonCountries, $portion/@ism:releasableTo), subsequence($remainingPartTags, 2))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- The function that should be called from schematron rules.
        This function iterates through the portions until it gets to a portion 
        that has @ism:releasableTo and does not contain a special tetra in @ism:releasableTo.
        It uses the countries in @ism:releasableTo from that portion as the initial common 
        countries list for the recursive function. 
    -->
    <xsl:function name="util:checkRelToPortionsAgainstBannerAndGetCommonCountries"
                 as="xs:string*">
        <xsl:param name="bannerRelTo" as="xs:string"/>
        <xsl:param name="remainingPartTags" as="node()*"/>
        
        <xsl:variable name="portion" select="$remainingPartTags[1]"/>
        
        <xsl:choose>
            <xsl:when test="count($remainingPartTags) = 0">
                <!-- no portions provided, so we either: had no portions to begin with OR no portion had a special tetra -->
                <xsl:value-of select="('PASS')"/>
            </xsl:when>
            <xsl:when test="util:containsFDR($portion) and not($portion/@ism:releasableTo)">
                <!-- this portion contributes, contains FD&R markings, and is not releasable so the commonCountry set is empty -->
                <xsl:value-of select="()"/>
            </xsl:when>
            <xsl:when test="$portion/@ism:releasableTo and not(util:containsSpecialTetra($portion/@ism:releasableTo))">
                <!-- first portion with releasableTo that does not have a special tetra; use it to seed common country list -->
                <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, util:decomposeTetragraphs($portion/@ism:releasableTo), $remainingPartTags)"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- remove the first portion in the list (the one we just checked) -->
                <xsl:value-of select="util:checkRelToPortionsAgainstBannerAndGetCommonCountries($bannerRelTo, subsequence($remainingPartTags, 2))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- DISPLAY ONLY TO RULES -->
    
    <!-- Returns the @ism:releasableTo and @ism:displayOnlyTo strings concatenated together -->
    <xsl:function name="util:getDisplayToCountries">
        <xsl:param name="portion" as="node()"/>
        <xsl:value-of select="normalize-space(concat(normalize-space(string($portion/@ism:releasableTo)),             ' ',             normalize-space(string($portion/@ism:displayOnlyTo))))"/>
    </xsl:function>
    
    <!-- Returns true if this element specifies attribute @ism:releasableTo or @ism:displayOnlyTo -->
    <xsl:function name="util:isDisplayable" as="xs:boolean">
        <xsl:param name="portion" as="node()"/>
        <xsl:value-of select="$portion/@ism:releasableTo or $portion/@ism:displayOnlyTo"/>
    </xsl:function>
    
    <!-- Recursively iterates over the contributing portions in a document and makes sure that the displayability markings
    are consistent with the banner. Returns the list of common countries if no portion fails constraint checking -->
    <xsl:function name="util:recursivelyCheckDisplayTo" as="xs:string*">
        <xsl:param name="bannerRelToAndDisplayTo" as="xs:string"/>
        <xsl:param name="commonCountries" as="xs:string"/>
        <xsl:param name="remainingPartTags" as="node()*"/>
        
        <xsl:variable name="portion" select="$remainingPartTags[1]"/>
        
        <xsl:choose>
            <xsl:when test="count(tokenize($commonCountries, ' ')) = 0">
                <!-- base case, if commonCountries is the empty set, then there 
                    is no common country to display to -->
                <xsl:value-of select="()"/>
            </xsl:when>
            <xsl:when test="count($remainingPartTags) = 0">
                <!-- base case, no more portions to look at, return commonCountries -->
                <xsl:value-of select="$commonCountries"/>
            </xsl:when>
            <xsl:when test="not(util:containsFDR($portion)) and $portion/@ism:classification='U'">
                <!-- normal unclass portion without FRD markings does not impact displayability, iterate over this portion -->
                <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelToAndDisplayTo, $commonCountries, subsequence($remainingPartTags, 2))"/>
            </xsl:when>
            <xsl:when test="not($portion/@ism:releasableTo) and not($portion/@ism:displayOnlyTo)">
                <!-- this portion contributes and is not displayable, so it means there are no common countries -->
                <xsl:value-of select="()"/>
            </xsl:when>
            <xsl:when test="util:containsSpecialTetra(util:getDisplayToCountries($portion))">
                <!-- this portion has special tetras. We cannot handle special tetras, so iterate over this portion -->
                <xsl:value-of select="util:recursivelyCheckDisplayToRecurseHelper($bannerRelToAndDisplayTo, $commonCountries, $remainingPartTags)"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- this portion has no special tetras, check it -->
                <xsl:choose>
                    <xsl:when test="util:bannerIsSubset($bannerRelToAndDisplayTo, util:getDisplayToCountries($portion))">
                        <!-- banner displayTo list is correctly a subset of this portion displayTo list, iterate to next portion -->
                        <xsl:value-of select="util:recursivelyCheckDisplayToRecurseHelper($bannerRelToAndDisplayTo, $commonCountries, $remainingPartTags)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- banner says displayTo a country that this portion is not displayable to, so we know it is wrong -->
                        <xsl:value-of select="('BANNER_NOT_A_SUBSET_OF_A_PORTION')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- convenience function for iterating to the next portion and updating the common countries list -->
    <xsl:function name="util:recursivelyCheckDisplayToRecurseHelper" as="xs:string*">
        <xsl:param name="bannerRelToAndDisplayTo" as="xs:string"/>
        <xsl:param name="commonCountries" as="xs:string"/>
        <xsl:param name="remainingPartTags" as="node()*"/>
        
        <xsl:variable name="portion" select="$remainingPartTags[1]"/>
        
        <xsl:choose>
            <xsl:when test="count($remainingPartTags) = 1">
                <!-- we just checked the last item in the list, give empty list to kill recursion -->
                <xsl:value-of select="util:recursivelyCheckDisplayTo($bannerRelToAndDisplayTo, util:intersectionOfCountries($commonCountries, util:getDisplayToCountries($portion)), ())"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- remove the first portion in the list (the one we just checked) -->
                <xsl:value-of select="util:recursivelyCheckDisplayTo($bannerRelToAndDisplayTo, util:intersectionOfCountries($commonCountries, util:getDisplayToCountries($portion)), subsequence($remainingPartTags, 2))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- The function that should be called from schematron rules.
        This function iterates through the portions until it gets to a portion 
        that has @ism:releasableTo and does not contain a special tetra in @ism:releasableTo.
        It uses the countries in @ism:releasableTo from that portion as the initial common 
        countries list for the recursive function. 
    -->
    <xsl:function name="util:checkDisplayToPortionsAgainstBannerAndGetCommonCountries"
                 as="xs:string*">
        <xsl:param name="bannerRelToAndDisplayTo" as="xs:string"/>
        <xsl:param name="remainingPartTags" as="node()*"/>
        
        <xsl:variable name="portion" select="$remainingPartTags[1]"/>
        
        <xsl:choose>
            <xsl:when test="count($remainingPartTags) = 0">
                <!-- no portions provided, so we either: had no portions to begin with OR no portion had a special tetra -->
                <xsl:value-of select="('PASS')"/>
            </xsl:when>
            <xsl:when test="util:containsFDR($portion) and not(util:isDisplayable($portion))">
                <!-- this portion contributes, contains FD&R markings, and is not displayable so the commonCountry set is empty -->
                <xsl:value-of select="()"/>
            </xsl:when>
            <xsl:when test="util:isDisplayable($portion) and not(util:containsSpecialTetra(util:getDisplayToCountries($portion)))">
                <!-- first portion with releasableTo or displayOnlyTo that does not have a special tetra; use it to seed common country list -->
                <xsl:value-of select="util:recursivelyCheckDisplayTo($bannerRelToAndDisplayTo, util:decomposeTetragraphs(util:getDisplayToCountries($portion)), $remainingPartTags)"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- remove the first portion in the list (the one we just checked) and iterate -->
                <xsl:value-of select="util:checkDisplayToPortionsAgainstBannerAndGetCommonCountries($bannerRelToAndDisplayTo, subsequence($remainingPartTags, 2))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <!--****************************-->
<!-- (U) ISM ID Rules -->
<!--****************************-->

<!--(U) ACCM-->
   <sch:include href="./Rules/ACCM/ISM_ID_00220.sch"/>

   <!--(U) atomicEnergyMarkings-->
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00173.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00174.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00175.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00176.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00178.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00181.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00182.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00183.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00184.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00185.sch"/>

   <!--(U) classification-->
   <sch:include href="./Rules/classification/ISM_ID_00015.sch"/>
   <sch:include href="./Rules/classification/ISM_ID_00016.sch"/>
   <sch:include href="./Rules/classification/ISM_ID_00040.sch"/>
   <sch:include href="./Rules/classification/ISM_ID_00115.sch"/>
   <sch:include href="./Rules/classification/ISM_ID_00142.sch"/>

   <!--(U) classifiedBy-->
   <sch:include href="./Rules/classifiedBy/ISM_ID_00017.sch"/>

   <!--(U) compliesWith-->
   <sch:include href="./Rules/compliesWith/ISM_ID_00222.sch"/>

   <!--(U) declassException-->
   <sch:include href="./Rules/declassException/ISM_ID_00003.sch"/>
   <sch:include href="./Rules/declassException/ISM_ID_00023.sch"/>
   <sch:include href="./Rules/declassException/ISM_ID_00133.sch"/>
   <sch:include href="./Rules/declassException/ISM_ID_00299.sch"/>

   <!--(U) DeclassManualReview-->
   <sch:include href="./Rules/DeclassManualReview/ISM_ID_00101.sch"/>

   <!--(U) derivativelyClassifiedBy-->
   <sch:include href="./Rules/derivativelyClassifiedBy/ISM_ID_00143.sch"/>
   <sch:include href="./Rules/derivativelyClassifiedBy/ISM_ID_00221.sch"/>

   <!--(U) displayOnlyTo-->
   <sch:include href="./Rules/displayOnlyTo/ISM_ID_00167.sch"/>
   <sch:include href="./Rules/displayOnlyTo/ISM_ID_00168.sch"/>

   <!--(U) disseminationControls-->
   <sch:include href="./Rules/disseminationControls/ISM_ID_00004.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00026.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00027.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00028.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00029.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00030.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00031.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00033.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00034.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00050.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00052.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00053.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00054.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00091.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00092.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00093.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00094.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00106.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00107.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00117.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00120.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00124.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00140.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00164.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00169.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00213.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00215.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00302.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_10001.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_10002.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_10003.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_10004.sch"/>

   <!--(U) FGIsourceOpen-->
   <sch:include href="./Rules/FGIsourceOpen/ISM_ID_00005.sch"/>
   <sch:include href="./Rules/FGIsourceOpen/ISM_ID_00024.sch"/>
   <sch:include href="./Rules/FGIsourceOpen/ISM_ID_00095.sch"/>
   <sch:include href="./Rules/FGIsourceOpen/ISM_ID_00216.sch"/>
   <sch:include href="./Rules/FGIsourceOpen/ISM_ID_00232.sch"/>
   <sch:include href="./Rules/FGIsourceOpen/ISM_ID_00233.sch"/>

   <!--(U) FGIsourceProtected-->
   <sch:include href="./Rules/FGIsourceProtected/ISM_ID_00006.sch"/>
   <sch:include href="./Rules/FGIsourceProtected/ISM_ID_00025.sch"/>
   <sch:include href="./Rules/FGIsourceProtected/ISM_ID_00096.sch"/>
   <sch:include href="./Rules/FGIsourceProtected/ISM_ID_00097.sch"/>
   <sch:include href="./Rules/FGIsourceProtected/ISM_ID_00217.sch"/>
   <sch:include href="./Rules/FGIsourceProtected/ISM_ID_00218.sch"/>
   <sch:include href="./Rules/FGIsourceProtected/ISM_ID_00234.sch"/>
   <sch:include href="./Rules/FGIsourceProtected/ISM_ID_00235.sch"/>

   <!--(U) generalConstraints-->
   <sch:include href="./Rules/generalConstraints/ISM_ID_00002.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00012.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00098.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00102.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00103.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00119.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00125.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00126.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00166.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00170.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00179.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00180.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00188.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00189.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00190.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00191.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00192.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00193.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00194.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00195.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00196.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00197.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00198.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00199.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00200.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00201.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00202.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00203.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00204.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00205.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00206.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00207.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00208.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00209.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00210.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00211.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00212.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00223.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00226.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00236.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00300.sch"/>

   <!--(U) nonICmarkings-->
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00007.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00035.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00036.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00037.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00038.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00051.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00055.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00148.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00225.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00252.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00313.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00314.sch"/>

   <!--(U) nonUSControls-->
   <sch:include href="./Rules/nonUSControls/ISM_ID_00163.sch"/>

   <!--(U) notice-->
   <sch:include href="./Rules/notice/ISM_ID_00127.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00128.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00129.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00130.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00131.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00134.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00135.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00136.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00137.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00138.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00139.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00150.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00151.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00152.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00153.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00156.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00157.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00158.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00159.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00160.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00161.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00237.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00238.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00239.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00240.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00244.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00245.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00248.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00249.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00250.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00251.sch"/>

   <!--(U) ownerProducer-->
   <sch:include href="./Rules/ownerProducer/ISM_ID_00001.sch"/>
   <sch:include href="./Rules/ownerProducer/ISM_ID_00008.sch"/>
   <sch:include href="./Rules/ownerProducer/ISM_ID_00039.sch"/>
   <sch:include href="./Rules/ownerProducer/ISM_ID_00099.sch"/>
   <sch:include href="./Rules/ownerProducer/ISM_ID_00100.sch"/>
   <sch:include href="./Rules/ownerProducer/ISM_ID_00219.sch"/>
   <sch:include href="./Rules/ownerProducer/ISM_ID_00315.sch"/>

   <!--(U) pocType-->
   <sch:include href="./Rules/pocType/ISM_ID_00224.sch"/>
   <sch:include href="./Rules/pocType/ISM_ID_00247.sch"/>

   <!--(U) releasableTo-->
   <sch:include href="./Rules/releasableTo/ISM_ID_00009.sch"/>
   <sch:include href="./Rules/releasableTo/ISM_ID_00032.sch"/>
   <sch:include href="./Rules/releasableTo/ISM_ID_00041.sch"/>
   <sch:include href="./Rules/releasableTo/ISM_ID_00214.sch"/>

   <!--(U) resourceElement-->
   <sch:include href="./Rules/resourceElement/ISM_ID_00013.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00014.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00056.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00057.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00058.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00059.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00060.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00061.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00062.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00063.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00064.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00065.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00066.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00067.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00068.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00069.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00070.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00071.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00072.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00073.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00074.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00075.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00076.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00077.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00078.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00079.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00080.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00081.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00082.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00083.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00084.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00085.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00086.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00087.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00088.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00089.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00090.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00104.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00105.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00108.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00109.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00110.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00111.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00112.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00113.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00116.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00118.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00132.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00141.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00144.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00145.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00146.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00147.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00149.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00154.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00155.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00162.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00165.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00171.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00172.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00227.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00228.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00229.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00230.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00231.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00246.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00298.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00303.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00312.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00316.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00317.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00318.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00319.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00320.sch"/>

   <!--(U) SARIdentifier-->
   <sch:include href="./Rules/SARIdentifier/ISM_ID_00114.sch"/>
   <sch:include href="./Rules/SARIdentifier/ISM_ID_00121.sch"/>

   <!--(U) SCIcontrols-->
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00010.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00042.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00043.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00044.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00045.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00046.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00047.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00048.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00049.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00122.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00123.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00177.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00186.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00187.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00241.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00242.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00243.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00301.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00304.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00305.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00306.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00307.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00308.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00309.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00310.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00311.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_10005.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_10006.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_10007.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_10008.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_10009.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_10010.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_10011.sch"/>

   <!--(U) typeConstraintPatterns-->
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00268.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00269.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00270.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00271.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00272.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00273.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00274.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00275.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00276.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00277.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00278.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00279.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00280.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00281.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00282.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00283.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00284.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00285.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00286.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00287.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00288.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00289.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00290.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00291.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00292.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00293.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00294.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00295.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00296.sch"/>
   <sch:include href="./Rules/typeConstraintPatterns/ISM_ID_00297.sch"/>

   <!--(U) typeOfExemptedSource-->
   <sch:include href="./Rules/typeOfExemptedSource/ISM_ID_00011.sch"/>
   <sch:include href="./Rules/typeOfExemptedSource/ISM_ID_00018.sch"/>
   <sch:include href="./Rules/typeOfExemptedSource/ISM_ID_00019.sch"/>
   <sch:include href="./Rules/typeOfExemptedSource/ISM_ID_00020.sch"/>
   <sch:include href="./Rules/typeOfExemptedSource/ISM_ID_00021.sch"/>
   <sch:include href="./Rules/typeOfExemptedSource/ISM_ID_00022.sch"/>

   <!--(U) valueEnumerationConstraints-->
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00253.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00254.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00255.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00256.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00257.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00258.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00259.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00260.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00261.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00262.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00263.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00264.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00265.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00266.sch"/>
   <sch:include href="./Rules/valueEnumerationConstraints/ISM_ID_00267.sch"/>
</sch:schema>
<!-- UNCLASSIFIED -->