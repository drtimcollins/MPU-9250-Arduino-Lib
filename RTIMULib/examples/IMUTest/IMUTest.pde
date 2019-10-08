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

#include <Wire.h>
#include "I2Cdev.h"
#include "RTIMUSettings.h"
#include "RTIMU.h"
#include "RTFusionRTQF.h" 
#include "CalLib.h"
#include <EEPROM.h>

RTIMU *imu;                                           // the IMU object
RTFusionRTQF fusion;                                  // the fusion object
RTIMUSettings settings;                               // the settings object

//  DISPLAY_INTERVAL sets the rate at which results are displayed
#define DISPLAY_INTERVAL  100                         // interval between pose displays

//  SERIAL_PORT_SPEED defines the speed to use for the debug serial port
#define  SERIAL_PORT_SPEED  38400

unsigned long lastDisplay;
unsigned long lastRate;

RTQuaternion q; // Pose quaternion

void setup()
{
    int errcode;
  
    Serial.begin(SERIAL_PORT_SPEED);
    Wire.begin();
    imu = RTIMU::createIMU(&settings);                        // create the imu object
  
    if ((errcode = imu->IMUInit()) < 0) {
        Serial.print("Failed to init IMU: "); Serial.println(errcode);
    }

    lastDisplay = lastRate = millis();

    // Slerp power controls the fusion and can be between 0 and 1
    // 0 means that only gyros are used, 1 means that only accels/compass are used
    // In-between gives the fusion mix.
    
    fusion.setSlerpPower(0.02);
    
    // use of sensors in the fusion algorithm can be controlled here
    // change any of these to false to disable that sensor
    
    fusion.setGyroEnable(true);
    fusion.setAccelEnable(true);
    fusion.setCompassEnable(true);

}

void loop()
{  
    unsigned long now = millis();
    unsigned long delta;
    int loopCount = 1;
  
    while (imu->IMURead()) {                                // get the latest data if ready yet
        // this flushes remaining data in case we are falling behind
        if (++loopCount >= 10)
            continue;

        // Update pose data
        update();     
        
        if ((delta = now - lastRate) >= 1000) {
            lastRate = now;
        }
        if ((now - lastDisplay) >= DISPLAY_INTERVAL) {
			lastDisplay = now;
           
			printQuaternion(q);           
			printVector(imu->getAccel());
           
           Serial.println();
        }
    }
}

void printVector(RTVector3 v){
     Serial.print(v.x(),8);
     Serial.print("\t");
     Serial.print(v.y(),8);
     Serial.print("\t");
     Serial.print(v.z(),8);
     Serial.print("\t");
}
void printQuaternion(RTQuaternion q){
     Serial.print(q.scalar(),3);
     Serial.print("\t");
     Serial.print(q.x(),3);
     Serial.print("\t");
     Serial.print(q.y(),3);
     Serial.print("\t");
     Serial.print(q.z(),3);
     Serial.print("\t");
}

void update(){
  fusion.newIMUData(imu->getGyro(), imu->getAccel(), imu->getCompass(), imu->getTimestamp());
  q = fusion.getFusionQPose();
}
