<?xml version='1.0' encoding='UTF-8'?>

<!-- 
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 -->

<!-- 
  Simple transform of Solr query results to HTML
 -->
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml" 
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:my="http://hdl.handle.net/102.100.100/6976"
	xmlns:vamas="http://hdl.handle.net/102.100.100/6919"
	exclude-result-prefixes="oai_dc dc my">
	
	<xsl:output media-type="text/html; charset=UTF-8" encoding="UTF-8"/>
	
	
	<!-- utility template for find and replace in strings -->
	<xsl:template name="string-replace">
		<xsl:param name="string"/>
		<xsl:param name="find"/>
		<xsl:param name="replace"/>
		<xsl:choose>
			<xsl:when test="contains($string, $find)">
				<xsl:value-of select="substring-before($string, $find)"/>
				<xsl:value-of select="$replace"/>
				<xsl:call-template name="string-replace">
					<xsl:with-param name="string" select="substring-after($string, $find)"/>
					<xsl:with-param name="find" select="$find"/>
					<xsl:with-param name="replace" select="$replace"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- utility template to encode strings for use in URIs -->
	<xsl:template name="encode-for-uri">
		<xsl:param name="string"/>
		<xsl:call-template name="string-replace">
			<xsl:with-param name="string">
				<xsl:call-template name="string-replace">
					<xsl:with-param name="string" select="$string"/>
					<xsl:with-param name="find">/</xsl:with-param>
					<xsl:with-param name="replace">%2F</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="find">:</xsl:with-param>
			<xsl:with-param name="replace">%3A</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
 
	
	<xsl:template match="response[result/@numFound='0']">
		<!-- zero results returned -->
		<html>
			<head>
				<title>Welcome to the LaTrobe CMSS repository</title>
				<link rel="stylesheet" type="text/css" href="/css/solr.css"/>
			</head>
			<body>
				No result found.
			</body>
		</html>
		


	</xsl:template>

 
	
	<!-- Main template matching a response which contains just a single record - present a detailed page about the record -->
	<xsl:template match="response[result/@numFound='1']">
			<!-- templates to render elements from the person, group, dataset, and project datastreams -->
		<xsl:variable name="edit-uri" select="result/doc/str[@name='edit-uri']"/>
		<xsl:variable name="title" select="result/doc/arr[@name='title']/str"/>
		<xsl:variable name="handle" select="result/doc/str[@name='handle']"/>
		<xsl:variable name="metadata-stream-uri" select="result/doc/str[@name='metadata-stream-uri']" />
		<xsl:variable name="metadata-stream" select="document(concat('http://localhost',$metadata-stream-uri))/*" />
		<xsl:variable name="download-links" select="result/doc/arr[@name='datastream']/str"/>
		<html>
			<head>
				<title>
					<xsl:value-of select="$title"/> - CMSS</title>
				<link rel="stylesheet" type="text/css" href="/css/solr.css"/>
			</head>
			<body>
				<div class="container">
					<xsl:call-template name="template-header">
						<xsl:with-param name="title" select="$title" />
					</xsl:call-template>
					<div class="clear">
 
						<xsl:call-template name="sample-metadata">
							<xsl:with-param name="metadata-stream" select="$metadata-stream" />
						</xsl:call-template>
						<xsl:call-template name="description-metadata">
							<xsl:with-param name="metadata-stream" select="$metadata-stream" />
						</xsl:call-template>
            <xsl:call-template name="primary-metadata">
							<xsl:with-param name="metadata-stream" select="$metadata-stream" />
						</xsl:call-template>
						<xsl:call-template name="secondary-metadata">
							<xsl:with-param name="metadata-stream" select="$metadata-stream" />
						</xsl:call-template>
						
	
						<!-- plot vamas data using Google Charts -->
						<xsl:call-template name="vamas-graphs"/>
						
            <xsl:call-template name="citation">
							<xsl:with-param name="handle" select="$handle"/>
						</xsl:call-template>
						
						<xsl:if test="$download-links">
							<h2>Download data files</h2>
							<table class="downloads">
								<tr>
									<th>File</th>
									<th>File Type</th>
								</tr>
								<xsl:apply-templates select="$download-links" mode="download-link"/>
							</table>
						</xsl:if>
						<a href="{$edit-uri}">Edit</a>
					</div>
					<xsl:call-template name="template-footer" />
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="citation">
		<xsl:param name="handle"/>
		<xsl:if test="$handle[normalize-space()]">
			<h2>Citation</h2>
      <p>Use this URL to cite this <xsl:value-of select="result/doc/str[@name='type']"/>: <a href="{$handle}"><xsl:value-of select="$handle"/></a></p>
		</xsl:if>
	</xsl:template>

	
	<xsl:template match="str" mode="download-link">
		<!-- 
		expecting a quoted HTML hyperlink like:
		<a href="/fedora/objects/andsdb-dc19%3A160/datastreams/test/content" type="application/x-iontof-surfacelab-measurement">conal/test.itm</a>
		-->
		<!-- decode the hyperlink -->
		<xsl:variable name="type" select="substring-before(substring-after(., ' type=&quot;'), '&quot;')"/>
		<tr>
			<xsl:if test="position() mod 2"><xsl:attribute name="class">odd</xsl:attribute></xsl:if>
			<td><xsl:call-template name="unquote-hyperlink">
				<xsl:with-param name="quoted-hyperlink" select="normalize-space()"/>
			</xsl:call-template></td>
			<td><xsl:choose>
				<xsl:when test="$type='application/x-kratos-vision-dataset'"><a href="http://hdl.handle.net/102.100.100/6973">Kratos Vision 2 dataset</a></xsl:when>
				<xsl:when test="$type='chemical/x-vamas-iso14976'"><a href="http://www.iso.org/iso/iso_catalogue/catalogue_tc/catalogue_detail.htm?csnumber=24269">ISO-14976/VAMAS</a></xsl:when>
				<xsl:when test="$type='application/x-iontof-surfacelab-measurement'"><a href="http://hdl.handle.net/102.100.100/6972">SurfaceLab 6 Measurement</a></xsl:when>
				<xsl:otherwise>unknown</xsl:otherwise>
			</xsl:choose></td>
		</tr>
	</xsl:template>
	
	<!-- unquoting XHTML hyperlink -->
	<xsl:template name="unquote-hyperlink">
		<xsl:param name="quoted-hyperlink"/>
		<xsl:variable name="opening-tag-content" select="substring-before(substring-after($quoted-hyperlink, '&lt;'), '&gt;')"/>
		<xsl:variable name="element-name" select="substring-before(concat($opening-tag-content, ' '), ' ')"/>
		<xsl:variable name="attributes" select="normalize-space(substring-after($opening-tag-content, $element-name))"/>
		<xsl:variable name="text-content" select="substring-before(substring-after($quoted-hyperlink, '&gt;'), '&lt;')"/>
		<xsl:element name="{$element-name}">
			<xsl:call-template name="create-attributes">
				<xsl:with-param name="attributes" select="$attributes"/>
			</xsl:call-template>
			<xsl:value-of select="$text-content"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="create-attributes">
		<xsl:param name="attributes"/>
		<xsl:if test="$attributes">
			<xsl:variable name="first-attribute-name" select="normalize-space(substring-before($attributes, '='))"/>
			<xsl:variable name="first-attribute-value" select="substring-before(substring-after($attributes, '&quot;'), '&quot;')"/>
			<xsl:attribute name="{$first-attribute-name}">
				<xsl:value-of select="$first-attribute-value"/>
			</xsl:attribute>
			<xsl:variable name="remaining-attributes" select="normalize-space(substring-after(substring-after($attributes, '&quot;'), '&quot;'))"/>
			<xsl:call-template name="create-attributes">
				<xsl:with-param name="attributes" select="$remaining-attributes"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!--assembly -->
	
	<!-- header  -->
	<xsl:template name="template-header">
		<xsl:param name="title" />
		<div class="header">
			<div class="lhs">
				<a href="http://www.latrobe.edu.au/">
					<img src="/xforms/images/latrobe_university.gif" />
				</a>
			</div>
			<div class="topnavbar">
				<ul>
					<li>
						<a href="/index.html">CMSS Repository Search</a>
					</li>
					<li>
						<a href="http://www.latrobe.edu.au/home">La‌ Trobe‌ Home</a>
					</li>
					<li>
						<a href="http://www.latrobe.edu.au/eresearch/">e-Research</a>
					</li>
					<li>
						<a href="http://www.latrobe.edu.au/surface/">CMSS‌ Home</a>
					</li>
					<li>
						<a href="https://rli.latrobe.edu.au/index.php">RLI‌ Home</a>
					</li>
				</ul>
			</div>
			<div class="textjustify automargin lpad">
				<h2>
					<xsl:value-of select="$title" /><br /><br />
				</h2>
			</div>
		</div>

	
	</xsl:template>

	<!-- end header -->

	<!-- footer -->
	
	<xsl:template name="template-footer">
		<div class="footer padded">
			<div class="lhs">
				<a href="http://www.latrobe.edu.au/surface/">
					<img src="/xforms/images/cmss_logo.gif" />
				</a>
			</div>
			<div class="rhs padded">
				<a href="http://versi.edu.au/">
					<img src="/xforms/images/VeRSI.gif" />
				</a>
			</div>
		</div>
		<xsl:variable name="encoded-identifier">
			<xsl:call-template name="encode-for-uri">
				<xsl:with-param name="string" select="lst[@name='responseHeader']/lst[@name='params']/str[@name='q']"/>
			</xsl:call-template>
		</xsl:variable>
		<div class="debug">
			<a href="?q={$encoded-identifier}&amp;wt=xml">raw results</a>
		</div>
	</xsl:template>

	<!-- end footer -->
	
	<!-- pagination -->
	<xsl:template name="pagination">
		
		
		<xsl:variable name="rows" select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='rows']" />
		<xsl:variable name="start" select="/response/result/@start" />
		<xsl:variable name="numFound" select="/response/result/@numFound" />
		<xsl:variable name="q" select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='q']" />
		
		<xsl:variable name="not-on-first-page" select="($numFound > $rows) and ($start > $rows)"/>
		<xsl:variable name="previous-pages-exist" select="($numFound > $rows) and ($start > 0 )"/>
		<xsl:variable name="subsequent-pages-exist" select="($numFound mod $rows) = 0"/>
		<xsl:variable name="not-on-last-page" select="(($numFound mod $rows) !=0) and (($start + $rows) &lt; ($numFound))"/>
		
		<div class="pagination">
		
		<!-- QAZ TODO -->

			<div class="button" id="first"><div class="spacer">.</div>
				<xsl:if test="($numFound > $rows) and ($start > $rows)"><!-- if numFound > rows and start > rows  -->		    	
					<a href="?q={$q}&amp;rows={$rows}">&lt;&lt;</a>
				</xsl:if>
			</div>
			<div class="button" id="prev"><div class="spacer">.</div><!-- if numFound > rows and start > 0 -->
				<xsl:if test="($numFound > $rows) and ($start > 0 )">
					<a href="?q={$q}&amp;start={$start - $rows}&amp;rows={$rows}">&lt;</a>
				</xsl:if>
			</div>
			<div class="button" id="next"><div class="spacer">.</div><!-- if start + rows < numFound -->
				<xsl:if test="($start + $rows) &lt; $numFound">
					<a href="?q={$q}&amp;start={$start + $rows}&amp;rows={$rows}">&gt;</a>
				</xsl:if>
			</div>
			<div class="button" id="last"><div class="spacer">.</div><!-- if start + rows < numFound (plus special case for ($numFound mod $rows) == 0 ) -->
				<xsl:if test="(($numFound &gt; 0) and ($numFound mod $rows) = 0)">
					<a href="?q={$q}&amp;start={$numFound - $rows}&amp;rows={$rows}">&gt;&gt;</a>
				</xsl:if>
				<xsl:if test="(($numFound mod $rows) != 0) and (($start + $rows) &lt; ($numFound))">
					<a href="?q={$q}&amp;start={$numFound - ($numFound mod $rows)}&amp;rows={$rows}">&gt;&gt;</a>
				</xsl:if>
			</div>
		</div>

	</xsl:template>
	<!-- pagination -->
	
	<xsl:template name="primary-metadata"> <!-- Display primary record data for person, dataset, group and project -->
		<xsl:param name="metadata-stream" />
		<xsl:for-each select="$metadata-stream">
			<xsl:for-each select="my:department[normalize-space()]">
				<div>
					<b>Department: </b>
					<xsl:value-of select="."/>
				</div>
			</xsl:for-each>
			
			<xsl:for-each select="my:institution[normalize-space()]">
				<div>
					<b>Institution: </b>
					<xsl:value-of select="."/>
				</div>
			</xsl:for-each>
			
			<xsl:for-each select="my:dateOfBirth[normalize-space()]">
				<div>
					<b>Date Of birth: </b>
					<xsl:value-of select="."/>
				</div>
			</xsl:for-each>
			
			<xsl:for-each select="my:startDate[normalize-space()]">
				<div>
					<b>Date: </b>
					<xsl:value-of select="."/>
				</div>
			</xsl:for-each>
			
			<xsl:for-each select="my:email[normalize-space()]">
				<div>
					<b>email: </b>
					<xsl:value-of select="."/>
				</div>
			</xsl:for-each>
			
			<xsl:for-each select="my:phone[normalize-space()]">
				<div>
					<b>phone: </b>
					<xsl:value-of select="."/>
				</div>
			</xsl:for-each>
			
			<xsl:for-each select="my:fax[normalize-space()]">
				<div>
					<b>fax: </b>
					<xsl:value-of select="."/>
				</div>
			</xsl:for-each>
			
			<xsl:for-each select="my:url[normalize-space()]">
				<div>
					<b>Primary Webpage: </b>
					<a href="{.}">
						<xsl:value-of select="."/>
					</a>
				</div>
			</xsl:for-each>
			
			<xsl:for-each select="streetAddress">
				<div class="address">
					<b>Street Address </b>
					<br />
					<xsl:value-of select="my:text" />
					<br />
					<xsl:value-of select="my:state" />
					<xsl:text></xsl:text>
					<xsl:value-of select="my:postcode" />
					<xsl:text></xsl:text>
					<xsl:value-of select="my:country" />
				</div>
				<br />
			</xsl:for-each>
			
			<xsl:for-each select="postalAddress">
				<div class="address">
					<b>Postal Address </b>
					<br />
					<xsl:value-of select="my:text" />
					<br />
					<xsl:value-of select="my:state" />
					<xsl:text></xsl:text>
					<xsl:value-of select="my:postcode" />
					<xsl:text></xsl:text>
					<xsl:value-of select="my:country" />
				</div>
				<br />
			</xsl:for-each>
			
			<xsl:for-each select="my:otherElectronic[normalize-space()]">
				<div>
					<b>
						<xsl:value-of select="@type"/>: </b>
					<xsl:value-of select="."/>
				</div>
			</xsl:for-each>
		
		</xsl:for-each>
	</xsl:template>
	
	<!-- for default searchHandler --><!-- 
	<xsl:template name="render-link-to-object">
		<xsl:param name="object"/>
				<xsl:variable name="encoded-id">
					<xsl:call-template name="string-replace">
						<xsl:with-param name="string">
							<xsl:call-template name="encode-for-uri">
								<xsl:with-param name="string" select="@id"/>
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="find">%3A</xsl:with-param>
						<xsl:with-param name="replace">\%3A</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<a href="?q=id%3A{$encoded-id}"><xsl:value-of select="." /></a>
				<br />
	</xsl:template>
	-->

	<!-- for Dismax  -->
	<xsl:template name="render-link-to-object">
		<xsl:param name="object"/>
				<xsl:variable name="encoded-id">
					<xsl:with-param name="string">
						<xsl:call-template name="encode-for-uri">
							<xsl:with-param name="string" select="@id"/>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:variable>
				<a href="?q=&quot;{$encoded-id}&quot;"><xsl:value-of select="." /></a>
				<br />
	</xsl:template>

	<xsl:template name="vamas-graphs">
		<xsl:variable name="vamas-xml-streams" select="result/doc/arr[@name='vamas-xml']/str"/>
		<xsl:if test="$vamas-xml-streams">
			<!-- load Google Charts javascript -->
			<h2>Spectral graphs</h2>
			<script type="text/javascript" src="https://www.google.com/jsapi">//</script>
			<!-- define chart-plotting code -->
			<!-- on page load, Google will call our callback function 'drawCharts', which will then -->
			<!-- call the individual chart-drawing functions called "drawChartXXXX', where XXXX is -->
			<!-- a generated identifier for each VAMAS dataset -->
			<script type="text/javascript">
				google.load("visualization", "1", {packages:["corechart"]});
				google.setOnLoadCallback(drawCharts);
				function drawCharts() {
					<xsl:for-each select="$vamas-xml-streams">
						<xsl:variable name="vamas-id" select="generate-id(.)"/>
						drawChartsFromVamasFile<xsl:value-of select="$vamas-id"/>();
					</xsl:for-each>
				}
			</script>
				
			<!-- define each of the "drawChartXXXX" functions -->
			<xsl:for-each select="$vamas-xml-streams">

				<xsl:variable name="vamas-id" select="generate-id(.)"/>
				<!-- read the vamas-xml from Fedora -->
				<xsl:variable name="vamas-xml" select="document(concat('http://localhost', .))"/>
				<xsl:variable name="file-title" select="substring-before(substring-after(., '/datastreams/'), '-xml/content')"/>
				<xsl:variable name="blocks" select="$vamas-xml/vamas:dataset/vamas:block"/>
				<script type="text/javascript">
					 function nsResolver(prefix) {  
						var ns = {  
						  'xhtml' : 'http://www.w3.org/1999/xhtml',  
						  'svg': 'http://www.w3.org/2000/svg'  
						};  
						return ns[prefix] || null;  
					 }  
					function drawChartsFromVamasFile<xsl:value-of select="$vamas-id"/>() {
					<xsl:for-each select="$blocks">
						<xsl:variable name="chart-id" select="generate-id(.)"/>
						drawChart<xsl:value-of select="$chart-id"/>();
					</xsl:for-each>
					}
				</script>
				<h4><xsl:value-of select="$file-title"/></h4>
				
				<!-- create the html div elements into which the Google Chart javascript will insert the charts -->
				<!-- and within the div, insert the javascript to do the drawing -->
				<xsl:for-each select="$blocks">
					<xsl:variable name="block" select="."/>
					<xsl:variable name="chart-id" select="generate-id(.)"/>
					<div id="{$chart-id}">
						<xsl:variable name="chart-title" select="$block/vamas:blockIdentifier"/>
						<!--<xsl:variable name="abscissa-increment" select="$block/vamas:signalCollectionTime"/>-->
						<xsl:variable name="abscissa-label" select="$block/vamas:abscissaLabel"/>
						<xsl:variable name="abscissa-units" select="$block/vamas:abscissaUnits"/>
						<xsl:variable name="abscissa-increment" select="number($block/vamas:abscissaIncrement)"/>
						<xsl:variable name="abscissa-start" select="number($block/vamas:abscissaStart)"/>
						<xsl:variable name="analysis-source-characteristic-energy" select="number($block/vamas:analysisSourceCharacteristicEnergy)"/>

						<script type="text/javascript">
						function tweakChart<xsl:value-of select="$chart-id"/>() {
							// This function is called when the chart is ready.
							// This is where we remove font-style="italic" attributes from the svg:text elements
							// representing the charts axes.
							if (document["evaluate"]) {
								// browser supports DOM3 "evaluate" function for evaluating xpaths
								var chartDiv = document.getElementById("<xsl:value-of select="$chart-id"/>");
								var iframe = chartDiv.firstChild;
								var frameDocument = (iframe.contentWindow || iframe.contentDocument).document;
								var italicElements = frameDocument.evaluate(".//*[@font-style='italic']", frameDocument, nsResolver, 4, null);
								var axis1 = italicElements.iterateNext();
								var axis2 = italicElements.iterateNext();
								if (axis1) {
									axis1.removeAttribute("font-style");
								}
								if (axis2) {
									axis2.removeAttribute("font-style");
								}
							}
						}
						function drawChart<xsl:value-of select="$chart-id"/>() {
						  var d = new google.visualization.DataTable();
						  <!-- add a method to plot co-ordinates (helps to compress the javascript below -->
						  d.p = function(index, x, y) {
							this.setValue(index, 0, x);
							this.setValue(index, 1, y);
						}
						<!-- plotting only the first variable -->
						  <xsl:variable name="corresponding-variable" select="$block/vamas:correspondingVariable[1]"/>
						  <xsl:variable name="maximum" select="$corresponding-variable/vamas:maximum"/>
						  <xsl:variable name="ordinate-unit-exponent" select="string-length($maximum) - 1"/>
						  <xsl:variable name="ordinate-scalar" select="substring('100000000', 1, $ordinate-unit-exponent + 1)"/>
						  <xsl:variable name="number-of-points" select="count($block/vamas:ordinateValues/vamas:correspondingVariables)"/>
						  d.addColumn('string', '<xsl:value-of select="concat($abscissa-label, ' (', $abscissa-units, ')')"/>');
						  d.addColumn('number', '<xsl:value-of select="$corresponding-variable/vamas:label"/>');
						  d.addRows(<xsl:value-of select="$number-of-points"/>);
						  <xsl:for-each select="$block/vamas:ordinateValues/vamas:correspondingVariables">
							<xsl:variable name="index" select="position() - 1"/>
							<xsl:text>d.p(</xsl:text>
							<xsl:value-of select="$index"/>
							<xsl:text>,'</xsl:text>
							<xsl:value-of select="
								format-number(
									$analysis-source-characteristic-energy - (
										$abscissa-start + 
										$index * $abscissa-increment
									), 
									'#'
								)
							"/>
							<xsl:text>',</xsl:text>
							<xsl:value-of select="vamas:variable div $ordinate-scalar"/>
							<xsl:text>);&#xA;</xsl:text>
						  </xsl:for-each>
						  
						  <!-- create a Google LineChart object for drawing a chart into a named div element (defined below) -->
						  var chartDiv = document.getElementById('<xsl:value-of select="$chart-id"/>');
						  var chart = new google.visualization.LineChart(chartDiv);
						  google.visualization.events.addListener(chart, "ready", tweakChart<xsl:value-of select="$chart-id"/>);
						  <!-- draw the data onto chart, specifying various formatting attributes -->
						  chart.draw(
							d, 
							{
								width: 750, 
								height: 500, 
								hAxis: {
									titleTextStyle: {
										fontSize: 20
									},
									title: 'Binding Energy (<xsl:value-of select="$abscissa-units"/>)',
									slantedText: false,
									maxAlternation: 1,
									showTextEvery: <xsl:value-of select="floor(($number-of-points - 1) div 5)"/>
								},
								vAxis: {
									titleTextStyle: {
										fontSize: 20
									},
									title: '<xsl:value-of select="concat(
										$block/vamas:correspondingVariable/vamas:label,
										' (10 ',
										translate($ordinate-unit-exponent, '0123456789', '⁰¹²³⁴⁵⁶⁷⁸⁹'),
										' counts/s)'
									)"/>'
								},
								legend: 'none',
								title: '<xsl:value-of select="$chart-title"/>'
							  }
						  );
						}
					</script>
				</div>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:if>	
	</xsl:template>
	
	<xsl:template name="secondary-metadata">	<!--Links to related info, extended data, graphs & representations, etc-->
		<xsl:param name="metadata-stream" />
		
		<xsl:for-each select="$metadata-stream">
			<xsl:if test="my:hasMember">
				<h3>Member List</h3>
			</xsl:if>
			<xsl:if test="my:hasCollector">
				<h3>Collector List</h3>
			</xsl:if>
			
			<xsl:for-each select="my:hasMember">
				<xsl:call-template name="render-link-to-object">
					<xsl:with-param name="object" select="."/>
				</xsl:call-template>
			</xsl:for-each>
			
			<xsl:for-each select="my:hasCollector">
				<xsl:call-template name="render-link-to-object">
					<xsl:with-param name="object" select="."/>
				</xsl:call-template>
			</xsl:for-each>
			
			<xsl:if test="my:relatedWebsite[normalize-space()]">
				<h3>Related Links</h3>
			</xsl:if>
			
			<xsl:for-each select="my:relatedWebsite[normalize-space()]">
				<div>
					<b>
						<a href="{my:location}">
							<xsl:value-of select="my:title" />
						</a>
					</b>: <xsl:value-of select="my:notes" />
				</div>
			</xsl:for-each>
			
			<xsl:if test="my:relatedPublication[normalize-space()]">
				<h3>Related Publications</h3>
			</xsl:if>
			
			<xsl:for-each select="my:relatedPublication[normalize-space()]">
				<div>
					<b>
						<a href="{my:location}">
							<xsl:value-of select="my:title" />
						</a>
					</b>: <xsl:value-of select="my:notes" />
				</div>
			</xsl:for-each>
			
			<xsl:if test="my:subject">
				<h3>Associated Subject Types</h3>
			</xsl:if>
			
			<xsl:for-each select="my:subject">
				<b>type: </b>
				<xsl:value-of select="@type" />
				<b> code: </b>
				<xsl:value-of select="." />
				<br />
			</xsl:for-each>
		
		</xsl:for-each>

