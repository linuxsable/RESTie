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
  int clientId = 0;
  int i = 0;
  char output[255];
  
  Client cli = server.available();
  if (cli) {
    
    // Get the HEADER string
    while (cli.connected()) {
      if (cli.available()) {
        char c = cli.read();
        if (c != '\n' && c != '\r') {
          output[i] = c;
          i++;
        } else {
          output[i] = '\0';
          break;
        }
      }
    }
    
    char *d = " ";
    char *hMethod = strtok(output, d);
    char *hURI;
    char *hVersion;
    if (NULL != hMethod) {
      hURI = strtok(NULL, d);
      if (NULL != hURI) {
        hVersion = strtok(NULL, d);
      }
    }
    
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
  c.println("No action");
}

void printNoController(Client c) {
  c.println("No controller found");
}

void l(char *v) {
  Serial.println(v);
}