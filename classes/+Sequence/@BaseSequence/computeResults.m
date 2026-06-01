function [RESULT] = computeResults(this, phase)

% bvalue has to be per direction (2 at the same time)

% attenuation vector
dir = [1, 1, 0; 1, -1, 0; 1, 0, 1; 1, 0, -1; 0, 1, 1; 0, 1, -1];
signal_ratio = zeros(size(dir, 1), 1);
for n = 1:size(dir, 1)
    particle_phase = sum(dir(n, :) .* phase, 2);
    signal_exp = sum(exp(-1i*particle_phase));
    signal_ratio(n) = abs(signal_exp/size(phase, 1));
end
b = log(signal_ratio);

% b-matrix
A = zeros(length(dir), 6);
for iDir = 1:length(dir)
    dir_i = dir(iDir, :);
    A(iDir, :) = this.bfactor * [dir_i(1)^2, dir_i(2)^2, dir_i(3)^2, ... % xx, yy, zz
        2*dir_i(1)*dir_i(2), 2*dir_i(1)*dir_i(3), 2*dir_i(2)*dir_i(3)];  % xy, xz, yz
end

% least squares solution
DTI = -lscov(A, b); % LAPACK can do this
tensor = [DTI(1), DTI(4), DTI(5); DTI(4), DTI(2), DTI(6); DTI(5), DTI(6), DTI(3)]; % assign
[vector, lambda_3x3] = eig(tensor);
lambda = diag(lambda_3x3).';
[~, idx] = sort(lambda, 'descend');
Evec = vector(:, idx); % (E1, E2, E3) eigenvectors
Eval = lambda(:, idx); % (E1, E2, E3) eigenvalues
MD = trace(tensor)/3; % mean diffusivity
FA = sqrt(1.5)*sqrt(sum((Eval-MD).^2))./sqrt(sum(Eval.^2)); % fractional anisotropy
%                norm(Eval-MD) / norm(Eval)
TM = moment(Eval, 2).^(-3/2).*moment(Eval, 3)*sqrt(2); % mode
% mean((Eval-mean(Eval)).^2)^(-3/2)*mean val-mean(Eval)).^3)*sqrt(2);

RESULT.tensor = tensor;
RESULT.Evec = Evec; % (E1, E2, E3) eigenvectors
RESULT.Eval = Eval; % (E1, E2, E3) eigenvalues
RESULT.MD = MD; % mean diffusivity
RESULT.FA = FA; % fractional anisotropy
RESULT.mo = TM; % tensor mode

end
