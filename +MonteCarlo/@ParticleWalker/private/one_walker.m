function [pos_i, phi_i, flag_i] = one_walker(i, pos_all, phi_all, flag_all, rng_seed, sequence, substrate)
% core function to be executed for each walker
%   receives index of walker and global data to pick its own (and return that only)

% load data
pos_i  = pos_all(i, :);  % [ [x,y,z]_1 ; ... ; [x,y,z]_N ] % position
phi_i  = phi_all(i, :);  % [ [x,y,z]_1 ; ... ; [x,y,z]_N ] % phase
flag_i = flag_all(i, :); % [    f_1    ; ... ;    f_N    ] % flag
pos_i(1, 4) = inf; % we store final index in the 4th dimension. init here in case of error

% init randomness
num_streams = size(pos_all, 1); % as many as there are walkers
stream = RandStream.create('mlfg6331_64', 'Seed', rng_seed, ...
                           'NumStreams', num_streams, 'StreamIndices', i);
% this stream has 2^51=2e15 substreams

% find initial position
try
    pos_i(1, 4) = substrate.findMyocyte(pos_i(1, 1:3), 'global'); % throws 'Myocyte:inside'
catch exception % initialisation failed
    switch exception.identifier
        case 'Myocyte:inside'
            flag_i = 1;
            return
        otherwise
            rethrow(exception); % unexpected runtime error
    end
end

% march in time
for n = 1:sequence.NT

    % get sequence step values
    dt = sequence.get_dt(n);
    gG = sequence.get_gG(n); % may be 1D or 3D

    % phase
    phi_i(1, :) = phi_i(1, :) + gG(:)'.*pos_i(1, 1:3)*dt; % allows for scalar or vector gG

    % try step until success
    counter = 0;
    step_success = false;
    while ~step_success
        counter = counter + 1;
        if counter > 50 % give up after 50
            flag_i = 2;
            return
        end

        % execute one dt step
        try
            % perform one random step (new call = new random step)
            [pos_i] = one_dt(pos_i, dt, stream, substrate);
            step_success = true; % no error thrown, that's it!
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
                case 'exec:leftdomain'
                    flag_i = 3;
                    return
                case 'exec:whereami'
                    flag_i = 4; % Reason: particle got lost wrt block bounding box
                    return
                case 'exec:whereami22'
                    flag_i = 22; % ???
                    return
                otherwise
                    rethrow(exception); % unexpected runtime error
            end
        end
    end

end

end
