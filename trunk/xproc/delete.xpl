<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            name="main" version="1.0">

	<p:option name="username" required="true"/>
	<p:option name="password" required="true"/>
	<p:option name="uri" required="true"/>
	
	<p:in-scope-names name="variables"/>
	
	<p:template>
	  <p:input port="template">
		 <p:inline exclude-inline-prefixes="c">
			<c:request detailed="true" method="DELETE" href="{$uri}" auth-method="Basic"
						  username="{$username}" password="{$password}">
             <c:header name="Accept" value="text/xml"/>
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
	<p:http-request/>
</p:pipeline>

