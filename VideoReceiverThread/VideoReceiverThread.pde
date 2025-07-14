// Daniel Shiffman
// <http://www.shiffman.net>

// A Thread using receiving UDP to receive images

import java.awt.image.*; 
import javax.imageio.*;
import java.io.*;

// import UDP library
import hypermedia.net.*;

PImage video;
ReceiverThread thread;

void setup() {
  size(400,300);
  video = createImage(320,240,RGB);
  thread = new ReceiverThread(video.width,video.height);
  thread.setParent(this);  // Set parent reference for UDP
  thread.start();
}

void draw() {
  if (thread.available()) {
    video = thread.getImage();
  }

  // Draw the image
  background(0);
  imageMode(CENTER);
  image(video,width/2,height/2);
}

/**
 * UDP receive handler - this will be called by the UDP library
 * when data arrives
 */
void receive( byte[] data, String ip, int port ) {
  if (thread != null) {
    thread.processImage(data, ip, port);
  }
}