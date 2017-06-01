# Geospatial User Feedback schema plugin

This is the Geospatial User Feedback (GUF) schema plugin for GeoNetwork 3.1.x or greater version.

## Reference documents:

* http://schemas.opengis.net/guf/1.0
 

## Description:

Schema can be used to describe structure of user feedback items on catalogue items.

This plugin is composed of:

* indexing
* editing (Angular editor only)
 * editor associated resources
 * directory support for contact, logo and format.
* viewing
* CSW
* from/to DUV conversion
* multilingual metadata support
* validation (XSD and Schematron)

## Metadata rules:

### Metadata identifier

The metadata identifier is stored in the element mdb:MD_Metadata/mdb:metadataIdentifier.
Only the code is set by default but more complete description may be defined (see authority,
codeSpace, version, description).

```
<guf:itemIdentifier>
<mcc:MD_Identifier>
<mcc:code>
<gco:CharacterString>GCL2000_feedack_item_1</gco:CharacterString>
</mcc:code>
</mcc:MD_Identifier>
</guf:itemIdentifier>
```


### Target metadata

The target metadata record is referenced using the following form from the editor:

```
<guf:GUF_FeedbackTarget>
<guf:resourceRef xlink:href="http://www-gvm.jrc.it/glc2000">
<cit:CI_Citation>
<cit:title/>
<cit:identifier>
<mcc:MD_Identifier>
<mcc:code>
<gco:CharacterString>GLC2000</gco:CharacterString>
</mcc:code>
<mcc:codeSpace>
<gco:CharacterString>jrc.ec.europa.eu</gco:CharacterString>
</mcc:codeSpace>
</mcc:MD_Identifier>
</cit:identifier>
</cit:CI_Citation>
</resourceRef>
</guf:GUF_FeedbackTarget>
```

Nevertheless, the citation code is also indexed.



### Validation



## CSW requests:

If requesting using output schema http://www.isotc211.org/2005/gmd an ISO19139 record is returned. 
To retrieve the record in ISO19115-3, use http://standards.iso.org/iso/19115/-3/mdb/1.0 output schema.
```
<?xml version="1.0"?>
<csw:GetRecordById xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
  service="CSW"
  version="2.0.2"
  outputSchema="http://standards.iso.org/iso/19115/-3/mdb/1.0">
    <csw:Id>cecd1ebf-719e-4b1f-b6a7-86c17ed02c62</csw:Id>
    <csw:ElementSetName>brief</csw:ElementSetName>
</csw:GetRecordById>
```
Note: outputSchema = own will also return the record in ISO19115-3.




## Installing the plugin

### GeoNetwork version to use with this plugin

This is an implementation of the latest XSD published by ISO-TC211. 
It'll not be supported in 2.10.x series so don't plug it into it!
Use GeoNetwork 3.0.3+ version.

### Adding the plugin to the source code

The best approach is to add the plugin as a submodule into GeoNetwork schema module.

```
cd schemas
git submodule add https://github.com/metadata101/iso19115-3.git iso19115-3
```

Add the new module to the schema/pom.xml:

```
  
  <module>iso19115-3</module>
  <module>guf</module>
</modules>
```

Add the dependency in the web module in web/pom.xml:

```
<dependency>
  <groupId>${project.groupId}</groupId>
  <artifactId>schema-iso19115-3</artifactId>
  <version>${project.version}</version>
</dependency>
```

Add the module to the webapp in web/pom.xml:

```
<execution>
  <id>copy-schemas</id>
  <phase>process-resources</phase>
  ...
  <resource>
    <directory>${project.basedir}/../schemas/GUF10/src/main/plugin</directory>
    <targetPath>${basedir}/src/main/webapp/WEB-INF/data/config/schema_plugins</targetPath>
  </resource>
```


Build the application.


### Adding editor configuration

Once the application started, check the plugin is loaded in the admin > standard page. 
Then in admin > Settings, add to metadata/editor/schemaConfig the editor configuration
for the schema:

```
"iso19115-3":{
  "defaultTab":"default",
  "displayToolTip":false,
  "related":{
    "display":true,
    "categories":[]},
  "suggestion":{"display":true},
  "validation":{"display":true}}
```


### Adding the conversion to the import record page

In https://github.com/geonetwork/core-geonetwork/tree/3.2.x/web/src/main/webapp/xsl/conversion/import, add the 19139 to 19115-3 conversion file https://github.com/metadata101/iso19115-3/blob/3.2.x/ISO19139-to-ISO19115-3.xsl.



## More work required

### Formatter


### GML support

Polygon or line editing and view.


## Community

Comments and questions to geonetwork-developers or geonetwork-users mailing lists.


## Contributors


* Paul van Genuchten (GeoCat)
* Jose Garcia (GeoCat)