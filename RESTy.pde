#include <SPI.h>
#include <Ethernet.h>

byte mac[] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};
byte ip[] = {192, 168, 1, 125};

Server server(80);

void setup() {
  Serial.begin(9600);

  Ethernet.begin(mac, ip);
  server.begin();
}

// url buffer size
#define BUFFER_SIZE 255

void loop() {
  Client client = server.available();
  if (client) {
    log("client connected");
    
    header(client, 200);
    client.println("You rock!");
    
    delay(1);
    client.stop();
  }
}

void header(Client client, int code) {
  switch (code) {
    case 200:
      client.println("HTTP/1.1 200 OK");
      client.println("Content-Type: text/html");
      client.println();
    break;
      
    case 404:
      client.println("HTTP/1.1 404 Not Found");
      client.println("Content-Type: text/html");
      client.println();
    break; 
  }
}

void log(char* value) {
  Serial.println(value);
}