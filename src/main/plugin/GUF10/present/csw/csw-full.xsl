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
  xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
  xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/1.0"
  xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:guf="http://www.opengis.net/guf/1.0/core"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:ows="http://www.opengis.net/ows"
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

    <csw:Record>
      <xsl:for-each select="guf:itemIdentifier">
        <dc:identifier><xsl:value-of select="mcc:MD_Identifier/mcc:code/gco:CharacterString"/></dc:identifier>
      </xsl:for-each>
      
      <xsl:for-each select="guf:dateInfo/cit:date/
        cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']
        /cit:date/*">
        <dc:date><xsl:value-of select="."/></dc:date>
      </xsl:for-each>
      
      <!-- Title -->
      <xsl:for-each select="guf:citation/cit:CI_Citation">
        <xsl:for-each select="cit:title">
          <dc:title>
            <xsl:apply-templates mode="localised" select=".">
              <xsl:with-param name="langId" select="$langId"/>
            </xsl:apply-templates>
          </dc:title>
        </xsl:for-each>
      </xsl:for-each>

      <!-- Type - - - - - - - - - -->


      <!-- subject -->
      <xsl:for-each select="guf:descriptiveKeywords/mri:MD_Keywords/mri:keyword[not(@gco:nilReason)]">
        <dc:subject>
          <xsl:apply-templates mode="localised19115-1-2013" select=".">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:apply-templates>
        </dc:subject>
      </xsl:for-each>

      <xsl:for-each select="guf:tag/gco:CharacterString">
        <dc:subject>
          <xsl:apply-templates mode="localised" select=".">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:apply-templates>
        </dc:subject>
      </xsl:for-each>


      <!-- Distribution - - - - - - - - - -->
        
        
      <!-- FIXME: this is the date that the resource was modified - how does
        this relate to the date that the metadata was modified -
        see the dc:date above -->
      <xsl:for-each select="guf:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date/*">
        <dct:modified><xsl:value-of select="."/></dct:modified>
      </xsl:for-each>

      <xsl:for-each select="guf:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue='originator']/cit:party/cit:CI_Organisation/cit:name">
        <dc:creator>
          <xsl:apply-templates mode="localised19115-1-2013" select=".">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:apply-templates>
        </dc:creator>
      </xsl:for-each>

      <xsl:for-each select="guf:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue='publisher']/cit:party/cit:CI_Organisation/cit:name">
        <dc:publisher>
          <xsl:apply-templates mode="localised19115-1-2013" select=".">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:apply-templates>
        </dc:publisher>
      </xsl:for-each>

      <xsl:for-each select="guf:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue='author']/cit:party/cit:CI_Organisation/cit:name">
        <dc:contributor>
          <xsl:apply-templates mode="localised19115-1-2013" select=".">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:apply-templates>
        </dc:contributor>
      </xsl:for-each>

      <!-- abstract -->
      <xsl:for-each select="guf:abstract">
        <dct:abstract>
          <xsl:apply-templates mode="localised19115-1-2013" select=".">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:apply-templates>
        </dct:abstract>
        <dc:description>
          <xsl:apply-templates mode="localised19115-1-2013" select=".">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:apply-templates>
        </dc:description>
      </xsl:for-each>
      
      
      <!-- rights -->
      
      
      <!-- language -->
      <xsl:for-each select="guf:locale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue">
        <dc:language><xsl:value-of select="."/></dc:language>
      </xsl:for-each>
      
      
      <!-- Lineage -->
      <xsl:for-each select="guf:additionalLineageSteps/mrl:LI_Lineage/mrl:statement">
        <dc:source>
          <xsl:apply-templates mode="localised19115-1-2013" select=".">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:apply-templates>
        </dc:source>
      </xsl:for-each>

      
      <!-- Target -->
      <xsl:for-each select="guf:target/guf:GUF_FeedbackTarget/guf:resourceRef">
        <dc:relation><xsl:value-of select="cit:CI_Citation/
          cit:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString|@xlink:href"/></dc:relation>
      </xsl:for-each>
      
      <!-- bounding box -->

      
      <!-- GeoNetwork elements added when resultType is equal to results_with_summary -->
      <xsl:if test="$displayInfo = 'true'">
        <xsl:copy-of select="$info"/>
      </xsl:if>
      
    </csw:Record>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:apply-templates select="*"/>
  </xsl:template>
</xsl:stylesheet>