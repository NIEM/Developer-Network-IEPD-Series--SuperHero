<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet
[
<!ENTITY ns-ism "urn:us:gov:ic:ism">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
    xmlns:ism="&ns-ism;"
    version="1.0">
    
    <xsl:import href="../XSL/ISM/IC-ISM-PortionMark.xsl" />
    <xsl:import href="../XSL/ISM/IC-ISM-SecurityBanner.xsl" />
    <xsl:import href="../XSL/ISM/IC-ISM-ClassDeclass.xsl" />
    
    <xsl:output method="html" indent="yes" />
    
    <!--Determines when a test case failure will terminate the transform.-->
    <xsl:param name="failOnError" select="false()" />  
    <!--Determines whether or not to produce the classification banner in the HTML output (will be useful for generating public release artifacts)-->
    <xsl:param name="showBanner" select="true()" />
    
    <xsl:variable name="pass" select="'pass'" />
    <xsl:variable name="fail" select="'fail'" />
    <xsl:variable name="lowerCase" select="'abcdefghijklmnopqrstuvwxyz'" />
    <xsl:variable name="upperCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
    
    <xsl:variable name="authority-element" select="'authority'" />
    
    <xsl:template match="/">
        <html>
            <xsl:call-template name="head" /> 
            <xsl:call-template name="body" />
        </html>
    </xsl:template>
 
    <xsl:template name="head">
        <head>
            <xsl:call-template name="CSS" />     
            <xsl:call-template name="JavaScript"/>
        </head>
    </xsl:template>
     
    <xsl:template name="body">
        <body>
            <xsl:apply-templates select="ISMTestData" mode="security.banner" />
            
            <table id="test-summary">
                <caption>ISM test failures</caption>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Type</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
            
            <table id="test-results">
                <caption>ISM Banner Line/Portion Mark/Authority Block test results</caption>
                <thead>
                    <tr>
                        <th>Row Classif</th>
                        <th>Name</th>
                        <th>Type</th>
                        <th>Expected</th>
                        <th>Generated</th>
                        <th>Expect Fail</th>
                        <th>Equal</th>
                        <th>Test Result</th>
                    </tr>
                </thead>
                <tbody>          
                    <xsl:apply-templates select="ISMTestData/test" />
                </tbody>
            </table>
            <xsl:apply-templates select="ISMTestData" mode="security.banner" />
        </body>
    </xsl:template> 
     
    <xsl:template name="JavaScript">
        <xsl:call-template name="JavaScript.common"/>
        <xsl:call-template name="JavaScript.testConfig"/>
    </xsl:template>
    
    <xsl:template name="JavaScript.common">
        <script type="text/javascript">
            //Creates an event handler
            function addEvent(obj, evType, fn){ 
                if (obj.addEventListener){ 
                    obj.addEventListener(evType, fn, false); 
                    return true; 
                } else if (obj.attachEvent){ 
                    var r = obj.attachEvent("on"+evType, fn); 
                    return r; 
                } else { 
                    return false; 
                } 
            }
            
            function getElementsByClassName( strClassName, obj, failureList ) { 
                if (obj.className!=null &amp;&amp; obj.className.indexOf(strClassName) != -1) {
                    failureList[failureList.length] = obj;
                }
                for ( var i = 0; i &lt; obj.childNodes.length; i++ ) {
                    getElementsByClassName( strClassName, obj.childNodes[i], failureList);
                }
            }
        </script>
    </xsl:template>    
        
    <xsl:template name="JavaScript.testConfig">
        <script type="text/javascript">
            //Registers the window.onLoad event handler
            addEvent(window, 'load', displayFailureSummary);
            
            //Evaluates the HTML output and presents a summary table that links directly to the failures
            function displayFailureSummary() {
            var failureList = new Array();
            failureList.length = 0;
            var testTable = document.getElementById('test-results');
            getElementsByClassName( 'test-fail', testTable, failureList);
            var failureSummary = document.getElementById('test-summary');
            
            if (failureList.length > 0) {
            
            for (var i = 0; i &lt; failureList.length; i++){
            var row  = failureSummary.insertRow();
            var nameCell = row.insertCell();
            nameCell.innerText = failureList[i].previousSibling.cells[1].innerText;
            var  linkCell  = row.insertCell();
            linkCell.innerHTML = "&lt;a href='#"+failureList[i].id+"'>"+failureList[i].cells[0].innerText+"&lt;/a>";
            }
            
            var footer = failureSummary.createTFoot();
            var footerRow = footer.insertRow();
            var totalCell = footerRow.insertCell();
            totalCell.innerText="Total Tests: " + getTestCount(testTable);
            var footerCell = footerRow.insertCell();
            footerCell.rowspan="2";
            footerCell.innerText="Failures: " + failureList.length ;
            // footer.innerText=failureList.length + " failures";
            failureSummary.style.display = "inline";
            } else {
            failureSummary.style.display = "none";
            }
            }
            
            function getTestCount(testTable) {
            var count = 0;
            for (var i = 0; i &lt; testTable.rows.length; i++) {
            //If the row has more than 3 cells, then it is for a (banner, portion, authority) test
            if (testTable.rows[i].cells.length > 3) {
            count++;
            }
            }
            return count;
            }
        </script>
    </xsl:template>
    
    <!--***********************************************-->
    <!-- CSS style for the test results rendering -->
    <!--***********************************************-->
    <xsl:template name="CSS">        
        <style type="text/css">
            .<xsl:value-of select="$fail"/> {
            background-color:red;
            }
            .<xsl:value-of select="$pass"/> {
                background-color:#98fb98;
            }
            caption {
                background:#cecece;
                font-size:140%;
                border:1px solid #000;
                border-bottom:none;
                padding:5px;
                text-align:left;
            }
            table {
                border: 1px solid #000000;
                border-collapse:collapse;
            }
            thead tr th{
                padding-left:.5em;
                text-align:left;
                border-bottom:thin solid #00000;
            }
            tbody tr.even {
                background:#CECECE;
            }
            tbody tr td {
                border-bottom:1px solid #000000;
                white-space:nowrap;
                padding: .5em;
                border:1px solid #000000;
            }
            tbody tr.<xsl:value-of select="$authority-element"/> td{
                /* Authority Block warning messages can be really long, so allow this cell the wrap */
                white-space:normal;
            }
            tbody tr td.ism{                 
                border-bottom:thin solid #000000;
            }
            #test-summary {
                display:none;
                border-color: #F00000;
            }
            #test-summary caption{
                background-color: #F00000;
            }
            #test-summary tfoot {
                font-weight: bold;
            }
            #test-summary tfoot td{
                padding: .5em;
            }
        </style>
    </xsl:template>
            
    <!--***********************************************-->
    <!-- Render results of each test -->
    <!--***********************************************-->
    <xsl:template match="test">
        <!-- Count children to determine how many rows will be rendered for this test case (may have Portion, Banner and/or Declass)  -->
        <xsl:variable name="rows" select="count(*)-1" />
        <xsl:variable name="descriptionCount" select="count(./description)" />
        
        <tr>
            <td rowspan="{$rows +1 -$descriptionCount}">
                <xsl:apply-templates select="." mode="ism:portionmark" />
            </td> 
            <xsl:if test="./description">
                <td colspan="7" >Use Description: 
                    <xsl:value-of select="./description"/>
                </td>
            </xsl:if>
        </tr>
        <tr>
            <td rowspan="{$rows -$descriptionCount}">
                <xsl:value-of select="name" />
            </td>
            <td colspan="6" class="ism">
                <xsl:apply-templates select="sampleAttributes/@*[namespace-uri()='&ns-ism;']" />
            </td>
        </tr>
        
        <xsl:call-template name="banner-row" />
   
        <xsl:call-template name="portion-row" />
        
        <xsl:call-template name="authority-row" />
        
    </xsl:template>
    
    <!--***********************************************-->
    <!--Generates a row of HTML to display the Banner test case -->
    <!--***********************************************-->
    <xsl:template name="banner-row">
        <xsl:if test="banner">
            <xsl:call-template name="generate-test-row">
                <xsl:with-param name="test-element" select="banner"/>
            </xsl:call-template>  
        </xsl:if> 
    </xsl:template>
    
    <!--***********************************************-->
    <!-- Generates a row of HTML to display the Portion test case -->
    <!--***********************************************-->
    <xsl:template name="portion-row">
        <xsl:if test="portion">
           <xsl:call-template name="generate-test-row">
               <xsl:with-param name="test-element" select="portion"/>
           </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!--***********************************************-->
    <!-- Generates a row of HTML to display the Classification Authority Block test case -->
    <!--***********************************************-->
    <xsl:template name="authority-row"> 
            <xsl:if test="authority">
                <xsl:call-template name="generate-test-row">
                    <xsl:with-param name="test-element" select="authority"/>
                </xsl:call-template>   
            </xsl:if>    
    </xsl:template>
    
    <!--***********************************************-->
    <!-- Generic template to construct a row displaying test results -->
    <!--***********************************************-->
    <xsl:template name="generate-test-row">
        <xsl:param name="test-element" />
             
        <xsl:variable name="generated-value">
            <xsl:choose>
                <xsl:when test="local-name($test-element)='banner'">
                    <xsl:apply-templates select="$test-element/parent::*/sampleAttributes" mode="ism:banner" />
                </xsl:when>
                <xsl:when test="local-name($test-element)='portion'">
                    <xsl:apply-templates select="$test-element/parent::*/sampleAttributes" mode="ism:portionmark" />
                </xsl:when>
                <xsl:when test="local-name($test-element)=$authority-element">
                    <xsl:apply-templates select="$test-element/parent::*/sampleAttributes" mode="ism:authority" />
                </xsl:when>
                <xsl:otherwise>INVALID TEST ELEMENT: <xsl:value-of select="local-name($test-element)"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="test-isEqual" >
            <xsl:choose>
                <xsl:when test="$generated-value=$test-element">
                    <xsl:value-of select="$pass"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$fail"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="test-result">
            <xsl:choose>
                <xsl:when test="$test-isEqual=$pass or ($test-isEqual=$fail and $test-element/@expectFail='true')">pass</xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="result-fail">
                        <xsl:with-param name="failOnError" select="$failOnError" />
                        <xsl:with-param name="test-element" select="$test-element" />
                        <xsl:with-param name="generated-value" select="$generated-value" />
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
               
        <tr>
            <xsl:attribute name="id"><xsl:value-of select="generate-id($test-element)"/></xsl:attribute>
            <xsl:attribute name="class">
                <!--Add element name as a class attribute, in order to be able to select each row -->
                <xsl:value-of select="local-name($test-element)"/>
                <!-- So that we can achieve alternating row styles... -->
                <xsl:if test="$test-element[count(preceding-sibling::*) mod 2 = 1]">
                    <xsl:text> even </xsl:text>
                </xsl:if>
                <xsl:text>  test-</xsl:text><xsl:value-of select="$test-result" />
               
            </xsl:attribute>
            <td>
                <xsl:call-template name="first-letter-uppercase">
                    <xsl:with-param name="txt" select="local-name($test-element)" />
                </xsl:call-template>
            </td>
            <td>
                <!--Expected value -->
                <xsl:choose>
                    <xsl:when test="local-name($test-element)=$authority-element">
                        <xsl:call-template name="render-authority">
                            <xsl:with-param name="txt" select="$test-element" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="$test-element" /></xsl:otherwise>
                </xsl:choose>      
            </td>
            <td>
               <xsl:choose>
                   <xsl:when test="local-name($test-element)=$authority-element">
                       <xsl:call-template name="render-authority">
                           <xsl:with-param name="txt" select="$generated-value" />
                       </xsl:call-template>
                   </xsl:when>
                   <xsl:otherwise><xsl:value-of select="$generated-value" /></xsl:otherwise>
               </xsl:choose>       
            </td>
            <td>
                <xsl:value-of select="$test-element/@expectFail"/>
            </td>
            <td>
                <xsl:attribute name="class">
                    <xsl:value-of select="$test-isEqual" />
                </xsl:attribute>
                <xsl:value-of select="$test-isEqual" />
            </td>
            <td>
                <xsl:attribute name="class">
                    <xsl:value-of select="$test-result" />
                </xsl:attribute>
                <xsl:value-of select="$test-result" />
            </td>
        </tr>
    </xsl:template>
            
    <!--***********************************************-->
    <!--Generates a rendering of ISM attributes for HTML display -->
    <!--***********************************************-->
    <xsl:template match="@*[namespace-uri()='&ns-ism;']">
        <xsl:value-of select="name()" />="<xsl:value-of select="." />"<br />
    </xsl:template>
    
    <!--***********************************************-->
    <!--Generic template for handling failure conditions -->
    <!--***********************************************-->
    <xsl:template name="result-fail">
        <xsl:param name="failOnError" />
        <xsl:param name="test-element" />
        <xsl:param name="generated-value" />
        
        <xsl:variable name="label">
            <xsl:call-template name="first-letter-uppercase">
                <xsl:with-param name="txt" select="local-name($test-element)" />
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:if test="translate(string($failOnError),$upperCase,$lowerCase)='true'">
            <xsl:message terminate="yes">
                <xsl:value-of select="concat('Invalid ',$label,': ',$generated-value,' expected: ',$test-element)" />
            </xsl:message>
        </xsl:if>
        <xsl:text>fail</xsl:text>
    </xsl:template>

    <!--***********************************************-->
    <!-- Generates a color coded HTML banner -->
    <!--***********************************************-->
    <xsl:template match="ISMTestData" mode="security.banner">
        <xsl:if test="translate(string($showBanner),$upperCase,$lowerCase)='true' or translate(string($showBanner),$upperCase,$lowerCase)='yes'">
            <div>
                <xsl:attribute name="style">text-align:center; 
                    <xsl:call-template name="security-banner-color-attributes">
                        <xsl:with-param name="base-security" select="@ism:classification" />
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:apply-templates select="." mode="ism:banner" />
            </div>
        </xsl:if>
    </xsl:template>
    
    <!--***********************************************-->
    <!-- Generate color attributes based upon overall classification -->
    <!--***********************************************-->
    <xsl:template name="security-banner-color-attributes">
        <xsl:param name="base-security" select="@ism:classification" /><xsl:text>color:</xsl:text>
        <xsl:choose>
            <xsl:when test="$base-security='TS'and @ism:SCIcontrols">
                <xsl:text>black</xsl:text>
            </xsl:when>
            <xsl:when test="$base-security='U' or $base-security='C' or $base-security='S' or $base-security='TS'">
                <xsl:text>white</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>white</xsl:text>
            </xsl:otherwise>
        </xsl:choose>; background-color: <xsl:choose>
            <xsl:when test="$base-security='U'"><xsl:text>green</xsl:text></xsl:when>
            <xsl:when test="$base-security='C'"><xsl:text>blue</xsl:text></xsl:when>
            <xsl:when test="$base-security='S'"><xsl:text>red</xsl:text></xsl:when>
            <xsl:when test="$base-security='TS' and @ism:SCIcontrols"><xsl:text>yellow</xsl:text></xsl:when>
            <xsl:when test="$base-security='TS'"><xsl:text>orange</xsl:text></xsl:when>
            <!--Purple for non-US classifications -->
            <xsl:otherwise><xsl:text>#800080</xsl:text></xsl:otherwise>
        </xsl:choose>; </xsl:template>
        
    <!--***********************************************-->
    <!--Generate a string with the first letter capitalized -->
    <!--***********************************************-->
    <xsl:template name="first-letter-uppercase">
        <xsl:param name="txt"/>      
        <xsl:value-of select="concat( translate( substring( $txt, 1, 1 ),$lowerCase, $upperCase ), substring($txt, 2))" />
    </xsl:template>
    
    <!--***********************************************-->
    <!--Generate a string with the first letter capitalized -->
    <!--***********************************************-->
    <xsl:template name="render-authority">
        <xsl:param name="num" select="0"/>
        <xsl:param name="txt" select="''" />
        <xsl:param name="delimiter"/>
        
        <!--default delimiter value to |, if delimiter param not specified-->
        <xsl:variable name="parse-delimiter">
            <xsl:choose>
                <xsl:when test="not($delimiter) or ($delimiter = '')">
                    <xsl:text>|</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$delimiter"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
            <xsl:choose>
                <xsl:when test="contains($txt, $parse-delimiter)" >
                    <xsl:value-of select="substring-before($txt, $parse-delimiter)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$txt" />
                </xsl:otherwise>
            </xsl:choose>
            <br />
        
        <xsl:variable name="left" select="substring-after($txt, $parse-delimiter)" />
        <xsl:if test="string-length($left)>1" >
            <xsl:call-template name="render-authority" >
                <xsl:with-param name="num" select="$num + 1" />
                <xsl:with-param name="txt" select="$left" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>