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
  static int stat_clients = 0;
  char clientLine[255];
  
  Client cli = server.available();
  if (cli) {
    stat_clients++;
    
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
    
    // START routes
    if (!strcmp("house", controller)) {
      // Define actions
      if (!strcmp("temp", action)) {
        cli.println("House temperature is: 70f");
      }
      else if (!strcmp("light", action)) {
        cli.println("Light in house is: over 9000");
      }
      else {
        printNoAction(cli);
      }
    }
    else if (!strcmp("stats", controller)) {
      char output[100];
      sprintf(output, "Number of client connections: %d", stat_clients);
      cli.println(output);
    }
    else {
      printNoController(cli);
    }
    // END routes
    
    delay(1);
    cli.stop();
  }
}

void header(Client c, int co) {
  switch (co) {
    case 200:
      c.println("HTTP/1.1 200 OK");
    break;
    
    case 404:
      c.println("HTTP/1.1 404 Not Found");
    break;
    
    c.println("Content-Type: text/html");
    c.println("");
  }
}

void printNoAction(Client c) {
  c.println("No action found");
}

void printNoController(Client c) {
  c.println("No controller found");
}

void l(char *v) {
  Serial.println(v);
}