</xsl:template>

<xsl:template name="description-metadata">
	<xsl:param name="metadata-stream" />
	<div class="center" id="descbox">
		<xsl:for-each select="$metadata-stream">
			<xsl:for-each select="my:briefDescription[normalize-space()]">
				<div class="description">
					<h4>Summary</h4>
					<div class="">
						<xsl:value-of select="."/>
					</div>
				</div>
			</xsl:for-each>
				
			<xsl:for-each select="my:fullDescription[normalize-space()]">
				<div class="description">
					<h4>Complete Description</h4>
					<div class="">
						<xsl:call-template name="line-feeds-to-paragraphs"/>
					</div>
				</div>
			</xsl:for-each>
		</xsl:for-each>
	</div>
</xsl:template>

	<!-- info on samples  -->

<xsl:template name="sample-metadata">
	<xsl:param name="metadata-stream" />
	<xsl:if test="$metadata-stream/my:sample[normalize-space()]">
		<div><h3>Sample Data</h3>
			<xsl:for-each select="$metadata-stream/my:sample">
				<xsl:if test="my:name[normalize-space()]">
					<b>Name: </b> <xsl:value-of select="my:name[normalize-space()]" /><br />
				</xsl:if>	
				<xsl:if test="my:id[normalize-space()]">
					<b>Sample ID: </b> <xsl:value-of select="my:id[normalize-space()]" /><br />
				</xsl:if>	
				<xsl:if test="my:cas[normalize-space()]">
					<b>CAS ID: </b> <xsl:value-of select="my:cas[normalize-space()]" /><br />
				</xsl:if>	
				<xsl:if test="my:dimensions[normalize-space()]">
					<b>Dimensions: </b> <xsl:value-of select="my:dimensions[normalize-space()]" /><br />
				</xsl:if>
				<xsl:if test="my:supplier[normalize-space()]">
					<b>Supplier: </b> <xsl:value-of select="my:supplier[normalize-space()]" /><br />
				</xsl:if>	
				<xsl:if test="my:supplierCode[normalize-space()]">
					<b>Supplier ID: </b> <xsl:value-of select="my:supplierCode[normalize-space()]" /><br />
				</xsl:if>	
				<xsl:if test="my:purity[normalize-space()]">
					<b>Purity: </b> <xsl:value-of select="my:purity[normalize-space()]" /><br />
				</xsl:if>	
				<xsl:if test="my:typicalAnalysis[normalize-space()]">
					<b>Typical Analysis: </b> <xsl:value-of select="my:typicalAnalysis[normalize-space()]" /><br />
				</xsl:if>	
				<xsl:if test="my:prep[normalize-space()]">
					<b>Preparation: </b> <xsl:value-of select="my:prep[normalize-space()]" /><br />
				</xsl:if>	
				<xsl:if test="my:additionalNotes[normalize-space()]">
					<b>Additional Notes: </b> <xsl:value-of select="my:additionalNotes[normalize-space()]" /><br />
				</xsl:if>	

			</xsl:for-each>
		</div>
	</xsl:if>
