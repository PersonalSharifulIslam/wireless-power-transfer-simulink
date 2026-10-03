function result = run_wpt_simulation(p)
%RUN_WPT_SIMULATION Build/update, simulate, capture diagnostics, and save output.
if nargin<1, p=wpt_parameters(); end
if ~exist(p.paths.results,'dir'), mkdir(p.paths.results); end
mdl=p.sim.modelName;
result=struct('model',mdl,'success',false,'warnings',{{}},'error',[],'simulationOutput',[]);
[lastMsg,lastId]=lastwarn(''); %#ok<ASGLU>
try
    if ~bdIsLoaded(mdl), build_wpt_model_R2026a(p); end
    set_param(mdl,'SimulationCommand','update');
    result.simulationOutput=sim(mdl,'ReturnWorkspaceOutputs','on');
    [msg,id]=lastwarn; result.warnings={msg,id};
    result.success=true;
catch ME
    [msg,id]=lastwarn; result.warnings={msg,id}; result.error=ME;
    save(fullfile(p.paths.results,'failed_run.mat'),'result','p');
    rethrow(ME);
end
save(fullfile(p.paths.results,'simulation_output.mat'),'result','p','-v7.3');
end
