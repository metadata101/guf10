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
  xmlns:guf="http://www.opengis.net/guf/1.0/core"
  xmlns:gml="http://www.opengis.net/gml/3.2" 
  xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
  xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
  xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
  xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0"
  xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
  xmlns:dqm="http://standards.iso.org/iso/19157/-2/dqm/1.0"
  xmlns:gfc="http://standards.iso.org/iso/19110/gfc/1.1"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:java="java:org.fao.geonet.util.XslUtil"
  xmlns:mime="java:org.fao.geonet.util.MimeTypeFinder"
  xmlns:gn="http://www.fao.org/geonetwork"
  exclude-result-prefixes="#all">
  
  <xsl:import href="convert/ISO19139/utility/create19115-3Namespaces.xsl"/>
  
  <!--<xsl:include href="convert/functions.xsl"/>-->


  <!-- If no metadata linkage exist, build one based on
  the metadata UUID. -->
  <xsl:variable name="createMetadataLinkage" select="true()"/>
  <xsl:variable name="url" select="/root/env/siteURL"/>
  <xsl:variable name="uuid" select="/root/env/uuid"/>

  <xsl:variable name="metadataIdentifierCodeSpace"
                select="'urn:uuid'"
                as="xs:string"/>

  <xsl:template match="/root">
    <xsl:apply-templates select="guf:GUF_FeedbackItem"/>
  </xsl:template>
  
  <xsl:template match="guf:GUF_FeedbackItem">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      
      <xsl:call-template name="add-iso19115-3-namespaces"/>
      
      <!-- Add metadataIdentifier if it doesn't exist
      TODO: only if not harvested -->
      <guf:itemIdentifier>
        <mcc:MD_Identifier>
          <!-- authority could be for this GeoNetwork node ?
            <mcc:authority><cit:CI_Citation>etc</cit:CI_Citation></mcc:authority>
          -->
          <mcc:code>
            <gco:CharacterString><xsl:value-of select="/root/env/uuid"/></gco:CharacterString>
          </mcc:code>
          <mcc:codeSpace>
            <gco:CharacterString><xsl:value-of select="$metadataIdentifierCodeSpace"/></gco:CharacterString>
          </mcc:codeSpace>
        </mcc:MD_Identifier>
      </guf:itemIdentifier>

  <!--    <xsl:apply-templates select="mdb:metadataIdentifier[
                                    mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString !=
                                    $metadataIdentifierCodeSpace]"/>-->

      <xsl:apply-templates select="guf:abstract"/>
      <xsl:apply-templates select="guf:purpose"/>
      <xsl:apply-templates select="guf:contactRole"/>
      <xsl:apply-templates select="mdb:contact"/>


      <xsl:variable name="isCreationDateAvailable"
                    select="guf:dateInfo/*[cit:dateType/*/@codeListValue = 'creation']"/>
      <xsl:variable name="isRevisionDateAvailable"
                    select="guf:dateInfo/*[cit:dateType/*/@codeListValue = 'revision']"/>

      <!-- Add creation date if it does not exist-->
      <xsl:if test="not($isCreationDateAvailable)">
        <guf:dateInfo>
          <cit:CI_Date>
            <cit:date>
              <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
            </cit:date>
            <cit:dateType>
              <cit:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="creation"/>
            </cit:dateType>
          </cit:CI_Date>
        </guf:dateInfo>
      </xsl:if>
      <xsl:if test="not($isRevisionDateAvailable)">
        <guf:dateInfo>
          <cit:CI_Date>
            <cit:date>
              <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
            </cit:date>
            <cit:dateType>
              <cit:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="revision"/>
            </cit:dateType>
          </cit:CI_Date>
        </guf:dateInfo>
      </xsl:if>


      <!-- Preserve date order -->
      <xsl:for-each select="guf:dateInfo">
        <xsl:variable name="currentDateType" select="*/cit:dateType/*/@codeListValue"/>

        <!-- Update revision date-->
        <xsl:choose>
          <xsl:when test="$currentDateType = 'revision' and /root/env/changeDate">
            <guf:dateInfo>
              <cit:CI_Date>
                <cit:date>
                  <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
                </cit:date>
                <cit:dateType>
                  <cit:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="revision"/>
                </cit:dateType>
              </cit:CI_Date>
            </guf:dateInfo>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <xsl:apply-templates select="guf:itemIsReplyTo"/>
      <xsl:apply-templates select="guf:descriptiveKeywords"/>
      <xsl:apply-templates select="guf:tag"/>
      <xsl:apply-templates select="guf:locale"/>
      <xsl:apply-templates select="guf:externalFeedback"/>
      <xsl:apply-templates select="guf:citation"/>
      <xsl:apply-templates select="guf:additionalLineageSteps"/>
      <xsl:apply-templates select="guf:additionalQuality"/>
      <xsl:apply-templates select="guf:rating"/>
      <xsl:apply-templates select="guf:usage"/>

      <xsl:apply-templates select="guf:contact"/>
      <xsl:apply-templates select="guf:userComment"/>
      <xsl:apply-templates select="guf:significantEvent"/>
      <xsl:apply-templates select="guf:target"/>

      <!--<xsl:variable name="pointOfTruthUrl" select="concat($url, '/metadata/', $uuid)"/>

      <xsl:if test="$createMetadataLinkage and count(mdb:metadataLinkage/cit:CI_OnlineResource/cit:linkage/*[. = $pointOfTruthUrl]) = 0">
        &lt;!&ndash; TODO: This should only be updated for not harvested records ? &ndash;&gt;
        <mdb:metadataLinkage>
          <cit:CI_OnlineResource>
            <cit:linkage>
              &lt;!&ndash; TODO: define a URL pattern and use it here &ndash;&gt;
              &lt;!&ndash; TODO: URL could be multilingual ? &ndash;&gt;
              <gco:CharacterString><xsl:value-of select="$pointOfTruthUrl"/></gco:CharacterString>
            </cit:linkage>
            &lt;!&ndash; TODO: Could be relevant to add description of the
            point of truth for the metadata linkage but this
            needs to be language dependant. &ndash;&gt;
            <cit:function>
              <cit:CI_OnLineFunctionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_OnLineFunctionCode"
                                         codeListValue="completeMetadata"/>
            </cit:function>
          </cit:CI_OnlineResource>
        </mdb:metadataLinkage>
      </xsl:if>-->
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Update revision date -->
  <xsl:template match="guf:dateInfo[cit:CI_Date/cit:dateType/cit:CI_DateTypeCode/@codeListValue='lastUpdate']">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="/root/env/changeDate">
          <cit:CI_Date>
            <cit:date>
              <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
            </cit:date>
            <cit:dateType>
              <cit:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="lastUpdate"/>
            </cit:dateType>
          </cit:CI_Date>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="@gml:id">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="gml:id">
          <xsl:value-of select="generate-id(.)"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- Fix srsName attribute generate CRS:84 (EPSG:4326 with long/lat 
    ordering) by default -->
  <xsl:template match="@srsName">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="srsName">
          <xsl:text>CRS:84</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Add required gml attributes if missing -->
  <xsl:template match="gml:Polygon[not(@gml:id) and not(@srsName)]">
    <xsl:copy>
      <xsl:attribute name="gml:id">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
      <xsl:attribute name="srsName">
        <xsl:text>urn:x-ogc:def:crs:EPSG:6.6:4326</xsl:text>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="*"/>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="*[gco:CharacterString]">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(name()='gco:nilReason')]"/>
      <xsl:choose>
        <xsl:when test="normalize-space(gco:CharacterString)=''">
          <xsl:attribute name="gco:nilReason">
            <xsl:choose>
              <xsl:when test="@gco:nilReason"><xsl:value-of select="@gco:nilReason"/></xsl:when>
              <xsl:otherwise>missing</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@gco:nilReason!='missing' and normalize-space(gco:CharacterString)!=''">
          <xsl:copy-of select="@gco:nilReason"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- codelists: set @codeList path -->
  <xsl:template match="lan:LanguageCode[@codeListValue]" priority="10">
    <lan:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/">
      <xsl:apply-templates select="@*[name(.)!='codeList']"/>
    </lan:LanguageCode>
  </xsl:template>
  
  <xsl:template match="*[@codeListValue]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="codeList">
        <xsl:value-of select="concat('http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#',local-name(.))"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  
  <!-- Set local identifier to the first 3 letters of iso code. Locale ids
    are used for multilingual charcterString using #iso2code for referencing.
  -->
  <xsl:template match="guf:MD_Metadata/*/lan:PT_Locale">
    <xsl:element name="lan:{local-name()}">
      <xsl:variable name="id"
                    select="upper-case(java:twoCharLangCode(lan:language/lan:LanguageCode/@codeListValue))"/>
      
      <xsl:apply-templates select="@*"/>
      <xsl:if test="normalize-space(@id)='' or normalize-space(@id)!=$id">
        <xsl:attribute name="id">
          <xsl:value-of select="$id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>
  
  <!-- Apply same changes as above to the lan:LocalisedCharacterString -->
  <xsl:variable name="language" select="//(mdb:defaultLocale|mdb:otherLocale)/lan:PT_Locale" /> <!-- Need list of all locale -->
  
  <xsl:template match="lan:LocalisedCharacterString">
    <xsl:element name="lan:{local-name()}">
      <xsl:variable name="currentLocale" select="upper-case(replace(normalize-space(@locale), '^#', ''))"/>
      <xsl:variable name="ptLocale" select="$language[upper-case(replace(normalize-space(@id), '^#', '')) = string($currentLocale)]"/>
      <xsl:variable name="id" select="upper-case(java:twoCharLangCode($ptLocale/lan:language/lan:LanguageCode/@codeListValue))"/>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$id != '' and ($currentLocale = '' or @locale != concat('#', $id)) ">
        <xsl:attribute name="locale">
          <xsl:value-of select="concat('#',$id)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>
  
  <!-- ================================================================= -->
  <!-- Adjust the namespace declaration - In some cases name() is used to get the 
    element. The assumption is that the name is in the format of  <ns:element> 
    however in some cases it is in the format of <element xmlns=""> so the 
    following will convert them back to the expected value. This also corrects the issue 
    where the <element xmlns=""> loose the xmlns="" due to the exclude-result-prefixes="#all" -->
  <!-- Note: Only included prefix gml, mds and gco for now. -->
  <!-- TODO: Figure out how to get the namespace prefix via a function so that we don't need to hard code them -->
  <!-- ================================================================= -->
  
  <xsl:template name="correct_ns_prefix">
    <xsl:param name="element" />
    <xsl:param name="prefix" />
    <xsl:choose>
      <xsl:when test="local-name($element)=name($element) and $prefix != '' ">
        <xsl:element name="{$prefix}:{local-name($element)}">
          <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="guf:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'guf'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="gco:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'gco'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="gml:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'gml'"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- copy everything else as is -->
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
