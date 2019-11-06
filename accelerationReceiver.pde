import processing.serial.*;

Serial sp;
String[] inString;

void setup(){
  sp = new Serial(this, Serial.list()[0], 9600);
  sp.bufferUntil(10);  // Buffer serial input until line feed character
}

// Nothing in draw() function but it must be there for the callback to work.
void draw() { 
} 
 
// Callback function - called when a line feed character is received into the serial buffer
void serialEvent(Serial serial) { 
  // Read input buffer and split into an array of strings
  inString = splitTokens(serial.readString());    
  if(inString.length == 3){
    PVector a = new PVector(float(inString[0]),float(inString[1]),float(inString[2]));
    print("Acceleration vector: ");
    println(a.toString());
  }
} 
