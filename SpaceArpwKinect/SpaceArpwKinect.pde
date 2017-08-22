/*
Note that this set up is developed for particular parameters for distance, lights and MIDI instruments 
Results may vary if these are changed 
Cameras used for development: MBP anno 2015 integrated webcam, Creative webcam 
*/

import gab.opencv.*;
import processing.video.*;
import dmxP512.*;
import processing.serial.*;
import themidibus.*; 
import org.openkinect.processing.*;
import org.openkinect.freenect.*;


//Capture video;
OpenCV opencv;
Kinect video;


//MUSIC//
MidiBus myBus1; // The MidiBus - continous -- fiolett
//MidiBus myBus2; // The MidiBus -- melodi -- grønn //uncomment and to add anoter bus aka vitual midi 
MidiBus myBus3; // The MidiBus --- bass --- pink

long nextTimeNodeMillis = 0;
long nextTimeMelNodeMillis = 0;
long nextTimeBassNodeMillis = 0;

long Bus1intervall = 0; // virtual midi 
long Bus2intervall = 0;
long Bus3intervall = 0; 

// java starts to count in 0  = +1 in channel in Ableton 
int Bus1channel = 0; // 0-2 //channel inableton 
int Bus2channel = 3; // 3-5
int Bus3channel = 6; // 6-8

// c minor scale 
// C, D, D#, F, G, G#, A#, C
int notes[] = {
  0, 2, 3, 5, 7, 8, 10, 12
}; //0.octav start

int pitch = 2; // tangent 
int pitchMel = 2; 
int pitchBass = 2; 
int velocity = 127; //hit hardness: 0 - 127 

//// LIGHTS ///// 
DmxP512 dmxOutput;
int universeSize=128;
String DMXPRO_PORT="/dev/cu.usbserial-EN173628";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE=115000;

float runningAverageMovement = 0;

void setup() {
  size(720, 480);
  video = new Kinect(this);
  video.initVideo();
  opencv = new OpenCV(this, 640/2, 480/2);
 
 
  dmxOutput=new DmxP512(this, universeSize, false);
  dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE); //dmx setup comment out if no lights

  opencv.startBackgroundSubtraction(5, 3, 0.5);

  myBus1 = new MidiBus(this, -1, "Bus 1"); // Create a new virtual MidiBus device 
  //myBus2 = new MidiBus(this, -1, "Bus 2"); /remove while not using melody 
  myBus3 = new MidiBus(this, -1, "Bus 3");
 
}

void draw() {
  image(video.getVideoImage(), 0, 0);
  //image(video.getDepthImage(), 640, 0);
  //fill(255);
  opencv.loadImage(video.getVideoImage());

  opencv.calculateOpticalFlow();

  PVector aveFlow = opencv.getAverageFlow( );
 // int flowScale = 50;

  //stroke(255);
  //strokeWeight(2); //strokeline showing movening flow 
  //line(video.width, video.height, video.width + aveFlow.x*flowScale, video.height/2 + aveFlow.y*flowScale);

  noFill();
  stroke(255, 0, 0);
  strokeWeight(3); 
  text(aveFlow.mag(), 150, 150); //averege flow shown in campure video window 
  //println(aveFlow.mag()); //or print 


  int tempo = 120; //beats per minute //GLOBAL variable 

  ///// BUS 1 ///// CONTINIOUS Harmony 
  if (nextTimeNodeMillis < millis()) {
    for(int i = 0; i < 16; i++){
      myBus1.sendNoteOff(Bus1channel, pitch, 0); // Send a Midi noteOff
    }
    int nodeFractions[] = {4, 4, 2, 2};
    int noteLength = nodeFractions[round(random(0, nodeFractions.length-1))];

    nextTimeNodeMillis = millis() + (round(random(1, 2))*((60*1000/tempo)/noteLength));

    if (aveFlow.mag() > 0.2) { //flow over x send note on (
      Bus1intervall += 1; //runs though the loop 
      if ((Bus1intervall  % 45 ) == 0) { //when it updates x times (!!check frame rate!!) 
        Bus1channel += 1; //switch to next channel 
        if  (Bus1channel > 2) { //go back to first channel 
          Bus1channel = 0;
        }
      }
      pitch = notes[round(random(notes.length-1))]+48; //based on global notes array in 0.octave ->3 oct up
      velocity = round(random(90, 127));   //notes in scale and velocity set to random 
      myBus1.sendNoteOn(Bus1channel, pitch, velocity); // Send a Midi noteOn
    }
    println("INTERVALL# :");
    println("harmony:", Bus1intervall, "channel:", Bus1channel+1);
  }


  ///// BUS-3 ///// BASS 

  if (nextTimeBassNodeMillis < millis()) {
    for(int i = 0; i < 16; i++){
      myBus3.sendNoteOff(Bus3channel, pitchBass, 0); // Send a Midi noteOff
    }

    int nodeFractions[] = {8, 4, 4, 2, 2}; //note lengde, helnote = 4 takt, halv 2, kvart 4 etc 
    int noteLength = nodeFractions[round(random(0, nodeFractions.length-1))];

    nextTimeBassNodeMillis = millis() + (round(random(1, 2))*((60*1000/tempo)/noteLength));

    if (aveFlow.mag() > 0.2) { //flow over 1 (super sensitive)
      Bus3intervall += 1; //runs though the program 
      if ((Bus3intervall  % 30 ) == 0) { //when it updates 30 times //check frame rate stuff !! 
        Bus3channel += 1; //switch to next channel 
        if  (Bus3channel > 8) { //go back to first channel 
          Bus3channel = 6;
        }
      }
      pitchBass = notes[round(random(notes.length-1))]+36; //2 oct up - very deep !! NOT FOR COMPUTER SPEAKERS !! 
      velocity = round(random(90, 127));      
      myBus3.sendNoteOn(Bus3channel, pitchBass, velocity); // Send a Midi noteOn
    }
    println("bass:", Bus3intervall,"channel:",Bus3channel+1);
  }


  ///// LIGHTS  ///// 

  dmxOutput.set(25, 150); // always on - camera cannot see in the dark...

  if (aveFlow.mag() > 0.29) { //white light 2-  blink when movement over 1.5 (same as bass)
    dmxOutput.set(23, 150);
  }

  if (aveFlow.mag() > 0.2) { //turn off white light 2 when movement over 3.5 (high)
    dmxOutput.set(23, 0);
  }

  if (aveFlow.mag() > 0.28 ) { //red light off when movement over 2.3 (mid)
    dmxOutput.set(11, 0);
  } else {
    dmxOutput.set(11, 100); //red light on default 
  }
}