</xsl:template>
	
	<!-- not just a single result - this should return a list of hits -->
	<!-- (what follows is the original generic Solr results handler) -->
<xsl:template match="response[not(result/@numFound='1')]">
	<xsl:variable name="title" select="concat('CMSS search results (',result/@numFound,' documents)')"/>
	<html>
		<head>
			<title>
				<xsl:value-of select="$title"/>
			</title>
			<link rel="stylesheet" type="text/css" href="/css/solr.css"/>
			
		</head>
		<body>
			<div class="container">
					
				<xsl:call-template name="template-header">
					<xsl:with-param name="title" select="$title" />
				</xsl:call-template>
					
					<!-- <xsl:apply-templates select="result/doc"/> -->
					
				<xsl:call-template name="result-list" />
					
				<xsl:call-template name="pagination" />
					
				<xsl:call-template name="template-footer" />
			</div>
		</body>
	</html>
</xsl:template>

	<!-- fix this! -->
 	
	
<xsl:template name="result-list">
	<xsl:for-each select="result/doc">
					
		<div class="doc">
			<table width="100%">
				<xsl:if test="arr[@name='title']">
					<tr>
						<td class="name">Title</td>
						<td class="value">
							<xsl:for-each select="arr[@name='title']/str">
								<xsl:value-of select="."/>
								<br />
							</xsl:for-each>
						</td>
					</tr>
				</xsl:if>
				<xsl:if test="str[@name='type']">
					<tr>
						<td class="name">Record type</td>
						<td class="value">
							<xsl:value-of select="str[@name='type']" />
						</td>
					</tr>
				</xsl:if>
				<xsl:if test="str[@name='instrument_model']">
					<tr>
						<td class="name">Instrument model</td>
						<td class="value">
							<xsl:value-of select="str[@name='instrument_model']" />
						</td>
					</tr>
				</xsl:if>
				<xsl:if test="arr[@name='technique']">
					<tr>
						<td class="name">Techniques used</td>
						<td class="value">
							<xsl:for-each select="arr[@name='technique']/str">
								<xsl:value-of select="."/>
								<br />
							</xsl:for-each>
						</td>
					</tr>
				</xsl:if>
				<tr>
					<td></td>
					<td>
						<!-- <xsl:variable name="full-record-link">
							<xsl:choose>
								<xsl:when test="str[@name='handle'][normalize-space()]">
									<xsl:value-of select="str[@name='handle']" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat()" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable> -->
						<a href="{str[@name='handle']}">view full record</a>
					</td>
				</tr>
					
			</table>
		</div>
	</xsl:for-each>
