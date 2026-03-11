%% ========================================================================
%  PHASE 1: OFFLINE ML TRAINING PIPELINE
%  Physics-Guided ML Fault Detection System for Induction Motors
%  ========================================================================
%  Description:
%    This script generates synthetic vibration data (healthy vs. outer-race
%    fault), extracts physics-informed spectral features at the Ball-Pass
%    Frequency (Outer Race) — BPFO, trains a binary SVM classifier, and
%    exports the model for Simulink Coder deployment.
%
%  CWRU Bearing Dataset Reference Constants Used:
%    Bearing: 6205-2RS JEM SKF  (Drive-end)
%    N = 9 rolling elements | d = 0.3126 in | D = 1.537 in | alpha = 0°
%    (We use the simplified values per the project specification.)
%
%  Author  : [Your Name]
%  Date    : 2026-03-08
%  MATLAB  : R2023b+ recommended (requires Statistics & ML Toolbox)
%  ========================================================================
clc; clear; close all;

%% =====================  1. SYSTEM CONSTANTS  ============================
Fs       = 12000;           % Sampling frequency [Hz]
duration = 1;               % Signal duration [s]
N_samp   = Fs * duration;   % Number of samples per record
t        = (0 : N_samp-1)' / Fs;   % Time vector (column)

% --- Bearing geometry (CWRU 6205-2RS) ---
N_balls  = 9;               % Number of rolling elements
fr       = 1750 / 60;       % Shaft rotational frequency [Hz] (1750 RPM)
d_ball   = 0.311;           % Ball diameter [inches]
D_pitch  = 1.5;             % Pitch diameter [inches]
alpha    = 0;               % Contact angle [radians]

%% =====================  2. PHYSICS ENGINE  ==============================
%  Kinematic bearing equation — Ball-Pass Frequency, Outer Race (BPFO):
%
%        f_BPFO = (N/2) * f_r * (1 - (d/D) * cos(alpha))
%
f_BPFO = (N_balls / 2) * fr * (1 - (d_ball / D_pitch) * cos(alpha));
fprintf('=== Physics Engine ===\n');
fprintf('Shaft speed         : %8.2f RPM  (%.4f Hz)\n', 1750, fr);
fprintf('Calculated f_BPFO   : %8.4f Hz\n\n', f_BPFO);

%% =====================  3. SYNTHETIC DATA GENERATION  ===================
%  We generate multiple records per class to give the SVM enough training
%  samples.  Each record is 1 second of vibration at 12 kHz.
%
%  Class 0 — Healthy    : White Gaussian noise only.
%  Class 1 — OR Fault   : Noise + periodic impulses at f_BPFO.
%  -----------------------------------------------------------------------

numRecords  = 50;           % Records per class (total = 100)
rng(42);                    % Reproducibility

% Pre-allocate storage
signals     = zeros(N_samp, 2 * numRecords);
labels      = zeros(2 * numRecords, 1);

for k = 1:numRecords
    % --- Healthy signal (pure noise) ---
    noise_h = 0.5 * randn(N_samp, 1);
    signals(:, k) = noise_h;
    labels(k)     = 0;                          % Label: Healthy

    % --- Outer-race fault signal ---
    noise_f = 0.5 * randn(N_samp, 1);
    % Periodic impulse train at f_BPFO
    impulse_train = 1.5 * sin(2 * pi * f_BPFO * t);
    % Add 2nd & 3rd harmonics (more realistic fault signature)
    impulse_train = impulse_train ...
                  + 0.75 * sin(2 * pi * 2 * f_BPFO * t) ...
                  + 0.35 * sin(2 * pi * 3 * f_BPFO * t);
    signals(:, numRecords + k) = noise_f + impulse_train;
    labels(numRecords + k)     = 1;             % Label: Faulty
end

fprintf('Generated %d records  (%d Healthy + %d Faulty)\n\n', ...
        2*numRecords, numRecords, numRecords);

%% =====================  4. SIGNAL PROCESSING (FFT)  =====================
%  Convert each time-domain record into its single-sided amplitude spectrum.
%  We keep only the positive-frequency half.

NFFT      = 2^nextpow2(N_samp);      % Zero-pad for FFT efficiency
freqAxis  = Fs * (0 : NFFT/2) / NFFT;  % Frequency axis [Hz]

% Storage for single-sided amplitude spectra
spectra = zeros(length(freqAxis), 2 * numRecords);

for k = 1 : (2 * numRecords)
    Y = fft(signals(:, k), NFFT) / N_samp;
    spectra(:, k) = 2 * abs(Y(1 : NFFT/2 + 1));
