function [h] = plot(this, varargin)

%%% checks
nargoutchk(0, 1);
%TODO: parse varargin and disallow those that corrupt the data

%%% core task
fn_patch = patch('XData', this.Vertices(:, 1), 'YData', this.Vertices(:, 2), varargin{:});

%%% output
if nargout == 1
    h = fn_patch(); % pass function handle like plot does
else
    fn_patch(); % call plot by itself
end

end
