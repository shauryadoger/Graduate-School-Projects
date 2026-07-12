/*
Sample code for collector 
 */

#include <Wire.h>
#include "HT_SSD1306Wire.h"
// Initialize the OLED display
static SSD1306Wire display(0x3c, 500000, SDA_OLED, SCL_OLED, GEOMETRY_128_64, RST_OLED);
#include "LoRaWan_APP.h"
#include "Arduino.h"
//Initialize Wifi
#include <WiFi.h>
#include <WiFiUdp.h>

const char* ssid = "CenturyLinkCC81";
const char* password = "6af8d5d6e9bb76";

WiFiUDP udp;
const char* udpAddress = "192.168.0.69";  // your laptop IP
const int udpPort = 9990;

#define RF_FREQUENCY                                915E6 // Hz
#define TX_OUTPUT_POWER                             22        // dBm
#define LORA_BANDWIDTH                              0         // [0: 125 kHz,
                                                              //  1: 250 kHz,
                                                              //  2: 500 kHz,
                                                              //  3: Reserved]
#define LORA_SPREADING_FACTOR                       12         // [SF7..SF12]
#define LORA_CODINGRATE                             1         // [1: 4/5,
                                                              //  2: 4/6,
                                                              //  3: 4/7,
                                                              //  4: 4/8]
#define LORA_PREAMBLE_LENGTH                        8         // Same for Tx and Rx
#define LORA_SYMBOL_TIMEOUT                         0         // Symbols
#define LORA_FIX_LENGTH_PAYLOAD_ON                  false
#define LORA_IQ_INVERSION_ON                        false

#define RX_TIMEOUT_VALUE                            1000
#define BUFFER_SIZE                                 30 // Define the payload size here

char txpacket[BUFFER_SIZE];
char rxpacket[BUFFER_SIZE];

static RadioEvents_t RadioEvents;
void OnTxDone( void );
void OnTxTimeout( void );
void OnRxDone( uint8_t *payload, uint16_t size, int16_t rssi, int8_t snr );

typedef enum
{
    LOWPOWER,
    STATE_RX,
    STATE_TX
} States_t;

int16_t txNumber;
States_t state;
bool sleepMode = false;
int16_t Rssi, rxSize;

void VextON(void) {
  pinMode(Vext, OUTPUT);
  digitalWrite(Vext, LOW);
}

void VextOFF(void) {
  pinMode(Vext, OUTPUT);
  digitalWrite(Vext, HIGH);
}

//Timing variables
unsigned long t1 = 0, t4 = 0;
unsigned long delta_t41 = 0, delta_t32 = 0;
unsigned long latency = 0;

void setup() {
  //Connect the collector node to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");

  Serial.begin(115200);
  Mcu.begin(HELTEC_BOARD,SLOW_CLK_TPYE);
  txNumber = 0;
  Rssi = 0;

  RadioEvents.TxDone = OnTxDone;
  RadioEvents.TxTimeout = OnTxTimeout;
  RadioEvents.RxDone = OnRxDone;

  Radio.Init( &RadioEvents );
  Radio.SetChannel(RF_FREQUENCY);
  Radio.SetTxConfig(MODEM_LORA, TX_OUTPUT_POWER, 0, LORA_BANDWIDTH,
                                LORA_SPREADING_FACTOR, LORA_CODINGRATE,
                                LORA_PREAMBLE_LENGTH, LORA_FIX_LENGTH_PAYLOAD_ON,
                                true, 0, 0, LORA_IQ_INVERSION_ON, 3000);

  Radio.SetRxConfig(MODEM_LORA, LORA_BANDWIDTH, LORA_SPREADING_FACTOR,
                                LORA_CODINGRATE, 0, LORA_PREAMBLE_LENGTH,
                                LORA_SYMBOL_TIMEOUT, LORA_FIX_LENGTH_PAYLOAD_ON,
                                0, true, 0, 0, LORA_IQ_INVERSION_ON, true);
  state = STATE_TX;
  VextON();
  display.init();
  display.setFont(ArialMT_Plain_10);
  display.clear();
  display.drawString(0, 0, "setup done!");
  display.display();
}

