function [position, myoIndex, nIntersectionTries] = one_dt(position, myoIndex, dt, geom, params)

myocytes = geom.myocytes;
substrate = geom.substrate;

persistent bbsrange_myo;
if isempty(bbsrange_myo)
    %Containts bounding box for each myocyte
    tmp_bbs = [myocytes.BoundingBox];
    %Range of the bounding box
    bbsrange_myo = [tmp_bbs.Range];
end
persistent block_bb;
if isempty(block_bb)
    block_bb = Geometry.Polyhedron('cuboid', [0, substrate.dx, 0, substrate.dy, 0, substrate.dz]);
end

% get step length (dim=3 for 3D)
dxdydz_normaldistrib = getLimitedStep(3); % throws 'exec'stepsize' if it fails

% scale initially
% diffusivity
if isnan(myoIndex) % none
    D_old = params.D_e;
else
    D_old = params.D_i; %TODO: assign based on individual myocyte with index iM
end
D_new = D_old; % D_new holds the new diffusivity for every sub-step
dxdydz = dxdydz_normaldistrib * sqrt(2*dt*D_old); % currently only D_i and D_e

nIntersectionTries = 0;

% until no more step left
ZERO = 1e-12; % 1e-12[m] = 1e-6[um] (note: eps(1) == 2e-16)
counter = 0;
while norm(dxdydz, 2) > ZERO
    D_old = D_new;
    
    counter = counter + 1;
    if counter > 50
        error('exec:unfinishedstep', 'step has not finished after 50 substeps');
    end
    
    %{
    CHECK_IMPERMEABLE = false;
    if CHECK_IMPERMEABLE
        [cannotDetect, myoContainsPosition] = deal(false(1, numel(myocytes)));
        for iMyo = 1:numel(myocytes)
            try
                myoContainsPosition(iMyo) = myocytes(iMyo).containsPoint(position);
            catch me
                cannotDetect(iMyo) = true;
                disp(me)
            end
        end
        if ~any(myoContainsPosition) || (any(position<3.433e-5) || any(position>6.568e-5))
            % write all necessary data and fail with error
            save('DEBUG_dump.mat');
            error('particle left myocyte');
        end
    end
    %}
    
    [position_LOCAL, position_rotated, ROT_reverse] = transformPosition(substrate, position);
    
    %C++ code 
    needsChecks = needsChecking_box(position_LOCAL, dxdydz, bbsrange_myo); % ~(wontEnter && isOutside)
    
    intersectInfo = [];
    for iMyocyte = find(needsChecks) % only relevant ones
        try
            [info] = myocytes(iMyocyte).intersection(position_LOCAL, dxdydz);
        catch exception
            switch exception.identifier
                case 'exec:tooclose'
                    rethrow(exception); % is being handled
                otherwise
                    rethrow(exception);
            end
        end
        if ~isempty(info) % intersection found
            info.myoindex = iMyocyte;
            if isempty(intersectInfo) % no other intersection so far
                intersectInfo = info;
            else % compare new with existing intersection
                if info.t < intersectInfo.t
                    intersectInfo = info;
                elseif info.t == intersectInfo.t
                    % should not happen for a valid geometry, but check anyways
                    error('exec:twointersect', 'two identical intersection points found');
                else
                    % leave it
                end
            end
        end
    end
    % intersectInfo now contains info about first encountered intersection (including p, reflection-normal, position, t, ...)
    
    stepEps = 1e-8;
    if isempty(intersectInfo) % no intersection encountered
        
        position_future = position_LOCAL + dxdydz;
        if ~block_bb.BoundingBox.containsPoint(position_future) % would leave the block
            
            try
                intersectInfoBB = block_bb.intersection(position_LOCAL, dxdydz); % may throw an error, just take it and flag particle
                if isempty(intersectInfoBB)
                    error('empty intersection when there should be one');
                end
            catch except
                error('exec:tooclose', 'Problem with block BB');
            end
            dxdydz_toIntersection = dxdydz*intersectInfoBB.t;
            dxdydz = dxdydz*(1-intersectInfoBB.t); % what's remaining
            
            %{
            % ENABLE if the particles cannot leave the bounding box
            % --> reflect
            vert0 = intersectInfoBB.vertices(1, :);
            vert1 = intersectInfoBB.vertices(2, :);
            vert2 = intersectInfoBB.vertices(3, :);
            edge01 = vert1-vert0;
            edge02 = vert2-vert0;
            normal = cross(edge01, edge02);
            normal = normal/norm(normal, 2);
            dxdydz_magn = norm(dxdydz, 2);
            dxdydz_norm = dxdydz/dxdydz_magn;
            dxdydz_norm_reflected = dxdydz_norm(:) - 2*normal(:)*dot(dxdydz_norm, normal);
            dxdydz(:) = dxdydz_norm_reflected(:)*dxdydz_magn;
            %}
            
            position_rotated = position_rotated + dxdydz_toIntersection;
            position_rotated = position_rotated + dxdydz*stepEps;
            dxdydz = dxdydz*(1-stepEps); % remove eps
            
        else
            position_rotated = position_rotated + dxdydz; % no need to worry about 'position_LOCAL'
            dxdydz = zeros(size(dxdydz)); % explicitly set to zero
        end
    else % an intersection was encountered
        nIntersectionTries = nIntersectionTries + 1;
        
        dxdydz_toIntersection = dxdydz*intersectInfo.t; % move partially in LOCAL
        dxdydz = dxdydz*(1-intersectInfo.t);
        
        volumeAreaRatio = intersectInfo.VolumeAreaRatio;
        I_wholeStep = norm(dxdydz, 2);
        switch substrate.transitModel
            case 'constant'
                probability_of_transit = params.permeab; % is constant probability of transit
            case 'Rose'
                if isnan(myoIndex) % currently outside
                    D_new_over_D_old = params.D_i/params.D_e;
                else % currently inside
                    D_new_over_D_old = params.D_e/params.D_i;
                end
                % here, permeab is constant membrane probability of transit
                probability_of_transit = params.permeab * min(sqrt(D_new_over_D_old), 1.0);
            case 'Hall'
                probability_of_transit = params.permeab * ( I_wholeStep ) /D_old;
            case 'FieremansNovikov' % Fieremans & Novikov 2010
                probability_of_transit = params.permeab * ( 2 * (I_wholeStep*intersectInfo.t) ) /D_old;
            otherwise
                error('BUG: wrong transit model');
        end
        
        if rand(1) < probability_of_transit % ??? ensure boundary cases (rand==0 or rand==1 are handled correctly)
            % --> go through
            % update index %TODO: ensure this is done correctly!!!
            if isnan(myoIndex)
                myoIndex = intersectInfo.myoindex;
            else
                myoIndex = NaN;
            end
            % change D
            if isnan(myoIndex) % none
                D_new = params.D_e;
            else
                D_new = params.D_i; %TODO: assign based on individual myocyte with index iM
            end
            dxdydz = dxdydz * sqrt(D_new/D_old);
        else
            % --> reflect
            vert0 = intersectInfo.vertices(1, :);
            vert1 = intersectInfo.vertices(2, :);
            vert2 = intersectInfo.vertices(3, :);
            edge01 = vert1-vert0;
            edge02 = vert2-vert0;
            normal = cross(edge01, edge02);
            normal = normal/norm(normal, 2);
            dxdydz_magn = norm(dxdydz, 2);
            dxdydz_norm = dxdydz/dxdydz_magn;
            dxdydz_norm_reflected = dxdydz_norm(:) - 2*normal(:)*dot(dxdydz_norm, normal);
            dxdydz(:) = dxdydz_norm_reflected(:)*dxdydz_magn;
        end
        % step a little bit to get off face %%%%%%%%%%%% this requires faces to be at least a certain distance away from each other (geometry check!)
        position_rotated = position_rotated + dxdydz_toIntersection; % initial sub-step to intersection side
        position_rotated = position_rotated + dxdydz*stepEps; % little Eps extra of new step to move away from face
        dxdydz = dxdydz*(1-stepEps); % remove eps
    end
    
    % TRANSFORM GLOBAL->LOCAL
    position = (ROT_reverse*position_rotated.').';
end

end

function [c] = cross(a, b)
    c = [a(2)*b(3)-a(3)*b(2), a(3)*b(1)-a(1)*b(3), a(1)*b(2)-a(2)*b(1)];
end
