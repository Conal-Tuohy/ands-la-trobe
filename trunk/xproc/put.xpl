<p:pipeline xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" name="main" version="1.0">

	<p:option name="username" required="true"/>
	<p:option name="password" required="true"/>
	<p:option name="uri" required="true"/>

	<p:in-scope-names name="variables"/>

	<!-- 
		construct an XProc http request document
		by taking "uri", "username" and "password"
		parameters and substituting them into a
		template
	--> 
	<p:template>
		<p:input port="template">
			<p:inline exclude-inline-prefixes="c">
				<c:request detailed="true" method="PUT" href="{$uri}" auth-method="Basic" username="{$username}" password="{$password}">
					<c:header name="Accept" value="text/xml"/>
					<c:body content-type="text/xml">{/*}</c:body>
				</c:request>
			</p:inline>
		</p:input>
		<p:input port="source">
			<p:pipe step="main" port="source"/>
		</p:input>
		<p:input port="parameters">
			<p:pipe step="variables" port="result"/>
		</p:input>
	</p:template>
	
	<!-- execute the request -->
	<p:http-request/>
	
</p:pipeline>

