function [position_iP, phase_iP, histIdx_iP, histTry_iP, histPosx_i, histPosy_i, histPosz_i] = exec(position_iP, phase_iP, scan, geom)

%%% find initial position
try
    myoIndex = findMyocyte(position_iP, geom); % throws 'Myocyte:inside' if there is a problem
catch exception
    switch exception.identifier
        case 'Myocyte:inside'
            error('exec:init', exception.message);
        otherwise
            rethrow(exception);
    end
end

iHist = 0;
histIdx_iP = inf(1, numel(scan.dt));
histTry_iP = inf(1, numel(scan.dt));
histPosx_i = inf(1, numel(scan.dt));
histPosy_i = inf(1, numel(scan.dt));
histPosz_i = inf(1, numel(scan.dt));

nIntersectionTries = 0;

params = geom.params;

%%% march in time
while scan.next()
    
    % write history
    iHist = iHist + 1;
    histIdx_iP(1, iHist) = myoIndex;
    histTry_iP(1, iHist) = nIntersectionTries;
    histPosx_i(1, iHist) = position_iP(1);
    histPosy_i(1, iHist) = position_iP(2);
    histPosz_i(1, iHist) = position_iP(3);
    
    % get sequence step values
    dt = scan.get_dt;
    gG = scan.get_gG; % may be 1D or 3D
    
    % phase
    phase_iP(:) = phase_iP(:) + gG(:).*position_iP(:)*dt; % allows for scalar or vector gG
    
    % try step until success
    counter = 0;
    while true()
        counter = counter + 1;
        if counter > 50
            error('exec:steptries', 'cannot execute step, tried 50 times'); % this will abort the exec for this particle
        end
        
        % execute one dt step
        try
            
            % can also add different types of motion here (like free diffusion, etc.)
            [position_iP, myoIndex, nIntersectionTries] = one_dt(position_iP, myoIndex, dt, geom, params); % perform one random step (new call = new random step)
            break; % no error thrown! we can proceed with the next dt
            
        catch exception
            switch exception.identifier
                case 'exec:stepsize'
                    continue; % Try again! Reason: cannot draw a step with the correct magnitude
                case 'exec:twointersect'
                    continue; % Try again! Reason: found two identical intersection points
                case 'exec:unfinishedstep'
                    continue; % Try again! Reason: step has too many substeps
                case 'exec:tooclose'
                    continue; % Try again! Reason: point was too close to an edge, vertex, face
                case 'exec:whereami'
                    rethrow(exception); % Try again! Reason: particle got lost wrt block bounding box
                otherwise
                    rethrow(exception); % unexpected runtime error
            end
        end
    end
    
end

position_iP(4) = myoIndex;

end
