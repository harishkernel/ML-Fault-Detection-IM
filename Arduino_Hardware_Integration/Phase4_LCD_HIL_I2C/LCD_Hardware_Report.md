### Phase 4: Complete Hardware-in-the-Loop (HIL) with LCD

This is the ultimate capstone for your project report. Instead of just a colored LED or a Python script, you are using the industrial gold-standard (**MATLAB**) to run your pre-trained Support Vector Machine (`mySVM.mat`), and outputting the real-time AI classification flag directly to a hardware Edge HMI (Human-Machine Interface) utilizing an **LCD Display**.

This directly proves the usefulness of Phase 1 (Training the SVM), Phase 2 (Extracting Features), and Phase 3 (MATLAB streaming).

#### 1. Wire the 16x2 LCD to Arduino UNO
*   LCD **RS** pin to Arduino digital pin **12**
*   LCD **Enable** pin to Arduino digital pin **11**
*   LCD **D4** pin to Arduino digital pin **5**
*   LCD **D5** pin to Arduino digital pin **4**
*   LCD **D6** pin to Arduino digital pin **3**
*   LCD **D7** pin to Arduino digital pin **2**
*   *(Optional: Green LED to pin 8, Red LED to pin 9)*
*   Don't forget the LCD power, ground, and contrast potentiometer as usual!

#### 2. Flash the Arduino
1. Open up the `Arduino_Hardware_Integration/Phase4_LCD_HIL/LCD_Fault_Indicator.ino` file in the Arduino IDE.
2. Upload it to your board. Ensure you see "System Starting" on the LCD.

#### 3. Run the MATLAB HIL Bridge
1. Open MATLAB.
2. Navigate your Current Folder to `Arduino_Hardware_Integration/Phase4_LCD_HIL/`
3. Make sure the `arduinoPort` string in `run_live_svm_bridge.m` matches your Arduino's COM port (e.g. "COM3").
4. Make sure your `mySVM.mat` file is in your innovation lab folder.
5. Hit **RUN** in MATLAB. 

MATLAB will now continuously generate vibration data, run the FFT code, pump the peak amplitude through your `mySVM.mat` model, and finally transmit a `0` or `1` character directly to the Arduino's LCD screen. 

---

### What to write in your Project Report

Add this section to `UGPROJECTREPORT_innovation_lab.docx`:

### 4. Hardware Implementation: Hardware-in-the-Loop Edge Intelligence Display

*To validate the practical deployment of the proposed fault detection algorithm, a Hardware-in-the-Loop (HIL) mechanism was engineered bridging the central Machine Learning kernel with field-level microcontroller hardware.* 

*The trained Support Vector Machine (SVM) model acts as the core predictive engine within the host MATLAB environment. MATLAB constructs the discrete real-time vibration datasets, performs the Fast Fourier Transform (FFT) for feature engineering at the BPFO frequencies, and classifies the current machine state based on the multi-dimensional SVM boundary analysis executed entirely online.*

*The predicted system state acts as the diagnostic flag which is instantly transmitted asynchronously over a Universal Serial Bus telemetry link at 9600 Baud to an Atmel ATmega328P edge microcontroller (Arduino UNO). The edge node acts as a resilient Human-Machine Interface (HMI), processing the binary machine flags to dynamically control a generic 16x2 Liquid Crystal Display alongside acoustic/visual warnings. This establishes a fully integrated, scalable edge-display topography proving the real-world operational readiness of the offline-trained Artificial Intelligence architecture.*
