# ⚙️ Physics-Guided ML Fault Detection for Induction Motors

A **Simulink + MATLAB** project that uses physics-informed machine learning to detect **outer-race bearing faults** in induction motors in real time. Built as part of the Innovation Lab coursework (Semester 6, EEC).

---

## Overview

Bearing failures account for nearly 40% of induction motor breakdowns. This project builds a **digital twin**-based fault detection system that:

1. **Computes the Ball-Pass Frequency (Outer Race)** — `f_BPFO` — using bearing kinematics (CWRU 6205-2RS dataset parameters).
2. **Generates synthetic vibration data** for healthy and faulty bearings.
3. **Extracts spectral features** at `f_BPFO` via FFT.
4. **Trains an SVM classifier** to distinguish healthy vs. faulty signals.
5. **Deploys the model in Simulink** for real-time classification.

### System Architecture

```
┌──────────────┐     ┌──────────┐     ┌─────────────────────┐     ┌─────────┐
│ From         │     │          │     │   MATLAB Function   │     │ Display │
│ Workspace    │────►│  Buffer  │────►│  (Phase 2 Code)     │──┬─►│  (0/1)  │
│ (simInput)   │     │ (12000)  │     │                     │  │  └─────────┘
└──────────────┘     └──────────┘     │  FFT → Feature →   │  │  ┌─────────┐
                                      │  SVM → faultFlag    │  ├─►│  Scope  │
                                      └─────────────────────┘  │  └─────────┘
                                                               │  ┌─────────┐
                                                               └─►│  Lamp   │
                                                                  └─────────┘
```

---

## Project Structure

| File | Description |
|------|-------------|
| `phase1_offline_training.m` | Offline ML pipeline — data generation, FFT, feature extraction, SVM training, and model export |
| `phase2_simulink_function.m` | Real-time MATLAB Function block code for Simulink — performs FFT + SVM classification on buffered vibration data |
| `phase3_simulink_guide.md` | Step-by-step guide to assemble the Simulink model (block wiring, configuration, troubleshooting) |
| `generate_experiment_reports.py` | Python script to auto-generate experiment report documents |
| `generate_ppt_light.py` | Python script to generate the project presentation |
| `Experiment_1_Problem_Identification.docx` | Experiment 1 — Problem identification and literature survey |
| `Experiment_2_Concept_Design.docx` | Experiment 2 — Concept design and feasibility analysis |
| `Experiment_3_System_Architecture.docx` | Experiment 3 — System architecture and detailed design |
| `FaultDetection_Presentation.pptx` | Final project presentation |

---

## Getting Started

### Prerequisites

- **MATLAB R2023b** or later
- **Statistics and Machine Learning Toolbox** (for `fitcsvm`, `loadLearnerForCoder`)
- **DSP System Toolbox** (for the Buffer block in Simulink)
- **Simulink**

### Run the Project

**Step 1 — Train the model (offline):**

```matlab
>> cd 'path/to/this/repo'
>> phase1_offline_training
```

This generates:
- `mySVM.mat` — trained SVM model (Coder-compatible)
- `signal_params.mat` — physics and FFT parameters
- Visualization plots for sanity checking

**Step 2 — Build the Simulink model:**

Follow the detailed instructions in [`phase3_simulink_guide.md`](phase3_simulink_guide.md) to wire the digital twin on the Simulink canvas.

**Step 3 — Run the simulation:**

Press **Run (▶)** in Simulink. The Display block will show `0` (Healthy) or `1` (Outer-Race Fault).

---

## 🔬 Technical Details

### Bearing Parameters (CWRU 6205-2RS)

| Parameter | Value |
|-----------|-------|
| Rolling elements | 9 |
| Ball diameter | 0.311 in |
| Pitch diameter | 1.5 in |
| Contact angle | 0° |
| Shaft speed | 1750 RPM |
| Sampling rate | 12 kHz |

### ML Pipeline

- **Feature**: Peak spectral amplitude at `f_BPFO ± 2 Hz`
- **Classifier**: SVM with RBF kernel (auto-scaled, standardized)
- **Training data**: 100 synthetic records (50 healthy + 50 faulty)
- **Training accuracy**: ~100%

---

## 📄 License

This project was developed for academic purposes as part of the EEC Innovation Lab curriculum.

---

## Author

**Harish** — B.E. Electrical and Electronics Engineering
