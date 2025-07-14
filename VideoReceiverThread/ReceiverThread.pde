// Daniel Shiffman
// <http://www.shiffman.net>

// A Thread using receiving UDP

import java.io.*;

class ReceiverThread extends Thread {

  // Port we are receiving.
  int port = 9100; 
  UDP udp;  // define the UDP object
  // Reference to parent for UDP callback
  VideoReceiverThread parent;

  boolean running;    // Is the thread running?  Yes or no?
  boolean available;  // Are there new images available?

  // Start with something 
  PImage img;

  ReceiverThread (int w, int h) {
    img = createImage(w,h,RGB);
    running = false;
    available = true; // We start with "loading . . " being available
  }

  // Set the parent reference for UDP callbacks
  void setParent(VideoReceiverThread p) {
    parent = p;
    // create a new datagram connection on port and wait for incoming message
    udp = new UDP( parent, port );
    udp.listen( true );
  }

  PImage getImage() {
    // We set available equal to false now that we've gotten the data
    available = false;
    return img;
  }

  boolean available() {
    return available;
  }

  // Overriding "start()"
  void start () {
    running = true;
    super.start();
  }

  // We must implement run, this gets triggered by start()
  void run () {
    while (running) {
      // With UDP library, we don't need to actively poll
      // The receive handler will be called automatically
      // Just sleep to keep thread alive
      try {
        Thread.sleep(10);
      } catch (InterruptedException e) {
        break;
      }
    }
  }

  // Process incoming image data (called from UDP receive handler)
  void processImage(byte[] data, String ip, int port) {
    println("Received datagram with " + data.length + " bytes from " + ip);

    // Read incoming data into a ByteArrayInputStream
    ByteArrayInputStream bais = new ByteArrayInputStream( data );

    // We need to unpack JPG and put it in the PImage img
    img.loadPixels();
    try {
      // Make a BufferedImage out of the incoming bytes
      BufferedImage bimg = ImageIO.read(bais);
      // Put the pixels into the PImage
      bimg.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width);
    } 
    catch (Exception e) {
      e.printStackTrace();
    }
    // Update the PImage pixels
    img.updatePixels();
    
    // New data is available!
    available = true;
  }


  // Our method that quits the thread
  void quit() {
    System.out.println("Quitting."); 
    running = false;  // Setting running to false ends the loop in run()
    // In case the thread is waiting. . .
    interrupt();
  }
}

