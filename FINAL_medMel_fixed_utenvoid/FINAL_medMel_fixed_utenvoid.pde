import gab.opencv.*;
import processing.video.*;
import dmxP512.*;
import processing.serial.*;
import themidibus.*; //Import the library

Capture video;
OpenCV opencv;

//MUSIC//
MidiBus myBus1; // The MidiBus -- harmony -- fiolett
MidiBus myBus2; // The MidiBus -- melodi -- grønn
MidiBus myBus3; // The MidiBus --- bass --- pink

long nextTimeNodeMillis = 0;  //next note counter 
long nextTimeMelNodeMillis = 0;
long nextTimeBassNodeMillis = 0;

long Bus1intervall = 0; // virtuell midi 
long Bus2intervall = 0;
long Bus3intervall = 0; 

// !! java starter å  telle i null +1 på channel i Ableton!!
int Bus1channel = 0; // 0-2 //kanal i abbleton 
int Bus2channel = 3; // 3-5
int Bus3channel = 6; // 6-8

// c minor scale 
// C, D, D#, F, G, G#, A#, C
int notes[] = {
  0, 2, 3, 5, 7, 8, 10, 12
}; //0.octav

int pitch = 2; // tangent 
int pitchMel = 2; 
int pitchBass = 2; 
int velocity = 127; //hit hardness: 0 - 127 

//// LIGHTS ///// 
DmxP512 dmxOutput;
int universeSize=128;
String DMXPRO_PORT="/dev/cu.usbserial-EN172579";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE=115000;

float runningAverageMovement = 0;

void setup() {
  size(720, 480);
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);

  dmxOutput=new DmxP512(this, universeSize, false);
  //dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);

  opencv.startBackgroundSubtraction(5, 3, 0.5);

  video.start();
  myBus1 = new MidiBus(this, -1, "Bus 1"); // Create a new virtual MidiBus device 
  myBus2 = new MidiBus(this, -1, "Bus 2");
  myBus3 = new MidiBus(this, -1, "Bus 3");
 
}

void draw() {
  image(video, 0, 0);  
  opencv.loadImage(video);

  opencv.calculateOpticalFlow();

  PVector aveFlow = opencv.getAverageFlow( );

  int flowScale = 50;

  stroke(255);
  strokeWeight(2); //strokeline showing movening flow 
  line(video.width/2, video.height/2, video.width/2 + aveFlow.x*flowScale, video.height/2 + aveFlow.y*flowScale);

  noFill();
  stroke(255, 0, 0);
  strokeWeight(3); 
  text(aveFlow.mag(), 150, 150); //averege flow shown in campure video window 
  //println(aveFlow.mag());


  int tempo = 120; //beats per minute //GLOBAL variable 

  ///// BUS 1// CONTINIOUS Harmony////
  if (nextTimeNodeMillis < millis()) {
    for(int i = 0; i < 16; i++){
      myBus1.sendNoteOff(Bus1channel, pitch, 0); // Send a Midi noteOff
    }
    int nodeFractions[] = {8, 4, 4, 2, 2};
    int noteLength = nodeFractions[round(random(0, nodeFractions.length-1))];

    nextTimeNodeMillis = millis() + (round(random(1, 2))*((60*1000/tempo)/noteLength));

    if (aveFlow.mag() > 2) { //flow over x send note on (1> = super sensitive)
      Bus1intervall += 1; //runs though the loop 
      if ((Bus1intervall  % 45 ) == 0) { //when it updates x times (!!check frame rate!!) 
        Bus1channel += 1; //switch to next channel 
        if  (Bus1channel > 2) { //go back to first channel 
          Bus1channel = 0;
        }
      }
      pitch = notes[round(random(notes.length-1))]+48; //based on global notes array in 0.octave
      velocity = round(random(90, 127));      
      myBus1.sendNoteOn(Bus1channel, pitch, velocity); // Send a Midi noteOn
    }
    println("INTERVALL# :");
    println("harmony:", Bus1intervall, "channel:", Bus1channel+1); //process, +1 viser rett kanal if ableton
  }


  //MELoDY  
  if (nextTimeMelNodeMillis < millis()) {
    for(int i = 0; i < 16; i++){
      myBus2.sendNoteOff(Bus2channel, pitchMel, 0); // Send a Midi noteOff
    }
    int nodeFractions[] = {8, 8, 16};
    int noteLength = nodeFractions[round(random(0, nodeFractions.length-1))];

    nextTimeMelNodeMillis = millis() + (round(random(1, 2))*((60*1000/tempo)/noteLength));

    if (aveFlow.mag() > 1) { //flow over 1 (super sensitive)
      Bus2intervall += 1; //runs though the program 
      if ((Bus2intervall  % 20) == 0) { //when it updates 15 times //check frame rate stuff !! 
        Bus2channel += 1; //switch to next channel 
        if  (Bus2channel > 5) { //go back to first channel 
          Bus2channel = 3;
        }
      }
      pitchMel = notes[round(random(notes.length-1))]+48;
      velocity = round(random(90, 127));      
      myBus2.sendNoteOn(Bus2channel, pitchMel, velocity); // Send a Midi noteOn
    }

    println("melodi:", Bus2intervall,"channel:",Bus2channel+1);
  }



  /////BUS-3 ///// BASS 

  if (nextTimeBassNodeMillis < millis()) {
    for(int i = 0; i < 16; i++){
      myBus3.sendNoteOff(Bus3channel, pitchBass, 0); // Send a Midi noteOff
    }

    int nodeFractions[] = {4, 4, 2, 2}; //note lengde, helnote = 4 takt, halv 2, kvart 4 etc 
    int noteLength = nodeFractions[round(random(0, nodeFractions.length-1))];

    nextTimeBassNodeMillis = millis() + (round(random(1, 2))*((60*1000/tempo)/noteLength));

    if (aveFlow.mag() > 1.5) { //flow over 1 (super sensitive)
      Bus3intervall += 1; //runs though the program 
      if ((Bus3intervall  % 30 ) == 0) { //when it updates 30 times //check frame rate stuff !! 
        Bus3channel += 1; //switch to next channel 
        if  (Bus3channel > 8) { //go back to first channel 
          Bus3channel = 6;
        }
      }
      pitchBass = notes[round(random(notes.length-1))]+48;
      velocity = round(random(90, 127));      
      myBus3.sendNoteOn(Bus3channel, pitchBass, velocity); // Send a Midi noteOn
    }
    println("bass:", Bus3intervall,"channel:",Bus3channel+1);
  }

  /// LIGHTS SET UP /// an element of unpredicatbily and randomness 

  dmxOutput.set(19, 255); //19 always on - camera cannot see in the dark..... 

  if (aveFlow.mag() > 1.5) { //white light 2 blink when movement over 1.5 (same as bass)
    dmxOutput.set(13, 255);
  }

  if (aveFlow.mag() > 3.5) { //turn off white light 2 when movement over 3.5 (high)
    dmxOutput.set(13, 0);
  }

  if (aveFlow.mag() > 2.3) { //red light off when movement over 2.3 (mid)
    dmxOutput.set(21, 0);
  } else {
    dmxOutput.set(21, 255); //red light on default 
  }
}






void captureEvent(Capture m) {
  m.read();
}