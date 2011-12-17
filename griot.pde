/*

 Griot v.0.1

  Created 16 December 2011
  By Francesco Fantoni  <francesco@hv-a.com>

  http://www.hv-a.com
  
*/


// Define the number of samples to keep track of.  The higher the number,
// the more the readings will be smoothed, but the slower the output will
// respond to the input.  Using a constant rather than a normal variable lets
// use this value to determine the size of the readings array.
const int numReadings = 10;

int readings[numReadings];      // the readings from the analog input
int index = 0;                  // the index of the current reading
int total = 0;                  // the running total
int value = 0;                  // the average
int signalPage = 0;
int currentPage = 0;
int previous = 0;
int previousPage = 0;
int previousSignal = 0;

// the following variables are long's because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
long valueDebounceTime = 0;  // the last time the output pin was toggled
long valueDebounceDelay = 100;    // the debounce time; increase if the output flickers
long pageDebounceTime = 0;
long pageDebounceDelay = 400; // the time you must stay on a page to trigger reading

int inputPin = A0;

// wave stuff
#include <FatReader.h>
#include <SdReader.h>
#include <avr/pgmspace.h>
#include "WaveHC.h"
#include "WaveUtil.h"

SdReader card;    // This object holds the information for the card
FatVolume vol;    // This holds the information for the partition on the card
FatReader root;   // This holds the information for the volumes root directory
FatReader file;   // This object represent the WAV file 
WaveHC wave;      // This is the only wave (audio) object, since we will only play one at a time


/*
 * Define macro to put error messages in flash memory
 */
#define error(msg) error_P(PSTR(msg))


// end wave stuff

void setup()
{
  // initialize serial communication with computer:
  Serial.begin(9600);
  
  // wave initialization  
  if (!card.init()) error("card.init");
  // enable optimized read - some cards may timeout
  card.partialBlockRead(true);
  
  // Now we will look for a FAT partition!
  uint8_t part;
  for (part = 0; part < 5; part++) {   // we have up to 5 slots to look in
    if (vol.init(card, part)) 
      break;                           // we found one, lets bail
  }
  if (part == 5) {                     // if we ended up not finding one  :(
    error("No valid FAT partition!");  // Something went wrong, lets print out why
  }

  // Try to open the root directory
  if (!root.openRoot(vol)) {
    error("Can't open root dir!");      // Something went wrong,
  }
  // end wave initialization

  
  // initialize all the readings to 0: 
  for (int thisReading = 0; thisReading < numReadings; thisReading++)
    readings[thisReading] = 0;


playcomplete("XDO.WAV");
playcomplete("XDO_ALTO.WAV");
playcomplete("XFA.WAV");
playcomplete("XLA.WAV");
playcomplete("XMI.WAV");
playcomplete("XRE.WAV");
playcomplete("XSO.WAV");
playcomplete("XTI.WAV");


    
}

void loop() {
  // subtract the last reading:
  total= total - readings[index];         
  // read from the sensor:  
  readings[index] = analogRead(inputPin); 
  // add the reading to the total:
  total= total + readings[index];       
  // advance to the next position in the array:  
  index = index + 1;                    

  // if we're at the end of the array...
  if (index >= numReadings)              
    // ...wrap around to the beginning: 
    index = 0;                           

  // calculate the average:
  value = total / numReadings;
  
  
  if (value < previous*0.90 || value > previous*1.1) {
  // reset the debouncing timer
    valueDebounceTime = millis();
  }
  
    
  if (((millis() - valueDebounceTime)) > valueDebounceDelay) {


  if (value >= 957) { 
  signalPage = 10;
  }
  if (value >= 841 && value < 957) { 
  signalPage = 9;
  }
   if (value >= 751 && value < 841) { 
  signalPage = 8;
  }
  if (value >= 679 && value < 751) { 
  signalPage = 7;
  }
  if (value >= 618 && value < 679) { 
  signalPage = 6;
  }
  if (value >= 568 && value < 618) { 
  signalPage = 5;
  }
  if (value >= 525 && value < 568) { 
  signalPage = 4;
  }
  if (value >= 487 && value < 525) { 
  signalPage = 3;
  }
  if (value >= 455 && value < 487) { 
  signalPage = 2;
  }
  if (value >= 390 && value < 455) {  
  signalPage = 1;
  }
  if (value < 100) {  
  signalPage = 0;
  }
  }
  
  if (signalPage != previousSignal) 
  {
  // reset the debouncing timer
    pageDebounceTime = millis();
  }
  
  if (((millis() - pageDebounceTime)) > pageDebounceDelay)
  {
    currentPage = signalPage;
    if (currentPage != previousPage)
    {
      // here the page stuff must happen
      //
      Serial.println(currentPage, DEC);
      if (currentPage == 1) {playcomplete("XDO.WAV"); playfile("1.WAV");}
      if (currentPage == 2) {playcomplete("XDO.WAV"); playfile("2.WAV");}
      if (currentPage == 3) {playcomplete("XDO.WAV"); playfile("3.WAV");}
      if (currentPage == 4) {playcomplete("XDO.WAV"); playfile("4.WAV");}
      if (currentPage == 5) {playcomplete("XDO.WAV"); playfile("5.WAV");}
      if (currentPage == 6) {playcomplete("XDO.WAV"); playfile("6.WAV");}
      if (currentPage == 7) {playcomplete("XDO.WAV"); playfile("7.WAV");}
      if (currentPage == 8) {playcomplete("XDO.WAV"); playfile("8.WAV");}
      if (currentPage == 9) {playcomplete("XDO.WAV"); playfile("9.WAV");}
      if (currentPage == 10) {playcomplete("XDO.WAV"); playfile("0.WAV");}
      
      //
      //
      previousPage = currentPage;
      
    }
  }
  
  previousSignal = signalPage;
  previous = value;
}


/////////////////////////////////// HELPERS
/*
 * print error message and halt
 */
void error_P(const char *str)
{
  PgmPrint("Error: ");
  SerialPrint_P(str);
  sdErrorCheck();
  while(1);
}
/*
 * print error message and halt if SD I/O error, great for debugging!
 */
void sdErrorCheck(void)
{
  if (!card.errorCode()) return;
  PgmPrint("\r\nSD I/O error: ");
  Serial.print(card.errorCode(), HEX);
  PgmPrint(", ");
  Serial.println(card.errorData(), HEX);
  while(1);
}

// Plays a full file from beginning to end with no pause.
void playcomplete(char *name) {
  // call our helper to find and play this name
  playfile(name);
  while (wave.isplaying) {
  // do nothing while its playing
  }
  // now its done playing
}

void playfile(char *name) {
  // see if the wave object is currently doing something
  if (wave.isplaying) {// already playing something, so stop it!
    wave.stop(); // stop it
  }
  // look in the root directory and open the file
  if (!file.open(root, name)) {
    putstring("Couldn't open file "); Serial.print(name); return;
  }
  // OK read the file and turn it into a wave object
  if (!wave.create(file)) {
    putstring_nl("Not a valid WAV"); return;
  }
  
  // ok time to play! start playback
  wave.play();
}

