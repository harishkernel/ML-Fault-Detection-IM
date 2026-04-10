# ⚙️ Physics-Guided ML Fault Detection for Induction Motors

A **System-Level Digital Twin + Hardware-in-the-Loop (HIL)** project that uses physics-informed machine learning to detect **outer-race bearing faults** in induction motors in real time. 

This repository contains the complete production-ready source code, integrating structural vibration simulation, SVM machine learning intelligence, and a live serial bridge to an physical Arduino LCD dashboard.

---

## 📖 Overview

Bearing failures account for nearly 40% of induction motor breakdowns. This project builds a fault detection system that:
1. **Generates synthetic vibration data** simulating mechanical fault characteristics.
2. **Extracts critical spectral features**, primarily the Ball-Pass Frequency (Outer Race) — `f_BPFO`.
3. **Trains a 3-Dimensional Support Vector Machine (SVM)** classifier using Statistical/Signal features (RMS, Kurtosis, BPFO Peaks).
4. **Bridges MATLAB & Hardware** connecting the ML intelligence directly to an Arduino-powered physical LCD for real-time Remaining Useful Life (RUL) forecasting.

---

## 📂 Project Structure

| File / Folder | Role in System |
|---|---|
| `generate_motor_data.m` | **Data Engine:** Simulates 12kHz motor vibrations and physics conditions; builds root `.mat` Datasets. |
| `train_svm_model.m` | **AI Training:** Reads generated data, extracts the 3D IEEE features, and trains `mySVM.mat` using 5-Fold Validation. |
| `matlab_simulation_IM.slx` | **Digital Twin:** A Simulink canvas modeling the physical block systems (if visual modeling is preferred). |
| `Arduino_Hardware_Integration/` | **HIL Connectors:** Houses the `.ino` Arduino LCD Sketch and the vital `run_live_svm_bridge.m` real-time simulation script. |
| `assets/` | Contains reference charts of the expected output vibration mappings. |

---

## 🚀 Getting Started

### 📋 Prerequisites
- **MATLAB R2023b** (or later) with Statistics & Machine Learning Toolbox.
- **Arduino IDE** with a compatible Microcontroller connected via USB (Any standard board).
- Simple 16x2 I2C LCD connected to the Arduino (for the HIL Dashboard display).

---

### Step 1: Pre-Train the Machine Learning Model
The simulation requires the SVM model to be compiled locally first.
1. Open MATLAB and navigate to this repository's root folder.
2. Open and hit **Run** on `generate_motor_data.m` *(this simulates 100 datasets of physics data)*.
3. Once completed, Open and hit **Run** on `train_svm_model.m`. 
   > This extracts the IEEE features and compiles a highly robust `mySVM.mat` brain.

### Step 2: Flash the Physical Hardware 
Before starting the live diagnostic bridge, the peripheral must be ready.
1. Navigate into the `Arduino_Hardware_Integration/Phase4_LCD_HIL_I2C` folder.
2. Open **`Phase4_LCD_HIL_I2C.ino`** using the standard Arduino IDE.
3. Check your COM Port, compile/upload it to your board.
4. Open the Arduino Serial Monitor and wait until it successfully prints: **`OK`**.
   > *Leave the Serial Monitor open or the Arduino plugged in.*

### Step 3: Launch the Live Dashboard (HIL)
1. Head back into MATLAB and navigate into the `Arduino_Hardware_Integration/Phase4_LCD_HIL_I2C/` folder.
2. Open the **`run_live_svm_bridge.m`** script.
3. Ensure the **`arduinoPort`** variable matches your exact COM Port (e.g., `"COM3"`).
4. **Click RUN!** 
   > A live Diagnostic Dashboard UI will open inside MATLAB charting the frequency/time domains while simultaneously broadcasting predictive statuses & Remaining Useful Life (RUL) strings dynamically to your Arduino's LCD Screen!

---
*Created for Academic/Industrial Demonstration built upon realistic CWRU-equivalent kinematics.*
