# Simulink Wireless Communications — MIMO Zero-Forcing & BPSK OFDM

A MATLAB and Simulink wireless communication simulation suite implementing **2×2 and 4×4 MIMO Zero-Forcing (ZF)** equalization and **BPSK OFDM** transmission over Rayleigh / multipath fading channels, built without Communications Toolbox block dependencies.

---

## Modules

### 1. `mimo_zero_forcing/` — 2×2 & 4×4 MIMO Zero-Forcing
- **Simulink Models**: `mimo_2x2_zf.slx`, `mimo_4x4_zf.slx` (MATLAB R2024b)
- **Builders & Sweep Scripts**: `build_mimo_models.m`, `zf_sweep_2x2.m`, `zf_sweep_4x4.m`
- **Verification & Plotting**: `run_mimo_models.m`, `verify_mimo_results.m`, `mimo_ber_results.mat`, `ber_comparison.png`, block diagrams (`mimo_2x2_zf_diagram.png`, `mimo_4x4_zf_diagram.png`)
- Simulates `N = 1e6` BPSK symbols across `SNR = 0:5:40 dB` over Rayleigh channels using ZF matrix inversion and plots empirical vs. analytical BER curves.

### 2. `ofdm_bpsk/` — BPSK OFDM over Multipath Channels
- **Simulink Model**: `OFDM_Simulink.slx`
- **Programmatic Builder & Validation**: `build_ofdm_model.m`, `simtest_ofdm.m`, `compare_ber_simulink.m`
- Programmatically generates the OFDM Simulink topology using `Constant` + `MATLAB Function` + `Display` blocks and benchmarks Simulink BER against standalone MATLAB Monte Carlo sweeps.

---

## Usage

### Run MIMO Zero-Forcing Models
```matlab
cd mimo_zero_forcing
run_mimo_models
verify_mimo_results
```

### Build & Compare OFDM Simulink Model
```matlab
cd ofdm_bpsk
build_ofdm_model
compare_ber_simulink
```

---

## License
MIT License — see [LICENSE](LICENSE).
