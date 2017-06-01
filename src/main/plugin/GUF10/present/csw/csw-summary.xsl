<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
  xmlns:dc ="http://purl.org/dc/elements/1.1/"
  xmlns:dct="http://purl.org/dc/terms/"
  xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
  xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
  xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
  xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
  xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
  xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
  xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
  xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:guf="http://www.opengis.net/guf/1.0/core"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:geonet="http://www.fao.org/geonetwork"
  exclude-result-prefixes="#all">
  
  <xsl:param name="displayInfo"/>
  <xsl:param name="lang"/>
  
  <xsl:include href="../metadata-utils.xsl"/>

  <xsl:template match="guf:GUF_FeedbackItem|*[contains(@gco:isoType,'guf:GUF_FeedbackItem')]">
    
    <xsl:variable name="info" select="geonet:info"/>
    <xsl:variable name="langId">
      <xsl:call-template name="getLangId19115-1-2013">
        <xsl:with-param name="langGui" select="$lang"/>
        <xsl:with-param name="md" select="."/>
      </xsl:call-template>
    </xsl:variable>
    
    <csw:SummaryRecord>
      
      <xsl:for-each select="guf:itemIdentifier">
        <dc:identifier><xsl:value-of select="mcc:MD_Identifier/mcc:code/gco:CharacterString"/></dc:identifier>
      </xsl:for-each>
      
      <!-- Identification -->

      <xsl:for-each select="guf:citation/cit:CI_Citation">
        <xsl:for-each select="cit:title">
          <dc:title>
            <xsl:apply-templates mode="localised" select=".">
              <xsl:with-param name="langId" select="$langId"/>
            </xsl:apply-templates>
          </dc:title>
        </xsl:for-each>
      </xsl:for-each>
        
      <!-- Type -->


      <!-- subject -->
      <xsl:for-each select="guf:descriptiveKeywords/mri:MD_Keywords/mri:keyword[not(@gco:nilReason)]">
        <dc:subject>
          <xsl:apply-templates mode="localised" select=".">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:apply-templates>
        </dc:subject>
      </xsl:for-each>
      <xsl:for-each select="guf:tag">
        <dc:subject>
          <xsl:apply-templates mode="localised" select=".">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:apply-templates>
        </dc:subject>
      </xsl:for-each>

        
      <!-- Target -->
      <xsl:for-each select="guf:target/guf:GUF_FeedbackTarget/guf:resourceRef">
        <dc:relation><xsl:value-of select="cit:CI_Citation/
          cit:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString|@xlink:href"/></dc:relation>
      </xsl:for-each>

        
      <!-- Resource modification date (metadata modification date is in
        mdb:MD_Metadata/mdb:dateInfo  -->
      <xsl:for-each select="guf:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date/*">
        <dct:modified><xsl:value-of select="."/></dct:modified>
      </xsl:for-each>


      <!-- Abstract -->
      <xsl:for-each select="guf:abstract">
        <dct:abstract>
          <xsl:apply-templates mode="localised" select=".">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:apply-templates>
        </dct:abstract>
      </xsl:for-each>

      
      <!-- GeoNetwork elements added when resultType is equal to results_with_summary -->
      <xsl:if test="$displayInfo = 'true'">
        <xsl:copy-of select="$info"/>
      </xsl:if>
      
    </csw:SummaryRecord>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:apply-templates select="*"/>
  </xsl:template>
</xsl:stylesheet>