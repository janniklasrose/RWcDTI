function [h] = plot(this, varargin)

%%% checks
nargoutchk(0, 1);
%TODO: parse varargin and disallow options that don't make sense

%%% core task
switch this.DIM
    case 3
        fn_plot = @() plot3(this.Coordinates(1), this.Coordinates(2), this.Coordinates(3), varargin{:});
    case 2
        fn_plot = @() plot(this.Coordinates(1), this.Coordinates(2), varargin{:});
    case 1
        fn_plot = @() plot(this.Coordinates, 0, varargin{:});
    otherwise
        error('I don''t know how to plot this Point!');
end

%%% output
if nargout() == 1
    h = fn_plot(); % pass function handle like plot does
else
    fn_plot(); % call plot by itself
end

end
