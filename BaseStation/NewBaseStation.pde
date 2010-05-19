/*
Base Station
By: Mark Huson
Public Domain
Version 1.0
*/

#include "Ports.h"
#include "RF12.h"
#include "Radio.h"
#include "PortsLCD.h"

//Define Ports for LCD, LED, and Button
PortI2C myI2C (4);
LiquidCrystalI2C lcd (myI2C);
Port ledPort(1), launchButtonPort(2);

//Variables
boolean readyReceived, launched;
char ready[]="Ready";
char fire[]="Fire";
char confirm[]="Confirm";
int fireCount=0;

//Initialize the Radio object
char frequency = RF12_915MHZ;  //Frequency to operate radio at. 
                               //RF12_915MHZ can be used in North America
                               
char group = 0xD4;  //This 0-255 represents the operating "group" of the radio
                    //Message for radios sent to a different group will not be
                    //seen. Default is 212 (0xD4)
                      
char nodeID = 2;    //This is a number (1-31) to identify this radio transmission
                    //Nothing stops to radios from having the same ID, but may cause 
                    //confusion
                      
Radio theRadio(frequency, group, nodeID);

void setup()
{
  Serial.begin(57600);
  Serial.println("Started");
  theRadio.begin();
  
  ledPort.mode(OUTPUT);
  launchButtonPort.mode(INPUT);
  
  lcd.begin(16,2);
  lcd.print("Node Rockets!");
  lcd.setCursor(0,1);
  lcd.print("Launches: ");
  lcd.setCursor(10,1);
  lcd.print(fireCount);

}

void loop()
{
  if(theRadio.available())
  {
    Serial.println("Available");
    Serial.println(theRadio.message());
    if(!strcmp(theRadio.message(), ready))
    {
      Serial.println("Write");
      delay(2000); //This pauses just enough to let the radio send
      readyReceived=true;
      theRadio.write(0, confirm);
    }
  }
  if(launchButtonPort.digiRead() && readyReceived && !launched)
  {
    theRadio.write(0, fire);
    fireCount++;
    lcd.setCursor(10,1);
    lcd.print(fireCount);
    launched=true;
  }
}
