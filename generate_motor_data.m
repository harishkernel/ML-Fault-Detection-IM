%% ========================================================================
%  SCRIPT 1: SYNTHETIC MOTOR VIBRATION DATA GENERATOR (IEEE REALISTIC)
%  ========================================================================
%  Description: Generates heavily noisy, realistic industrial vibration 
%  records. Features variable Signal-to-Noise Ratios and load fluctuations 
%  to test the SVM realistically rather than achieving a fake 100%.
%  ========================================================================
clc; clear; close all;

Fs       = 12000;           
duration = 1;               
N_samp   = Fs * duration;   
t        = (0 : N_samp-1)' / Fs;   

N_balls  = 9; fr = 1750 / 60; d_ball = 0.311; D_pitch = 1.5; alpha = 0;               
f_BPFO = (N_balls / 2) * fr * (1 - (d_ball / D_pitch) * cos(alpha));

fprintf('Generating Realistic IEEE Motor Telemetry...\n');
numRecords  = 150; % Total 300 records for realistic ML training          
rng(42); % For reproducibility                    

signals     = zeros(N_samp, 2 * numRecords);
labels      = zeros(2 * numRecords, 1);

for k = 1:numRecords
    % Random dynamic load (motor running between 60% and 100% capacity)
    loadFactor = 0.6 + (0.4 * rand());
    % Random environmental factory noise
    noiseLevel = 0.5 + (1.2 * rand()); 
    
    % --- 1. Healthy Drivetrain ---
    baseRotation = loadFactor * sin(2*pi*30*t);
    signals(:, k) = (noiseLevel * randn(N_samp, 1)) + baseRotation;
    labels(k)     = 0;

    % --- 2. Faulty Drivetrain (BPFO) ---
    % The fault might be subtle (weak impulse) or severe (heavy impulse)
    faultSeverity = 0.8 + (1.5 * rand());
    noise_f = (noiseLevel * randn(N_samp, 1)) + baseRotation;
    
    % BPFO impact + varying modulation
    impulse_train = faultSeverity * sin(2 * pi * f_BPFO * t) .* (1 + (0.3*rand())*cos(2*pi*30*t));
    
    signals(:, numRecords + k) = noise_f + impulse_train;
    labels(numRecords + k)     = 1;             
end

save('raw_motor_dataset.mat', 'signals', 'labels', 'Fs', 'N_samp', 'f_BPFO', 't');
fprintf('Realistic Dataset generated and saved: raw_motor_dataset.mat\n');
