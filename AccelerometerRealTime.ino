//////////////////////////////////////////////////////////////////////
// Real-time Accelerometer using the RTIMU Arduino Library
// Tim Collins, 2019
//
// Assumes MPU-9250 connected in I2C mode. Run Serial Monitor (from Tools
// menu) and select '38400 baud' to see the output.

#include <Wire.h>
#include "I2Cdev.h"
#include "RTIMUSettings.h"
#include "RTIMU.h"

RTIMU *imu;               // the IMU object
RTIMUSettings settings;   // the settings object

#define SERIAL_PORT_SPEED 9600

unsigned long lastDisplay;

void setup()
{
    int errcode;
    Serial.begin(SERIAL_PORT_SPEED);    // USB serial link to PC
    Wire.begin();                       // I2C link to MPU-9250
    imu = RTIMU::createIMU(&settings);  // Create the IMU object...

    if ((errcode = imu->IMUInit()) < 0) // ...and initialise
    {
        Serial.print("Failed to initialise IMU: ");
        Serial.println(errcode);
    }
    lastDisplay = millis();
}

void loop()
{
    unsigned long now = millis();
    while (imu->IMURead()) {
        // Display the latest reading every 100ms
        if ((now - lastDisplay) >= 100) {
            lastDisplay = now;
            RTVector3 a = imu->getAccel();
      			Serial.print(a.x());
      			Serial.print("\t");
      			Serial.print(a.y());
      			Serial.print("\t");
      			Serial.println(a.z());
        }
    }
}
