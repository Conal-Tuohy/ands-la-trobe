  /** Copyright 2011 Conal Tuohy
   *
   * Licensed under the Apache License, Version 2.0 (the "License");
   * you may not use this file except in compliance with the License.
   * You may obtain a copy of the License at
   *
   *   http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software
   * distributed under the License is distributed on an "AS IS" BASIS,
   * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   * See the License for the specific language governing permissions and
   * limitations under the License.package au.edu.latrobe.fedora;
   */
import org.fcrepo.client.messaging.*;
import javax.jms.Message;
import javax.jms.TextMessage;
import javax.jms.JMSException;
import java.util.Properties;
import java.util.Enumeration;
import javax.naming.Context;
import org.fcrepo.server.messaging.JMSManager;
import org.fcrepo.server.errors.MessagingException;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.io.IOException;

/**
 *  Description of the Class
 *
 *@author     ctuohy
 *@created    1 August 2011
 */
public class FedoraUpdateHandler implements MessagingListener {
	private final static String START_COMMAND = "start";
	private final static String STOP_COMMAND = "stop";
	private final static String HANDLER_COMMAND = "handler.command";
	private final static String HANDLER_JMS_CLIENTID = "handler.jms.clientid";

	/*
	 *  The Fedora MessagingClient used to listen to the Fedora JMS server
	 */
	private org.fcrepo.client.messaging.MessagingClient messagingClient;
	/*
	 *  configuration of the FedoraUpdateHandler
	 */
	Properties properties;


	/**
	 *  Constructor for the FedoraUpdateHandler object
	 *
	 *@param  properties  Description of the Parameter
	 */
	public FedoraUpdateHandler(Properties properties) {
		// Define some default properties ...
		this.properties = new Properties();

		// Properties passed to JmsMessagingClient's properties
		this.properties.setProperty(Context.INITIAL_CONTEXT_FACTORY, "org.apache.activemq.jndi.ActiveMQInitialContextFactory");
		this.properties.setProperty(Context.PROVIDER_URL, "failover://tcp://localhost:61616");
		this.properties.setProperty(JMSManager.CONNECTION_FACTORY_NAME, "ConnectionFactory");
		this.properties.setProperty("topic.fedora", "fedora.apim.update");

		// Other properties needed to instantiate the JmsMessagingClient
		// See http://www.fedora-commons.org/documentation/3.4/javadocs/org/fcrepo/client/messaging/JmsMessagingClient.html#constructor-detail
		// The name of the client (must be unique - only one client may register with this name at any one time)
		this.properties.setProperty("handler.jms.clientid", "FedoraUpdateHandler");
		// The command to run
		this.properties.setProperty("handler.command", "cat");
		
		// Copy the user-provided properties (which will override the defaults)
		Enumeration propertyNames = properties.propertyNames();
		while (propertyNames.hasMoreElements()) {
			String propertyName = (String) propertyNames.nextElement();
			this.properties.setProperty(propertyName, properties.getProperty(propertyName));
		}
	}


	private static void printUsage() {
			System.out.println("FedoraUpdateHandler listens for Fedora update messages and executes an external program to handle them.");
			System.out.println("For more information, visit http://code.google.com/p/ands-la-trobe/");
			System.out.println();
			System.out.println("FedoraUpdateHandler expects either one or two parameters:");
			System.out.println("The first parameter is either 'start' or 'stop' to control the listener.");
			System.out.println("The second (and optional) parameter is the name of a Java properties XML file to configure the listener.");
			System.out.println("e.g.");
			System.out.println("java -jar FedoraUpdateHandler.jar start handle-ingest.xml");
			System.out.println("java -jar FedoraUpdateHandler.jar start handle-dc-update.xml");
			System.out.println("java -jar FedoraUpdateHandler.jar stop handle-dc-update.xml");
			System.out.println();
			System.out.println("The following properties are documented at https://wiki.duraspace.org/display/FCR30/Messaging");
			System.out.println(" * java.naming.factory.initial)");
			System.out.println(" * java.naming.provider.url");
			System.out.println(" * connection.factory.name");
			System.out.println(" * topic.fedora");
			System.out.println();
			System.out.println("The property \"handler.jms.clientid\" identifies the listener to Fedora.");
			System.out.println("This value must be unique (i.e. each simultaneous client must use a different value for this property).");
			System.out.println();
			System.out.println("The property \"handler.command\" specifies the application which the listener will run to handle the event.");
			System.out.println("FedoraUpdateHandler will execute this application and pipe the Fedora message (an Atom XML document)");
			System.out.println("to the application's standard input stream. ");
			System.out.println();
			System.out.println("Any properties not defined in the properties file will use defaults as shown below:");
			System.out.println();
			System.out.println("<!DOCTYPE properties SYSTEM \"http://java.sun.com/dtd/properties.dtd\">");
			System.out.println("<properties version=\"1.0\">");
			System.out.println("	<entry key=\"java.naming.factory.initial\">org.apache.activemq.jndi.ActiveMQInitialContextFactory</entry>");
			System.out.println("	<entry key=\"java.naming.provider.url\">failover://tcp://localhost:61616</entry>");
			System.out.println("	<entry key=\"connection.factory.name\">ConnectionFactory</entry>");
			System.out.println("	<entry key=\"topic.fedora\">fedora.apim.update</entry>");
			System.out.println("	<entry key=\"handler.jms.clientid\">FedoraUpdateHandler</entry>");
			System.out.println("	<entry key=\"handler.command\">cat</entry>");
			System.out.println("</properties>");
	}		
	
