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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:ogc="http://www.opengis.net/rdf#"
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
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:guf10="http://geonetwork-opensource.org/schemas/guf10"
                version="2.0"
                extension-element-prefixes="saxon" exclude-result-prefixes="#all">


  <!-- TODO : add Multilingual metadata support
    See http://www.w3.org/TR/2004/REC-rdf-syntax-grammar-20040210/#section-Syntax-languages

    TODO : maybe some characters may be encoded / avoid in URIs
    See http://www.w3.org/TR/2004/REC-rdf-concepts-20040210/#dfn-URI-reference
  -->

  <!--
    Create reference block to metadata record and dataset to be added in dcat:Catalog usually.
  -->
  <!-- FIME : $url comes from a global variable. -->
  <xsl:template match="guf:GUF_FeedbackItem|*[@gco:isoType='guf:GUF_FeedbackItem']" mode="record-reference">
    <!-- TODO : a metadata record may contains aggregate. In that case create one dataset per aggregate member. -->
    <dcat:dataset rdf:resource="{$resourcePrefix}/datasets/{guf10:getResourceCode(.)}"/>
    <dcat:record rdf:resource="{$resourcePrefix}/records/{guf:itemIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString}"/>
  </xsl:template>


  <!--
    Convert ISO record to DCAT
    -->
  <xsl:template match="guf:GUF_FeedbackItem|*[@gco:isoType='guf:GUF_FeedbackItem']" mode="to-dcat">


    <!-- Catalogue records
      "A record in a data catalog, describing a single dataset."

      xpath: //gmd:MD_Metadata|//*[@gco:isoType='gmd:MD_Metadata']
    -->
    <dcat:CatalogRecord rdf:about="{$resourcePrefix}/records/{guf:itemIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString}">
      <!-- Link to a dcat:Dataset or a rdf:Description for services and feature catalogue. -->
      <foaf:primaryTopic rdf:resource="{$resourcePrefix}/resources/{guf10:getResourceCode(.)}"/>

      <!-- Metadata change date.
      "The date is encoded as a literal in "YYYY-MM-DD" form (ISO 8601 Date and Time Formats)." -->
      <xsl:variable name="date" select="substring-before(guf:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date/gco:DateTime, 'T')"/>
      <dct:issued>
        <xsl:value-of select="$date"/>
      </dct:issued>
      <dct:modified>
        <xsl:value-of select="$date"/>
      </dct:modified>
      <!-- xpath: gmd:dateStamp/gco:DateTime -->

      <xsl:call-template name="add-reference-guf10">
        <xsl:with-param name="uuid" select="guf:itemIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString"/>
      </xsl:call-template>
    </dcat:CatalogRecord>


    <dcat:Dataset rdf:about="{$resourcePrefix}/datasets/{guf10:getResourceCode(../../.)}">
      <xsl:call-template name="to-dcat-guf10"/>
    </dcat:Dataset>
  </xsl:template>


  <!-- Add references for HTML and XML metadata record link -->
  <xsl:template name="add-reference-guf10">
    <xsl:param name="uuid"/>

    <dct:references>
      <rdf:Description rdf:about="{$resourcePrefix}/records/{$uuid}/formatters/xml">
        <dct:format>
          <dct:IMT>
            <rdf:value>application/xml</rdf:value>
            <rdfs:label>XML</rdfs:label>
          </dct:IMT>
        </dct:format>
      </rdf:Description>
    </dct:references>

    <dct:references>
      <rdf:Description rdf:about="{$resourcePrefix}/records/{$uuid}">
        <dct:format>
          <dct:IMT>
            <rdf:value>text/html</rdf:value>
            <rdfs:label>HTML</rdfs:label>
          </dct:IMT>
        </dct:format>
      </rdf:Description>
    </dct:references>
  </xsl:template>

  <!-- Create all references for GUF_FeedbackItem record (if rdf.metadata.get) or records (if rdf.search) -->
  <xsl:template match="guf:GUF_FeedbackItem|*[@gco:isoType='guf:GUF_FeedbackItem']" mode="references">

    <!-- Keywords -->
    <xsl:for-each-group
      select="//guf:descriptiveKeywords/mri:MD_Keywords[(mri:thesaurusName)]/mri:keyword/gco:CharacterString" group-by=".">
      <!-- FIXME maybe only do that, if keyword URI is available (when xlink is used ?) -->
      <skos:Concept
        rdf:about="{$resourcePrefix}/registries/vocabularies/{guf10:getThesaurusCode(../../mri:thesaurusName)}/concepts/{encode-for-uri(.)}">
        <skos:inScheme
          rdf:resource="{$resourcePrefix}/registries/vocabularies/{guf10:getThesaurusCode(../../mri:thesaurusName)}"/>
        <skos:prefLabel>
          <xsl:value-of select="."/>
        </skos:prefLabel>
      </skos:Concept>
    </xsl:for-each-group>

    <xsl:for-each-group
      select="//guf:contact/guf:GUF_UserInformation/guf:userDetails/cit:CI_Responsibility/cit:party[cit:CI_Organisation/cit:name/gco:CharacterString!='']"
      group-by="cit:CI_Organisation/cit:name/gco:CharacterString">
      <!-- Organization description.
        Organization could be linked to a catalogue, a catalogue record.

        xpath: //gmd:organisationName
      -->
      <foaf:Organization rdf:about="{$resourcePrefix}/organizations/{encode-for-uri(current-grouping-key())}">
        <foaf:name>
          <xsl:value-of select="current-grouping-key()"/>
        </foaf:name>
        <!-- xpath: gmd:organisationName/gco:CharacterString -->
        <xsl:for-each-group
          select="//guf:contact/guf:GUF_UserInformation/guf:userDetails/cit:CI_Responsibility/cit:party[cit:CI_Organisation/cit:name/gco:CharacterString=current-grouping-key()]"
          group-by="cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress/gco:CharacterString">
          <foaf:member
            rdf:resource="{$resourcePrefix}/persons/{encode-for-uri(guf10:getContactId(.))}"/>
        </xsl:for-each-group>
      </foaf:Organization>
    </xsl:for-each-group>

    <!-- TODO: Review -->
