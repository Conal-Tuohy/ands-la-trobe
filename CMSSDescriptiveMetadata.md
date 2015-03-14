# Introduction #

Here is a list of schema used by the DC19 CMSS system. Note that these are not the authoritative schema files. Those are located [here](http://code.google.com/p/ands-la-trobe/source/browse/#svn%2Ftrunk%2Fxforms).

### LTU dataset ###
```
<dataset xmlns="http://hdl.handle.net/102.100.100/6976">
    <hasCollector id="" /> 
    <hasCollector id="" />
    <abbreviatedName />
    <name />
    <otherElectronic type="" />
    <otherElectronic type="" />
    <startDate />
    <endDate />
    <subject type="anzsrc-for" code="020406" />
    <subject type="anzsrc-for" code="030603" />
    <subject type="anzsrc-for" code="030301" />
    <subject type="local" code="" />
    <briefDescription />
    <fullDescription />
    <sample>
            <name />
            <id />
            <cas />
            <dimensions />
            <supplier />
            <supplierCode />
            <purity />
            <typicalAnalysis />
            <prep />
            <additionalNotes />
    </sample>
    <sample>
            <name />
            <id />
            <cas />
            <dimensions />
            <supplier />
            <supplierCode />
            <purity />
            <typicalAnalysis />
            <prep />
            <additionalNotes />
    </sample>
    <relatedWebsite />
        <location />
        <title />
        <notes />
    </relatedWebsite>
    <relatedWebsite>
        <location />
        <title />
        <notes />
    </relatedWebsite>
    <relatedPublication>
        <location />
        <title />
        <notes />
    </relatedPublication>
    <relatedPublication>
        <location />
        <title />
        <notes />
    </relatedPublication>
</dataset>
```

### Notes ###



&lt;hasCollector id="" /&gt;


  * Values: Collector's name (plaintext), @id: fedora entry pid
  * Sources: RLI booking system, @id: fedora internal



&lt;subject type="" code="" /&gt;


  * Values: Name of subject (plaintext), @type: classification index/type (e.g ICHI, CAS, etc) @code: lookup code
  * Sources: Some added autmoatically on ingest, based on submission source (e.g machine type)


### LTU group ###
```
<group xmlns="http://hdl.handle.net/102.100.100/6976">
    <nlaPartyIdentifier />
    <institution />
    <department />
    <abbreviatedName />
    <name />
    <url />
    <email />
    <fax />
    <phone />
    <otherElectronic type="" />
    <startDate />
    <endDate />
    <postalAddress>
            <text />
            <state />
            <postcode />
            <country />
    </postalAddress>
    <streetAddress>
            <text />
            <state />
            <postcode />
            <country />
    </streetAddress>
    <hasMember id="" />
    <hasMember id="" />
    <subject type="anzsrc-for" code="020406" />
    <subject type="anzsrc-for" code="030603" />
    <subject type="anzsrc-for" code="030301" />
    <subject type="local" code="" />
    <briefDescription />
    <fullDescription />
    <relatedWebsite>
            <location />
            <title />
            <notes />
    </relatedWebsite>
    <relatedWebsite>
            <location />
            <title />
            <notes />
    </relatedWebsite>
    <relatedPublication>
            <location />
            <title />
            <notes />
    </relatedPublication>
    <relatedPublication>
            <location />
            <title />
            <notes />
    </relatedPublication>
</group>
```

### Notes ###



&lt;hasMember id="" /&gt;


> See dataset/hasCollector



&lt;subject type="" code="" /&gt;


> See dataset/subject

### LTU project ###
```
<project xmlns="http://hdl.handle.net/102.100.100/6976">
    <institution />
    <department />
    <alternativeName />
    <alternativeName />
    <abbreviatedName />
    <name />
    <url />
    <email />
    <otherElectronic type="" />
    <startDate />
    <endDate />
    <postalAddress>
        <text />
        <country />
        <postcode />
        <state />
    </postalAddress>
    <streetAddress>
        <text />
        <country />
        <postcode />
        <state />
    </streetAddress>
    <hasMember id="aslasdf" />
    <hasMember id="aslasdf2" />
    <subject type="anzsrc-for" code="020406" />
    <subject type="anzsrc-for" code="030603" />
    <subject type="anzsrc-for" code="030301" />
    <subject type="local" code="plastic film" />
    <briefDescription />
    <fullDescription />
    <relatedWebsite>
        <location />
        <title />
        <notes />
    </relatedWebsite>
    <relatedWebsite>
        <location />
        <title />
        <notes />
    </relatedWebsite>
    <relatedPublication>
        <location />
        <title />
        <notes />
    </relatedPublication>
    <relatedPublication>
        <location />
        <title />
        <notes />
    </relatedPublication>
</project>
```

### Notes ###



&lt;hasMember id="" /&gt;


> See dataset/hasCollector



&lt;subject type="" code="" /&gt;


> See dataset/subject

### LTU person ###
```
<person xmlns="http://hdl.handle.net/102.100.100/6976">
    <nlaPartyIdentifier />
    <institution />
    <department />
    <name />
    <abbreviatedName />
    <url />
    <dateOfBirth />
    <email />
    <phone />
    <fax />
    <postalAddress>
        <text />
        <country />
        <postcode />
        <state />
    </postalAddress>
    <briefDescription />
    <fullDescription />
    <relatedWebsite>
        <location />
        <title />
        <notes />
    </relatedWebsite>
    <relatedWebsite>
        <location />
        <title />
        <notes />
    </relatedWebsite>
    <relatedPublication>
        <location />
        <title />
        <notes />
    </relatedPublication>
    <relatedPublication>
        <location />
        <title />
        <notes />
    </relatedPublication>
</person>
```

### Notes ###



&lt;hasMember id="" /&gt;


> See dataset/hasCollector



&lt;subject type="" code="" /&gt;


> See dataset/subject