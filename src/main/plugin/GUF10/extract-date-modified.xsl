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

<xsl:stylesheet
  version="2.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
  xmlns:guf="http://www.opengis.net/guf/1.0/core"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template
    match="guf:GUF_FeedbackItem">
    <xsl:variable name="revisionDate" 
                  select="guf:dateInfo/cit:CI_Date
      [cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']
      /cit:date/*"/>
    <dateStamp>
      <xsl:choose>
        <xsl:when test="normalize-space($revisionDate)">
          <xsl:value-of select="$revisionDate"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="guf:dateInfo/cit:CI_Date
            [cit:dateType/cit:CI_DateTypeCode/@codeListValue='creation']
            /cit:date/*"/>
          <!-- TODO: Should we handle when no creation nor revision date
          defined ? -->
        </xsl:otherwise>
      </xsl:choose>
    </dateStamp>
  </xsl:template>
</xsl:stylesheet>