	/**
	 *  The main program for the FedoraUpdateHandler class
	 *
	 *@param  args  The command line arguments
	 */
	public static void main(String[] args) {
		/*
		 *  Parse and handle the command-line arguments
		 */
		 if (args.length == 0) {
		 	 // no command-line arguments
		 	 printUsage();
		 } else if (! START_COMMAND.equalsIgnoreCase(args[0]) && ! STOP_COMMAND.equalsIgnoreCase(args[0])) {
			/*
			 *  first arg is not "start" or "stop" - print a usage message and exit
			 */
		 	 printUsage();
		} else {
			try {
				Properties properties = new Properties();
				if (args.length == 2) {
					// Read properties from XML file to override defaults
					properties.loadFromXML(new FileInputStream(args[1]));
				}
				FedoraUpdateHandler fuh = new FedoraUpdateHandler(properties);
				fuh.start(); // need to start the client so the persistent subscription can be stopped
				if (STOP_COMMAND.equalsIgnoreCase(args[0])) {
					fuh.stop();
				}
			} catch (FileNotFoundException fnfe) {
				System.out.println("Error reading configuration file.");
				System.out.println(fnfe.getLocalizedMessage());
			} catch (IOException ioe) {
				System.out.println("Error reading configuration file.");
				System.out.println(ioe.getLocalizedMessage());
			} catch (MessagingException me) {
				System.out.println("Error communicating with Fedora.");
				me.printStackTrace(System.out);
			}
		}
	}


	/**
	 *  Start the messaging client
	 *
	 *@exception  MessagingException  Description of the Exception
	 */
	public void start() throws MessagingException {
		System.out.println("Messaging Client starting...");

		// Start the client
		messagingClient = new JmsMessagingClient(
				properties.getProperty(HANDLER_JMS_CLIENTID),
				this,
				properties,
				true
				);
		messagingClient.start();

		System.out.println("Messaging Client started.");
	}


	/**
	 *  Stop the messaging client
	 *
	 *@exception  MessagingException  Description of the Exception
	 */
	public void stop() throws MessagingException {
		System.out.println("Messaging Client stopping...");
		messagingClient.stop(false);
		System.out.println("Messaging Client stopped.");
	}


	/**
	 *  Pipes an InputStream to an OutputStream
	 *
	 *@author     ctuohy
	 *@created    1 August 2011
	 */
	private class StreamCopier implements Runnable {
		private InputStream in;
		private OutputStream out;


		/**
		 *  Constructor for the StreamCopier object
		 *
		 *@param  in   Description of the Parameter
		 *@param  out  Description of the Parameter
		 */
		public StreamCopier(InputStream in, OutputStream out) {
			this.in = in;
			this.out = out;
		}


		/**
		 *  Main processing method for the StreamCopier object
		 */
		public void run() {
			try {
				byte[] buffer = new byte[1024];
				int len = in.read(buffer);
				while (len != -1) {
					out.write(buffer, 0, len);
					len = in.read(buffer);
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@param  clientId  Description of the Parameter
	 *@param  message   Description of the Parameter
	 */
	public void onMessage(String clientId, Message message) {
		String messageText = "";
		try {
			messageText = ((TextMessage) message).getText();
		} catch (JMSException e) {
			System.err.println("Error retrieving message text " + e.getMessage());
		}
		System.out.println("Message received: " + messageText + " from client " + clientId);
		/*
		 *  create a new process and pass the message to the process's standard input stream
		 */
		try {
			System.out.print("Passing message to ");
			System.out.println(properties.getProperty(HANDLER_COMMAND));

			Process messageHandler = Runtime.getRuntime().exec(properties.getProperty(HANDLER_COMMAND));
			// read the output of the messageHandler and copy it to standard output
			new Thread(
					new StreamCopier(messageHandler.getInputStream(), System.out)
					).start();
			// read the error output of the messageHandler and copy it to standard error
			new Thread(
					new StreamCopier(messageHandler.getErrorStream(), System.err)
					).start();
			// write Fedora's Atom message to the messageHandler's standard input stream
			PrintStream messageStream = new PrintStream(messageHandler.getOutputStream());
			messageStream.print(messageText);
			messageStream.close();
			System.out.println("Message handler returned exit code " + String.valueOf(messageHandler.waitFor()));
		} catch (java.io.IOException ioe) {
			System.err.println("Error passing message to message handling process. " + ioe.getMessage());
		} catch (InterruptedException ie) {
			System.err.println("The message handling process was interrupted. " + ie.getMessage());
		}
	}
}

