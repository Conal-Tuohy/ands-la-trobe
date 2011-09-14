<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
<!--
<values>
	<Other>
		<ExtractionDate>2011-08-22T14:31:46+10:00</ExtractionDate>
		<RequestFrom>131.172.245.199</RequestFrom>
		<EPN>XPS-Ultra-10005</EPN>
	</Other>
	<logSheet>
		<Instrument>XPS-Ultra</Instrument>

		<JobNumber>XPS-Ultra-10005</JobNumber>
		<ProposalNumber>2011-04-11_10:54:40-XPS-md</ProposalNumber>
		<Clips></Clips>
		<Composition></Composition>
		<CompositionKV></CompositionKV>
		<ConstantHeightBar></ConstantHeightBar>
		<DepthProfiles></DepthProfiles>
		<EBeamHeater></EBeamHeater>

		<EBeamHeaterNumber></EBeamHeaterNumber>
		<fDay>20</fDay>
		<FlatBar></FlatBar>
		<FlatStub></FlatStub>
		<fMonth>5</fMonth>
		<fPressureY></fPressureY>
		<fPressureYY></fPressureYY>
		<Fracture></Fracture>

		<fTime>23:30</fTime>
		<fYear>2011</fYear>
		<Gas></Gas>
		<GeneralDescription></GeneralDescription>
		<HeatingCooling></HeatingCooling>
		<Images></Images>
		<InstrumentTimeHours>23</InstrumentTimeHours>

		<InstrumentTimeMinutes>30</InstrumentTimeMinutes>
		<LineScans></LineScans>
		<LoadLock></LoadLock>
		<LoadLockCooling></LoadLockCooling>
		<LoadLockCoolingT></LoadLockCoolingT>
		<LoadLockHeating></LoadLockHeating>
		<LoadLockHeatingT></LoadLockHeatingT>
		<Maps></Maps>

		<noSamples>2</noSamples>
		<operator></operator>
		<Other></Other>
		<OtherSampleTreatment></OtherSampleTreatment>
		<OtherSampleTreatmentText></OtherSampleTreatmentText>
		<OtherSelect></OtherSelect>
		<RecessedBar></RecessedBar>
		<RecessedStub></RecessedStub>

		<SAC></SAC>
		<SACCooling></SACCooling>
		<SACCoolingT></SACCoolingT>
		<SACHeating></SACHeating>
		<SACHeatingT></SACHeatingT>
		<Screws></Screws>
		<sDay>20</sDay>
		<sMonth>5</sMonth>

		<Spectra></Spectra>
		<sPressureY></sPressureY>
		<sPressureYY></sPressureYY>
		<sTime>00:00</sTime>
		<sYear>2011</sYear>
		<Tape></Tape>
		<depthprofilingtable>
			<profile>

				<value>1</value>
				<value>2</value>
				<value>3</value>
			</profile>
			<profile>
				<value>11</value>
				<value>22</value>

				<value>33</value>
			</profile>
		</depthprofilingtable>
		<sampletable>
			<sample>
				<id>sam1</id>
				<details>sample 1</details>

				<type>undivided solid</type>
			</sample>
			<sample>
				<id>sam2</id>
				<details>sample 2</details>
				<type>liquid/film</type>
			</sample>

		</sampletable>
		<xraytable>
			<set>
				<source>Al</source>
				<ImA>123</ImA>
				<VkV>456</VkV>
			</set>

			<set>
				<source>Mg</source>
				<ImA>112233</ImA>
				<VkV>445566</VkV>
			</set>
		</xraytable>
	</logSheet>

	<proposalRequest>
		<UsersUID>md</UsersUID>
		<RequestNumber>2011-04-11_10:54:40-XPS-md</RequestNumber>
		<date>2011-04-11</date>
		<technique>XPS</technique>
		<description></description>
		<numberofsamples>2</numberofsamples>

		<samples>
			<sample>
				<id>sam1</id>
				<details>sample 1</details>
				<type></type>			
			</sample>
			<sample>
				<id>sam2</id>

				<details>sample 2</details>
				<type></type>			
			</sample>
		</samples>
		<ultrahighvacuum></ultrahighvacuum>
		<magnetic></magnetic>
		<afteranalysis></afteranalysis>
		<hazardous></hazardous>
		<dangerous></dangerous>

		<analysis></analysis>
		<analysisby>user</analysisby>
		<accesspresent>no</accesspresent>
		<accesstype>local</accesstype>
		<users></users>
		<sapA></sapA>
		<sapB></sapB>

		<status>cancelled</status>
		<billing></billing>
		<jobcat></jobcat>
		<ASA></ASA>
		<Instrument>XPS-Ultra</Instrument>
		<teachingCourseCode></teachingCourseCode>
		<UsersName>Mr Michael DSilva</UsersName>

		<UsersInstitution>VeRSI</UsersInstitution>
		<UsersDepartment>Collaborative Cyberinfrastructure for Instrumentation</UsersDepartment>
		<UsersAddress>Street. Rob's office City. Latrobe uni State. VIC Postcode. 3083</UsersAddress>
		<UsersTelephone>(+614) 03-19-18-55</UsersTelephone>
		<UsersFax></UsersFax>
		<UsersEmail>michael.dsilva@versi.edu.au</UsersEmail>

	</proposalRequest>
	<MountPoint>/SAN/ltri/XPS-Ultra/archive/XPS-Ultra-10005</MountPoint>
</values>
-->

	<xsl:template match="values">
		<person xmlns="http://hdl.handle.net/102.100.100/6976">
			<name><xsl:value-of select="proposalRequest/UsersName"/></name>
			<department><xsl:value-of select="proposalRequest/UsersDepartment" /></department>
			<institution><xsl:value-of select="proposalRequest/UsersInstitution" /></institution>
			<dateOfBirth></dateOfBirth>
			<alternativeName></alternativeName>
			<abbreviatedName></abbreviatedName>
			<url></url>
			<email><xsl:value-of select="proposalRequest/UsersEmail" /></email>
			<phone><xsl:value-of select="proposalRequest/UsersTelephone" /></phone>
			<fax><xsl:value-of select="proposalRequest/UsersFax" /></fax>
			<otherElectronic type=""></otherElectronic>
			<postalAddress>
				<country></country>
				<postcode></postcode>
				<state></state>
				<text><xsl:value-of select="proposalRequest/UsersAddress" /></text>
			</postalAddress>
			<streetAddress>
				<country></country>
				<postcode></postcode>
				<state></state>
				<text><xsl:value-of select="proposalRequest/UsersAddress" /></text>
			</streetAddress>
			<briefDescription></briefDescription>
			<fullDescription></fullDescription>
			<relatedWebsite>
				<location></location>
				<title></title>
				<notes></notes>
			</relatedWebsite>
			<relatedPublication>
				<location></location>
				<title></title>
				<notes></notes>
			</relatedPublication>
		</person>
	</xsl:template>
	

</xsl:stylesheet>
