import java.awt.image.*; 
import javax.imageio.*;
import java.io.*;

// import UDP library
import hypermedia.net.*;

// Port we are receiving.
int port = 9100; 

UDP udp;  // define the UDP object

PImage video;

void setup() {
  size(400,300);
  // create a new datagram connection on port and wait for incoming message
  udp = new UDP( this, port );
  udp.listen( true );
  video = createImage(320,240,RGB);
}

 void draw() {
  // Draw the image
  background(0);
  imageMode(CENTER);
  image(video,width/2,height/2);
}

/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 */
void receive( byte[] data, String ip, int port ) {
  println("Received datagram with " + data.length + " bytes from " + ip);

  // Read incoming data into a ByteArrayInputStream
  ByteArrayInputStream bais = new ByteArrayInputStream( data );

  // We need to unpack JPG and put it in the PImage video
  video.loadPixels();
  try {
    // Make a BufferedImage out of the incoming bytes
    BufferedImage img = ImageIO.read(bais);
    // Put the pixels into the video PImage
    img.getRGB(0, 0, video.width, video.height, video.pixels, 0, video.width);
  } catch (Exception e) {
    e.printStackTrace();
  }
  // Update the PImage pixels
  video.updatePixels();
}
