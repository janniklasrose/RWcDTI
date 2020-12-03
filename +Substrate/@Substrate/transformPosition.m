function [varargout] = transformPosition(obj, position)
% transform the position using the substrate transform
%   just a wrapper around the transform function

[varargout{1:nargout}] = obj.transform.transformPosition(position);

end
