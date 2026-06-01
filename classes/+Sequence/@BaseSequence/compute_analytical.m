function [D] = compute_analytical(this, spacing, D0, N_terms)
%COMPUTE_ANALYTICAL Summary of this function goes here
%   Detailed explanation goes here

%TODO: 'this' requires
% * this.delta
% * this.G_peak
% * this.DELTA
% * this.bfactor

if nargin() < 4
    N_terms = 10; % 10 terms is usually enough
end
ii = 1:N_terms;

if isnan(this.delta)
    D = D0;
    return
end
if isinf(spacing) % no restriction
    D = D0;
    return;
end

K = this.delta * spacing * this.gamma * this.G_peak; % aux variable
terms     = exp(-(ii.^2*pi^2*D0*this.DELTA)/(spacing^2)) .* (1-(-1).^ii*cos(K)) ./ (K^2-(ii*pi).^2).^2;
attenuation = 2*(1 - cos(K))/K^2 + 4*K^2*sum(terms);
D = -log(attenuation)/this.bfactor;

end
