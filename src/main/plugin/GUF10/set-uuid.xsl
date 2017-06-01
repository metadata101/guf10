<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:guf="http://www.opengis.net/guf/1.0/core"
  xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
  exclude-result-prefixes="#all">
  
  <xsl:template match="/root">
    <xsl:apply-templates select="*[name() != 'env']"/>
  </xsl:template>

  <xsl:template match="guf:GUF_FeedbackItem|*[@gco:isoType='guf:GUF_FeedbackItem']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <guf:metadataIdentifier>
        <mcc:MD_Identifier>
          <!-- citation could be for this GeoNetwork node ?
            <mcc:citation><cit:CI_Citation>etc</cit:CI_Citation></mcc:citation>
          -->
          <mcc:codeSpace>
            <gco:CharacterString>urn:uuid</gco:CharacterString>
          </mcc:codeSpace>
          <mcc:code>
            <gco:CharacterString><xsl:value-of select="/root/env/uuid"/></gco:CharacterString>
          </mcc:code>
        </mcc:MD_Identifier>
      </guf:metadataIdentifier>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="guf:metadataIdentifier"/>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>