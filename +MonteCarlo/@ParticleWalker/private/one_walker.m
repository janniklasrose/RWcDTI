function [pos_i, phi_i, flag_i] = one_walker(i, pos_all, phi_all, flag_all, rng_seed, sequence, substrate)
% core function to be executed for each walker
%   receives index of walker and global data to pick its own (and return that only)

% load data
pos_i  = pos_all(i, :);  % [ [x,y,z]_1 ; ... ; [x,y,z]_N ] % position
phi_i  = phi_all(i, :);  % [ [x,y,z]_1 ; ... ; [x,y,z]_N ] % phase
flag_i = flag_all(i); % {f_1 ; ... ; f_N } % flag
pos_i(1, 4) = inf; % we store final index in the 4th dimension. init here in case of error

% init randomness
num_streams = size(pos_all, 1); % as many as there are walkers
stream = RandStream.create('mlfg6331_64', 'Seed', rng_seed, ...
                           'NumStreams', num_streams, 'StreamIndices', i);
% this stream has 2^51=2e15 substreams

% find initial position
try
    pos_i(1, 4) = substrate.findMyocyte(pos_i(1, 1:3), 'global');
catch exception % initialisation failed
    switch exception.identifier
        case 'Substrate:search_myocytes:multiple' % thrown by Substrate.findMyocyte
            flag_i{1} = exception.identifier;
            return
        otherwise
            rethrow(exception)
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
            % rethrow the last exception we encountered
            flag_i{1} = exception.identifier; %#ok<NODEF>
            return
        end

        % execute one dt step
        try
            % perform one random step (new call = new random step)
            [pos_i] = one_dt(pos_i, dt, stream, substrate);
            step_success = true; % no error thrown, that's it!
        catch exception
            switch exception.identifier
                case {...
                      'ParticleWalker:one_dt:unfinished', ... % step was too long
                      'Polyhedron:intersection:uncertain', ... % too close to edge etc
                     }
                    continue; % Try again
                case {...
                      'Transform:transformPosition:where', ... % got lost, flag it!
                      'Substrate:intersectMyocytes:duplicate' ... % odd, flag it!
                      'Polyhedron:intersection:duplicate', ... % odd, flag it!
                      'ParticleWalker:one_dt:bb_inconsistent', ... % odd, flag it!
                     }
                    flag_i{1} = exception.identifier;
                    return
                case 'ParticleWalker:getLimitedStep:tries' % poor parameter choice
                    rethrow(exception);
                otherwise % unexpected runtime error
                    rethrow(exception);
            end
        end
    end

end

end
