function [h] = plot(this, varargin)
%PLOT Summary of this function goes here
%   Detailed explanation goes here

if nargin>1 && isscalar(varargin{1}) && ishandle(varargin{1})
    ax = varargin{1};
    varargin = varargin(2:end);
else
    ax = gca;
end
h = plot(ax, [0, cumsum(this.dt)], [this.gG, 0]/this.gamma, varargin{:});

end
