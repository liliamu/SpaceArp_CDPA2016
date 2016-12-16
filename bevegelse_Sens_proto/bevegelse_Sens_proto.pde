import gab.opencv.*;
import processing.video.*;
import themidibus.*; //Import the library

MidiBus myBus; // The MidiBus
Capture video;
OpenCV opencv;

long nextTimeNodeMillis = 0;

// chromatic
// C  C#  Db  D  D#  Eb  E  F  F#  [Gb]  G  G#  Ab  A  A#  Bb  B
int notes[] = {
  26, 27, 31, 33, 34
}; //2.octav

int channel = 3; // ? 
int pitch = 2; //hvorfor 2 og ikke 0 ? // hvilke tangent som spilles
int velocity = 127; //hit hardness 0 - 127 //

void setup() {
  size(720, 480);
  video = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);

  opencv.startBackgroundSubtraction(5, 3, 0.5);

  video.start();

  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

  // Either you can
  //                   Parent In Out
  //                     |    |  |
  //myBus = new MidiBus(this, 0, 1); // Create a new MidiBus using the device index to select the Midi input and output devices respectively.

  // or you can ...
  //                   Parent         In                   Out
  //                     |            |                     |
  //myBus = new MidiBus(this, "IncomingDeviceName", "OutgoingDeviceName"); // Create a new MidiBus using the device names to select the Midi input and output devices respectively.

  // or for testing you could ...
  //                 Parent  In        Out
  //                   |     |          |
  myBus = new MidiBus(this, -1, "Bus 1"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
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
      pitch = notes[round(random(notes.length-1))]+24;
      velocity = round(random(90, 127));      
      myBus.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
      //myBus.sendNoteOn(channel, pitch+1, velocity); // Send a Midi noteOn
      //myBus.sendNoteOn(channel, pitch+4, velocity); // Send a Midi noteOn
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