</xsl:template>
	
	
<xsl:template match="doc">
	<xsl:variable name="pos" select="position()"/>
	<div class="doc">
		<table width="100%">
			<xsl:apply-templates>
				<xsl:with-param name="pos">
					<xsl:value-of select="$pos"/>
				</xsl:with-param>
			</xsl:apply-templates>
		</table>
	</div>
</xsl:template>
	
<xsl:template match="doc/*[@name='score']" priority="100">
	<xsl:param name="pos"></xsl:param>
	<tr>
		<td class="name">
			<xsl:value-of select="@name"/>
		</td>
		<td class="value">
			<xsl:value-of select="."/>
				
			<xsl:if test="boolean(//lst[@name='explain'])">
				<xsl:element name="a">
            <!-- can't allow whitespace here -->
					<xsl:attribute name="href">javascript:toggle("<xsl:value-of select="concat('exp-',$pos)" />");</xsl:attribute>?</xsl:element>
				<br/>
				<xsl:element name="div">
					<xsl:attribute name="class">exp</xsl:attribute>
					<xsl:attribute name="id">
						<xsl:value-of select="concat('exp-',$pos)" />
					</xsl:attribute>
					<xsl:value-of select="//lst[@name='explain']/str[position()=$pos]"/>
				</xsl:element>
			</xsl:if>
		</td>
	</tr>
