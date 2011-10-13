<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:f="info:fedora/fedora-system:def/foxml#"
	xmlns:vamas="http://hdl.handle.net/102.100.100/6919"
	xmlns:latrobe="http://hdl.handle.net/102.100.100/6976"
	xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
	exclude-result-prefixes="f vamas latrobe"
>

	<xsl:variable name="handle-datastream" select="/f:digitalObject/f:datastream[@ID='handle']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="vamas-datastream" select="/f:digitalObject/f:datastream[@ID='vamas-xml']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="surfacelab-datastream" select="/f:digitalObject/f:datastream[@ID='vamas-xml']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="dataset-datastream" select="/f:digitalObject/f:datastream[@ID='dataset']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="person-datastream" select="/f:digitalObject/f:datastream[@ID='person']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="group-datastream" select="/f:digitalObject/f:datastream[@ID='group']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<xsl:variable name="project-datastream" select="/f:digitalObject/f:datastream[@ID='project']/f:datastreamVersion[last()]/f:xmlContent/*"/>
	<!-- the "descriptive datastream" is whichever of the "dataset", "person", "group", or "project" datastreams is actually present-->
	<xsl:variable name="descriptive-datastream" select="$dataset-datastream | $person-datastream | $group-datastream | $project-datastream"/>
	
	<xsl:template match="/">
		<registryObjects 
			xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
			xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/1.2.0/schema/registryObjects.xsd">
			<registryObject group="La Trobe University">
				<key><xsl:value-of select="$handle-datastream//response/identifier/@handle"/></key>
				<originatingSource>http://andsdb-dc19-dev.latrobe.edu.au/</originatingSource>
				<xsl:apply-templates select="$descriptive-datastream"/>
			</registryObject>
		</registryObjects>
	</xsl:template>
	
	<xsl:template match="*"/>

	<xsl:template name="convert-descriptive-datastream-contents">
		<!-- some of these elements need to be wrapped in a rif-cs:location element -->
		<xsl:variable name="location-elements" select="
			*[normalize-space()]
			[
				self::latrobe:url|
				self::latrobe:email|
				self::latrobe:fax|
				self::latrobe:phone|
				self::latrobe:otherElectronic|
				self::latrobe:postalAddress|
				self::latrobe:streetAddress
			]"/>
		<xsl:variable name="non-location-elements" select="*[count(. | $location-elements) &gt; count($location-elements)][normalize-space()]"/>
		<xsl:apply-templates select="$non-location-elements"/>
		<location>
			<xsl:apply-templates select="$location-elements"/>
		</location>
	</xsl:template>
	
	<xsl:template match="latrobe:person">
		<party type="person">
			<xsl:call-template name="convert-descriptive-datastream-contents"/>
		</party>
	</xsl:template>

	<xsl:template match="latrobe:group">
		<party type="group">
			<xsl:call-template name="convert-descriptive-datastream-contents"/>
		</party>
	</xsl:template>

	<xsl:template match="latrobe:dataset">
		<collection type="dataset">
			<xsl:call-template name="convert-descriptive-datastream-contents"/>
		</collection>
	</xsl:template>

	<xsl:template match="latrobe:project">
		<activity type="project">
			<xsl:call-template name="convert-descriptive-datastream-contents"/>
		</activity>
	</xsl:template>
	
	
	<!-- name, department and institution make up a full "primary" name in rif-cs -->
	<!-- so when we match the <name> we can concatentate them -->
	<xsl:template match="latrobe:department | latrobe:institution"/>
	<xsl:template match="latrobe:name[normalize-space()]">
		<name type="primary">
			<namePart><xsl:apply-templates/><xsl:apply-templates select="latrobe:department"/><xsl:apply-templates select="latrobe:institution"/></namePart>
		</name>
	</xsl:template>
	
	<xsl:template match="latrobe:department[normalize-space()] | latrobe:institution[normalize-space()]" mode="within-name">
			<xsl:text>
</xsl:text><xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="latrobe:abbreviatedName[normalize-space()]">
		<name type="abbreviated">
			<namePart><xsl:apply-templates/></namePart>
		</name>
	</xsl:template>

	<xsl:template match="latrobe:url">	
		<address>
			<electronic type="url">
				<value><xsl:apply-templates/></value>
			</electronic>
		</address>
	</xsl:template>
			
	<xsl:template match="latrobe:email">	
		<address>
			<electronic type="email">
				<value><xsl:apply-templates/></value>
			</electronic>
		</address>
	</xsl:template>

	<xsl:template match="latrobe:fax">
			<address>
				<physical>
					<addressPart type="faxNumber"><xsl:apply-templates/></addressPart>
				</physical>
			</address>
	</xsl:template>
	
	<xsl:template match="latrobe:phone">
			<address>
				<physical>
					<addressPart type="telephoneNumber"><xsl:apply-templates/></addressPart>
				</physical>
			</address>
	</xsl:template>
	
	<xsl:template match="latrobe:postalAddress | latrobe:streetAddress">
			<address>
				<physical type="{local-name()}">
					<addressPart type="text"><xsl:apply-templates select="latrobe:text"/><xsl:apply-templates select="latrobe:state"/><xsl:apply-templates select="latrobe:postcode"/><xsl:apply-templates select="latrobe:country"/></addressPart>
				</physical>
			</address>
	</xsl:template>
	
	<!-- add line breaks to the end of each component of an address -->
	<xsl:template match="latrobe:text[normalize-space()] | latrobe:state[normalize-space()] | latrobe:postcode[normalize-space()] | latrobe:country[normalize-space()]"><xsl:apply-templates/><xsl:text>
