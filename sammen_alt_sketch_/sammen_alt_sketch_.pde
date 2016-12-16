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
  myBus1 = new MidiBus(this, -1, "Bus 1"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  myBus2 = new MidiBus(this, -1, "Bus 2");
  myBus3 = new MidiBus(this, -1, "Bus 3");
   // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
}

void draw() {
  image(video, 0, 0);  
  opencv.loadImage(video);

  opencv.calculateOpticalFlow();

  PVector aveFlow = opencv.getAverageFlow( );

  int flowScale = 50;

  stroke(255);
  strokeWeight(2);
  line(video.width/2, video.height/2, video.width/2 + aveFlow.x*flowScale, video.height/2 + aveFlow.y*flowScale);

  noFill();
  stroke(255, 0, 0);
  strokeWeight(3);
 
//BUS1 CONTINOUS - ECHOS 

  if (nextTimeNodeMillis < millis()) {
    myBus1.sendNoteOff(channel, pitch, 0); // Send a Midi noteOff

    int tempo = 134; //beats per minute 
    int nodeFractions[] = {8, 8, 8, 4, 4, 2, 2};
    int noteLength = nodeFractions[round(random(0, nodeFractions.length-1))];
    nextTimeNodeMillis = millis() + (round(random(1, 2))*((60*1000/tempo)/noteLength));

    if (aveFlow.mag() > 2) {
      channel = 2;
      pitch = notes[round(random(notes.length-1))]+36;
      velocity = round(random(90, 127));      
      myBus1.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
      
      println(aveFlow.mag());
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
}
  


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