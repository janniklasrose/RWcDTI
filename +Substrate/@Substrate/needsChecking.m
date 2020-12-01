function [needsChecks] = needsChecking(obj, position, step_xyz, refFrame)
% finds all myocytes that need checking for a given position and step
%   assumes position is in the global coordinate frame and transforms if necessary
%   (unless specified as 'local' with refFrame)

% transformation if needed
if nargin < 3
    refFrame = 'global';
end
if strcmp(obj.type, 'block') && strcmp(refFrame, 'global')
    position = obj.transformPosition(position);
end

% execute fast bounding box checks
needsChecks = needsChecking_box(position, step_xyz, obj.myocyte_bbrange);

end
