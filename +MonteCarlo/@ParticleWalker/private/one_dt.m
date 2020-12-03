function [position] = one_dt(position, dt, stream, substrate)
% Perform a single time step

% get step length (dim=3 for 3D), max 5stdevs
dxdydz_normaldistrib = getLimitedStep(3, 5, stream);

myoIndex = position(1, 4);

% scale initially
% diffusivity
if isnan(myoIndex) % none
    D_old = substrate.D_e;
else
    D_old = substrate.D_i; %TODO: assign based on individual myocyte with index iM
end
D_new = D_old; % D_new holds the new diffusivity for every sub-step
dxdydz = dxdydz_normaldistrib * sqrt(2*dt*D_old); % currently only D_i and D_e

% until no more step left
ZERO = 1e-12; % 1e-12[m] = 1e-6[um] (note: eps(1) == 2e-16)
counter = 0;
while norm(dxdydz, 2) > ZERO
    D_old = D_new;
    
    counter = counter + 1;
    if counter > 50
        error('ParticleWalker:one_dt:unfinished', ...
              'Step has not finished after 50 substeps');
    end

    % substrate checks
    [position_LOCAL, position_rotated, fn_RotReverse] = substrate.transformPosition(position(1, 1:3));
    
    intersectInfo = substrate.intersectMyocytes(position_LOCAL, dxdydz, 'local');
    % intersectInfo now contains info about first encountered intersection

    stepEps = 1e-8;
    if isempty(intersectInfo) % no intersection encountered

        position_future = position_LOCAL + dxdydz;
        if ~substrate.block_bb.BoundingBox.containsPoint(position_future) % would leave the block

            % may throw an error, just take it and flag particle
            intersectInfoBB = substrate.block_bb.intersection(position_LOCAL, dxdydz);
            if isempty(intersectInfoBB)
                error('ParticleWalker:one_dt:bb_inconsistent', ...
                      'Empty intersection when there should be one');
            end
            dxdydz_toIntersection = dxdydz*intersectInfoBB.t;
            dxdydz = dxdydz*(1-intersectInfoBB.t); % what's remaining

            % ENABLE if the particles cannot leave the bounding box
            %dxdydz(:) = Geometry.reflect(dxdydz, intersectInfoBB.vertices);

            position_rotated = position_rotated + dxdydz_toIntersection;
            position_rotated = position_rotated + dxdydz*stepEps;
            dxdydz = dxdydz*(1-stepEps); % remove eps

        else
            position_rotated = position_rotated + dxdydz; % no need to worry about 'position_LOCAL'
            dxdydz = zeros(size(dxdydz)); % explicitly set to zero
        end
    else % an intersection was encountered

        dxdydz_toIntersection = dxdydz*intersectInfo.t; % move partially in LOCAL
        dxdydz = dxdydz*(1-intersectInfo.t);

        switch substrate.transit_model
            case 'constant'
                probability_of_transit = substrate.kappa; % is constant probability of transit
            otherwise
                error('Error:NotImplemented', 'Transit model not supported');
        end

        U = rand(stream, 1);
        if U < probability_of_transit % ??? ensure boundary cases (rand==0 or rand==1 are handled correctly)
            % --> go through

            % update index %TODO: ensure this is done correctly!!!
            if isnan(myoIndex)
                myoIndex = intersectInfo.myoindex;
            else
                myoIndex = NaN;
            end

            % change D
            if isnan(myoIndex) % none
                D_new = substrate.D_e;
            else
                D_new = substrate.D_i; %TODO: assign based on individual myocyte with index iM
            end

            dxdydz = dxdydz * sqrt(D_new/D_old);

        else
            % --> reflect

            dxdydz(:) = Geometry.reflect(dxdydz, intersectInfo.vertices);

        end

        % step a little bit to get off face
        % - this requires faces to be at least a certain distance away from each other (geometry check!)
        position_rotated = position_rotated + dxdydz_toIntersection; % initial sub-step to intersection side
        position_rotated = position_rotated + dxdydz*stepEps; % little Eps extra of new step to move away from face
        dxdydz = dxdydz*(1-stepEps); % remove eps
    end

    % transform the position back from the local to the global frame
    position(1, 1:3) = fn_RotReverse(position_rotated);
    position(1, 4) = myoIndex;

end

end
