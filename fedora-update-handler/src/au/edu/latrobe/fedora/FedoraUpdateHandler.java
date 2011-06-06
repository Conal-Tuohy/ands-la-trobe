package au.edu.latrobe.fedora;

import org.fcrepo.client.messaging.*;
import javax.jms.Message;
import javax.jms.TextMessage;
import javax.jms.JMSException;
import java.util.Properties;
import javax.naming.Context;
import org.fcrepo.server.messaging.JMSManager;
import org.fcrepo.server.errors.MessagingException;
import java.io.OutputStream;
import java.io.PrintStream;

public class FedoraUpdateHandler implements MessagingListener {
	
	/* The Fedora MessagingClient used to listen to the Fedora JMS server */
    private org.fcrepo.client.messaging.MessagingClient messagingClient;
    /* The command line to run in response to an event received from Fedora */
    private String[] args;
	
	private FedoraUpdateHandler(String[] args) {
		/* Record the command line to run when an event is received */
		this.args = args;
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
		FedoraUpdateHandler fuh = new FedoraUpdateHandler(args);
	}
	
    public void start() throws MessagingException {
    	 System.out.println("Messaging Client starting...");
        Properties properties = new Properties();
        properties.setProperty(Context.INITIAL_CONTEXT_FACTORY, "org.apache.activemq.jndi.ActiveMQInitialContextFactory");
        properties.setProperty(Context.PROVIDER_URL, "failover://tcp://localhost:61616");
        properties.setProperty(JMSManager.CONNECTION_FACTORY_NAME, "ConnectionFactory");
        properties.setProperty("topic.fedora", "fedora.apim.update");
        messagingClient = new JmsMessagingClient("FedoraUpdateHandler", this, properties, true);
        messagingClient.start();
        System.out.println("Messaging Client started.");
    }
    
    public void stop() throws MessagingException {
    	 System.out.println("Messaging Client stopping...");	
    	 messagingClient.stop(false);
    	 System.out.println("Messaging Client stopped.");
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
				  PrintStream messageStream = new PrintStream(messageHandler.getOutputStream());
				  messageStream.print(messageText);
				  messageStream.close();
				  System.out.print("Message handler returned ");
				  System.out.println(messageHandler.waitFor());
			  } catch (java.io.IOException ioe) {
				  System.err.println("Error passing message to message handling process. " + ioe.getMessage());
			  } catch (InterruptedException ie) {
				  System.err.println("The message handling process was interrupted. " + ie.getMessage());
			  }
		  }
    }
}
