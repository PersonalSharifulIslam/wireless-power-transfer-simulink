# 100-kHz WPT workflow

The initial repository commit was a guarded skeleton. This update adds a release-tolerant block diagnostic utility, stricter product/block checks, fixes MATLAB result access issues, and prevents saving a misleading incomplete power-stage model.

Run:

```matlab
addpath(genpath(pwd));
p = wpt_parameters();
diagnose_r2026a_blocks();
build_wpt_model_R2026a(p);
result = run_wpt_simulation(p);
report = generate_verification_report(result,p);
```

If the builder reports `WPT:ElectricalBlockResolution`, open `results/r2026a_block_diagnostics.txt` and use the reported installed block paths to update the resolver. The builder intentionally stops instead of claiming a valid model when it cannot confirm all required physical components.

Actual compilation, simulation, waveform inspection, and numerical verification must be performed in MATLAB R2026a with Simulink, Simscape, and Simscape Electrical installed.
