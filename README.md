# SpaceArp Read me 

Processing 
Uses Open CV to calculate average flow of movement, and sends MIDI notes via Ableton. Set in C scale minor. 
For audiovisual installation Space Arp, a collison (http://vimeo.com/204410479)


#Synopsis
This code is developed for Space Arp, a collision, which is an audiovisual installation that detects the average flow of movement, and translates it to sound though Ableton. Movement is set to play random notes in a C minor scale, iterating though 3x3 instruments. A shadow display is visualising the movement through 3 light sources via DMX output. 
 

#Installation
Needs a video feed, dmx (remember to write the correct number for output), music software that can output MIDI (I use Ableton). 

Set MIDI IAC driver online, set the required amount of Buses (default is 3, one is commented out). 
Set your music software to play from the Bus and channel according to the code. 

Processing libraries used and fetched from: 
themidibus: http://www.smallbutdigital.com/themidibus.php
dmxP512: http://motscousus.com/stuff/2011-01_dmxP512/
gab.opencv: http://atduskgreg.github.io/opencv-processing/reference/ 


#Contributors
liliamu (liam@itu.dk) 
Ole Kristensen (olek@itu.dk) 

#License
https://creativecommons.org/licenses/by-nc-sa/4.0/ 
Share — copy and redistribute the material in any medium or format
Adapt — remix, transform, and build upon the material
The licensor cannot revoke these freedoms as long as you follow the license terms.
NonCommercial — You may not use the material for commercial purposes.
Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
