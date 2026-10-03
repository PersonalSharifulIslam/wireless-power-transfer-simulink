function result = run_wpt_simulation(p)
%RUN_WPT_SIMULATION Build/update, simulate, capture diagnostics, and save output.
if nargin < 1, p = wpt_parameters(); end
if ~exist(p.paths.results,'dir'), mkdir(p.paths.results); end
mdl = p.sim.modelName;
result = struct('model',mdl,'success',false,'warnings',{{}},'error',[],'simulationOutput',[]);
try
    if ~bdIsLoaded(mdl), build_wpt_model_R2026a(p); end
    set_param(mdl,'SimulationCommand','update');
    result.simulationOutput = sim(mdl,'ReturnWorkspaceOutputs','on');
    result.success = true;
catch ME
    result.error = ME;
    result.warnings = lastwarn;
    save(fullfile(p.paths.results,'failed_run.mat'),'result','p');
    rethrow(ME);
end
save(fullfile(p.paths.results,'simulation_output.mat'),'result','p','-v7.3');
end
