function [] = makeSTEAM(this, bfactor, G_peak, slewrate)
%MAKESTEAM Summary of this function goes here
%   Detailed explanation goes here

% based on MAKEPGSE (same principle)

alpha90 = 0.002212; % half the RF gradient plus short reverse gradient
alpha180 = 0; % whole duration of 180 pulse (CAN BE IGNORED FOR THIS SEQUENCE)
alphaEcho = 0.012141 / 2 - 0.000749; % half of readout time plus little pause before

epsilon = G_peak/slewrate;

maxTE = 100; % limited by T2
minTE = alpha90+2*epsilon+alpha180+2*epsilon+alphaEcho; % this is the theoretical minimum for TE, but not possible for alphaEcho ~= alpha90

% we will go through all DELTA values and pick the optimal one
DELTA_values = 1; % 1second
delta_values = NaN(size(DELTA_values));
TE_values    = NaN(size(DELTA_values));
for i = 1:numel(DELTA_values) % try all possible DELTA values
    
    % take any DELTA
    DELTA_i = DELTA_values(i);
    
    % compute delta
    delta_i = this.compute_delta(DELTA_i, epsilon, bfactor, G_peak); % returns all positive real deltas
    delta_i = min(delta_i); % take smallest
    
    % did not find a positive real delta
    if isempty(delta_i) || isnan(delta_i) || isinf(delta_i)
        continue; % delta_values(i) stays NaN
    end
    
    % check if delta is valid
    TE_i = alpha90 + DELTA_i + (epsilon+delta_i+epsilon) + alphaEcho;
    t0_i = 0;
    t1_i = t0_i + alpha90;
    t4_i = t1_i + (epsilon+delta_i+epsilon); % end of first gradient
    t5_i = t1_i + DELTA_i; % start of second gradient
    t6_i = t5_i + (epsilon+delta_i+epsilon); % end of second gradient
    invalid(1) = TE_i > maxTE || TE_i < minTE; % TE in bounds
    invalid(2) = t5_i < TE_i/2+alpha180/2 || t4_i > TE_i/2-alpha180/2; % 180 at TE/2 overlaps with gradients
    invalid(3) = t6_i > TE_i-alphaEcho; % second gradient overlaps with signal readout
    %... add more constraints
    if any(invalid)
        continue; % delta_values(i) stays NaN
    end
    
    TE_values(i)    = TE_i;
    delta_values(i) = delta_i; %NOTE: this is the delta in the bvalue notation, i.e. flat+ramp
    
end

if all(isnan(TE_values))
    error('No suitable sequence found');
end

% pick the delta that yielded the lowest TE
[~, idx] = min(TE_values);
DELTA = DELTA_values(idx);
delta = delta_values(idx)-epsilon;
TE    = TE_values(idx);

% aux
TM = DELTA - (epsilon+delta+epsilon);

delta2  = delta + epsilon;
bfactor_old = bfactor;
bfactor = (this.gamma*abs(G_peak))^2 * (delta2^2*(DELTA-delta2/3) + epsilon^3/30 - delta2*epsilon^2/6); %*sqrt(2)
if abs(bfactor-bfactor_old) > 1e6
    error('bfactor does not match');
end

% once final values are found, compute the sequence
t_Dt = [alpha90, epsilon, delta, epsilon, TM, epsilon, delta, epsilon, alphaEcho];
idFine = [2:4, 6:8];
idCorse = [1, 5, 9];
durationFine = sum(t_Dt(idFine));
durationCorse = sum(t_Dt(idCorse));

dtCurrent = (durationCorse + durationFine)/this.nT;
dtCorse = min(dtCurrent, this.MAXDTCORSE);
dtFine  = min(dtCurrent, this.MAXDTFINE);
t_Nt = zeros(size(t_Dt));
t_Nt(idCorse) = ceil(t_Dt(idCorse)/dtCorse);
t_Nt(idFine) = ceil(t_Dt(idFine)/dtFine);

t = 0;
for i=1:numel(t_Dt)
    t = [t(1:end-1), t(end)+linspace(0, t_Dt(i), t_Nt(i)+1)];
end
t = unique(t); % should already be unique but lets be safe
t_ms = cumsum(t_Dt); % milestones
dt = diff(t);
gG = zeros(size(dt));
gG_peak = this.gamma*G_peak;
for i = 1:numel(gG)
    if     t(i) >= t_ms(1) && t(i) < t_ms(2) % gradient 1 - ramp up
        gG(i) = +gG_peak*(t(i)-t_ms(1))/(t_ms(2)-t_ms(1));
    elseif t(i) >= t_ms(2) && t(i) < t_ms(3) % gradient 1 - plateau
        gG(i) = +gG_peak;
    elseif t(i) >= t_ms(3) && t(i) < t_ms(4) % gradient 1 - ramp down
        gG(i) = +gG_peak*(1 - (t(i)-t_ms(3))/(t_ms(4)-t_ms(3)));
    elseif t(i) >= t_ms(5) && t(i) < t_ms(6) % gradient 2 - ramp down
        gG(i) = -gG_peak*(t(i)-t_ms(5))/(t_ms(6)-t_ms(5));
    elseif t(i) >= t_ms(6) && t(i) < t_ms(7) % gradient 2 - plateau
        gG(i) = -gG_peak;
    elseif t(i) >= t_ms(7) && t(i) < t_ms(8) % gradient 2 - ramp up
        gG(i) = -gG_peak*(1 - (t(i)-t_ms(7))/(t_ms(8)-t_ms(7)));
    end
end

this.dt = dt;
this.gG = gG;
this.bfactor = bfactor;
this.DELTA = DELTA;
this.delta = delta2;

end
