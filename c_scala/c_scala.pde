import gab.opencv.*;
import processing.video.*;
import themidibus.*; //Import the library

MidiBus myBus1; // The MidiBus - continous -- fiolett
MidiBus myBus2; // The MidiBus -- melodi -- grønn
MidiBus myBus3; // The MidiBus --- bass --- pink

Capture video;
OpenCV opencv;

long nextTimeNodeMillis = 0;
long nextTimeBassNodeMillis = 0;

// chromatic - c scale 
// C# D# E F# G# A B
int notes[] = {
  1, 3, 4, 6, 8, 9, 11, 13
}; //0.octav

int channel = 3; // ? 
int pitch = 2; //hvorfor 2 og ikke 0 ? // hvilke tangent som spilles
int velocity = 127; //hit hardness 0 - 127 //

void setup() {
  size(720, 480);
  video = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);

  opencv.startBackgroundSubtraction(5, 3, 0.5);
  video.start();

 //  MidiBus.list(); 
  myBus1 = new MidiBus(this, -1, "Bus 1"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  myBus2 = new MidiBus(this, -1, "Bus 2");
  myBus3 = new MidiBus(this, -1, "Bus 3");
}

void draw() {
  image(video, 0, 0);  
  opencv.loadImage(video);

  opencv.calculateOpticalFlow();

  PVector aveFlow = opencv.getAverageFlow( );

  int flowScale = 50;
  println(aveFlow.mag());

  stroke(255);
  strokeWeight(2);
  line(video.width/2, video.height/2, video.width/2 + aveFlow.x*flowScale, video.height/2 + aveFlow.y*flowScale);

  noFill();
  stroke(255, 0, 0);
  strokeWeight(3);
  
  int tempo = 120; //beats per minute 

  if (nextTimeNodeMillis < millis()) {
    myBus1.sendNoteOff(channel, pitch, 0); // Send a Midi noteOff
    //myBus2.sendNoteOff(channel, pitch+1, 0); // Send a Midi noteOff

    int nodeFractions[] = {8, 4, 4, 2, 2};
    int noteLength = nodeFractions[round(random(0, nodeFractions.length-1))];
   
    nextTimeNodeMillis = millis() + (round(random(1, 2))*((60*1000/tempo)/noteLength));

    if (aveFlow.mag() > 2) {
      channel = 2;
      pitch = notes[round(random(notes.length-1))]+24;
      velocity = round(random(90, 127));      
      myBus1.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
     // myBus2.sendNoteOn(channel, pitch+1, velocity); // Send a Midi noteOn
    }
  }

  if (nextTimeBassNodeMillis < millis()) {
    myBus3.sendNoteOff(channel, pitch+4, 0); // Send a Midi noteOff

    int nodeFractions[] = {4, 2};
    int noteLength = nodeFractions[round(random(0, nodeFractions.length-1))];
   
    nextTimeBassNodeMillis = millis() + (round(random(1, 2))*((60*1000/tempo)/noteLength));

    if (aveFlow.mag() > 2) {
      channel = 2;
      pitch = notes[round(random(notes.length-1))]+24;
      velocity = round(random(90, 127));      
      myBus3.sendNoteOn(channel, pitch+4, velocity); // Send a Midi noteOn
    }
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