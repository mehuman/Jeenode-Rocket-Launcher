/*
Launch Pad
By: Mark Huson
Public Domain
*/

#include "Ports.h"
#include "RF12.h"
#include "Radio.h"

//Define Ports for LED, Button, and Valve
Port ledPort(1), readyButtonPort(2), launchPort(3);

//Variables
boolean readySent, confirmed, failed;
int tries;
long timer;
char ready[]="Ready";
char fire[]="Fire";
char confirm[]="Confirm";

//Initialize the Radio object
char frequency = RF12_915MHZ;  //Frequency to operate radio at. 
                               //RF12_915MHZ can be used in North America
                               
char group = 0xD4;  //This 0-255 represents the operating "group" of the radio
                    //Message for radios sent to a different group will not be
                    //seen. Default is 212 (0xD4)
                      
char nodeID = 1;    //This is a number (1-31) to identify this radio transmission
                    //Nothing stops to radios from having the same ID, but may cause 
                    //confusion
                      
Radio theRadio(frequency, group, nodeID);

void setup()
{
  Serial.begin(57600);
  theRadio.begin();
  
  ledPort.mode(OUTPUT);
  readyButtonPort.mode(INPUT);
  launchPort.mode(OUTPUT);
  
  tries=0;
  readySent=false;
  confirmed=false;
  failed=false;
  timer=millis();
  
  ledPort.digiWrite(HIGH);
  delay(2000);
  ledPort.digiWrite(LOW);
}

void loop()
{
  if(readyButtonPort.digiRead())
  {
    Serial.println("Ready Button Pressed");
    readySent=true;
    theRadio.write(0, ready);
    ledPortBlink();
  }
  
  if(theRadio.available())
  {
    if(strcmp(theRadio.message(), confirm))
    {
      confirmed=true;
    }
    else if (strcmp(theRadio.message(), fire))
    {
      launchRocket();
    }
  }
  
  if((millis()-timer>1000) && readySent && !failed && !confirmed)
  {
    if(tries<5)
    {
      Serial.println(tries);
      theRadio.write(0, ready);
      ledPortBlink();
      tries++;
    }
    else
    {
      Serial.println("Failed to send Ready");
      failed=true;
      ledPort.digiWrite(HIGH);
    }
  }
}
  

void launchRocket()
{
  Serial.println("Launch initiated! GO! GO! GO!");
  launchPort.digiWrite(HIGH);
  delay(1000);
  launchPort.digiWrite(LOW);
}

void ledPortBlink()
{
  ledPort.digiWrite(HIGH);
  delay(500);
  ledPort.digiWrite(LOW);
  delay(500);
  ledPort.digiWrite(HIGH);
  delay(500);
  ledPort.digiWrite(LOW);
}
