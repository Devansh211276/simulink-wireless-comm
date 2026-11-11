clc;
clear all;
close all;

% Set channel length (1 to 16)
L = 2; 

modelName = 'OFDM_Simulink';

% Load Simulink model into memory
load_system(modelName);

% Update the Constant block value with L
set_param([modelName, '/Constant'], 'Value', num2str(L));

fprintf('Running OFDM BPSK Simulation via Simulink for L = %d...\n', L);
out = sim(modelName);

% Extract BER results from To Workspace blocks
if isprop(out, 'ber1')
    ber1 = out.ber1(end, :);
    theoretical = out.theoretical(end, :);
else
    ber1 = out.get('ber1');
    theoretical = out.get('theoretical');
    if size(ber1, 1) > 1
        ber1 = ber1(end, :);
        theoretical = theoretical(end, :);
    end
end

snrdb = 0:3:39;

% Plotting results
figure('Name', 'OFDM BPSK Simulink Results', 'NumberTitle', 'off');
semilogy(snrdb, ber1, '-+', 'LineWidth', 2);
hold on;
semilogy(snrdb, theoretical, 'r-o', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title(['BER vs SNR for BPSK OFDM (Simulink), L = ', num2str(L)]);
legend('Simulated BER (Simulink)', 'Theoretical BER');

% Display outputs to command window
disp('Channel length L:');
disp(L);

disp('Cyclic prefix length:');
disp(L - 1);

disp('Simulated BER:');
disp(ber1);

disp('Theoretical BER:');
disp(theoretical);