//Calculate Cyclical Redudancy Check for error detection purposes
uint8_t calculateCRC4(const char *data) {
  uint8_t crc = 0x0F; // Initial value for CRC-4
  uint8_t polynomial = 0x1B; // Polynomial x^4 + x^3 + x + 1

  while (*data) {
    crc ^= *data++;
    for (int i = 0; i < 8; i++) {
      if (crc & 0x10) {
        crc = (crc << 1) ^ polynomial;
      } else {
        crc <<= 1;
      }
    }
  }
  return crc & 0x0F; // Ensure CRC is 4 bits
}

//Execute the loop as according to the following states shwon in switch-case statements
void loop() {
  unsigned long timestamp, crc;
  unsigned int ACK = 0;
  switch(state) {
    case STATE_TX:
      delay(1000);
      txNumber++;
      timestamp = millis(); // Initialize timestamp here
      if (txNumber % 10 == 0) {
        sprintf(txpacket, "PING %d %lu", txNumber, timestamp); //PING to show latency every 10 packets.
      } else {
        sprintf(txpacket, "7E %d %d", txNumber, ACK);
      }
      //sprintf(txpacket, "7E %d %d", txNumber, ACK);
      display.clear();
      display.drawString(0, 0, "Sending packet:");
      display.drawString(0, 10, txpacket);
      display.display();
      Radio.Send((uint8_t *)txpacket, strlen(txpacket));
      state = LOWPOWER;
      break;
    case STATE_RX:
      display.clear();
      display.drawString(0, 0, "into RX mode");
      display.display();
      Radio.Rx(0);
      state = LOWPOWER;
      break;
    case LOWPOWER:
      Radio.IrqProcess();
      break;
    default:
      break;
  }
}

//Switch to Rx state when completed with transmission
void OnTxDone(void) {
  display.clear();
  display.drawString(0, 0, "TX done...");
  display.display();
  state = STATE_RX;
}

//Execute when transmission state enters timeout.
void OnTxTimeout(void) {
  Radio.Sleep();
  display.clear();
  display.drawString(0, 0, "TX Timeout...");
  display.display();
  state = STATE_TX;
}

