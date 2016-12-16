import gab.opencv.*;
import processing.video.*;

Capture video;
OpenCV opencv;

void setup() {
  size(720, 480);
  video = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);
  
  opencv.startBackgroundSubtraction(5, 3, 0.5);
  
  video.start();
}

void draw() {
  image(video, 0, 0);  
  opencv.loadImage(video);
  
//  opencv.updateBackground();
  
//  opencv.dilate();
//  opencv.erode();

//  PImage result = opencv.getSnapshot();

  opencv.calculateOpticalFlow();

  PVector aveFlow = opencv.getAverageFlow();

  int flowScale = 50;
  
  stroke(255);
  strokeWeight(2);
  line(video.width/2, video.height/2, video.width/2 + aveFlow.x*flowScale, video.height/2 + aveFlow.y*flowScale);

 // image(result, 0, 0);
  noFill();
  stroke(255, 0, 0);
  strokeWeight(3);
  //for (Contour contour : opencv.findContours()) {
  //  contour.draw();
  //}
  
  if (aveFlow.mag() > 2) {
    rect(10,10,100,100);
  }
  
}

void captureEvent(Capture m) {
  m.read();
}