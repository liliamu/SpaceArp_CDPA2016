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
long nextTimeBassNodeMillis = 0;



// c scale 
// c,d, 
int notes[] = {
  0, 2, 3, 5, 7, 10, 11, 12
}; //0.octav

int channel = 3; // Hvorfor 3 ?
int pitch = 2; //hvorfor 2 og ikke 0 ? // hvilke tangent som spilles
int velocity = 127; //hit hardness 0 - 127 //




float runningAverageMovement = 0;


void setup() {
  size(720, 480);
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  


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
  text(aveFlow.mag(), 150 ,150);

   
  int tempo = 120; //beats per minute GOBAL 
  
  // CONTINIOUS //BUS1 

  if (nextTimeNodeMillis < millis()) {
    myBus1.sendNoteOff(channel, pitch, 0); // Send a Midi noteOff

    int nodeFractions[] = {8, 4, 4, 2, 2};
    int noteLength = nodeFractions[round(random(0, nodeFractions.length-1))];
   
    nextTimeNodeMillis = millis() + (round(random(1, 2))*((60*1000/tempo)/noteLength));

    if (aveFlow.mag() > 1) {
      channel = 2;
      pitch = notes[round(random(notes.length-1))]+24;
      velocity = round(random(90, 127));      
      myBus1.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
    }
  }


    if (nextTimeBassNodeMillis < millis()) {
    myBus3.sendNoteOff(channel, pitch, 0);
   
    int nodeFractions[] = {4, 4, 2, 2, 1};
    int noteLength = nodeFractions[round(random(0, nodeFractions.length-1))];
   
    nextTimeBassNodeMillis = millis() + (round(random(1, 2))*((60*1000/tempo)/noteLength));

    if (aveFlow.mag() > 1) {
      channel = 2;
      pitch = notes[round(random(notes.length-1))]+36;
      velocity = round(random(90, 127));      
      myBus3.sendNoteOn(channel, pitch+1, velocity); // Send a Midi noteOn
          }
  }
  

  
  
  println(aveFlow.mag());
  
  


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