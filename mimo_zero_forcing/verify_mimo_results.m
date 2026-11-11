function verify_mimo_results
% Check full-run results and export model diagrams for inspection.
folder = fileparts(mfilename('fullpath'));
data = load(fullfile(folder, 'mimo_ber_results.mat'));
snrdb = 0:5:40;
rho = 10.^(snrdb/10);
% Square iid complex Rayleigh ZF has exponential post-ZF per-stream SNR.
theory = 0.5*(1-sqrt(rho./(1+rho)));
reportPath = fullfile(folder, 'validation.txt');
fid = fopen(reportPath, 'w');
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, 'MATLAB %s\nN = 1000000 symbols per stream per SNR\n', version);
fprintf(fid, 'SNR_dB        BER_2x2        BER_4x4        Theory\n');
fprintf(fid, '%6.0f    %12.7g    %12.7g    %12.7g\n', ...
    [snrdb; data.ber_2x2(:).'; data.ber_4x4(:).'; theory]);
for nt = [2 4]
    suffix = sprintf('%dx%d', nt, nt);
    ber = data.(['ber_' suffix]);
    loggedSnr = data.(['snrdb_' suffix]);
    assert(numel(ber)==9 && all(isfinite(ber(:))));
    assert(isequal(loggedSnr(:), snrdb(:)));
    assert(all(ber(:)>=0 & ber(:)<=1));
    % Broad Monte Carlo check: count uncertainty plus allowance for stream
    % correlation within a channel realization. No exact random match assumed.
    tolerance = 8*sqrt(theory.*(1-theory)/1e6) + 5e-6;
    assert(all(abs(ber(:).'-theory) < tolerance));
    model = ['mimo_' suffix '_zf'];
    load_system(fullfile(folder, [model '.slx']));
    assert(strcmp(get_param([model '/N_symbols'], 'Value'), '1e6'));
    assert(strcmp(get_param(model, 'StopTime'), '0'));
    assert(numel(find_system(model, 'SearchDepth', 1, 'BlockType', 'Constant'))==2);
    assert(numel(find_system(model, 'SearchDepth', 1, 'BlockType', 'Display'))==1);
    assert(numel(find_system(model, 'SearchDepth', 1, 'BlockType', 'ToWorkspace'))==2);
    print(['-s' model], '-dpng', '-r150', fullfile(folder, [model '_diagram.png']));
    fprintf(fid, '%s: compiled and simulated; arrays, configuration, and BER sanity checks passed.\n', model);
end
fprintf('Validation passed. Report: %s\n', reportPath);
end
