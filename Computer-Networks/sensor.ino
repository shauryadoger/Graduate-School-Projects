/*
Sample code for sensor
*/

#include <Wire.h>
#include "HT_SSD1306Wire.h"        // OLED display driver
//#include "OLEDDisplayFonts.h"   // Font definitions like ArialMT_Plain_10
#include "LoRaWan_APP.h"        // Heltec LoRa library
#include "Arduino.h"

// Initialize the OLED display
//static SSD1306Wire display(0x3c, SDA_OLED, SCL_OLED, GEOMETRY_128_64, RST_OLED);
static SSD1306Wire display(0x3c, 500000, SDA_OLED, SCL_OLED, GEOMETRY_128_64, RST_OLED);

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
#define IR_SENSOR_PIN 4 //GPIO 4
#define WINDOW_SIZE 10
#define TIMEOUT_MS 3000

//Packet struct to contain all the detailed information
struct Packet {
  int seq;
  int sensorState;
  uint8_t crc;
  unsigned long timestamp;
  bool sent;
  bool acked;
  unsigned long lastSendTime;
  char payload[BUFFER_SIZE];
};

Packet window[WINDOW_SIZE];
int baseSeq = 0;
int nextSeq = 0;

char txpacket[BUFFER_SIZE]; //Transmission Packet
char rxpacket[BUFFER_SIZE]; //Recieving Packet

static RadioEvents_t RadioEvents;
void OnTxDone( void );
void OnTxTimeout( void );
void OnRxDone( uint8_t *payload, uint16_t size, int16_t rssi, int8_t snr );

//Define possible states for the sensors
typedef enum
{
    LOWPOWER, //Low-Power
    STATE_RX, //Recieving State
    STATE_TX  //Transmitting State
} States_t;

int16_t txNumber;
States_t state;
bool sleepMode = false;
int16_t Rssi, rxSize;
bool packetDropped = false;

//Dynamically powers on external devices if connected via Ve
void VextON(void) {
  pinMode(Vext, OUTPUT);
  digitalWrite(Vext, LOW);
}

//Dynamically powers off external devices if connected via Ve for enery savings
void VextOFF(void) {
  pinMode(Vext, OUTPUT);
  digitalWrite(Vext, HIGH);
}

//Timing variables
unsigned long t2 = 0, t3 = 0;
unsigned long delta_t32 = 0;

