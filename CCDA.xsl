<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:n1="urn:hl7-org:v3"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:in="urn:lantana-com:inline-variable-data">
  <xsl:output method="html" indent="yes" version="4.01" encoding="ISO-8859-1" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"/>

  <!--Incoming Parameters-->
  <xsl:param name="printPDF"/>

  <!-- CDA document -->
  <xsl:param name="limit-external-images" select="'yes'"/>
  <!-- A vertical bar separated list of URI prefixes, such as "http://www.example.com|https://www.example.com" -->
  <xsl:param name="external-image-whitelist"/>
  <xsl:variable name="tableWidth">50%</xsl:variable>
  <!-- string processing variables -->
  <xsl:variable name="lc" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
  <!-- removes the following characters, in addition to line breaks "':;?`{}“”„‚’ -->
  <xsl:variable name="simple-sanitizer-match">
    <xsl:text>&#10;&#13;&#34;&#39;&#58;&#59;&#63;&#96;&#123;&#125;&#8220;&#8221;&#8222;&#8218;&#8217;</xsl:text>
  </xsl:variable>
  <xsl:variable name="simple-sanitizer-replace" select="'***************'"/>
  <xsl:variable name="javascript-injection-warning">WARNING: Javascript injection attempt detected in source CDA document. Terminating</xsl:variable>
  <xsl:variable name="malicious-content-warning">WARNING: Potentially malicious content found in CDA document.</xsl:variable>

  <xsl:variable name="title">
    <xsl:choose>
      <xsl:when test="/n1:ClinicalDocument/n1:title">
        <xsl:value-of select="/n1:ClinicalDocument/n1:title"/>
      </xsl:when>
      <xsl:otherwise>Patient Clinical Summary For Encounter Date: "</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:template match="/">
    <xsl:apply-templates select="n1:ClinicalDocument"/>
  </xsl:template>
  <xsl:template match="n1:ClinicalDocument">
    <html xml:lang="en" lang="en">
      <head>
        <xsl:comment> Do NOT edit this HTML directly: it was generated via an XSLT transformation from a CDA Release 2 XML document. </xsl:comment>
        <title>
          <xsl:value-of select="$title"/>
        </title>
        <xsl:call-template name="addCSS"/>
      </head>
      <body>
        <h2 align="center">
          <xsl:value-of select="$title"/>
          <xsl:call-template name="componentOfDate">
            <xsl:with-param name="title" select="$title"/>
          </xsl:call-template>
        </h2>
        <xsl:if test="/n1:ClinicalDocument/n1:recordTarget/n1:patientRole">
          <hr/>
          <table width='100%'>
            <xsl:variable name="patientRole" select="/n1:ClinicalDocument/n1:recordTarget/n1:patientRole"/>
            <tr>
              <td width='20%' valign="top" rowspan="4" class="header-cell">
                <b>
                  <xsl:text>Patient </xsl:text>
                </b>
              </td>
              <td width='25%' valign="top" rowspan="4">
                <xsl:call-template name="show-name">
                  <xsl:with-param name="name" select="$patientRole/n1:patient/n1:name"/>
                </xsl:call-template>
                - <xsl:value-of select="$patientRole/n1:patient/n1:administrativeGenderCode/@displayName"/>
                <xsl:if test="$patientRole/n1:addr">
                  <br />
                  <xsl:call-template name="getAddress">
                    <xsl:with-param name="addr" select="$patientRole/n1:addr"/>
                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$patientRole/n1:telecom">
                  <xsl:call-template name="getTelecom">
                    <xsl:with-param name="telecom" select="$patientRole/n1:telecom"/>
                  </xsl:call-template>
                </xsl:if>
              </td>
              <td width='8%'  valign="top" class="header-cell">
                <b>
                  <xsl:text>Birthdate </xsl:text>
                </b>
              </td>
              <td width='15%' valign="top">
                <xsl:call-template name="show-date">
                  <xsl:with-param name="date" select="$patientRole/n1:patient/n1:birthTime/@value"/>
                </xsl:call-template>
              </td>
              <td valign="top" class="header-cell" width="8%">
                <b>
                  <xsl:text>Race </xsl:text>
                </b>
              </td>
              <td valign="top">
                <xsl:value-of select="$patientRole/n1:patient/n1:raceCode/@displayName"/>
              </td>
            </tr>
            <tr>
              <td valign="top" class="header-cell">
                <b>
                  <xsl:text>Ethnicity </xsl:text>
                </b>
              </td>
              <td valign="top">
                <xsl:value-of select="$patientRole/n1:patient/n1:ethnicGroupCode/@displayName"/>
              </td>
              <td valign="top" class="header-cell">
                <b>
                  <xsl:text>Language </xsl:text>
                </b>
              </td>
              <td valign="top">
                <xsl:value-of select="$patientRole/n1:patient/n1:languageCommunication/n1:languageCode/@code"/>
              </td>
            </tr>
          </table>
          <hr/>
          <table width='100%'>
            <xsl:variable name="assignedEntity" select="/n1:ClinicalDocument/n1:documentationOf/n1:serviceEvent/n1:performer[1]/n1:assignedEntity"/>
            <tr>
              <td width='20%' valign="top" class="header-cell">
                <b>
                  <xsl:text>Primary Care Provider </xsl:text>
                </b>
              </td>
              <td width='25%' valign="top">
                <xsl:call-template name="show-name">
                  <xsl:with-param name="name" select="$assignedEntity/n1:assignedPerson/n1:name"/>
                </xsl:call-template>
              </td>

              <td valign="top" width="8%" class="header-cell">
                <b>
                  <xsl:text>Office </xsl:text>
                </b>
              </td>
              <td>
                <xsl:if test="$assignedEntity/n1:addr">
                  <xsl:call-template name="getAddress">
                    <xsl:with-param name="addr" select="$assignedEntity/n1:addr"/>
                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$assignedEntity/n1:telecom">
                  <xsl:call-template name="getTelecom">
                    <xsl:with-param name="telecom" select="$assignedEntity/n1:telecom"/>
                  </xsl:call-template>
                </xsl:if>
              </td>
            </tr>
          </table>
          <xsl:call-template name="care-team"/>
          <hr id="tocSeparator"/>
          <!-- produce table of contents -->
          <xsl:if test="not(//n1:nonXMLBody)">
            <xsl:if test="count(/n1:ClinicalDocument/n1:component/n1:structuredBody/n1:component[n1:section]) &gt; 1">
              <xsl:call-template name="make-tableofcontents"/>
            </xsl:if>
          </xsl:if>
          <hr/>
        </xsl:if>

        <xsl:apply-templates select="n1:component/n1:structuredBody|n1:component/n1:nonXMLBody"/>
        <xsl:call-template name="bottomline"/>
      </body>
    </html>
  </xsl:template>

  <!-- informant -->
  <xsl:template name="informant">
    <xsl:if test="n1:informant">
      <hr/>
      <h3>Care Team</h3>
      <table width='100%'>
        <tbody>
          <xsl:for-each select="n1:informant">
            <xsl:choose>
              <xsl:when test="n1:assignedEntity/n1:addr | n1:assignedEntity/n1:telecom">
                <tr>
                  <td width='15%' valign="top" class="header-cell">
                    <b>
                      <xsl:text>Provider </xsl:text>
                    </b>
                  </td>
                  <td width='20%' valign="top">
                    <xsl:if test="n1:assignedEntity">
                      <xsl:call-template name="show-name">
                        <xsl:with-param name="name" select="n1:assignedEntity/n1:assignedPerson/n1:name"/>
                      </xsl:call-template>
                    </xsl:if>
                  </td>
                  <td width='8%' valign="top" class="header-cell">
                    <b>
                      <xsl:text>Office </xsl:text>
                    </b>
                  </td>
                  <td width='55%' valign="top">
                    <xsl:if test="n1:assignedEntity/n1:addr">
                      <xsl:call-template name="show-address">
                        <xsl:with-param name="address" select="n1:assignedEntity/n1:addr"/>
                      </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="n1:assignedEntity/n1:telecom">
                      <xsl:call-template name="show-telecom">
                        <xsl:with-param name="telecom" select="n1:assignedEntity/n1:telecom"/>
                      </xsl:call-template>
                    </xsl:if>
                  </td>
                </tr>
              </xsl:when>
              <xsl:when test="n1:relatedEntity/n1:addr | n1:relatedEntity/n1:telecom">
                <tr>
                  <td width='15%' valign="top" class="header-cell">
                    <b>
                      <xsl:text>Referring Provider </xsl:text>
                    </b>
                  </td>
                  <td width='30%' valign="top">
                    <xsl:if test="n1:relatedEntity">
                      <xsl:call-template name="show-name">
                        <xsl:with-param name="name" select="n1:relatedEntity/n1:assignedPerson/n1:name"/>
                      </xsl:call-template>
                    </xsl:if>
                  </td>
                  <td width='8%' valign="top" class="header-cell">
                    <b>
                      <xsl:text>Office </xsl:text>
                    </b>
                  </td>
                  <td width='35%' valign="top">
                    <xsl:if test="n1:relatedEntity/n1:addr">
                      <xsl:call-template name="show-address">
                        <xsl:with-param name="address" select="n1:relatedEntity/n1:addr"/>
                      </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="n1:relatedEntity/n1:telecom">
                      <xsl:call-template name="show-telecom">
                        <xsl:with-param name="telecom" select="n1:relatedEntity/n1:telecom"/>
                      </xsl:call-template>
                    </xsl:if>
                  </td>
                </tr>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </tbody>
      </table>
    </xsl:if>
  </xsl:template>
  <!-- care team -->
  <xsl:template name="care-team">
    <xsl:if test="n1:documentationOf/n1:serviceEvent/n1:performer">
      <hr/>
      <table width='100%'>
        <tbody>
          <xsl:for-each select="n1:documentationOf/n1:serviceEvent/n1:performer">
            <tr>
              <td width="10%">
                <h3 style="margin:0;">Care Team</h3>
              </td>
              <td width='10%' class="header-cell" valign="top" >
                <xsl:choose>
                  <xsl:when test="n1:functionCode/@code='CP'">
                    <b>
                      <xsl:text>Provider </xsl:text>
                    </b>
                  </xsl:when>
                  <xsl:when test="n1:functionCode/@code='PCP'">
                    <b>
                      <xsl:text>Provider </xsl:text>
                    </b>
                  </xsl:when>
                  <xsl:when test="n1:functionCode/@code='RP'">
                    <b>
                      <xsl:text>Referral Provider </xsl:text>
                    </b>
                  </xsl:when>
                  <xsl:otherwise>
                    <b>
                      <xsl:text>Medical Staff </xsl:text>
                    </b>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              <td width='25%' valign="top" >
                <xsl:if test="n1:assignedEntity">
                  <xsl:call-template name="show-name">
                    <xsl:with-param name="name" select="n1:assignedEntity/n1:assignedPerson/n1:name"/>
                  </xsl:call-template>
                </xsl:if>
              </td>
              <td width='8%' class="header-cell" valign="top" >
                <b>
                  <xsl:text>Office </xsl:text>
                </b>
              </td>
              <td width='50%' valign="top" >
                <xsl:if test="n1:assignedEntity/n1:addr">
                  <xsl:call-template name="show-address">
                    <xsl:with-param name="address" select="n1:assignedEntity/n1:addr"/>
                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="n1:assignedEntity/n1:telecom">
                  <xsl:call-template name="show-telecom">
                    <xsl:with-param name="telecom" select="n1:assignedEntity/n1:telecom"/>
                  </xsl:call-template>
                </xsl:if>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </xsl:if>
  </xsl:template>
  <!-- generate table of contents -->
  <xsl:template name="make-tableofcontents">
    <div id="tableofcontents">
      <h3 style="margin:0;">
        <a name="toc">Table of Contents</a>
      </h3>
      <ul>
        <xsl:for-each select="n1:component/n1:structuredBody/n1:component/n1:section">
          <xsl:if test="string-length(n1:text)>0">
            <li>
              <a href="#{generate-id(n1:title)}">
                <xsl:value-of select="n1:title"/>
              </a>
            </li>
          </xsl:if>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>
  <xsl:template name="componentOfDate">
    <xsl:param name="title"/>
    <xsl:if test="not($title = 'Patient Clinical Summary For All Encounters')">
      <xsl:if test="n1:componentOf">
        <xsl:variable name="encompassingEncounter" select="n1:componentOf/n1:encompassingEncounter"/>
        <xsl:if test="$encompassingEncounter/n1:effectiveTime">
          <xsl:choose>
            <xsl:when test="$encompassingEncounter/n1:effectiveTime/@value">
              <xsl:call-template name="show-time">
                <xsl:with-param name="datetime" select="$encompassingEncounter/n1:effectiveTime"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$encompassingEncounter/n1:effectiveTime/n1:low">
              <xsl:call-template name="show-time">
                <xsl:with-param name="datetime" select="$encompassingEncounter/n1:effectiveTime/n1:low"/>
              </xsl:call-template>
              <xsl:if test="$encompassingEncounter/n1:effectiveTime/n1:high">
                <xsl:text> to </xsl:text>
                <xsl:call-template name="show-time">
                  <xsl:with-param name="datetime" select="$encompassingEncounter/n1:effectiveTime/n1:high"/>
                </xsl:call-template>
              </xsl:if>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <xsl:template name="componentOfType">
    <xsl:if test="n1:componentOf">
      <xsl:variable name="encompassingEncounter" select="n1:componentOf/n1:encompassingEncounter"/>
      <xsl:if test="$encompassingEncounter/n1:id">
        <xsl:choose>
          <xsl:when test="$encompassingEncounter/n1:code">
            <xsl:call-template name="show-code">
              <xsl:with-param name="code" select="$encompassingEncounter/n1:code"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getParticipant">
    <xsl:param name="participant"/>
    <p>
      <xsl:call-template name="show-name">
        <xsl:with-param name="name"
        select="$participant/n1:associatedPerson/n1:name"/>
      </xsl:call-template>
      <xsl:if test="$participant/n1:addr">
        <xsl:call-template name="getAddress">
          <xsl:with-param name="addr" select="$participant/n1:addr"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$participant/n1:telecom">
        <xsl:call-template name="getTelecom">
          <xsl:with-param name="telecom"
             select="$participant/n1:telecom"/>
        </xsl:call-template>
      </xsl:if>
    </p>
  </xsl:template>

  <xsl:template name="getAddress">
    <xsl:param name="addr"/>
    <xsl:choose>
      <xsl:when test="$addr">
        <xsl:for-each select="$addr/n1:streetAddressLine">
          <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:if test="string-length($addr/n1:city)>0">
          <xsl:value-of select="$addr/n1:city"/>
        </xsl:if>
        <xsl:if test="string-length($addr/n1:state)>0">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$addr/n1:state"/>
        </xsl:if>
        <xsl:if test="string-length($addr/n1:postalCode)>0">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$addr/n1:postalCode"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>--</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getTelecom">
    <xsl:param name="telecom"/>;
    <xsl:value-of select="$telecom/@value"/>
  </xsl:template>

  <!-- show-name  -->
  <xsl:template name="show-name">
    <xsl:param name="name"/>
    <xsl:choose>
      <xsl:when test="$name/n1:family">
        <xsl:if test="$name/n1:prefix">
          <xsl:value-of select="$name/n1:prefix"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="$name/n1:given"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$name/n1:family"/>
        <xsl:if test="$name/n1:suffix">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$name/n1:suffix"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- show-address -->
  <xsl:template name="show-address">
    <xsl:param name="address"/>
    <xsl:choose>
      <xsl:when test="$address">
        <xsl:for-each select="$address/n1:streetAddressLine">
          <xsl:value-of select="."/>
          <xsl:text> </xsl:text>
        </xsl:for-each>
        <xsl:if test="string-length($address/n1:city)>0">
          <xsl:value-of select="$address/n1:city"/>
        </xsl:if>
        <xsl:if test="string-length($address/n1:state)>0">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$address/n1:state"/>
        </xsl:if>
        <xsl:if test="string-length($address/n1:postalCode)>0">
          <xsl:text> </xsl:text>
          <xsl:value-of select="$address/n1:postalCode"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>--</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- show-telecom -->
  <xsl:template name="show-telecom">
    <xsl:param name="telecom"/>
    <xsl:if test="string-length($telecom/@value)>0">
      <xsl:text>; </xsl:text>
      <xsl:value-of select="$telecom/@value"/>
    </xsl:if>
  </xsl:template>
  <!-- show time -->
  <xsl:template name="show-time">
    <xsl:param name="datetime"/>
    <xsl:choose>
      <xsl:when test="not($datetime)">
        <xsl:call-template name="show-date">
          <xsl:with-param name="date" select="@value"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="show-date">
          <xsl:with-param name="date" select="$datetime/@value"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- show code -->
  <xsl:template name="show-code">
    <xsl:param name="code"/>
    <xsl:variable name="this-codeSystem">
      <xsl:value-of select="$code/@codeSystem"/>
    </xsl:variable>
    <xsl:variable name="this-code">
      <xsl:value-of select="$code/@code"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$code/n1:originalText">
        <xsl:value-of select="$code/n1:originalText"/>
      </xsl:when>
      <xsl:when test="$code/@displayName">
        <xsl:value-of select="$code/@displayName"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$this-code"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--  Format Date 
    
          outputs a date in Month Day, Year form
          e.g., 19991207  ==> December 07, 1999
    -->
  <xsl:template name="formatDate">
    <xsl:param name="date"/>
    <xsl:variable name="month" select="substring ($date, 5, 2)"/>
    <xsl:choose>
      <xsl:when test="$month='01'">
        <xsl:text>January </xsl:text>
      </xsl:when>
      <xsl:when test="$month='02'">
        <xsl:text>February </xsl:text>
      </xsl:when>
      <xsl:when test="$month='03'">
        <xsl:text>March </xsl:text>
      </xsl:when>
      <xsl:when test="$month='04'">
        <xsl:text>April </xsl:text>
      </xsl:when>
      <xsl:when test="$month='05'">
        <xsl:text>May </xsl:text>
      </xsl:when>
      <xsl:when test="$month='06'">
        <xsl:text>June </xsl:text>
      </xsl:when>
      <xsl:when test="$month='07'">
        <xsl:text>July </xsl:text>
      </xsl:when>
      <xsl:when test="$month='08'">
        <xsl:text>August </xsl:text>
      </xsl:when>
      <xsl:when test="$month='09'">
        <xsl:text>September </xsl:text>
      </xsl:when>
      <xsl:when test="$month='10'">
        <xsl:text>October </xsl:text>
      </xsl:when>
      <xsl:when test="$month='11'">
        <xsl:text>November </xsl:text>
      </xsl:when>
      <xsl:when test="$month='12'">
        <xsl:text>December </xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test='substring ($date, 7, 1)="0"'>
        <xsl:value-of select="substring ($date, 8, 1)"/>
        <xsl:text>, </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring ($date, 7, 2)"/>
        <xsl:text>, </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="substring ($date, 1, 4)"/>
  </xsl:template>

  <xsl:template name="show-date">
    <xsl:param name="date"/>
    <!-- output format mm/dd/yyyy -->
    <xsl:value-of select="substring ($date, 5, 2)"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="substring ($date, 7, 2)"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="substring ($date, 1, 4)"/>
  </xsl:template>

  <!-- show StructuredBody  -->
  <xsl:template match="n1:component/n1:structuredBody">
    <xsl:apply-templates select="n1:component/n1:section"/>
  </xsl:template>

  <!-- Component/Section -->
  <xsl:template match="n1:component/n1:section">
    <xsl:if test="string-length(n1:text)>0">
      <xsl:variable name="tbodytd" select="n1:text/n1:table/n1:tbody/n1:tr/n1:td/text()" />
      <xsl:if test="not(contains($tbodytd, 'No Data Available'))">
        <xsl:apply-templates select="n1:title"/>
        <xsl:apply-templates select="n1:text"/>
        <xsl:apply-templates select="n1:component/n1:section"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!--   Title  -->
  <xsl:template match="n1:title">
    <span style="margin:7px;visibility:hidden;">
      <a name="{generate-id(.)}" href="#toc">
        <xsl:value-of select="."/>
      </a>
    </span>
  </xsl:template>

  <!--   Text   -->
  <xsl:template match="n1:text">
    <xsl:apply-templates />
  </xsl:template>

  <!--   paragraph  -->
  <xsl:template match="n1:paragraph">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <!--     Content w/ deleted text is hidden -->
  <xsl:template match="n1:content[@revised='delete']"/>

  <!--   content  -->
  <xsl:template match="n1:content">
    <xsl:apply-templates/>
  </xsl:template>

  <!--   list  -->
  <xsl:template match="n1:list">
    <xsl:if test="n1:caption">
      <span style="font-weight:bold; ">
        <xsl:apply-templates select="n1:caption"/>
      </span>
    </xsl:if>
    <ul>
      <xsl:for-each select="n1:item">
        <li>
          <xsl:apply-templates />
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="n1:list[@listType='ordered']">
    <xsl:if test="n1:caption">
      <span style="font-weight:bold; ">
        <xsl:apply-templates select="n1:caption"/>
      </span>
    </xsl:if>
    <ol>
      <xsl:for-each select="n1:item">
        <li>
          <xsl:apply-templates />
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>

  <!--   caption  -->
  <xsl:template match="n1:caption">
    <xsl:apply-templates/>
    <xsl:text>: </xsl:text>
  </xsl:template>

  <!--      Tables   -->
  <xsl:template match="n1:table/@*|n1:thead/@*|n1:tfoot/@*|n1:tbody/@*|n1:colgroup/@*|n1:col/@*|n1:tr/@*|n1:th/@*|n1:td/@*">
    <xsl:copy>
      <xsl:call-template name="output-attrs"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="n1:table">
    <table class="ccda">
      <xsl:call-template name="output-attrs"/>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match="n1:thead">
    <thead>
      <xsl:call-template name="output-attrs"/>
      <xsl:apply-templates/>
    </thead>
  </xsl:template>

  <xsl:template match="n1:tfoot">
    <tfoot>
      <xsl:call-template name="output-attrs"/>
      <xsl:apply-templates/>
    </tfoot>
  </xsl:template>

  <xsl:template match="n1:tbody">
    <tbody>
      <xsl:call-template name="output-attrs"/>
      <xsl:apply-templates/>
    </tbody>
  </xsl:template>

  <xsl:template match="n1:colgroup">
    <colgroup>
      <xsl:call-template name="output-attrs"/>
      <xsl:apply-templates/>
    </colgroup>
  </xsl:template>

  <xsl:template match="n1:col">
    <col>
      <xsl:call-template name="output-attrs"/>
      <xsl:apply-templates/>
    </col>
  </xsl:template>

  <xsl:template match="n1:tr">
    <tr>
      <xsl:call-template name="output-attrs"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>

  <xsl:template match="n1:th">
    <th>
      <xsl:call-template name="output-attrs"/>
      <xsl:apply-templates/>
    </th>
  </xsl:template>

  <xsl:template match="n1:td">
    <xsl:choose>
      <xsl:when test="string-length(.)>0">
        <td>
          <xsl:call-template name="output-attrs"/>
          <xsl:apply-templates/>
        </td>
      </xsl:when>
      <xsl:otherwise>
        <td>
          <xsl:text disable-output-escaping="yes">&amp;#160;</xsl:text>
        </td>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="n1:table/n1:caption">
    <span style="font-weight:bold; ">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!--   RenderMultiMedia 

         this currently only handles GIF's and JPEG's.  It could, however,
	 be extended by including other image MIME types in the predicate
	 and/or by generating <object> or <applet> tag with the correct
	 params depending on the media type  @ID  =$imageRef     referencedObject
    -->
  <xsl:template match="n1:renderMultiMedia">
    <xsl:variable name="imageRef" select="@referencedObject"/>
    <xsl:choose>
      <xsl:when test="//n1:regionOfInterest[@ID=$imageRef]">
        <!-- Here is where the Region of Interest image referencing goes -->
        <xsl:if test="//n1:regionOfInterest[@ID=$imageRef]//n1:observationMedia/n1:value[@mediaType='image/gif' or
 @mediaType='image/jpeg']">
          <xsl:variable name="image-uri" select="//n1:regionOfInterest[@ID=$imageRef]//n1:observationMedia/n1:value/n1:reference/@value"/>

          <xsl:choose>
            <xsl:when test="$limit-external-images='yes' and (contains($image-uri,':') or starts-with($image-uri,'\\'))">
              <xsl:call-template name="check-external-image-whitelist">
                <xsl:with-param name="current-whitelist" select="$external-image-whitelist"/>
                <xsl:with-param name="image-uri" select="$image-uri"/>
              </xsl:call-template>
              <!--
                            <p>WARNING: non-local image found <xsl:value-of select="$image-uri"/>. Removing. If you wish non-local images preserved please set the limit-external-images param to 'no'.</p>
                            <xsl:message>WARNING: non-local image found <xsl:value-of select="$image-uri"/>. Removing. If you wish non-local images preserved please set the limit-external-images param to 'no'.</xsl:message>
                            -->
            </xsl:when>
            <!--
                        <xsl:when test="$limit-external-images='yes' and starts-with($image-uri,'\\')">
                            <p>WARNING: non-local image found <xsl:value-of select="$image-uri"/></p>
                            <xsl:message>WARNING: non-local image found <xsl:value-of select="$image-uri"/>. Removing. If you wish non-local images preserved please set the limit-external-images param to 'no'.</xsl:message>
                        </xsl:when>
                        -->
            <xsl:otherwise>
              <br clear="all"/>
              <xsl:element name="img">
                <xsl:attribute name="src">
                  <xsl:value-of select="$image-uri"/>
                </xsl:attribute>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <!-- Here is where the direct MultiMedia image referencing goes -->
        <xsl:if test="//n1:observationMedia[@ID=$imageRef]/n1:value[@mediaType='image/gif' or @mediaType='image/jpeg']">
          <br clear="all"/>
          <xsl:element name="img">
            <xsl:attribute name="src">
              <xsl:value-of select="//n1:observationMedia[@ID=$imageRef]/n1:value/n1:reference/@value"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 	Stylecode processing   
	  Supports Bold, Underline and Italics display

    -->

  <xsl:template match="//n1:*[@styleCode]">

    <xsl:if test="@styleCode='Bold'">
      <xsl:element name='b'>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:if>

    <xsl:if test="@styleCode='Italics'">
      <xsl:element name='i'>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:if>

    <xsl:if test="@styleCode='Underline'">
      <xsl:element name='u'>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:if>

    <xsl:if test="contains(@styleCode,'Bold') and contains(@styleCode,'Italics') and not (contains(@styleCode, 'Underline'))">
      <xsl:element name='b'>
        <xsl:element name='i'>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:element>
    </xsl:if>

    <xsl:if test="contains(@styleCode,'Bold') and contains(@styleCode,'Underline') and not (contains(@styleCode, 'Italics'))">
      <xsl:element name='b'>
        <xsl:element name='u'>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:element>
    </xsl:if>

    <xsl:if test="contains(@styleCode,'Italics') and contains(@styleCode,'Underline') and not (contains(@styleCode, 'Bold'))">
      <xsl:element name='i'>
        <xsl:element name='u'>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:element>
    </xsl:if>

    <xsl:if test="contains(@styleCode,'Italics') and contains(@styleCode,'Underline') and contains(@styleCode, 'Bold')">
      <xsl:element name='b'>
        <xsl:element name='i'>
          <xsl:element name='u'>
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:if>

  </xsl:template>

  <!-- 	Superscript or Subscript   -->
  <xsl:template match="n1:sup">
    <xsl:element name='sup'>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="n1:sub">
    <xsl:element name='sub'>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!--  Bottomline  -->
  <xsl:template name="bottomline">
    <p>
      <b>
        <xsl:text>Electronically generated </xsl:text>
      </b>
      <xsl:if test="/n1:ClinicalDocument/n1:author/n1:assignedAuthor/n1:assignedPerson">
        <b> by: </b>
        <xsl:call-template name="show-name">
          <xsl:with-param name="name" select="/n1:ClinicalDocument/n1:author/n1:assignedAuthor/n1:assignedPerson/n1:name"/>
        </xsl:call-template>
      </xsl:if>

      <xsl:text> on </xsl:text>
      <xsl:call-template name="show-date">
        <xsl:with-param name="date" select="//n1:ClinicalDocument/n1:effectiveTime/@value"/>
      </xsl:call-template>
    </p>
  </xsl:template>
  <xsl:template name="addCSS">
    <style type="text/css">
      <xsl:text>
                body {font-size: 10px; font-family: arial,helvetica,sans-serif;}
                body, hr, a {color: #3E3E3E;}
                h2 {font-size: 10pt; font-weight: bold;}
                h3 {font-size: 9pt; font-weight: bold;}
                table {line-height: 10pt; font-size: 8pt; font-family: arial,helvetica,sans-serif;}
                hr {border-color: #7B7B7E;border-style: solid;border-width: 1px 0 0;clear: both;margin: 0 0 0px;height: 0;}
                .header-cell {border-right: solid 1px #7B7B7E; padding-right:5px; text-align:right;}
                .ccda, .ccda thead th, .ccda td {border-color: #7B7B7E; border-style: solid; color: #515967;}
                .ccda {border-collapse: separate; border-spacing: 0; border-width: 0 1px 0 0; empty-cells: show; outline: 0 none; width: 100%; margin-bottom:2px;}
                .ccda thead {background-color: #F3F3F4;}
                .ccda thead th{border-width: 1px 0 1px 1px; text-align: left;}
                .ccda td{border-width: 0 0 1px 1px; overflow: hidden; text-overflow: ellipsis; vertical-align: middle;}
            </xsl:text>

      <xsl:choose>
        <xsl:when test="$printPDF='1'">
          <xsl:text>
                #tableofcontents{display:none;}
				        table {font-size: 6pt;}  
                #tocSeparator {display:none;}
              </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>
                @media print {
					        #tableofcontents{display:none;}
					        table {font-size: 6pt;}}
              </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </style>
  </xsl:template>

  <!-- show nonXMLBody -->
  <xsl:template match='n1:component/n1:nonXMLBody'>
    <xsl:choose>
      <!-- if there is a reference, use that in an IFRAME -->
      <xsl:when test='n1:text/n1:reference'>
        <xsl:variable name="source" select="string(n1:text/n1:reference/@value)"/>
        <xsl:variable name="lcSource" select="translate($source, $uc, $lc)"/>
        <xsl:variable name="scrubbedSource" select="translate($source, $simple-sanitizer-match, $simple-sanitizer-replace)"/>
        <xsl:message>
          <xsl:value-of select="$source"/>, <xsl:value-of select="$lcSource"/>
        </xsl:message>
        <xsl:choose>
          <xsl:when test="contains($lcSource,'javascript')">
            <p>
              <xsl:value-of select="$javascript-injection-warning"/>
            </p>
            <xsl:message>
              <xsl:value-of select="$javascript-injection-warning"/>
            </xsl:message>
          </xsl:when>
          <xsl:when test="not($source = $scrubbedSource)">
            <p>
              <xsl:value-of select="$malicious-content-warning"/>
            </p>
            <xsl:message>
              <xsl:value-of select="$malicious-content-warning"/>
            </xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <iframe name='nonXMLBody' id='nonXMLBody' WIDTH='80%' HEIGHT='600' src='{$source}' sandbox=""/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test='n1:text/@mediaType="text/plain"'>
        <pre>
          <xsl:value-of select='n1:text/text()'/>
        </pre>
      </xsl:when>
      <xsl:otherwise>
        <pre>Cannot display the text</pre>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:variable name="table-elem-attrs">
    <in:tableElems>
      <in:elem name="table">
        <in:attr name="ID"/>
        <in:attr name="language"/>
        <in:attr name="styleCode"/>
        <in:attr name="summary"/>
        <in:attr name="width"/>
        <in:attr name="border"/>
        <in:attr name="frame"/>
        <in:attr name="rules"/>
        <in:attr name="cellspacing"/>
        <in:attr name="cellpadding"/>
      </in:elem>
      <in:elem name="thead">
        <in:attr name="ID"/>
        <in:attr name="language"/>
        <in:attr name="styleCode"/>
        <in:attr name="align"/>
        <in:attr name="char"/>
        <in:attr name="charoff"/>
        <in:attr name="valign"/>
      </in:elem>
      <in:elem name="tfoot">
        <in:attr name="ID"/>
        <in:attr name="language"/>
        <in:attr name="styleCode"/>
        <in:attr name="align"/>
        <in:attr name="char"/>
        <in:attr name="charoff"/>
        <in:attr name="valign"/>
      </in:elem>
      <in:elem name="tbody">
        <in:attr name="ID"/>
        <in:attr name="language"/>
        <in:attr name="styleCode"/>
        <in:attr name="align"/>
        <in:attr name="char"/>
        <in:attr name="charoff"/>
        <in:attr name="valign"/>
      </in:elem>
      <in:elem name="colgroup">
        <in:attr name="ID"/>
        <in:attr name="language"/>
        <in:attr name="styleCode"/>
        <in:attr name="span"/>
        <in:attr name="width"/>
        <in:attr name="align"/>
        <in:attr name="char"/>
        <in:attr name="charoff"/>
        <in:attr name="valign"/>
      </in:elem>
      <in:elem name="col">
        <in:attr name="ID"/>
        <in:attr name="language"/>
        <in:attr name="styleCode"/>
        <in:attr name="span"/>
        <in:attr name="width"/>
        <in:attr name="align"/>
        <in:attr name="char"/>
        <in:attr name="charoff"/>
        <in:attr name="valign"/>
      </in:elem>
      <in:elem name="tr">
        <in:attr name="ID"/>
        <in:attr name="language"/>
        <in:attr name="styleCode"/>
        <in:attr name="align"/>
        <in:attr name="char"/>
        <in:attr name="charoff"/>
        <in:attr name="valign"/>
      </in:elem>
      <in:elem name="th">
        <in:attr name="ID"/>
        <in:attr name="language"/>
        <in:attr name="styleCode"/>
        <in:attr name="abbr"/>
        <in:attr name="axis"/>
        <in:attr name="headers"/>
        <in:attr name="scope"/>
        <in:attr name="rowspan"/>
        <in:attr name="colspan"/>
        <in:attr name="align"/>
        <in:attr name="char"/>
        <in:attr name="charoff"/>
        <in:attr name="valign"/>
      </in:elem>
      <in:elem name="td">
        <in:attr name="ID"/>
        <in:attr name="language"/>
        <in:attr name="styleCode"/>
        <in:attr name="abbr"/>
        <in:attr name="axis"/>
        <in:attr name="headers"/>
        <in:attr name="scope"/>
        <in:attr name="rowspan"/>
        <in:attr name="colspan"/>
        <in:attr name="align"/>
        <in:attr name="char"/>
        <in:attr name="charoff"/>
        <in:attr name="valign"/>
      </in:elem>
    </in:tableElems>
  </xsl:variable>

  <xsl:template name="output-attrs">
    <xsl:variable name="elem-name" select="local-name(.)"/>
    <xsl:for-each select="@*">
      <xsl:variable name="attr-name" select="local-name(.)"/>
      <xsl:variable name="source" select="."/>
      <xsl:variable name="lcSource" select="translate($source, $uc, $lc)"/>
      <xsl:variable name="scrubbedSource" select="translate($source, $simple-sanitizer-match, $simple-sanitizer-replace)"/>
      <xsl:choose>
        <xsl:when test="contains($lcSource,'javascript')">
          <p>
            <xsl:value-of select="$javascript-injection-warning"/>
          </p>
          <xsl:message terminate="yes">
            <xsl:value-of select="$javascript-injection-warning"/>
          </xsl:message>
        </xsl:when>
        <xsl:when test="$attr-name='styleCode'">
          <xsl:apply-templates select="."/>
        </xsl:when>
        <xsl:when test="not(document('')/xsl:stylesheet/xsl:variable[@name='table-elem-attrs']/in:tableElems/in:elem[@name=$elem-name]/in:attr[@name=$attr-name])">
          <xsl:message>
            <xsl:value-of select="$attr-name"/> is not legal in <xsl:value-of select="$elem-name"/>
          </xsl:message>
        </xsl:when>
        <xsl:when test="not($source = $scrubbedSource)">
          <p>
            <xsl:value-of select="$malicious-content-warning"/>
          </p>
          <xsl:message>
            <xsl:value-of select="$malicious-content-warning"/>
          </xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="check-external-image-whitelist">
    <xsl:param name="current-whitelist"/>
    <xsl:param name="image-uri"/>
    <xsl:choose>
      <xsl:when test="string-length($current-whitelist) &gt; 0">
        <xsl:variable name="whitelist-item">
          <xsl:choose>
            <xsl:when test="contains($current-whitelist,'|')">
              <xsl:value-of select="substring-before($current-whitelist,'|')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$current-whitelist"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="starts-with($image-uri,$whitelist-item)">
            <br clear="all"/>
            <xsl:element name="img">
              <xsl:attribute name="src">
                <xsl:value-of select="$image-uri"/>
              </xsl:attribute>
            </xsl:element>
            <xsl:message>
              <xsl:value-of select="$image-uri"/> is in the whitelist
            </xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="check-external-image-whitelist">
              <xsl:with-param name="current-whitelist" select="substring-after($current-whitelist,'|')"/>
              <xsl:with-param name="image-uri" select="$image-uri"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:when>
      <xsl:otherwise>
        <p>
          WARNING: non-local image found <xsl:value-of select="$image-uri"/>. Removing. If you wish non-local images preserved please set the limit-external-images param to 'no'.
        </p>
        <xsl:message>
          WARNING: non-local image found <xsl:value-of select="$image-uri"/>. Removing. If you wish non-local images preserved please set the limit-external-images param to 'no'.
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>