</xsl:text></xsl:template>

	<xsl:template match="latrobe:briefDescription">
		<description type="brief"><xsl:apply-templates/></description>
	</xsl:template>
	
	<xsl:template match="latrobe:fullDescription">
		<description type="full"><xsl:apply-templates/></description>
	</xsl:template>
	

	<!-- relationships between RegistryObjects -->
	<xsl:template match="latrobe:hasMember|latrobe:hasCollector">
		<xsl:if test="normalize-space()">
			<!-- The @identifier is the local Fedora PID -->
			<!-- For RIF-CS, we use a handle, so we need to look up the "handle" datastream of the Fedora object identified by this PID -->
			<xsl:variable name="handle-datastream-uri" select="
				concat(
					'http://localhost:8080/fedora/objects/',
					substring-before(@id, ':'),
					'%3A',
					substring-after(@id, ':'),
					'/datastreams/handle/content'
				)
			"/>
			<!-- read the handle value from the datastream -->
			<xsl:variable name="handle" select="document($handle-datastream-uri)//identifier/@handle"/>
			<relatedObject>
				<key><xsl:value-of select="$handle"/></key>
				<relation type="{local-name()}"/>
			</relatedObject>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="latrobe:subject[normalize-space()]">
		<subject type="{@type}"><xsl:apply-templates/></subject>
	</xsl:template>
	
	<xsl:template match="latrobe:description[normalize-space()]">
		<description type="{@type}"><xsl:apply-templates/></description>
	</xsl:template>
	
	<xsl:template match="latrobe:relatedWebsite[latrobe:location][normalize-space()]">
		<relatedInfo>
			<identifier type="uri"><xsl:apply-templates select="latrobe:location"/></identifier>
			<xsl:apply-templates select="latrobe:title | latrobe:notes"/>
		</relatedInfo>
	</xsl:template>
	
	<xsl:template match="latrobe:title[normalize-space()]">
		<title><xsl:apply-templates/></title>
	</xsl:template>
	<xsl:template match="latrobe:notes[normalize-space()]">
		<notes><xsl:apply-templates/></notes>
	</xsl:template>

	
	<!-- for documentation purposes, here is a sample RIF-CS record -->
	<registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/1.2.0/schema/registryObjects.xsd">
		 <registryObject group="La Trobe University">
			  <key>latrobe:cmss</key>
			  <originatingSource>https://services.ands.org.au/sandbox/orca</originatingSource>
			  <party type="group">
					<name type="abbreviated">
						 <namePart>CMSS</namePart>
					</name>
					<name type="abbreviated">
						 <namePart>C.M.S.S.</namePart>
					</name>
					<name type="primary">
						 <namePart>Centre for Materials and Surface Science</namePart>
					</name>
					<location>
						 <address>
							  <electronic type="url">
									<value>http://www.latrobe.edu.au/surface/</value>
							  </electronic>
						 </address>
						 <address>
							  <electronic type="email">
									<value>cmss@latrobe.edu.au</value>
							  </electronic>
						 </address>
						 <address>
							  <physical>
									<addressPart type="faxNumber">+61-3-94791552</addressPart>
							  </physical>
						 </address>
						 <address>
							  <physical>
									<addressPart type="telephoneNumber">+61-3-94793031</addressPart>
							  </physical>
						 </address>
						 <address>
							  <physical type="postalAddress">
									<addressPart type="addressLine">Centre for Materials and Surface Science</addressPart>
									<addressPart type="addressLine">Department of Physics</addressPart>
									<addressPart type="addressLine">La Trobe University</addressPart>
									<addressPart type="addressLine">Victoria 3086</addressPart>
									<addressPart type="addressLine">Australia</addressPart>
							  </physical>
						 </address>
						 <address>
							  <physical type="streetAddress">
									<addressPart type="addressLine">Centre for Materials and Surface Science</addressPart>
									<addressPart type="addressLine">Room 303, Physical Sciences Building 1</addressPart>
									<addressPart type="addressLine">La Trobe University</addressPart>
									<addressPart type="addressLine">Kingsbury Drive</addressPart>
									<addressPart type="addressLine">Bundoora</addressPart>
									<addressPart type="addressLine">Victoria 3083</addressPart>
									<addressPart type="addressLine">Australia</addressPart>
							  </physical>
						 </address>
					</location>
					<relatedObject>
						 <key>latrobe:r.jones</key>
						 <relation type="hasMember"/>
					</relatedObject>
					<subject type="anzsrc-for">020406</subject>
					<subject type="anzsrc-for">030603</subject>
					<subject type="anzsrc-for">030301</subject>
					<description type="brief">The Centre for Materials and Surface Science is an interdisciplinary research centre involving staff from the departments of Physics, Chemistry, Electronic Engineering and Pharmacy.  CMSS research activities are predominantly within the areas of materials and surface science involving significant interaction with both local and international industrial and academic research organisations.</description>
					<relatedInfo>
						 <identifier type="uri">http://www.latrobe.edu.au/surface/contact.html</identifier>
					</relatedInfo>
					<relatedInfo>
						 <identifier type="uri">https://rli.latrobe.edu.au/index.php</identifier>
					</relatedInfo>
			  </party>
		 </registryObject>
	</registryObjects>
	
</xsl:stylesheet>
