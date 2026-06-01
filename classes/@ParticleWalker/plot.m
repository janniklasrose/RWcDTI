function [] = plot(this)
%PLOT Summary of this function goes here
%   Detailed explanation goes here

figure();
ax = gobjects(1, 4);
dimnames = 'xyz';
for dim = 1:3
    ax(dim) = subplot(3, 3, 1+(dim-1)*3);
    histogram(ax(dim), this.position(:, dim));
    xlabel([dimnames(dim), ' [m]']);
    ylabel('count [-]');
end
ax(4) = subplot(3, 3, [2:3,5:6,8:9]);
plot3(ax(4), this.position(:, 1), this.position(:, 2), this.position(:, 3), 'b.'); % points
axis equal;
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
drawnow;

end
