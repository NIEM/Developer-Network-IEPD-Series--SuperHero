<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:ism="urn:us:gov:ic:ism"
                xmlns:cve="urn:us:gov:ic:cve"
                xmlns:dvf="deprecated:value:function"
                xmlns:util="urn:us:gov:ic:ism:xsl:util"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->
<xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="util:contributesToRollup"
                 as="xs:boolean">
                <xsl:param name="context"/>
                <xsl:value-of select="not(string($context/@ism:excludeFromRollup)='true')"/>
        </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="dvf:deprecated"
                 as="xs:string*">
                <xsl:param name="attribute" as="xs:string"/>
                <xsl:param name="depTerms" as="element()*"/>
                <xsl:param name="curDate" as="xs:date?"/>
                <xsl:param name="isError" as="xs:boolean"/>
                
                <xsl:if test="count($curDate)=1">
                        <xsl:for-each select="$depTerms[cve:Value=tokenize($attribute,' ')]">
                                <xsl:if test="($isError and $curDate gt xs:date(@deprecated)) or (not($isError) and $curDate le xs:date(@deprecated))">
                                        <xsl:sequence select="concat('[',string(current()/cve:Value),'] has been deprecated and is not authorized for use after  ', current()/@deprecated)"/>
                                </xsl:if>
                        </xsl:for-each>
                </xsl:if>
        </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:containsAnyTokenMatching"
                 as="xs:boolean">
                <xsl:param name="attribute"/>
                <xsl:param name="regexList" as="xs:string+"/>
                <xsl:value-of select="       some $attrToken in tokenize(normalize-space(string($attribute)), ' ') satisfies         (some $regex in $regexList satisfies           matches($attrToken, $regex))       "/>
        </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:containsAnyOfTheTokens"
                 as="xs:boolean">
                <xsl:param name="attribute"/>
                <xsl:param name="tokenList" as="xs:string+"/>
                <xsl:value-of select="       some $attrToken in tokenize(normalize-space(string($attribute)), ' ') satisfies         $attrToken = $tokenList       "/>
        </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="util:unsortedValues"
                 as="xs:string">
                <xsl:param name="attribute"/>
                <xsl:param name="tokenList" as="xs:string+"/>
                <xsl:variable name="attrValues" select="tokenize(normalize-space(string($attribute)), ' ')"/>

                <xsl:variable name="badValues">
                        <xsl:for-each select="$attrValues">
                                
                                <xsl:if test="not(index-of($attrValues, current())[last()] = count($attrValues))">

                                        
                                        <xsl:variable name="indexOfValue" select="util:getIndexFromListMatch(current(), $tokenList)"/>
                                        <xsl:variable name="indexOfNextValue"
                             select="util:getIndexFromListMatch($attrValues[index-of($attrValues,current())+1], $tokenList)"/>


                                        <xsl:choose>
                                                <xsl:when test="$indexOfValue = $indexOfNextValue">
                                                  
                                                  
                                                  <xsl:if test="compare(current(), $attrValues[index-of($attrValues,current())+1]) = 1">
                                                  <xsl:value-of select="$attrValues[index-of($attrValues,current())+1]"/>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="$indexOfValue &gt; $indexOfNextValue">
                                                  
                                                  <xsl:value-of select="$attrValues[index-of($attrValues,current())+1]"/>
                                                </xsl:when>
                                        </xsl:choose>
                                </xsl:if>
                        </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="normalize-space(string($badValues))"/>
        </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getIndexFromListMatch"
                 as="xs:integer">
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
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="util:meetsType"
                 as="xs:boolean">
                <xsl:param name="value"/>
                <xsl:param name="typePattern" as="xs:string"/>
                <xsl:value-of select="matches(normalize-space(string($value)), concat('^(', $typePattern, ')$'))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="util:isEyesTetragraph"
                 as="xs:boolean">
        <xsl:param name="unknownTetra"/>
        <xsl:value-of select="$unknownTetra = ('FVEY', 'ACGU', 'TEYE')"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="util:decomposeTetragraphs"
                 as="xs:string*">
        <xsl:param name="releasableTo" as="xs:string"/>
        <xsl:value-of select="for $token in tokenize(normalize-space($releasableTo),' ') return             if($token = 'FVEY')             then tokenize('USA GBR CAN AUS NZL', ' ')             else if($token = 'ACGU')             then tokenize('USA GBR CAN AUS', ' ')             else if($token = 'TEYE')             then tokenize('USA GBR CAN', ' ')             else $token"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="util:containsSpecialTetra"
                 as="xs:boolean">
        <xsl:param name="releasableTo" as="xs:string"/>
        <xsl:value-of select="some $token in tokenize(normalize-space($releasableTo), ' ') satisfies             string-length($token) = 4 and not(util:isEyesTetragraph($token))"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="util:extractTrigraphs"
                 as="xs:string*">
        <xsl:param name="toExtractFrom" as="xs:string"/>
        <xsl:value-of select="for $token in tokenize(normalize-space($toExtractFrom), ' ') return             if(string-length($token) = 3)             then $token             else if(util:isEyesTetragraph($token))             then util:decomposeTetragraphs($token)             else ()"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="util:bannerIsSubset"
                 as="xs:boolean">
        <xsl:param name="bannerRelTo" as="xs:string"/>
        <xsl:param name="portionRelTo" as="xs:string"/>
        <xsl:variable name="bannerRelToDecomposed"
                    select="tokenize(normalize-space(util:decomposeTetragraphs($bannerRelTo)), ' ')"/>
        <xsl:variable name="portionRelToDecomposed"
                    select="tokenize(normalize-space(util:decomposeTetragraphs($portionRelTo)), ' ')"/>
        <xsl:value-of select="util:containsSpecialTetra($bannerRelTo) or             (every $bannerToken in $bannerRelToDecomposed satisfies             (some $portionToken in $portionRelToDecomposed satisfies             if($bannerToken = 'USA')             then true()             else $bannerToken = $portionToken))"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="util:containsFDR"
                 as="xs:boolean">
        <xsl:param name="elementNode" as="node()"/>
        <xsl:value-of select="$elementNode/@ism:releasableTo or             $elementNode/@ism:displayOnlyTo or             util:containsAnyOfTheTokens($elementNode/@ism:disseminationControls, ('NF', 'RELIDO')) or             util:containsAnyOfTheTokens($elementNode/@ism:nonICmarkings, ('LES-NF', 'SBU-NF'))"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:intersectionOfCountries"
                 as="xs:string*">
        <xsl:param name="commonCountries" as="xs:string"/>
        <xsl:param name="portionRelTo" as="xs:string"/>
        <xsl:variable name="portionRelToDecomposed"
                    select="tokenize(normalize-space(util:decomposeTetragraphs($portionRelTo)), ' ')"/>
        <xsl:value-of select="for $token in tokenize(normalize-space($commonCountries), ' ') return             if($token = $portionRelToDecomposed and not($token='USA'))             then $token             else ()"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:recursivelyCheckRelTo"
                 as="xs:string*">
        <xsl:param name="bannerRelTo" as="xs:string"/>
        <xsl:param name="commonCountries" as="xs:string"/>
        <xsl:param name="remainingPartTags" as="node()*"/>
        
        <xsl:variable name="portion" select="$remainingPartTags[1]"/>
        
        <xsl:choose>
            <xsl:when test="count(tokenize($commonCountries, ' ')) = 0">
                
                <xsl:value-of select="()"/>
            </xsl:when>
            <xsl:when test="count($remainingPartTags) = 0">
                
                <xsl:value-of select="$commonCountries"/>
            </xsl:when>
            <xsl:when test="not(util:containsFDR($portion)) and $portion/@ism:classification='U'">
                
                <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, $commonCountries, subsequence($remainingPartTags, 2))"/>
            </xsl:when>
            <xsl:when test="not($portion/@ism:releasableTo)">
                
                <xsl:value-of select="()"/>
            </xsl:when>
            <xsl:when test="util:containsSpecialTetra($portion/@ism:releasableTo)">
                
                <xsl:value-of select="util:recursivelyCheckRelToRecurseHelper($bannerRelTo, $commonCountries, $remainingPartTags)"/>
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:choose>
                    <xsl:when test="util:bannerIsSubset($bannerRelTo, $portion/@ism:releasableTo)">
                        
                        <xsl:value-of select="util:recursivelyCheckRelToRecurseHelper($bannerRelTo, $commonCountries, $remainingPartTags)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        
                        <xsl:value-of select="('BANNER_NOT_A_SUBSET_OF_A_PORTION')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:recursivelyCheckRelToRecurseHelper"
                 as="xs:string*">
        <xsl:param name="bannerRelTo" as="xs:string"/>
        <xsl:param name="commonCountries" as="xs:string"/>
        <xsl:param name="remainingPartTags" as="node()*"/>
        
        <xsl:variable name="portion" select="$remainingPartTags[1]"/>
        
        <xsl:choose>
            <xsl:when test="count($remainingPartTags) = 1">
                
                <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, util:intersectionOfCountries($commonCountries, $portion/@ism:releasableTo), ())"/>
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, util:intersectionOfCountries($commonCountries, $portion/@ism:releasableTo), subsequence($remainingPartTags, 2))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:checkRelToPortionsAgainstBannerAndGetCommonCountries"
                 as="xs:string*">
        <xsl:param name="bannerRelTo" as="xs:string"/>
        <xsl:param name="remainingPartTags" as="node()*"/>
        
        <xsl:variable name="portion" select="$remainingPartTags[1]"/>
        
        <xsl:choose>
            <xsl:when test="count($remainingPartTags) = 0">
                
                <xsl:value-of select="('PASS')"/>
            </xsl:when>
            <xsl:when test="util:containsFDR($portion) and not($portion/@ism:releasableTo)">
                
                <xsl:value-of select="()"/>
            </xsl:when>
            <xsl:when test="$portion/@ism:releasableTo and not(util:containsSpecialTetra($portion/@ism:releasableTo))">
                
                <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, util:decomposeTetragraphs($portion/@ism:releasableTo), $remainingPartTags)"/>
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:value-of select="util:checkRelToPortionsAgainstBannerAndGetCommonCountries($bannerRelTo, subsequence($remainingPartTags, 2))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getDisplayToCountries">
        <xsl:param name="portion" as="node()"/>
        <xsl:value-of select="normalize-space(concat(normalize-space(string($portion/@ism:releasableTo)),             ' ',             normalize-space(string($portion/@ism:displayOnlyTo))))"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="util:isDisplayable"
                 as="xs:boolean">
        <xsl:param name="portion" as="node()"/>
        <xsl:value-of select="$portion/@ism:releasableTo or $portion/@ism:displayOnlyTo"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:recursivelyCheckDisplayTo"
                 as="xs:string*">
        <xsl:param name="bannerRelToAndDisplayTo" as="xs:string"/>
        <xsl:param name="commonCountries" as="xs:string"/>
        <xsl:param name="remainingPartTags" as="node()*"/>
        
        <xsl:variable name="portion" select="$remainingPartTags[1]"/>
        
        <xsl:choose>
            <xsl:when test="count(tokenize($commonCountries, ' ')) = 0">
                
                <xsl:value-of select="()"/>
            </xsl:when>
            <xsl:when test="count($remainingPartTags) = 0">
                
                <xsl:value-of select="$commonCountries"/>
            </xsl:when>
            <xsl:when test="not(util:containsFDR($portion)) and $portion/@ism:classification='U'">
                
                <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelToAndDisplayTo, $commonCountries, subsequence($remainingPartTags, 2))"/>
            </xsl:when>
            <xsl:when test="not($portion/@ism:releasableTo) and not($portion/@ism:displayOnlyTo)">
                
                <xsl:value-of select="()"/>
            </xsl:when>
            <xsl:when test="util:containsSpecialTetra(util:getDisplayToCountries($portion))">
                
                <xsl:value-of select="util:recursivelyCheckDisplayToRecurseHelper($bannerRelToAndDisplayTo, $commonCountries, $remainingPartTags)"/>
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:choose>
                    <xsl:when test="util:bannerIsSubset($bannerRelToAndDisplayTo, util:getDisplayToCountries($portion))">
                        
                        <xsl:value-of select="util:recursivelyCheckDisplayToRecurseHelper($bannerRelToAndDisplayTo, $commonCountries, $remainingPartTags)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        
                        <xsl:value-of select="('BANNER_NOT_A_SUBSET_OF_A_PORTION')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:recursivelyCheckDisplayToRecurseHelper"
                 as="xs:string*">
        <xsl:param name="bannerRelToAndDisplayTo" as="xs:string"/>
        <xsl:param name="commonCountries" as="xs:string"/>
        <xsl:param name="remainingPartTags" as="node()*"/>
        
        <xsl:variable name="portion" select="$remainingPartTags[1]"/>
        
        <xsl:choose>
            <xsl:when test="count($remainingPartTags) = 1">
                
                <xsl:value-of select="util:recursivelyCheckDisplayTo($bannerRelToAndDisplayTo, util:intersectionOfCountries($commonCountries, util:getDisplayToCountries($portion)), ())"/>
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:value-of select="util:recursivelyCheckDisplayTo($bannerRelToAndDisplayTo, util:intersectionOfCountries($commonCountries, util:getDisplayToCountries($portion)), subsequence($remainingPartTags, 2))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:checkDisplayToPortionsAgainstBannerAndGetCommonCountries"
                 as="xs:string*">
        <xsl:param name="bannerRelToAndDisplayTo" as="xs:string"/>
        <xsl:param name="remainingPartTags" as="node()*"/>
        
        <xsl:variable name="portion" select="$remainingPartTags[1]"/>
        
        <xsl:choose>
            <xsl:when test="count($remainingPartTags) = 0">
                
                <xsl:value-of select="('PASS')"/>
            </xsl:when>
            <xsl:when test="util:containsFDR($portion) and not(util:isDisplayable($portion))">
                
                <xsl:value-of select="()"/>
            </xsl:when>
            <xsl:when test="util:isDisplayable($portion) and not(util:containsSpecialTetra(util:getDisplayToCountries($portion)))">
                
                <xsl:value-of select="util:recursivelyCheckDisplayTo($bannerRelToAndDisplayTo, util:decomposeTetragraphs(util:getDisplayToCountries($portion)), $remainingPartTags)"/>
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:value-of select="util:checkDisplayToPortionsAgainstBannerAndGetCommonCountries($bannerRelToAndDisplayTo, subsequence($remainingPartTags, 2))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="" schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:text>This is the root file for the ISM Schematron rule set. It loads all of
                the required CVEs declares some variables and includes all of the Rule .sch files. </svrl:text>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism" prefix="ism"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:cve" prefix="cve"/>
         <svrl:ns-prefix-in-attribute-values uri="deprecated:value:function" prefix="dvf"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism:xsl:util" prefix="util"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">typeConstraintPatterns</xsl:attribute>
            <xsl:attribute name="name">typeConstraintPatterns</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M5"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00220</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00220</xsl:attribute>
            <svrl:text>
        [ISM-ID-00220][Error] Rule removed in V7.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M104"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00173</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00173</xsl:attribute>
            <svrl:text>
        [ISM-ID-00173][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains a name token starting with 
        [RD-SG] or [FRD-SG], then attribute classification must 
        have a value of [TS], [S], or [C].
        
        Human Readable: Portions in a USA document that contain RD or FRD SIGMA 
        data must be marked CONFIDENTIAL, SECRET, or TOP SECRET.
    </svrl:text>
            <svrl:text>
		If the document is an ISM-CAPCO-RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing 
		a token starting with [RD-SG] or [FRD-SG], we make sure that the attribute 
		ism:classification has a value of [TS], [S], or [C].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M105"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00174</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00174</xsl:attribute>
            <svrl:text>
        [ISM-ID-00174][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD], [FRD], or [TFNI], 
        then attribute classification must have a value of [TS], [S], or [C].
        
        Human Readable: USA documents with RD, FRD, or TFNI data must be marked CONFIDENTIAL,
        SECRET, or TOP SECRET.
    </svrl:text>
            <svrl:text>
		If the document is an ISM-CAPCO-RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing 
		the token [RD], [FRD], or [TFNI], we make sure that the attribute 
		ism:classification has a value of [TS], [S], or [C].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M106"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00175</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00175</xsl:attribute>
            <svrl:text>
        [ISM-ID-00175][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD-CNWDI], then attribute 
        classification must have a value of [TS] or [S].
    </svrl:text>
            <svrl:text>
		If the document is an ISM-CAPCO-RESORUCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing 
		the token [RD-CNWDI], we make sure that the attribute ism:classification
		has a value of [TS] or [S].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M107"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00176</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00176</xsl:attribute>
            <svrl:text>
        [ISM-ID-00176][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings has a name token containing [RD] or [FRD], 
        then attributes declassDate and declassEvent cannot be specified
        on the resourceElement.
        
        Human Readable: Automatic declassification of documents containing 
        RD or FRD information is prohibited. Attributes declassDate and 
        declassEvent cannot be used in the classification authority block when 
        RD or FRD is present.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which 
    	has attribute ism:atomicEnergyMarkings specified with a value containing
    	the token [RD] or [FRD], we make sure that the resourceElement does not
    	have attributes ism:declassDate or ism:declassEvent specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M108"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00178</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00178</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M109"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00181</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00181</xsl:attribute>
            <svrl:text>
        [ISM-ID-00181][Error] If ISM_CAPCO_RESOURCE and element's 
        classification does not have a value of "U" then attribute atomicEnergyMarkings must not 
        contain the name token [UCNI] or [DCNI].
        
        Human Readable: UCNI and DCNI may only be used on UNCLASSIFIED portions.
    </svrl:text>
            <svrl:text>
		If the document is an ISM-CAPCO-RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified and has attribute 
		ism:classification specified with a value other than [U], we 
		make sure that attribute ism:atomicEnergyMarkings does not contain the 
		token [UCNI] or [DNCI].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M110"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00182</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00182</xsl:attribute>
            <svrl:text>
        [ISM-ID-00182][Error] Rule removed in V8. Values moved to rule 181.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M111"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00183</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00183</xsl:attribute>
            <svrl:text>
        [ISM-ID-00183][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains a name token starting with [RD-SG],
        then it must also contain the name token [RD].
    </svrl:text>
            <svrl:text>
		If the document is an ISM-CAPCO-RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing a 
		token starting with [RD-SG], we make sure that attribute 
		ism:atomicEnergyMarkings also contains the token [RD].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M112"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00184</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00184</xsl:attribute>
            <svrl:text>
        [ISM-ID-00184][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains a name token starting with [FRD-SG],
        then it must also contain the name token [FRD].
    </svrl:text>
            <svrl:text>
		If the document is an ISM-CAPCO-RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing a 
		token starting with [FRD-SG], we make sure that attribute 
		ism:atomicEnergyMarkings also contains the token [FRD].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M113"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00185</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00185</xsl:attribute>
            <svrl:text>
        [ISM-ID-00185][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD-CNWDI],
        then it must also contain the name token [RD].
    </svrl:text>
            <svrl:text>
		If the document is an ISM-CAPCO-RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing 
		the token [RD-CNWDI], we make sure that attribute 
		ism:atomicEnergyMarkings also contains the token [RD].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M114"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00015</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00015</xsl:attribute>
            <svrl:text>
        [ISM-ID-00015][Error] Rule removed in V8. Values moved to rule 16.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M115"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00016</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00016</xsl:attribute>
            <svrl:text>
        [ISM-ID-00016][Error] If ISM_CAPCO_RESOURCE and attribute 
        classification has a value of [U], then attributes classificationReason,
        classifiedBy, derivativelyClassifiedBy, declassDate, declassEvent, 
        declassException, derivedFrom, SARIdentifier, or 
        SCIcontrols must not be specified.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:classification specified with a value of [U] we make
    	sure that NONE of the following attributes are specified:
    	ism:classifiedBy, ism:declassDate, ism:declassEvent, ism:declassException,
    	ism:derivativelyClassifiedBy, ism:derivedFrom, 
    	ism:SARIdentifier, or ism:SCIcontrols. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M116"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00040</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00040</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M117"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00115</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00115</xsl:attribute>
            <svrl:text>
        [ISM-ID-00115][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M118"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00142</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00142</xsl:attribute>
            <svrl:text>
        [ISM-ID-00142][Error] If ISM_NSI_EO_APPLIES and attribute classification
        has a value other than [U], then attribute classifiedBy or 
        derivativelyClassifiedBy must be specified on the ISM_RESOURCE_ELEMENT.
        
        Human Readable: Classified data including DOE data requires either an 
        original classifier or a derivative classifier be identified.
    </svrl:text>
            <svrl:text>
    	If ISM_NSI_EO_APPLIES, for each element which specified attribute
    	ism:classification with a value other than [U], we make sure that
    	the ISM_RESOURCE_ELEMENT specifies attribute ism:classifiedBy or 
    	ism:derivativelyClassifiedBy.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M119"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00017</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00017</xsl:attribute>
            <svrl:text>
        [ISM-ID-00017][Error] If ISM_NSI_EO_APPLIES and attribute 
        classifiedBy is specified, then attribute classificationReason must 
        be specified. 
        
        Human Readable: Documents under E.O. 13526 containing 
        Originally Classified data require a classification reason to be
        identified.
    </svrl:text>
            <svrl:text>
    	If ISM_NSI_EO_APPLIES, for each element which specifies attribute
    	ism:classifiedBy we make sure that attribute ism:classificationReason
    	is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M120"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00222</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00222</xsl:attribute>
            <svrl:text>
        [ISM-ID-00222][Error] If ISM_INTELREPORT_APPLIES, then attribute pocType
        must be specified with a value of [ICD-710] on some element in the
        document.
        
        Human Readable: A document claiming compliance with ICD-710 must specify
        a point-of-contact to whom questions about the document can be directed.
    </svrl:text>
            <svrl:text>
        If ISM_INTELREPORT_APPLIES, then ensure that some element specifies 
        attribute ism:pocType with a value of [ICD-710].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M121"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00003</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00003</xsl:attribute>
            <svrl:text>
        [ISM-ID-00003][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M122"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00023</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00023</xsl:attribute>
            <svrl:text>
        [ISM-ID-00023][Error] Rule removed in V4.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M123"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00133</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00133</xsl:attribute>
            <svrl:text>
        [ISM-ID-00133][Error] If ISM_NSI_EO_APPLIES and attribute 
        declassException is specified and contains the tokens 
        [50X1-HUM], or [50X2-WMD], then attribute declassDate or declassEvent must NOT be specified.
        
        Human Readable: Documents under E.O. 13526 must not specify declassDate or declassEvent if 
        a declassException of 50X1-HUM or 50X2-WMD is specified.
    </svrl:text>
            <svrl:text>
    	If ISM_NSI_EO_APPLIES, for each element which specifies 
    	ism:declassException with a value containing token 
    	[50X1-HUM], or [50X2-WMD] we make sure that attributes ism:declassDate
    	and ism:declassEvent are NOT specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M124"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00299</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00299</xsl:attribute>
            <svrl:text>
        [ISM-ID-00299][Error] If an element contains the attribute declassException with a value of [AEA], 
        it must also contain the attribute atomicEnergyMarkings.
    </svrl:text>
            <svrl:text>
		If an element contains an ism:declassException attribute with a value containing
		AEA, we must check to make sure that element also has an ism:atomicEnergyMarkings
		attribute.
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M125"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00101</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00101</xsl:attribute>
            <svrl:text>
        [ISM-ID-000101][Error] Introduced and removed in V2. Never made it to signed package.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M126"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00143</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00143</xsl:attribute>
            <svrl:text>
        [ISM-ID-00143][Error] If ISM_CAPCO_RESOURCE and attribute 
        derivativelyClassifiedBy is specified, then attribute derivedFrom must
        be specified. 
        
        Human Readable: Derivatively Classified data including DOE data requires
        a derived from value to be identified.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which 
    	specifies attribute ism:derivativelyClassifiedBy we make sure that
    	attribute ism:derivedFrom is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M127"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00221</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00221</xsl:attribute>
            <svrl:text>
        [ISM-ID-00221][Error] If ISM_CAPCO_RESOURCE and attribute 
        derivativelyClassifiedBy is specified, then attribute classificationReason
        must not be specified.
        
        Human Readable: USA documents that are derivatively classified must not
        specify a classification reason.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which 
    	specifies attribute ism:derivativelyClassifiedBy we make sure that
    	attribute ism:classificationReason is NOT specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M128"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00167</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00167</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M129"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00168</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00168</xsl:attribute>
            <svrl:text>
        [ISM-ID-00168][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls is not specified or is specified and does not contain the name token 
        [DISPLAYONLY], then attribute displayOnlyTo must not be specified.
        
        Human Readable: If a portion in a USA document is not marked for DISPLAY ONLY dissemination, 
        it must not list countries to which it may be disclosed. 
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE and attribute ism:disseminationControls
      	does not contain the token [DISPLAYONLY], we make sure that the attribute 
      	ism:displayOnlyTo is not specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M130"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00004</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00004</xsl:attribute>
            <svrl:text>
        [ISM-ID-00004][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M131"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00026</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00026</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M132"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00027</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00027</xsl:attribute>
            <svrl:text>
        [ISM-ID-00027][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M133"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00028</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00028</xsl:attribute>
            <svrl:text>
      [ISM-ID-00028][Error] If ISM_CAPCO_RESOURCE and attribute 
      disseminationControls contains the name token [OC] or [EYES],
      then attribute classification must have a value of [TS], [S], or [C].
      
      Human Readable: Portions marked for ORCON or EYES ONLY dissemination 
      in a USA document must be CONFIDENTIAL, SECRET, or TOP SECRET.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [OC] or [EYES] we make sure that attribute
    	ism:classification is specified with a value of [C], [S], or [TS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M134"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00029</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00029</xsl:attribute>
            <svrl:text>
        [ISM-ID-00029][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M135"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00030</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00030</xsl:attribute>
            <svrl:text>
        [ISM-ID-00030][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [FOUO], then attribute
        classification must have a value of [U].
        
        Human Readable: Portions marked for FOUO dissemination in a USA document
        must be classified UNCLASSIFIED.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [FOUO] we make sure that attribute ism:classification is 
    	specified with a value of [U].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M136"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00031</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00031</xsl:attribute>
            <svrl:text>
        [ISM-ID-00031][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [REL] or [EYES], then 
        attribute releasableTo must be specified.
        
        Human Readable: USA documents containing REL TO or EYES ONLY 
        dissemination must specify to which countries the document is releasable.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [REL] or [EYES] we make sure that attribute ism:releasableTo
    	is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M137"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00033</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00033</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M138"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00034</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00034</xsl:attribute>
            <svrl:text>
        [ISM-ID-00034][Error] Rule removed in V8. Covered by rule 169.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M139"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00050</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00050</xsl:attribute>
            <svrl:text>
        [ISM-ID-00050][Error] Rule removed in V2.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M140"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00052</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00052</xsl:attribute>
            <svrl:text>
        [ISM-ID-00052][Error] Rule removed in V2.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M141"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00053</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00053</xsl:attribute>
            <svrl:text>
        [ISM-ID-00053][Error] Rule removed in V2.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M142"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00054</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00054</xsl:attribute>
            <svrl:text>
        [ISM-ID-00054][Error] Rule removed in V2.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M143"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00091</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00091</xsl:attribute>
            <svrl:text>
        [ISM-ID-00091][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M144"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00092</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00092</xsl:attribute>
            <svrl:text>
        [ISM-ID-00092][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M145"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00093</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00093</xsl:attribute>
            <svrl:text>
        [ISM-ID-00093][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M146"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00094</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00094</xsl:attribute>
            <svrl:text>
        [ISM-ID-00094][Error] Rule removed in V8.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M147"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00106</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00106</xsl:attribute>
            <svrl:text>
        [ISM-ID-00106][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M148"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00107</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00107</xsl:attribute>
            <svrl:text>
        [ISM-ID-00107][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [IMC] then attribute 
        classification must have a value of [TS] or [S].
        
        Human Readable:  IMCON data is SECRET (S), but may appear with 
        S or TOP SECRET data.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [IMC] we make sure that attribute ism:classification is not
    	specified with a value of [TS] or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M149"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00117</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00117</xsl:attribute>
            <svrl:text>
        [ISM-ID-00117][Warning] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M150"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00120</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00120</xsl:attribute>
            <svrl:text>
        [ISM-ID-00120][Error] Rule removed in V4.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M151"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00124</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00124</xsl:attribute>
            <svrl:text>
      [ISM-ID-00124][Warning] If ISM_CAPCO_RESOURCE and
      1. Attribute ownerProducer does not contain [USA].
      AND
      2. Attribute disseminationControls contains [RELIDO]
      
      Human Readable: RELIDO is not authorized for non-US portions.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [RELIDO] we make sure that attribute ism:ownerProducer is
    	specified with a value containing [USA].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M152"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00140</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00140</xsl:attribute>
            <svrl:text>
        [ISM-ID-00140][Error] Rule removed in V8.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M153"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00164</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00164</xsl:attribute>
            <svrl:text>
        [ISM-ID-00164][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [RS],
        then attribute classification must have a value of [TS] or [S].
        
        Human Readable: USA documents with RISK SENSITIVE dissemination must
        be classified SECRET or TOP SECRET.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [RS] we make sure that attribute ism:classification is not
    	specified with a value of [TS] or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M154"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00169</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00169</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M155"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00213</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00213</xsl:attribute>
            <svrl:text>
        [ISM-ID-00213][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [DISPLAYONLY], then 
        attribute displayOnlyTo must be specified.
        
        Human Readable: A USA document with DISPLAY ONLY dissemination must 
        indicate the countries to which it may be disclosed.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [DISPLAYONLY] we make sure that attribute ism:displayOnlyTo
    	is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M156"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00215</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00215</xsl:attribute>
            <svrl:text>
        [ISM-ID-00215][Error] Rule removed in V8.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M157"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00302</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00302</xsl:attribute>
            <svrl:text>
        [ISM-ID-00302][Error] Added and removed in v10.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M158"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00005</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00005</xsl:attribute>
            <svrl:text>
        [ISM-ID-00005][Error] Rule removed in V2. Replaced by ISM_ID_00024.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M159"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00024</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00024</xsl:attribute>
            <svrl:text>
        [ISM-ID-00024][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M160"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00095</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00095</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M161"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00216</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00216</xsl:attribute>
            <svrl:text>
        [ISM-ID-000216][] Introduced and removed in V6. Never made it to signed package.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M162"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00232</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00232</xsl:attribute>
            <svrl:text>
        [ISM-ID-00232][] Introduced and removed in V8. Never made it to signed package.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M163"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00233</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00233</xsl:attribute>
            <svrl:text>
        [ISM-ID-00233][Error] If ISM_CAPCO_RESOURCE, then any portion with  
        attribute FGIsourceOpen specified and an ownerProducer containing [USA]
        must not have attribute disseminationControls containing [DISPLAYONLY] 
        or [RELIDO].
        
        Human Readable: DISPLAYONLY and RELIDO are not authorized for use on portions 
        containing Foreign Government Information.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which is not
    	the ISM_RESOURCE_ELEMENT, has attribute ism:FGIsourceOpen specified, has
    	attribute ism:disseminationControls specified, and has attribute 
    	ism:ownerProducer specified with a value containing the
    	token [USA], we make sure that attribute ism:disseminationControls does
    	not contain the token [DISPLAYONLY] or [RELIDO].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M164"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00006</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00006</xsl:attribute>
            <svrl:text>
        [ISM-ID-00006][Error] Rule removed in V2. Replaced by ISM_ID_00025.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M165"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00025</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00025</xsl:attribute>
            <svrl:text>
        [ISM-ID-00025][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M166"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00096</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00096</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M167"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00097</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00097</xsl:attribute>
            <svrl:text>
        [ISM-ID-00097][Warning] If ISM_CAPCO_RESOURCE and attribute FGIsourceProtected is 
        specified with a value other than [FGI] then the value(s) must not be discoverable in IC shared spaces.
        
        Human Readable: FGI Protected should rarely if ever be seen outside of an agency's internal systems.    
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which specifies
    	the attribute ism:FGIsourceProtected, we make sure that attribute
    	ism:FGIsourceProtected contains only the token [FGI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M168"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00217</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00217</xsl:attribute>
            <svrl:text>
        [ISM-ID-00217][Error] If ISM_CAPCO_RESOURCE attribute FGIsourceProtected
        contains [FGI], it must be the only value.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which specifies
    	the attribute ism:FGIsourceProtected, we make sure that attribute
    	ism:FGIsourceProtected contains only the token [FGI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M169"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00218</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00218</xsl:attribute>
            <svrl:text>
        [ISM-ID-000218][] Introduced and removed in V6. Never made it to signed package.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M170"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00234</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00234</xsl:attribute>
            <svrl:text>
        [ISM-ID-00234][Error] If ISM_CAPCO_RESOURCE, then any portion with  
        attribute FGIsourceProtected specified and an ownerProducer containing [USA]
        must not have attribute disseminationControls containing token 
        [RELIDO] or [DISPLAYONLY].
        
        Human Readable: RELIDO and DISPLAYONLY are not authorized for use on portions containing
        Foreign Government Information.
    </svrl:text>
            <svrl:text>
    If the document is an ISM-CAPCO-RESOURCE, for each element which is not
    the ISM_RESOURCE_ELEMENT, has attribute ism:FGIsourceProtected specified, has
    attribute ism:disseminationControls specified, and has attribute 
    ism:ownerProducer specified with a value containing the
    token [USA], we make sure that attribute ism:disseminationControls does
    not contain the token [DISPLAYONLY] or [DISPLAYONLY].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M171"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00235</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00235</xsl:attribute>
            <svrl:text>
        [ISM-ID-00235][] Introduced and removed in V8. Never made it to signed package.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M172"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00002</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00002</xsl:attribute>
            <svrl:text>
        [ISM-ID-00002][Error] For every attribute in the ISM namespace that is
        used in a document a non-null value must be present.
    </svrl:text>
            <svrl:text>
        For each element which defines an attribute in the ISM namespace, we 
        make sure that each attribute in the ISM namespace is specified with 
        a non-whitespace value.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M173"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00012</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00012</xsl:attribute>
            <svrl:text>
        [ISM-ID-00012][Error] If any of the attributes defined in 
        this DES other than DESVersion, unregisteredNoticeType, or pocType 
        are specified for an element, then attributes classification and 
        ownerProducer must be specified for the element.
    </svrl:text>
            <svrl:text>
    	For each element which defines an attribute in the ISM namespace other
    	than ism:pocTyp, ism:DESVersion, or ism:unregisteredNoticeType we make
    	sure that attributes ism:classification and ism:ownerProducer are
    	specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M174"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00098</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00098</xsl:attribute>
            <svrl:text>
        [ISM-ID-00098][] This rule number was skipped and never used. removed
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M175"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00102</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00102</xsl:attribute>
            <svrl:text>
        [ISM-ID-00102][Error] The attribute 
        DESVersion in the namespace urn:us:gov:ic:ism must be specified.
        
        Human Readable: The data encoding specification version must
        be specified.
    </svrl:text>
            <svrl:text>
        Make sure that the attribute edh:DESVersion 
        is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M176"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00103</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00103</xsl:attribute>
            <svrl:text>
        [ISM-ID-00103][Error] At least one element must have attribute 
        resourceElement specified with a value of [true].
    </svrl:text>
            <svrl:text>
        For the document, we make sure that at least one element specifies 
        attribute ism:resourceElement with a value of [true].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M177"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00119</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00119</xsl:attribute>
            <svrl:text>
        [ISM-ID-00119][Error] If ISM_CAPCO_RESOURCE and 
        1. attribute classification is not [U]
        AND
        2. ISM_ICDOCUMENT_APPLIES
        AND
        3. attribute excludeFromRollup is not true
        AND
        4. Attribute disseminationControls must contain one or more of 
            [DISPLAYONLY], [REL], [RELIDO], [EYES], or [NF]

        Human Readable: All classified NSI that claims compliance with 
        ICD 710 must have an appropriate foreign disclosure or release marking.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document, or ICDocument does not apply to the document,
        or the resource is unclassified, or  excludeFromRollup is true, then the rule does not apply. 
        Otherwise, we make sure that the attribute disseminationControls contains at least
        one of the values [DISPLAYONLY], [RELIDO], [REL], [EYES], or [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M178"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00125</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00125</xsl:attribute>
            <svrl:text>
    [ISM-ID-00125][Error] If any attributes in namespace 
    urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMAttributes.xml. 
    
    Human Readable: Ensure that attributes in the ISM namespace are defined by ISM.XML.
  </svrl:text>
            <svrl:text>
    This rule uses an abstract pattern to consolidate logic. It checks that the
    value in parameter $searchTerm is contained in the parameter $list. The parameter
    $searchTerm is relative in scope to the parameter $context. The value for the parameter 
    $list is a variable defined in the main document (ISM_XML.sch), which reads 
    values from a specific CVE file.
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M179"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00126</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00126</xsl:attribute>
            <svrl:text>
        [ISM-ID-00126][Error] Attributes with namespace urn:us:gov:ic:ism must 
        not appear with attribute @xs:any. 
        
        Human Readable: Ensure that no attributes that appear to be in the 
        ISM namespace, but are not defined by ISM.XML, are used in a schema
        that might have an xs:any.
    </svrl:text>
            <svrl:text>
        For any element which specifies an attribute in the ISM namespace, we
        make sure that the attribute xs:any is NOT specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M180"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00166</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00166</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M181"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00170</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00170</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M182"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00179</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00179</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M183"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00180</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00180</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M184"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00188</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00188</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M185"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00189</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00189</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M186"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00190</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00190</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M187"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00191</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00191</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M188"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00192</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00192</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M189"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00193</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00193</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M190"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00194</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00194</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M191"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00195</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00195</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M192"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00196</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00196</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M193"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00197</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00197</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M194"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00198</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00198</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M195"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00199</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00199</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M196"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00200</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00200</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M197"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00201</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00201</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M198"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00202</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00202</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M199"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00203</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00203</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M200"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00204</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00204</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M201"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00205</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00205</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M202"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00206</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00206</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M203"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00207</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00207</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M204"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00208</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00208</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M205"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00209</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00209</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M206"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00210</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00210</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M207"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00211</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00211</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M208"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00212</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00212</xsl:attribute>
            <svrl:text>
        [ISM-ID-00212][Error] Rule removed in V6.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M209"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00223</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00223</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M210"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00226</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00226</xsl:attribute>
            <svrl:text>
        [ISM-ID-00226][Error] Attributes @ism:noticeType and @ism:unregisteredNoticeType
        may not both be used on the same element. 
        
        Human Readable: Ensure that the ISM attributes noticeType and
        unregisteredNoticeType are not used on the same element.
    </svrl:text>
            <svrl:text>
        For each element which has attribute ism:noticeType specified, we
        make sure that ism:unregisteredNoticeType is not specified. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M211"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00236</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00236</xsl:attribute>
            <svrl:text> [ISM-ID-00236][Error] Duplicate tokens are not permitted in ISM
        attributes.</svrl:text>
            <svrl:text> To determine the valid values, this rule first retrieves the CVE values
        for the attribute, which in this case is classification. Then, each attribute token is
        converted into a numerical value based on its characters. Next, each attribute token is
        given an order number, which compares its position to that of its value in the CVE file. If
        the token is not found, its order number will be -1. If the document is a CAPCO resource and
        the ownerProducer of this element is 'USA', then the rule will fail if tokens are found with
        order numbers of -1. The rule will also fail if duplicate values are found for the element,
        or when its count is greater than 1. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M212"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00300</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00300</xsl:attribute>
            <svrl:text>
        [ISM-ID-00300][Error] DESVersion attributes must be specified as version 10.
    </svrl:text>
            <svrl:text>
        DESVersion attributes must be specified as version 10.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M213"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00007</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00007</xsl:attribute>
            <svrl:text>
        [ISM-ID-00007][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M214"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00035</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00035</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M215"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00036</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00036</xsl:attribute>
            <svrl:text>
        [ISM-ID-00036][Error] Rule removed in V8.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M216"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00037</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00037</xsl:attribute>
            <svrl:text>
        [ISM-ID-00037][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings
        contains the name token [SBU], [SBU-NF] then attribute
        classification must have a value of [U].
        
        Human Readable: SBU, SBU-NF data must be marked UNCLASSIFIED
        in USA documents.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which 
    	has attribute ism:nonICmarkings specified with a value containing
    	the token [SBU], [SBU-NF] we make sure that attribute
    	ism:classification is specified with a value of [U].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M217"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00038</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00038</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M218"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00051</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00051</xsl:attribute>
            <svrl:text>
        [ISM-ID-00051][Error] Rule removed in V2.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M219"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00055</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00055</xsl:attribute>
            <svrl:text>
        [ISM-ID-00055][Error] Rule removed in V2.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M220"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00148</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00148</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M221"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00225</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00225</xsl:attribute>
            <svrl:text>
        [ISM-ID-00225][Error] If ISM-ICDOCUMENT-APPLIES, then attribute 
        nonICmarkings must not be specified with a value containing any name 
        token starting with [ACCM] or [NNPI]. 
        
        Human Readable: ACCM and NNPI tokens are not valid for documents that claim
        compliance with IC rules.
    </svrl:text>
            <svrl:text>
    	If ISM_ICDOCUMENT_APPLIES, for each element which has attribute 
    	ism:nonICmarkings specified, we make sure that attribute
    	ism:nonICmarkings is not specified with a value containing a token
    	which starts with [ACCM] or [NNPI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M222"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00252</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00252</xsl:attribute>
            <svrl:text>
        [ISM-ID-00252][Error] If ISM_RESOURCE_ELEMENT specifies the attribute
        ism:disseminationControls with a value containing the token [RELIDO], 
        then attribute nonICmarkings must not be specified with a value containing 
        the token [NNPI]. 
        
        Human Readable: NNPI tokens are not valid for documents that have
        RELIDO at the resource level.
    </svrl:text>
            <svrl:text>
        For resource elements which have attribute ism:disseminationControls specified 
        with a value containing the token [RELIDO], we make sure that attribute 
        ism:nonICmarkings is not specified with a value containing the token [NNPI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M223"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00313</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00313</xsl:attribute>
            <svrl:text>
        [ISM-ID-00313][Error] If nonICmarkings contains the token [ND] then the 
        attribute disseminationControls must contain [NF].
        
        Human Readable: NODIS data must be marked NOFORN.
    </svrl:text>
            <svrl:text>
        If the nonICmarkings contains the ND token, then check that the disseminationControls
        attribute must have NF specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M224"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00314</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00314</xsl:attribute>
            <svrl:text>
        [ISM-ID-00314][Error] If nonICmarkings contains the token [XD] then the 
        attribute disseminationControls must contain [NF].
        
        Human Readable: EXDIS data must be marked NOFORN.
    </svrl:text>
            <svrl:text>
        If the nonICmarkings contains the ND token, then check that the disseminationControls
        attribute must have NF specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M225"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00163</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00163</xsl:attribute>
            <svrl:text>
        [ISM-ID-00163][Error] If attribute nonUSControls exists the attribute 
        ownerProducer must equal [NATO].
        
        Human Readable: NATO is the only owner of classification markings
        for which nonUSControls are currently authorized.
    </svrl:text>
            <svrl:text>
        For each element which specifies attribute ism:nonUSControls, we make
        sure that attribute ism:nonUSControls is specified with a value of [NATO].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M226"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00127</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00127</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M227"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00128</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00128</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M228"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00129</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00129</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M229"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00130</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00130</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M230"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00131</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00131</xsl:attribute>
            <svrl:text>
        [ISM-ID-00131][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M231"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00134</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00134</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M232"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00135</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00135</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M233"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00136</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00136</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M234"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00137</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00137</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M235"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00138</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00138</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M236"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00139</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00139</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M237"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00150</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00150</xsl:attribute>
            <svrl:text>
    [ISM-ID-00150][Error] If ISM_CAPCO_RESOURCE and:
    1. Any element, other than ISM_RESOURCE_ELEMENT, meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [LES]
    AND
    2. No element meeting ISM_CONTRIBUTES in the document has the attribute noticeType containing [LES]
    
    Human Readable: USA documents containing LES data must also have an LES notice.
  </svrl:text>
            <svrl:text>
    If the document is an ISM-CAPCO-RESOURCE, for each element which
    is not the ISM_RESOURCE_ELEMENT and meets ISM_CONTRIBUTES and specifies 
    attribute ism:nonICmarkings with a value containing the token [LES], we make
    sure that an element meeting ISM_CONTRIBUTES specifies attribute
    ism:noticeType with a value containing the token [LES].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M238"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00151</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00151</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M239"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00152</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00152</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M240"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00153</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00153</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M241"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00156</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00156</xsl:attribute>
            <svrl:text>
        [ISM-ID-00156][Error] Rule removed in V8. Replaced by rules 237 and 238.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M242"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00157</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00157</xsl:attribute>
            <svrl:text>
        [ISM-ID-00157][Error] If ISM_CAPCO_RESOURCE and:
        1. The attribute notice contains one of the [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], or [DoD-Dist-E]
        AND
        2. The attribute noticeReason is not specified.
        
        Human Readable: DoD distribution statements B, C, D , or E  all require a reason.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:noticeType with a value containing the token
        [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], or [DoD-Dist-E], we make
        sure that attribute ism:noticeReason is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M243"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00158</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00158</xsl:attribute>
            <svrl:text>
        [ISM-ID-00158][Error] If ISM_CAPCO_RESOURCE and:
        1. ISM_DoD5230_24_Applies
        AND
        2. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        AND
        3. A resource attribute notice does not contain one of [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], or [DoD-Dist-F].
       
        
        Human Readable: All classified documents that claim compliance with DoD5230.24 must use one of DoD 
        distribution statements B, C, D, E, or F.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE and ISM_DOD5230_24_APPLIES and
        the attribute classification of ISM_RESOURCE_ELEMENT is not [U], then
        we make sure that the resource element specifies attribute
        ism:noticeType with a value containing the token [DoD-Dist-B],
        [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], or [DoD-Dist-F].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M244"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00159</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00159</xsl:attribute>
            <svrl:text>
        [ISM-ID-00159][Error] If ISM_CAPCO_RESOURCE and:
        1. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        AND
        2. The attribute notice does contain [DoD-Dist-A] 
        or has attribute externalNotice with a value of [true].
        
        Human Readable: Distribution statement A (Public Release) is forbidden on classified documents.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE and the attribute
        classification of ISM_RESOURCE_ELEMENT is not [U], for each element
        which specifies attribute ism:noticeType we make sure that attribute
        ism:noticeType is not specified with a value containing the token
        [DoD-Dist-A] unless it is an external notice with attribute ism:externalNotice is [true].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M245"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00160</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00160</xsl:attribute>
            <svrl:text>
        [ISM-ID-00160][Error] Rule removed in V8. Replaced by rules 239 and 240.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M246"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00161</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00161</xsl:attribute>
            <svrl:text>
        [ISM-ID-00161][Error] If ISM_CAPCO_RESOURCE and:
        1. The attribute notice of ISM_RESOURCE_ELEMENT does contains [DoD-Dist-A]
        and does not have attribute externalNotice with a value of [true].
        AND
        2. attribute nonICmarkings contains any of [XD], [ND], [SBU], [SBU-NF], [LES], OR [LES-NF].
        
        Human Readable: Distribution statement A (Public Release) is incompatible with [XD], [ND], [SBU], [SBU-NF], [LES], OR [LES-NF].
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE and the attribute
    	noticeType of ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A]
    	and does not have attribute externalNotice with a value of [true], for
    	each element which specifies attribute ism:nonICmarkings we make
    	sure that attribute ism:nonICmarkings does not contain any of the
    	following tokens: [XD], [ND], [SBU], [SBU-NF], [LES], [LES-NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M247"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00237</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00237</xsl:attribute>
            <svrl:text>
        [ISM-ID-00237][Error] If ISM-CAPCO-RESOURCE, any element which specifies
        attribute noticeType containing one of the tokens [DoD-Dist-B], 
       	[DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
       	must also specify attribute noticeDate.
       	
        Human Readable: DoD distribution statements B, C, D ,E ,F, and X all require a date.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:noticeType specified with a value containing the token
        [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], 
        or [DoD-Dist-X], we make sure that attribute ism:noticeDate is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M248"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00238</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00238</xsl:attribute>
            <svrl:text>
    	[ISM-ID-00238][Error] If ISM-CAPCO-RESOURCE, if any element specifies
    	attribute noticeType containing one of the tokens [DoD-Dist-B], 
    	[DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X],
    	then an element in the document must specify attribute pocType with
    	the same value as attribute noticeType.
    	
        Human Readable: DoD distribution statements B, C, D ,E ,F, and X all 
        require a corresponding point of contact.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE, for each element which has 
    	attribute ism:noticeType specified with a value containing the token
        [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], 
        or [DoD-Dist-X], we make sure that some element in the document 
        specifies attribute ism:pocType with the same value as ism:noticeType.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M249"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00239</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00239</xsl:attribute>
            <svrl:text>
		[ISM-ID-00239][Error] If ISM_CAPCO_RESOURCE and attribute noticeType of
		ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], then any element 
		which contributes to rollup should not have an attribute
		disseminationControls that contains any of the following tokens:
		[FOUO], [PR], [DSEN], or [FISA].
		
		Human Readable: Distribution statement A (Public Release) is incompatible 
		with [FOUO], [PR], [DSEN], and [FISA] for contributing portions.
	</svrl:text>
            <svrl:text>
		If the document is an ISM-CAPCO-RESOURCE and the attribute
		noticeType of ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], for
		each element which specifies attribute ism:disseminationControls 
		we make sure that attribute ism:disseminationControls does not contain any of the
		following tokens: [FOUO], [PR], [DSEN], [FISA].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M250"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00240</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00240</xsl:attribute>
            <svrl:text>
        [ISM-ID-00240][Error] If ISM_CAPCO_RESOURCE and attribute noticeType of
        ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], then any element
        which contributes to rolluop should not have an attribute
        atomicEnergyMarkings that contains any of the following tokens:
        [DCNI], [UCNI].
        
        Human Readable: Distribution statement A (Public Release) is incompatible 
        with [DCNI] and [UCNI].
    </svrl:text>
            <svrl:text>
    	If the document is an ISM-CAPCO-RESOURCE and the attribute
    	noticeType of ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], for
    	each element which specifies attribute ism:atomicEnergyMarkings we make
    	sure that attribute ism:atomicEnergyMarkings does not contain any of the
    	following tokens: [DCNI], [UCNI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M251"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00244</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00244</xsl:attribute>
            <svrl:text>
    [ISM-ID-00244][Error] If ISM_CAPCO_RESOURCE and:
    1. Any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD-CNWDI]
    AND
    2. No element meeting ISM_CONTRIBUTES in the document has noticeType containing [CNWDI].
    that does not have attribute externalNotice with a value of [true].
    Human Readable: USA documents containing CNWDI data must also have an CNWDI notice.
  </svrl:text>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE, for each element meeting
    ISM_CONTRIBUTES which specifies attribute ism:atomicEnergyMarkings with
    a value containing the token [RD-CNWDI], we make sure that some element
    in the document specifies attribute ism:noticeType with a value containing
    the token [CNWDI] and not an attribute externalNotice with a value of [true].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M252"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00245</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00245</xsl:attribute>
            <svrl:text>
        [ISM-ID-00245][Error] If ISM_CAPCO_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute atomicEnergyMarkings containing [RD-CNWDI]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute noticeType containing [CNWDI]
        and not the attribute externalNotice with a value of [true].
        Human Readable: USA documents containing an CNWDI notice must also have RD-CNWDI data.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, for each element which meets
      ISM_CONTRIBUTES and specifies attribute ism:noticeType with a value
      containing the token [CNWDI] and not the attribute externalNotice with a value of [true], we make sure that some element in the
      document specifies attribute ism:atomicEnergyMarkings with a value
      containing the token [RD-CNWDI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M253"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00248</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00248</xsl:attribute>
            <svrl:text>
		[ISM-ID-00248][Error] ISM_RESOURCE_ELEMENT cannot have externalNotice set to [true].
		
		Human Readable: ISM resource elements can not be external notices.
	</svrl:text>
            <svrl:text>
		If ISM_RESOURCE_ELEMENT, we make sure that the ISM_RESOURCE_ELEMENT does not contain
		externalNotice set to [true].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M254"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00249</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00249</xsl:attribute>
            <svrl:text>
		[ISM-ID-00249][Error] Introduced and removed in V9. Never made it to signed package.
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M255"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00250</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00250</xsl:attribute>
            <svrl:text>
		[ISM-ID-00250][Error] If ISM-CAPCO-RESOURCE, element Notice must specify
		attribute ism:noticeType or ism:unregisteredNoticeType.
		
		Human Readable: Notices must specify their type.
	</svrl:text>
            <svrl:text>
		For element ism:Notice
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M256"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00251</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00251</xsl:attribute>
            <svrl:text>
        [[ISM-ID-00251][Error] If ISM-ICDOCUMENT-APPLIES, then attribute 
        @ism:noticeType must not be specified with a value of [COMSEC]. 
        
        Human Readable: COMSEC notices are not valid for documents that claim
        compliance with IC rules.
    </svrl:text>
            <svrl:text>
    	If ISM_ICDOCUMENT_APPLIES, for each element which has attribute 
    	@ism:noticeType specified, we make sure that attribute
    	@ism:noticeType is not specified with a value containing token
    	[COMSEC].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M257"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00001</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00001</xsl:attribute>
            <svrl:text>
        [ISM-ID-00001][Error] Rule removed in V8. Covered by rule 2.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M258"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00008</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00008</xsl:attribute>
            <svrl:text>
        [ISM-ID-00008][Error] Rule removed in V2. Replaced by ISM_ID_00039.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M259"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00039</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00039</xsl:attribute>
            <svrl:text>
        [ISM-ID-00039][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M260"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00099</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00099</xsl:attribute>
            <svrl:text>
        [ISM-ID-00099][Error] If ISM_CAPCO_RESOURCE and attribute ownerProducer
        contains the token [FGI], then the token [FGI] must be the only value 
        in attribute ownerProducer.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribtue ism:ownerProducer with a value containing the token
        [FGI] we make sure that attribute ism:ownerProducer only contains a 
        single token.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M261"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00100</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00100</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M262"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00219</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00219</xsl:attribute>
            <svrl:text>
        [ISM-ID-00219][Error] If element meets ISM_CONTRIBUTES and attribute
        ownerProducer contains the token [FGI], then attribute 
        FGIsourceProtected must have a value containing the token [FGI].
        
        Human Readable: Any non-resource element that contributes to the 
        document's banner roll-up and has FOREIGN GOVERNMENT INFORMATION (FGI)
        must also specify attribute FGIsourceProtected with token FGI.
    </svrl:text>
            <svrl:text>
        For each element which is not the $ISM_RESOURCE_ELEMENT and meets 
        ISM_CONTRIBUTES and specifies attribute ism:ownerProducer with a value
        containing the token [FGI], we make sure that attribute 
        ism:FGIsourceProtected is specified with a value containing the
        token [FGI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M263"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00315</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00315</xsl:attribute>
            <svrl:text>
        [ISM-ID-00315][Error] If element meets ISM_CONTRIBUTES and attribute
        ownerProducer contains the token [NATO], then attribute declassException
        must be specified with a value of [NATO] or [NATO-AEA] on the resourceElement.
        
        Human Readable: Any non-resource element that contributes to the 
        document's banner roll-up and has NATO Information)
        must also specify a NATO declass exemption on the banner.
    </svrl:text>
            <svrl:text>
        In a document that meets ISM_CAPCO_RESOURCE, for each element which is 
        not the $ISM_RESOURCE_ELEMENT and meets ISM_CONTRIBUTES and specifies 
        attribute ism:ownerProducer with a value containing the token [NATO], 
        we make sure that attribute ism:declassExemption on the resource element 
        is specified with a value containing the token [NATO] or [NATO-AEA].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M264"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00224</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00224</xsl:attribute>
            <svrl:text>
        [ISM-ID-00224][Error] Removed in V10.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M265"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00247</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00247</xsl:attribute>
            <svrl:text>
        [ISM-ID-00247][Error] Removed in V10.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M266"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00009</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00009</xsl:attribute>
            <svrl:text>
        [ISM-ID-00009][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M267"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00032</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00032</xsl:attribute>
            <svrl:text>
        [ISM-ID-00032][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls is not specified, or is specified and does not 
        contain the name token [REL] or [EYES], then attribute releasableTo 
        must not be specified.
        
        Human Readable: USA documents must only specify to which countries it is 
        authorized for release if dissemination information contains 
        REL TO or EYES ONLY data. 
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        does not specify attribute disseminationControls or specifies attribute
        ism:disseminationControls with a value containing the token 
        [REL] or [EYES] we make sure that attribute ism:releasableTo is not 
        specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M268"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00041</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00041</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M269"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00214</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00214</xsl:attribute>
            <svrl:text>
        [ISM-ID-00214][Error] If ISM_CAPCO_RESOURCE then attribute 
        releasableTo must start with [USA].
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute releasableTo we make sure that attribute
        releasableTo is specified with a value that starts with the token [USA].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M270"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00013</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00013</xsl:attribute>
            <svrl:text>
        [ISM-ID-00013][Error] If ISM_NSI_EO_APPLIES then either attribute classifiedBy or 
        derivedFrom must be specified on the ISM_RESOURCE_ELEMENT. 
        
        Human Readable: Documents under E.O. 13526 must have classification authority block information.
    </svrl:text>
            <svrl:text>
      If ISM_NSI_EO_APPLIES, we make sure that the ISM_RESOURCE_ELEMENT specifies
      attribute ism:classifiedBy or attribute ism:derivedFrom.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M271"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00014</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00014</xsl:attribute>
            <svrl:text>
        [ISM-ID-00014][Error] If ISM_NSI_EO_APPLIES then one or more of the following 
        attributes: declassDate, declassEvent, or declassException must be specified on the ISM_RESOURCE_ELEMENT.
        
        Human Readable: Documents under E.O. 13526 must have declassification instructions included in the 
        classification authority block information.
    </svrl:text>
            <svrl:text>
      If ISM_NSI_EO_APPLIES, we make sure that the ISM_RESOURCE_ELEMENT specifies
      one of the following attributes: ism:declassDate, ism:declassEvent, ism:declassException.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M272"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00056</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00056</xsl:attribute>
            <svrl:text>
        [ISM-ID-00056][Error] If ISM_CAPCO_RESOURCE and attribute classification of 
        ISM_RESOURCE_ELEMENT has a value of [U] then no element meeting ISM_CONTRIBUTES_USA in the document may have 
        a classification attribute of [C], [S], [TS], or [R].
        
        Human Readable: USA UNCLASSIFIED documents can't have portion markings with the classification TOP SECRET, SECRET, CONFIDENTIAL, or RESTRICTED data.    
    </svrl:text>
            <svrl:text>
      If the document is an ISM-CAPCO-RESOURCE and attribute ism:classification
      on $ISM_RESOURCE_ELEMENT has a value of [U], then we make sure that
      no element meeting ISM_CONRIBUTES_USA has attribute ism:classification with
      value [C], [S], [TS], [R].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M273"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00057</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00057</xsl:attribute>
            <svrl:text>
      [ISM-ID-00057][Error] Rule removed in V8. Values moved to rule 56.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M274"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00058</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00058</xsl:attribute>
            <svrl:text>
        [ISM-ID-00058][Error] If ISM_CAPCO_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
        has a value of [C] then no element meeting ISM_CONTRIBUTES_USA in the document may have a classification attribute of [S] or [TS].
        
        Human Readable: USA CONFIDENTIAL documents can't have TOP SECRET or SECRET data.
    </svrl:text>
            <svrl:text>
      If the document is an ISM-CAPCO-RESOURCE and attribute ism:classification
      on $ISM_RESOURCE_ELEMENT has a value of [C], then we make sure that
      no element meeting ISM_CONRIBUTES_USA has attribute ism:classification with
      value [S], [TS]. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M275"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00059</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00059</xsl:attribute>
            <svrl:text>
        [ISM-ID-00059][Error] If ISM_CAPCO_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
        has a value of [S] then no element meeting ISM_CONTRIBUTES_USA in the document may have a classification attribute of [TS].
        
        Human Readable: USA SECRET documents can't have TOP SECRET data.
    </svrl:text>
            <svrl:text>
      If the document is an ISM-CAPCO-RESOURCE and attribute ism:classification
      on $ISM_RESOURCE_ELEMENT has a value of [S], then we make sure that
      no element meeting ISM_CONRIBUTES_USA has attribute ism:classification with
      value [TS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M276"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00060</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00060</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:SCIcontrols with a value containing the token
    [SI], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:SCIcontrols with a value containing the token [SI].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M277"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00061</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00061</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:SCIcontrols with a value containing the token
    [SI-G], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:SCIcontrols with a value containing the token [SI-G].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M278"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00062</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00062</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:SCIcontrols with a value containing the token
    [TK], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:SCIcontrols with a value containing the token [TK].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M279"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00063</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00063</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:SCIcontrols with a value containing the token
    [HCS], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:SCIcontrols with a value containing the token [HCS].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M280"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00064</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00064</xsl:attribute>
            <svrl:text>
        [ISM-ID-00064][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute FGIsourceOpen containing any value then the ISM_RESOURCE_ELEMENT must have either 
        FGIsourceOpen or FGIsourceProtected with a value. 
        
        Human Readable: USA documents having FGI Open data must have FGI Open or FGI Protected at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute 
        FGIsourceOpen specified and does not have attribute excludeFromRollup set to true, 
        then we make sure that the resourceElement has one of the following attributes 
        specified: FGIsourceOpen or FGIsourceProtected.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M281"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00065</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00065</xsl:attribute>
            <svrl:text>
        [ISM-ID-00065][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute FGIsourceProtected containing any value then the ISM_RESOURCE_ELEMENT must have FGIsourceProtected with a value.
        
        Human Readable: USA documents having FGI Protected data must have FGI Protected at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute FGIsourceProtected specified 
        with a non-empty value and does not have attribute excludeFromRollup set to true, 
        then we make sure that the banner has attribute FGIsourceProtected specified with 
        a non-empty value.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M282"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00066</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00066</xsl:attribute>
            <svrl:text>
        [ISM-ID-00066][Error] If ISM_CAPCO_RESOURCE and: 
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute disseminationControls containing [FOUO]
        AND
        2. ISM_RESOURCE_ELEMENT has the attribute classification [U]
        AND
        3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings containing [SBU], [SBU-NF], [LES], [LES-NF]
        
        Then the ISM_RESOURCE_ELEMENT must have disseminationControls containing [FOUO].
        
        Human Readable: USA Unclassified documents having FOUO data and not having SBU, SBU-NF, LES, or LES-NF must have 
        FOUO at the resource level.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_CAPCO_RESOURCE, the current element is the ISM_RESOURCE_ELEMENT,
        some element meeting ISM_CONTRIBUTES specifies attribute ism:disseminationControls
        with a value containing [FOUO], the ISM_RESOURCE_ELEMENT specifies the attribute
        ism:classification with a value of [U], and no element meeting ISM_CONTRIBUTES
        specifies attribute ism:nonICmarkings with a value containing [SBU], [SBU-NF],
        [LES], or LES-NF], then we make sure that the ISM_RESOURCE_ELEMENT
        specifies attribute ism:disseminationControls with a value containing the
        token [FOUO].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M283"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00067</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00067</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:disseminationControls with a value containing the token
    [OC], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [OC].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M284"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00068</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00068</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:disseminationControls with a value containing the token
    [IMC], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [IMC].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M285"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00069</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00069</xsl:attribute>
            <svrl:text>
        [ISM-ID-00069][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M286"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00070</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00070</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:disseminationControls with a value containing the token
    [NF], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [NF].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M287"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00071</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00071</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:disseminationControls with a value containing the token
    [PR], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [PR].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M288"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00072</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00072</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:atomicEnergyMarkings with a value containing the token
    [RD], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:atomicEnergyMarkings with a value containing the token [RD].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M289"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00073</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00073</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:atomicEnergyMarkings with a value containing the token
    [RD-CNWDI], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:atomicEnergyMarkings with a value containing the token [RD-CNWDI].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M290"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00074</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00074</xsl:attribute>
            <svrl:text>
        [ISM-ID-00074][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document has the attribute atomicEnergyMarkings containing [RD-SG-##] then the ISM_RESOURCE_ELEMENT must have 
        atomicEnergyMarkings containing [RD-SG-##]. ## represent digits 1 through 99 the ## must match.
        
        Human Readable: USA documents having Restricted SIGMA-## Data must have the same Restricted SIGMA-## Data at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute atomicEnergyMarkings specified
        with a value containing [RD-SG-##], where ## is represented by a regular expression matching
        numbers 1 through 99, unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [RD-SG-##].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M291"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00075</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00075</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:atomicEnergyMarkings with a value containing the token
    [FRD], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:atomicEnergyMarkings with a value containing the token [FRD].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M292"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00076</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00076</xsl:attribute>
            <svrl:text>
        [ISM-ID-00076][Error] Rule removed in V3.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M293"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00077</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00077</xsl:attribute>
            <svrl:text>
        [ISM-ID-00077][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the 
        document has the attribute atomicEnergyMarkings containing [FRD-SG-##] then the ISM_RESOURCE_ELEMENT must have 
        atomicEnergyMarkings containing [FRD-SG-##]. ## represent digits 1 through 99 the ## must match.
        
        Human Readable: USA documents having Formerly Restricted SIGMA-## Data must have the same Formerly Restricted SIGMA-## Data at 
        the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute atomicEnergyMarkings specified
        with a value containing [FRD-SG-##], where ## is represented by a regular expression matching
        numbers 1 through 99, unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [FRD-SG-##].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M294"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00078</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00078</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE, and the ISM_RESOURCE_ELEMENT 
    specifies attribute ism:classification with a value of 
    Uan element meeting ISM_CONTRIBUTES
    specifies attribute ism:atomicEnergyMarkings with a value containing the token
    [DCNI], then we make sure that the ISM_RESOURCE_ELEMENT specifies the 
    attribute ism:atomicEnergyMarkings with a value containing the token [DCNI].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M295"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00079</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00079</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE, and the ISM_RESOURCE_ELEMENT 
    specifies attribute ism:classification with a value of 
    Uan element meeting ISM_CONTRIBUTES
    specifies attribute ism:atomicEnergyMarkings with a value containing the token
    [UCNI], then we make sure that the ISM_RESOURCE_ELEMENT specifies the 
    attribute ism:atomicEnergyMarkings with a value containing the token [UCNI].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M296"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00080</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00080</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:disseminationControls with a value containing the token
    [DSEN], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [DSEN].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M297"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00081</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00081</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:disseminationControls with a value containing the token
    [FISA], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [FISA].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M298"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00082</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00082</xsl:attribute>
            <svrl:text>
        [ISM-ID-00082][Error] Rule removed in V8
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M299"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00083</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00083</xsl:attribute>
            <svrl:text>
        [ISM-ID-00083][Error] Rule removed in V8
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M300"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00084</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00084</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:nonICmarkings with a value containing the token
    [DS], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:nonICmarkings with a value containing the token [DS].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M301"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00085</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00085</xsl:attribute>
            <svrl:text>
        [ISM-ID-00085][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        has the attribute nonICmarkings containing [XD] and does not have any element meeting ISM_CONTRIBUTES in the document having the 
        attribute nonICmarkings containing [ND] then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [XD].
        
        Human Readable: USA documents having XD Data and not having ND must have XD at the resource level.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, the current element is the ISM_CAPCO_RESOURCE,
      any element meeting ISM_CONTRIBUTES specifies attribute ism:nonICmarkings with a value
      containing the token [XD], and no element meeting ISM_CONTRIBUTES specifies the
      attribute ism:nonICmarkings with a value containing the token [ND], then we make sure
      that the ISM_RESOURCE_ELEMENT specifies attribute ism:nonICmarkings with a value
      containing the token [XD].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M302"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00086</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00086</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:nonICmarkings with a value containing the token
    [ND], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:nonICmarkings with a value containing the token [ND].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M303"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00087</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00087</xsl:attribute>
            <svrl:text>
        [ISM-ID-00087][Error] If ISM_CAPCO_RESOURCE and there exist at least 2 elements in the document:
        1. Each element: Meets ISM_CONTRIBUTES
        AND
        2. One of the elements: Has the attribute nonICmarkings containing [SBU-NF]
        AND
        3. One of the elements: Has the attribute classification NOT having a value of [U]
        Then the ISM_RESOURCE_ELEMENT must have disseminationControls containing [NF].
        
        Human Readable: Classified USA documents having SBU-NF Data must have NF at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified
        with a value containing [SBU-NF], does not have attribute excludeFromRollup set to 
        true, and the resourceElement has attribute classification
        specified with a value other than [U], then we make sure that the resourceElement 
        has attribute disseminationControls specified with a value containing [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M304"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00088</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00088</xsl:attribute>
            <svrl:text>
        [ISM-ID-00088][Error] If ISM_CAPCO_RESOURCE and releasableTo is specified on 
        the resource element then all classified portions must specify releasableTo.
        
        Human Readable: USA documents having any classified portion that is not 
        Releasable or having unclassified portions with [NF], [DISPLAYONLY], or [RELIDO]
        cannot be REL at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules apply to the document, we verify that all portions either have 
        the attribute classification specified with a value of [U] or classified portions 
        of the document have the attribute releasableTo. 
        
        Attribute releasableTo is only valid on an element if attribute 
        disseminationControls is specified with a value containing [REL] or [EYES], 
        as [REL] supersedes [EYES] in the banner.
                
        If any elements do not meet either of the two requirements stated above, 
        then the assertion fails since attribute releasableTo appears on 
        the banner but is not present on all classified portions.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M305"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00089</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00089</xsl:attribute>
            <svrl:text>
        [ISM-ID-00089][Error] Rule removed in V4.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M306"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00090</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00090</xsl:attribute>
            <svrl:text>
        [ISM-ID-00090][Error] If ISM_CAPCO_RESOURCE and any element: 
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute disseminationControls containing [REL]
        Then the ISM_RESOURCE_ELEMENT must not have attribute disseminationControls containing [EYES]. 
        
        Human Readable: USA documents with any portion that is REL must not be EYES at the resource level.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_CAPO_RESOURCE, the current element is the 
        ISM_RESOURCE_ELEMENT, and some element meeting ISM_CONTRIBUTES specifies
        attribute ism:disseminationControls with a value containing [REL], then
        we make sure that ISM_RESOURCE_ELEMENT does not specify attribute
        ism:disseminationControls or specifies the attribute with a value
        that does not contain the token [EYES].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M307"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00104</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00104</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE, and the ISM_RESOURCE_ELEMENT 
    specifies attribute ism:classification with a value of 
    Uan element meeting ISM_CONTRIBUTES
    specifies attribute ism:nonICmarkings with a value containing the token
    [SBU-NF], then we make sure that the ISM_RESOURCE_ELEMENT specifies the 
    attribute ism:nonICmarkings with a value containing the token [SBU-NF].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M308"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00105</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00105</xsl:attribute>
            <svrl:text>
    [ISM-ID-00105][Error] If ISM_CAPCO_RESOURCE and any element in the document: 
    1. Meets ISM_CONTRIBUTES
    AND
    2. Has the attribute nonICmarkings containing [SBU]
    AND
    3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings containing any of [SBU-NF]
    Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [SBU].
    
    Human Readable: USA documents having SBU and not having SBU-NF must have SBU at the resource level.
  </svrl:text>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE, the current element is the 
    ISM_RESOURCE_ELEMENT, some element meeting ISM_CONTIBUTES specifies
    attribute ism:nonICmarkings with a value containing the token [SBU], and
    no element meeting ISM_CONTRIBUTES specifies attribute ism:nonICmarkings
    with a value containing the token [SBU-NF], then we make sure that
    ISM_RESOURCE_ELEMENT sepcifies attribute ism:nonICmarkings with a value
    containing the token [SBU].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M309"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00108</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00108</xsl:attribute>
            <svrl:text>
    If ISM_CAPCO_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
    has a value of [TS] and attribute ism:compilationReason does not have a 
    value, then we make sure that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute classification with a value of [TS].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M310"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00109</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00109</xsl:attribute>
            <svrl:text>
    If ISM_CAPCO_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
    has a value of [S] and attribute ism:compilationReason does not have a 
    value, then we make sure that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute classification with a value of [S].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M311"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00110</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00110</xsl:attribute>
            <svrl:text>
    If ISM_CAPCO_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
    has a value of [C] and attribute ism:compilationReason does not have a 
    value, then we make sure that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute classification with a value of [C].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M312"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00111</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00111</xsl:attribute>
            <svrl:text>
    If ISM_CAPCO_RESOURCE and attribute SCIcontrols of ISM_RESOURCE_ELEMENT 
    has a value of [SI] and attribute ism:compilationReason does not have a 
    value, then we make sure that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute SCIcontrols with a value of [SI].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M313"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00112</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00112</xsl:attribute>
            <svrl:text>
    If ISM_CAPCO_RESOURCE and attribute SCIcontrols of ISM_RESOURCE_ELEMENT 
    has a value of [SI-G] and attribute ism:compilationReason does not have a 
    value, then we make sure that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute SCIcontrols with a value of [SI-G].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M314"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00113</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00113</xsl:attribute>
            <svrl:text>
    If ISM_CAPCO_RESOURCE and attribute SCIcontrols of ISM_RESOURCE_ELEMENT 
    has a value of [TK] and attribute ism:compilationReason does not have a 
    value, then we make sure that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute SCIcontrols with a value of [TK].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M315"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00116</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00116</xsl:attribute>
            <svrl:text>
    If ISM_CAPCO_RESOURCE and attribute SCIcontrols of ISM_RESOURCE_ELEMENT 
    has a value of [HCS] and attribute ism:compilationReason does not have a 
    value, then we make sure that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute SCIcontrols with a value of [HCS].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M316"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00118</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00118</xsl:attribute>
            <svrl:text>
        [ISM-ID-00118][Error] The first element in document order having 
        resourceElement true must have createDate specified.
    </svrl:text>
            <svrl:text>
        We make sure that the resourceElement has attribute createDate specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M317"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00132</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00132</xsl:attribute>
            <svrl:text>
        [ISM-ID-00132][Error] If ISM_CAPCO_RESOURCE and the ISM_RESOURCE_ELEMENT has the 
        attribute disseminationControls containing [RELIDO] then every element meeting 
        ISM_CONTRIBUTES_CLASSIFIED in the document must have the attribute 
        disseminationControls containing [RELIDO].
        
        Human Readable: USA documents having RELIDO at the resource level must have every classified portion having RELIDO and on any U portions that have explicit Release specified must have RELIDO.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_CAPCO_RESOURCE, the current element is the
        ISM_RESOURCE_ELEMENT, and the ISM_RESOURCE_ELEMENT specifies the attribute
        ism:disseminationControls with a value containing the token [RELIDO],
        then we make sure that every element meeting ISM_CONTRIBUTES_CLASSIFIED
        speficies attribute ism:disseminationControls with a value containing
        the token [RELIDO].
        
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M318"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00141</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00141</xsl:attribute>
            <svrl:text>
        [ISM-ID-00141][Error] If ISM_NSI_EO_APPLIES and 
        1. ISM_RESOURCE_ELEMENT attribute declassException does not have a value of [50X1-HUM], or [50X2-WMD]
        AND
        2. ISM_RESOURCE_ELEMENT attribute declassDate is not specified
        AND
        3. ISM_RESOURCE_ELEMENT attribute declassEvent is not specified
        AND
        4. ISM_RESOURCE_ELEMENT attribute atomicEnergyMarkings is not specified
           with a value of [RD] or [FRD]
            
        Human Readable: Documents under E.O. 13526 require declassDate or declassEvent unless 
        50X1-HUM, 50X2-WMD, RD, FRD, AEA, NATO, or NATO-AEA is specified.
    </svrl:text>
            <svrl:text>
        If ISM_NSI_EO_APPLIES, the current element is the ISM_RESOURCE_ELEMENT,
        and attribtue ism:declassExeption is not specified with a value
        containing the token [50X1-HUM], or [50X2-WMD], [AEA], [NATO], or [NATO-AEA]
        then we make sure that attribute ism:declassDate is 
        specified or attribute ism:declassEvent is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M319"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00144</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00144</xsl:attribute>
            <svrl:text>
        [ISM-ID-00144][Error] Rule removed in V4.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M320"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00145</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00145</xsl:attribute>
            <svrl:text>
        [ISM-ID-00145][Error] If ISM_CAPCO_RESOURCE and any element in the document: 
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute nonICmarkings containing [LES]
        AND
        3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings containing any of [LES-NF]
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [LES].
        
        Human Readable: USA documents having LES and not having LES-NF must have LES at the resource level.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, the current element is the 
      ISM_RESOURCE_ELEMENT, some element meeting ISM_CONTIBUTES specifies
      attribute ism:nonICmarkings with a value containing the token [LES], and
      no element meeting ISM_CONTRIBUTES specifies attribute ism:nonICmarkings
      with a value containing the token [LES-NF], then we make sure that
      ISM_RESOURCE_ELEMENT sepcifies attribute ism:nonICmarkings with a value
      containing the token [LES].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M321"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00146</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00146</xsl:attribute>
            <svrl:text>
        [ISM-ID-00146][Error] If ISM_CAPCO_RESOURCE and there exist at least 2 elements in the document:
        1. Each element: Meets ISM_CONTRIBUTES
        AND
        2. One of the elements: Has the attribute nonICmarkings containing [LES-NF]
        AND
        3. One of the elements: meets ISM_CONTRIBUTES_CLASSIFIED
        Then the ISM_RESOURCE_ELEMENT must have disseminationControls containing [NF].
        
        Human Readable: Classified USA documents having LES-NF Data must have NF at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified 
        with a value containing [LES-NF] and the resourceElement has attribute classification specified 
        with a value other than [U], then we make sure that the resourceElement has attribute 
        disseminationControls specified with a value containing [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M322"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00147</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00147</xsl:attribute>
            <svrl:text>
        [ISM-ID-00147][Error] If ISM_CAPCO_RESOURCE and there exist at least 2 elements in the document:
        1. Each element: Meets ISM_CONTRIBUTES
        AND
        2. One of the elements: Has the attribute nonICmarkings containing [LES-NF]
        AND
        3. One of the elements: meets ISM_CONTRIBUTES_CLASSIFIED
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [LES].
        
        Human Readable: Classified USA documents having LES-NF Data must have LES at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified 
        with a value containing [LES-NF] and the resourceElement has attribute classification specified 
        with a value other than [U], then we make sure that the resourceElement has attribute nonICmarkings
        specified with a value containing [LES].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M323"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00149</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00149</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE, and the ISM_RESOURCE_ELEMENT 
    specifies attribute ism:classification with a value of 
    Uan element meeting ISM_CONTRIBUTES
    specifies attribute ism:nonICmarkings with a value containing the token
    [LES-NF], then we make sure that the ISM_RESOURCE_ELEMENT specifies the 
    attribute ism:nonICmarkings with a value containing the token [LES-NF].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M324"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00154</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00154</xsl:attribute>
            <svrl:text>
    If ISM_CAPCO_RESOURCE and attribute disseminationControls of ISM_RESOURCE_ELEMENT 
    has a value of [FOUO] and attribute ism:compilationReason does not have a 
    value, then we make sure that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute disseminationControls with a value of [FOUO].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M325"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00155</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00155</xsl:attribute>
            <svrl:text>
        [ISM-ID-00155][Error] If ISM_CAPCO_RESOURCE and 
        1. ISM_DoD5230_24_Applies
        AND
        2. Attribute noticeType of ISM_RESOURCE_ELEMENT does not contain one of 
        [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
        
        Human Readable: All USA documents that claim compliance with DoD5230.24 must have a distribution statement
        for the entire document.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, ISM_DOD5230_24_APPLIES, and
      the current element is the ISM_RESOURCE_ELEMENT, we make sure that 
      attribute ism:noticeType is specified with a value containing one of the
      tokens: [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D],
      [DoD-Dist-E], [DoD-Dist-F], [DoD-Dist-X].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M326"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00162</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00162</xsl:attribute>
            <svrl:text>
        [ISM-ID-00162][Error] If ISM_CAPCO_RESOURCE and 
        1. ISM_DoD5230_24_Applies
        AND
        2. Attribute noticeType of ISM_RESOURCE_ELEMENT contains more than one of 
        [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
        
        Human Readable: All USA documents that claim compliance with DoD5230.24 must have only 1 distribution statement
        for the entire document.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, ISM_DOD5230_24_APPLIES, and
      the current element is the ISM_RESOURCE_ELEMENT, we make sure that
      attribute noticeType is specified with a value containing only one of 
      [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], 
      [DoD-Dist-F], or [DoD-Dist-X].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M327"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00165</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00165</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:disseminationControls with a value containing the token
    [RS], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [RS].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M328"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00171</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00171</xsl:attribute>
            <svrl:text>
        [ISM-ID-00171][Warning] Rule removed in V10 because it did not correctly
        treat portions with @ism:releasableTo as also contributing to displayability.
        Rule 320 was introduced in V10 to enforce rollup of displayability on the banner.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M329"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00172</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00172</xsl:attribute>
            <svrl:text>
        [ISM-ID-00172][Error] Rule removed in V6.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M330"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00227</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00227</xsl:attribute>
            <svrl:text>
        [ISM-ID-00227][Error] Attribute @noticeType may only appear on the 
        resource node when it contains the values [DoD-Dist-A], [DoD-Dist-B], 
        [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X].
        
        Human Readable: Documents may only specify a document-level notice if
        it pertains to DoD Distribution.
    </svrl:text>
            <svrl:text>
        For every resource element with the ism:noticeType attribute specified,
        we make sure that attribute's value is one of [DoD-Dist-A], [DoD-Dist-B], 
        [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
        by using a regular expression.
        
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M331"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00228</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00228</xsl:attribute>
            <svrl:text>
        [ISM-ID-00228][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [FRD] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        atomicEnergyMarking attribute containing [FRD].
        
        Human Readable: USA documents marked FRD at the resource level must have FRD data.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing the value [FRD], then we make sure that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings
      with a value containing [FRD].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M332"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00229</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00229</xsl:attribute>
            <svrl:text>
        [ISM-ID-00229][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [RD] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        atomicEnergyMarking attribute containing [RD].
        
        Human Readable: USA documents marked RD at the resource level must have RD data.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing the value [RD], then we make sure that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings
      with a value containing [RD].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M333"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00230</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00230</xsl:attribute>
            <svrl:text>
        [ISM-ID-00230][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [FRD-SG-##] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        atomicEnergyMarking attribute containing the same [FRD-SG-##].
        
        Human Readable: USA documents marked FRD-SG-## at the resource level must have FRD-SG-## data, where ## is the same.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing a token matching [FRD-SG-##], then we make sure that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings
      with a value containing a token matching the same [FRD-SG-##].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M334"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00231</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00231</xsl:attribute>
            <svrl:text>
        [ISM-ID-00231][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [RD-SG-##] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        atomicEnergyMarking attribute containing the same [RD-SG-##].
        
        Human Readable: USA documents marked RD-SG-## at the resource level must have RD-SG-## data, where ## is the same.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing a token matching [RD-SG-##], then we make sure that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings
      with a value containing a token matching the same [RD-SG-##].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M335"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00246</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00246</xsl:attribute>
            <svrl:text>
        [ISM-ID-00246][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [RD], [FRD], or [TFNI] then the ISM_RESOURCE_ELEMENT must have a declassException of [AEA] or [NATO-AEA].
        
        Human Readable: USA documents containing [RD], [FRD], or [TFNI] data must have declassException containing [AEA] or [NATO-AEA] at the resource level.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing a token matching [RD], [FRD], or [TFNI], then we make sure that the 
      ISM_RESOURCE_ELEMENT has a declassException of [AEA] or [NATO-AEA].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M336"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00298</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00298</xsl:attribute>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:atomicEnergyMarkings with a value containing the token
    [TFNI], then we make sure that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:atomicEnergyMarkings with a value containing the token [TFNI].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M337"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00303</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00303</xsl:attribute>
            <svrl:text>
        [ISM-ID-00303][Error] Added and removed in v10.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M338"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00312</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00312</xsl:attribute>
            <svrl:text>
        [ISM-ID-00312][Error] Added and removed in V10. Removed during final review, never made it to released package.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M339"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00316</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00316</xsl:attribute>
            <svrl:text>
        [ISM-ID-00316][Error] If ISM_CAPCO_RESOURCE and attribute declassExemption of ISM_RESOURCE_ELEMENT contains 
        [NATO] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        ownerProducer attribute containing [NATO].
        
        Human Readable: USA documents marked with a NATO declass exemption must have NATO portions.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:declassExemption is specified
      with a value containing the value [NATO], then we make sure that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:ownerProducer
      with a value containing [NATO].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M340"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00317</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00317</xsl:attribute>
            <svrl:text>
        [ISM-ID-00317][Error] If ISM_CAPCO_RESOURCE and attribute declassExemption of ISM_RESOURCE_ELEMENT contains 
        [NATO-AEA] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        ownerProducer attribute containing [NATO] and one portion containing ism:atomicEnergyMarkings.
        
        Human Readable: USA documents marked with a NATO-AEA declass exemption must have at lease one NATO portion 
        and one portion that contains Atomic Energy Markings.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:declassExemption is specified
      with a value containing the value [NATO-AEA], then we make sure that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:ownerProducer
      with a value containing [NATO] and ism:atomicEnergyMarkings.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M341"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00318</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00318</xsl:attribute>
            <svrl:text>
        [ISM-ID-00318][Error] Rollup compiliation does not meet CAPCO guidance.
    </svrl:text>
            <svrl:text>
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
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M342"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00319</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00319</xsl:attribute>
            <svrl:text>
        [ISM-ID-00319][Error] If attribute releasableTo is specified, then it must
        contain more than a single token.
    </svrl:text>
            <svrl:text>
    	If a portion specifies attribute releasableTo, then we make sure the 
    	token count is greater than 1.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M343"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00320</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00320</xsl:attribute>
            <svrl:text>
        
    </svrl:text>
            <svrl:text>
    	
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M344"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00114</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00114</xsl:attribute>
            <svrl:text>
        [ISM-ID-00114][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M345"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00121</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00121</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M346"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00010</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00010</xsl:attribute>
            <svrl:text>
        [ISM-ID-00010][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M347"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00042</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00042</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M348"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00043</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00043</xsl:attribute>
            <svrl:text>
        [ISM-ID-00043][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
        contains the name token [SI], then attribute classification must have
        a value of [TS], [S], or [C].
        
        Human Readable: A USA document containing Special Intelligence (SI) 
        data must be classified CONFIDENTIAL, SECRET, or TOP SECRET.  
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [SI] we make sure that attribute ism:classification is specified with
        a value containing the token [TS], [S], or [C].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M349"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00044</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00044</xsl:attribute>
            <svrl:text>
        [ISM-ID-00044][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
        contains a name token starting with [SI-G], then attribute
        classification must have a value of [TS].
        
        Human Readable: A USA document containing Special Intelligence (SI)
        GAMMA compartment data must be classified TOP SECRET.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing a token
        starting with [SI-G] we make sure that attribute ism:classification
        is specified with a value containing the token [TS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M350"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00045</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00045</xsl:attribute>
            <svrl:text>
        [ISM-ID-00045][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
        contains a name token starting with [SI-G], then attribute
        disseminationControls must contain the name token [OC].
        
        Human Readable: A USA document containing Special Intelligence (SI)
        GAMMA compartment data must be marked for ORIGINATOR CONTROLLED 
        dissemination.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing a token
        starting with [SI-G] we make sure that attribute
        ism:disseminationControls is specified with a value containing the
        token [OC].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M351"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00046</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00046</xsl:attribute>
            <svrl:text>
        [ISM-ID-00046][Error] Rule removed in V8.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M352"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00047</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00047</xsl:attribute>
            <svrl:text>
        [ISM-ID-00047][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
        contains the name token [TK], then attribute classification must have
        a value of [TS] or [S].
        
        Human Readable: A USA document containing TALENT KEYHOLE data must
        be classified SECRET or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [TK] we make sure that attribute ism:classification is 
        specified with a value containing the token [TS] or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M353"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00048</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00048</xsl:attribute>
            <svrl:text>
        [ISM-ID-00048][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
        contains the name token [HCS], then attribute classification must have
        a value of [TS], [S], or [C].
        
        Human Readable: A USA document containing HCS data must be classified
        CONFIDENTIAL, SECRET, or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [HCS] we make sure that attribute ism:classification is 
        specified with a value containing the token [TS], [S], or [C].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M354"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00049</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00049</xsl:attribute>
            <svrl:text>
        [ISM-ID-00049][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
        contains the name token [HCS], then attribute disseminationControls
        must contain the name token [NF].
        
        Human Readable: A USA document containing HCS data must be marked
        for NO FOREIGN dissemination.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [HCS] we make sure that attribute ism:disseminationControls is 
        specified with a value containing the token [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M355"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00122</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00122</xsl:attribute>
            <svrl:text>
        [ISM-ID-00122][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
        contains the name token [KDK], then attribute classification must have
        a value of [TS] or [S].
        
        Human Readable: A USA document with KLONDIKE data must be 
        classified SECRET or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [KDK] we make sure that attribute ism:classification is 
        specified with a value containing the token [TS] or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M356"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00123</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00123</xsl:attribute>
            <svrl:text>
        [ISM-ID-00123][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
        contains the name token [KDK], then attribute disseminationControls
        must contain the name token [NF].
        
        Human Readable: A USA document containing KLONDIKE data must also be
        marked for NO FOREIGN dissemination.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [KDK] we make sure that attribute ism:disseminationControls is 
        specified with a value containing the token [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M357"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00177</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00177</xsl:attribute>
            <svrl:text>
        [ISM-ID-00177][Error] Rule removed in V8.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M358"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00186</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00186</xsl:attribute>
            <svrl:text>
        [ISM-ID-00186][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains a token matching [SI-G-XXXX],
        where X is represented by the regular expression character class [A-Z]{4}, then it must also contain the
        name token [SI-G].
        
        Human Readable: A USA document that contains Special Intelligence (SI) GAMMA sub-compartments must
        also specify that it contains SI-GAMMA compartment data.
    </svrl:text>
            <svrl:text>
      If the document is an ISM-CAPCO-RESOURCE, for each element which
      specifies attribute ism:SCIcontrols with a value containing a token
      matching [SI-G-XXXX], where X is represented by the regular expression
      character class [A-Z]{4}, we make sure that attribute ism:SCIcontrols is 
      specified with a value containing the token [SI-G].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M359"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00187</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00187</xsl:attribute>
            <svrl:text>
        [ISM-ID-00187][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G],
        then it must also contain the name token [SI].
        
        Human Readable: A USA document that contains Special Intelligence (SI) -GAMMA compartment data must also specify that 
        it contains SI data. 
    </svrl:text>
            <svrl:text>
      If the document is an ISM-CAPCO-RESOURCE, for each element which
      specifies attribute ism:SCIcontrols with a value containing the token
      [SI-G] we make sure that attribute ism:SCIcontrols is 
      specified with a value containing the token [SI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M360"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00241</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00241</xsl:attribute>
            <svrl:text>
        [ISM-ID-00241][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [RSV-XXX],
        then it must also contain the name token [RSV].
        
        Human Readable: A USA document that contains RESEVERE data (RSV) compartment data must also specify that 
        it contains RSV data. 
    </svrl:text>
            <svrl:text>
        If the document is an ISM_CAPCO_RESOURCE, for each element which specifies
        attribute ism:SCIcontrols with a value containing a token matching
        the regular expression "RSV-[A-Z0-9]{3}", we make sure that attribute
        ism:SCIcontrols is specified with a value containing the token [RSV].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M361"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00242</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00242</xsl:attribute>
            <svrl:text>
        [ISM-ID-00242][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [RSV],
        then it must also have attribute classificatoin with a value of [S] or [TS].
        
        Human Readalbe: A USA document that contains RESERVE data must be classified SECRET or TOP SECRET.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_CAPCO_RESOURCE, for each element which specifies
      attribute ism:SCIcontrols with a value containing the token [RSV], we make
      sure that attribute ism:classification is specified with a value containing
      the token [TS] or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M362"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00243</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00243</xsl:attribute>
            <svrl:text>
    [ISM-ID-00243][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [RSV],
    then it must also contain a compartment [RSV-XXX].
    
    Human Readable: RESERVE is not permitted as a stand-alone value and a compartment must be expressed.
  </svrl:text>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE, for each element which specifies
    attribute ism:SCIcontrols with a value containing the token [RSV], we make
    sure that attribute ism:SCIcontrols is specified with a value containing
    a token maching the regular expression "RSV-[A-Z0-9]{3}".
    
    If CAPCO rules do not apply to the document then the rule does not apply
    and we return true. If the current element has attribute SCIcontrols specified
    with a value containing [RSV], then we make sure that attribute SCIcontrols also contains the value [RSV-XXX].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M363"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00301</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00301</xsl:attribute>
            <svrl:text>
    [ISM-ID-00301][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains any of the name tokens [EL],
    [EL-EU], or [EL-NK], then it must also contain the name token [SI].
    
    Human Readable: A USA document that contains ENDSEAL (EL), -ECRU (EK), or -NONBOOK (NK) compartment data must also specify that 
    it contains SI data. 
  </svrl:text>
            <svrl:text>
    If the document is an ISM_CAPCO_RESOURCE, for each element which specifies
    attribute ism:SCIcontrols with a value containing any of the tokens [EL], 
    [EL-EU], or [EL-NK], we make sure that attribute ism:SCIcontrols is 
    specified with a value containing the token [SI].
    
    If CAPCO rules do not apply to the document then the rule does not apply
    and we return true. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M364"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00304</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00304</xsl:attribute>
            <svrl:text>
        [ISM-ID-00304][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK-BLFH],
        then it must also contain the name token [KDK].
        
        Human Readable: A USA document that contains KLONDIKE (KDK) -BLUEFISH compartment data must also specify that 
        it contains KDK data. 
    </svrl:text>
            <svrl:text>
      If the document is an ISM-CAPCO-RESOURCE, for each element which
      specifies attribute ism:SCIcontrols with a value containing the token
      [KDK-BLFH] we make sure that attribute ism:SCIcontrols is 
      specified with a value containing the token [KDK].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M365"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00305</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00305</xsl:attribute>
            <svrl:text>
    [ISM-ID-00305][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK-IDIT],
    then it must also contain the name token [KDK].
    
    Human Readable: A USA document that contains KLONDIKE (KDK) -IDITAROD compartment data must also specify that 
    it contains KDK data. 
  </svrl:text>
            <svrl:text>
    If the document is an ISM-CAPCO-RESOURCE, for each element which
    specifies attribute ism:SCIcontrols with a value containing the token
    [KDK-IDIT] we make sure that attribute ism:SCIcontrols is 
    specified with a value containing the token [KDK].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M366"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00306</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00306</xsl:attribute>
            <svrl:text>
    [ISM-ID-00306][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK-KAND],
    then it must also contain the name token [KDK].
    
    Human Readable: A USA document that contains KLONDIKE (KDK) -KANDIK compartment data must also specify that 
    it contains KDK data. 
  </svrl:text>
            <svrl:text>
    If the document is an ISM-CAPCO-RESOURCE, for each element which
    specifies attribute ism:SCIcontrols with a value containing the token
    [KDK-KAND] we make sure that attribute ism:SCIcontrols is 
    specified with a value containing the token [KDK].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M367"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00307</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00307</xsl:attribute>
            <svrl:text>
        [ISM-ID-00307][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains a token matching [KDK-BLFH-XXXXXX],
        where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
        name token [KDK-BLFH].
        
        Human Readable: A USA document that contains KLONDIKE (KDK) BLUEFISH sub-compartments must
        also specify that it contains KDK -BLUEFISH compartment data.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing a token
        matching [KDK-BLFH-XXXXXX], where X is represented by the regular expression
        character class [A-Z]{1,6}, we make sure that attribute ism:SCIcontrols is 
        specified with a value containing the token [KDK-BLFH].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M368"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00308</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00308</xsl:attribute>
            <svrl:text>
        [ISM-ID-00308][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains a token matching [KDK-IDIT-XXXXXX],
        where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
        name token [KDK-IDIT].
        
        Human Readable: A USA document that contains KLONDIKE (KDK) IDITAROD sub-compartments must
        also specify that it contains KDK -IDITAROD compartment data.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing a token
        matching [KDK-IDIT-XXXXXX], where X is represented by the regular expression
        character class [A-Z]{1,6}, we make sure that attribute ism:SCIcontrols is 
        specified with a value containing the token [KDK-IDIT].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M369"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00309</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00309</xsl:attribute>
            <svrl:text>
        [ISM-ID-00309][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains a token matching [KDK-KAND-XXXXXX],
        where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
        name token [KDK-KAND].
        
        Human Readable: A USA document that contains KLONDIKE (KDK) KANDIK sub-compartments must
        also specify that it contains KDK -KANDIK compartment data.
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing a token
        matching [KDK-KAND-XXXXXX], where X is represented by the regular expression
        character class [A-Z]{1,6}, we make sure that attribute ism:SCIcontrols is 
        specified with a value containing the token [KDK-KAND].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M370"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00310</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00310</xsl:attribute>
            <svrl:text>
    [ISM-ID-00310][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [EL-EU],
    then it must also contain the name token [EL].
    
    Human Readable: A USA document that contains ENDSEAL (EL) -ECRU compartment data must also specify that 
    it contains EL data. 
  </svrl:text>
            <svrl:text>
    If the document is an ISM-CAPCO-RESOURCE, for each element which
    specifies attribute ism:SCIcontrols with a value containing the token
    [EL-EU] we make sure that attribute ism:SCIcontrols is 
    specified with a value containing the token [EL].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M371"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00311</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00311</xsl:attribute>
            <svrl:text>
        [ISM-ID-00311][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [EL-NK],
        then it must also contain the name token [EL].
        
        Human Readable: A USA document that contains ENDSEAL (EL) -NONBOOK compartment data must also specify that 
        it contains EL data. 
    </svrl:text>
            <svrl:text>
        If the document is an ISM-CAPCO-RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [EL-NK] we make sure that attribute ism:SCIcontrols is 
        specified with a value containing the token [EL].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M372"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00268</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00268</xsl:attribute>
            <svrl:text>
		[ISM-ID-00268][Error] All atomicEnergyMarkings attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an atomicEnergyMarkings attribute, we 
		make sure that the atomicEnergyMarkings value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M373"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00269</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00269</xsl:attribute>
            <svrl:text>
		[ISM-ID-00269][Error] All classifiction attributes must be of type NmToken. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an classification attribute, we 
		make sure that the classification value matches the pattern
		defined for type NmTokens.  
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M374"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00270</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00270</xsl:attribute>
            <svrl:text>
		[ISM-ID-00270][Error] All classificationReason attributes must be a string with less than 4096 characters. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an classificationReason attribute, we 
		make sure that the classificationReason value is a string with less
		than 4096 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M375"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00271</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00271</xsl:attribute>
            <svrl:text>
		[ISM-ID-00271][Error] All classifiedBy attributes must be a string with less than 1024 characters. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an classifiedBy attribute, we 
		make sure that the classifiedBy value is a string with less
		than 1024 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M376"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00272</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00272</xsl:attribute>
            <svrl:text>
		[ISM-ID-00272][Error] All compilationReason attributes must be a string with less than 1024 characters. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an compilationReason attribute, we 
		make sure that the compilationReason value is a string with less
		than 1024 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M377"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00273</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00273</xsl:attribute>
            <svrl:text>
		[ISM-ID-00273][Error] All compliesWith attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an compliesWith attribute, we 
		make sure that the compliesWith value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M378"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00274</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00274</xsl:attribute>
            <svrl:text>
		[ISM-ID-00274][Error] All createDate attributes must be of type Date. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an createDate attribute, we 
		make sure that the createDate value matches the pattern
		defined for type Date. 
		
		Note: this rule is not able to be failed. If the createDate does
		not confirm to type Date, schematron fails when defining global
		variables before any rules are fired. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M379"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00275</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00275</xsl:attribute>
            <svrl:text>
		[ISM-ID-00275][Error] All declassDate attributes must be of type Date. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an declassDate attribute, we 
		make sure that the declassDate value matches the pattern
		defined for type Date. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M380"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00276</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00276</xsl:attribute>
            <svrl:text>
		[ISM-ID-00276][Error] All declassEvent attributes must be a string with less than 1024 characters. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an declassEvent attribute, we 
		make sure that the declassEvent value is a string with less
		than 1024 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M381"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00277</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00277</xsl:attribute>
            <svrl:text>
		[ISM-ID-00277][Error] All declassException attributes must be of type NmToken. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an declassException attribute, we 
		make sure that the declassException value matches the pattern
		defined for type NmToken. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M382"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00278</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00278</xsl:attribute>
            <svrl:text>
		[ISM-ID-00278][Error] All derivativelyClassifiedBy attributes must be a string with less than 1024 characters. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an declassEvent attribute, we 
		make sure that the derivativelyClassifiedBy value is a string with less
		than 1024 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M383"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00279</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00279</xsl:attribute>
            <svrl:text>
		[ISM-ID-00279][Error] All derivedFrom attributes must be a string with less than 1024 characters. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an derivedFrom attribute, we 
		make sure that the derivedFrom value is a string with less
		than 1024 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M384"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00280</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00280</xsl:attribute>
            <svrl:text>
		[ISM-ID-00280][Error] All displayOnlyTo attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an displayOnlyTo attribute, we 
		make sure that the displayOnlyTo value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M385"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00281</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00281</xsl:attribute>
            <svrl:text>
		[ISM-ID-00281][Error] All disseminationControls attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an disseminationControls attribute, we 
		make sure that the disseminationControls value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M386"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00282</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00282</xsl:attribute>
            <svrl:text>
		[ISM-ID-00282][Error] All excludeFromRollup attributes must be of type Boolean. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an excludeFromRollup attribute, we 
		make sure that the excludeFromRollup value matches the pattern
		defined for type Boolean. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M387"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00283</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00283</xsl:attribute>
            <svrl:text>
		[ISM-ID-00283][Error] All FGIsourceOpen attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an FGIsourceOpen attribute, we 
		make sure that the FGIsourceOpen value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M388"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00284</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00284</xsl:attribute>
            <svrl:text>
		[ISM-ID-00284][Error] All FGIsourceProtected attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an FGIsourceProtected attribute, we 
		make sure that the FGIsourceProtected value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M389"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00285</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00285</xsl:attribute>
            <svrl:text>
		[ISM-ID-00285][Error] All nonICmarkings attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an nonICmarkings attribute, we 
		make sure that the nonICmarkings value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M390"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00286</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00286</xsl:attribute>
            <svrl:text>
		[ISM-ID-00286][Error] All nonUSControls attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an nonUSControls attribute, we 
		make sure that the nonUSControls value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M391"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00287</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00287</xsl:attribute>
            <svrl:text>
		[ISM-ID-00287][Error] All noticeDate attributes must be of type Date. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an noticeDate attribute, we 
		make sure that the noticeDate value matches the pattern
		defined for type Date. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M392"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00288</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00288</xsl:attribute>
            <svrl:text>
		[ISM-ID-00288][Error] All noticeReason attributes must be a string with less than 2048 characters. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an noticeReason attribute, we 
		make sure that the noticeReason value is a string with less
		than 2048 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M393"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00289</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00289</xsl:attribute>
            <svrl:text>
		[ISM-ID-00289][Error] All noticeType attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an noticeType attribute, we 
		make sure that the noticeType value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M394"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00290</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00290</xsl:attribute>
            <svrl:text>
		[ISM-ID-00290][Error] All externalNotice attributes must be of type Boolean. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an externalNotice attribute, we 
		make sure that the externalNotice value matches the pattern
		defined for type Boolean. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M395"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00291</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00291</xsl:attribute>
            <svrl:text>
		[ISM-ID-00291][Error] All ownerProducer attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an ownerProducer attribute, we 
		make sure that the ownerProducer value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M396"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00292</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00292</xsl:attribute>
            <svrl:text>
		[ISM-ID-00292][Error] All pocType attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an pocType attribute, we 
		make sure that the pocType value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M397"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00293</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00293</xsl:attribute>
            <svrl:text>
		[ISM-ID-00293][Error] All releasableTo attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an releasableTo attribute, we 
		make sure that the releasableTo value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M398"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00282</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00282</xsl:attribute>
            <svrl:text>
		[ISM-ID-00282][Error] All resourceElement attributes must be of type Boolean. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an resourceElement attribute, we 
		make sure that the resourceElement value matches the pattern
		defined for type Boolean. 
		
		Note: this rule is not able to be failed. If the resourceElement does
		not confirm to type Boolean, schematron fails when defining global
		variables before any rules are fired. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M399"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00295</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00295</xsl:attribute>
            <svrl:text>
		[ISM-ID-00295][Error] All SARIdentifier attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an SARIdentifier attribute, we 
		make sure that the SARIdentifier value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M400"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00296</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00296</xsl:attribute>
            <svrl:text>
		[ISM-ID-00296][Error] All SCIcontrols attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an SCIcontrols attribute, we 
		make sure that the SCIcontrols value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M401"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00297</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00297</xsl:attribute>
            <svrl:text>
		[ISM-ID-00297][Error] All unregisteredNoticeType attributes must be a string with less than 2048 characters. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an unregisteredNoticeType attribute, we 
		make sure that the unregisteredNoticeType value is a string with less
		than 2048 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M402"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00011</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00011</xsl:attribute>
            <svrl:text>
        [ISM-ID-00011][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M403"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00018</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00018</xsl:attribute>
            <svrl:text>
        [ISM-ID-00018][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M404"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00019</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00019</xsl:attribute>
            <svrl:text>
        [ISM-ID-00019][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M405"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00020</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00020</xsl:attribute>
            <svrl:text>
        [ISM-ID-00020][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M406"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00021</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00021</xsl:attribute>
            <svrl:text>
        [ISM-ID-00021][Error] Rule removed in V5.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M407"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00022</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00022</xsl:attribute>
            <svrl:text>
        [ISM-ID-00022][Error] Rule removed in V3.
    </svrl:text>
            <svrl:text/>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M408"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00253</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00253</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M409"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00254</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00254</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M410"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00255</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00255</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M411"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00256</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00256</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M412"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00257</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00257</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M413"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00258</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00258</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M414"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00259</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00259</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M415"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00260</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00260</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M416"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00261</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00261</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M417"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00262</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00262</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M418"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00263</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00263</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M419"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00264</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00264</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M420"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00265</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00265</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M421"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00266</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00266</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M422"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00267</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00267</xsl:attribute>
            <svrl:text>$ruleText</svrl:text>
            <svrl:text>$codeDesc</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M423"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->


<!--PATTERN typeConstraintPatterns-->
<xsl:variable name="NameStartCharPattern" select="':|[A-Z]|_|[a-z]'"/>
   <xsl:variable name="NameCharPattern" select="concat($NameStartCharPattern, '|-|\.|[0-9]')"/>
   <xsl:variable name="NmTokenPattern" select="concat('(', $NameCharPattern, ')+')"/>
   <xsl:variable name="NmTokensPattern"
                 select="concat($NmTokenPattern, '( ', $NmTokenPattern, ')*')"/>
   <xsl:variable name="BooleanPattern" select="'(false|true|0|1)'"/>
   <xsl:variable name="DatePattern"
                 select="'-?([1-9][0-9]{3,}|0[0-9]{3})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])(Z|(\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00))?'"/>
   <xsl:template match="text()" priority="-1" mode="M5"/>
   <xsl:template match="@*|node()" priority="-2" mode="M5">
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>
   <xsl:param name="countriesList"
              select="document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="classificationAllList"
              select="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="classificationUSList"
              select="document('../../CVE/ISM/CVEnumISMClassificationUS.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="ownerProducerList"
              select="document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="declassExceptionList"
              select="document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="FGIsourceOpenList"
              select="document('../../CVE/ISM/CVEnumISMFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="FGIsourceProtectedList"
              select="document('../../CVE/ISM/CVEnumISMFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="nonICmarkingsList"
              select="document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="releasableToList"
              select="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="SCIcontrolsList"
              select="document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="SARIdentifierList"
              select="document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="validAttributeList"
              select="document('../../CVE/ISM/CVEnumISMAttributes.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="validElementList"
              select="document('../../CVE/ISM/CVEnumISMElements.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="noticeList"
              select="document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="nonUSControlsList"
              select="document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="compliesWithList"
              select="document('../../CVE/ISM/CVEnumISMCompliesWith.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="atomicEnergyMarkingsList"
              select="document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="displayOnlyToList"
              select="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="pocTypeList"
              select="document('../../CVE/ISM/CVEnumISMPocType.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="disseminationControlsList"
              select="document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="ISM_RESOURCE_ELEMENT"
              select="(for $each in (//*) return if($each/@ism:resourceElement=true()) then $each else null)[1]"/>
   <xsl:param name="ISM_RESOURCE_CREATE_DATE" select="$ISM_RESOURCE_ELEMENT/@ism:createDate"/>
   <xsl:param name="ISM_CAPCO_RESOURCE"
              select="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:ownerProducer)), ' '),'USA') &gt; 0"/>
   <xsl:param name="ISM_ICDOCUMENT_APPLIES"
              select="(index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:compliesWith)), ' '),'ICDocument' ) &gt; 0) or              index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:compliesWith)), ' '),'IntelReport' ) &gt; 0"/>
   <xsl:param name="ISM_INTELREPORT_APPLIES"
              select="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:compliesWith)), ' '),'IntelReport') &gt; 0"/>
   <xsl:param name="ISM_DOD5230_24_APPLIES"
              select="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:compliesWith)), ' '),'DoD5230.24') &gt; 0"/>
   <xsl:param name="ISM_ORCON_POC_DATE" select="xs:date('2011-03-11')"/>
   <xsl:param name="bannerClassification"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:classification))"/>
   <xsl:param name="bannerDisseminationControls"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:disseminationControls))"/>
   <xsl:param name="bannerDisplayOnlyTo"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:displayOnlyTo))"/>
   <xsl:param name="bannerNonICmarkings"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:nonICmarkings))"/>
   <xsl:param name="bannerFGIsourceOpen"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:FGIsourceOpen))"/>
   <xsl:param name="bannerFGIsourceProtected"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:FGIsourceProtected))"/>
   <xsl:param name="bannerReleasableTo"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:releasableTo))"/>
   <xsl:param name="bannerSCIcontrols"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:SCIcontrols))"/>
   <xsl:param name="bannerNotice"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:noticeType))"/>
   <xsl:param name="bannerAtomicEnergyMarkings"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings))"/>
   <xsl:param name="bannerDisseminationControls_tok"
              select="tokenize(normalize-space(string($bannerDisseminationControls)), ' ')"/>
   <xsl:param name="bannerDisplayOnlyTo_tok"
              select="tokenize(normalize-space(string($bannerDisplayOnlyTo)), ' ')"/>
   <xsl:param name="bannerNonICmarkings_tok"
              select="tokenize(normalize-space(string($bannerNonICmarkings)), ' ')"/>
   <xsl:param name="bannerFGIsourceOpen_tok"
              select="tokenize(normalize-space(string($bannerFGIsourceOpen)), ' ')"/>
   <xsl:param name="bannerFGIsourceProtected_tok"
              select="tokenize(normalize-space(string($bannerFGIsourceProtected)), ' ')"/>
   <xsl:param name="bannerReleasableTo_tok"
              select="tokenize(normalize-space(string($bannerReleasableTo)), ' ')"/>
   <xsl:param name="bannerSCIcontrols_tok"
              select="tokenize(normalize-space(string($bannerSCIcontrols)), ' ')"/>
   <xsl:param name="bannerNotice_tok"
              select="tokenize(normalize-space(string($bannerNotice)), ' ')"/>
   <xsl:param name="bannerAtomicEnergyMarkings_tok"
              select="tokenize(normalize-space(string($bannerAtomicEnergyMarkings)), ' ')"/>
   <xsl:param name="partTags"
              select="/descendant-or-self::node()[@ism:* and util:contributesToRollup(.) and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))]"/>
   <xsl:param name="partClassification"
              select="for $token in $partTags/@ism:classification return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partOwnerProducer"
              select="for $token in $partTags/@ism:ownerProducer return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partDisseminationControls"
              select="for $token in $partTags/@ism:disseminationControls return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partDisplayOnlyTo"
              select="for $token in $partTags/@ism:displayOnlyTo return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partAtomicEnergyMarkings"
              select="for $token in $partTags/@ism:atomicEnergyMarkings return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partNonICmarkings"
              select="for $token in $partTags/@ism:nonICmarkings return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partFGIsourceOpen"
              select="for $token in $partTags/@ism:FGIsourceOpen return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partFGIsourceProtected"
              select="for $token in $partTags/@ism:FGIsourceProtected return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partSCIcontrols"
              select="for $token in $partTags/@ism:SCIcontrols return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partNoticeType"
              select="for $token in $partTags/@ism:noticeType return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partPocType"
              select="for $token in $partTags/@ism:pocType return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partClassification_tok"
              select="for $token in $partClassification return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partOwnerProducer_tok"
              select="for $token in $partOwnerProducer return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partDisseminationControls_tok"
              select="for $token in $partDisseminationControls return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partDisplayOnlyTo_tok"
              select="for $token in $partDisplayOnlyTo return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partAtomicEnergyMarkings_tok"
              select="for $token in $partAtomicEnergyMarkings return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partNonICmarkings_tok"
              select="for $token in $partNonICmarkings return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partSCIcontrols_tok"
              select="for $token in $partSCIcontrols return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partNoticeType_tok"
              select="for $token in $partNoticeType return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partPocType_tok"
              select="for $token in $partPocType return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partNoticeNodeType"
              select="for $token in $partTags/@ism:noticeType return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="ISM_NSI_EO_APPLIES"
              select="$ISM_CAPCO_RESOURCE and                     not($ISM_RESOURCE_ELEMENT/@ism:classification='U') and                     $ISM_RESOURCE_CREATE_DATE &gt;= xs:date('1996-04-11') and                     (some $element in $partTags satisfies                             not($element/@ism:classification='U') and not($element/@ism:atomicEnergyMarkings))"/>
   <xsl:param name="TEYE_tok" select="tokenize(string('USA CAN GBR'), ' ')"/>
   <xsl:param name="ACGU_tok" select="tokenize(string('USA AUS CAN GBR'), ' ')"/>
   <xsl:param name="FVEY_tok" select="tokenize(string('USA AUS CAN GBR NZL'), ' ')"/>
   <xsl:param name="dcTags"
              select="for $piece in $disseminationControlsList return $piece/text()"/>
   <xsl:param name="dcTagsFound"
              select="for $token in $dcTags return if ( index-of($partDisseminationControls_tok,$token) &gt; 0 and (not(index-of($bannerDisseminationControls_tok,$token) &gt; 0))) then $token else null"/>
   <xsl:param name="aeaTags"
              select="for $piece in $atomicEnergyMarkingsList return $piece/text()"/>
   <xsl:param name="aeaTagsFound"
              select="for $token in $aeaTags return if ( index-of($partAtomicEnergyMarkings_tok,$token) &gt; 0 and (not(index-of($bannerAtomicEnergyMarkings_tok,$token) &gt; 0))) then $token else null"/>

   <!--PATTERN ISM-ID-00220-->
<xsl:template match="text()" priority="-1" mode="M104"/>
   <xsl:template match="@*|node()" priority="-2" mode="M104">
      <xsl:apply-templates select="*" mode="M104"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00173-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                          and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^RD-SG', '^FRD-SG'))]"
                 priority="1000"
                 mode="M105">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                          and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^RD-SG', '^FRD-SG'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:classification = ('TS','S','C')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classification = ('TS','S','C')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
		   [ISM-ID-00173][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains a name token starting with 
        [RD-SG] or [FRD-SG], then attribute classification must 
        have a value of [TS], [S], or [C].
        
        Human Readable: Portions in a USA document that contain RD or FRD SIGMA 
        data must be marked CONFIDENTIAL, SECRET, or TOP SECRET.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M105"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M105"/>
   <xsl:template match="@*|node()" priority="-2" mode="M105">
      <xsl:apply-templates select="*" mode="M105"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00174-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD', 'FRD', 'TFNI'))]"
                 priority="1000"
                 mode="M106">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD', 'FRD', 'TFNI'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:classification = ('TS','S','C')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classification = ('TS','S','C')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00174][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD], [FRD], or [TFNI], 
        then attribute classification must have a value of [TS], [S], or [C].
        
        Human Readable: USA documents with RD, FRD, or TFNI data must be marked CONFIDENTIAL,
        SECRET, or TOP SECRET.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M106"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M106"/>
   <xsl:template match="@*|node()" priority="-2" mode="M106">
      <xsl:apply-templates select="*" mode="M106"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00175-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                        and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]"
                 priority="1000"
                 mode="M107">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                        and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:classification = ('TS','S')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classification = ('TS','S')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00175][Error] If ISM-CAPCO-RESOURCE and attribute 
			atomicEnergyMarkings contains the name token [RD-CNWDI], then attribute 
			classification must have a value of [TS] or [S].
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M107"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M107"/>
   <xsl:template match="@*|node()" priority="-2" mode="M107">
      <xsl:apply-templates select="*" mode="M107"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00176-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                        and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD', 'FRD'))]"
                 priority="1000"
                 mode="M108">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                        and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD', 'FRD'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($ISM_RESOURCE_ELEMENT/@ism:declassDate or $ISM_RESOURCE_ELEMENT/@ism:declassEvent)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($ISM_RESOURCE_ELEMENT/@ism:declassDate or $ISM_RESOURCE_ELEMENT/@ism:declassEvent)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00176][Error] Automatic declassification of documents containing 
        	RD or FRD information is prohibited. Attributes declassDate and 
        	declassEvent cannot be used in the classification authority block when 
        	RD or FRD is present.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M108"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M108"/>
   <xsl:template match="@*|node()" priority="-2" mode="M108">
      <xsl:apply-templates select="*" mode="M108"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00178-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:atomicEnergyMarkings]" priority="1000"
                 mode="M109">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:atomicEnergyMarkings, $atomicEnergyMarkingsList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:atomicEnergyMarkings, $atomicEnergyMarkingsList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00178][Error] If ISM_CAPCO_RESOURCE and attribute      atomicEnergyMarkings is specified, then each of its values must be ordered in accordance with      CVEnumISMAtomicEnergyMarkings.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:atomicEnergyMarkings, $atomicEnergyMarkingsList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:atomicEnergyMarkings"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M109"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M109"/>
   <xsl:template match="@*|node()" priority="-2" mode="M109">
      <xsl:apply-templates select="*" mode="M109"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00181-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and @ism:atomicEnergyMarkings                      and not(@ism:classification='U')]"
                 priority="1000"
                 mode="M110">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and @ism:atomicEnergyMarkings                      and not(@ism:classification='U')]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('UCNI', 'DCNI')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('UCNI', 'DCNI')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        [ISM-ID-00181][Error] If ISM_CAPCO_RESOURCE and element's 
        classification does not have a value of "U" then attribute atomicEnergyMarkings must not 
        contain the name token [UCNI] or [DCNI].
        
        Human Readable: UCNI and DCNI may only be used on UNCLASSIFIED portions.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M110"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M110"/>
   <xsl:template match="@*|node()" priority="-2" mode="M110">
      <xsl:apply-templates select="*" mode="M110"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00182-->
<xsl:template match="text()" priority="-1" mode="M111"/>
   <xsl:template match="@*|node()" priority="-2" mode="M111">
      <xsl:apply-templates select="*" mode="M111"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00183-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^RD-SG'))]"
                 priority="1000"
                 mode="M112">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^RD-SG'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00183][Error] If ISM_CAPCO_RESOURCE and attribute 
      atomicEnergyMarkings contains a name token starting with [RD-SG],
      then it must also contain the name token [RD].
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M112"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M112"/>
   <xsl:template match="@*|node()" priority="-2" mode="M112">
      <xsl:apply-templates select="*" mode="M112"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00184-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^FRD-SG'))]"
                 priority="1000"
                 mode="M113">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^FRD-SG'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00184][Error] If ISM_CAPCO_RESOURCE and attribute 
			atomicEnergyMarkings contains a name token starting with [FRD-SG],
			then it must also contain the name token [FRD].
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M113"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M113"/>
   <xsl:template match="@*|node()" priority="-2" mode="M113">
      <xsl:apply-templates select="*" mode="M113"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00185-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]"
                 priority="1000"
                 mode="M114">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00185][Error] If ISM_CAPCO_RESOURCE and attribute 
			atomicEnergyMarkings contains the name token [RD-CNWDI],
			then it must also contain the name token [RD].
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M114"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M114"/>
   <xsl:template match="@*|node()" priority="-2" mode="M114">
      <xsl:apply-templates select="*" mode="M114"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00015-->
<xsl:template match="text()" priority="-1" mode="M115"/>
   <xsl:template match="@*|node()" priority="-2" mode="M115">
      <xsl:apply-templates select="*" mode="M115"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00016-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:classification='U']" priority="1000"
                 mode="M116">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:classification='U']"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(                     @ism:classificationReason                  or @ism:classifiedBy                  or @ism:declassDate                  or @ism:declassEvent                  or @ism:declassException                  or @ism:derivativelyClassifiedBy                  or @ism:derivedFrom                  or @ism:SARIdentifier                 or @ism:SCIcontrols                 )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not( @ism:classificationReason or @ism:classifiedBy or @ism:declassDate or @ism:declassEvent or @ism:declassException or @ism:derivativelyClassifiedBy or @ism:derivedFrom or @ism:SARIdentifier or @ism:SCIcontrols )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00016][Error] If ISM_CAPCO_RESOURCE and attribute 
          classification has a value of [U], then attributes classificationReason,
          classifiedBy, derivativelyClassifiedBy, declassDate, declassEvent, 
          declassException, derivedFrom, SARIdentifier, or 
          SCIcontrols must not be specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M116"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M116"/>
   <xsl:template match="@*|node()" priority="-2" mode="M116">
      <xsl:apply-templates select="*" mode="M116"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00040-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                                      and util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))]"
                 priority="1000"
                 mode="M117">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                                      and util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             some $token in $classificationUSList satisfies              $token = @ism:classification             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $token in $classificationUSList satisfies $token = @ism:classification">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00040][Error] If ISM_CAPCO_RESOURCE and attribute    ownerProducer contains [USA] then attribute classification must have a   value in CVEnumISMClassificationUS.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M117"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M117"/>
   <xsl:template match="@*|node()" priority="-2" mode="M117">
      <xsl:apply-templates select="*" mode="M117"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00115-->
<xsl:template match="text()" priority="-1" mode="M118"/>
   <xsl:template match="@*|node()" priority="-2" mode="M118">
      <xsl:apply-templates select="*" mode="M118"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00142-->


	<!--RULE -->
<xsl:template match="*[$ISM_NSI_EO_APPLIES and @ism:classification!='U']" priority="1000"
                 mode="M119">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_NSI_EO_APPLIES and @ism:classification!='U']"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$ISM_RESOURCE_ELEMENT/@ism:classifiedBy               or $ISM_RESOURCE_ELEMENT/@ism:derivativelyClassifiedBy"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$ISM_RESOURCE_ELEMENT/@ism:classifiedBy or $ISM_RESOURCE_ELEMENT/@ism:derivativelyClassifiedBy">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00142][Error] Classified data including DOE data requires 
            either an original classifier or a derivative classifier be identified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M119"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M119"/>
   <xsl:template match="@*|node()" priority="-2" mode="M119">
      <xsl:apply-templates select="*" mode="M119"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00017-->


	<!--RULE -->
<xsl:template match="*[$ISM_NSI_EO_APPLIES and @ism:classifiedBy]" priority="1000"
                 mode="M120">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_NSI_EO_APPLIES and @ism:classifiedBy]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:classificationReason"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:classificationReason">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00017][Error] If ISM_NSI_EO_APPLIES and attribute 
        	classifiedBy is specified, then attribute classificationReason must 
        	be specified. 
        	
        	Human Readable: Documents under E.O. 13526 containing 
        	Originally Classified data require a classification reason to be
        	identified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M120"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M120"/>
   <xsl:template match="@*|node()" priority="-2" mode="M120">
      <xsl:apply-templates select="*" mode="M120"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00222-->


	<!--RULE -->
<xsl:template match="/*[$ISM_INTELREPORT_APPLIES]" priority="1000" mode="M121">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/*[$ISM_INTELREPORT_APPLIES]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="index-of($partPocType_tok, 'ICD-710') &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partPocType_tok, 'ICD-710') &gt; 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00222][Error] If ISM_INTELREPORT_APPLIES, then attribute pocType
        	must be specified with a value of [ICD-710] on some element in the
        	document.
        	
        	Human Readable: A document claiming compliance with ICD-710 must specify
        	a point-of-contact to whom questions about the document can be directed.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M121"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M121"/>
   <xsl:template match="@*|node()" priority="-2" mode="M121">
      <xsl:apply-templates select="*" mode="M121"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00003-->
<xsl:template match="text()" priority="-1" mode="M122"/>
   <xsl:template match="@*|node()" priority="-2" mode="M122">
      <xsl:apply-templates select="*" mode="M122"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00023-->
<xsl:template match="text()" priority="-1" mode="M123"/>
   <xsl:template match="@*|node()" priority="-2" mode="M123">
      <xsl:apply-templates select="*" mode="M123"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00133-->


	<!--RULE -->
<xsl:template match="*[$ISM_NSI_EO_APPLIES                      and util:containsAnyOfTheTokens(@ism:declassException, ('50X1-HUM', '50X2-WMD'))]"
                 priority="1000"
                 mode="M124">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_NSI_EO_APPLIES                      and util:containsAnyOfTheTokens(@ism:declassException, ('50X1-HUM', '50X2-WMD'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(@ism:declassDate or @ism:declassEvent)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@ism:declassDate or @ism:declassEvent)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00133][Error] If ISM_NSI_EO_APPLIES and attribute 
        	declassException is specified and contains the tokens 
        	[50X1-HUM], or [50X2-WMD], then attribute declassDate or declassEvent 
        	must NOT be specified.
        	
        	Human Readable: Documents under E.O. 13526 must not specify declassDate
        	or declassEvent if a declassException of 50X1-HUM or 50X2-WMD is specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M124"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M124"/>
   <xsl:template match="@*|node()" priority="-2" mode="M124">
      <xsl:apply-templates select="*" mode="M124"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00299-->


	<!--RULE -->
<xsl:template match="*[util:containsAnyTokenMatching(@ism:declassException, ('AEA'))]"
                 priority="1000"
                 mode="M125">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[util:containsAnyTokenMatching(@ism:declassException, ('AEA'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:atomicEnergyMarkings"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:atomicEnergyMarkings">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00299][Error] If an element contains the attribute declassException with a value of [AEA], 
			it must also contain the attribute atomicEnergyMarkings.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M125"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M125"/>
   <xsl:template match="@*|node()" priority="-2" mode="M125">
      <xsl:apply-templates select="*" mode="M125"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00101-->
<xsl:template match="text()" priority="-1" mode="M126"/>
   <xsl:template match="@*|node()" priority="-2" mode="M126">
      <xsl:apply-templates select="*" mode="M126"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00143-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:derivativelyClassifiedBy]"
                 priority="1000"
                 mode="M127">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:derivativelyClassifiedBy]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:derivedFrom"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:derivedFrom">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00143][Error] If ISM_CAPCO_RESOURCE and attribute 
        	derivativelyClassifiedBy is specified, then attribute derivedFrom must
        	be specified. 
        	
        	Human Readable: Derivatively Classified data including DOE data requires
        	a derived from value to be identified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M127"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M127"/>
   <xsl:template match="@*|node()" priority="-2" mode="M127">
      <xsl:apply-templates select="*" mode="M127"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00221-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:derivativelyClassifiedBy]"
                 priority="1000"
                 mode="M128">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:derivativelyClassifiedBy]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(@ism:classificationReason)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@ism:classificationReason)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00221][Error] If ISM_CAPCO_RESOURCE and attribute 
        	derivativelyClassifiedBy is specified, then attribute classificationReason
        	must not be specified.
        	
        	Human Readable: USA documents that are derivatively classified must not
        	specify a classification reason.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M128"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M128"/>
   <xsl:template match="@*|node()" priority="-2" mode="M128">
      <xsl:apply-templates select="*" mode="M128"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00167-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:displayOnlyTo]" priority="1000"
                 mode="M129">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:displayOnlyTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:displayOnlyTo, $displayOnlyToList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:displayOnlyTo, $displayOnlyToList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00167][Error] If ISM_CAPCO_RESOURCE and attribute displayOnlyTo is specified,      then each of its values must be ordered in accordance with CVEnumISMRelTo.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:displayOnlyTo, $displayOnlyToList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:displayOnlyTo"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M129"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M129"/>
   <xsl:template match="@*|node()" priority="-2" mode="M129">
      <xsl:apply-templates select="*" mode="M129"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00168-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY')))]"
                 priority="1000"
                 mode="M130">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY')))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(@ism:displayOnlyTo)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@ism:displayOnlyTo)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00168][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls is not specified or is specified and does not contain the name token 
            [DISPLAYONLY], then attribute displayOnlyTo must not be specified.
            
            Human Readable: If a portion in a USA document is not marked for DISPLAY ONLY dissemination, 
            it must not list countries to which it may be disclosed.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M130"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M130"/>
   <xsl:template match="@*|node()" priority="-2" mode="M130">
      <xsl:apply-templates select="*" mode="M130"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00004-->
<xsl:template match="text()" priority="-1" mode="M131"/>
   <xsl:template match="@*|node()" priority="-2" mode="M131">
      <xsl:apply-templates select="*" mode="M131"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00026-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:disseminationControls]" priority="1000"
                 mode="M132">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:disseminationControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:disseminationControls, $disseminationControlsList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:disseminationControls, $disseminationControlsList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00026][Error] If ISM_CAPCO_RESOURCE and attribute disseminationControls     is specified, then each of its values must be ordered in accordance with      CVEnumISMDissem.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:disseminationControls, $disseminationControlsList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:disseminationControls"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M132"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M132"/>
   <xsl:template match="@*|node()" priority="-2" mode="M132">
      <xsl:apply-templates select="*" mode="M132"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00027-->
<xsl:template match="text()" priority="-1" mode="M133"/>
   <xsl:template match="@*|node()" priority="-2" mode="M133">
      <xsl:apply-templates select="*" mode="M133"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00028-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC', 'EYES'))]"
                 priority="1000"
                 mode="M134">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC', 'EYES'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:classification=('TS', 'S', 'C')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classification=('TS', 'S', 'C')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00028][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [OC] or [EYES], 
            then attribute classification must have a value of [TS], [S], or [C].
            
            Human Readable: Portions marked for ORCON or EYES ONLY dissemination 
            in a USA document must be CONFIDENTIAL, SECRET, or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M134"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M134"/>
   <xsl:template match="@*|node()" priority="-2" mode="M134">
      <xsl:apply-templates select="*" mode="M134"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00029-->
<xsl:template match="text()" priority="-1" mode="M135"/>
   <xsl:template match="@*|node()" priority="-2" mode="M135">
      <xsl:apply-templates select="*" mode="M135"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00030-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))]"
                 priority="1000"
                 mode="M136">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:classification='U'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:classification='U'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00030][Error] If ISM_CAPCO_RESOURCE and attribute 
        	disseminationControls contains the name token [FOUO], then attribute
        	classification must have a value of [U].
        	
        	Human Readable: Portions marked for FOUO dissemination in a USA document
        	must be classified UNCLASSIFIED.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M136"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M136"/>
   <xsl:template match="@*|node()" priority="-2" mode="M136">
      <xsl:apply-templates select="*" mode="M136"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00031-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES'))]"
                 priority="1000"
                 mode="M137">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:releasableTo"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:releasableTo">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00031][Error] If ISM_CAPCO_RESOURCE and attribute 
        	disseminationControls contains the name token [REL] or [EYES], then 
        	attribute releasableTo must be specified.
        	
        	Human Readable: USA documents containing REL TO or EYES ONLY 
        	dissemination must specify to which countries the document is releasable.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M137"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M137"/>
   <xsl:template match="@*|node()" priority="-2" mode="M137">
      <xsl:apply-templates select="*" mode="M137"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00033-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                                    and util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES', 'NF'))]"
                 priority="1000"
                 mode="M138">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                                    and util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES', 'NF'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     for $token in tokenize(normalize-space(string(@ism:disseminationControls)),' ') return      if($token = ('REL', 'EYES', 'NF'))      then 1      else null    ) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( for $token in tokenize(normalize-space(string(@ism:disseminationControls)),' ') return if($token = ('REL', 'EYES', 'NF')) then 1 else null ) = 1">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00033][Error] If ISM_CAPCO_RESOURCE, then tokens [REL], [EYES]    and [NF] are mutually exclusive for attribute disseminationControls.   '"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M138"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M138"/>
   <xsl:template match="@*|node()" priority="-2" mode="M138">
      <xsl:apply-templates select="*" mode="M138"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00034-->
<xsl:template match="text()" priority="-1" mode="M139"/>
   <xsl:template match="@*|node()" priority="-2" mode="M139">
      <xsl:apply-templates select="*" mode="M139"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00050-->
<xsl:template match="text()" priority="-1" mode="M140"/>
   <xsl:template match="@*|node()" priority="-2" mode="M140">
      <xsl:apply-templates select="*" mode="M140"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00052-->
<xsl:template match="text()" priority="-1" mode="M141"/>
   <xsl:template match="@*|node()" priority="-2" mode="M141">
      <xsl:apply-templates select="*" mode="M141"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00053-->
<xsl:template match="text()" priority="-1" mode="M142"/>
   <xsl:template match="@*|node()" priority="-2" mode="M142">
      <xsl:apply-templates select="*" mode="M142"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00054-->
<xsl:template match="text()" priority="-1" mode="M143"/>
   <xsl:template match="@*|node()" priority="-2" mode="M143">
      <xsl:apply-templates select="*" mode="M143"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00091-->
<xsl:template match="text()" priority="-1" mode="M144"/>
   <xsl:template match="@*|node()" priority="-2" mode="M144">
      <xsl:apply-templates select="*" mode="M144"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00092-->
<xsl:template match="text()" priority="-1" mode="M145"/>
   <xsl:template match="@*|node()" priority="-2" mode="M145">
      <xsl:apply-templates select="*" mode="M145"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00093-->
<xsl:template match="text()" priority="-1" mode="M146"/>
   <xsl:template match="@*|node()" priority="-2" mode="M146">
      <xsl:apply-templates select="*" mode="M146"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00094-->
<xsl:template match="text()" priority="-1" mode="M147"/>
   <xsl:template match="@*|node()" priority="-2" mode="M147">
      <xsl:apply-templates select="*" mode="M147"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00106-->
<xsl:template match="text()" priority="-1" mode="M148"/>
   <xsl:template match="@*|node()" priority="-2" mode="M148">
      <xsl:apply-templates select="*" mode="M148"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00107-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))]"
                 priority="1000"
                 mode="M149">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:classification=('TS', 'S')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classification=('TS', 'S')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00107][Error] If ISM_CAPCO_RESOURCE and attribute 
        	disseminationControls contains the name token [IMC] then attribute 
        	classification must have a value of [TS] or [S].
        	
        	Human Readable:  IMCON data is SECRET (S), but may appear with 
        	S or TOP SECRET data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M149"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M149"/>
   <xsl:template match="@*|node()" priority="-2" mode="M149">
      <xsl:apply-templates select="*" mode="M149"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00117-->
<xsl:template match="text()" priority="-1" mode="M150"/>
   <xsl:template match="@*|node()" priority="-2" mode="M150">
      <xsl:apply-templates select="*" mode="M150"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00120-->
<xsl:template match="text()" priority="-1" mode="M151"/>
   <xsl:template match="@*|node()" priority="-2" mode="M151">
      <xsl:apply-templates select="*" mode="M151"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00124-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RELIDO'))]"
                 priority="1000"
                 mode="M152">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RELIDO'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00124][Warning] If ISM_CAPCO_RESOURCE and
          1. Attribute ownerProducer does not contain [USA].
          AND
          2. Attribute disseminationControls contains [RELIDO]
          
          Human Readable: RELIDO is not authorized for non-US portions.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M152"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M152"/>
   <xsl:template match="@*|node()" priority="-2" mode="M152">
      <xsl:apply-templates select="*" mode="M152"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00140-->
<xsl:template match="text()" priority="-1" mode="M153"/>
   <xsl:template match="@*|node()" priority="-2" mode="M153">
      <xsl:apply-templates select="*" mode="M153"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00164-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RS'))]"
                 priority="1000"
                 mode="M154">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RS'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:classification=('TS', 'S')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classification=('TS', 'S')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00164][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [RS],
            then attribute classification must have a value of [TS] or [S].
            
            Human Readable: USA documents with RISK SENSITIVE dissemination must
            be classified SECRET or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M154"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M154"/>
   <xsl:template match="@*|node()" priority="-2" mode="M154">
      <xsl:apply-templates select="*" mode="M154"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00169-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                                    and util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO', 'NF'))]"
                 priority="1000"
                 mode="M155">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                                    and util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO', 'NF'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     for $token in tokenize(normalize-space(string(@ism:disseminationControls)),' ') return      if($token = ('DISPLAYONLY', 'RELIDO', 'NF'))      then 1      else null    ) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( for $token in tokenize(normalize-space(string(@ism:disseminationControls)),' ') return if($token = ('DISPLAYONLY', 'RELIDO', 'NF')) then 1 else null ) = 1">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'    [ISM-ID-00169][Error] If ISM_CAPCO_RESOURCE, then for attribute disseminationControls     the name tokens [DISPLAYONLY], [RELIDO] and [NF] are mutually exclusive.        Human Readable: In a USA document, DISPLAY ONLY, RELIDO and NO FOREIGN dissemination are     mutually exclusive for a single element.   '"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M155"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M155"/>
   <xsl:template match="@*|node()" priority="-2" mode="M155">
      <xsl:apply-templates select="*" mode="M155"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00213-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY'))]"
                 priority="1000"
                 mode="M156">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:displayOnlyTo"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:displayOnlyTo">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00213][Error] If ISM_CAPCO_RESOURCE and attribute 
        	disseminationControls contains the name token [DISPLAYONLY], then 
        	attribute displayOnlyTo must be specified.
        	
        	Human Readable: A USA document with DISPLAY ONLY dissemination must 
        	indicate the countries to which it may be disclosed.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M156"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M156"/>
   <xsl:template match="@*|node()" priority="-2" mode="M156">
      <xsl:apply-templates select="*" mode="M156"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00215-->
<xsl:template match="text()" priority="-1" mode="M157"/>
   <xsl:template match="@*|node()" priority="-2" mode="M157">
      <xsl:apply-templates select="*" mode="M157"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00302-->
<xsl:template match="text()" priority="-1" mode="M158"/>
   <xsl:template match="@*|node()" priority="-2" mode="M158">
      <xsl:apply-templates select="*" mode="M158"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00005-->
<xsl:template match="text()" priority="-1" mode="M159"/>
   <xsl:template match="@*|node()" priority="-2" mode="M159">
      <xsl:apply-templates select="*" mode="M159"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00024-->
<xsl:template match="text()" priority="-1" mode="M160"/>
   <xsl:template match="@*|node()" priority="-2" mode="M160">
      <xsl:apply-templates select="*" mode="M160"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00095-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:FGIsourceOpen]" priority="1000"
                 mode="M161">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:FGIsourceOpen]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:FGIsourceOpen, $FGIsourceOpenList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:FGIsourceOpen, $FGIsourceOpenList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00095][Error] If ISM_CAPCO_RESOURCE and attribute FGIsourceOpen is      specified then each of its values must be ordered in accordance with CVEnumISMFGIOpen.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:FGIsourceOpen, $FGIsourceOpenList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:FGIsourceOpen"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M161"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M161"/>
   <xsl:template match="@*|node()" priority="-2" mode="M161">
      <xsl:apply-templates select="*" mode="M161"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00216-->
<xsl:template match="text()" priority="-1" mode="M162"/>
   <xsl:template match="@*|node()" priority="-2" mode="M162">
      <xsl:apply-templates select="*" mode="M162"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00232-->
<xsl:template match="text()" priority="-1" mode="M163"/>
   <xsl:template match="@*|node()" priority="-2" mode="M163">
      <xsl:apply-templates select="*" mode="M163"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00233-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                  and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                 and @ism:FGIsourceOpen                    and util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))]"
                 priority="1000"
                 mode="M164">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                  and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                 and @ism:FGIsourceOpen                    and util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00233][Error] If ISM_CAPCO_RESOURCE, then any portion with  
        	attribute FGIsourceOpen specified and an ownerProducer containing [USA]
        	must not have attribute disseminationControls containing [DISPLAYONLY] 
        	or [RELIDO].
        	
        	Human Readable: DISPLAYONLY and RELIDO are not authorized for use on portions 
        	containing Foreign Government Information.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M164"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M164"/>
   <xsl:template match="@*|node()" priority="-2" mode="M164">
      <xsl:apply-templates select="*" mode="M164"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00006-->
<xsl:template match="text()" priority="-1" mode="M165"/>
   <xsl:template match="@*|node()" priority="-2" mode="M165">
      <xsl:apply-templates select="*" mode="M165"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00025-->
<xsl:template match="text()" priority="-1" mode="M166"/>
   <xsl:template match="@*|node()" priority="-2" mode="M166">
      <xsl:apply-templates select="*" mode="M166"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00096-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:FGIsourceProtected]" priority="1000"
                 mode="M167">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:FGIsourceProtected]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:FGIsourceProtected, $FGIsourceProtectedList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:FGIsourceProtected, $FGIsourceProtectedList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00096][Error] If ISM_CAPCO_RESOURCE and attribute FGIsourceProtected is specified      then each of its values must be ordered in accordance with CVEnumISMFGIProtected.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:FGIsourceProtected, $FGIsourceProtectedList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:FGIsourceProtected"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M167"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M167"/>
   <xsl:template match="@*|node()" priority="-2" mode="M167">
      <xsl:apply-templates select="*" mode="M167"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00097-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:FGIsourceProtected]" priority="1000"
                 mode="M168">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:FGIsourceProtected]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string(./@ism:FGIsourceProtected))='FGI'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string(./@ism:FGIsourceProtected))='FGI'">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00097][Warning] If ISM_CAPCO_RESOURCE and attribute FGIsourceProtected is 
        	specified with a value other than [FGI] then the value(s) must not be discoverable in IC shared spaces.
        	
        	Human Readable: FGI Protected should rarely if ever be seen outside of an agency's internal systems.  
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M168"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M168"/>
   <xsl:template match="@*|node()" priority="-2" mode="M168">
      <xsl:apply-templates select="*" mode="M168"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00217-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:FGIsourceProtected]" priority="1000"
                 mode="M169">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:FGIsourceProtected]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string(@ism:FGIsourceProtected))='FGI'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string(@ism:FGIsourceProtected))='FGI'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00217][Error] If ISM_CAPCO_RESOURCE attribute FGIsourceProtected
        	contains [FGI], it must be the only value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M169"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M169"/>
   <xsl:template match="@*|node()" priority="-2" mode="M169">
      <xsl:apply-templates select="*" mode="M169"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00218-->
<xsl:template match="text()" priority="-1" mode="M170"/>
   <xsl:template match="@*|node()" priority="-2" mode="M170">
      <xsl:apply-templates select="*" mode="M170"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00234-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                 and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                 and @ism:FGIsourceProtected                       and util:containsAnyOfTheTokens(@ism:ownerProducer,('USA'))  ]"
                 priority="1000"
                 mode="M171">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                 and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                 and @ism:FGIsourceProtected                       and util:containsAnyOfTheTokens(@ism:ownerProducer,('USA'))  ]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:disseminationControls,('RELIDO', 'DISPLAYONLY')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:disseminationControls,('RELIDO', 'DISPLAYONLY')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00234][Error] If ISM_CAPCO_RESOURCE, then any portion with  
          attribute FGIsourceProtected specified and an ownerProducer containing [USA]
          must not have attribute disseminationControls containing token 
          [RELIDO] or [DISPLAYONLY].
          
          Human Readable: RELIDO and DISPLAYONLY are not authorized for use on portions containing
          Foreign Government Information.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M171"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M171"/>
   <xsl:template match="@*|node()" priority="-2" mode="M171">
      <xsl:apply-templates select="*" mode="M171"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00235-->
<xsl:template match="text()" priority="-1" mode="M172"/>
   <xsl:template match="@*|node()" priority="-2" mode="M172">
      <xsl:apply-templates select="*" mode="M172"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00002-->


	<!--RULE -->
<xsl:template match="*[@ism:*]" priority="1000" mode="M173">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:*]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $attribute in @ism:* satisfies                     normalize-space(string($attribute))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $attribute in @ism:* satisfies normalize-space(string($attribute))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00002][Error] For every attribute that is used in a 
        	document a non-null value must be present.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M173"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M173"/>
   <xsl:template match="@*|node()" priority="-2" mode="M173">
      <xsl:apply-templates select="*" mode="M173"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00012-->


	<!--RULE -->
<xsl:template match="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType)]"
                 priority="1000"
                 mode="M174">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:ownerProducer and @ism:classification"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:ownerProducer and @ism:classification">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00012][Error] If any of the attributes defined in 
        	this DES other than DESVersion, unregisteredNoticeType, or pocType 
        	are specified for an element, then attributes classification and 
        	ownerProducer must be specified for the element.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M174"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M174"/>
   <xsl:template match="@*|node()" priority="-2" mode="M174">
      <xsl:apply-templates select="*" mode="M174"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00098-->
<xsl:template match="text()" priority="-1" mode="M175"/>
   <xsl:template match="@*|node()" priority="-2" mode="M175">
      <xsl:apply-templates select="*" mode="M175"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00102-->


	<!--RULE -->
<xsl:template match="/" priority="1000" mode="M176">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="some $element in descendant-or-self::node() satisfies $element/@ism:DESVersion"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $element in descendant-or-self::node() satisfies $element/@ism:DESVersion">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00102][Error] The attribute 
            DESVersion in the namespace urn:us:gov:ic:ism must be specified.
            
            Human Readable: The data encoding specification version must 
            be specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M176"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M176"/>
   <xsl:template match="@*|node()" priority="-2" mode="M176">
      <xsl:apply-templates select="*" mode="M176"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00103-->


	<!--RULE -->
<xsl:template match="/*" priority="1000" mode="M177">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="some $token in //*[(@ism:*)] satisfies               $token/@ism:resourceElement=true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $token in //*[(@ism:*)] satisfies $token/@ism:resourceElement=true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00103][Error] At least one element must have attribute 
        	resourceElement specified with a value of [true].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M177"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M177"/>
   <xsl:template match="@*|node()" priority="-2" mode="M177">
      <xsl:apply-templates select="*" mode="M177"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00119-->


	<!--RULE -->
<xsl:template match="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType)                              and $ISM_CAPCO_RESOURCE                              and $ISM_ICDOCUMENT_APPLIES                              and util:contributesToRollup(.)                             and not(@ism:classification='U')]"
                 priority="1000"
                 mode="M178">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType)                              and $ISM_CAPCO_RESOURCE                              and $ISM_ICDOCUMENT_APPLIES                              and util:contributesToRollup(.)                             and not(@ism:classification='U')]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO','REL','EYES', 'NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO','REL','EYES', 'NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00119][Error] If ISM_CAPCO_RESOURCE and ISM_ICDOCUMENT_APPLIES
        	and attribute classification is specified with a value other than [U],
        	then attribute disseminationControls must contain one or more of the
        	following named tokens: [DISPLAYONLY], [REL], [RELIDO], [EYES], or [NF].
        	
        	Human Readable: All classified NSI that claims compliance with 
        	ICD 710 must have an appropriate foreign disclosure or release marking.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M178"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M178"/>
   <xsl:template match="@*|node()" priority="-2" mode="M178">
      <xsl:apply-templates select="*" mode="M178"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00125-->


	<!--RULE -->
<xsl:template match="*[@ism:*]" priority="1000" mode="M179">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:*]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $attr in @ism:* satisfies               $attr[local-name() = $validAttributeList]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $attr in @ism:* satisfies $attr[local-name() = $validAttributeList]">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'         [ISM-ID-00125][Error] If any attributes in namespace          urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMAttributes.xml.                   Human Readable: Ensure that attributes in the ISM namespace are defined by ISM.XML.         '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M179"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M179"/>
   <xsl:template match="@*|node()" priority="-2" mode="M179">
      <xsl:apply-templates select="*" mode="M179"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00126-->


	<!--RULE -->
<xsl:template match="*[@ism:*]" priority="1000" mode="M180">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:*]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(./@xs:any)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(./@xs:any)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00126][Error] Attributes with namespace urn:us:gov:ic:ism must 
        	not appear with attribute @xs:any. 
        	
        	Human Readable: Ensure that no attributes that appear to be in the 
        	ISM namespace, but are not defined by ISM.XML, are used in a schema
        	that might have an xs:any.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M180"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M180"/>
   <xsl:template match="@*|node()" priority="-2" mode="M180">
      <xsl:apply-templates select="*" mode="M180"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00166-->


	<!--RULE -->
<xsl:template match="*[@ism:classification]" priority="1000" mode="M181">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:classification]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:classification),      document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:classification), document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00166'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="classification"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:classification),     document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M181"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M181"/>
   <xsl:template match="@*|node()" priority="-2" mode="M181">
      <xsl:apply-templates select="*" mode="M181"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00170-->


	<!--RULE -->
<xsl:template match="*[@ism:classification]" priority="1000" mode="M182">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:classification]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:classification),    document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:classification), document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00170'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="classification"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:classification),     document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M182"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M182"/>
   <xsl:template match="@*|node()" priority="-2" mode="M182">
      <xsl:apply-templates select="*" mode="M182"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00179-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M183">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:disseminationControls),      document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:disseminationControls), document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00179'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="disseminationControls"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:disseminationControls),     document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M183"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M183"/>
   <xsl:template match="@*|node()" priority="-2" mode="M183">
      <xsl:apply-templates select="*" mode="M183"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00180-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M184">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:disseminationControls),    document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:disseminationControls), document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00180'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="disseminationControls"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:disseminationControls),     document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M184"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M184"/>
   <xsl:template match="@*|node()" priority="-2" mode="M184">
      <xsl:apply-templates select="*" mode="M184"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00188-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceOpen]" priority="1000" mode="M185">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:FGIsourceOpen]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:FGIsourceOpen),      document('../../CVE/ISM/CVEnumISMFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:FGIsourceOpen), document('../../CVE/ISM/CVEnumISMFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00188'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="FGIsourceOpen"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:FGIsourceOpen),     document('../../CVE/ISM/CVEnumISMFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M185"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M185"/>
   <xsl:template match="@*|node()" priority="-2" mode="M185">
      <xsl:apply-templates select="*" mode="M185"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00189-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceOpen]" priority="1000" mode="M186">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:FGIsourceOpen]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:FGIsourceOpen),    document('../../CVE/ISM/CVEnumISMFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:FGIsourceOpen), document('../../CVE/ISM/CVEnumISMFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00189'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="FGIsourceOpen"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:FGIsourceOpen),     document('../../CVE/ISM/CVEnumISMFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M186"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M186"/>
   <xsl:template match="@*|node()" priority="-2" mode="M186">
      <xsl:apply-templates select="*" mode="M186"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00190-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceProtected]" priority="1000" mode="M187">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:FGIsourceProtected]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:FGIsourceProtected),      document('../../CVE/ISM/CVEnumISMFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:FGIsourceProtected), document('../../CVE/ISM/CVEnumISMFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00190'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="FGIsourceProtected"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:FGIsourceProtected),     document('../../CVE/ISM/CVEnumISMFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M187"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M187"/>
   <xsl:template match="@*|node()" priority="-2" mode="M187">
      <xsl:apply-templates select="*" mode="M187"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00191-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceProtected]" priority="1000" mode="M188">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:FGIsourceProtected]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:FGIsourceProtected),    document('../../CVE/ISM/CVEnumISMFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:FGIsourceProtected), document('../../CVE/ISM/CVEnumISMFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00191'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="FGIsourceProtected"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:FGIsourceProtected),     document('../../CVE/ISM/CVEnumISMFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M188"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M188"/>
   <xsl:template match="@*|node()" priority="-2" mode="M188">
      <xsl:apply-templates select="*" mode="M188"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00192-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M189">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:nonICmarkings),      document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:nonICmarkings), document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00192'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="nonICmarkings"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:nonICmarkings),     document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M189"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M189"/>
   <xsl:template match="@*|node()" priority="-2" mode="M189">
      <xsl:apply-templates select="*" mode="M189"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00193-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M190">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:nonICmarkings),    document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:nonICmarkings), document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00193'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="nonICmarkings"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:nonICmarkings),     document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M190"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M190"/>
   <xsl:template match="@*|node()" priority="-2" mode="M190">
      <xsl:apply-templates select="*" mode="M190"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00194-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M191">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:noticeType),      document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:noticeType), document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00194'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="noticeType"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:noticeType),     document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M191"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M191"/>
   <xsl:template match="@*|node()" priority="-2" mode="M191">
      <xsl:apply-templates select="*" mode="M191"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00195-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M192">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:noticeType),    document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:noticeType), document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00195'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="noticeType"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:noticeType),     document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M192"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M192"/>
   <xsl:template match="@*|node()" priority="-2" mode="M192">
      <xsl:apply-templates select="*" mode="M192"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00196-->


	<!--RULE -->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M193">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:ownerProducer]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:ownerProducer),      document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:ownerProducer), document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00196'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="ownerProducer"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:ownerProducer),     document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M193"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M193"/>
   <xsl:template match="@*|node()" priority="-2" mode="M193">
      <xsl:apply-templates select="*" mode="M193"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00197-->


	<!--RULE -->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M194">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:ownerProducer]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:ownerProducer),    document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:ownerProducer), document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00197'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="ownerProducer"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:ownerProducer),     document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M194"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M194"/>
   <xsl:template match="@*|node()" priority="-2" mode="M194">
      <xsl:apply-templates select="*" mode="M194"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00198-->


	<!--RULE -->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M195">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:releasableTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:releasableTo),      document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:releasableTo), document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00198'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="releasableTo"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:releasableTo),     document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M195"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M195"/>
   <xsl:template match="@*|node()" priority="-2" mode="M195">
      <xsl:apply-templates select="*" mode="M195"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00199-->


	<!--RULE -->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M196">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:releasableTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:releasableTo),    document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:releasableTo), document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00199'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="releasableTo"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:releasableTo),     document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M196"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M196"/>
   <xsl:template match="@*|node()" priority="-2" mode="M196">
      <xsl:apply-templates select="*" mode="M196"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00200-->


	<!--RULE -->
<xsl:template match="*[@ism:displayOnlyTo]" priority="1000" mode="M197">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:displayOnlyTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:displayOnlyTo),      document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:displayOnlyTo), document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00200'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="displayOnlyTo"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:displayOnlyTo),     document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M197"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M197"/>
   <xsl:template match="@*|node()" priority="-2" mode="M197">
      <xsl:apply-templates select="*" mode="M197"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00201-->


	<!--RULE -->
<xsl:template match="*[@ism:displayOnlyTo]" priority="1000" mode="M198">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:displayOnlyTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:displayOnlyTo),    document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:displayOnlyTo), document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00201'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="displayOnlyTo"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:displayOnlyTo),     document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M198"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M198"/>
   <xsl:template match="@*|node()" priority="-2" mode="M198">
      <xsl:apply-templates select="*" mode="M198"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00202-->


	<!--RULE -->
<xsl:template match="*[@ism:SARIdentifier]" priority="1000" mode="M199">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SARIdentifier]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:SARIdentifier),      document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:SARIdentifier), document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00202'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="SARIdentifier"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:SARIdentifier),     document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M199"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M199"/>
   <xsl:template match="@*|node()" priority="-2" mode="M199">
      <xsl:apply-templates select="*" mode="M199"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00203-->


	<!--RULE -->
<xsl:template match="*[@ism:SARIdentifier]" priority="1000" mode="M200">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SARIdentifier]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:SARIdentifier),    document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:SARIdentifier), document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00203'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="SARIdentifier"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:SARIdentifier),     document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M200"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M200"/>
   <xsl:template match="@*|node()" priority="-2" mode="M200">
      <xsl:apply-templates select="*" mode="M200"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00204-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M201">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:SCIcontrols),      document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:SCIcontrols), document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00204'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="SCIcontrols"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:SCIcontrols),     document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M201"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M201"/>
   <xsl:template match="@*|node()" priority="-2" mode="M201">
      <xsl:apply-templates select="*" mode="M201"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00205-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M202">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:SCIcontrols),    document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:SCIcontrols), document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00205'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="SCIcontrols"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:SCIcontrols),     document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M202"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M202"/>
   <xsl:template match="@*|node()" priority="-2" mode="M202">
      <xsl:apply-templates select="*" mode="M202"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00206-->


	<!--RULE -->
<xsl:template match="*[@ism:declassException]" priority="1000" mode="M203">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:declassException]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:declassException),      document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:declassException), document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00206'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="declassException"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:declassException),     document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M203"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M203"/>
   <xsl:template match="@*|node()" priority="-2" mode="M203">
      <xsl:apply-templates select="*" mode="M203"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00207-->


	<!--RULE -->
<xsl:template match="*[@ism:declassException]" priority="1000" mode="M204">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:declassException]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:declassException),    document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:declassException), document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00207'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="declassException"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:declassException),     document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M204"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M204"/>
   <xsl:template match="@*|node()" priority="-2" mode="M204">
      <xsl:apply-templates select="*" mode="M204"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00208-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M205">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:atomicEnergyMarkings),      document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:atomicEnergyMarkings), document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00208'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="atomicEnergyMarkings"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:atomicEnergyMarkings),     document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M205"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M205"/>
   <xsl:template match="@*|node()" priority="-2" mode="M205">
      <xsl:apply-templates select="*" mode="M205"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00209-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M206">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:atomicEnergyMarkings),    document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:atomicEnergyMarkings), document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00209'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="atomicEnergyMarkings"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:atomicEnergyMarkings),     document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M206"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M206"/>
   <xsl:template match="@*|node()" priority="-2" mode="M206">
      <xsl:apply-templates select="*" mode="M206"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00210-->


	<!--RULE -->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M207">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonUSControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     dvf:deprecated(      string(@ism:nonUSControls),      document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],      $ISM_RESOURCE_CREATE_DATE,      false()     )    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:nonUSControls), document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false() ) )=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00210'"/>
                  <xsl:text/>][Warning] For attribute 
			<xsl:text/>
                  <xsl:value-of select="nonUSControls"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:nonUSControls),     document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     false())     "/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M207"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M207"/>
   <xsl:template match="@*|node()" priority="-2" mode="M207">
      <xsl:apply-templates select="*" mode="M207"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00211-->


	<!--RULE -->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M208">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonUSControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(    dvf:deprecated(    string(@ism:nonUSControls),    document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated],    $ISM_RESOURCE_CREATE_DATE,    true())    )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:nonUSControls), document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00211'"/>
                  <xsl:text/>][Error] For attribute 
			<xsl:text/>
                  <xsl:value-of select="nonUSControls"/>
                  <xsl:text/>, value(s)
			<xsl:text/>
                  <xsl:value-of select="     dvf:deprecated(     string(@ism:nonUSControls),     document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated],     $ISM_RESOURCE_CREATE_DATE,     true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M208"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M208"/>
   <xsl:template match="@*|node()" priority="-2" mode="M208">
      <xsl:apply-templates select="*" mode="M208"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00212-->
<xsl:template match="text()" priority="-1" mode="M209"/>
   <xsl:template match="@*|node()" priority="-2" mode="M209">
      <xsl:apply-templates select="*" mode="M209"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00223-->


	<!--RULE -->
<xsl:template match="ism:*" priority="1000" mode="M210">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ism:*"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             some $token in $validElementList satisfies              $token = local-name()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $token in $validElementList satisfies $token = local-name()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00223][Error] If any elements in namespace    urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMElements.xml.       Human Readable: Ensure that elements in the ISM namespace are defined by ISM.XML.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M210"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M210"/>
   <xsl:template match="@*|node()" priority="-2" mode="M210">
      <xsl:apply-templates select="*" mode="M210"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00226-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M211">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(@ism:unregisteredNoticeType)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@ism:unregisteredNoticeType)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00226][Error]
            @ism:noticeType and @ism:unregisteredNoticeType may not both be 
            applied to the same element.
            
            Human Readable: The ISM attributes noticeType and unregisteredNoticeType 
            are mutually exclusive and cannot both be applied to the same element. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M211"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M211"/>
   <xsl:template match="@*|node()" priority="-2" mode="M211">
      <xsl:apply-templates select="*" mode="M211"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00236-->


	<!--RULE -->
<xsl:template match="*[@ism:*]" priority="1000" mode="M212">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:*]"/>
      <xsl:variable name="errMsg_ValueNotFound"
                    select="'             [ISM-ID-00236][Error] If ISM_CAPCO_RESOURCE and attribute              ownerProducer contains [USA] then attribute classification must have a value in              CVEnumISMClassificationUS.xml.'             "/>
      <xsl:variable name="dupAttrs"
                    select="for $attr in ./@ism:* return if(count(distinct-values(tokenize(string($attr),' '))) != count(tokenize(string($attr),' '))) then $attr else null"/>
      <xsl:variable name="hasDups" select="count($dupAttrs)&gt;0"/>
      <xsl:variable name="dupValues"
                    select="     if ($hasDups) then     distinct-values(     for $attrib in $dupAttrs return     for $each in tokenize(string($attrib),' ') return     if(count(index-of(tokenize(string($attrib),' '), $each))&gt;1)     then concat(string($each),' in attribute ',$attrib/name(),'; ')     else null)     else null     "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasDups)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasDups)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00236][Error] Duplicate tokens
            are not permitted in ISM attributes. Duplicate values found: [<xsl:text/>
                  <xsl:value-of select="$dupValues"/>
                  <xsl:text/>]</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M212"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M212"/>
   <xsl:template match="@*|node()" priority="-2" mode="M212">
      <xsl:apply-templates select="*" mode="M212"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00300-->


	<!--RULE -->
<xsl:template match="*[@ism:DESVersion]" priority="1000" mode="M213">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:DESVersion]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:DESVersion='10'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:DESVersion='10'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00300][Error] DESVersion attributes must be specified as version 10.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M213"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M213"/>
   <xsl:template match="@*|node()" priority="-2" mode="M213">
      <xsl:apply-templates select="*" mode="M213"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00007-->
<xsl:template match="text()" priority="-1" mode="M214"/>
   <xsl:template match="@*|node()" priority="-2" mode="M214">
      <xsl:apply-templates select="*" mode="M214"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00035-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:nonICmarkings]" priority="1000"
                 mode="M215">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:nonICmarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:nonICmarkings, $nonICmarkingsList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:nonICmarkings, $nonICmarkingsList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00035][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings is      specified, then each of its values must be ordered in accordance with CVEnumISMNonIC.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:nonICmarkings, $nonICmarkingsList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:nonICmarkings"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M215"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M215"/>
   <xsl:template match="@*|node()" priority="-2" mode="M215">
      <xsl:apply-templates select="*" mode="M215"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00036-->
<xsl:template match="text()" priority="-1" mode="M216"/>
   <xsl:template match="@*|node()" priority="-2" mode="M216">
      <xsl:apply-templates select="*" mode="M216"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00037-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                 and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU', 'SBU-NF'))]"
                 priority="1000"
                 mode="M217">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                 and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU', 'SBU-NF'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:classification='U'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:classification='U'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00037][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings
          contains the name token [SBU], [SBU-NF] then attribute
          classification must have a value of [U].
          
          Human Readable: SBU, SBU-NF data must be marked UNCLASSIFIED
          in USA documents.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M217"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M217"/>
   <xsl:template match="@*|node()" priority="-2" mode="M217">
      <xsl:apply-templates select="*" mode="M217"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00038-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE           and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD', 'ND'))]"
                 priority="1000"
                 mode="M218">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE           and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD', 'ND'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     for $token in tokenize(normalize-space(string(@ism:nonICmarkings)),' ') return      if($token = ('XD', 'ND'))      then 1      else null    ) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( for $token in tokenize(normalize-space(string(@ism:nonICmarkings)),' ') return if($token = ('XD', 'ND')) then 1 else null ) = 1">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00038][Error] If ISM_CAPCO_RESOURCE, then Name tokens    [XD] and [ND] are mutually exclusive for attribute nonICmarkings.      Human Readable: USA documents must not specify both XD and ND on a    single element.   '"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M218"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M218"/>
   <xsl:template match="@*|node()" priority="-2" mode="M218">
      <xsl:apply-templates select="*" mode="M218"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00051-->
<xsl:template match="text()" priority="-1" mode="M219"/>
   <xsl:template match="@*|node()" priority="-2" mode="M219">
      <xsl:apply-templates select="*" mode="M219"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00055-->
<xsl:template match="text()" priority="-1" mode="M220"/>
   <xsl:template match="@*|node()" priority="-2" mode="M220">
      <xsl:apply-templates select="*" mode="M220"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00148-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE          and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES', 'LES-NF'))]"
                 priority="1000"
                 mode="M221">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE          and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES', 'LES-NF'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    count(     for $token in tokenize(normalize-space(string(@ism:nonICmarkings)),' ') return      if($token = ('LES', 'LES-NF'))      then 1      else null    ) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( for $token in tokenize(normalize-space(string(@ism:nonICmarkings)),' ') return if($token = ('LES', 'LES-NF')) then 1 else null ) = 1">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00148][Error] If ISM_CAPCO_RESOURCE, then Name tokens    [LES] and [LES-NF] are mutually exclusive for attribute nonICmarkings.      Human Readable: USA documents must not specify both LES and LES-NF    on a single element.   '"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M221"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M221"/>
   <xsl:template match="@*|node()" priority="-2" mode="M221">
      <xsl:apply-templates select="*" mode="M221"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00225-->


	<!--RULE -->
<xsl:template match="*[$ISM_ICDOCUMENT_APPLIES and @ism:nonICmarkings]" priority="1000"
                 mode="M222">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_ICDOCUMENT_APPLIES and @ism:nonICmarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(util:containsAnyTokenMatching(@ism:nonICmarkings, ('ACCM', 'NNPI')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyTokenMatching(@ism:nonICmarkings, ('ACCM', 'NNPI')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00225][Error] If ISM-ICDOCUMENT-APPLIES, then attribute 
        	nonICmarkings must not be specified with a value containing any name 
        	token starting with [ACCM] or [NNPI]. 
        	
        	Human Readable: ACCM and NNPI tokens are not valid for documents that claim
        	compliance with IC rules.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M222"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M222"/>
   <xsl:template match="@*|node()" priority="-2" mode="M222">
      <xsl:apply-templates select="*" mode="M222"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00252-->


	<!--RULE -->
<xsl:template match="*[index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/         @ism:disseminationControls)), ' '),'RELIDO') &gt; 0 and @ism:nonICmarkings]"
                 priority="1000"
                 mode="M223">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/         @ism:disseminationControls)), ' '),'RELIDO') &gt; 0 and @ism:nonICmarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(util:containsAnyTokenMatching(@ism:nonICmarkings, 'NNPI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyTokenMatching(@ism:nonICmarkings, 'NNPI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00252][Error] If ISM_RESOURCE_ELEMENT specifies the attribute
            ism:disseminationControls with a value containing the token [RELIDO], 
            then attribute nonICmarkings must not be specified with a value containing 
            the token [NNPI]. 
        	
        	Human Readable: NNPI tokens are not valid for documents that have
        	RELIDO at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M223"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M223"/>
   <xsl:template match="@*|node()" priority="-2" mode="M223">
      <xsl:apply-templates select="*" mode="M223"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00313-->


	<!--RULE -->
<xsl:template match="*[util:containsAnyOfTheTokens(@ism:nonICmarkings, ('ND'))]"
                 priority="1000"
                 mode="M224">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[util:containsAnyOfTheTokens(@ism:nonICmarkings, ('ND'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00313][Error] If nonICmarkings contains the token [ND] then the 
            attribute disseminationControls must contain [NF].
            
            Human Readable: NODIS data must be marked NOFORN.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M224"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M224"/>
   <xsl:template match="@*|node()" priority="-2" mode="M224">
      <xsl:apply-templates select="*" mode="M224"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00314-->


	<!--RULE -->
<xsl:template match="*[util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD'))]"
                 priority="1000"
                 mode="M225">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00314][Error] If nonICmarkings contains the token [XD] then the 
            attribute disseminationControls must contain [NF].
            
            Human Readable: EXDIS data must be marked NOFORN.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M225"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M225"/>
   <xsl:template match="@*|node()" priority="-2" mode="M225">
      <xsl:apply-templates select="*" mode="M225"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00163-->


	<!--RULE -->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M226">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonUSControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string(@ism:ownerProducer))='NATO'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string(@ism:ownerProducer))='NATO'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00163][Error] If attribute nonUSControls exists the attribute 
        	ownerProducer must equal [NATO].
        	
        	Human Readable: NATO is the only owner of classification markings
        	for which nonUSControls are currently authorized.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M226"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M226"/>
   <xsl:template match="@*|node()" priority="-2" mode="M226">
      <xsl:apply-templates select="*" mode="M226"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00127-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:contributesToRollup(.)      and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))]"
                 priority="1000"
                 mode="M227">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:contributesToRollup(.)      and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    some $elem in $partTags satisfies     ($elem[@ism:noticeType]     and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('RD'))     and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('RD')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00127'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE, any element meeting ISM_CONTRIBUTES in 
			the document has the attribute <xsl:text/>
                  <xsl:value-of select="'atomicEnergyMarkings'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute
			noticeType containing [<xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/>].
			
			Human Readable:
			USA documents containing <xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/> 
			data must also have an <xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/> notice.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M227"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M227"/>
   <xsl:template match="@*|node()" priority="-2" mode="M227">
      <xsl:apply-templates select="*" mode="M227"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00128-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:contributesToRollup(.)      and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))]"
                 priority="1000"
                 mode="M228">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:contributesToRollup(.)      and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    some $elem in $partTags satisfies     ($elem[@ism:noticeType]     and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('FRD'))     and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('FRD')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00128'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE, any element meeting ISM_CONTRIBUTES in 
			the document has the attribute <xsl:text/>
                  <xsl:value-of select="'atomicEnergyMarkings'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute
			noticeType containing [<xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/>].
			
			Human Readable:
			USA documents containing <xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/> 
			data must also have an <xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/> notice.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M228"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M228"/>
   <xsl:template match="@*|node()" priority="-2" mode="M228">
      <xsl:apply-templates select="*" mode="M228"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00129-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:contributesToRollup(.)      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))]"
                 priority="1000"
                 mode="M229">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:contributesToRollup(.)      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    some $elem in $partTags satisfies     ($elem[@ism:noticeType]     and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('IMC'))     and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('IMC')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00129'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE, any element meeting ISM_CONTRIBUTES in 
			the document has the attribute <xsl:text/>
                  <xsl:value-of select="'disseminationControls'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute
			noticeType containing [<xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/>].
			
			Human Readable:
			USA documents containing <xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/> 
			data must also have an <xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/> notice.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M229"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M229"/>
   <xsl:template match="@*|node()" priority="-2" mode="M229">
      <xsl:apply-templates select="*" mode="M229"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00130-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:contributesToRollup(.)      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FISA'))]"
                 priority="1000"
                 mode="M230">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:contributesToRollup(.)      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FISA'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    some $elem in $partTags satisfies     ($elem[@ism:noticeType]     and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('FISA'))     and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('FISA')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00130'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE, any element meeting ISM_CONTRIBUTES in 
			the document has the attribute <xsl:text/>
                  <xsl:value-of select="'disseminationControls'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute
			noticeType containing [<xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/>].
			
			Human Readable:
			USA documents containing <xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/> 
			data must also have an <xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/> notice.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M230"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M230"/>
   <xsl:template match="@*|node()" priority="-2" mode="M230">
      <xsl:apply-templates select="*" mode="M230"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00131-->
<xsl:template match="text()" priority="-1" mode="M231"/>
   <xsl:template match="@*|node()" priority="-2" mode="M231">
      <xsl:apply-templates select="*" mode="M231"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00134-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:contributesToRollup(.)      and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('DS'))]"
                 priority="1000"
                 mode="M232">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:contributesToRollup(.)      and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('DS'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    some $elem in $partTags satisfies     ($elem[@ism:noticeType]     and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('DS'))     and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('DS')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00134'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE, any element meeting ISM_CONTRIBUTES in 
			the document has the attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute
			noticeType containing [<xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/>].
			
			Human Readable:
			USA documents containing <xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/> 
			data must also have an <xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/> notice.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M232"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M232"/>
   <xsl:template match="@*|node()" priority="-2" mode="M232">
      <xsl:apply-templates select="*" mode="M232"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00135-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('RD'))]"
                 priority="1000"
                 mode="M233">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('RD'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    index-of($partAtomicEnergyMarkings_tok, 'RD')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partAtomicEnergyMarkings_tok, 'RD')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00135'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE and any element meeting 
			ISM_CONTRIBUTES in the document has the attribute noticeType 
			containing [<xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute <xsl:text/>
                  <xsl:value-of select="'atomicEnergyMarkings'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/>].
			
			Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/> 
			notice must also have <xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M233"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M233"/>
   <xsl:template match="@*|node()" priority="-2" mode="M233">
      <xsl:apply-templates select="*" mode="M233"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00136-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('FRD'))]"
                 priority="1000"
                 mode="M234">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('FRD'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    index-of($partAtomicEnergyMarkings_tok, 'FRD')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partAtomicEnergyMarkings_tok, 'FRD')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00136'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE and any element meeting 
			ISM_CONTRIBUTES in the document has the attribute noticeType 
			containing [<xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute <xsl:text/>
                  <xsl:value-of select="'atomicEnergyMarkings'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/>].
			
			Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/> 
			notice must also have <xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M234"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M234"/>
   <xsl:template match="@*|node()" priority="-2" mode="M234">
      <xsl:apply-templates select="*" mode="M234"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00137-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('IMC'))]"
                 priority="1000"
                 mode="M235">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('IMC'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    index-of($partDisseminationControls_tok, 'IMC')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partDisseminationControls_tok, 'IMC')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00137'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE and any element meeting 
			ISM_CONTRIBUTES in the document has the attribute noticeType 
			containing [<xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute <xsl:text/>
                  <xsl:value-of select="'disseminationControls'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/>].
			
			Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/> 
			notice must also have <xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M235"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M235"/>
   <xsl:template match="@*|node()" priority="-2" mode="M235">
      <xsl:apply-templates select="*" mode="M235"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00138-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('DS'))]"
                 priority="1000"
                 mode="M236">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('DS'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    index-of($partNonICmarkings_tok, 'DS')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partNonICmarkings_tok, 'DS')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00138'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE and any element meeting 
			ISM_CONTRIBUTES in the document has the attribute noticeType 
			containing [<xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/>].
			
			Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/> 
			notice must also have <xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M236"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M236"/>
   <xsl:template match="@*|node()" priority="-2" mode="M236">
      <xsl:apply-templates select="*" mode="M236"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00139-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('FISA'))]"
                 priority="1000"
                 mode="M237">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('FISA'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    index-of($partDisseminationControls_tok, 'FISA')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partDisseminationControls_tok, 'FISA')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00139'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE and any element meeting 
			ISM_CONTRIBUTES in the document has the attribute noticeType 
			containing [<xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute <xsl:text/>
                  <xsl:value-of select="'disseminationControls'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/>].
			
			Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/> 
			notice must also have <xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M237"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M237"/>
   <xsl:template match="@*|node()" priority="-2" mode="M237">
      <xsl:apply-templates select="*" mode="M237"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00150-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                       and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES'))]"
                 priority="1000"
                 mode="M238">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                       and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="some $elem in $partTags satisfies          ($elem[@ism:noticeType]          and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('LES'))          and not ($elem/@ism:externalNotice='true'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('LES')) and not ($elem/@ism:externalNotice='true'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00150][Error] If ISM_CAPCO_RESOURCE and:
      1. Any element, other than ISM_RESOURCE_ELEMENT, meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [LES]
      AND
      2. No element meeting ISM_CONTRIBUTES in the document has the attribute noticeType containing [LES]
      
      Human Readable: USA documents containing LES data must also have an LES notice.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M238"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M238"/>
   <xsl:template match="@*|node()" priority="-2" mode="M238">
      <xsl:apply-templates select="*" mode="M238"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00151-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('LES'))]"
                 priority="1000"
                 mode="M239">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('LES'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    index-of($partNonICmarkings_tok, 'LES')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partNonICmarkings_tok, 'LES')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00151'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE and any element meeting 
			ISM_CONTRIBUTES in the document has the attribute noticeType 
			containing [<xsl:text/>
                  <xsl:value-of select="'LES'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'LES'"/>
                  <xsl:text/>].
			
			Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'LES'"/>
                  <xsl:text/> 
			notice must also have <xsl:text/>
                  <xsl:value-of select="'LES'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M239"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M239"/>
   <xsl:template match="@*|node()" priority="-2" mode="M239">
      <xsl:apply-templates select="*" mode="M239"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00152-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:contributesToRollup(.)      and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES-NF'))]"
                 priority="1000"
                 mode="M240">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:contributesToRollup(.)      and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES-NF'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    some $elem in $partTags satisfies     ($elem[@ism:noticeType]     and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('LES-NF'))     and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('LES-NF')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00152'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE, any element meeting ISM_CONTRIBUTES in 
			the document has the attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute
			noticeType containing [<xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/>].
			
			Human Readable:
			USA documents containing <xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/> 
			data must also have an <xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/> notice.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M240"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M240"/>
   <xsl:template match="@*|node()" priority="-2" mode="M240">
      <xsl:apply-templates select="*" mode="M240"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00153-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('LES-NF'))]"
                 priority="1000"
                 mode="M241">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE       and util:contributesToRollup(.)                      and not (@ism:externalNotice=true())                     and util:containsAnyOfTheTokens(@ism:noticeType, ('LES-NF'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    index-of($partNonICmarkings_tok, 'LES-NF')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partNonICmarkings_tok, 'LES-NF')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00153'"/>
                  <xsl:text/>][Error]
			If ISM_CAPCO_RESOURCE and any element meeting 
			ISM_CONTRIBUTES in the document has the attribute noticeType 
			containing [<xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/>], then some element
			meeting ISM_CONTRIBUTES in the document MUST have attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> containing 
			[<xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/>].
			
			Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/> 
			notice must also have <xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M241"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M241"/>
   <xsl:template match="@*|node()" priority="-2" mode="M241">
      <xsl:apply-templates select="*" mode="M241"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00156-->
<xsl:template match="text()" priority="-1" mode="M242"/>
   <xsl:template match="@*|node()" priority="-2" mode="M242">
      <xsl:apply-templates select="*" mode="M242"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00157-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:noticeType,                         ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E'))]"
                 priority="1000"
                 mode="M243">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                      and util:containsAnyOfTheTokens(@ism:noticeType,                         ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:noticeReason"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:noticeReason">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
        	[ISM-ID-00157][Error] If ISM_CAPCO_RESOURCE and:
        	1. The attribute notice contains one of the [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], or [DoD-Dist-E]
        	AND
        	2. The attribute noticeReason is not specified.
        	
        	Human Readable: DoD distribution statements B, C, D , or E  all require a reason.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M243"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M243"/>
   <xsl:template match="@*|node()" priority="-2" mode="M243">
      <xsl:apply-templates select="*" mode="M243"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00158-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and $ISM_DOD5230_24_APPLIES                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and not(@ism:classification='U')]"
                 priority="1000"
                 mode="M244">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and $ISM_DOD5230_24_APPLIES                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and not(@ism:classification='U')]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             util:containsAnyOfTheTokens(@ism:noticeType,               ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:noticeType, ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
        	[ISM-ID-00158][Error] If ISM_CAPCO_RESOURCE and:
        	1. ISM_DoD5230_24_Applies
        	AND
        	2. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        	AND
        	3. The resource attribute notice does not contain one of [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], or [DoD-Dist-F].
        	
        	Human Readable: All classified documents that claim compliance with DoD5230.24 must use one of DoD 
        	distribution statements B, C, D, E, or F.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M244"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M244"/>
   <xsl:template match="@*|node()" priority="-2" mode="M244">
      <xsl:apply-templates select="*" mode="M244"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00159-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                          and not($ISM_RESOURCE_ELEMENT/@ism:classification = 'U')]"
                 priority="1000"
                 mode="M245">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                          and not($ISM_RESOURCE_ELEMENT/@ism:classification = 'U')]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:noticeType, ('DoD-Dist-A')))                 or (@ism:externalNotice=true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:noticeType, ('DoD-Dist-A'))) or (@ism:externalNotice=true())">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00159][Error] If ISM_CAPCO_RESOURCE and:
        1. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        AND
        2. The attribute notice does contains [DoD-Dist-A]
        or has attribute externalNotice with a value of [true].
        Human Readable: Distribution statement A (Public Release) is forbidden on classified documents.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M245"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M245"/>
   <xsl:template match="@*|node()" priority="-2" mode="M245">
      <xsl:apply-templates select="*" mode="M245"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00160-->
<xsl:template match="text()" priority="-1" mode="M246"/>
   <xsl:template match="@*|node()" priority="-2" mode="M246">
      <xsl:apply-templates select="*" mode="M246"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00161-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE       and (util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A')))       and not (@ism:externalNotice=true())]"
                 priority="1000"
                 mode="M247">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE       and (util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A')))       and not (@ism:externalNotice=true())]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD', 'ND', 'SBU', 'SBU-NF', 'LES', 'LES-NF')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD', 'ND', 'SBU', 'SBU-NF', 'LES', 'LES-NF')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00161][Error] Distribution statement A (Public Release) is incompatible with [XD], [ND], [SBU], [SBU-NF], [LES], OR [LES-NF].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M247"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M247"/>
   <xsl:template match="@*|node()" priority="-2" mode="M247">
      <xsl:apply-templates select="*" mode="M247"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00237-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE          and util:containsAnyOfTheTokens(@ism:noticeType,            ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))]"
                 priority="1000"
                 mode="M248">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE          and util:containsAnyOfTheTokens(@ism:noticeType,            ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:noticeDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:noticeDate">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00237][Error] DoD distribution statements B, C, D ,E ,F, and X all require a date.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M248"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M248"/>
   <xsl:template match="@*|node()" priority="-2" mode="M248">
      <xsl:apply-templates select="*" mode="M248"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00238-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE          and util:containsAnyOfTheTokens(@ism:noticeType,            ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))]"
                 priority="1000"
                 mode="M249">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE          and util:containsAnyOfTheTokens(@ism:noticeType,            ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))]"/>
      <xsl:variable name="foundNoticeTokens"
                    select="           for $noticeToken in tokenize(normalize-space(string(@ism:noticeType)), ' ') return                if(matches($noticeToken, '^DoD-Dist-[BCDEFX]'))               then $noticeToken               else null"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $noticeToken in $foundNoticeTokens satisfies                  index-of($partPocType_tok, $noticeToken)&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $noticeToken in $foundNoticeTokens satisfies index-of($partPocType_tok, $noticeToken)&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
        	[ISM-ID-00238][Error] DoD distribution statements B, C, D ,E ,F, and X all 
        	require a corresponding point of contact.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M249"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M249"/>
   <xsl:template match="@*|node()" priority="-2" mode="M249">
      <xsl:apply-templates select="*" mode="M249"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00239-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE   and util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A'))   and not (@ism:excludeFromRollup='true')]"
                 priority="1000"
                 mode="M250">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE   and util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A'))   and not (@ism:excludeFromRollup='true')]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="    not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO', 'PR', 'DSEN', 'FISA')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO', 'PR', 'DSEN', 'FISA')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
			[ISM-ID-00239][Error] If ISM_CAPCO_RESOURCE and attribute noticeType of
			ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], then any element 
			which contributes to rollup should not have an attribute
			disseminationControls that contains any of the following tokens:
			[FOUO], [PR], [DSEN], or [FISA].
			
			Human Readable: Distribution statement A (Public Release) is incompatible 
			with [FOUO], [PR], [DSEN], and [FISA] for contributing portions.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M250"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M250"/>
   <xsl:template match="@*|node()" priority="-2" mode="M250">
      <xsl:apply-templates select="*" mode="M250"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00240-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                 and util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A'))                 and not (@ism:excludeFromRollup='true')]"
                 priority="1000"
                 mode="M251">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                 and util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A'))                 and not (@ism:excludeFromRollup='true')]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('DCNI', 'UCNI')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('DCNI', 'UCNI')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00240][Error] If ISM_CAPCO_RESOURCE and attribute noticeType of
            ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], then any element
            which contributes to rolluop should not have an attribute
            atomicEnergyMarkings that contains any of the following tokens:
            [DCNI], [UCNI].
            
            Human Readable: Distribution statement A (Public Release) is incompatible 
            with [DCNI] and [UCNI].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M251"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M251"/>
   <xsl:template match="@*|node()" priority="-2" mode="M251">
      <xsl:apply-templates select="*" mode="M251"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00244-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and util:contributesToRollup(.)                       and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]"
                 priority="1000"
                 mode="M252">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and util:contributesToRollup(.)                       and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="       some $elem in $partTags satisfies         ($elem[@ism:noticeType]         and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('CNWDI'))         and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('CNWDI')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00244][Error] If ISM_CAPCO_RESOURCE and:
      1. Any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD-CNWDI]
      AND
      2. No element meeting ISM_CONTRIBUTES in the document has noticeType containing [CNWDI].
      
      Human Readable: USA documents containing CNWDI data must also have an CNWDI notice.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M252"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M252"/>
   <xsl:template match="@*|node()" priority="-2" mode="M252">
      <xsl:apply-templates select="*" mode="M252"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00245-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:contributesToRollup(.)                         and (util:containsAnyOfTheTokens(@ism:noticeType, ('CNWDI')))                         and not (@ism:externalNotice=true())]"
                 priority="1000"
                 mode="M253">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:contributesToRollup(.)                         and (util:containsAnyOfTheTokens(@ism:noticeType, ('CNWDI')))                         and not (@ism:externalNotice=true())]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="index-of($partAtomicEnergyMarkings_tok, 'RD-CNWDI')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partAtomicEnergyMarkings_tok, 'RD-CNWDI')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00245][Error] If ISM_CAPCO_RESOURCE and:
            1. No element without ism:excludeFromRollup=true() in the document has the attribute atomicEnergyMarkings containing [RD-CNWDI]
            AND
            2. Any element without ism:excludeFromRollup=true() in the document has the attribute noticeType containing [CNWDI]
            without the attribute externalNotice with a value of [true]
            
            Human Readable: USA documents containing an CNWDI notice must also have RD-CNWDI data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M253"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M253"/>
   <xsl:template match="@*|node()" priority="-2" mode="M253">
      <xsl:apply-templates select="*" mode="M253"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00248-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][@ism:externalNotice]"
                 priority="1000"
                 mode="M254">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][@ism:externalNotice]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(string(@ism:externalNotice)='true')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(string(@ism:externalNotice)='true')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00248][Error] ISM_RESOURCE_ELEMENT cannot have externalNotice set to [true].
			
			Human Readable: ISM resource elements can not be external notices.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M254"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M254"/>
   <xsl:template match="@*|node()" priority="-2" mode="M254">
      <xsl:apply-templates select="*" mode="M254"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00249-->
<xsl:template match="text()" priority="-1" mode="M255"/>
   <xsl:template match="@*|node()" priority="-2" mode="M255">
      <xsl:apply-templates select="*" mode="M255"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00250-->


	<!--RULE -->
<xsl:template match="ism:Notice[$ISM_CAPCO_RESOURCE]" priority="1000" mode="M256">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ism:Notice[$ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:noticeType or @ism:unregisteredNoticeType"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:noticeType or @ism:unregisteredNoticeType">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00250][Error] If ISM-CAPCO-RESOURCE, element Notice must specify
			attribute ism:noticeType or ism:unregisteredNoticeType.
			
			Human Readable: Notices must specify their type.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M256"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M256"/>
   <xsl:template match="@*|node()" priority="-2" mode="M256">
      <xsl:apply-templates select="*" mode="M256"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00251-->


	<!--RULE -->
<xsl:template match="*[$ISM_ICDOCUMENT_APPLIES and @ism:noticeType]" priority="1000"
                 mode="M257">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_ICDOCUMENT_APPLIES and @ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(util:containsAnyTokenMatching(@ism:noticeType, 'COMSEC'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyTokenMatching(@ism:noticeType, 'COMSEC'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00251][Error] If ISM-ICDOCUMENT-APPLIES, then attribute 
        	@ism:noticeType must not be specified with a value of [COMSEC]. 
        	
        	Human Readable: COMSEC notices are not valid for documents that claim
        	compliance with IC rules.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M257"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M257"/>
   <xsl:template match="@*|node()" priority="-2" mode="M257">
      <xsl:apply-templates select="*" mode="M257"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00001-->
<xsl:template match="text()" priority="-1" mode="M258"/>
   <xsl:template match="@*|node()" priority="-2" mode="M258">
      <xsl:apply-templates select="*" mode="M258"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00008-->
<xsl:template match="text()" priority="-1" mode="M259"/>
   <xsl:template match="@*|node()" priority="-2" mode="M259">
      <xsl:apply-templates select="*" mode="M259"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00039-->
<xsl:template match="text()" priority="-1" mode="M260"/>
   <xsl:template match="@*|node()" priority="-2" mode="M260">
      <xsl:apply-templates select="*" mode="M260"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00099-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:ownerProducer, ('FGI'))]"
                 priority="1000"
                 mode="M261">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:ownerProducer, ('FGI'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             count(                 tokenize(normalize-space(string(@ism:ownerProducer)), ' ')             ) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( tokenize(normalize-space(string(@ism:ownerProducer)), ' ') ) = 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00099][Error] If ISM_CAPCO_RESOURCE and attribute ownerProducer
            contains the token [FGI], then the token [FGI] must be the only value 
            in attribute ownerProducer.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M261"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M261"/>
   <xsl:template match="@*|node()" priority="-2" mode="M261">
      <xsl:apply-templates select="*" mode="M261"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00100-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:ownerProducer]" priority="1000"
                 mode="M262">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:ownerProducer]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:ownerProducer, $ownerProducerList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:ownerProducer, $ownerProducerList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00100][Error] If ISM_CAPCO_RESOURCE and attribute ownerProducer is specified,      then each of its values must be ordered in accordance with CVEnumISMOwnerProducer.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:ownerProducer, $ownerProducerList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:ownerProducer"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M262"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M262"/>
   <xsl:template match="@*|node()" priority="-2" mode="M262">
      <xsl:apply-templates select="*" mode="M262"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00219-->


	<!--RULE -->
<xsl:template match="*[not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                         and util:contributesToRollup(.)                         and util:containsAnyOfTheTokens(@ism:ownerProducer, ('FGI'))]"
                 priority="1000"
                 mode="M263">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                         and util:contributesToRollup(.)                         and util:containsAnyOfTheTokens(@ism:ownerProducer, ('FGI'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:FGIsourceProtected, ('FGI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:FGIsourceProtected, ('FGI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00219][Error] If element meets ISM_CONTRIBUTES and attribute
            ownerProducer contains the token [FGI], then attribute 
            FGIsourceProtected must have a value containing the token [FGI].
            
            Human Readable: Any non-resource element that contributes to the 
            document's banner roll-up and has FOREIGN GOVERNMENT INFORMATION (FGI)
            must also specify attribute FGIsourceProtected with token FGI.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M263"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M263"/>
   <xsl:template match="@*|node()" priority="-2" mode="M263">
      <xsl:apply-templates select="*" mode="M263"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00315-->


	<!--RULE -->
<xsl:template match="*[not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                         and util:contributesToRollup(.)                         and $ISM_CAPCO_RESOURCE                         and not(@ism:classification='U')                         and util:containsAnyOfTheTokens(@ism:ownerProducer, ('NATO'))]"
                 priority="1000"
                 mode="M264">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                         and util:contributesToRollup(.)                         and $ISM_CAPCO_RESOURCE                         and not(@ism:classification='U')                         and util:containsAnyOfTheTokens(@ism:ownerProducer, ('NATO'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:declassException, ('NATO', 'NATO-AEA'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:declassException, ('NATO', 'NATO-AEA'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00315][Error] If element meets ISM_CONTRIBUTES and attribute
            ownerProducer contains the token [NATO], then attribute declassException
            must be specified with a value of [NATO] or [NATO-AEA] on the resourceElement.
            
            Human Readable: Any non-resource element that contributes to the 
            document's banner roll-up and has NATO Information)
            must also specify a NATO declass exemption on the banner.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M264"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M264"/>
   <xsl:template match="@*|node()" priority="-2" mode="M264">
      <xsl:apply-templates select="*" mode="M264"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00224-->
<xsl:template match="text()" priority="-1" mode="M265"/>
   <xsl:template match="@*|node()" priority="-2" mode="M265">
      <xsl:apply-templates select="*" mode="M265"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00247-->
<xsl:template match="text()" priority="-1" mode="M266"/>
   <xsl:template match="@*|node()" priority="-2" mode="M266">
      <xsl:apply-templates select="*" mode="M266"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00009-->
<xsl:template match="text()" priority="-1" mode="M267"/>
   <xsl:template match="@*|node()" priority="-2" mode="M267">
      <xsl:apply-templates select="*" mode="M267"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00032-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES')))]"
                 priority="1000"
                 mode="M268">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES')))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(@ism:releasableTo)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@ism:releasableTo)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00032][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls is not specified, or is specified and does not 
            contain the name token [REL] or [EYES], then attribute releasableTo 
            must not be specified.
            
            Human Readable: USA documents must only specify to which countries it is 
            authorized for release if dissemination information contains 
            REL TO or EYES ONLY data. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M268"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M268"/>
   <xsl:template match="@*|node()" priority="-2" mode="M268">
      <xsl:apply-templates select="*" mode="M268"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00041-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:releasableTo]" priority="1000"
                 mode="M269">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:releasableTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:releasableTo, $releasableToList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:releasableTo, $releasableToList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00041][Error] If ISM_CAPCO_RESOURCE and attribute releasableTo is specified,      then each of its values must be ordered in accordance with CVEnumISMRelTo.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:releasableTo, $releasableToList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:releasableTo"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M269"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M269"/>
   <xsl:template match="@*|node()" priority="-2" mode="M269">
      <xsl:apply-templates select="*" mode="M269"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00214-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:releasableTo]" priority="1000"
                 mode="M270">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:releasableTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="index-of(tokenize(normalize-space(string(@ism:releasableTo)),' '),'USA')=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of(tokenize(normalize-space(string(@ism:releasableTo)),' '),'USA')=1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00214][Error] If ISM_CAPCO_RESOURCE then attribute 
            releasableTo must start with [USA].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M270"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M270"/>
   <xsl:template match="@*|node()" priority="-2" mode="M270">
      <xsl:apply-templates select="*" mode="M270"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00013-->


	<!--RULE -->
<xsl:template match="*[$ISM_NSI_EO_APPLIES                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M271">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_NSI_EO_APPLIES                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:classifiedBy or @ism:derivedFrom"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classifiedBy or @ism:derivedFrom">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00013][Error] Documents under E.O. 13526 must have classification authority block information.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M271"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M271"/>
   <xsl:template match="@*|node()" priority="-2" mode="M271">
      <xsl:apply-templates select="*" mode="M271"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00014-->


	<!--RULE -->
<xsl:template match="*[$ISM_NSI_EO_APPLIES                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M272">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_NSI_EO_APPLIES                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:declassDate or @ism:declassEvent or @ism:declassException"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:declassDate or @ism:declassEvent or @ism:declassException">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00014][Error] If ISM_NSI_EO_APPLIES then one or more of the following 
            attributes: declassDate, declassEvent, or declassException must be specified on the ISM_RESOURCE_ELEMENT.
            
            Human Readable: Documents under E.O. 13526 must have declassification instructions included in the 
            classification authority block information.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M272"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M272"/>
   <xsl:template match="@*|node()" priority="-2" mode="M272">
      <xsl:apply-templates select="*" mode="M272"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00056-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and normalize-space(string(@ism:classification))='U']"
                 priority="1000"
                 mode="M273">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and normalize-space(string(@ism:classification))='U']"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $ele in $partTags satisfies                     not(util:containsAnyOfTheTokens($ele/@ism:classification, ('C', 'S', 'TS', 'R')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $ele in $partTags satisfies not(util:containsAnyOfTheTokens($ele/@ism:classification, ('C', 'S', 'TS', 'R')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00056][Error] If ISM_CAPCO_RESOURCE and attribute classification of 
          ISM_RESOURCE_ELEMENT has a value of [U] then no element meeting ISM_CONTRIBUTES_USA in the document may have 
          a classification attribute of [C], [S], [TS], or [R].
          
          Human Readable: USA UNCLASSIFIED documents can't have portion markings with the classification TOP SECRET, SECRET, CONFIDENTIAL, or RESTRICTED data.  
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M273"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M273"/>
   <xsl:template match="@*|node()" priority="-2" mode="M273">
      <xsl:apply-templates select="*" mode="M273"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00057-->
<xsl:template match="text()" priority="-1" mode="M274"/>
   <xsl:template match="@*|node()" priority="-2" mode="M274">
      <xsl:apply-templates select="*" mode="M274"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00058-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and normalize-space(string(@ism:classification))='C']"
                 priority="1000"
                 mode="M275">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and normalize-space(string(@ism:classification))='C']"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $ele in $partTags satisfies                 not(util:containsAnyOfTheTokens($ele/@ism:classification, ('S', 'TS')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $ele in $partTags satisfies not(util:containsAnyOfTheTokens($ele/@ism:classification, ('S', 'TS')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00058][Error] USA CONFIDENTIAL documents can't have TOP SECRET or SECRET data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M275"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M275"/>
   <xsl:template match="@*|node()" priority="-2" mode="M275">
      <xsl:apply-templates select="*" mode="M275"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00059-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and normalize-space(string(@ism:classification))='S']"
                 priority="1000"
                 mode="M276">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and normalize-space(string(@ism:classification))='S']"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $ele in $partTags satisfies                 not(util:containsAnyOfTheTokens($ele/@ism:classification, ('TS')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $ele in $partTags satisfies not(util:containsAnyOfTheTokens($ele/@ism:classification, ('TS')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00059][Error] USA SECRET documents can't have TOP SECRET data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M276"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M276"/>
   <xsl:template match="@*|node()" priority="-2" mode="M276">
      <xsl:apply-templates select="*" mode="M276"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00060-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('SI'))                       )]"
                 priority="1000"
                 mode="M277">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('SI'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00060][Error] USA documents having SI data must have SI at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M277"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M277"/>
   <xsl:template match="@*|node()" priority="-2" mode="M277">
      <xsl:apply-templates select="*" mode="M277"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00061-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('SI-G'))                       )]"
                 priority="1000"
                 mode="M278">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('SI-G'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00061][Error] USA documents having SI-G data must have SI-G at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M278"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M278"/>
   <xsl:template match="@*|node()" priority="-2" mode="M278">
      <xsl:apply-templates select="*" mode="M278"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00062-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('TK'))                       )]"
                 priority="1000"
                 mode="M279">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('TK'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00062][Error] USA documents having TK data must have TK at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M279"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M279"/>
   <xsl:template match="@*|node()" priority="-2" mode="M279">
      <xsl:apply-templates select="*" mode="M279"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00063-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('HCS'))                       )]"
                 priority="1000"
                 mode="M280">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('HCS'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00063][Error] USA documents having HCS data must have HCS at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M280"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M280"/>
   <xsl:template match="@*|node()" priority="-2" mode="M280">
      <xsl:apply-templates select="*" mode="M280"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00064-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M281">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(not(empty($partFGIsourceOpen)))                  then ($bannerFGIsourceOpen                        or $bannerFGIsourceProtected)                  else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not(empty($partFGIsourceOpen))) then ($bannerFGIsourceOpen or $bannerFGIsourceProtected) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00064][Error] USA documents having FGI Open data must have FGI Open or FGI Protected at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M281"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M281"/>
   <xsl:template match="@*|node()" priority="-2" mode="M281">
      <xsl:apply-templates select="*" mode="M281"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00065-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and not(empty($partFGIsourceProtected))]"
                 priority="1000"
                 mode="M282">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and not(empty($partFGIsourceProtected))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:FGIsourceProtected"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:FGIsourceProtected">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00065][Error] USA documents having FGI Protected data must have FGI Protected at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M282"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M282"/>
   <xsl:template match="@*|node()" priority="-2" mode="M282">
      <xsl:apply-templates select="*" mode="M282"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00066-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and index-of($dcTagsFound,'FOUO') &gt; 0                         and util:containsAnyOfTheTokens(@ism:classification, ('U'))                         and not($partNonICmarkings_tok = ('SBU', 'SBU-NF', 'LES', 'LES-NF'))]"
                 priority="1000"
                 mode="M283">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and index-of($dcTagsFound,'FOUO') &gt; 0                         and util:containsAnyOfTheTokens(@ism:classification, ('U'))                         and not($partNonICmarkings_tok = ('SBU', 'SBU-NF', 'LES', 'LES-NF'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00066][Error] USA Unclassified documents having FOUO data and not having SBU, SBU-NF, LES, or LES-NF must have 
            FOUO at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M283"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M283"/>
   <xsl:template match="@*|node()" priority="-2" mode="M283">
      <xsl:apply-templates select="*" mode="M283"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00067-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('OC'))                       )]"
                 priority="1000"
                 mode="M284">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('OC'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00067][Error] USA documents having ORCON data must have ORCON at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M284"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M284"/>
   <xsl:template match="@*|node()" priority="-2" mode="M284">
      <xsl:apply-templates select="*" mode="M284"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00068-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('IMC'))                       )]"
                 priority="1000"
                 mode="M285">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('IMC'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00068][Error] USA documents having IMCON data must have IMCON at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M285"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M285"/>
   <xsl:template match="@*|node()" priority="-2" mode="M285">
      <xsl:apply-templates select="*" mode="M285"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00069-->
<xsl:template match="text()" priority="-1" mode="M286"/>
   <xsl:template match="@*|node()" priority="-2" mode="M286">
      <xsl:apply-templates select="*" mode="M286"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00070-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('NF'))                       )]"
                 priority="1000"
                 mode="M287">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('NF'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00070][Error] USA documents having NF data must have NF at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M287"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M287"/>
   <xsl:template match="@*|node()" priority="-2" mode="M287">
      <xsl:apply-templates select="*" mode="M287"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00071-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('PR'))                       )]"
                 priority="1000"
                 mode="M288">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('PR'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('PR'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('PR'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00071][Error] USA documents having PROPIN data must have PROPIN at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M288"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M288"/>
   <xsl:template match="@*|node()" priority="-2" mode="M288">
      <xsl:apply-templates select="*" mode="M288"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00072-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('RD'))                       )]"
                 priority="1000"
                 mode="M289">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('RD'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00072][Error] USA documents having Restricted Data (RD) must have RD at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M289"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M289"/>
   <xsl:template match="@*|node()" priority="-2" mode="M289">
      <xsl:apply-templates select="*" mode="M289"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00073-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('RD-CNWDI'))                       )]"
                 priority="1000"
                 mode="M290">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('RD-CNWDI'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00073][Error] USA documents having Restricted CNWDI Data must have Restricted CNWDI Data at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M290"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M290"/>
   <xsl:template match="@*|node()" priority="-2" mode="M290">
      <xsl:apply-templates select="*" mode="M290"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00074-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M291">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>
      <xsl:variable name="matchingTokens"
                    select="         for $token in $partAtomicEnergyMarkings_tok return           if(matches($token,'^RD-SG-[1-9][0-9]?$'))           then $token           else null         "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $token in $matchingTokens satisfies                             index-of($bannerAtomicEnergyMarkings_tok, $token) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $token in $matchingTokens satisfies index-of($bannerAtomicEnergyMarkings_tok, $token) &gt; 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00074][Error] USA documents having Restricted SIGMA-## Data must have the same Restricted SIGMA-## Data at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M291"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M291"/>
   <xsl:template match="@*|node()" priority="-2" mode="M291">
      <xsl:apply-templates select="*" mode="M291"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00075-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('FRD'))                       )]"
                 priority="1000"
                 mode="M292">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('FRD'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00075][Error] USA documents having Formerly Restricted Data (FRD) must have FRD at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M292"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M292"/>
   <xsl:template match="@*|node()" priority="-2" mode="M292">
      <xsl:apply-templates select="*" mode="M292"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00076-->
<xsl:template match="text()" priority="-1" mode="M293"/>
   <xsl:template match="@*|node()" priority="-2" mode="M293">
      <xsl:apply-templates select="*" mode="M293"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00077-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M294">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>
      <xsl:variable name="matchingTokens"
                    select="           for $token in $partAtomicEnergyMarkings_tok return             if(matches($token,'^FRD-SG-[1-9][0-9]?$'))             then $token             else null           "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $token in $matchingTokens satisfies                     index-of($bannerAtomicEnergyMarkings_tok, $token) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $token in $matchingTokens satisfies index-of($bannerAtomicEnergyMarkings_tok, $token) &gt; 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00077][Error] USA documents having Formerly Restricted SIGMA-## Data must have the same Formerly Restricted SIGMA-## Data at 
            the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M294"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M294"/>
   <xsl:template match="@*|node()" priority="-2" mode="M294">
      <xsl:apply-templates select="*" mode="M294"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00078-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('U'))                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('DCNI'))                       )]"
                 priority="1000"
                 mode="M295">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('U'))                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('DCNI'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('DCNI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('DCNI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00078][Error] Unclassified USA documents having DCNI Data must have DCNI at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M295"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M295"/>
   <xsl:template match="@*|node()" priority="-2" mode="M295">
      <xsl:apply-templates select="*" mode="M295"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00079-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('U'))                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('UCNI'))                       )]"
                 priority="1000"
                 mode="M296">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('U'))                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('UCNI'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('UCNI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('UCNI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00079][Error] Unclassified USA documents having UCNI Data must have UCNI at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M296"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M296"/>
   <xsl:template match="@*|node()" priority="-2" mode="M296">
      <xsl:apply-templates select="*" mode="M296"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00080-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('DSEN'))                       )]"
                 priority="1000"
                 mode="M297">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('DSEN'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('DSEN'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('DSEN'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00080][Error] USA documents having DSEN Data must have DSEN at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M297"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M297"/>
   <xsl:template match="@*|node()" priority="-2" mode="M297">
      <xsl:apply-templates select="*" mode="M297"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00081-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('FISA'))                       )]"
                 priority="1000"
                 mode="M298">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('FISA'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('FISA'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('FISA'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00081][Error] USA documents having FISA Data must have FISA at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M298"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M298"/>
   <xsl:template match="@*|node()" priority="-2" mode="M298">
      <xsl:apply-templates select="*" mode="M298"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00082-->
<xsl:template match="text()" priority="-1" mode="M299"/>
   <xsl:template match="@*|node()" priority="-2" mode="M299">
      <xsl:apply-templates select="*" mode="M299"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00083-->
<xsl:template match="text()" priority="-1" mode="M300"/>
   <xsl:template match="@*|node()" priority="-2" mode="M300">
      <xsl:apply-templates select="*" mode="M300"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00084-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('DS'))                       )]"
                 priority="1000"
                 mode="M301">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('DS'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('DS'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('DS'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00084][Error] USA documents having DS Data must have DS at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M301"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M301"/>
   <xsl:template match="@*|node()" priority="-2" mode="M301">
      <xsl:apply-templates select="*" mode="M301"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00085-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and index-of($partNonICmarkings_tok, 'XD') &gt; 0                         and not(index-of($partNonICmarkings_tok, 'ND')&gt;0)]"
                 priority="1000"
                 mode="M302">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and index-of($partNonICmarkings_tok, 'XD') &gt; 0                         and not(index-of($partNonICmarkings_tok, 'ND')&gt;0)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00085][Error] USA documents having XD Data and not having ND must have XD at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M302"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M302"/>
   <xsl:template match="@*|node()" priority="-2" mode="M302">
      <xsl:apply-templates select="*" mode="M302"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00086-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('ND'))                       )]"
                 priority="1000"
                 mode="M303">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('ND'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('ND'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('ND'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00086][Error] USA documents having ND Data must have ND at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M303"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M303"/>
   <xsl:template match="@*|node()" priority="-2" mode="M303">
      <xsl:apply-templates select="*" mode="M303"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00087-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M304">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if(index-of($partNonICmarkings_tok, 'SBU-NF') &gt; 0 and not($bannerClassification='U'))                      then (index-of($bannerDisseminationControls_tok, 'NF') &gt; 0)                     else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'SBU-NF') &gt; 0 and not($bannerClassification='U')) then (index-of($bannerDisseminationControls_tok, 'NF') &gt; 0) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00087][Error] Classified USA documents having SBU-NF Data must have NF at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M304"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M304"/>
   <xsl:template match="@*|node()" priority="-2" mode="M304">
      <xsl:apply-templates select="*" mode="M304"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00088-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                          and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                          and @ism:releasableTo]"
                 priority="1000"
                 mode="M305">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                          and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                          and @ism:releasableTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $portion in $partTags satisfies             (                 ($portion/@ism:classification='U' and                     not(util:containsAnyOfTheTokens($portion/@ism:disseminationControls, ('NF')) or                     (util:containsAnyOfTheTokens($portion/@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO'))                      and not(util:containsAnyOfTheTokens($portion/@ism:dissemintationControls, ('REL')))))                 )                 or $portion/@ism:releasableTo[normalize-space()]                 or not($portion/@ism:classification)              )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $portion in $partTags satisfies ( ($portion/@ism:classification='U' and not(util:containsAnyOfTheTokens($portion/@ism:disseminationControls, ('NF')) or (util:containsAnyOfTheTokens($portion/@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO')) and not(util:containsAnyOfTheTokens($portion/@ism:dissemintationControls, ('REL'))))) ) or $portion/@ism:releasableTo[normalize-space()] or not($portion/@ism:classification) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00088][Error] USA documents having any classified portion that is not 
            Releasable or having unclassified portions with [NF], [DISPLAYONLY], or [RELIDO]
            cannot be REL at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M305"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M305"/>
   <xsl:template match="@*|node()" priority="-2" mode="M305">
      <xsl:apply-templates select="*" mode="M305"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00089-->
<xsl:template match="text()" priority="-1" mode="M306"/>
   <xsl:template match="@*|node()" priority="-2" mode="M306">
      <xsl:apply-templates select="*" mode="M306"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00090-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and index-of($partDisseminationControls_tok, 'REL') &gt; 0]"
                 priority="1000"
                 mode="M307">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and index-of($partDisseminationControls_tok, 'REL') &gt; 0]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('EYES')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('EYES')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00090][Error] USA documents with any portion that is REL must not be EYES at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M307"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M307"/>
   <xsl:template match="@*|node()" priority="-2" mode="M307">
      <xsl:apply-templates select="*" mode="M307"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00104-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('U'))                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('SBU-NF'))                       )]"
                 priority="1000"
                 mode="M308">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('U'))                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('SBU-NF'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU-NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU-NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00104][Error] Unclassified USA documents having SBU-NF must have SBU-NF at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M308"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M308"/>
   <xsl:template match="@*|node()" priority="-2" mode="M308">
      <xsl:apply-templates select="*" mode="M308"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00105-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE     and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)     and $bannerClassification='U'     and index-of($partNonICmarkings_tok, 'SBU') &gt; 0     and not(index-of($partNonICmarkings_tok, 'SBU-NF') &gt; 0)]"
                 priority="1000"
                 mode="M309">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE     and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)     and $bannerClassification='U'     and index-of($partNonICmarkings_tok, 'SBU') &gt; 0     and not(index-of($partNonICmarkings_tok, 'SBU-NF') &gt; 0)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00105][Error] USA Unclassified documents having SBU and not having SBU-NF must have SBU at the resource level.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M309"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M309"/>
   <xsl:template match="@*|node()" priority="-2" mode="M309">
      <xsl:apply-templates select="*" mode="M309"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00108-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('TS'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M310">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('TS'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="         some $ele in $partTags satisfies           util:containsAnyOfTheTokens($ele/@ism:classification, ('TS'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:classification, ('TS'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00108][Error] USA TS documents not using compilation must have TS data.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M310"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M310"/>
   <xsl:template match="@*|node()" priority="-2" mode="M310">
      <xsl:apply-templates select="*" mode="M310"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00109-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('S'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M311">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('S'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="         some $ele in $partTags satisfies           util:containsAnyOfTheTokens($ele/@ism:classification, ('S'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:classification, ('S'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00109][Error] USA S documents not using compilation must have S data.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M311"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M311"/>
   <xsl:template match="@*|node()" priority="-2" mode="M311">
      <xsl:apply-templates select="*" mode="M311"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00110-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('C'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M312">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('C'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="         some $ele in $partTags satisfies           util:containsAnyOfTheTokens($ele/@ism:classification, ('C'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:classification, ('C'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00110][Error] USA C documents not using compilation must have C data.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M312"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M312"/>
   <xsl:template match="@*|node()" priority="-2" mode="M312">
      <xsl:apply-templates select="*" mode="M312"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00111-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M313">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="         some $ele in $partTags satisfies           util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('SI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('SI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00111][Error] USA SI documents not using compilation must have SI data.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M313"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M313"/>
   <xsl:template match="@*|node()" priority="-2" mode="M313">
      <xsl:apply-templates select="*" mode="M313"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00112-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M314">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="         some $ele in $partTags satisfies           util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('SI-G'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('SI-G'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00112][Error] USA SI-G documents not using compilation must have SI-G data.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M314"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M314"/>
   <xsl:template match="@*|node()" priority="-2" mode="M314">
      <xsl:apply-templates select="*" mode="M314"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00113-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M315">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="         some $ele in $partTags satisfies           util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('TK'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('TK'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00113][Error] USA TK documents not using compilation must have TK data.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M315"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M315"/>
   <xsl:template match="@*|node()" priority="-2" mode="M315">
      <xsl:apply-templates select="*" mode="M315"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00116-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M316">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="         some $ele in $partTags satisfies           util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('HCS'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:SCIcontrols, ('HCS'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00116][Error] USA HCS documents not using compilation must have HCS data.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M316"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M316"/>
   <xsl:template match="@*|node()" priority="-2" mode="M316">
      <xsl:apply-templates select="*" mode="M316"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00118-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][1]"
                 priority="1000"
                 mode="M317">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][1]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:createDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:createDate">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00118][Error] The first element in document order having 
            resourceElement true must have createDate specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M317"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M317"/>
   <xsl:template match="@*|node()" priority="-2" mode="M317">
      <xsl:apply-templates select="*" mode="M317"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00132-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RELIDO'))]"
                 priority="1000"
                 mode="M318">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RELIDO'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $ele in $partTags satisfies             if  ($ele/@ism:classification[normalize-space()='U'] and not(util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('REL','NF','DISPLAYONLY')))                        or not($ele/@ism:classification)                  )                     then true()                     else                       util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('RELIDO'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $ele in $partTags satisfies if ($ele/@ism:classification[normalize-space()='U'] and not(util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('REL','NF','DISPLAYONLY'))) or not($ele/@ism:classification) ) then true() else util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('RELIDO'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00132][Error] USA documents having RELIDO at the resource level must have every classified portion having RELIDO and on any U portions that have explicit Release specified must have RELIDO.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M318"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M318"/>
   <xsl:template match="@*|node()" priority="-2" mode="M318">
      <xsl:apply-templates select="*" mode="M318"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00141-->


	<!--RULE -->
<xsl:template match="*[$ISM_NSI_EO_APPLIES                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and not(util:containsAnyOfTheTokens(@ism:declassException, ('50X1-HUM', '50X2-WMD', 'AEA', 'NATO', 'NATO-AEA')))]"
                 priority="1000"
                 mode="M319">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_NSI_EO_APPLIES                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and not(util:containsAnyOfTheTokens(@ism:declassException, ('50X1-HUM', '50X2-WMD', 'AEA', 'NATO', 'NATO-AEA')))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@ism:declassDate or @ism:declassEvent"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:declassDate or @ism:declassEvent">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00141][Error] Documents under E.O. 13526 require declassDate or declassEvent unless  
            50X1-HUM, 50X2-WMD, RD, FRD, AEA, NATO, or NATO-AEA is specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M319"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M319"/>
   <xsl:template match="@*|node()" priority="-2" mode="M319">
      <xsl:apply-templates select="*" mode="M319"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00144-->
<xsl:template match="text()" priority="-1" mode="M320"/>
   <xsl:template match="@*|node()" priority="-2" mode="M320">
      <xsl:apply-templates select="*" mode="M320"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00145-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and index-of($partNonICmarkings_tok, 'LES') &gt; 0                         and not(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0)]"
                 priority="1000"
                 mode="M321">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and index-of($partNonICmarkings_tok, 'LES') &gt; 0                         and not(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00145][Error] USA documents having LES and not having LES-NF must have LES at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M321"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M321"/>
   <xsl:template match="@*|node()" priority="-2" mode="M321">
      <xsl:apply-templates select="*" mode="M321"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00146-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M322">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and not($bannerClassification='U'))                  then (index-of($bannerDisseminationControls_tok, 'NF') &gt; 0)                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and not($bannerClassification='U')) then (index-of($bannerDisseminationControls_tok, 'NF') &gt; 0) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00146][Error] Classified USA documents having LES-NF Data must have NF at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M322"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M322"/>
   <xsl:template match="@*|node()" priority="-2" mode="M322">
      <xsl:apply-templates select="*" mode="M322"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00147-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M323">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and not($bannerClassification='U'))                  then (index-of($bannerNonICmarkings_tok, 'LES') &gt; 0)                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and not($bannerClassification='U')) then (index-of($bannerNonICmarkings_tok, 'LES') &gt; 0) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00147][Error] Classified USA documents having LES-NF Data must have LES at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M323"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M323"/>
   <xsl:template match="@*|node()" priority="-2" mode="M323">
      <xsl:apply-templates select="*" mode="M323"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00149-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('U'))                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('LES-NF'))                       )]"
                 priority="1000"
                 mode="M324">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('U'))                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('LES-NF'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES-NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES-NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00149][Error] Unclassified USA documents having LES-NF data must have LES-NF at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M324"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M324"/>
   <xsl:template match="@*|node()" priority="-2" mode="M324">
      <xsl:apply-templates select="*" mode="M324"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00154-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M325">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="         some $ele in $partTags satisfies           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('FOUO'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('FOUO'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00154][Error] USA FOUO documents not using compilation must have FOUO data.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M325"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M325"/>
   <xsl:template match="@*|node()" priority="-2" mode="M325">
      <xsl:apply-templates select="*" mode="M325"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00155-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and $ISM_DOD5230_24_APPLIES                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M326">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and $ISM_DOD5230_24_APPLIES                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:noticeType,                      ('DoD-Dist-A', 'DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:noticeType, ('DoD-Dist-A', 'DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00155][Error] All USA documents that claim compliance with DoD5230.24 must have a distribution statement
            for the entire document.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M326"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M326"/>
   <xsl:template match="@*|node()" priority="-2" mode="M326">
      <xsl:apply-templates select="*" mode="M326"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00162-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and $ISM_DOD5230_24_APPLIES                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M327">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and $ISM_DOD5230_24_APPLIES                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>
      <xsl:variable name="matchingTokens"
                    select="           for $token in tokenize(normalize-space(string(@ism:noticeType)), ' ') return             if(matches($token,'^DoD-Dist-[ABCDEFX]$'))             then $token             else null           "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($matchingTokens) &lt;= 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($matchingTokens) &lt;= 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00162][Error] All USA documents that claim compliance with DoD5230.24 must have only 1 distribution statement
            for the entire document.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M327"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M327"/>
   <xsl:template match="@*|node()" priority="-2" mode="M327">
      <xsl:apply-templates select="*" mode="M327"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00165-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('RS'))                       )]"
                 priority="1000"
                 mode="M328">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('RS'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('RS'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('RS'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00165][Error] USA documents having RISK SENSITIVE (RS) data must have RS at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M328"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M328"/>
   <xsl:template match="@*|node()" priority="-2" mode="M328">
      <xsl:apply-templates select="*" mode="M328"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00171-->
<xsl:template match="text()" priority="-1" mode="M329"/>
   <xsl:template match="@*|node()" priority="-2" mode="M329">
      <xsl:apply-templates select="*" mode="M329"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00172-->
<xsl:template match="text()" priority="-1" mode="M330"/>
   <xsl:template match="@*|node()" priority="-2" mode="M330">
      <xsl:apply-templates select="*" mode="M330"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00227-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                        and @ism:noticeType]"
                 priority="1000"
                 mode="M331">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                        and @ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $noticeToken in tokenize(normalize-space(string(@ism:noticeType)), ' ') satisfies                     matches($noticeToken, '^DoD-Dist-[ABCDEFX]')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $noticeToken in tokenize(normalize-space(string(@ism:noticeType)), ' ') satisfies matches($noticeToken, '^DoD-Dist-[ABCDEFX]')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00227][Error] Attribute @noticeType may only appear on the 
            resource node when it contains the values [DoD-Dist-A], [DoD-Dist-B], 
            [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X].
            
            Human Readable: Documents may only specify a document-level notice if
            it pertains to DoD Distribution.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M331"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M331"/>
   <xsl:template match="@*|node()" priority="-2" mode="M331">
      <xsl:apply-templates select="*" mode="M331"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00228-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))]"
                 priority="1000"
                 mode="M332">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="index-of($partAtomicEnergyMarkings_tok,'FRD')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partAtomicEnergyMarkings_tok,'FRD')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00228][Error] USA documents marked FRD at the resource level must have FRD data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M332"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M332"/>
   <xsl:template match="@*|node()" priority="-2" mode="M332">
      <xsl:apply-templates select="*" mode="M332"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00229-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))]"
                 priority="1000"
                 mode="M333">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="index-of($partAtomicEnergyMarkings_tok,'RD')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partAtomicEnergyMarkings_tok,'RD')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00229][Error] USA documents marked RD at the resource level must have RD data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M333"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M333"/>
   <xsl:template match="@*|node()" priority="-2" mode="M333">
      <xsl:apply-templates select="*" mode="M333"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00230-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M334">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>
      <xsl:variable name="matchingTokens"
                    select="           for $token in tokenize(normalize-space(string(@ism:atomicEnergyMarkings)), ' ') return             if(matches($token,'^FRD-SG-[1-9][0-9]?$'))             then $token             else null           "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $token in $matchingTokens satisfies                             index-of($partAtomicEnergyMarkings_tok, $token) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $token in $matchingTokens satisfies index-of($partAtomicEnergyMarkings_tok, $token) &gt; 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00230][Error] USA documents marked FRD-SG-## at the resource level must have FRD-SG-## data, where ## is the same.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M334"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M334"/>
   <xsl:template match="@*|node()" priority="-2" mode="M334">
      <xsl:apply-templates select="*" mode="M334"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00231-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M335">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>
      <xsl:variable name="matchingTokens"
                    select="         for $token in tokenize(normalize-space(string(@ism:atomicEnergyMarkings)), ' ') return           if(matches($token,'^RD-SG-[1-9][0-9]?$'))           then $token           else null         "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $token in $matchingTokens satisfies                           index-of($partAtomicEnergyMarkings_tok, $token) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $token in $matchingTokens satisfies index-of($partAtomicEnergyMarkings_tok, $token) &gt; 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00231][Error] USA documents marked RD-SG-## at the resource level must have RD-SG-## data, where ## is the same.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M335"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M335"/>
   <xsl:template match="@*|node()" priority="-2" mode="M335">
      <xsl:apply-templates select="*" mode="M335"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00246-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD','FRD', 'TFNI'))]"
                 priority="1000"
                 mode="M336">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD','FRD', 'TFNI'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:declassException, ('AEA', 'NATO-AEA'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:declassException, ('AEA', 'NATO-AEA'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00246][Error] USA documents containing [RD], [FRD], or [TFNI] data must have declassException containing [AEA] or [NATO-AEA] at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M336"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M336"/>
   <xsl:template match="@*|node()" priority="-2" mode="M336">
      <xsl:apply-templates select="*" mode="M336"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00298-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('TFNI'))                       )]"
                 priority="1000"
                 mode="M337">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('TFNI'))                       )]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('TFNI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('TFNI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00298][Error] USA documents having Transclassified Foreign Nuclear Information (TFNI) must have TFNI at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M337"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M337"/>
   <xsl:template match="@*|node()" priority="-2" mode="M337">
      <xsl:apply-templates select="*" mode="M337"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00303-->
<xsl:template match="text()" priority="-1" mode="M338"/>
   <xsl:template match="@*|node()" priority="-2" mode="M338">
      <xsl:apply-templates select="*" mode="M338"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00312-->
<xsl:template match="text()" priority="-1" mode="M339"/>
   <xsl:template match="@*|node()" priority="-2" mode="M339">
      <xsl:apply-templates select="*" mode="M339"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00316-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:declassException, ('NATO'))]"
                 priority="1000"
                 mode="M340">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:declassException, ('NATO'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="index-of($partOwnerProducer_tok,'NATO')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partOwnerProducer_tok,'NATO')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00316][Error] USA documents marked with a NATO declass exemption must have NATO portions.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M340"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M340"/>
   <xsl:template match="@*|node()" priority="-2" mode="M340">
      <xsl:apply-templates select="*" mode="M340"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00317-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:declassException, ('NATO-AEA'))]"
                 priority="1000"
                 mode="M341">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:declassException, ('NATO-AEA'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="index-of($partOwnerProducer_tok,'NATO')&gt;0 and count($partAtomicEnergyMarkings_tok)&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partOwnerProducer_tok,'NATO')&gt;0 and count($partAtomicEnergyMarkings_tok)&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00317][Error] USA documents marked with a NATO-AEA declass exemption must have at lease one NATO portion 
            and one portion that contains Atomic Energy Markings.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M341"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M341"/>
   <xsl:template match="@*|node()" priority="-2" mode="M341">
      <xsl:apply-templates select="*" mode="M341"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00318-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and                         @ism:releasableTo]"
                 priority="1000"
                 mode="M342">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and                         @ism:releasableTo]"/>
      <xsl:variable name="msg"
                    select="'[ISM-ID-00318][Error] Rollup compilation does not meet CAPCO guidance. '"/>
      <xsl:variable name="result"
                    select="util:checkRelToPortionsAgainstBannerAndGetCommonCountries(@ism:releasableTo, $partTags)"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if($result[1]='BANNER_NOT_A_SUBSET_OF_A_PORTION')                 then false()                 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if($result[1]='BANNER_NOT_A_SUBSET_OF_A_PORTION') then false() else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$msg"/>
                  <xsl:text/> There exists a portion with @ism:releasableTo in this document for which 
            this banner @ism:releasableTo is not a subset.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(count(tokenize(string($result), ' '))=0)                 then false()                 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(count(tokenize(string($result), ' '))=0) then false() else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$msg"/>
                  <xsl:text/> The banner cannot have @ism:releasableTo because
            there is no common country in @ism:releasableTo for the contributing portions.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(not(util:containsSpecialTetra(@ism:releasableTo)) and @ism:compilationReason)                     then util:bannerIsSubset(@ism:releasableTo, $result)                     else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not(util:containsSpecialTetra(@ism:releasableTo)) and @ism:compilationReason) then util:bannerIsSubset(@ism:releasableTo, $result) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$msg"/>
                  <xsl:text/> The banner @ism:releasableTo must be a subset 
            of the common countries for contributing portions because @ism:compilationReason
            is specified. Common countries: [<xsl:text/>
                  <xsl:value-of select="$result"/>
                  <xsl:text/>].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(not(util:containsSpecialTetra(@ism:releasableTo)) and not(@ism:compilationReason))                     then util:bannerIsSubset(@ism:releasableTo, $result) and util:bannerIsSubset($result, @ism:releasableTo)                     else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not(util:containsSpecialTetra(@ism:releasableTo)) and not(@ism:compilationReason)) then util:bannerIsSubset(@ism:releasableTo, $result) and util:bannerIsSubset($result, @ism:releasableTo) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$msg"/>
                  <xsl:text/> The banner @ism:releasableTo must be equal to 
            the set of the common countries because @ism:compilationReason is not specified.
            Common countries: [<xsl:text/>
                  <xsl:value-of select="$result"/>
                  <xsl:text/>].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M342"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M342"/>
   <xsl:template match="@*|node()" priority="-2" mode="M342">
      <xsl:apply-templates select="*" mode="M342"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00319-->


	<!--RULE -->
<xsl:template match="*[@ism:releasableTo and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M343">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:releasableTo and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(tokenize(normalize-space(string(@ism:releasableTo)), ' ')) &gt; 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(normalize-space(string(@ism:releasableTo)), ' ')) &gt; 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00319][Error] If attribute releasableTo is specified, then it must
            contain more than a single token.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M343"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M343"/>
   <xsl:template match="@*|node()" priority="-2" mode="M343">
      <xsl:apply-templates select="*" mode="M343"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00320-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and                             (@ism:releasableTo or @ism:displayOnlyTo)]"
                 priority="1000"
                 mode="M344">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and                             (@ism:releasableTo or @ism:displayOnlyTo)]"/>
      <xsl:variable name="result"
                    select="util:checkDisplayToPortionsAgainstBannerAndGetCommonCountries(util:getDisplayToCountries(.), $partTags)"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if($result[1]='BANNER_NOT_A_SUBSET_OF_A_PORTION')                 then false()                 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if($result[1]='BANNER_NOT_A_SUBSET_OF_A_PORTION') then false() else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00320][Error] There exists a portion with the combination of @ism:releasableTo and @ism:displayOnlyTo in this document for which 
            this banner @ism:releasableTo combined with the banner @ism:releasableTo is not a subset
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(count(tokenize(string($result), ' '))=0)                 then false()                 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(count(tokenize(string($result), ' '))=0) then false() else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00320][Error] The banner cannot have @ism:displayOnlyTo because
            there is no common country in the contributing portions.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(not(util:containsSpecialTetra(util:getDisplayToCountries(.))) and @ism:compilationReason)                     then util:bannerIsSubset(util:getDisplayToCountries(.), $result)                     else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not(util:containsSpecialTetra(util:getDisplayToCountries(.))) and @ism:compilationReason) then util:bannerIsSubset(util:getDisplayToCountries(.), $result) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00320][Error] The banner @ism:releasableTo and @ism:displayOnlyTo must be a subset 
            of the common countries for contributing portions because @ism:compilationReason
            is specified. Common countries: [<xsl:text/>
                  <xsl:value-of select="$result"/>
                  <xsl:text/>].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(not(util:containsSpecialTetra(util:getDisplayToCountries(.))) and not(@ism:compilationReason))                     then util:bannerIsSubset(util:getDisplayToCountries(.), $result) and util:bannerIsSubset($result, util:getDisplayToCountries(.))                     else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not(util:containsSpecialTetra(util:getDisplayToCountries(.))) and not(@ism:compilationReason)) then util:bannerIsSubset(util:getDisplayToCountries(.), $result) and util:bannerIsSubset($result, util:getDisplayToCountries(.)) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00320][Error] The banner @ism:releasableTo and @ism:displayOnlyTo must be 
            equal to the set of common countries for contributing portions because @ism:compilationReason
            is not specified. Common countries: [<xsl:text/>
                  <xsl:value-of select="$result"/>
                  <xsl:text/>].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M344"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M344"/>
   <xsl:template match="@*|node()" priority="-2" mode="M344">
      <xsl:apply-templates select="*" mode="M344"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00114-->
<xsl:template match="text()" priority="-1" mode="M345"/>
   <xsl:template match="@*|node()" priority="-2" mode="M345">
      <xsl:apply-templates select="*" mode="M345"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00121-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:SARIdentifier]" priority="1000"
                 mode="M346">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:SARIdentifier]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:SARIdentifier, $SARIdentifierList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:SARIdentifier, $SARIdentifierList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00121][Error] If ISM_CAPCO_RESOURCE and attribute SARIdentifier      is specified, then each of its values must be ordered in accordance      with CVEnumISMSAR.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:SARIdentifier, $SARIdentifierList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:SARIdentifier"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M346"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M346"/>
   <xsl:template match="@*|node()" priority="-2" mode="M346">
      <xsl:apply-templates select="*" mode="M346"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00010-->
<xsl:template match="text()" priority="-1" mode="M347"/>
   <xsl:template match="@*|node()" priority="-2" mode="M347">
      <xsl:apply-templates select="*" mode="M347"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00042-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and @ism:SCIcontrols]" priority="1000" mode="M348">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and @ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:SCIcontrols, $SCIcontrolsList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:SCIcontrols, $SCIcontrolsList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00042][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols      is specified, each of its values must be ordered in accordance with     CVEnumISMSCIControls.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:SCIcontrols, $SCIcontrolsList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:SCIcontrols"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M348"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M348"/>
   <xsl:template match="@*|node()" priority="-2" mode="M348">
      <xsl:apply-templates select="*" mode="M348"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00043-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))]"
                 priority="1000"
                 mode="M349">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S', 'C'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S', 'C'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00043][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
            contains the name token [SI], then attribute classification must have
            a value of [TS], [S], or [C].
            
            Human Readable: A USA document containing Special Intelligence (SI) 
            data must be classified CONFIDENTIAL, SECRET, or TOP SECRET. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M349"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M349"/>
   <xsl:template match="@*|node()" priority="-2" mode="M349">
      <xsl:apply-templates select="*" mode="M349"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00044-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G'))]"
                 priority="1000"
                 mode="M350">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00044][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
            contains a name token starting with [SI-G], then attribute
            classification must have a value of [TS].
            
            Human Readable: A USA document containing Special Intelligence (SI)
            GAMMA compartment data must be classified TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M350"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M350"/>
   <xsl:template match="@*|node()" priority="-2" mode="M350">
      <xsl:apply-templates select="*" mode="M350"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00045-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G'))]"
                 priority="1000"
                 mode="M351">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00045][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
            contains a name token starting with [SI-G], then attribute
            disseminationControls must contain the name token [OC].
            
            Human Readable: A USA document containing Special Intelligence (SI)
            GAMMA compartment data must be marked for ORIGINATOR CONTROLLED 
            dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M351"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M351"/>
   <xsl:template match="@*|node()" priority="-2" mode="M351">
      <xsl:apply-templates select="*" mode="M351"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00046-->
<xsl:template match="text()" priority="-1" mode="M352"/>
   <xsl:template match="@*|node()" priority="-2" mode="M352">
      <xsl:apply-templates select="*" mode="M352"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00047-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))]"
                 priority="1000"
                 mode="M353">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00047][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
            contains the name token [TK], then attribute classification must have
            a value of [TS] or [S].
            
            Human Readable: A USA document containing TALENT KEYHOLE data must
            be classified SECRET or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M353"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M353"/>
   <xsl:template match="@*|node()" priority="-2" mode="M353">
      <xsl:apply-templates select="*" mode="M353"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00048-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))]"
                 priority="1000"
                 mode="M354">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S', 'C'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S', 'C'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00048][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
            contains the name token [HCS], then attribute classification must have
            a value of [TS], [S], or [C].
            
            Human Readable: A USA document containing HCS data must be classified
            CONFIDENTIAL, SECRET, or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M354"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M354"/>
   <xsl:template match="@*|node()" priority="-2" mode="M354">
      <xsl:apply-templates select="*" mode="M354"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00049-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))]"
                 priority="1000"
                 mode="M355">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00049][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
            contains the name token [HCS], then attribute disseminationControls
            must contain the name token [NF].
            
            Human Readable: A USA document containing HCS data must be marked
            for NO FOREIGN dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M355"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M355"/>
   <xsl:template match="@*|node()" priority="-2" mode="M355">
      <xsl:apply-templates select="*" mode="M355"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00122-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK'))]"
                 priority="1000"
                 mode="M356">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00122][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
            contains the name token [KDK], then attribute classification must have
            a value of [TS] or [S].
            
            Human Readable: A USA document with KLONDIKE data must be 
            classified SECRET or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M356"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M356"/>
   <xsl:template match="@*|node()" priority="-2" mode="M356">
      <xsl:apply-templates select="*" mode="M356"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00123-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK'))]"
                 priority="1000"
                 mode="M357">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00123][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols
            contains the name token [KDK], then attribute disseminationControls
            must contain the name token [NF].
            
            Human Readable: A USA document containing KLONDIKE data must also be
            marked for NO FOREIGN dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M357"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M357"/>
   <xsl:template match="@*|node()" priority="-2" mode="M357">
      <xsl:apply-templates select="*" mode="M357"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00177-->
<xsl:template match="text()" priority="-1" mode="M358"/>
   <xsl:template match="@*|node()" priority="-2" mode="M358">
      <xsl:apply-templates select="*" mode="M358"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00186-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G-[A-Z]{4}$'))]"
                 priority="1000"
                 mode="M359">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G-[A-Z]{4}$'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00186][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains a token matching [SI-G-XXXX],
          where X is represented by the regular expression character class [A-Z]{4}, then it must also contain the
          name token [SI-G].
          
          Human Readable: A USA document that contains Special Intelligence (SI) GAMMA sub-compartments must
          also specify that it contains SI-GAMMA compartment data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M359"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M359"/>
   <xsl:template match="@*|node()" priority="-2" mode="M359">
      <xsl:apply-templates select="*" mode="M359"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00187-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))]"
                 priority="1000"
                 mode="M360">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00187][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G],
          then it must also contain the name token [SI].
          
          Human Readable: A USA document that contains Special Intelligence (SI) -GAMMA compartment data must also specify that 
          it contains SI data. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M360"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M360"/>
   <xsl:template match="@*|node()" priority="-2" mode="M360">
      <xsl:apply-templates select="*" mode="M360"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00241-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('RSV-[A-Z0-9]{3}'))]"
                 priority="1000"
                 mode="M361">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('RSV-[A-Z0-9]{3}'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00241][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [RSV-XXX],
            then it must also contain the name token [RSV].
            
            Human Readable: A USA document that contains RESEVERE data (RSV) compartment data must also specify that 
            it contains RSV data. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M361"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M361"/>
   <xsl:template match="@*|node()" priority="-2" mode="M361">
      <xsl:apply-templates select="*" mode="M361"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00242-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))]"
                 priority="1000"
                 mode="M362">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00242][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [RSV],
            then it must also have attribute classificatoin with a value of [S] or [TS].
            
            Human Readalbe: A USA document that contains RESERVE data must be classified SECRET or TOP SECRET. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M362"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M362"/>
   <xsl:template match="@*|node()" priority="-2" mode="M362">
      <xsl:apply-templates select="*" mode="M362"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00243-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))]"
                 priority="1000"
                 mode="M363">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyTokenMatching(@ism:SCIcontrols, ('RSV-[A-Z0-9]{3}'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyTokenMatching(@ism:SCIcontrols, ('RSV-[A-Z0-9]{3}'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00243][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [RSV],
      then it must also contain a compartment [RSV-XXX].
      
      Human Readable: RESERVE is not permitted as a stand-alone value and a compartment must be expressed.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M363"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M363"/>
   <xsl:template match="@*|node()" priority="-2" mode="M363">
      <xsl:apply-templates select="*" mode="M363"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00301-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL', 'EL-EU', 'EL-NK'))]"
                 priority="1000"
                 mode="M364">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL', 'EL-EU', 'EL-NK'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyTokenMatching(@ism:SCIcontrols, ('SI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyTokenMatching(@ism:SCIcontrols, ('SI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00301][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains any of the name tokens [EL],
      [EL-EU], or [EL-NK], then it must also contain the name token [SI].
      
      Human Readable: A USA document that contains ENDSEAL (EL), -ECRU (EK), or -NONBOOK (NK) compartment data must also specify that 
      it contains SI data. 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M364"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M364"/>
   <xsl:template match="@*|node()" priority="-2" mode="M364">
      <xsl:apply-templates select="*" mode="M364"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00304-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-BLFH'))]"
                 priority="1000"
                 mode="M365">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-BLFH'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00304][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK-BLFH],
          then it must also contain the name token [KDK].
          
          Human Readable: A USA document that contains KLONDIKE (KDK) -BLUEFISH compartment data must also specify that 
          it contains KDK data. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M365"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M365"/>
   <xsl:template match="@*|node()" priority="-2" mode="M365">
      <xsl:apply-templates select="*" mode="M365"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00305-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE     and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-IDIT'))]"
                 priority="1000"
                 mode="M366">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE     and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-IDIT'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00305][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK-IDIT],
      then it must also contain the name token [KDK].
      
      Human Readable: A USA document that contains KLONDIKE (KDK) -IDITAROD compartment data must also specify that 
      it contains KDK data. 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M366"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M366"/>
   <xsl:template match="@*|node()" priority="-2" mode="M366">
      <xsl:apply-templates select="*" mode="M366"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00306-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE     and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-KAND'))]"
                 priority="1000"
                 mode="M367">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE     and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-KAND'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00306][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK-KAND],
      then it must also contain the name token [KDK].
      
      Human Readable: A USA document that contains KLONDIKE (KDK) -KANDIK compartment data must also specify that 
      it contains KDK data. 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M367"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M367"/>
   <xsl:template match="@*|node()" priority="-2" mode="M367">
      <xsl:apply-templates select="*" mode="M367"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00307-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^KDK-BLFH-[A-Z]{1,6}$'))]"
                 priority="1000"
                 mode="M368">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^KDK-BLFH-[A-Z]{1,6}$'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-BLFH'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-BLFH'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00307][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains a token matching [KDK-BLFH-XXXXXX],
            where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
            name token [KDK-BLFH].
            
            Human Readable: A USA document that contains KLONDIKE (KDK) BLUEFISH sub-compartments must
            also specify that it contains KDK -BLUEFISH compartment data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M368"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M368"/>
   <xsl:template match="@*|node()" priority="-2" mode="M368">
      <xsl:apply-templates select="*" mode="M368"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00308-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^KDK-IDIT-[A-Z]{1,6}$'))]"
                 priority="1000"
                 mode="M369">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^KDK-IDIT-[A-Z]{1,6}$'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-IDIT'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-IDIT'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00308][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains a token matching [KDK-IDIT-XXXXXX],
            where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
            name token [KDK-IDIT].
            
            Human Readable: A USA document that contains KLONDIKE (KDK) IDITAROD sub-compartments must
            also specify that it contains KDK -IDITAROD compartment data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M369"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M369"/>
   <xsl:template match="@*|node()" priority="-2" mode="M369">
      <xsl:apply-templates select="*" mode="M369"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00309-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^KDK-KAND-[A-Z]{1,6}$'))]"
                 priority="1000"
                 mode="M370">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^KDK-KAND-[A-Z]{1,6}$'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-KAND'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('KDK-KAND'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00309][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains a token matching [KDK-KAND-XXXXXX],
            where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
            name token [KDK-KAND].
            
            Human Readable: A USA document that contains KLONDIKE (KDK) KANDIK sub-compartments must
            also specify that it contains KDK -KANDIK compartment data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M370"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M370"/>
   <xsl:template match="@*|node()" priority="-2" mode="M370">
      <xsl:apply-templates select="*" mode="M370"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00310-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE     and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL-EU'))]"
                 priority="1000"
                 mode="M371">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE     and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL-EU'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00310][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [EL-EU],
      then it must also contain the name token [EL].
      
      Human Readable: A USA document that contains ENDSEAL (EL) -ECRU compartment data must also specify that 
      it contains EL data. 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M371"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M371"/>
   <xsl:template match="@*|node()" priority="-2" mode="M371">
      <xsl:apply-templates select="*" mode="M371"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00311-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL-NK'))]"
                 priority="1000"
                 mode="M372">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL-NK'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('EL'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00311][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [EL-NK],
            then it must also contain the name token [EL].
            
            Human Readable: A USA document that contains ENDSEAL (EL) -NONBOOK compartment data must also specify that 
            it contains EL data. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M372"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M372"/>
   <xsl:template match="@*|node()" priority="-2" mode="M372">
      <xsl:apply-templates select="*" mode="M372"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00268-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M373">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:atomicEnergyMarkings, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:atomicEnergyMarkings, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00268][Error] All atomicEnergyMarkings attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M373"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M373"/>
   <xsl:template match="@*|node()" priority="-2" mode="M373">
      <xsl:apply-templates select="*" mode="M373"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00269-->


	<!--RULE -->
<xsl:template match="*[@ism:classification]" priority="1000" mode="M374">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:classification]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:classification, $NmTokenPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:classification, $NmTokenPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00269][Error] All classifiction attributes values must be of type NmToken. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M374"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M374"/>
   <xsl:template match="@*|node()" priority="-2" mode="M374">
      <xsl:apply-templates select="*" mode="M374"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00270-->


	<!--RULE -->
<xsl:template match="*[@ism:classificationReason]" priority="1000" mode="M375">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classificationReason]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(@ism:classificationReason) &lt;= 4096"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:classificationReason) &lt;= 4096">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00270][Error] All classificationReason attributes must be a string with less than 4096 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M375"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M375"/>
   <xsl:template match="@*|node()" priority="-2" mode="M375">
      <xsl:apply-templates select="*" mode="M375"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00271-->


	<!--RULE -->
<xsl:template match="*[@ism:classifiedBy]" priority="1000" mode="M376">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:classifiedBy]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(@ism:classifiedBy) &lt;= 1024"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:classifiedBy) &lt;= 1024">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00271][Error] All classifiedBy attributes must be a string with less than 1024 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M376"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M376"/>
   <xsl:template match="@*|node()" priority="-2" mode="M376">
      <xsl:apply-templates select="*" mode="M376"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00272-->


	<!--RULE -->
<xsl:template match="*[@ism:compilationReason]" priority="1000" mode="M377">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:compilationReason]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(@ism:compilationReason) &lt;= 1024"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:compilationReason) &lt;= 1024">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00272][Error] All compilationReason attributes must be a string with less than 1024 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M377"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M377"/>
   <xsl:template match="@*|node()" priority="-2" mode="M377">
      <xsl:apply-templates select="*" mode="M377"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00273-->


	<!--RULE -->
<xsl:template match="*[@ism:compliesWith]" priority="1000" mode="M378">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:compliesWith]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:compliesWith, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:compliesWith, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00273][Error] All compliesWith attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M378"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M378"/>
   <xsl:template match="@*|node()" priority="-2" mode="M378">
      <xsl:apply-templates select="*" mode="M378"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00274-->


	<!--RULE -->
<xsl:template match="*[@ism:createDate]" priority="1000" mode="M379">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:createDate]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:createDate, $DatePattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:createDate, $DatePattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00274][Error] All createDate attributes values must be of type Date. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M379"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M379"/>
   <xsl:template match="@*|node()" priority="-2" mode="M379">
      <xsl:apply-templates select="*" mode="M379"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00275-->


	<!--RULE -->
<xsl:template match="*[@ism:declassDate]" priority="1000" mode="M380">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:declassDate]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:declassDate, $DatePattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:declassDate, $DatePattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00275][Error] All declassDate attributes values must be of type Date. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M380"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M380"/>
   <xsl:template match="@*|node()" priority="-2" mode="M380">
      <xsl:apply-templates select="*" mode="M380"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00276-->


	<!--RULE -->
<xsl:template match="*[@ism:declassEvent]" priority="1000" mode="M381">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:declassEvent]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(@ism:declassEvent) &lt;= 1024"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:declassEvent) &lt;= 1024">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00276][Error] All declassEvent attributes must be a string with less than 1024 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M381"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M381"/>
   <xsl:template match="@*|node()" priority="-2" mode="M381">
      <xsl:apply-templates select="*" mode="M381"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00277-->


	<!--RULE -->
<xsl:template match="*[@ism:declassException]" priority="1000" mode="M382">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:declassException]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:declassException, $NmTokenPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:declassException, $NmTokenPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00277][Error] All declassException attributes values must be of type NmToken. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M382"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M382"/>
   <xsl:template match="@*|node()" priority="-2" mode="M382">
      <xsl:apply-templates select="*" mode="M382"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00278-->


	<!--RULE -->
<xsl:template match="*[@ism:derivativelyClassifiedBy]" priority="1000" mode="M383">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:derivativelyClassifiedBy]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(@ism:derivativelyClassifiedBy) &lt;= 1024"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:derivativelyClassifiedBy) &lt;= 1024">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00278][Error] All derivativelyClassifiedBy attributes must be a string with less than 1024 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M383"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M383"/>
   <xsl:template match="@*|node()" priority="-2" mode="M383">
      <xsl:apply-templates select="*" mode="M383"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00279-->


	<!--RULE -->
<xsl:template match="*[@ism:derivedFrom]" priority="1000" mode="M384">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:derivedFrom]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(@ism:derivedFrom) &lt;= 1024"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:derivedFrom) &lt;= 1024">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00279][Error] All derivedFrom attributes must be a string with less than 1024 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M384"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M384"/>
   <xsl:template match="@*|node()" priority="-2" mode="M384">
      <xsl:apply-templates select="*" mode="M384"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00280-->


	<!--RULE -->
<xsl:template match="*[@ism:displayOnlyTo]" priority="1000" mode="M385">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:displayOnlyTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:displayOnlyTo, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:displayOnlyTo, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00280][Error] All displayOnlyTo attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M385"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M385"/>
   <xsl:template match="@*|node()" priority="-2" mode="M385">
      <xsl:apply-templates select="*" mode="M385"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00281-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M386">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:disseminationControls, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:disseminationControls, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00281][Error] All disseminationControls attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M386"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M386"/>
   <xsl:template match="@*|node()" priority="-2" mode="M386">
      <xsl:apply-templates select="*" mode="M386"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00282-->


	<!--RULE -->
<xsl:template match="*[@ism:excludeFromRollup]" priority="1000" mode="M387">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:excludeFromRollup]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:excludeFromRollup, $BooleanPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:excludeFromRollup, $BooleanPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00282][Error] All excludeFromRollup attributes values must be of type Boolean. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M387"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M387"/>
   <xsl:template match="@*|node()" priority="-2" mode="M387">
      <xsl:apply-templates select="*" mode="M387"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00283-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceOpen]" priority="1000" mode="M388">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:FGIsourceOpen]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:FGIsourceOpen, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:FGIsourceOpen, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00283][Error] All FGIsourceOpen attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M388"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M388"/>
   <xsl:template match="@*|node()" priority="-2" mode="M388">
      <xsl:apply-templates select="*" mode="M388"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00284-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceProtected]" priority="1000" mode="M389">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:FGIsourceProtected]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:FGIsourceProtected, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:FGIsourceProtected, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00284][Error] All FGIsourceProtected attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M389"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M389"/>
   <xsl:template match="@*|node()" priority="-2" mode="M389">
      <xsl:apply-templates select="*" mode="M389"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00285-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M390">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:nonICmarkings, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:nonICmarkings, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00285][Error] All nonICmarkings attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M390"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M390"/>
   <xsl:template match="@*|node()" priority="-2" mode="M390">
      <xsl:apply-templates select="*" mode="M390"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00286-->


	<!--RULE -->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M391">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonUSControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:nonUSControls, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:nonUSControls, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00286][Error] All nonUSControls attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M391"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M391"/>
   <xsl:template match="@*|node()" priority="-2" mode="M391">
      <xsl:apply-templates select="*" mode="M391"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00287-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeDate]" priority="1000" mode="M392">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeDate]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:noticeDate, $DatePattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:noticeDate, $DatePattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00287][Error] All noticeDate attributes values must be of type Date. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M392"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M392"/>
   <xsl:template match="@*|node()" priority="-2" mode="M392">
      <xsl:apply-templates select="*" mode="M392"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00288-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeReason]" priority="1000" mode="M393">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeReason]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(@ism:noticeReason) &lt;= 2048"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:noticeReason) &lt;= 2048">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00288][Error] All noticeReason attributes must be a string with less than 2048 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M393"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M393"/>
   <xsl:template match="@*|node()" priority="-2" mode="M393">
      <xsl:apply-templates select="*" mode="M393"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00289-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M394">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:noticeType, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:noticeType, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00289][Error] All noticeType attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M394"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M394"/>
   <xsl:template match="@*|node()" priority="-2" mode="M394">
      <xsl:apply-templates select="*" mode="M394"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00290-->


	<!--RULE -->
<xsl:template match="*[@ism:externalNotice]" priority="1000" mode="M395">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:externalNotice]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:externalNotice, $BooleanPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:externalNotice, $BooleanPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00290][Error] All externalNotice attributes values must be of type Boolean. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M395"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M395"/>
   <xsl:template match="@*|node()" priority="-2" mode="M395">
      <xsl:apply-templates select="*" mode="M395"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00291-->


	<!--RULE -->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M396">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:ownerProducer]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:ownerProducer, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:ownerProducer, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00291][Error] All ownerProducer attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M396"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M396"/>
   <xsl:template match="@*|node()" priority="-2" mode="M396">
      <xsl:apply-templates select="*" mode="M396"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00292-->


	<!--RULE -->
<xsl:template match="*[@ism:pocType]" priority="1000" mode="M397">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:pocType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:pocType, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:pocType, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00292][Error] All pocType attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M397"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M397"/>
   <xsl:template match="@*|node()" priority="-2" mode="M397">
      <xsl:apply-templates select="*" mode="M397"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00293-->


	<!--RULE -->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M398">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:releasableTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:releasableTo, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:releasableTo, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00293][Error] All releasableTo attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M398"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M398"/>
   <xsl:template match="@*|node()" priority="-2" mode="M398">
      <xsl:apply-templates select="*" mode="M398"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00282-->


	<!--RULE -->
<xsl:template match="*[@ism:resourceElement]" priority="1000" mode="M399">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:resourceElement]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:resourceElement, $BooleanPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:resourceElement, $BooleanPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00282][Error] All resourceElement attributes values must be of type Boolean. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M399"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M399"/>
   <xsl:template match="@*|node()" priority="-2" mode="M399">
      <xsl:apply-templates select="*" mode="M399"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00295-->


	<!--RULE -->
<xsl:template match="*[@ism:SARIdentifier]" priority="1000" mode="M400">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SARIdentifier]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:SARIdentifier, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:SARIdentifier, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00295][Error] All SARIdentifier attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M400"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M400"/>
   <xsl:template match="@*|node()" priority="-2" mode="M400">
      <xsl:apply-templates select="*" mode="M400"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00296-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M401">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:SCIcontrols, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:SCIcontrols, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00296][Error] All SCIcontrols attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M401"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M401"/>
   <xsl:template match="@*|node()" priority="-2" mode="M401">
      <xsl:apply-templates select="*" mode="M401"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00297-->


	<!--RULE -->
<xsl:template match="*[@ism:unregisteredNoticeType]" priority="1000" mode="M402">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:unregisteredNoticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(@ism:unregisteredNoticeType) &lt;= 2048"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:unregisteredNoticeType) &lt;= 2048">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00297][Error] All unregisteredNoticeType attributes must be a string with less than 2048 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M402"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M402"/>
   <xsl:template match="@*|node()" priority="-2" mode="M402">
      <xsl:apply-templates select="*" mode="M402"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00011-->
<xsl:template match="text()" priority="-1" mode="M403"/>
   <xsl:template match="@*|node()" priority="-2" mode="M403">
      <xsl:apply-templates select="*" mode="M403"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00018-->
<xsl:template match="text()" priority="-1" mode="M404"/>
   <xsl:template match="@*|node()" priority="-2" mode="M404">
      <xsl:apply-templates select="*" mode="M404"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00019-->
<xsl:template match="text()" priority="-1" mode="M405"/>
   <xsl:template match="@*|node()" priority="-2" mode="M405">
      <xsl:apply-templates select="*" mode="M405"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00020-->
<xsl:template match="text()" priority="-1" mode="M406"/>
   <xsl:template match="@*|node()" priority="-2" mode="M406">
      <xsl:apply-templates select="*" mode="M406"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00021-->
<xsl:template match="text()" priority="-1" mode="M407"/>
   <xsl:template match="@*|node()" priority="-2" mode="M407">
      <xsl:apply-templates select="*" mode="M407"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00022-->
<xsl:template match="text()" priority="-1" mode="M408"/>
   <xsl:template match="@*|node()" priority="-2" mode="M408">
      <xsl:apply-templates select="*" mode="M408"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00253-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M409">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:atomicEnergyMarkings)), ' ') satisfies                      $searchTerm = $atomicEnergyMarkingsList or                     (some $atomicEnergyMarkingsListTerm in $atomicEnergyMarkingsList satisfies (matches(normalize-space($searchTerm), concat('^',$atomicEnergyMarkingsListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:atomicEnergyMarkings)), ' ') satisfies $searchTerm = $atomicEnergyMarkingsList or (some $atomicEnergyMarkingsListTerm in $atomicEnergyMarkingsList satisfies (matches(normalize-space($searchTerm), concat('^',$atomicEnergyMarkingsListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00253][Error] All @ism:atomicEnergyMarkings values must   be defined in CVEnumISMAtomicEnergyMarkings.xml.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M409"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M409"/>
   <xsl:template match="@*|node()" priority="-2" mode="M409">
      <xsl:apply-templates select="*" mode="M409"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00254-->


	<!--RULE -->
<xsl:template match="*[@ism:classification]" priority="1000" mode="M410">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:classification]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:classification)), ' ') satisfies                      $searchTerm = $classificationAllList or                     (some $classificationAllListTerm in $classificationAllList satisfies (matches(normalize-space($searchTerm), concat('^',$classificationAllListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:classification)), ' ') satisfies $searchTerm = $classificationAllList or (some $classificationAllListTerm in $classificationAllList satisfies (matches(normalize-space($searchTerm), concat('^',$classificationAllListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00254][Error] All @ism:classification values must   be a defined in CVEnumISMClassificationAll.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M410"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M410"/>
   <xsl:template match="@*|node()" priority="-2" mode="M410">
      <xsl:apply-templates select="*" mode="M410"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00255-->


	<!--RULE -->
<xsl:template match="*[@ism:compliesWith]" priority="1000" mode="M411">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:compliesWith]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:compliesWith)), ' ') satisfies                      $searchTerm = $compliesWithList or                     (some $compliesWithListTerm in $compliesWithList satisfies (matches(normalize-space($searchTerm), concat('^',$compliesWithListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:compliesWith)), ' ') satisfies $searchTerm = $compliesWithList or (some $compliesWithListTerm in $compliesWithList satisfies (matches(normalize-space($searchTerm), concat('^',$compliesWithListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00255][Error] All @ism:compliesWith values must   be defined in CVEnumISMCompliesWith.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M411"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M411"/>
   <xsl:template match="@*|node()" priority="-2" mode="M411">
      <xsl:apply-templates select="*" mode="M411"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00256-->


	<!--RULE -->
<xsl:template match="*[@ism:declassException]" priority="1000" mode="M412">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:declassException]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:declassException)), ' ') satisfies                      $searchTerm = $declassExceptionList or                     (some $declassExceptionListTerm in $declassExceptionList satisfies (matches(normalize-space($searchTerm), concat('^',$declassExceptionListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:declassException)), ' ') satisfies $searchTerm = $declassExceptionList or (some $declassExceptionListTerm in $declassExceptionList satisfies (matches(normalize-space($searchTerm), concat('^',$declassExceptionListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00256][Error] All @ism:declassException values must   be defined in CVEnumISM25X.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M412"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M412"/>
   <xsl:template match="@*|node()" priority="-2" mode="M412">
      <xsl:apply-templates select="*" mode="M412"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00257-->


	<!--RULE -->
<xsl:template match="*[@ism:displayOnlyTo]" priority="1000" mode="M413">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:displayOnlyTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:displayOnlyTo)), ' ') satisfies                      $searchTerm = $displayOnlyToList or                     (some $displayOnlyToListTerm in $displayOnlyToList satisfies (matches(normalize-space($searchTerm), concat('^',$displayOnlyToListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:displayOnlyTo)), ' ') satisfies $searchTerm = $displayOnlyToList or (some $displayOnlyToListTerm in $displayOnlyToList satisfies (matches(normalize-space($searchTerm), concat('^',$displayOnlyToListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00257][Error] All @ism:displayOnlyTo values must   be defined in CVEnumISMRelTo.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M413"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M413"/>
   <xsl:template match="@*|node()" priority="-2" mode="M413">
      <xsl:apply-templates select="*" mode="M413"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00258-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M414">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:disseminationControls)), ' ') satisfies                      $searchTerm = $disseminationControlsList or                     (some $disseminationControlsListTerm in $disseminationControlsList satisfies (matches(normalize-space($searchTerm), concat('^',$disseminationControlsListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:disseminationControls)), ' ') satisfies $searchTerm = $disseminationControlsList or (some $disseminationControlsListTerm in $disseminationControlsList satisfies (matches(normalize-space($searchTerm), concat('^',$disseminationControlsListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00258][Error] All @ism:disseminationControls values must   be a defined in CVEnumISMDissem.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M414"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M414"/>
   <xsl:template match="@*|node()" priority="-2" mode="M414">
      <xsl:apply-templates select="*" mode="M414"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00259-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceOpen]" priority="1000" mode="M415">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:FGIsourceOpen]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:FGIsourceOpen)), ' ') satisfies                      $searchTerm = $FGIsourceOpenList or                     (some $FGIsourceOpenListTerm in $FGIsourceOpenList satisfies (matches(normalize-space($searchTerm), concat('^',$FGIsourceOpenListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:FGIsourceOpen)), ' ') satisfies $searchTerm = $FGIsourceOpenList or (some $FGIsourceOpenListTerm in $FGIsourceOpenList satisfies (matches(normalize-space($searchTerm), concat('^',$FGIsourceOpenListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00259][Error] All @ism:FGIsourceOpen values must   be defined in CVEnumISMFGIOpen.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M415"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M415"/>
   <xsl:template match="@*|node()" priority="-2" mode="M415">
      <xsl:apply-templates select="*" mode="M415"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00260-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceProtected]" priority="1000" mode="M416">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:FGIsourceProtected]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:FGIsourceProtected)), ' ') satisfies                      $searchTerm = $FGIsourceProtectedList or                     (some $FGIsourceProtectedListTerm in $FGIsourceProtectedList satisfies (matches(normalize-space($searchTerm), concat('^',$FGIsourceProtectedListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:FGIsourceProtected)), ' ') satisfies $searchTerm = $FGIsourceProtectedList or (some $FGIsourceProtectedListTerm in $FGIsourceProtectedList satisfies (matches(normalize-space($searchTerm), concat('^',$FGIsourceProtectedListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00260][Error] All @ism:FGIsourceProtected values must   be defined in CVEnumISMFGIProtected.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M416"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M416"/>
   <xsl:template match="@*|node()" priority="-2" mode="M416">
      <xsl:apply-templates select="*" mode="M416"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00261-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M417">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:nonICmarkings)), ' ') satisfies                      $searchTerm = $nonICmarkingsList or                     (some $nonICmarkingsListTerm in $nonICmarkingsList satisfies (matches(normalize-space($searchTerm), concat('^',$nonICmarkingsListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:nonICmarkings)), ' ') satisfies $searchTerm = $nonICmarkingsList or (some $nonICmarkingsListTerm in $nonICmarkingsList satisfies (matches(normalize-space($searchTerm), concat('^',$nonICmarkingsListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00261][Error] All @ism:nonICmarkings values must   be defined in CVEnumISMNonIC.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M417"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M417"/>
   <xsl:template match="@*|node()" priority="-2" mode="M417">
      <xsl:apply-templates select="*" mode="M417"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00262-->


	<!--RULE -->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M418">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonUSControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:nonUSControls)), ' ') satisfies                      $searchTerm = $nonUSControlsList or                     (some $nonUSControlsListTerm in $nonUSControlsList satisfies (matches(normalize-space($searchTerm), concat('^',$nonUSControlsListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:nonUSControls)), ' ') satisfies $searchTerm = $nonUSControlsList or (some $nonUSControlsListTerm in $nonUSControlsList satisfies (matches(normalize-space($searchTerm), concat('^',$nonUSControlsListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00262][Error] Any @ism:nonUSControls values must   be defined in CVEnumISMNonUSControls.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M418"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M418"/>
   <xsl:template match="@*|node()" priority="-2" mode="M418">
      <xsl:apply-templates select="*" mode="M418"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00263-->


	<!--RULE -->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M419">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:ownerProducer]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:ownerProducer)), ' ') satisfies                      $searchTerm = $ownerProducerList or                     (some $ownerProducerListTerm in $ownerProducerList satisfies (matches(normalize-space($searchTerm), concat('^',$ownerProducerListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:ownerProducer)), ' ') satisfies $searchTerm = $ownerProducerList or (some $ownerProducerListTerm in $ownerProducerList satisfies (matches(normalize-space($searchTerm), concat('^',$ownerProducerListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00263][Error] Any @ism:ownerProducer values must   be defined in CVEnumISMOwnerProducer.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M419"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M419"/>
   <xsl:template match="@*|node()" priority="-2" mode="M419">
      <xsl:apply-templates select="*" mode="M419"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00264-->


	<!--RULE -->
<xsl:template match="*[@ism:pocType]" priority="1000" mode="M420">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:pocType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:pocType)), ' ') satisfies                      $searchTerm = $pocTypeList or                     (some $pocTypeListTerm in $pocTypeList satisfies (matches(normalize-space($searchTerm), concat('^',$pocTypeListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:pocType)), ' ') satisfies $searchTerm = $pocTypeList or (some $pocTypeListTerm in $pocTypeList satisfies (matches(normalize-space($searchTerm), concat('^',$pocTypeListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00264][Error] Any @ism:pocType values must   be defined in CVEnumISMPocType.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M420"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M420"/>
   <xsl:template match="@*|node()" priority="-2" mode="M420">
      <xsl:apply-templates select="*" mode="M420"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00265-->


	<!--RULE -->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M421">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:releasableTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:releasableTo)), ' ') satisfies                      $searchTerm = $releasableToList or                     (some $releasableToListTerm in $releasableToList satisfies (matches(normalize-space($searchTerm), concat('^',$releasableToListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:releasableTo)), ' ') satisfies $searchTerm = $releasableToList or (some $releasableToListTerm in $releasableToList satisfies (matches(normalize-space($searchTerm), concat('^',$releasableToListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00265][Error] Any @ism:releasableTo must   be a value in CVEnumISMRelTo.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M421"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M421"/>
   <xsl:template match="@*|node()" priority="-2" mode="M421">
      <xsl:apply-templates select="*" mode="M421"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00266-->


	<!--RULE -->
<xsl:template match="*[@ism:SARIdentifier]" priority="1000" mode="M422">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SARIdentifier]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:SARIdentifier)), ' ') satisfies                      $searchTerm = $SARIdentifierList or                     (some $SARIdentifierListTerm in $SARIdentifierList satisfies (matches(normalize-space($searchTerm), concat('^',$SARIdentifierListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:SARIdentifier)), ' ') satisfies $searchTerm = $SARIdentifierList or (some $SARIdentifierListTerm in $SARIdentifierList satisfies (matches(normalize-space($searchTerm), concat('^',$SARIdentifierListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00266][Error] Any @ism:SARIdentifier must   be a value in CVEnumISMSAR.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M422"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M422"/>
   <xsl:template match="@*|node()" priority="-2" mode="M422">
      <xsl:apply-templates select="*" mode="M422"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00267-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M423">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:SCIcontrols)), ' ') satisfies                      $searchTerm = $SCIcontrolsList or                     (some $SCIcontrolsListTerm in $SCIcontrolsList satisfies (matches(normalize-space($searchTerm), concat('^',$SCIcontrolsListTerm,'$'))))              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:SCIcontrols)), ' ') satisfies $searchTerm = $SCIcontrolsList or (some $SCIcontrolsListTerm in $SCIcontrolsList satisfies (matches(normalize-space($searchTerm), concat('^',$SCIcontrolsListTerm,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00267][Error] All @ism:SCIcontrols values must   be defined in CVEnumISMSCIControls.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M423"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M423"/>
   <xsl:template match="@*|node()" priority="-2" mode="M423">
      <xsl:apply-templates select="*" mode="M423"/>
   </xsl:template>
</xsl:stylesheet>