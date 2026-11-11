%% =========================================================================
% SCRIPT: compare_ber_simulink.m
% Description: Sweeps across SNR (0:3:39 dB), runs the Simulink model 'lab9'
%              for each SNR point, records the BER, computes theoretical BER,
%              and plots the comparison (matching Lab 6 & Lab 8 lab structure).
% =========================================================================

clc;
clear;
close all;

%% 1. Simulation Parameters
N = 16;                     % Number of OFDM subcarriers
L = 3;                      % Channel length L (match with your model)
cp = L - 1;                 % Cyclic prefix length
Niter = 500;                % Iterations per SNR point (500 gives fast, accurate results)

snrdb = 0:3:39;             % SNR range in dB (14 points)
snrlin = 10.^(snrdb / 10);  % Linear SNR

% Pre-allocate BER array for all 14 SNR points
ber_sim = zeros(1, length(snrdb));

%% 2. Load Simulink Model
modelName = 'lab9';

if ~bdIsLoaded(modelName)
    load_system(modelName);
end

% Configure solver: Fixed-step of 1 so each time step is 1 OFDM symbol
set_param(modelName, ...
    'SolverType', 'Fixed-step', ...
    'Solver', 'FixedStepAuto', ...
    'FixedStep', '1', ...
    'StopTime', num2str(Niter));

fprintf('Starting Simulink simulation sweep across %d SNR points (0 to 39 dB)...\n', length(snrdb));
fprintf('Iterations per SNR point: %d OFDM symbols\n\n', Niter);

%% 3. SNR Sweep Loop (One SNR at a time, exactly like Lab 6 & Lab 8)
for i = 1:length(snrdb)
    % Compute SCALAR noise standard deviation for this specific SNR point
    nstd = 1 / sqrt(2 * N * snrlin(i));
    
    % Push scalar nstd into base workspace for the Constant block
    assignin('base', 'nstd', nstd);
    assignin('base', 'L', L);
    assignin('base', 'cp', cp);

    % Clear persistent variables in MATLAB Function blocks for a fresh run
    clear functions;

    % Run the Simulink model for this SNR point
    out = sim(modelName);

    % Extract simulated BER from To Workspace block ('simout')
    if isprop(out, 'simout')
        raw = out.simout;
    elseif isfield(out, 'simout')
        raw = out.simout;
    else
        raw = evalin('base', 'simout');
    end

    % Extract scalar BER value (handles Timeseries, Array, or Struct)
    if isa(raw, 'timeseries')
        data_vals = raw.Data;
    elseif isstruct(raw)
        data_vals = raw.signals.values;
    else
        data_vals = raw;
    end
    
    % If cumulative (persistent accumulator), take the last converged value:
    % If instantaneous, take the average over all steps:
    if size(data_vals, 1) > 1
        ber_sim(i) = data_vals(end); % Last accumulated value
    else
        ber_sim(i) = data_vals;
    end

    fprintf('  SNR = %2d dB (%2d/%2d) | Simulink BER = %.6f\n', ...
        snrdb(i), i, length(snrdb), ber_sim(i));
end

%% 4. Theoretical BER Calculation (BPSK over Rayleigh Fading)
theoretical = 0.5 * (1 - sqrt(snrlin ./ (1 + snrlin)));

%% 5. Plot Comparison: Simulink vs Theoretical
figure('Name', 'BER Comparison: Simulink vs Theoretical', ...
       'Color', [1 1 1], 'Position', [150 150 850 550]);

% Replace 0 with NaN so semilogy connects points properly
ber_plot = ber_sim;
ber_plot(ber_plot == 0) = NaN;

semilogy(snrdb, ber_plot, '-+b', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
semilogy(snrdb, theoretical, '-or', 'LineWidth', 2, 'MarkerSize', 7);
grid on;

xlim([0 39]);
ylim([1e-4 1]);

xlabel('SNR (dB)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Bit Error Rate (BER)', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('BER vs SNR for BPSK OFDM (Simulink vs Theoretical, L = %d, CP = %d)', L, cp), ...
    'FontSize', 13, 'FontWeight', 'bold');
legend('Simulated BER (Simulink)', 'Theoretical BER', ...
    'Location', 'southwest', 'FontSize', 11);

%% 6. Display Comparison Summary Table
disp(' ');
disp('================================================================');
disp('                    BER RESULTS COMPARISON                      ');
disp('================================================================');
fprintf('%-10s | %-16s | %-16s\n', 'SNR (dB)', 'Simulink BER', 'Theoretical BER');
disp('----------------------------------------------------------------');
for k = 1:length(snrdb)
    fprintf('%-10.1f | %-16.6f | %-16.6f\n', snrdb(k), ber_sim(k), theoretical(k));
end
disp('================================================================');
