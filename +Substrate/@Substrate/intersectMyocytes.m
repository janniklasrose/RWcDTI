function [intersectInfo] = intersectMyocytes(obj, position, dxdydz, refFrame)
% find intersection of step with myocytes
%   assumes position is in the global coordinate frame and transforms if necessary
%   (unless specified as 'local' with refFrame)

% transformation if needed
if nargin < 3
    refFrame = 'global';
end
if strcmp(obj.type, 'block') && strcmp(refFrame, 'global')
    position = obj.transformPosition(position);
end

% initialise
intersectInfo = []; % empty in case nothing is found

% find all that need proper checking - can do it in local since we checked above
needsChecks = obj.needsChecking(position, dxdydz, 'local'); % ~(wontEnter && isOutside)

% do the checking
for iMyocyte = find(needsChecks) % only relevant ones

    % find intersection
    try
        [info] = obj.myocytes(iMyocyte).intersection(position, dxdydz);
    catch exception
        switch exception.identifier
            case 'exec:tooclose'
                rethrow(exception); % is being handled
            otherwise
                rethrow(exception);
        end
    end

    % handle result
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

end
