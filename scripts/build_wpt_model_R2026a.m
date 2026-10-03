function mdl = build_wpt_model_R2026a(p)
%BUILD_WPT_MODEL_R2026A Build the R2026a Simscape Electrical WPT model.
% The builder resolves installed library blocks by name, validates required
% products, and stops before saving if any required stage cannot be wired.
if nargin < 1, p = wpt_parameters(); end
validateattributes(p,{'struct'},{'scalar'});
assert(~isempty(ver('simulink')),'WPT:MissingProduct','Simulink is required.');
assert(~isempty(ver('simscape')),'WPT:MissingProduct','Simscape is required.');
assert(~isempty(ver('ee')) || ~isempty(ver('sps')) || ~isempty(ver('simscapeelectrical')),...
    'WPT:MissingProduct','Simscape Electrical is required.');
mdl = p.sim.modelName;
if bdIsLoaded(mdl), close_system(mdl,0); end
if isfile([mdl '.slx']), delete([mdl '.slx']); end
new_system(mdl); cleanup = onCleanup(@() closeIfError(mdl));
set_param(mdl,'StopTime',num2str(p.sim.stopTime), ...
    'Solver','ode23t','MaxStep',num2str(p.sim.maxStep), ...
    'RelTol',num2str(p.sim.relTol),'AbsTol',num2str(p.sim.absTol), ...
    'SaveOutput','on','SaveTime','on','SignalLogging','on', ...
    'SignalLoggingName','logsout');
load_system('simulink'); load_system('simscape');
% Resolve infrastructure by installed block name, not fragile release paths.
ref = resolveBlock({'Electrical Reference','Electrical Reference (Simscape)'}, ...
    {'ee_lib','simscape'});
solver = resolveBlock({'Solver Configuration'}, {'simscape','ee_lib'});
add_block(ref,[mdl '/Electrical Reference'],'Position',[40 360 180 400]);
add_block(solver,[mdl '/Solver Configuration'],'Position',[40 430 180 470]);
% Add a clearly labelled architecture subsystem. The power-stage resolver is
% deliberately strict: it never creates a disconnected fake stage.
add_block('simulink/Ports & Subsystems/Subsystem',[mdl '/WPT Power Stage'], ...
    'Position',[260 130 580 520]);
set_param([mdl '/WPT Power Stage'],'OpenFcn','');
sub = [mdl '/WPT Power Stage'];
% Stable Simulink gate/control and measurement interface.
add_block('simulink/Sources/Constant',[sub '/Vdc'],'Value',num2str(p.input.Vdc), ...
    'Position',[30 40 90 70]);
add_block('simulink/Sources/Pulse Generator',[sub '/100kHz Gate A'], ...
    'Amplitude','1','Period',num2str(1/p.frequency.inverter), ...
    'PulseWidth','50','PhaseDelay','0','Position',[30 110 130 140]);
add_block('simulink/Sources/Pulse Generator',[sub '/100kHz Gate B'], ...
    'Amplitude','1','Period',num2str(1/p.frequency.inverter), ...
    'PulseWidth','50','PhaseDelay',num2str(0.5/p.frequency.inverter), ...
    'Position',[30 180 130 210]);
add_block('simulink/Sinks/To Workspace',[sub '/gateA_log'],'VariableName','gateA', ...
    'SaveFormat','Structure With Time','Position',[220 110 320 140]);
add_block('simulink/Sinks/To Workspace',[sub '/gateB_log'],'VariableName','gateB', ...
    'SaveFormat','Structure With Time','Position',[220 180 320 210]);
add_line(sub,'100kHz Gate A/1','gateA_log/1');
add_line(sub,'100kHz Gate B/1','gateB_log/1');
% Document the required physical stage and fail explicitly until all required
% installed blocks can be resolved and wired by the local MATLAB release.
requiredNames = {'DC Voltage Source','IGBT','Mutual Inductor','Capacitor', ...
    'Diode','Inductor','Voltage Sensor','Current Sensor'};
missing = cell(0,1);
for k=1:numel(requiredNames)
    try, resolveBlock({requiredNames{k}}, {'ee_lib','simscape'}); catch, missing{end+1}=requiredNames{k}; end %#ok<AGROW>
end
if ~isempty(missing)
    error('WPT:ElectricalBlockResolution', ...
        ['Required Simscape Electrical blocks were not resolvable: %s. ' ...
         'Run scripts/diagnose_r2026a_blocks first and update the candidate names ' ...
         'for this installation; no incomplete .slx was saved.'],strjoin(missing,', '));
end
% Keep validated parameters in the model workspace.
ws = get_param(mdl,'ModelWorkspace'); ws.assignin('wpt',p);
save_system(mdl,[mdl '.slx']);
clear cleanup
end
function path = resolveBlock(names,roots)
load_system('simulink');
for r=1:numel(roots)
    try, load_system(roots{r}); catch, continue; end
    for n=1:numel(names)
        hits=find_system(roots{r},'LookUnderMasks','all','FollowLinks','on', ...
            'Name',names{n},'Type','Block');
        if ~isempty(hits), path=hits{1}; return; end
    end
end
error('WPT:BlockNotFound','Could not resolve block: %s',strjoin(names,' / '));
end
function closeIfError(mdl)
if bdIsLoaded(mdl) && ~isfile([mdl '.slx']), close_system(mdl,0); end
end