//Execute when done recieving.
void OnRxDone(uint8_t *payload, uint16_t size, int16_t rssi, int8_t snr) {
    char rxpacket[BUFFER_SIZE];
    memcpy(rxpacket, payload, size);
    rxpacket[size] = '\0';
    Radio.Sleep();
    Rssi = rssi;

    // ---- Parse incoming packet ----
    int seq = -1;
    unsigned long timestamp = 0;
    int sensor = 0;
    int crc = 0;

    char *token = strtok(rxpacket, " "); // DATA
    token = strtok(NULL, " "); // seq
    if (token) seq = atoi(token);
    token = strtok(NULL, " "); // timestamp
    if (token) timestamp = atol(token);
    token = strtok(NULL, " "); // sensor
    if (token) sensor = atoi(token);
    /*if (token != NULL) {
        sensor = atoi(token); // Now you've got it!
    }*/
    token = strtok(NULL, " "); // crc
    if (token) crc = atoi(token);

    // ---- Recompute CRC for comparison ----
    char payloadNoCRC[BUFFER_SIZE];
    sprintf(payloadNoCRC, "DATA %d %lu %d", seq, timestamp, sensor);
    int checkCrc = calculateCRC4(payloadNoCRC);

    // New: Parse and handle latency measurement reply
    char packetType[10];
    //int seq;
    unsigned long sentT1, t2, t3, d32;
    int scanned = sscanf(rxpacket, "%s %d %lu %lu %lu %lu", packetType, &seq, &sentT1, &t2, &t3, &d32);

    //Reply is either latency-based 'or' a regular message
    if (scanned == 6 && strcmp(packetType, "PONG") == 0) {
      t4 = millis();
      delta_t41 = t4 - sentT1;
      delta_t32 = d32;
      latency = (delta_t41 - delta_t32) / 2;

      display.clear();
      display.drawString(0, 0, "TOF Latency Calc");
      display.drawString(0, 12, "Δt41=" + String(delta_t41) + " ms");
      display.drawString(0, 24, "Δt32=" + String(delta_t32) + " ms");
      display.drawString(0, 36, "Latency=" + String(latency) + " ms");
      display.display();
    } else {
      // ---- Display received data on OLED ----
      display.clear();
      display.drawString(0, 0, "RX Packet:");
      display.drawString(0, 12, payloadNoCRC);            // Show what was parsed (without CRC)
      display.drawString(0, 24, "CRC Rec: " + String(crc) + "| Sensor:" + String(sensor));
      display.drawString(0, 36, "CRC Calc: " + String(checkCrc) + "| RSSI:" + String(Rssi));
      //display.drawString(0, 48, "RSSI: " + String(Rssi));

      // ---- Decide and send ACK or NAK ----
      char txpacket[BUFFER_SIZE];
      if (crc == checkCrc) {
          sprintf(txpacket, "ACK %d", seq);
          Radio.Send((uint8_t *)txpacket, strlen(txpacket));
          display.drawString(0, 48, "Sent ACK: " + String(seq));
      } else {
          sprintf(txpacket, "NAK %d", seq);
          Radio.Send((uint8_t *)txpacket, strlen(txpacket));
          display.drawString(0, 48, "Sent NAK: " + String(seq));
      }
      display.display();
      //delay(1100); // <--- keeps message on screen for 1/2 second
    }
    // Send sensor 'and' RSSI + payload to Python server
    uint8_t packet[4];
    packet[0] = (uint8_t)(-Rssi);   // RSSI as positive number
    packet[1] = 0;                  // site ID high byte (customize)
    packet[2] = 1;                  // site ID low byte (customize)
    packet[3] = (uint8_t)sensor; // sensor (0 or 1)
    udp.beginPacket(udpAddress, udpPort);
    udp.write(packet, 4);
    udp.endPacket();

    state = STATE_TX;
}
/*Rssi = rssi;
  rxSize = size;
  memcpy(rxpacket, payload, size);
  rxpacket[size] = '\0';
  Radio.Sleep();

  display.clear();
  display.drawString(0, 0, "Received packet:");
  display.drawString(0, 10, rxpacket);
  display.drawString(0, 20, "RSSI: " + String(Rssi));
  display.display();

  // Assuming rxpacket contains the ASCII message:
  // "7E <txNumber> <timestamp> <Rssi> <sensorState> <crc>"
  // Parse <sensorState> from rxpacket.
  int sensorState = 1;  // Default value

  // Parse rxpacket (simple ASCII extraction, adjust if needed)
  char *token;
  token = strtok(rxpacket, " "); // "7E"
  token = strtok(NULL, " "); // txNumber
  token = strtok(NULL, " "); // timestamp
  token = strtok(NULL, " "); // Rssi
  token = strtok(NULL, " "); // sensorState
  if (token != NULL) {
      sensorState = atoi(token); // Now you've got it!
  }

  // Send sensorState 'and' RSSI + payload to Python server
  uint8_t packet[4];
  packet[0] = (uint8_t)(-Rssi);   // RSSI as positive number
  packet[1] = 0;                  // site ID high byte (customize)
  packet[2] = 1;                  // site ID low byte (customize)
  packet[3] = (uint8_t)sensorState; // sensorState (0 or 1)
  udp.beginPacket(udpAddress, udpPort);
  udp.write(packet, 4);
  udp.endPacket();

  Radio.Send((uint8_t *)txpacket, strlen(txpacket));
  state = STATE_TX;*/