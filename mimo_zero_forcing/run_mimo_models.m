% Run both supplied models and plot BER. Can be run from any current folder.
folder = fileparts(mfilename('fullpath'));
if ~isfile(fullfile(folder, 'mimo_2x2_zf.slx')) || ...
        ~isfile(fullfile(folder, 'mimo_4x4_zf.slx'))
    run(fullfile(folder, 'build_mimo_models.m'));
end
load_system(fullfile(folder, 'mimo_2x2_zf.slx'));
load_system(fullfile(folder, 'mimo_4x4_zf.slx'));
out2 = sim('mimo_2x2_zf', 'ReturnWorkspaceOutputs', 'on');
out4 = sim('mimo_4x4_zf', 'ReturnWorkspaceOutputs', 'on');
ber_2x2 = out2.get('ber_2x2');
ber_4x4 = out4.get('ber_4x4');
snrdb_2x2 = out2.get('snrdb_2x2');
snrdb_4x4 = out4.get('snrdb_4x4');
figure('Name', 'MIMO Zero Forcing BER');
semilogy(snrdb_2x2(:), ber_2x2(:), '-+', ...
    snrdb_4x4(:), ber_4x4(:), '-o', 'LineWidth', 1.5);
grid on;
xlabel('SNR (dB)'); ylabel('Bit Error Rate (BER)');
title('BPSK over Rayleigh fading with Zero Forcing detection');
legend('2x2 MIMO', '4x4 MIMO', 'Location', 'southwest');
save(fullfile(folder, 'mimo_ber_results.mat'), ...
    'snrdb_2x2', 'snrdb_4x4', 'ber_2x2', 'ber_4x4');
