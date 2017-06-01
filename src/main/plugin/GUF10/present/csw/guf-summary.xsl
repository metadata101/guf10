<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
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
                xmlns:ows="http://www.opengis.net/ows"
                xmlns:guf="http://www.opengis.net/guf/1.0/core"
                xmlns:geonet="http://www.fao.org/geonetwork"
                exclude-result-prefixes="#all">

  <xsl:param name="displayInfo"/>


  <xsl:template match="guf:GUF_FeedbackItem|*[contains(@gco:isoType,'GUF_FeedbackItem')]">
    <xsl:variable name="info" select="geonet:info"/>
    <xsl:copy>
      <xsl:apply-templates select="guf:itemIdentifier"/>
      <xsl:apply-templates select="guf:dateInfo"/>
      <xsl:apply-templates select="guf:citation"/>
      <xsl:apply-templates select="guf:abstract"/>

      <!-- GeoNetwork elements added when resultType is equal to results_with_summary -->
      <xsl:if test="$displayInfo = 'true'">
        <xsl:copy-of select="$info"/>
      </xsl:if>

    </xsl:copy>
  </xsl:template>


  <xsl:template match="cit:CI_Citation">
    <xsl:copy>
      <xsl:apply-templates select="cit:title"/>
      <xsl:apply-templates select="cit:date[cit:CI_Date/cit:dateType/
        cit:CI_DateTypeCode/@codeListValue='revision']"/>
      <xsl:apply-templates select="cit:identifier"/>
      <xsl:apply-templates select="cit:responsibleParty"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="cit:CI_Responsibility[
    cit:role/cit:CI_RoleCode/@codeListValue='originator' or
    cit:role/cit:CI_RoleCode/@codeListValue='author' or
    cit:role/cit:CI_RoleCode/@codeListValue='publisher']">
    <xsl:copy>
      <xsl:apply-templates select="cit:party/cit:CI_Organisation/cit:name"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>