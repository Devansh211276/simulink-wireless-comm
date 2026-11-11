# Simulink MIMO Zero Forcing models

Open `mimo_2x2_zf.slx` or `mimo_4x4_zf.slx` in MATLAB/Simulink and click **Run**.
The models were created with MATLAB R2024b. MATLAB and Simulink are required;
no Communications Toolbox blocks are used.

Each model uses only:

- Two **Constant** blocks: `N_symbols = 1e6` and `SNR_dB = 0:5:40`.
- One **MATLAB Function** block containing BPSK generation, the Rayleigh channel,
  complex Gaussian noise, Zero Forcing detection, and BER calculation.
- One **Display** block showing the nine BER values in increasing SNR order.
- Two **To Workspace** blocks saving the BER and SNR vectors as arrays.

Connections:

```text
N_symbols -----+
SNR_dB --------+--> MATLAB Function --> Display (BER)
                                   +--> To Workspace (BER)
SNR_dB -------------------------------> To Workspace (SNR)
```

The MATLAB Function block contains its code inside the `.slx` file. The separate
`zf_sweep_2x2.m` and `zf_sweep_4x4.m` files are readable copies used by the builder;
they are not required to run the existing models.

## Run and plot

1. Open either model and press **Run**. Keep **Stop time = 0**. This intentionally
   executes one complete Monte Carlo sweep at time zero. A simulation can take
   time even though its stop time is zero; the Display updates after the sweep.
2. The 2x2 model saves `ber_2x2` and `snrdb_2x2` to the MATLAB workspace. The 4x4
   model saves `ber_4x4` and `snrdb_4x4`. The model settings disable **Single
   simulation output** so these variables are directly accessible after GUI runs.
3. Run `run_mimo_models.m` to simulate both models, plot the two BER curves, and
   save `mimo_ber_results.mat`. This helper explicitly captures simulation outputs
   and extracts their arrays.

For a single model, after clicking Run:

```matlab
semilogy(snrdb_2x2(:), ber_2x2(:), '-+', 'LineWidth', 1.5);
grid on; xlabel('SNR (dB)'); ylabel('BER');
```

Change the Constant block values to change the experiment. `N_symbols` must be
a positive integer. Use `1e4` for
a quick demonstration and `1e6` for the requested experiment. Keep SNR as a row
vector. Increasing stop time repeats the entire sweep each simulation step;
it does not increase the number of symbols in a sweep.

## Correspondence with the supplied MATLAB scripts

The MATLAB Function blocks follow the supplied scripts, including their array
generation, original SNR/noise expressions, channel matrices, detection loops,
and BER calculations. No random seed input or `rng` call is added. The `randi`
and `randn` calls come from the supplied scripts.

Only the adaptations needed to place the scripts in MATLAB Function blocks are
made: `N` and `snrdb` become Constant block inputs, BER becomes the output, and
`xest` (and `Y` in the 4x4 model) is explicitly initialized as complex so the
code generator can assign complex results. `clc`, `clear all`, `close all`, and
plotting commands are omitted from the calculation block; plotting is provided
in `run_mimo_models.m`. Random values can differ from a standalone MATLAB run
because Simulink generated code can use a separate random-number state.

## Rebuild

With this folder on the MATLAB path, call `build_mimo_models`. It recreates both
`.slx` files from the supplied code and wiring. Rebuilding overwrites those two
models, so save any manual edits under a different filename first.
