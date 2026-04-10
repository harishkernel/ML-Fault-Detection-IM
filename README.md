# Induction Motor Fault Detection & Hardware-in-the-Loop (HIL) Project

## **Step 1: Train the Machine Learning Model**
Before running the live bridge, you must ensure the 3-feature SVM model is generated from your dataset.
1. Open MATLAB and navigate to the project root folder.
2. Open and run **`train_svm_model.m`**.
3. Wait for it to finish. This will generate a fresh `mySVM.mat` (the 3D Feature Map model) in your root folder.

## **Step 2: Start the Arduino Hardware**
1. Navigate to the `Arduino_Hardware_Integration/Phase4_LCD_HIL_I2C` folder.
2. Open the **`Phase4_LCD_HIL_I2C.ino`** file using the Arduino IDE.
3. Compile and upload it to your connected Arduino board.
4. Open the Serial Monitor in the Arduino IDE and wait until it prints **"OK"**. Leave the Arduino plugged in.

## **Step 3: Run the Live MATLAB-Arduino Bridge**
1. Once the Arduino says "OK", return to MATLAB.
2. Navigate into the `Arduino_Hardware_Integration/Phase4_LCD_HIL_I2C` folder inside MATLAB.
3. Open the **`run_live_svm_bridge.m`** script.
4. Click **"RUN"**. You will see the Live Motor Diagnostics Dashboard appear, and results will be simultaneously sent to the Arduino's LCD screen!

*(Note: If you need to re-generate the underlying dataset from scratch, you can run `generate_motor_data.m` in the root folder before Step 1).*
