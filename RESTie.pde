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

void loop() {
  char clientLine[255];
  static int stat_hits = 0;
  Client cli = server.available();
  
  if (cli) {
    stat_hits++;
    
    // Get the HEADER string
    int i = 0;
    while (cli.connected()) {
      if (cli.available()) {
        char c = cli.read();
        if (c != '\n' && c != '\r') {
          clientLine[i] = c;
          i++;
        } else {
          clientLine[i] = '\0';
          break;
        }
      }
    }
    
    // First we pull the header method, URI
    // and version.
    char *d = " ";
    char *hMethod = strtok(clientLine, d);
    char *hURI;
    char *hVersion;
    if (NULL != hMethod) {
      hURI = strtok(NULL, d);
      if (NULL != hURI) {
        hVersion = strtok(NULL, d);
      }
    }
    
    // Next we strip the controller, action,
    // and value from the URI
    d = "/";
    char *r = NULL;
    char *temp = (char *)malloc(sizeof(char) * (strlen(hURI) + 1));
    strcpy(temp, hURI);
    char *controller;
    char *action;
    char *value;
    
    if (NULL != temp) {
      if (NULL != (controller = strtok(temp, d))) {
        if (NULL != (action = strtok(NULL, d))) {
          value = strtok(NULL, d);
        }
      }
    }
    
    // Send "everything OK" header
    cli.println("HTTP/1.1 200 OK");
    cli.println("Content-Type: application/json");
    cli.println();
    
    String output = String();
    output += "{\"status\":\"OK\",\"error\":false,\"result\":";
    
    // START routes
    if (!strcmp("house", controller)) {
      // Define actions
      if (!strcmp("temp", action)) {
        output += "\"70f\"";
      }
      else if (!strcmp("light", action)) {
        output += 1300;
      }
      else {
        outAppendNull(output);
      }
    }
    else if (!strcmp("stats", controller)) {
      output += "{\"status\":\"OK\",";
      output += "\"uptime\":";
      output += millis() / 1000;
      output += ",\"hits\":";
      output += stat_hits;
      output += "}";
    }
    // No route, set result to null
    else {
      outAppendNull(output);
    }
    // END routes
    
    output += "}";
    cli.println(output);
    
    delay(1);
    cli.stop();
  }
}

void l(char *v) {
  Serial.println(v);
}

void outAppendNull(String &o) {
  o += "\"NULL\"";
}