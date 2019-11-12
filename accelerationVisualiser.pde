import processing.serial.*;

Serial sp;
String[] inString;

void setup(){
  size(800,600);
  sp = new Serial(this, Serial.list()[0], 9600);
  sp.bufferUntil(10);  // Buffer serial input until line feed character
}

void draw() { 
  if(inString != null) 
  if(inString.length == 3)
  {
    PVector a = new PVector(float(inString[0]),float(inString[1]),float(inString[2]));
    text(a.toString(), 20, 20);
    fill(255, 255, 255, 20);
    rect(0, 0, width, height);
    stroke(0);
    strokeWeight(3);
    pushMatrix();
    translate(width/2, height/2);
    circle(100*a.x, 100*a.y, 100*(a.z+1.5));
    popMatrix();
  }
} 
 
// Callback function - called when a line feed character is received into the serial buffer
void serialEvent(Serial serial) { 
  // Read input string and split into an array of strings
  inString = splitTokens(serial.readString());    
} 
