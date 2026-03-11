function faultFlag = detectFault(vibrationBuffer) %#codegen
%% ========================================================================
%  PHASE 2: ONLINE REAL-TIME FAULT DETECTION — Simulink MATLAB Function Block
%  ========================================================================
%  This function runs INSIDE a Simulink "MATLAB Function" block.
%  It receives a buffered vibration signal, computes the FFT, extracts the
%  spectral feature at f_BPFO, and classifies it using the pre-trained SVM.
%
%  INPUT  : vibrationBuffer — [12000 × 1] double  (1 s of data at 12 kHz)
%  OUTPUT : faultFlag       — int32  (0 = Healthy, 1 = Outer-Race Fault)
%
%  IMPORTANT SIMULINK CONSTRAINTS:
%    • Uses coder.load (NOT load) — required for code generation.
%    • Uses loadLearnerForCoder  — required for SVM in generated code.
%    • All constants are hard-coded (no workspace variable access).
%  ========================================================================

%% --- 1. Load the trained SVM model (Coder-safe, loads once) ---
%  coder.load is evaluated at compile time; the .mat file must be on the
%  MATLAB path or in the current directory when the model is built.
mdlStruct  = coder.load('mySVM.mat');                                      %#ok<NASGU>
SVMModel   = loadLearnerForCoder('mySVM');

%% --- 2. Physics & Signal Processing Constants ---
Fs           = 12000;                    % Sampling frequency [Hz]
N_samp       = 12000;                    % Buffer length (= Fs × 1 s)
NFFT         = 2^nextpow2(N_samp);       % FFT length (16384)

% Bearing geometry — CWRU 6205-2RS
N_balls      = 9;
fr           = 1750 / 60;               % Shaft speed [Hz]
d_ball       = 0.311;
D_pitch      = 1.5;
alpha        = 0;

% Ball-Pass Frequency, Outer Race
f_BPFO       = (N_balls / 2) * fr * (1 - (d_ball / D_pitch) * cos(alpha));

tolerance_Hz = 2;                        % ±2 Hz tolerance window

%% --- 3. FFT — Convert buffer to frequency domain ---
Y        = fft(vibrationBuffer, NFFT) / N_samp;
ampSpec  = 2 * abs(Y(1 : NFFT/2 + 1));  % Single-sided amplitude spectrum
freqAxis = Fs * (0 : NFFT/2)' / NFFT;   % Frequency axis [Hz]

%% --- 4. Feature Extraction — Peak amplitude at f_BPFO ±tolerance ---
idxBand  = (freqAxis >= (f_BPFO - tolerance_Hz)) & ...
           (freqAxis <= (f_BPFO + tolerance_Hz));

feature  = max(ampSpec(idxBand));        % Scalar feature for SVM

%% --- 5. SVM Classification ---
predictedLabel = predict(SVMModel, feature);

% Return as int32 for clean Simulink signal routing
faultFlag = int32(predictedLabel);

end
