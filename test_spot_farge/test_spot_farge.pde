import gab.opencv.*;
import processing.video.*;
import dmxP512.*;
import processing.serial.*;

//// LIGHTS ///// 
DmxP512 dmxOutput;
int universeSize=128;
int x, y, w, h;

String DMXPRO_PORT="/dev/cu.usbserial-EN172579";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE=115000;

float runningAverageMovement = 0;

//// camera ///// 
Capture video;
OpenCV opencv;



void setup() {
  size(720, 480);
  video = new Capture(this, 640, 480); //camera window 
  opencv = new OpenCV(this, 640, 480);

  dmxOutput=new DmxP512(this, universeSize, false);
  dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);

  opencv.startBackgroundSubtraction(5, 3, 0.5); //the math 

  video.start();
}

//// action ///// 
void draw() {
  image(video, 0, 0);  
  opencv.loadImage(video);

  opencv.calculateOpticalFlow();
  PVector aveFlow = opencv.getAverageFlow( );
  int flowScale = 50;

  stroke(255);
  strokeWeight(2);
  line(video.width/2, video.height/2, video.width/2 + aveFlow.x*flowScale, video.height/2 + aveFlow.y*flowScale);


  if (aveFlow.mag() > 1){
    dmxOutput.set(21, 90);
  }
  
   else{
    dmxOutput.set(21, 0); //intensitet temperatu 
  }
  }


  /*GENERAL MODE (9 channels)  
   //HUSK: processing er rekkefølgesensitiv, ifs må komme etter hverande så det gir mening 
   //BEvegelse flow: 2 rød (sensitiv), 3 gul (mer bevegelse), < 2 grønn (standard)
  
   if (aveFlow.mag() > 2){
   // red
   dmxOutput.set(1, 255);
   // amber
   dmxOutput.set(2, 0);
   // green cyan
   dmxOutput.set(3, 0);
   // blue
   dmxOutput.set(4, 0);
   // white 3K (warm)
   dmxOutput.set(5, 0);
   // white 6K (cold)
   dmxOutput.set(6, 0);
   // unused
   dmxOutput.set(7, 255);
   // intensity
   dmxOutput.set(8, 255);
   // strobe
   dmxOutput.set(9, 255);
   }
   
else{
   // red
   dmxOutput.set(1, 0);
   // amber
   dmxOutput.set(2, 0);
   // green cyan
   dmxOutput.set(3, 255);
   // blue
   dmxOutput.set(4, 0);
   // white 3K (warm)
   dmxOutput.set(5, 0);
   // white 6K (cold)
   dmxOutput.set(6, 0);
   // unused
   dmxOutput.set(7, 255);
   // intensity
   dmxOutput.set(8, 255);
   // strobe
   dmxOutput.set(9, 255);
   }   
   

  // STUDIO MODE (5 channels)
   
  // intensity
  dmxOutput.set(1, 255);
  
  // white point (warm - cold)
  dmxOutput.set(2, 0);
  // tint (green - magenta)

  float smoothLevel = 0.7;

  runningAverageMovement *= smoothLevel;
  runningAverageMovement += (1.0-smoothLevel) * aveFlow.mag();
  
  int tintLevel = round(constrain(
    map(runningAverageMovement, 1.0, 1.1, 3.0, 255.0)
    , 1, 255));

  //println(tintLevel);
  
  dmxOutput.set(3, tintLevel); // (_value coming in, _lowest)
  
  text(tintLevel, 300, 300);

  // unused
  dmxOutput.set(4, 0);
  
  // strobe 
  dmxOutput.set(5, 0);
} */

 
void captureEvent(Capture m) {
  m.read();
}