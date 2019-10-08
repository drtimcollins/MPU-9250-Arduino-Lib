////////////////////////////////////////////////////////////////////////////
//
//  This file is part of RTIMULib-Arduino
//
//  Copyright (c) 2014-2015, richards-tech
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of 
//  this software and associated documentation files (the "Software"), to deal in 
//  the Software without restriction, including without limitation the rights to use, 
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
//  Software, and to permit persons to whom the Software is furnished to do so, 
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all 
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Modified by Tim Collins, Oct 2019.
// Extra feedback to Serial monitor added to give better confidence that it's worked!

#include <Wire.h>
#include "I2Cdev.h"
#include "RTIMUSettings.h"
#include "RTIMU.h"
#include "CalLib.h"
#include <EEPROM.h>

RTIMU *imu;                                           // the IMU object
RTIMUSettings settings;                               // the settings object
CALLIB_DATA calData;                                  // the calibration data

//  SERIAL_PORT_SPEED defines the speed to use for the debug serial port

#define  SERIAL_PORT_SPEED  38400

void setup()
{
  calLibRead(0, &calData);                           // pick up existing mag data if there   

  calData.magValid = false;
  for (int i = 0; i < 3; i++) {
    calData.magMin[i] = 10000000;                    // init mag cal data
    calData.magMax[i] = -10000000;
  }
   
  Serial.begin(SERIAL_PORT_SPEED);
  Serial.println("ArduinoMagCal starting");
  Serial.println("Enter s to save current data to EEPROM");
  Wire.begin();
   
  imu = RTIMU::createIMU(&settings);                 // create the imu object
  imu->IMUInit();
  imu->setCalibrationMode(true);                     // make sure we get raw data
  Serial.print("ArduinoIMU calibrating device "); Serial.println(imu->IMUName());
}

void loop()
{  
  boolean changed;
  RTVector3 mag;
  
  if (imu->IMURead()) {                                 // get the latest data
    changed = false;
    mag = imu->getCompass();
    for (int i = 0; i < 3; i++) {
      if (mag.data(i) < calData.magMin[i]) {
        calData.magMin[i] = mag.data(i);
        changed = true;
      }
      if (mag.data(i) > calData.magMax[i]) {
        calData.magMax[i] = mag.data(i);
        changed = true;
      }
    }
 
    if (changed) {
      Serial.println("-------");
      printData();
    }
  }
  
  if (Serial.available()) {
    if (Serial.read() == 's') {                  // save the data
      calData.magValid = true;
      calLibWrite(0, &calData);
      Serial.print("Mag cal data saved for device "); Serial.println(imu->IMUName());

      // Check it wrote properly
      memset(&calData,0,sizeof(calData));
      calLibRead(0, &calData);
      Serial.println("Data stored in EEPROM:");
      printData();
    }
  }
}

void printData(){
  Serial.println("Header chars:");
  Serial.println(calData.validL);
  Serial.println(calData.validH);
  Serial.println(calData.magValid);
  Serial.println(calData.pad);  
  Serial.println("Float data:");
  for(int n = 0; n < 3; n++)
  {
    Serial.print("min"); Serial.print((char)('X'+n)); Serial.print(": ");
    Serial.print(calData.magMin[n]);
    Serial.print(", max"); Serial.print((char)('X'+n)); Serial.print(": ");
    Serial.println(calData.magMax[n]); 
  }
}
