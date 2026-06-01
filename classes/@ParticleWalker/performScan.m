function [tensor_values, data, history_all, posHist_all] = performScan(this, sequence, geometry)


pos0 = this.position;


%%% loop over all particles (all independent, thus parallel)
position_all = this.position; phase_all = this.phase; flag_all = this.flag;
f_run = @() run_forloop(this.nP, @core, position_all, phase_all, flag_all, sequence, geometry);
if nargout < 3 % ignore all history
    [position_all, phase_all, flag_all]                                                               = f_run();
elseif nargout < 4 % ignore position history
    [position_all, phase_all, flag_all, historyIdx_all, historyTry_all]                               = f_run();
    history_all = cat(3, historyIdx_all, historyTry_all);
else % default, compute all
    [position_all, phase_all, flag_all, historyIdx_all, historyTry_all, posx_all, posy_all, posz_all] = f_run();
    history_all = cat(3, historyIdx_all, historyTry_all);
    posHist_all = cat(3, posx_all, posy_all, posz_all);
end
this.position = position_all; this.phase = phase_all; this.flag = flag_all;
fprintf('Number of flagged particles: %i/%i\n', sum(flag_all(:)~=0), numel(flag_all(:)));


















%%% post-process
valid = ~this.flag;
% read-out happens inside voxel only
insideVoxel = false(size(this.flag));
voxel = Geometry.BoundingBox([0, 2.8e-3, 0, 2.8e-3, 0, 8.0e-3]); % voxel
for iP = 1:numel(insideVoxel)
    insideVoxel(iP) = voxel.containsPoint(this.position(iP, :));
end
% ec space
OUTSIDE = isnan(this.position(:, 4));
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.phase_outside = this.phase(OUTSIDE & insideVoxel & valid, :);
data.phase_inside = this.phase(~OUTSIDE & insideVoxel & valid, :);
displacement = this.position(:, 1:3) - pos0;
data.displacement_outside = displacement(OUTSIDE & valid, :);
data.displacement_inside = displacement(~OUTSIDE & valid, :);

% get signal and tensor
try
    tensor_values = sequence.computeResults(this.phase(insideVoxel & valid, :));
catch
    tensor_values = [];
end

end

function [pos_i, phi_i, flag_i, histIdx_i, histTry_i, histPosx_i, histPosy_i, histPosz_i] = core(i, pos_all, phi_all, flag_all, sequence, geometry)

%%% load and init
pos_i  = pos_all(i, :);  % [ [x,y,z]_1 ; ... ; [x,y,z]_N ] % position
phi_i  = phi_all(i, :);  % [ [x,y,z]_1 ; ... ; [x,y,z]_N ] % phase
flag_i = flag_all(i, :); % [    f_1    ; ... ;    f_N    ] % flag
scan_i = copy(sequence); % deep copy
histIdx_i = inf(1, numel(scan_i.dt));
histTry_i = inf(1, numel(scan_i.dt));
histPosx_i = inf(1, numel(scan_i.dt));
histPosy_i = inf(1, numel(scan_i.dt));
histPosz_i = inf(1, numel(scan_i.dt));

%%% exec
try
    [pos_i, phi_i, histIdx_i, histTry_i, histPosx_i, histPosy_i, histPosz_i] = exec(pos_i, phi_i, scan_i, geometry);
catch exception
    switch exception.identifier
        case 'exec:init' % initialisation failed (thrown by findMyocyte.m)
            flag_i = 1;
        case 'exec:steptries' % too many tries to execute step
            flag_i = 2;
        case 'exec:leftdomain'
            flag_i = 3;
        case 'exec:whereami'
            flag_i = 4;
        case 'exec:whereami22'
            flag_i = 22;
        otherwise
            rethrow(exception); % unexpected runtime error
    end
end
if numel(pos_i) ~= 4
    pos_i(4) = inf; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% forth coordinate is final myoindex
end

end
