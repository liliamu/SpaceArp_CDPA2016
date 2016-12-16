import gab.opencv.*;
import processing.video.*;
import dmxP512.*;
import processing.serial.*;
import themidibus.*; //Import the library

Capture video;
OpenCV opencv;

MidiBus myBus1; // The MidiBus - continous -- fiolett
MidiBus myBus2; // The MidiBus -- melodi -- grønn
MidiBus myBus3; // The MidiBus --- bass --- pink

long nextTimeNodeMillis = 0;

// chromatic
// C  C#  Db  D  D#  Eb  E  F  F#  [Gb]  G  G#  Ab  A  A#  Bb  B
int notes[] = {
  26, 27, 31, 33, 34
}; //2.octav

int channel = 3; // ? 
int pitch = 2; //hvorfor 2 og ikke 0 ? // hvilke tangent som spilles
int velocity = 127; //hit hardness 0 - 127 //

//// LIGHTS ///// 
DmxP512 dmxOutput;
int universeSize=128;
int x, y, w, h;

String DMXPRO_PORT="/dev/cu.usbserial-EN172579";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE=115000;

float runningAverageMovement = 0;


void setup() {
  size(720, 480);
  video = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);
  
  dmxOutput=new DmxP512(this, universeSize, false);
  dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);

  opencv.startBackgroundSubtraction(5, 3, 0.5);

  video.start();

   // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
}

void draw() {
  image(video, 0, 0);  
  opencv.loadImage(video);

  //  opencv.updateBackground();

  //  opencv.dilate();
  //  opencv.erode();

  //  PImage result = opencv.getSnapshot();

  opencv.calculateOpticalFlow();

  PVector aveFlow = opencv.getAverageFlow( );

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

  if (nextTimeNodeMillis < millis()) {
    myBus.sendNoteOff(channel, pitch, 0); // Send a Midi noteOff
    //myBus.sendNoteOff(channel, pitch+1, 0); // Send a Midi noteOff
    //myBus.sendNoteOff(channel, pitch+4, 0); // Send a Midi noteOff

    int bpm = 124;
    int noteLength = 4 * round(random(1, 2)); // fourth or eigths
    nextTimeNodeMillis = millis() + (round(random(1, 2))*((60*1000/bpm)/noteLength));

    if (aveFlow.mag() > 2) {
      channel = 2;
      pitch = notes[round(random(notes.length-1))]+36;
      velocity = round(random(90, 127));      
      myBus.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
      //myBus.sendNoteOn(channel, pitch+1, velocity); // Send a Midi noteOn
      //myBus.sendNoteOn(channel, pitch+4, velocity); // Send a Midi noteOn
    }
  }
  
  //lys
  
    if (aveFlow.mag() > 1){
    dmxOutput.set(13, 255);
    dmxOutput.set(19, 255);
  }
  
  else{
    dmxOutput.set(13, 0);
    dmxOutput.set(19, 0);
  }

  
 // STUDIO MODE (5 channels)
   
  // intensity
  dmxOutput.set(1, 50);
  
  // white point (warm - cold)
  dmxOutput.set(2, 0);
  
  // tint (green - magenta)
  float smoothLevel = 0.8;

  runningAverageMovement *= smoothLevel;
  runningAverageMovement += (1.0-smoothLevel) * aveFlow.mag();
  
  int tintLevel = round(constrain(
    map(runningAverageMovement, 0.0, 1.0, 3.0, 255.0)
    , 1, 255));

  //println(tintLevel);
  
  dmxOutput.set(3, tintLevel); 
  
  text(tintLevel, 300, 300);

  // unused
  dmxOutput.set(4, 0);
  
  // strobe 
  dmxOutput.set(5, 0);
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
   dmxOutput.set(8, 100);
   // strobe
   dmxOutput.set(9, 255);
   }
   
else{
   // red
   dmxOutput.set(1, 0);
   // amber
   dmxOutput.set(2, 0);
   // green cyan
   dmxOutput.set(3, 150);
   // blue
   dmxOutput.set(4, 0);
   // white 3K (warm)
   dmxOutput.set(5, 0);
   // white 6K (cold)
   dmxOutput.set(6, 0);
   // unused
   dmxOutput.set(7, 255);
   // intensity
   dmxOutput.set(8, 100);
   // strobe
   dmxOutput.set(9, 255);
   }   */
   

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("fffdg:"+pitch);
  println("Velocity:"+velocity);
}

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
}

void captureEvent(Capture m) {
  m.read();
}