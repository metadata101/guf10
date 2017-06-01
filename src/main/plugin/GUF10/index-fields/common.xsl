<?xml version="1.0" encoding="UTF-8" ?>
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

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:guf="http://www.opengis.net/guf/1.0/core"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
                xmlns:dqm="http://standards.iso.org/iso/19157/-2/dqm/1.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0"
                xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
                xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/1.0"
                xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
                xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
                xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
                xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
                xmlns:gfc="http://standards.iso.org/iso/19110/gfc/1.1"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:joda="java:org.fao.geonet.domain.ISODate"
                xmlns:gn-fn-core="http://geonetwork-opensource.org/xsl/functions/core"
                xmlns:gn-fn-guf10="http://geonetwork-opensource.org/xsl/functions/profiles/guf10"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                exclude-result-prefixes="#all">


  <xsl:include href="common/functions-core.xsl"/>
  <xsl:include href="../layout/utility-tpl-multilingual.xsl"/>
  <!--<xsl:include href="index-subtemplate-fields.xsl"/>-->


  <!-- Thesaurus folder -->
  <xsl:param name="thesauriDir"/>

  <!-- Enable INSPIRE or not -->
  <xsl:param name="inspire">false</xsl:param>

  <xsl:variable name="df">[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]</xsl:variable>

  <!-- If identification citation dates
    should be indexed as a temporal extent information (eg. in INSPIRE
    metadata implementing rules, those elements are defined as part
    of the description of the temporal extent). -->
  <xsl:variable name="useDateAsTemporalExtent" select="false()"/>

  <!-- Load INSPIRE theme thesaurus if available -->
  <xsl:variable name="inspire-thesaurus"
                select="document(concat('file:///', $thesauriDir, '/external/thesauri/theme/inspire-theme.rdf'))"/>

  <xsl:variable name="inspire-theme"
                select="if ($inspire-thesaurus//skos:Concept)
                        then $inspire-thesaurus//skos:Concept
                        else ''"/>

  <xsl:variable name="metadata"
                select="/guf:GUF_FeedbackItem"/>
  
  <!-- Metadata UUID. -->
  <xsl:variable name="fileIdentifier"
                select="$metadata/
                            guf:itemIdentifier[1]/
                            mcc:MD_Identifier/mcc:code/*"/>

  <!-- Get the language
      If not set, the default will be english.
  -->
  <xsl:variable name="defaultLang">eng</xsl:variable>

  <xsl:variable name="documentMainLanguage"
                select="if ($metadata/guf:locale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue != '')
                        then $metadata/guf:locale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue
                        else $defaultLang"/>




  <xsl:template name="indexMetadata">
    <xsl:param name="lang" select="$documentMainLanguage"/>
    <xsl:param name="langId" select="''"/>

    <Document locale="{$lang}">
      <Field name="_locale" string="{$lang}" store="true" index="true"/>
      <Field name="_docLocale" string="{$lang}" store="true" index="true"/>

      <!-- Extension point using index mode -->
      <xsl:apply-templates mode="index" select="*"/>

      <xsl:call-template name="CommonFieldsFactory">
        <xsl:with-param name="lang" select="$lang"/>
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>



      <!-- === Free text search === -->
      <Field name="any" store="false" index="true">
        <xsl:attribute name="string">
          <xsl:choose>
            <xsl:when test="$langId != ''">
              <xsl:value-of select="normalize-space(//node()[@locale=$langId])"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(string(.))"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text> </xsl:text>
          <xsl:for-each select="//@codeListValue">
            <xsl:value-of select="concat(., ' ')"/>
          </xsl:for-each>
        </xsl:attribute>
      </Field>
    </Document>
  </xsl:template>



  <!-- Index a field based on the language -->
  <xsl:function name="gn-fn-guf10:index-field" as="node()?">
    <xsl:param name="fieldName" as="xs:string"/>
    <xsl:param name="element" as="node()"/>

    <xsl:copy-of select="gn-fn-guf10:index-field($fieldName,
                  $element, $documentMainLanguage, true(), true())"/>
  </xsl:function>
  <xsl:function name="gn-fn-guf10:index-field" as="node()?">
    <xsl:param name="fieldName" as="xs:string"/>
    <xsl:param name="element" as="node()"/>
    <xsl:param name="langId" as="xs:string"/>

    <xsl:copy-of select="gn-fn-guf10:index-field($fieldName,
                  $element, $langId, true(), true())"/>
  </xsl:function>
  <xsl:function name="gn-fn-guf10:index-field" as="node()?">
    <xsl:param name="fieldName" as="xs:string"/>
    <xsl:param name="element" as="node()"/>
    <xsl:param name="langId" as="xs:string"/>
    <xsl:param name="store" as="xs:boolean"/>
    <xsl:param name="index" as="xs:boolean"/>

    <xsl:variable name="value">
      <xsl:for-each select="$element">
        <xsl:apply-templates mode="localised" select=".">
          <xsl:with-param name="langId" select="concat('#', $langId)"/>
        </xsl:apply-templates>
      </xsl:for-each>
    </xsl:variable>
    <!--<xsl:message><xsl:value-of select="$fieldName"/>:<xsl:value-of select="normalize-space($value)"/> (<xsl:value-of select="$langId"/>) </xsl:message>-->
    <xsl:if test="normalize-space($value) != ''">
      <Field name="{$fieldName}"
             string="{normalize-space($value)}"
             store="{$store}"
             index="{$index}"/>
    </xsl:if>
  </xsl:function>


  <!-- Grab the default title which will
  be added to all document in the index
  whatever the langugae. -->
  <xsl:template name="defaultTitle">
    <xsl:param name="isoDocLangId"/>

    <xsl:variable name="poundLangId"
                  select="concat('#',upper-case(util:twoCharLangCode($isoDocLangId)))" />

    <xsl:variable name="docLangTitle"
                  select="$metadata/guf:citation/*/cit:title//lan:LocalisedCharacterString[@locale = $poundLangId]"/>
    <xsl:variable name="charStringTitle"
                  select="$metadata/guf:citation/*/cit:title/gco:CharacterString"/>
    <xsl:variable name="locStringTitles"
                  select="$metadata/guf:citation/*/cit:title//lan:LocalisedCharacterString"/>
    <xsl:choose>
      <xsl:when test="string-length(string($docLangTitle)) != 0">
        <xsl:value-of select="$docLangTitle[1]"/>
      </xsl:when>
      <xsl:when test="string-length(string($charStringTitle[1])) != 0">
        <xsl:value-of select="string($charStringTitle[1])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="string($locStringTitles[1])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Format a date. If null, unknown, current, now return
  the current date time.
  -->
  <xsl:function name="gn-fn-guf10:formatDateTime" as="xs:string">
    <xsl:param name="value" as="xs:string"/>

    <xsl:choose>
      <xsl:when test="$value='' or lower-case($value)='unknown' or lower-case($value)='current' or lower-case($value)='now'">
        <xsl:value-of select="format-dateTime(current-dateTime(),$df)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="joda:parseISODateTime($value)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <xsl:template name="CommonFieldsFactory">
    <xsl:param name="lang" select="$documentMainLanguage"/>
    <xsl:param name="langId" select="''"/>

    <!-- The default title in the main language -->
    <xsl:variable name="_defaultTitle">
      <xsl:call-template name="defaultTitle">
        <xsl:with-param name="isoDocLangId" select="$documentMainLanguage"/>
      </xsl:call-template>
    </xsl:variable>

    <Field name="_defaultTitle"
           string="{string($_defaultTitle)}"
           store="true"
           index="true"/>
    <!-- not tokenized title for sorting, needed for multilingual sorting -->
    <Field name="_title"
           string="{string($_defaultTitle)}"
           store="true"
           index="true" />


    <xsl:for-each select="$metadata/guf:citation/*">
        <xsl:for-each select="mcc:identifier/mcc:MD_Identifier/mcc:code">
          <xsl:copy-of select="gn-fn-guf10:index-field('identifier', ., $langId)"/>
        </xsl:for-each>

        <xsl:for-each select="cit:title">
          <xsl:copy-of select="gn-fn-guf10:index-field('title', ., $langId)"/>
        </xsl:for-each>

        <xsl:for-each select="cit:alternateTitle">
          <xsl:copy-of select="gn-fn-guf10:index-field('altTitle', ., $langId)"/>
        </xsl:for-each>

        <xsl:for-each select="cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date">
          <Field name="revisionDate"
                 string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}"
                 store="true" index="true"/>
          <Field name="createDateMonth"
                 string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 8)}"
                 store="true" index="true"/>
          <Field name="createDateYear"
                 string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 5)}"
                 store="true" index="true"/>
          <xsl:if test="$useDateAsTemporalExtent">
            <Field name="tempExtentBegin"
                   string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}"
                   store="true" index="true"/>
          </xsl:if>
        </xsl:for-each>


        <xsl:for-each select="cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='creation']/cit:date">
          <Field name="createDate"
                 string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}"
                 store="true" index="true"/>
          <Field name="createDateMonth"
                 string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 8)}"
                 store="true" index="true"/>
          <Field name="createDateYear"
                 string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 5)}"
                 store="true" index="true"/>
          <xsl:if test="$useDateAsTemporalExtent">
            <Field name="tempExtentBegin"
                   string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}"
                   store="true" index="true"/>
          </xsl:if>
        </xsl:for-each>


        <xsl:for-each select="cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='publication']/cit:date">
          <Field name="publicationDate"
                 string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}"
                 store="true" index="true"/>
          <xsl:if test="$useDateAsTemporalExtent">
            <Field name="tempExtentBegin"
                   string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}"
                   store="true" index="true"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>

    <xsl:for-each select="$metadata/guf:abstract">
      <xsl:copy-of select="gn-fn-guf10:index-field('abstract', ., $langId)"/>
    </xsl:for-each>



    <xsl:for-each select="//mri:MD_Keywords">
      <xsl:variable name="thesaurusTitle"
                    select="replace(mri:thesaurusName/*/cit:title/gco:CharacterString/text(), ' ', '')"/>
      <xsl:variable name="thesaurusIdentifier"
                    select="mri:thesaurusName/*/cit:identifier/*/mcc:code/*/text()"/>
      <xsl:if test="$thesaurusIdentifier != ''">
        <Field name="thesaurusIdentifier"
               string="{substring-after(
                            $thesaurusIdentifier,
                            'geonetwork.thesaurus.')}"
               store="true" index="true"/>
      </xsl:if>
      <xsl:if test="mri:thesaurusName/*/cit:title/gco:CharacterString/text() != ''">
        <Field name="thesaurusName"
               string="{mri:thesaurusName/*/cit:title/gco:CharacterString/text()}"
               store="true" index="true"/>
      </xsl:if>

      <xsl:variable name="fieldName"
                    select="if ($thesaurusIdentifier != '')
                            then $thesaurusIdentifier
                            else $thesaurusTitle"/>
      <xsl:variable name="fieldNameTemp"
                    select="if (starts-with($fieldName, 'geonetwork.thesaurus'))
                              then substring-after($fieldName, 'geonetwork.thesaurus.')
                              else $fieldName"/>

      <xsl:for-each select="mri:keyword">
        <xsl:copy-of select="gn-fn-guf10:index-field('keyword', ., $langId)"/>

        <xsl:if test="$fieldNameTemp != ''">
          <!-- field thesaurus-{{thesaurusIdentifier}}={{keyword}} allows
          to group all keywords of same thesaurus in a field -->

          <xsl:copy-of select="gn-fn-guf10:index-field(
                                concat('thesaurus-', $fieldNameTemp), ., $langId)"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:for-each select="mri:keyword/gco:CharacterString|
                              mri:keyword/gcx:Anchor|
                              mri:keyword/lan:PT_FreeText/lan:textGroup/lan:LocalisedCharacterString">
        <xsl:if test="$inspire = 'true'">
          <xsl:if test="string-length(.) &gt; 0">
            <xsl:variable name="inspireannex">
              <xsl:call-template name="findInspireAnnex">
                <xsl:with-param name="keyword" select="string(.)"/>
                <xsl:with-param name="inspireThemes" select="$inspire-theme"/>
              </xsl:call-template>
            </xsl:variable>

            <!-- Add the inspire field if it's one of the 34 themes -->
            <xsl:if test="normalize-space($inspireannex)!=''">
              <xsl:variable name="keyword" select="."/>
              <xsl:variable name="inspireThemeAcronym">
                <xsl:call-template name="findInspireThemeAcronym">
                  <xsl:with-param name="keyword" select="$keyword"/>
                </xsl:call-template>
              </xsl:variable>

              <Field name="inspiretheme" string="{string(.)}" store="false" index="true"/>
              <Field name="inspirethemewithac"
                     string="{concat($inspireThemeAcronym, '|', $keyword)}"
                     store="true" index="true"/>
              <Field name="inspirethemeuri" string="{$inspire-theme[skos:prefLabel = $keyword]/@rdf:about}" store="true" index="true"/>
              <Field name="inspireannex" string="{$inspireannex}" store="false" index="true"/>
              <Field name="inspirecat" string="true" store="false" index="true"/>
            </xsl:if>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>

    <xsl:variable name="listOfKeywords">{
        <xsl:variable name="keywordWithNoThesaurus"
                      select="//mri:MD_Keywords[
                                not(mri:thesaurusName) or mri:thesaurusName/*/cit:title/*/text() = '']/
                                  mri:keyword[*/text() != '']"/>
        <xsl:if test="count($keywordWithNoThesaurus) > 0">
          'other': [
          <xsl:for-each select="$keywordWithNoThesaurus/(gco:CharacterString|gcx:Anchor)">
            <xsl:value-of select="concat('''', replace(., '''', '\\'''), '''')"/>
            <xsl:if test="position() != last()">,</xsl:if>
          </xsl:for-each>
          ]
          <xsl:if test="//mri:MD_Keywords[mri:thesaurusName]">,</xsl:if>
        </xsl:if>
        <xsl:for-each-group select="//mri:MD_Keywords[mri:thesaurusName/*/cit:title/*/text() != '']"
                            group-by="mri:thesaurusName/*/cit:title/*/text()">
          '<xsl:value-of select="replace(current-grouping-key(), '''', '\\''')"/>' :[
          <xsl:for-each select="mri:keyword/(gco:CharacterString|gcx:Anchor)">
            <xsl:value-of select="concat('''', replace(., '''', '\\'''), '''')"/>
            <xsl:if test="position() != last()">,</xsl:if>
          </xsl:for-each>
          ]
          <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each-group>
        }
      </xsl:variable>

    <Field name="keywordGroup"
             string="{normalize-space($listOfKeywords)}"
             store="true"
             index="false"/>


    <xsl:for-each select="$metadata/guf:locale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue">
      <Field name="datasetLang" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <xsl:for-each select="$metadata/guf:contact/guf:GUF_UserInformation/*/cit:CI_Responsibility/cit:party/cit:CI_Organisation">
        <xsl:variable name="orgName" select="string(cit:name/*)"/>

        <xsl:copy-of select="gn-fn-guf10:index-field('orgName', cit:name, $langId)"/>

        <xsl:call-template name="ContactIndexing">
          <xsl:with-param name="lang" select="$lang"/>
          <xsl:with-param name="langId" select="$langId"/>
        </xsl:call-template>
      </xsl:for-each>


    <xsl:for-each select="$metadata/guf:additionalQuality/*/dqm:report/*/dqm:result">
      <xsl:if test="$inspire='true'">
        <!--
        INSPIRE related dataset could contains a conformity section with:
        * COMMISSION REGULATION (EU) No 1089/2010 of 23 November 2010 implementing Directive 2007/2/EC of the European Parliament and of the Council as regards interoperability of spatial data sets and services
        * INSPIRE Data Specification on <Theme Name> – <version>
        * INSPIRE Specification on <Theme Name> – <version> for CRS and GRID

        Index those types of citation title to found dataset related to INSPIRE (which may be better than keyword
        which are often used for other types of datasets).

        "1089/2010" is maybe too fuzzy but could work for translated citation like "Règlement n°1089/2010, Annexe II-6" TODO improved
        -->
        <xsl:if test="(
            contains(dqm:DQ_ConformanceResult/dqm:specification/cit:CI_Citation/cit:title/gco:CharacterString, '1089/2010') or
            contains(dqm:DQ_ConformanceResult/dqm:specification/cit:CI_Citation/cit:title/gco:CharacterString, 'INSPIRE Data Specification') or
            contains(dqm:DQ_ConformanceResult/dqm:specification/cit:CI_Citation/cit:title/gco:CharacterString, 'INSPIRE Specification'))">
          <Field name="inspirerelated" string="on" store="false" index="true"/>
        </xsl:if>
      </xsl:if>

      <xsl:for-each select="//dqm:pass/gco:Boolean">
        <Field name="degree" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="//dqm:specification/*/cit:title">
        <xsl:copy-of select="gn-fn-guf10:index-field('specificationTitle', ., $langId)"/>
      </xsl:for-each>

      <xsl:for-each select="//dqm:specification/*/cit:date/*/cit:date">
        <Field name="specificationDate" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="//dqm:specification/*/cit:date/*/cit:dateType/cit:CI_DateTypeCode/@codeListValue">
        <Field name="specificationDateType" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:for-each select="mdb:dataQualityInfo/*/dqm:lineage/*/dqm:statement">
      <xsl:copy-of select="gn-fn-guf10:index-field('lineage', ., $langId)"/>
    </xsl:for-each>


    <Field name="hasDqMeasures" index="true" store="true"
           string="{count($metadata/guf:additionalQuality/*/mdq:report/*[
                            mdq:measure/*/mdq:measureIdentification/*/mcc:code/*/text() != ''
                          ]/mdq:result/mdq:DQ_QuantitativeResult[mdq:value/gco:Record/text() != '']) > 0}"/>

   <!-- TODO: Multilingual support -->
    <xsl:for-each select="$metadata/guf:additionalQuality">
      <!-- Checpoint / Index component id.
        If not set, then index by dq section position. -->
      <xsl:variable name="cptId" select="*/@uuid"/>
      <xsl:variable name="cptName" select="*/mdq:scope/*/mcc:levelDescription[1]/*/mcc:other/*/text()"/>
      <xsl:variable name="dqId" select="if ($cptId != '') then $cptId else position()"/>

      <Field name="dqCpt" index="true" store="true"
             string="{$dqId}"/>


      <xsl:for-each select="*/mdq:standaloneQualityReport/*[
                              mdq:reportReference/*/cit:title/*/text() != ''
                            ]">
        <Field name="dqSReport" index="false" store="true"
               string="{normalize-space(concat(
                          mdq:reportReference/*/cit:title/*/text(), '|', mdq:abstract/*/text()))}"/>
      </xsl:for-each>

      <xsl:for-each select="*/mdq:report/*[
                            mdq:measure/*/mdq:measureIdentification/*/mcc:code/*/text() != ''
                          ]">

        <xsl:variable name="qmId" select="mdq:measure/*/mdq:measureIdentification/*/mcc:code/*/text()"/>
        <xsl:variable name="qmName" select="mdq:measure/*/mdq:nameOfMeasure/*/text()"/>

        <!-- Search record by measure id or measure name. -->
        <Field name="dqMeasure" index="true" store="false"
               string="{$qmId}"/>
        <Field name="dqMeasureName" index="true" store="false"
               string="{$qmName}"/>


        <xsl:for-each select="mdq:result/mdq:DQ_QuantitativeResult">
          <xsl:variable name="qmDate" select="mdq:dateTime/gco:Date/text()"/>
          <xsl:variable name="qmValue" select="mdq:value/gco:Record/text()"/>
          <xsl:variable name="qmUnit" select="mdq:valueUnit/*/gml:identifier/text()"/>
          <Field name="dqValues" index="true" store="true"
                 string="{concat($dqId, '|', $cptName, '|', $qmId, '|', $qmName, '|', $qmDate, '|', $qmValue, '|', $qmUnit)}"/>

        </xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>


    <xsl:for-each select="$metadata/mdb:additionalLineageSteps/*/mrl:source[@uuidref]">
      <Field  name="hassource" string="{string(@uuidref)}" store="false" index="true"/>
    </xsl:for-each>


    <xsl:for-each select="$metadata/guf:locale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue">
      <Field name="language" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>


    <xsl:for-each select="$metadata/guf:itemIdentifier/mcc:MD_Identifier">
      <Field name="fileId" string="{string(mcc:code/gco:CharacterString)}" store="false" index="true"/>
    </xsl:for-each>


    <xsl:for-each select="$metadata/guf:contact/guf:GUF_UserInformation/*/cit:CI_Responsibility/cit:party/cit:CI_Organisation">
      <xsl:variable name="orgName" select="string(cit:name/*)"/>
      <xsl:copy-of select="gn-fn-guf10:index-field('orgName', cit:name, $langId)"/>

      <xsl:call-template name="ContactIndexing">
        <xsl:with-param name="type" select="'metadata'"/>
        <xsl:with-param name="lang" select="$lang"/>
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>


    <xsl:for-each select="$metadata/guf:dateInfo/cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date/*">
      <Field name="changeDate" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <!-- Index the relation, using agg_source relation -->
    <xsl:for-each select="$metadata/guf:target/guf:GUF_FeedbackTarget/guf:resourceRef/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString">
      <xsl:if test="string(.)">
        <xsl:copy-of select="gn-fn-guf10:index-field('agg_source', ., $langId)"/>
        <xsl:copy-of select="gn-fn-guf10:index-field('agg_associated', ., $langId)"/>

        <Field name="agg_associated" string="{.}" store="false" index="true"/>
        <Field name="agg_with_association" string="source" store="false"
               index="true"/>

        <Field name="agg_use"
               string="true"
               store="false" index="true"/>
      </xsl:if>
    </xsl:for-each>

    <!-- Index all codelist -->
    <xsl:for-each select="$metadata//*[*/@codeListValue != '']">
      <Field name="cl_{local-name()}"
             string="{*/@codeListValue}"
             store="true" index="true"/>
      <!--<xsl:message><xsl:value-of select="name(*)"/>:<xsl:value-of select="*/@codeListValue"/> (<xsl:value-of select="$lang"/>) = <xsl:value-of select="util:getCodelistTranslation(name(*), string(*/@codeListValue), $lang)"/></xsl:message>-->
      <Field name="cl_{concat(local-name(), '_text')}"
             string="{util:getCodelistTranslation(name(*), string(*/@codeListValue), string($lang))}"
             store="true" index="true"/>
    </xsl:for-each>

  </xsl:template>



  <xsl:template name="ContactIndexing">
    <xsl:param name="type" select="'resource'" required="no" as="xs:string"/>
    <xsl:param name="fieldPrefix" select="'responsibleParty'" required="no" as="xs:string"/>
    <xsl:param name="lang"/>
    <xsl:param name="langId"/>

    <xsl:copy-of select="gn-fn-guf10:index-field('orgName', cit:name, $langId)"/>
    <xsl:variable name="role" select="../../cit:role/*/@codeListValue"/>
    <xsl:variable name="email" select="cit:contactInfo/cit:CI_Contact/
                                              cit:address/cit:CI_Address/
                                              cit:electronicMailAddress/gco:CharacterString"/>
    <xsl:variable name="roleTranslation" select="util:getCodelistTranslation('cit:CI_RoleCode', string($role), string($lang))"/>
    <xsl:variable name="logo" select="cit:logo/mcc:MD_BrowseGraphic/mcc:fileName/gco:CharacterString"/>
    <xsl:variable name="phones"
                  select="cit:contactInfo/cit:CI_Contact/cit:phone/*/cit:number/gco:CharacterString"/>
    <!--<xsl:variable name="phones"
                  select="cit:contactInfo/cit:CI_Contact/cit:phone/concat(*/cit:numberType/*/@codeListValue, ':', */cit:number/gco:CharacterString)"/>-->
    <xsl:variable name="address" select="string-join(cit:contactInfo/*/cit:address/*/(
                                          cit:deliveryPoint|cit:postalCode|cit:city|
                                          cit:administrativeArea|cit:country)/gco:CharacterString/text(), ', ')"/>
    <xsl:variable name="individualNames" select="''"/>
    <xsl:variable name="positionName" select="''"/>

    <xsl:variable name="orgName">
      <xsl:apply-templates mode="localised" select="cit:name">
        <xsl:with-param name="langId" select="concat('#', $langId)"/>
      </xsl:apply-templates>
    </xsl:variable>

    <Field name="{$fieldPrefix}"
           string="{concat($roleTranslation, '|', $type, '|',
                              $orgName, '|', $logo, '|',
                              string-join($email, ','), '|', $individualNames,
                              '|', $positionName, '|',
                              $address, '|', string-join($phones, ','))}"
           store="true" index="false"/>
           
    <xsl:for-each select="$email">
      <Field name="{$fieldPrefix}Email" string="{string(.)}" store="true" index="true"/>
      <Field name="{$fieldPrefix}RoleAndEmail" string="{$role}|{string(.)}" store="true" index="true"/>
    </xsl:for-each>
    <xsl:for-each select="@uuid">
      <Field name="{$fieldPrefix}Uuid" string="{string(.)}" store="true" index="true"/>
      <Field name="{$fieldPrefix}RoleAndUuid" string="{$role}|{string(.)}" store="true" index="true"/>
    </xsl:for-each>

  </xsl:template>


  <!-- Traverse the tree in index mode -->
  <xsl:template mode="index" match="*|@*">
    <xsl:apply-templates mode="index" select="*|@*"/>
  </xsl:template>



  <!-- inspireThemes is a nodeset consisting of skos:Concept elements -->
  <!-- each containing a skos:definition and skos:prefLabel for each language -->
  <!-- This template finds the provided keyword in the skos:prefLabel elements and returns the English one from the same skos:Concept -->
  <xsl:template name="translateInspireThemeToEnglish">
    <xsl:param name="keyword"/>
    <xsl:param name="inspireThemes"/>
    <xsl:if test="$inspireThemes">
      <xsl:for-each select="$inspireThemes/skos:prefLabel">
        <!-- if this skos:Concept contains a kos:prefLabel with text value equal to keyword -->
        <xsl:if test="text() = $keyword">
          <xsl:value-of select="../skos:prefLabel[@xml:lang='en']/text()"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="findInspireThemeAcronym">
    <xsl:param name="keyword"/>
    <xsl:value-of select="$inspire-theme/skos:altLabel[../skos:prefLabel = $keyword]/text()"/>
  </xsl:template>

  <xsl:template name="findInspireAnnex">
    <xsl:param name="keyword"/>
    <xsl:param name="inspireThemes"/>
    <xsl:variable name="englishKeywordMixedCase">
      <xsl:call-template name="translateInspireThemeToEnglish">
        <xsl:with-param name="keyword" select="$keyword"/>
        <xsl:with-param name="inspireThemes" select="$inspireThemes"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="englishKeyword" select="lower-case($englishKeywordMixedCase)"/>
    <!-- Another option could be to add the annex info in the SKOS thesaurus using something
    like a related concept. -->
    <xsl:choose>
      <!-- annex i -->
      <xsl:when test="$englishKeyword='coordinate reference systems' or $englishKeyword='geographical grid systems'
                  or $englishKeyword='geographical names' or $englishKeyword='administrative units'
                  or $englishKeyword='addresses' or $englishKeyword='cadastral parcels'
                  or $englishKeyword='transport networks' or $englishKeyword='hydrography'
                  or $englishKeyword='protected sites'">
        <xsl:text>i</xsl:text>
      </xsl:when>
      <!-- annex ii -->
      <xsl:when test="$englishKeyword='elevation' or $englishKeyword='land cover'
                  or $englishKeyword='orthoimagery' or $englishKeyword='geology'">
        <xsl:text>ii</xsl:text>
      </xsl:when>
      <!-- annex iii -->
      <xsl:when test="$englishKeyword='statistical units' or $englishKeyword='buildings'
                  or $englishKeyword='soil' or $englishKeyword='land use'
                  or $englishKeyword='human health and safety' or $englishKeyword='utility and governmental services'
                  or $englishKeyword='environmental monitoring facilities' or $englishKeyword='production and industrial facilities'
                  or $englishKeyword='agricultural and aquaculture facilities' or $englishKeyword='population distribution — demography'
                  or $englishKeyword='area management/restriction/regulation zones and reporting units'
                  or $englishKeyword='natural risk zones' or $englishKeyword='atmospheric conditions'
                  or $englishKeyword='meteorological geographical features' or $englishKeyword='oceanographic geographical features'
                  or $englishKeyword='sea regions' or $englishKeyword='bio-geographical regions'
                  or $englishKeyword='habitats and biotopes' or $englishKeyword='species distribution'
                  or $englishKeyword='energy resources' or $englishKeyword='mineral resources'">
        <xsl:text>iii</xsl:text>
      </xsl:when>
      <!-- inspire annex cannot be established: leave empty -->
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
