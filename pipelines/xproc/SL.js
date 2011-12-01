var objFSO = WScript.CreateObject("Scripting.FileSystemObject");

//worst case, the stream we are updating should be blank to avoid false data. 
//Creating temp.xml here and overwriting the previous file should guarantee that.
objFSO.CreateTextFile('C:\\temp\\temp.xml', true);
var objDM = WScript.CreateObject("IONTOF.DataManager");
var objITMStream = WScript.CreateObject("ADODB.Stream");
// to contain the XML output, with a Byte Order Mark, because that's how MS likes to write unicode text
var objXMLBOMStream = WScript.CreateObject("ADODB.Stream");
// to contain the XML output, without a BOM, because Calabash's XML parser doesn't like BOMs
var objXMLStream = WScript.CreateObject("ADODB.Stream");
var objXMLHTTP = WScript.CreateObject("MSXML2.XMLHTTP.6.0");
var itmURI = WScript.Arguments.Item(0);
var username = WScript.Arguments.Item(1);
var password = WScript.Arguments.Item(2);

var tempFileLoc = "C:\\temp\\temp.itm";

objXMLHTTP.open("GET", itmURI, false, username, password);
objXMLHTTP.send();
while(objXMLHTTP.Status < 200) {
	WScript.sleep(60);
}
objITMStream.Open();
objITMStream.type = 1;
objITMStream.Write(objXMLHTTP.ResponseBody);
objITMStream.Position = 0;

if(objFSO.Fileexists(tempFileLoc)){
	objFSO.DeleteFile(tempFileLoc);
}

objITMStream.saveToFile(tempFileLoc);
objITMStream.Close();

var objTemp = objDM.loadMeasurement(tempFileLoc);
var data = objTemp.Header;
var properties = new Enumerator(data);
//<?xml version='1.0' encoding='ISO-8859-1'?>\n
var output = "<values xmlns='http://hdl.handle.net/102.100.100/6929'>\n";
for (properties.moveFirst(); !properties.atEnd(); properties.moveNext()) {
	var property = properties.item();
	output += "\t<" + property.name + ">" + property.StringValue.replace(/\x00/g, "\t").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;") + "</" + property.name + ">\n";
}

output += "</values>";

//WScript.StdOut.WriteLine(output);

// 2 means it's a "text" stream
objXMLBOMStream.Type = 2;
objXMLBOMStream.Charset='UTF-8';
objXMLBOMStream.Open();

// This is the binary stream which we use to create a BOM-less XML file
// 1 means it's a binary stream
objXMLStream.Type = 1;
objXMLStream.Open();

objXMLBOMStream.writeText(output);
// skip past the BOM
objXMLBOMStream.Position = 3;
objXMLBOMStream.copyTo(objXMLStream);
objXMLStream.saveToFile('C:\\temp\\temp.xml', 2);
objXMLBOMStream.close();
objXMLStream.close();
objFSO.DeleteFile(tempFileLoc);

