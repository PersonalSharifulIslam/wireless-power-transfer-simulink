# 100-kHz Wireless Power Transfer — MATLAB R2026a

This repository contains a MATLAB/Simulink model-generation and verification workflow for a 48-V, 100-kHz series-series compensated wireless power-transfer system.

## Scope

The workflow is designed for MATLAB R2026a with Simulink, Simscape, and Simscape Electrical. It generates a named `.slx` model, runs diagnostics and simulation, logs stable signals, plots electrical waveforms, and writes a Markdown verification report.

The baseline is an engineering reference model—not a substitute for measured coil data or a semiconductor thermal/EMI design. Replace the nominal coil, coupling, ESR, and semiconductor parameters with measured or datasheet values before hardware use.

## Baseline

- 48 V DC input
- 100 kHz, four-switch IGBT full bridge
- 100 W nominal target
- 100 uH Tx/Rx coils, 0.15 ohm winding resistance
- Coupling coefficient `k = 0.25`
- Series-series compensation; capacitors calculated from resonance
- Four-diode Schottky bridge
- 470 uF DC-link capacitor plus 1 uF bypass
- 100 kHz buck stage, 100 uH inductor, 220 uF output capacitor
- 24 V target and 6 ohm load

## Run in MATLAB R2026a

From the repository root:

```matlab
addpath(genpath(pwd));
p = wpt_parameters();
build_wpt_model_R2026a(p);
result = run_wpt_simulation(p);
report = generate_verification_report(result, p);
disp(report.markdownFile)
```

The builder performs capability checks and fails with an actionable diagnostic if a required Simscape Electrical block/API is unavailable. It does not create disconnected placeholder blocks.

## Important verification limitation

This repository is source-controlled MATLAB code. A binary `.slx` file is intentionally not committed until it has been generated and compiled in an actual MATLAB R2026a installation. The verification report is only authoritative after the commands above have been run successfully in MATLAB.

## বাংলা ব্যবহার

MATLAB R2026a-তে repository root থেকে `addpath(genpath(pwd))` চালিয়ে প্রথমে `wpt_parameters`, তারপর `build_wpt_model_R2026a`, `run_wpt_simulation`, এবং `generate_verification_report` চালান। কোনো error বা Diagnostic Viewer message এলে পুরো message এবং stack trace সংরক্ষণ করুন।
