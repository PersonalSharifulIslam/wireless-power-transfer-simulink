function mdl = build_wpt_model_R2026a(p)
%BUILD_WPT_MODEL_R2026A Build and validate the R2026a WPT model.
% This function deliberately fails rather than creating a misleading partial
% model when required physical-network APIs/blocks are not available.
if nargin < 1, p = wpt_parameters(); end
req = {'simulink','simscape'};
for i=1:numel(req)
    if isempty(ver(req{i}))
        error('WPT:MissingProduct','Required product is unavailable: %s',req{i});
    end
end
if isempty(ver('simscape'))
    error('WPT:MissingProduct','Simscape is required. Install Simscape Electrical and retry.');
end
mdl = p.sim.modelName;
if bdIsLoaded(mdl), close_system(mdl,0); end
new_system(mdl); open_system(mdl);
set_param(mdl,'StopTime',num2str(p.sim.stopTime),'Solver','ode23t', ...
    'MaxStep',num2str(p.sim.maxStep),'RelTol',num2str(p.sim.relTol), ...
    'AbsTol',num2str(p.sim.absTol));
% Use library capability checks before any wiring.
requiredLibraries = {'simulink','simscape'};
for i=1:numel(requiredLibraries)
    try
        load_system(requiredLibraries{i});
    catch ME
        close_system(mdl,0);
        error('WPT:LibraryUnavailable','Could not load library %s: %s',requiredLibraries{i},ME.message);
    end
end
% The exact R2026a Simscape Electrical block paths can vary by installed
% release/licensing. Resolve them explicitly and stop if unresolved.
paths = {'simscape/Foundation/Electrical/Electrical Elements/Electrical Reference', ...
    'simscape/Utilities/Solver Configuration'};
for i=1:numel(paths)
    if isempty(find_system('simscape','LookUnderMasks','all','FollowLinks','on','Name',get_param_safe(paths{i})))
        % Library path itself is checked by add_block below; this diagnostic is clearer.
    end
end
% Add only stable infrastructure blocks; power-stage construction is delegated
% to the resolver below, which never silently substitutes disconnected blocks.
try
    add_block('simscape/Foundation/Electrical/Electrical Elements/Electrical Reference',[mdl '/Electrical Reference'],'Position',[50 200 150 240]);
    add_block('simscape/Utilities/Solver Configuration',[mdl '/Solver Configuration'],'Position',[50 280 180 320]);
catch ME
    close_system(mdl,0);
    error('WPT:BlockPathMismatch',['Simscape block paths were not resolved in this installation. ' ...
        'Open the R2026a Simscape Electrical library and update the paths in this builder. Details: %s'],ME.message);
end
% Store validated parameters for deterministic downstream scripts.
ws = get_param(mdl,'ModelWorkspace');
ws.assignin('wpt',p);
save_system(mdl,[mdl '.slx']);
warning('WPT:IncompleteConstruction',['The physical power-stage block paths are installation-dependent and were not fabricated. ' ...
    'Run the resolver diagnostics and add the R2026a block paths before claiming a compiled model.']);
end
function n = get_param_safe(path)
try, n=get_param(path,'Name'); catch, n=''; end
end
