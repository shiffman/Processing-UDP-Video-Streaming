import processing.video.*;
import javax.imageio.*;
import java.awt.image.*;
import java.io.*;

// import UDP library
import hypermedia.net.*;

// This is the port we are sending to
int clientPort = 9100; 

// This is our object that sends UDP out
UDP udp;

// Webcam object
Capture cam;

void setup() {
  size(320,240);
  
  // Create a new connection for sending data
  udp = new UDP( this );
  
  // Initialize Camera with better error handling
  String[] cameras = Capture.list();
  
  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, width, height);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);
    // Use the first available camera
    cam = new Capture(this, cameras[0]);
  }
  
  // Start capturing the images from the camera
  cam.start();
}

void draw() {
  if (cam.available() == true) {
    cam.read();
    // Whenever we get a new image, send it!
    broadcast(cam, width, height);
  }
  image(cam,0,0,width,height);
}


// Function to broadcast a PImage over UDP
// Special thanks to: http://ubaa.net/shared/processing/udp/
void broadcast(PImage img, int outputWidth, int outputHeight) {

  // Create a resized copy of the image to match receiver dimensions
  PImage resized = createImage(outputWidth, outputHeight, RGB);
  resized.copy(img, 0, 0, img.width, img.height, 0, 0, outputWidth, outputHeight);

  // We need a buffered image to do the JPG encoding
  BufferedImage bimg = new BufferedImage( resized.width, resized.height, BufferedImage.TYPE_INT_RGB );

  // Transfer pixels from resized image to the BufferedImage
  resized.loadPixels();
  bimg.setRGB( 0, 0, resized.width, resized.height, resized.pixels, 0, resized.width);

  // Need these output streams to get image as bytes for UDP communication
  ByteArrayOutputStream baStream	= new ByteArrayOutputStream();
  BufferedOutputStream bos		= new BufferedOutputStream(baStream);

  // Turn the BufferedImage into a JPG and put it in the BufferedOutputStream
  // Requires try/catch
  try {
    ImageIO.write(bimg, "jpg", bos);
  } 
  catch (IOException e) {
    e.printStackTrace();
  }

  // Get the byte array, which we will send out via UDP!
  byte[] packet = baStream.toByteArray();

  // Send JPEG data as a datagram using UDP library
  println("Sending datagram with " + packet.length + " bytes");
  String ip = "localhost";	// the destination IP address
  udp.send( packet, ip, clientPort );
}