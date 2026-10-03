function report = diagnose_r2026a_blocks()
%DIAGNOSE_R2026A_BLOCKS List installed Simscape Electrical candidates.
% Run this in MATLAB R2026a and attach the generated report if resolution
% fails. It does not modify or create a model.
report = struct('products',ver,'blocks',struct());
roots = {'ee_lib','simscape','sps_lib'};
names = {'Electrical Reference','Solver Configuration','DC Voltage Source', ...
    'IGBT','Mutual Inductor','Capacitor','Diode','Inductor', ...
    'Voltage Sensor','Current Sensor','Controlled Voltage Source'};
for r=1:numel(roots)
    try, load_system(roots{r}); catch, continue; end
    for n=1:numel(names)
        key = matlab.lang.makeValidName(names{n});
        hits = find_system(roots{r},'LookUnderMasks','all','FollowLinks','on', ...
            'Name',names{n},'Type','Block');
        if ~isempty(hits), report.blocks.(key)=hits(:)'; end
    end
end
if ~exist('results','dir'), mkdir('results'); end
save(fullfile('results','r2026a_block_diagnostics.mat'),'report');
fid=fopen(fullfile('results','r2026a_block_diagnostics.txt'),'w');
cleanup=onCleanup(@() fclose(fid));
fprintf(fid,'R2026a Simscape Electrical block diagnostics\n\n');
keys=fieldnames(report.blocks);
for k=1:numel(keys)
    fprintf(fid,'%s\n',keys{k});
    for j=1:numel(report.blocks.(keys{k})), fprintf(fid,'  %s\n',report.blocks.(keys{k}){j}); end
end
end
