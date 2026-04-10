#include <LiquidCrystal_I2C.h>
#include <Wire.h>

LiquidCrystal_I2C lcd(0x27, 16, 2);

const int greenLED = 8;
const int redLED = 9;

int rul_seconds =
    85; // Simulated Remaining Useful Life (RUL) countdown for the presentation!

void setup() {
  Serial.begin(9600);

  pinMode(greenLED, OUTPUT);
  pinMode(redLED, OUTPUT);

  lcd.init();
  lcd.backlight();

  // 1. Initial Static Splash Screen
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(" ML Diagnosis ");
  lcd.setCursor(0, 1);
  lcd.print(" Project ");

  digitalWrite(greenLED, HIGH);
  digitalWrite(redLED, HIGH);
  delay(2000);
  digitalWrite(greenLED, LOW);
  digitalWrite(redLED, LOW);

  // 2. Animated waiting loop (Blinks exactly 4 times)
  for (int i = 0; i < 4; i++) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Awaiting Sensor ");
    lcd.setCursor(0, 1);
    lcd.print(" Telemetry...   ");
    delay(600);

    lcd.clear();
    delay(400);

    // Safety break if you run MATLAB really fast!
    if (Serial.available() > 0)
      break;
  }

  // 3. Static Ready Message
  // Settles on a professional ready screen forever until MATLAB sends data
  if (Serial.available() == 0) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(" System Ready   ");
    lcd.setCursor(0, 1);
    lcd.print(" Awaiting Start ");
  }
}

void loop() {
  if (Serial.available() > 0) {
    String data = Serial.readStringUntil('\n');
    data.trim();

    // Check if MATLAB is sending a (H)ealthy message
    if (data.startsWith("H")) {
      digitalWrite(greenLED, HIGH);
      digitalWrite(redLED, LOW);

      // Extract the RUL number from string (e.g., "H,14250" -> "14250")
      int splitIndex = data.indexOf(',');
      String life_str = data.substring(splitIndex + 1);

      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Status: Healthy ");

      lcd.setCursor(0, 1);
      lcd.print("Est. life: ");
      lcd.print(life_str);
      lcd.print("h");
    } // Check if MATLAB is sending a (F)ault message
    else if (data.startsWith("F")) {
      digitalWrite(greenLED, LOW);
      digitalWrite(redLED, HIGH);

      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Status: CRITICAL");
      lcd.setCursor(0, 1);
      lcd.print("! BPFO FAULT !  ");
    }
  }
}
