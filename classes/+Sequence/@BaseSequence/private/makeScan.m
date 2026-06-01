%% setup
close all
clear

if ispc
    path_to_scan = 'C:\Users\jnr14\Documents\Dropbox\Temporary\code\@Sequence\private';
elseif ismac
    path_to_scan = '/Users/jnr14/Documents/Dropbox/Temporary/code/@Sequence/private';
end

%%

scanType = 'PGSE';

% sequence-specific
scan = struct('dt', [], 'gG', [], 't', [], 'bfactor', []);
switch scanType
    case {'PGSE', 'STEAM'}
        switch scanType
            case 'STEAM'
                
                dt_fine = 1e-5; % fine to have sufficient steps inside very short gradients
                TE = 45e-3;
                alpha = 1e-3;
                
                DELTA = 1000e-3;
                
        end
        
        delta_possible = roots([-1/3, +DELTA, -epsilon^2/6, +epsilon^3/30 - bfactor/(gamma*G_peak)^2]); % 0 == a*x^3, b*x^2, c*x
        valid = delta_possible >= 0 & delta_possible <= DELTA-2*epsilon; % positive and shorter than 
        if sum(valid) < 1
            error('problem with delta');
        end
        delta = (delta_possible(valid));
        
        TM = DELTA-2*epsilon-delta;
        TE = 3;
        
        
        
        t_Dt = [alpha, epsilon,   delta, epsilon, TM, epsilon,   delta, epsilon, alpha];
        t1 = sum(t_Dt(1)); t2 = sum(t_Dt(1:4)); t3 = sum(t_Dt(1:5)); t4 = sum(t_Dt(1:8));
        t_dt = [   dt, dt_fine, dt_fine, dt_fine, dt, dt_fine, dt_fine, dt_fine,    dt];
        t_Nt = ceil(t_Dt./t_dt);
        t = 0;
        for i=1:numel(t_dt)
            t = [t(1:end-1), t(end)+linspace(0, t_Dt(i), t_Nt(i))];
        end
        scan.t = unique(t); % should already be unique but lets be safe
        scan.dt = diff(scan.t);
        scan.gG = zeros(size(scan.dt));
        gG_peak = gamma*G_peak;
        for i = 1:numel(scan.gG)
            if     scan.t(i) >= t1 && scan.t(i) < t2
                scan.gG(i) = +gG_peak;
            elseif scan.t(i) >= t3 && scan.t(i) < t4
                scan.gG(i) = -gG_peak;
            end
        end
        scan.bfactor = bfactor;
        
    case 'MC'
        
end

figure();
plot(cumsum(scan.dt), scan.gG, 'bo-');
xlabel('t [s]');
ylabel('G [?]');
drawnow;

%%
save(fullfile(path_to_scan, [scanType, '.mat']), 'scan');
