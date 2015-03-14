# FOXML #

[Fedora Object XML (FOXML)](https://wiki.duraspace.org/display/FEDORA35/Fedora+Object+XML+%28FOXML%29) is a markup language for describing the content of a Fedora Object.

Each Fedora Object has a FOXML representation which includes all the XML datastreams in the object, and references all the non-XML datastreams by URI.

In the DC19 system, XProc pipelines commonly retrieve the FOXML record for an object as a quick way to aggregate all the XML datastreams the object contains.