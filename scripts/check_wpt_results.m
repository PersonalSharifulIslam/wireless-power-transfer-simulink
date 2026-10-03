function check = check_wpt_results(result,p)
%CHECK_WPT_RESULTS Validate logged data and basic numerical sanity.
if nargin < 2, p = wpt_parameters(); end
check = struct('pass',false,'failures',{{}},'metrics',struct());
if ~isfield(result,'success') || ~result.success
    check.failures{end+1}='Simulation did not complete successfully.'; return
end
out = result.simulationOutput;
vars = {'t','vin','iin','vout','iout','pin','pout','efficiency'};
for i=1:numel(vars)
    if ~hasSignal(out,vars{i}), check.failures{end+1}=['Missing logged signal: ' vars{i}]; end
end
if ~isempty(check.failures), return; end
t = getSignal(out,'t');
for i=2:numel(vars)
    x=getSignal(out,vars{i});
    if any(~isfinite(x(:))), check.failures{end+1}=['Non-finite values in ' vars{i}]; end
end
steady = t >= t(1)+(t(end)-t(1))*p.sim.steadyStateFraction;
vout = getSignal(out,'vout'); iout=getSignal(out,'iout');
pout=getSignal(out,'pout');
check.metrics.voutMean=mean(vout(steady));
check.metrics.ioutMean=mean(iout(steady));
check.metrics.poutMean=mean(pout(steady));
check.metrics.efficiencyMean=mean(getSignal(out,'efficiency')(steady)); %#ok<NASGU>
if check.metrics.voutMean <= 0, check.failures{end+1}='Output voltage is not positive.'; end
if check.metrics.poutMean <= 0, check.failures{end+1}='Output power is not positive.'; end
check.pass = isempty(check.failures);
end
function tf=hasSignal(out,n), tf=ismember(n,out.who); end
function x=getSignal(out,n)
if isprop(out,n), x=out.(n); elseif isfield(out,n), x=out.(n); else, error('WPT:MissingSignal','Missing signal %s',n); end
if isa(x,'timeseries'), x=x.Data; end
end
