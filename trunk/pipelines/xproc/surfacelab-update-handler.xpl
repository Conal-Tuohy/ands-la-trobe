<p:declare-step name="main" version="1.0" 
	xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:lib="http://code.google.com/p/ands-la-trobe/wiki/XProcLibrary">
	
	<p:import href="library.xpl"/>
	
	<p:input port="source"/>
	<p:output port="result"/>
	
	<p:option name="fedora-username"/>
	<p:option name="fedora-password"/>
	
	<p:variable name="auth-method" select=" 'Basic' "/>
	<p:variable name="method" select="/atom:entry/atom:title[@type='text']"/>
	<p:variable name="alt-id" select="/atom:entry/atom:category[@scheme='fedora-types:altIDs']/@term"/>
	<p:variable name="datastream" select="/atom:entry/atom:category[@scheme='fedora-types:dsID']/@term"/>
	<p:variable name="identifier" select="/atom:entry/atom:summary[@type='text']"/>
	<p:variable name="uri-encoded-identifier" select="fn:encode-for-uri($identifier)"/> 
<!--
	<p:variable name="fedora-base-uri" select="/atom:entry/atom:author/atom:uri"/>
-->
	<p:variable name="fedora-base-uri" select="'http://andsdb-dc19-dev.latrobe.edu.au/fedora/'"/>	
	<p:variable name="item-base-uri" select="concat($fedora-base-uri, 'objects/', $uri-encoded-identifier)"/>
	<p:variable name="uri" select="concat($item-base-uri, '/datastreams/surfacelab-xml')"/>
	<!--
	methods:
		"purgeObject", "purgeDatastream" (delete)
		"modifyDatastreamByValue", "modifyDatastreamByReference" (update)
		"ingest" (create)
	-->


<!--

TODO

Problem is that we don't know the file name necessarily. Maybe we should just normalise the file name or type on ingest? 
Then we wouldn't have to download datastream metadata every time to tell if the modified datastream is a SurfaceLab6 file.

It's possible to change the Internet Media Type of a datastream with a PUT to a URL like this one:
http://andsdb-dc19-dev.latrobe.edu.au/fedora/objects/andsdb-dc19%3A9/datastreams/ITM?ignoreContent=true&altIDs=itm&mimeType=application/vnd.iontof.surfacelab6.itm

<entry xmlns="http://www.w3.org/2005/Atom" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:fedora-types="http://www.fedora.info/definitions/1/0/types/">
  <id>urn:uuid:783a7100-4133-4ffd-bed3-d65cf295e512</id>
  <updated>2011-08-19T09:24:11.661Z</updated>
  <author>
    <name>fedoraAdmin</name>
    <uri>http://andsdb-dc19-dev.latrobe.edu.au:8080/fedora</uri> 
  </author>
  <title type="text">modifyDatastreamByReference</title>
  <category term="andsdb-dc19:9" scheme="fedora-types:pid" label="xsd:string"/>
  <category term="ITM" scheme="fedora-types:dsID" label="xsd:string"/>
  <category term="itm" scheme="fedora-types:altIDs" label="fedora-types:ArrayOfString"/>
  <category term="null" scheme="fedora-types:dsLabel" label="xsd:string"/>
  <category term="null" scheme="fedora-types:formatURI" label="xsd:string"/>
  <category term="null" scheme="fedora-types:dsLocation" label="xsd:string"/>
  <category term="null" scheme="fedora-types:checksumType" label="xsd:string"/>
  <category term="null" scheme="fedora-types:checksum" label="xsd:string"/>
  <category term="null" scheme="fedora-types:logMessage" label="xsd:string"/>
  <summary type="text">andsdb-dc19:9</summary>
  <content type="text">2011-08-19T09:24:11.66Z</content>
  <category term="3.4.2" scheme="info:fedora/fedora-system:def/view#version"/>
  <category term="info:fedora/fedora-system:ATOM-APIM-1.0" scheme="http://www.fedora.info/definitions/1/0/types/formatURI"/>
</entry>

The ITM file is the one with the altIds="surfacelab-itm". NB This value will have been assigned to it by the ingest handler:
	The ingest handler will have downloaded the FoxML of the new record and identified this stream as the one whose @LABEL ends in ".itm":
	/foxml:digitalObject/foxml:datastream[foxml:datastreamVersion[last()][substring(@LABEL, string-length(@LABEL) - 3) = '.itm']

Check if that's the datastream which has changed
Construct the content URI for that datastream
Pass it to the SurfaceLab VBScript running under MS cscript.exe
Take the output of the script and save it to Fedora

-->


	<p:choose>
		<!-- if the event is an ingested object, or a modified ITM datastream ... -->
		<p:when test="($alt-id='surfacelab-itm')">
			
			<!-- execute a bash script to download the VAMAS file from Fedora and run the (Java) XML converter over it -->

			<p:exec name="download-surfacelab-itm-and-convert-to-xml" command="C:\Windows\SysWOW64\cscript.exe" result-is-xml="false">
				<!-- This is crucial! the CScript program is not reading from its standard input stream, so we should make sure we don't try to send it anything -->
				<p:input port="source">
					<p:empty/>
				</p:input>
				<p:with-option name="args" select="concat('C:\XML\Calabash\Pipelines\SL.js ', $item-base-uri, '/datastreams/', $datastream, '/content ', $fedora-username, ' ', $fedora-password, ' //nologo //b')"/>
			</p:exec>
			
			<p:load name='load-temp-textfile' href="C:\temp\temp.xml" /> 
		
			<!-- put the surfacelab-xml stream back into fedora -->
			<lib:fedora-save-datastream name="save-surfacelab-xml">
				<p:with-option name="username" select="$fedora-username"/>
				<p:with-option name="password" select="$fedora-password"/>
				<p:with-option name="uri" select="concat($item-base-uri, '/datastreams/surfacelab-xml')"/>
			</lib:fedora-save-datastream>
		</p:when>
		<p:otherwise>
			<!-- it's not an ingest or the update of a surfacelab datastream -->
			<p:identity name="ignoring-message"/>
		</p:otherwise>
	</p:choose>

</p:declare-step>