end

%% =====================  5. FEATURE EXTRACTION  =========================
%  Extract the spectral amplitude at f_BPFO.  We allow a ±2 Hz tolerance
%  window to account for spectral leakage / resolution limits.

tolerance_Hz = 2;           % Frequency tolerance window [Hz]
idx_band     = (freqAxis >= f_BPFO - tolerance_Hz) & ...
               (freqAxis <= f_BPFO + tolerance_Hz);

fprintf('Feature extraction window : [%.2f , %.2f] Hz\n', ...
        f_BPFO - tolerance_Hz, f_BPFO + tolerance_Hz);
fprintf('Frequency bins in window  : %d\n\n', sum(idx_band));

% Feature = maximum amplitude within the BPFO tolerance band
features = zeros(2 * numRecords, 1);
for k = 1 : (2 * numRecords)
    features(k) = max(spectra(idx_band, k));
end

%% =====================  6. VISUALISATION  ===============================
%  Quick sanity-check plots before training.

figure('Name', 'Phase 1 — Data Overview', 'NumberTitle', 'off', ...
       'Position', [100 100 1100 800]);

% --- (a) Time-domain comparison ---
subplot(2,2,1);
plot(t*1000, signals(:,1), 'b'); hold on;
plot(t*1000, signals(:, numRecords+1), 'r');
xlabel('Time [ms]'); ylabel('Amplitude');
title('Time Domain — Healthy (blue) vs Faulty (red)');
legend('Healthy', 'OR Fault'); grid on;

% --- (b) Frequency-domain comparison ---
subplot(2,2,2);
plot(freqAxis, spectra(:,1), 'b'); hold on;
plot(freqAxis, spectra(:, numRecords+1), 'r');
xline(f_BPFO, '--k', sprintf('f_{BPFO}=%.1f Hz', f_BPFO), ...
      'LabelOrientation', 'horizontal');
xlim([0 500]); xlabel('Frequency [Hz]'); ylabel('|X(f)|');
title('FFT Spectrum — Healthy vs Faulty');
legend('Healthy', 'OR Fault'); grid on;

% --- (c) Feature distribution ---
subplot(2,2,[3 4]);
histogram(features(labels==0), 15, 'FaceColor', [0.2 0.6 1]);  hold on;
histogram(features(labels==1), 15, 'FaceColor', [1 0.3 0.3]);
xlabel('Peak Amplitude at f_{BPFO}'); ylabel('Count');
title('Feature Distribution by Class');
legend('Healthy', 'OR Fault'); grid on;

%% =====================  7. SVM TRAINING  ================================
%  Train a binary SVM classifier.
%  Features matrix  : [numSamples × 1]   (single feature: BPFO amplitude)
%  Labels vector    : [numSamples × 1]   (0 = Healthy, 1 = Faulty)

fprintf('--- SVM Training ---\n');
SVMModel = fitcsvm(features, labels, ...
    'KernelFunction',   'rbf', ...
    'KernelScale',      'auto', ...
    'BoxConstraint',    1, ...
    'Standardize',      true, ...
    'ClassNames',       [0, 1]);

% Quick resubstitution accuracy (training set)
predLabels   = predict(SVMModel, features);
trainAcc     = sum(predLabels == labels) / numel(labels) * 100;
fprintf('Training accuracy   : %.2f %%\n', trainAcc);

% Confusion matrix
fprintf('\nConfusion Matrix (rows = actual, cols = predicted):\n');
C = confusionmat(labels, predLabels);
disp(C);

%% =====================  8. MODEL EXPORT (Simulink Coder)  ===============
%  saveLearnerForCoder stores the compact model in a .mat file that is
%  safe for C/C++ code generation (Simulink MATLAB Function blocks).
%
%  NOTE: Requires the compact model (no training data stored).

CompactSVMModel = compact(SVMModel);

modelFileName = 'mySVM';
saveLearnerForCoder(CompactSVMModel, modelFileName);
fprintf('\nModel exported  →  %s.mat   (Simulink Coder compatible)\n', ...
        modelFileName);

%% =====================  9. EXPORT KEY PARAMETERS  =======================
%  Save the BPFO and FFT parameters so the Simulink function block can
%  use the same physics constants without hard-coding duplicates.

params.Fs           = Fs;
params.NFFT         = NFFT;
params.f_BPFO       = f_BPFO;
params.tolerance_Hz = tolerance_Hz;
save('signal_params.mat', 'params');
fprintf('Signal parameters   →  signal_params.mat\n');

fprintf('\n===  Phase 1 complete.  ===\n');