</xsl:template>
	
<xsl:template match="doc/arr" priority="100">
		 <!-- <xsl:if test="boolean(not(result/doc/arr[@name='datastream']))"> -->
	<tr>
		<td class="name">
			<xsl:value-of select="@name"/>
		</td>
		<td class="value">
			<ul>
				<xsl:for-each select="*">
					<li>
						<xsl:value-of select="."/>
					</li>
				</xsl:for-each>
			</ul>
		</td>
	</tr>
		<!-- </xsl:if> -->
</xsl:template>

	
<xsl:template match="doc/*">
		
	<tr>
		<td class="name">
			<xsl:value-of select="@name"/>
		</td>
		<td class="value">
			<xsl:value-of select="."/>
		</td>
	</tr>
	
</xsl:template>
	
	
	<!-- handle line breaks in text -->
<xsl:template name="line-feeds-to-paragraphs">
	<xsl:param name="text" select="."/>
	<xsl:variable name="lf" select="'&#xA;'"/>
	<xsl:choose>
		<xsl:when test="contains($text, $lf)">
			<xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
				<xsl:value-of select="substring-before($text, $lf)"/>
			</xsl:element>
			<xsl:call-template name="line-feeds-to-paragraphs">
				<xsl:with-param name="text" select="substring-after($text, $lf)"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
				<xsl:value-of select="$text"/>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
	
<xsl:template match="*"/>
	
<xsl:template name="css">
	<script>
      function toggle(id) {
        var obj = document.getElementById(id);
        obj.style.display = (obj.style.display != 'block') ? 'block' : 'none';
      }
    </script>
	<style type="text/css">
      body { font-family: "Lucida Grande", sans-serif }
      td.name { font-style: italic; font-size:80%; }
      td { vertical-align: top; }
      ul { margin: 0px; margin-left: 1em; padding: 0px; }
      .note { font-size:80%; }
      .doc { margin-top: 1em; border-top: solid grey 1px; }
      .exp { display: none; font-family: monospace; white-space: pre; }
    </style>
</xsl:template>
</xsl:stylesheet>