//Sets up the sensor board for configurations to the IR sensor pin
void setup() {
  pinMode(IR_SENSOR_PIN, INPUT);
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

//Calculate Cyclical Redundancy Check for purposes of error detection
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


bool channelEmulator(char *packet) {
  float probability = 0.2;
  if (random(100) < (probability * 100)) {
    packet[0] ^= (1 << 7); // Flip the 8th MSB bit
    packetDropped = true;
  }
  return packetDropped;
}

unsigned long lastStateChangeTime = 0;
const unsigned long RX_TIMEOUT_MS = 3000; // 3 seconds--adjust as needed

//Execute the loop as according to the following states shwon in switch-case statements
void loop() {

  // Fill window with new packets if space
  while (nextSeq < baseSeq + WINDOW_SIZE) {
    int i = nextSeq % WINDOW_SIZE;
    window[i].seq = nextSeq;
    window[i].sensorState = digitalRead(IR_SENSOR_PIN);
    window[i].timestamp = millis();

    // Format payload and CRC
    sprintf(window[i].payload, "DATA %d %lu %d", window[i].seq, window[i].timestamp, window[i].sensorState);
    window[i].crc = calculateCRC4(window[i].payload);
    window[i].sent = false; window[i].acked = false;
    nextSeq++;
  }

  // Send unacked packets (new or due to timeout)
  for (int i = 0; i < WINDOW_SIZE; ++i) {
    int idx = (baseSeq + i) % WINDOW_SIZE;
    if (window[idx].sent && window[idx].acked) continue;
    if (!window[idx].sent || (millis() - window[idx].lastSendTime > TIMEOUT_MS)) {
      // Send (seq, timestamp, sensor, CRC)
      char txpacket[BUFFER_SIZE];
      sprintf(txpacket, "DATA %d %lu %d %d", window[idx].seq, window[idx].timestamp, window[idx].sensorState, window[idx].crc);
      Radio.Send((uint8_t *)txpacket, strlen(txpacket));
      window[idx].sent = true;
      window[idx].lastSendTime = millis();
    }
  }

  unsigned long timestamp, crc; // Declare timestamp at the beginning of the loop

  switch(state) {
    case STATE_TX: {
      lastStateChangeTime = millis();   // Record when you enter TX
      txNumber++;
      timestamp = millis(); // Initialize timestamp here
      int sensorState = digitalRead(IR_SENSOR_PIN);  // 0 = obstacle detected, 1 = clear
      sprintf(txpacket, "7E %d %lu %d %d", txNumber, timestamp, Rssi, sensorState);
      crc = calculateCRC4(txpacket);
      sprintf(txpacket + strlen(txpacket), " %d", crc); // Append CRC to the packet
      packetDropped = false;
      packetDropped = channelEmulator(txpacket); // Emulate channel with packet drop rate
      display.clear();
      display.drawString(0, 0, "Sending packet:");
      display.drawString(0, 10, txpacket);
      display.drawString(0, 20, packetDropped ? "packet dropped!" : "packet correctly");
      display.drawString(0, 30, sensorState == 0 ? "Obstacle!" : "Clear path"); //O
      display.display();
      delay(1000);
      Radio.Send((uint8_t *)txpacket, strlen(txpacket));
      state = LOWPOWER;
      break;
    }

    case STATE_RX:
      lastStateChangeTime = millis();   // Record when you enter RX
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

  // Timeout logic to force exit from RX/LOWPOWER if stuck
  if ((state == STATE_RX || state == LOWPOWER) &&
      (millis() - lastStateChangeTime > RX_TIMEOUT_MS)) {
    state = STATE_TX; // Force re-send and OLED update
    display.clear();
    display.drawString(0, 0, "Timeout! Restart TX.");
    display.display();
    delay(700); // Keep message visible
  }
  
}

//Execute when transmission is complete
void OnTxDone(void) {
  display.clear();
  display.drawString(0, 0, "TX done...");
  display.display();
  state = STATE_RX;
}

//Execute if there is a transmission timeout
void OnTxTimeout(void) {
  Radio.Sleep();
  display.clear();
  display.drawString(0, 0, "TX Timeout...");
  display.display();
  state = STATE_TX;
}

//Execute if sensor is done with its recieving mode
void OnRxDone(uint8_t *payload, uint16_t size, int16_t rssi, int8_t snr) {
  Rssi = rssi;
  rxSize = size;
  memcpy(rxpacket, payload, size);
  rxpacket[size] = '\0';

  // Parse for PING
  char packetType[10];
  int seq;
  unsigned long sentT1;
  int scanned = sscanf(rxpacket, "%s %d %lu", packetType, &seq, &sentT1);

  //Check for latency
  if (scanned == 3 && strcmp(packetType, "PING") == 0) {
    t2 = millis();
    // Sensor logic can be here if needed

    t3 = millis();
    delta_t32 = t3 - t2;

    char txpacket[BUFFER_SIZE];
    sprintf(txpacket, "PONG %d %lu %lu %lu %lu", seq, sentT1, t2, t3, delta_t32);

    display.clear();
    display.drawString(0, 0, "Reply with Δt32");
    display.drawString(0, 10, txpacket);
    display.drawString(0, 24, "Δt32=" + String(delta_t32) + " ms");
    display.display();

    Radio.Send((uint8_t *)txpacket, strlen(txpacket));
    
  } else {
  
    //Check if conditions are positive or negative ACK
    if (strncmp(rxpacket, "ACK", 3) == 0) {
      // Parse seq number
      char *token = strtok(rxpacket, " "); // ACK
      token = strtok(NULL, " ");
      int ackSeq = (token) ? atoi(token) : -1;
      int winIdx = ackSeq % WINDOW_SIZE;
      if (ackSeq >= baseSeq) {
        window[winIdx].acked = true;
        // Slide window
        while(window[baseSeq % WINDOW_SIZE].acked && baseSeq < nextSeq) {
          window[baseSeq % WINDOW_SIZE].sent = false;
          baseSeq++;
        }
      }
    } else if (strncmp(rxpacket, "NAK", 3) == 0) {
      char *token = strtok(rxpacket, " "); // NAK
      token = strtok(NULL, " ");
      int nakSeq = (token) ? atoi(token) : -1;
      int winIdx = nakSeq % WINDOW_SIZE;
      // Resend that packet
      char txpacket[BUFFER_SIZE];
      sprintf(txpacket, "DATA %d %lu %d %d", window[winIdx].seq, window[winIdx].timestamp, window[winIdx].sensorState, window[winIdx].crc);
      Radio.Send((uint8_t *)txpacket, strlen(txpacket));
      window[winIdx].sent = true; window[winIdx].lastSendTime = millis();
    }  

    display.clear();
    display.drawString(0, 0, "Received packet:");
    display.drawString(0, 10, rxpacket);
    display.display();
  }

  Radio.Sleep();
  state = STATE_TX;
}