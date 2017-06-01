/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

package org.fao.geonet.schema.GUF10;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.kernel.schema.*;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.jdom.filter.ElementFilter;
import org.jdom.xpath.XPath;


public class GUF10SchemaPlugin
        extends org.fao.geonet.kernel.schema.SchemaPlugin
        implements
                AssociatedResourcesSchemaPlugin,
                MultilingualSchemaPlugin,
                ExportablePlugin,
                ISOPlugin {
    public static final String IDENTIFIER = "GUF10";

    private static ImmutableSet<Namespace> allNamespaces;
    private static Map<String, Namespace> allTypenames;
    private static Map<String, String> allExportFormats;

    static {
        allNamespaces = ImmutableSet.<Namespace>builder()
                .add(GUF10Namespaces.GCO)
                .add(GUF10Namespaces.MDB)
                .add(GUF10Namespaces.MCC)
                .add(GUF10Namespaces.MRC)
                .add(GUF10Namespaces.MRL)
                .add(GUF10Namespaces.MRI)
                .add(GUF10Namespaces.SRV)
                .add(GUF10Namespaces.CIT)
                .add(GUF10Namespaces.GUF)
                .build();

        allTypenames = ImmutableMap.<String, Namespace>builder()
                .put("csw:Record", Namespace.getNamespace("csw", "http://www.opengis.net/cat/csw/2.0.2"))
                .put("guf:GUF_FeedbackItem", GUF10Namespaces.GUF)
                .build();

        //allExportFormats = ImmutableMap.<String, String>builder()
          //      .put("convert/ISO19139/toISO19139.xsl", "metadata-iso19139.xml")
            //    .build();
    }

    public GUF10SchemaPlugin() {
        super(IDENTIFIER, allNamespaces);
    }

    public Set<AssociatedResource> getAssociatedResourcesUUIDs(Element metadata) {
        String XPATH_FOR_AGGRGATIONINFO = "*//mri:associatedResource/*" +
                "[mri:metadataReference/@uuidref " +
                "and mri:initiativeType/mri:DS_InitiativeTypeCode/@codeListValue != '']";
        Set<AssociatedResource> listOfResources = new HashSet<AssociatedResource>();
        List<?> sibs = null;
        try {
            sibs = Xml
                    .selectNodes(
                            metadata,
                            XPATH_FOR_AGGRGATIONINFO,
                            allNamespaces.asList());


            for (Object o : sibs) {
                if (o instanceof Element) {
                    Element sib = (Element) o;
                    Element agId = (Element) sib.getChild("metadataReference", GUF10Namespaces.MRI);
                    // TODO: Reference may be defined in Citation identifier
                    String sibUuid = agId.getAttributeValue("uuidref");
                    String initType = sib.getChild("initiativeType", GUF10Namespaces.MRI)
                            .getChild("DS_InitiativeTypeCode", GUF10Namespaces.MRI)
                            .getAttributeValue("codeListValue");

                    AssociatedResource resource = new AssociatedResource(sibUuid, initType, "");
                    listOfResources.add(resource);
                }
            }
        } catch (JDOMException e) {
            e.printStackTrace();
        }
        return listOfResources;
    }

    @Override
    public Set<String> getAssociatedParentUUIDs(Element metadata) {
        ElementFilter elementFilter = new ElementFilter("parentMetadata", GUF10Namespaces.MDB);
        return Xml.filterElementValues(
                metadata,
                elementFilter,
                null, null,
                "uuidref");
    }

    public Set<String> getAssociatedDatasetUUIDs(Element metadata) {
        String XPATH_FOR_ASSOCIATEDDATASETS = "guf:target/guf:GUF_FeedbackTarget/guf:resourceRef/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code";

        Set<String> listOfDatasets = new HashSet<String>();
        List<?> sibs = null;
        try {
            sibs = Xml
                    .selectNodes(
                            metadata,
                            XPATH_FOR_ASSOCIATEDDATASETS,
                            allNamespaces.asList());


            for (Object o : sibs) {
                if (o instanceof Element) {
                    Element sib = (Element) o;
                    Element datasetIdEl = (Element) sib.getChild("CharacterString", GUF10Namespaces.GCO);

                    String datasetId = datasetIdEl.getText();

                    if (StringUtils.isNotEmpty(datasetId)) {
                        listOfDatasets.add(datasetId);
                    }
                }
            }
        } catch (JDOMException e) {
            e.printStackTrace();
        }
        return listOfDatasets;
    };

    public Set<String> getAssociatedFeatureCatalogueUUIDs (Element metadata) {
        // Feature catalog may also be embedded into the document
        // Or the citation of the feature catalog may contains a reference to it
        return getAttributeUuidrefValues(metadata, "featureCatalogueCitation", GUF10Namespaces.MRC);
    };
    public Set<String> getAssociatedSourceUUIDs (Element metadata) {
        return getAttributeUuidrefValues(metadata, "source", GUF10Namespaces.MRL);
    }

    private Set<String> getAttributeUuidrefValues(Element metadata, String tagName, Namespace namespace) {
        ElementFilter elementFilter = new ElementFilter(tagName, namespace);
        return Xml.filterElementValues(
                metadata,
                elementFilter,
                null, null,
                "uuidref");
    };


    @Override
    public List<Element> getTranslationForElement(Element element, String languageIdentifier) {
        final String path = ".//lan:LocalisedCharacterString" +
                "[@locale='#" + languageIdentifier + "']";
        try {
            XPath xpath = XPath.newInstance(path);
            @SuppressWarnings("unchecked")
            List<Element> matches = xpath.selectNodes(element);
            return matches;
        } catch (Exception e) {
            Log.debug(LOGGER_NAME, getIdentifier() + ": getTranslationForElement failed " +
                    "on element " + Xml.getString(element) +
                    " using XPath '" + path +
                    " Exception: " + e.getMessage());
        }
        return null;
    }

    /**
     *  Add a LocalisedCharacterString to an element. In ISO19139, the translation are
     *  stored gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString.
     *
     * <pre>
     * <cit:title xsi:type="lan:PT_FreeText_PropertyType">
     *    <gco:CharacterString>Template for Vector data</gco:CharacterString>
     *    <lan:PT_FreeText>
     *        <lan:textGroup>
     *            <lan:LocalisedCharacterString locale="#FRE">Modèle de données vectorielles en ISO19139 (multilingue)</lan:LocalisedCharacterString>
     *        </lan:textGroup>
     * </pre>
     *
     * @param element
     * @param languageIdentifier
     * @param value
     */
    @Override
    public void addTranslationToElement(Element element, String languageIdentifier, String value) {
        element.setAttribute("type", "lan:PT_FreeText_PropertyType",
                Namespace.getNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance"));

        // Create a new translation for the language
        Element langElem = new Element("LocalisedCharacterString", GUF10Namespaces.LAN);
        langElem.setAttribute("locale", "#" + languageIdentifier);
        langElem.setText(value);
        Element textGroupElement = new Element("textGroup", GUF10Namespaces.LAN);
        textGroupElement.addContent(langElem);

        // Get the PT_FreeText node where to insert the translation into
        Element freeTextElement = element.getChild("PT_FreeText", GUF10Namespaces.LAN);
        if (freeTextElement == null) {
            freeTextElement = new Element("PT_FreeText", GUF10Namespaces.LAN);
            element.addContent(freeTextElement);
        }
        freeTextElement.addContent(textGroupElement);
    }

    @Override
    public String getBasicTypeCharacterStringName() {
        return "gco:CharacterString";
    }

    @Override
    public Element createBasicTypeCharacterString() {
        return new Element("CharacterString", GUF10Namespaces.GCO);
    }

    @Override
    public Map<String, Namespace> getCswTypeNames() {
        return allTypenames;
    }

    @Override
    public Map<String, String> getExportFormats() {
        return allExportFormats;
    }
}