<!--    <xsl:for-each-group select="//guf:contact/guf:GUF_UserInformation/guf:userDetails/cit:CI_Responsibility/cit:party"
                        group-by="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString">
      &lt;!&ndash; Organization member

        xpath: //gmd:CI_ResponsibleParty&ndash;&gt;

      <foaf:Agent rdf:about="{$resourcePrefix}/persons/{encode-for-uri(guf10:getContactId(.))}">
        <xsl:if test="gmd:individualName/gco:CharacterString">
          <foaf:name>
            <xsl:value-of select="gmd:individualName/gco:CharacterString"/>
          </foaf:name>
        </xsl:if>
        &lt;!&ndash; xpath: gmd:individualName/gco:CharacterString &ndash;&gt;
        <xsl:if
          test="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString">
          <foaf:phone>
            <xsl:value-of
              select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString"/>
          </foaf:phone>
        </xsl:if>
        &lt;!&ndash; xpath: gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString &ndash;&gt;
        <xsl:if
          test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString">
          <foaf:mbox
            rdf:resource="mailto:{gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString}"/>
        </xsl:if>
        &lt;!&ndash; xpath: gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString &ndash;&gt;
      </foaf:Agent>
    </xsl:for-each-group>-->
  </xsl:template>



  <!-- Build a dcat record for a dataset -->
  <xsl:template name="to-dcat-guf10">
    <!-- "A unique identifier of the dataset." -->
    <dct:identifier>
      <xsl:value-of select="guf10:getResourceCode(../../.)"/>
    </dct:identifier>

    <dct:title>
      <xsl:value-of select="guf:citation/*/cit:title/gco:CharacterString"/>
    </dct:title>

    <dct:abstract>
      <xsl:value-of select="guf:abstract/gco:CharacterString"/>
    </dct:abstract>

    <!-- "A keyword or tag describing the dataset."
      Create dcat:keyword if no thesaurus name information available.
    -->
    <xsl:for-each
      select="guf:descriptiveKeywords/mri:MD_Keywords[not(mri:thesaurusName)]/mri:keyword/gco:CharacterString">
      <dcat:keyword>
        <xsl:value-of select="."/>
      </dcat:keyword>
    </xsl:for-each>

    <!-- "The main category of the dataset. A dataset can have multiple themes."
      Create dcat:theme if gmx:Anchor or GEMET concepts or INSPIRE themes
    -->
    <xsl:for-each
      select="guf:descriptiveKeywords/mri:MD_Keywords[mri:thesaurusName]/mri:keyword/gco:CharacterString">
      <!-- FIXME maybe only do that, if keyword URI is available (when xlink is used ?) -->
      <dcat:theme
        rdf:resource="{$resourcePrefix}/registries/vocabularies/{guf10:getThesaurusCode(../../mri:thesaurusName)}/concepts/{.}"/>
    </xsl:for-each>


    <xsl:for-each
      select="guf:dateInfo/*/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='creation']">
      <dct:issued>
        <xsl:value-of select="gmd:date/gco:Date|gmd:date/gco:DateTime"/>
      </dct:issued>
    </xsl:for-each>
    <xsl:for-each
      select="guf:dateInfo/*/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='revision']">
      <dct:updated>
        <xsl:value-of select="gmd:date/gco:Date|gmd:date/gco:DateTime"/>
      </dct:updated>
    </xsl:for-each>

    <!-- "An entity responsible for making the dataset available" -->
    <xsl:for-each select="guf:contact/guf:GUF_UserInformation/guf:userDetails/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString[.!='']">
      <dct:publisher rdf:resource="{$resourcePrefix}/organizations/{encode-for-uri(.)}"/>
    </xsl:for-each>


    <!--
      "The language of the dataset."
      "This overrides the value of the catalog language in case of conflict"
    -->
    <xsl:for-each select="guf:locale/gco:CharacterString">
      <dct:language>
        <xsl:value-of select="."/>
      </dct:language>
    </xsl:for-each>

    <!-- Target relation
    -->
    <xsl:for-each select="guf:target/guf:GUF_FeedbackTarget/guf:resourceRef">
      <dct:relation rdf:resource="{$resourcePrefix}/records/{cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString}"/>
    </xsl:for-each>


    <!--
      "A related document such as technical documentation, agency program page, citation, etc."

      TODO : only for URL ?
      <xsl:for-each select="gmd:citation/*/gmd:otherCitationDetails/gco:CharacterString">
      <dct:reference rdf:resource="url?"/>
      </xsl:for-each>
    -->
    <!-- xpath: gmd:identificationInfo/*/gmd:citation/*/gmd:otherCitationDetails/gco:CharacterString -->


    <!-- "describes the quality of data." -->
    <xsl:for-each
      select="guf:additionalLineageSteps/mrl:LI_Lineage/mrl:statement/gco:CharacterString">
      <dcat:dataQuality>
        <!-- rdfs:literal -->
        <xsl:value-of select="."/>
      </dcat:dataQuality>
    </xsl:for-each>

    <!-- FIXME ?
      <void:dataDump></void:dataDump>-->
  </xsl:template>


  <!--
    Get resource (dataset or service) identifier if set and return metadata UUID if not.
  -->
  <xsl:function name="guf10:getResourceCode" as="xs:string">
    <xsl:param name="metadata" as="node()"/>

    <xsl:value-of select="if ($metadata/guf:citation/*/mcc:identifier/*/mcc:code/gco:CharacterString!='')
      then $metadata/guf:citation/*/mcc:identifier/*/mcc:code/gco:CharacterString
      else $metadata/guf:itemIdentifier/*/mcc:code/gco:CharacterString"/>
  </xsl:function>


  <!--
    Get thesaurus identifier, otherCitationDetails value, citation @id or thesaurus title.
  -->
  <xsl:function name="guf10:getThesaurusCode" as="xs:string">
    <xsl:param name="thesaurusName" as="node()"/>

    <xsl:value-of select="if ($thesaurusName/*/cit:otherCitationDetails/*!='') then $thesaurusName/*/cit:otherCitationDetails/*
      else if ($thesaurusName/cit:CI_Citation/@id!='') then $thesaurusName/cit:CI_Citation/@id!=''
      else encode-for-uri($thesaurusName/*/cit:title/gco:CharacterString)"/>
  </xsl:function>

  <!--
    Get contact identifier (for the time being = email and node generated identifier if no email available)
  -->
  <xsl:function name="guf10:getContactId" as="xs:string">
    <xsl:param name="responsibleParty" as="node()"/>

    <xsl:value-of select="if ($responsibleParty/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress/gco:CharacterString!='')
      then $responsibleParty/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress/gco:CharacterString
      else generate-id($responsibleParty)"/>
  </xsl:function>

</xsl:stylesheet>
