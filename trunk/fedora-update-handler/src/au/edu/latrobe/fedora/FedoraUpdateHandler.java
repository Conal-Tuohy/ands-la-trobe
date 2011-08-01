package au.edu.latrobe.fedora;

import org.fcrepo.client.messaging.*;
import javax.jms.Message;
import javax.jms.TextMessage;
import javax.jms.JMSException;
import java.util.Properties;
import javax.naming.Context;
import org.fcrepo.server.messaging.JMSManager;
import org.fcrepo.server.errors.MessagingException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.io.IOException;

public class FedoraUpdateHandler implements MessagingListener {
	
	/* The Fedora MessagingClient used to listen to the Fedora JMS server */
    private org.fcrepo.client.messaging.MessagingClient messagingClient;
    /* configuration of the FedoraUpdateHandler */
    Properties properties;
	
	private FedoraUpdateHandler(String[] args) {
		if (args.length == 0) {
			/* no message-handling command specified - stop listening */
			try {
				start();
				stop();
			} catch (MessagingException me) {
				System.out.println("Messaging Client failed to stop correctly.");
				me.printStackTrace();
			}
		} else {
			/* a message-handling command was specified - start listening and
			forwarding update messages to the command */
			try {
				start();
			} catch (MessagingException me) {
				System.out.println("Messaging Client failed to start.");
				me.printStackTrace();
			}
		}
	};
	
	public static void main(String[] args) {
		/* Parse and handle the command-line arguments */
		if (args.length == 0) {
			/* no command-line arguments - print a usage message and exit */
			// qaz
		} else {
    	 // Define default properties ...
    	 Properties defaults = new Properties();
    	 
    	 // Properties passed to JmsMessagingClient's properties
        defaults.setProperty(Context.INITIAL_CONTEXT_FACTORY, "org.apache.activemq.jndi.ActiveMQInitialContextFactory");
        defaults.setProperty(Context.PROVIDER_URL, "failover://tcp://localhost:61616");
        defaults.setProperty(JMSManager.CONNECTION_FACTORY_NAME, "ConnectionFactory");
        defaults.setProperty("topic.fedora", "fedora.apim.update");
        
        // Other properties needed to instantiate the JmsMessagingClient
        // See http://www.fedora-commons.org/documentation/3.4/javadocs/org/fcrepo/client/messaging/JmsMessagingClient.html#constructor-detail
        // The name of the client (must be unique - only one client may register with this name at any one time)
        defaults.setProperty("clientId", "FedoraUpdateHandler"); 
        
        // Read properties from XML file to override defaults
        // TODO read XML config file
        // need to change command line syntax:
        // specify config XML and (optionally) either "start" (default action) or "stop" (to cancel durable subscriptions)
        // java -jar FedoraUpdateHandler.jar handle-minter.xml
        // java -jar FedoraUpdateHandler.jar crosswalk-rifcs-to-dc.xml
        // java -jar FedoraUpdateHandler.jar crosswalk-rifcs-to-dc.xml stop
        
        properties = new Properties(defaults); 
        properties.loadFromXML(args[0]);
        FedoraUpdateHandler fuh = new FedoraUpdateHandler(properties);
		}
	}
	
    public void start() throws MessagingException {
    	 System.out.println("Messaging Client starting...");
    	 
        
        // Start the client
        messagingClient = new JmsMessagingClient(
        	  properties.getProperty("clientId"), 
        	  this, 
        	  properties, 
        	  true
        );
        messagingClient.start();
        
        System.out.println("Messaging Client started.");
    }
    
    public void stop() throws MessagingException {
    	 System.out.println("Messaging Client stopping...");	
    	 messagingClient.stop(false);
    	 System.out.println("Messaging Client stopped.");
	 }
	
	 
	private class StreamCopier implements Runnable {
		private InputStream in;
		private OutputStream out;
		public StreamCopier(InputStream in, OutputStream out) {
			this.in = in;
			this.out = out;
		}
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
	 
    public void onMessage(String clientId, Message message) {
        String messageText = "";
        try {
            messageText = ((TextMessage)message).getText();
        } catch(JMSException e) {
            System.err.println("Error retrieving message text " + e.getMessage());
        }
        System.out.println("Message received: " + messageText + " from client " + clientId);
        /* create a new process and pass the message to the process's standard input stream */
        if (args.length > 0) {
			  try {
				  System.out.print("Passing message to");
				  for (int i = 0; i < args.length; i++) {
					  System.out.print(" ");
					  System.out.print(args[i]);
				  }
				  System.out.println();
				  	  	  
				  Process messageHandler = Runtime.getRuntime().exec(args);
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
}
