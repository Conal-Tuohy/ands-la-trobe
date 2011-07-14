/*  Simple parser for ISO14976 VAMAS format. Converts to XML.
    Copyright (C) 2011, Daniel Tosello & Conal Tuohy

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package vamasparser;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.Reader;
import java.net.URL;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.SimpleTimeZone;
import java.util.TimeZone;
import java.util.Vector;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
//import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.TransformerHandler;
import javax.xml.transform.sax.SAXTransformerFactory;
import javax.xml.transform.stream.StreamResult;
import org.xml.sax.ContentHandler;
import org.xml.sax.DTDHandler;
import org.xml.sax.EntityResolver;
import org.xml.sax.ErrorHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXNotRecognizedException;
import org.xml.sax.SAXNotSupportedException;
import org.xml.sax.XMLReader;

/**
 *
 * @author DTosello, CTuohy
 */
public class VAMASParser implements XMLReader {

    // The VAMAS-XML namespace
    final static String ns = "http://hdl.handle.net/102.100.100/6919";
    
    private ContentHandler handler = null;
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args){
        // TODO generate usage message if run without a parameter
        try {
            // The SAXTransformerFactory is a factory for transformers. Here we get the default factory.
            SAXTransformerFactory tf = (SAXTransformerFactory) SAXTransformerFactory.newInstance();
            // We ask the factory for an "identity" transformer that will simply pass our
            // SAX event stream to the result stream unchanged.
            TransformerHandler handler = tf.newTransformerHandler();
            // configure the TransformerHandler's Transformer (setting output properties)
            Transformer transformer = handler.getTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            // We tell the handler to write the result to the standard output stream.
            handler.setResult(new StreamResult(System.out));
            // We createa  parser and tell it to use the handler defined above.
            VAMASParser parser = new VAMASParser();
            parser.setContentHandler(handler);
            // Finally we parse the file indicated on the command line.
            // The SAX events which the parser produces will be identity-transformed and 
            // sent to the output stream 
            parser.parse(args[0]);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean getFeature(String name) throws SAXNotRecognizedException, SAXNotSupportedException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public void setFeature(String name, boolean value) throws SAXNotRecognizedException, SAXNotSupportedException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public Object getProperty(String name) throws SAXNotRecognizedException, SAXNotSupportedException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public void setProperty(String name, Object value) throws SAXNotRecognizedException, SAXNotSupportedException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public void setEntityResolver(EntityResolver resolver) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public EntityResolver getEntityResolver() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public void setDTDHandler(DTDHandler handler) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public DTDHandler getDTDHandler() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public void setContentHandler(ContentHandler handler) {
        this.handler = handler;
    }

    @Override
    public ContentHandler getContentHandler() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public void setErrorHandler(ErrorHandler handler) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public ErrorHandler getErrorHandler() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public void parse(InputSource input) throws IOException, SAXException {
        InputStream byteStream = input.getByteStream();
        Reader reader = new InputStreamReader(byteStream);
        LineNumberReader lineReader = new LineNumberReader(reader);
        // read the first line
        String line = lineReader.readLine();
        // keep reading past any blank lines
        while ("".equals(line))  {
            line = lineReader.readLine();
        }
        handler.startDocument();
        startElement("dataset");
        element("format", line); 
        element("institution", lineReader.readLine());
        element("instrumentModel", lineReader.readLine());
        element("operator", lineReader.readLine());
        element("experiment", lineReader.readLine());
        int numberOfComments = Integer.parseInt(lineReader.readLine());
        if (numberOfComments > 0) {
            startElement("comment");
            for (int i = 1; i <= numberOfComments; i++) {
                characters(lineReader.readLine());
                characters("\n");
            }
            endElement("comment");
        }
        String experimentMode = lineReader.readLine();
        element("experimentMode", experimentMode);
        String scanMode = lineReader.readLine();
        element("scanMode", scanMode);
        // Number of spectral regions only specified for experiment modes
        // MAP, MAPDP, NORM, or SDP
        if ("MAP".equals(experimentMode) || 
            "MAPDP".equals(experimentMode) || 
            "NORM".equals(experimentMode) ||
            "SDP".equals(experimentMode)) {
            element("numberOfSpectralRegions", lineReader.readLine());
        }
        // number of analysis positions, discrete x, and y coords only
        // specified for experiment modes MAP and MAPDP
        if ("MAP".equals(experimentMode) || "MAPDP".equals(experimentMode)) {
            element("numberOfAnalysisPositions", lineReader.readLine());
            element("numberOfDiscreteXCoordinates", lineReader.readLine());
            element("numberOfDiscreteYCoordinates", lineReader.readLine());
        }
        int numberOfExperimentalVariables = Integer.parseInt(lineReader.readLine());
        Vector<String> EVlabel = new Vector<String>();
        Vector<String> EVunit = new Vector<String>();
        for (int i = 1; i <= numberOfExperimentalVariables; i++) {
            EVlabel.add(lineReader.readLine());
            EVunit.add(lineReader.readLine());    
        }
        String shouldBeZero = lineReader.readLine();
        if (!shouldBeZero.equals("0")) {
           int errorLine = lineReader.getLineNumber() - 1;
            throw new SAXException(
               new ParseException(
                   "Error reading VAMAS file; expected '0', read '" + shouldBeZero + "' at line " + String.valueOf(errorLine), 
                   errorLine
               )
            );
        }
       
        
        int numberOfManuallyEnteredItems = Integer.parseInt(lineReader.readLine());
        Vector<String> manuallyEnteredItems = new Vector<String>();
        for (int i = 1; i <= numberOfManuallyEnteredItems; i++) {
            manuallyEnteredItems.add(lineReader.readLine());             
        }
        
        int numberOfFutureExperimentUpgradeEntries = Integer.parseInt(lineReader.readLine());
        int numberOfFutureUpgradeBlockEntries = Integer.parseInt(lineReader.readLine());
        
        if(numberOfFutureExperimentUpgradeEntries > 0) { 
            startElement("futureExperimentUpgradeEntries");
            for (int i = 1; i <= numberOfFutureExperimentUpgradeEntries; i++){
                element("entry", lineReader.readLine());
                
            }
            endElement("futureExperimentUpgradeEntries"); 
            
        }
        
        int numberOfBlocks = Integer.parseInt(lineReader.readLine());
        
        for( int i = 0; i < numberOfBlocks; i++){
            startElement("block");
            element("blockIdentifier", lineReader.readLine());
            element("sampleIdentifier", lineReader.readLine());
            
            // date
            int year = readInt(lineReader);
            int month = readInt(lineReader) - 1;
            int day = readInt(lineReader);
            int hours = readInt(lineReader);
            int minutes = readInt(lineReader);
            int seconds = readInt(lineReader);
            float gmtOffset = readFloat(lineReader); // e.g. -2.5
            
            TimeZone tz = new SimpleTimeZone(0, "GMT");
            //tz.setRawOffset((int) (gmtOffset * 1000 * 60 * 60));
            /*
            element("year", String.valueOf(year));
            element("month", String.valueOf(month));
            element("day", String.valueOf(day));
            element("hours", String.valueOf(hours));
            element("minutes", String.valueOf(minutes));
            element("seconds", String.valueOf(seconds));
            element("offset", String.valueOf(gmtOffset));
            */
            
            Calendar date = new GregorianCalendar(tz);
            date.set(year, month, day, hours, minutes, seconds);
            SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ");
            element("date", format.format(date.getTime()));

            // read multiple line comment
            numberOfComments = Integer.parseInt(lineReader.readLine());
            if (numberOfComments > 0) {
                startElement("comment");
                for (int j = 1; j <= numberOfComments; j++) {
                    characters(lineReader.readLine());
                    characters("\n");
                }
                endElement("comment");
            }
            
            String technique = lineReader.readLine();
            element("technique", technique);
            
            if ("MAP".equals(experimentMode) || "MAPDP".equals(experimentMode)){
                element("xCoordinate", lineReader.readLine());
                element("yCoordinate", lineReader.readLine());
            }
            
            // experimental variables
            if (numberOfExperimentalVariables > 0) {
                for (int j = 0; j < numberOfExperimentalVariables; j++) {
                    startElement("experimentalVariable");
                    element("label", EVlabel.get(j));
                    element("unit", EVunit.get(j));
                    element("value", lineReader.readLine());
                    endElement("experimentalVariable");
                }
            }
            
            element("analysisSourceLabel", lineReader.readLine());
            if (
                (
                    "MAPDP".equals(experimentMode) || 
                    "MAPSVDP".equals(experimentMode) ||
                    "SDP".equals(experimentMode) ||
                    "SDPSV".equals(experimentMode)
                ) || (
                    "FABMS".equals(technique) ||
                    "FABMS energy spec".equals(technique) ||
                    "ISS".equals(technique) ||
                    "SIMS".equals(technique) ||
                    "SIMS energy spec".equals(technique) ||
                    "SNMS".equals(technique) ||
                    "SNMS energy spec".equals(technique)
                )   
            )
            {
                element("sputteringIonOrAtomAtomicNumber", lineReader.readLine());
                element("numberOfAtomsInSputteringIonOrAtomParticle", lineReader.readLine());
                element("sputteringIonOrAtomChangeSignAndNumber", lineReader.readLine());
            }
            
            element("analysisSourceCharacteristicEnergy", lineReader.readLine());
            element("analysisSourceStrength", lineReader.readLine());
            element("analysisSourceBeamWidthX", lineReader.readLine());
            element("analysisSourceBeamWidthY", lineReader.readLine());
            
            if (
                    "MAP".equals(experimentMode) || 
                    "MAPDP".equals(experimentMode) || 
                    "MAPSV".equals(experimentMode) ||
                    "MAPSVDP".equals(experimentMode) ||
                    "SEM".equals(experimentMode)
            ) {
                element("fieldOfViewX", lineReader.readLine());
                element("fieldOfViewY", lineReader.readLine());
            }
            
            if (
                    "MAPSV".equals(experimentMode) ||
                    "MAPSVDP".equals(experimentMode) ||
                    "SEM".equals(experimentMode)
            ) {
                element("firstLineScanStartXCoordinate", lineReader.readLine());
                element("firstLineScanStartYCoordinate", lineReader.readLine());
                element("firstLineScanFinishXCoordinate", lineReader.readLine());
                element("firstLineScanFinishYCoordinate", lineReader.readLine());
                element("lastLineScanFinishXCoordinate", lineReader.readLine());
                element("lastLineScanFinishYCoordinate", lineReader.readLine());
            }
            
            element("analysisSourcePolarAngleOfIncidence", lineReader.readLine());
            element("analysisSourceAzimuth", lineReader.readLine());
            element("analyserMode", lineReader.readLine());
            element("analyserPassEnergyOrRetardRatioOrMassResolution", lineReader.readLine());
            if ("AES diff".equals(technique)) {
                element("differentialWidth", lineReader.readLine());
            }
            element("magnificationOfAnalyserTransferLens", lineReader.readLine());
            // QAZ semantics of next element depends on technique
            element("analyserWorkFunctionOrAcceptanceEnergyOfAtomOrIon", lineReader.readLine());
            
            element("targetBias", lineReader.readLine());
            element("analysisWidthX", lineReader.readLine());
            element("analysisWidthY", lineReader.readLine());
            element("analyserAxisTakeOffPolarAngle", lineReader.readLine());
            element("analyserAxisTakeOffAzimuth", lineReader.readLine());
            element("speciesLabel", lineReader.readLine());
            element("transitionOrStateChangeLabel", lineReader.readLine());
            element("chargeOfDetectedParticle", lineReader.readLine());
            if ("REGULAR".equals(scanMode)) {
                element("abscissaLabel", lineReader.readLine());
                element("abscissaUnits", lineReader.readLine());
                element("abscissaStart", lineReader.readLine());
                element("abscissaIncrement", lineReader.readLine());
            }
            int numberOfCorrespondingVariables = readInt(lineReader);
            Vector<String> correspondingVariableLabels = new Vector<String>();
            Vector<String> correspondingVariableUnits = new Vector<String>();
            for (int j=1; j <= numberOfCorrespondingVariables; j++) {
                correspondingVariableLabels.add(lineReader.readLine());
                correspondingVariableUnits.add(lineReader.readLine());
            }
            element("signalMode", lineReader.readLine());
            element("signalCollectionTime", lineReader.readLine());
            element("numberOfScansToCompileThisBlock", lineReader.readLine());
            element("signalTimeCorrection", lineReader.readLine());
            
            if (
                    (
                        "AES diff".equals(technique) ||
                        "AES dir".equals(technique) ||
                        "EDX".equals(technique) ||
                        "ELS".equals(technique) ||
                        "UPS".equals(technique) ||
                        "XPS".equals(technique) ||
                        "XRF".equals(technique)
                    ) &&
                    (
                        "MAPDP".equals(experimentMode) ||
                        "MAPSVDP".equals(experimentMode) ||
                        "SDP".equals(experimentMode) ||
                        "SDPSV".equals(experimentMode)
                    )
            ) {
                element("sputteringSourceEnergy", lineReader.readLine());
                element("sputteringSourceBeamCurrent", lineReader.readLine());
                element("sputteringSourceWidthX", lineReader.readLine());
                element("sputteringSourceWidthY", lineReader.readLine());
                element("sputteringSourcePolarAngleOfIncidence", lineReader.readLine());
                element("sputteringSourceAzimuth", lineReader.readLine());
                element("sputteringMode", lineReader.readLine());
            }
            element("sampleNormalPolarAngleOfTilt", lineReader.readLine());
            element("sampleNormalTiltAzimuth", lineReader.readLine());
            element("sampleRotationAngle", lineReader.readLine());
            int numberOfAdditionalNumericalParameters = readInt(lineReader);
            for (int j = 1; j <= numberOfAdditionalNumericalParameters; j++) {
                startElement("additionalNumericalParameter");
                element("label", lineReader.readLine());
                element("units", lineReader.readLine());
                element("value", lineReader.readLine());
                endElement("additionalNumericalParameter");
            }
            for (int j = 1; j <= numberOfFutureUpgradeBlockEntries; j++) {
                element("futureUpgradeBlockEntry", lineReader.readLine());
            }
            int numberOfOrdinateValues = readInt(lineReader);
            for (int j = 0; j < numberOfCorrespondingVariables; j++) {
                // column specification: label, units, min, and max
                startElement("correspondingVariable");
                element("label", correspondingVariableLabels.get(j));
                element("units", correspondingVariableUnits.get(j));
                element("minimum", lineReader.readLine());
                element("maximum", lineReader.readLine());
                endElement("correspondingVariable");
            }
            startElement("ordinateValues");
            int numberOfRows = numberOfOrdinateValues / numberOfCorrespondingVariables;
            for (int j = 1; j <= numberOfRows; j++) {
                startElement("correspondingVariables");
                for (int k = 1; k <= numberOfCorrespondingVariables; k++) {
                    element("variable", lineReader.readLine());
                }
                endElement("correspondingVariables");
            }
            endElement("ordinateValues");
            endElement("block");
        }
        
        // read until eof
        while (line != null) {
            // read the next line
            line = lineReader.readLine();
        }
        endElement("dataset");       
        handler.endDocument();
    } 
    
    private int readInt(BufferedReader lineReader) throws IOException {
        return Integer.parseInt(lineReader.readLine());
    }
    
    private float readFloat(BufferedReader lineReader) throws IOException {
        return Float.parseFloat(lineReader.readLine());
    }
    
    private void startElement(String name) throws SAXException {
        handler.startElement(ns, name, name, null);
    }
    
    private void endElement(String name) throws SAXException {
        handler.endElement(ns, name, name);
    }
    
    private void element(String name, String value) throws SAXException {
        startElement(name);
        characters(value);
        endElement(name);
    }
    
    private void characters(String value) throws SAXException {
        int length = value.length();
        handler.characters(value.toCharArray(), 0, length);
    }

    @Override
    public void parse(String systemId) throws IOException, SAXException {
        URL url = new URL(systemId);
        InputStream byteStream = url.openStream();
        InputSource source = new InputSource(byteStream);
        parse(source);
    }
}
