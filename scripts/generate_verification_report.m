function report = generate_verification_report(result,p)
%GENERATE_VERIFICATION_REPORT Plot available signals and write Markdown report.
if nargin < 2, p=wpt_parameters(); end
if ~exist(p.paths.figures,'dir'), mkdir(p.paths.figures); end
report = struct('markdownFile',fullfile(p.paths.results,'verification_report.md'));
if ~isfield(result,'success') || ~result.success
    txt=sprintf('# Verification report\n\nSimulation was not successful.\n\nError: %s\n',result.error.message);
    fid=fopen(report.markdownFile,'w'); fprintf(fid,'%s',txt); fclose(fid); return
end
out=result.simulationOutput;
if ismember('t',out.who), t=out.t; else, error('WPT:MissingSignal','Time signal t is required.'); end
names={'vin','iin','vout','iout','pin','pout','efficiency'};
fig=figure('Visible','off'); tiledlayout(numel(names),1);
for i=1:numel(names)
    nexttile; n=names{i};
    if ismember(n,out.who), x=out.(n); if isa(x,'timeseries'), x=x.Data; end; plot(t,x); grid on; ylabel(n); end
end
xlabel('Time (s)'); exportgraphics(fig,fullfile(p.paths.figures,'electrical_waveforms.png')); close(fig);
try, c=check_wpt_results(result,p); catch ME, c=struct('pass',false,'failures',{{ME.message}},'metrics',struct()); end
fid=fopen(report.markdownFile,'w');
fprintf(fid,'# Verification report\n\n');
fprintf(fid,'- Model: `%s`\n- Status: **%s**\n- MATLAB/Simulink execution must be performed in the user installation.\n\n',p.sim.modelName, ternary(c.pass,'PASS','FAIL'));
fprintf(fid,'## Metrics\n\n```matlab\n');
if isfield(c,'metrics'), dispStruct(fid,c.metrics); end
fprintf(fid,'```\n\n## Failures\n\n');
for i=1:numel(c.failures), fprintf(fid,'- %s\n',c.failures{i}); end
fclose(fid);
report.check=c;
end
function s=ternary(tf,a,b), if tf,s=a;else,s=b;end,end
function dispStruct(fid,s)
f=fieldnames(s); for i=1:numel(f), fprintf(fid,'%s = %g\n',f{i},s.(f{i})); end
end
