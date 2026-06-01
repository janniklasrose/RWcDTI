function [delta] = compute_delta(DELTA, epsilon, bfactor, G_peak)
%COMPUTE_DELTA Summary of this function goes here
%   Detailed explanation goes here

gamma = Sequence.BaseSequence.gamma;

delta_possible = roots([-1/3, +DELTA, -epsilon^2/6, +epsilon^3/30 - bfactor/(gamma*G_peak)^2]); % 0 == a*x^3, b*x^2, c*x
valid = false(size(delta_possible));
for i=1:numel(valid)
    valid(i) = delta_possible(i) >= 0 && isreal(delta_possible);
end
delta = min(delta_possible(valid)); % smallest positive real

end





% McNab -> pulse sequence

function [parameter] = bfactorTrapz(bfactor,gamma0,gradient,Delta,eta,epsilon)
    %%% SHORT HAND VARIABLES
    b = bfactor;     % bfactor
    g = gamma0;      % gamma0
    G = gradient;    % grad
    D = Delta;       % Delta
    d = epsilon+eta; % delta
    e = epsilon;     % epsilon
    n = eta;         % eta
    %%% SOLVE
    % select cases
    if     ischar(bfactor)
        b = G^2*g^2*(d^2*(D - d/3) - (d*e^2)/6 + e^3/30);
        if isempty(b) || ~isreal(b) || b < 0
            error('GPUcDTI:Simulation:bfactorTrapz','impossible "bfactor" detected');
        end
        parameter = b; % straightforward
    elseif ischar(gamma0)
        g = (30^(1/2)*b^(1/2))/(G*(30*D*d^2 - 5*d*e^2 - 10*d^3 + e^3)^(1/2));
        if isempty(g) || ~isreal(g) || g < 0
            error('GPUcDTI:Simulation:bfactorTrapz','impossible "gamma0" detected');
        end
        parameter = g; % positive root
    elseif ischar(gradient)
        G = (30^(1/2)*b^(1/2))/(g*(30*D*d^2 - 5*d*e^2 - 10*d^3 + e^3)^(1/2));
        if isempty(G) || ~isreal(G) || G < 0
            error('GPUcDTI:Simulation:bfactorTrapz','impossible "gradient" detected');
        end
        parameter = G; % positive root
    elseif ischar(Delta)
        D = ((d^3/3 + (d*e^2)/6 - e^3/30)*G^2*g^2 + b)/(G^2*d^2*g^2);
        if isempty(D) || ~isreal(D) || D < 0
            error('GPUcDTI:Simulation:bfactorTrapz','impossible "Delta" detected');
        end
        parameter = D; % straightforward
    elseif ischar(eta)
        d = roots([-10*G^2*g^2,+30*D*G^2*g^2,-5*G^2*e^2*g^2,-30*b+G^2*e^3*g^2]);
        if ~isreal(d)
            complexPair_mask = false(size(d));
            for i = 1:3
                complexPair_mask(i) = ~isreal(d(i));
            end
            complexPair = d(complexPair_mask);
            if abs(imag(complexPair(1)))<eps
                d = real(d);
            end
        end
        if ~isreal(d)
            complexPair_mask = false(size(d));
            for i = 1:3
                complexPair_mask(i) = ~isreal(d(i));
            end
            n = d(~complexPair_mask)-e; % real (not complex pair) root
        else
            n = d-e;
            n = min(n(n>=0 & n<=D-2*e)); % take the minimum positive value that fits
        end
        if isempty(n) || ~isreal(n) || n < 0
            error('GPUcDTI:Simulation:bfactorTrapz','impossible "eta" detected');
        end
        parameter = n;
    elseif ischar(epsilon)
        e = roots([+G^2*g^2,-5*G^2*d*g^2,0,-30*b-10*G^2*d^3*g^2+30*D*G^2*d^2*g^2]);
        if ~isreal(e)
            complexPair_mask = false(size(e));
            for i = 1:3
                complexPair_mask(i) = ~isreal(e(i));
            end
            complexPair = e(complexPair_mask);
            if abs(imag(complexPair(1)))<eps
                e = real(e);
            end
        end
        if ~isreal(e)
            complexPair_mask = false(size(e));
            for i = 1:3
                complexPair_mask(i) = ~isreal(e(i));
            end
            e = e(~complexPair_mask); % real (not complex pair) root
        else
            e = min(e(e>=0 & e<=(D-n)/2)); % take the minimum positive value
        end
        if isempty(e) || ~isreal(e) || e < 0
            error('GPUcDTI:Simulation:bfactorTrapz','impossible "epsilon" detected');
        end
        parameter = e;
    else
        error('GPUcDTI:Simulation:bfactorTrapz','invalid request');
    end
end
