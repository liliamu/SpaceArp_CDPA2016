import dmxP512.*;
import processing.serial.*;

DmxP512 dmxOutput;
int universeSize=128;

String DMXPRO_PORT="dev/cu.usbserial-EN172579";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE=115000;


void setup() {

  size(245, 245, JAVA2D);  

  dmxOutput=new DmxP512(this, universeSize, false);
  dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);
}

void draw() {    
  background(0);

  /* STUDIO MODE (5 channels)
   
   // intensity
   dmxOutput.set(1, 255);
   // white point (warm - cold)
   dmxOutput.set(2, (int)map(mouseX, 0, width, 0, 255));
   // tint (green - magenta)
   dmxOutput.set(3, (int)map(mouseY, 0, height, 0, 255));
   // unused
   dmxOutput.set(4, 0);
   // strobe off
   dmxOutput.set(5, 0);
   
   */

  /* GENERAL MODE (9 channels)  */

  // red
  dmxOutput.set(1, 0);
  // amber
  dmxOutput.set(2, 0);
  // green cyan
  dmxOutput.set(3, 0);
  // blue
  dmxOutput.set(4, 0);
  // white 3K (warm)
  dmxOutput.set(5, 255);
  // white 6K (cold)
  dmxOutput.set(6, 0);
  // unused
  dmxOutput.set(7, 255);
  // intensity
  dmxOutput.set(8, 255);
  // strobe
  dmxOutput.set(9, 0);
}