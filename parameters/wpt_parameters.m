function p = wpt_parameters()
%WPT_PARAMETERS Centralized validated parameters for the 100-kHz WPT model.

p.meta.name = 'wpt_100kHz_simscape_r2026a';
p.meta.requiredProducts = {'Simulink','Simscape','Simscape Electrical'};
p.input.Vdc = 48;
p.input.nominalPower = 100;
p.frequency.inverter = 100e3;
p.frequency.buck = 100e3;
p.coil.Ltx = 100e-6;
p.coil.Lrx = 100e-6;
p.coil.Rtx = 0.15;
p.coil.Rrx = 0.15;
p.coil.k = 0.25;
p.coil.M = p.coil.k*sqrt(p.coil.Ltx*p.coil.Lrx);
p.compensation.Ctx = 1/((2*pi*p.frequency.inverter)^2*p.coil.Ltx);
p.compensation.Crx = 1/((2*pi*p.frequency.inverter)^2*p.coil.Lrx);
p.rectifier.Cdc = 470e-6;
p.rectifier.Cbypass = 1e-6;
p.rectifier.schottkyVf = 0.55;
p.rectifier.schottkyRon = 20e-3;
p.buck.dutyNominal = 24/p.input.Vdc;
p.buck.L = 100e-6;
p.buck.Cout = 220e-6;
p.output.Vnom = 24;
p.output.Rload = 6;
p.output.Inom = p.output.Vnom/p.output.Rload;
p.sim.stopTime = 10e-3;
p.sim.maxStep = 1/(p.frequency.inverter*100);
p.sim.relTol = 1e-4;
p.sim.absTol = 1e-7;
p.sim.steadyStateFraction = 0.25;
p.sim.modelName = p.meta.name;
p.paths.results = fullfile(pwd,'results');
p.paths.figures = fullfile(p.paths.results,'figures');

assert(p.coil.k > 0 && p.coil.k <= 1,'Coupling coefficient must be in (0,1].');
assert(p.compensation.Ctx > 0 && p.compensation.Crx > 0,'Compensation capacitance must be positive.');
assert(p.buck.dutyNominal > 0 && p.buck.dutyNominal < 1,'Nominal buck duty must be in (0,1).');
assert(p.sim.maxStep <= 1/(p.frequency.inverter*50),'Maximum step is too large for switching resolution.');
end
