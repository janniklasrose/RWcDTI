function [varargout] = transformPosition(obj, position)
% transform the position using the substrate transform

varargout = cell(1, nargout); %TODO: more elegant way?
[varargout{1:nargout}] = obj.transform.transformPosition(position);

end
