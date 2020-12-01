function [myoIndex] = findMyocyte(obj, position, refFrame)
% find myocyte that the position is inside of
%   assumes position is in the global coordinate frame and transforms if necessary
%   (unless specified as 'local' with refFrame)

% transformation if needed
if nargin < 3
    refFrame = 'global';
end
if strcmp(obj.type, 'block') && strcmp(refFrame, 'global')
    position = obj.transformPosition(position);
end

% actual search
myoIndex = search_myocytes(obj.myocytes, position);

end
