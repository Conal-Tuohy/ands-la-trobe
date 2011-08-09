<p:library version="1.0" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:lib="http://code.google.com/p/ands-la-trobe/wiki/XProcLibrary">
	
		<!-- 
			Execute an HTTP request.
			
			Constructs an XProc http request document
			by taking "method", "uri", "username" and "password"
			parameters and substituting them into a
			template, then executes the request
		-->
	<p:declare-step type="lib:http-request" name="http-request">
		
		<p:input port="source"/>
		<p:output port="result"/>
		
		<p:option name="method" required="true"/>
		<p:option name="username" required="true"/>
		<p:option name="password" required="true"/>
		<p:option name="uri" required="true"/>
		
		<p:in-scope-names name="variables"/>
		
		<p:choose name="choose-method">
			<p:when test="$method = 'get' or $method='head'">
				<p:template name="construct-request-document">
					<p:input port="template">
						<p:inline exclude-inline-prefixes="c">
							<c:request detailed="true" method="{$method}" href="{$uri}" auth-method="Basic" username="{$username}" password="{$password}">
								<c:header name="Accept" value="text/xml"/>
							</c:request>
						</p:inline>
					</p:input>
					<p:input port="source">
						<p:pipe step="http-request" port="source"/>
					</p:input>
					<p:input port="parameters">
						<p:pipe step="variables" port="result"/>
					</p:input>
				</p:template>
			</p:when>
			<p:otherwise><!-- put or post allow a message body -->
				<p:template name="construct-request-document">
					<p:input port="template">
						<p:inline exclude-inline-prefixes="c">
							<c:request detailed="true" method="{$method}" href="{$uri}" auth-method="Basic" username="{$username}" password="{$password}">
								<c:header name="Accept" value="text/xml"/>
								<c:body content-type="text/xml">{/*}</c:body>
							</c:request>
						</p:inline>
					</p:input>
					<p:input port="source">
						<p:pipe step="http-request" port="source"/>
					</p:input>
					<p:input port="parameters">
						<p:pipe step="variables" port="result"/>
					</p:input>
				</p:template>
			</p:otherwise>
		</p:choose>
		<!-- execute the request -->
		<p:http-request name="execute-request"/>
	
	</p:declare-step>

</p:library>
