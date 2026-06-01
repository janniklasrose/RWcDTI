function [] = makeMCSE(this, bfactor, G_peak, slewrate)
%MAKEMCSE Summary of this function goes here
%   Detailed explanation goes here

epsilon = 0.000661;
delta1 = 0.007819;
delta2 = 0.016299;

TM = 2*epsilon+delta1;

alpha90 = 0.001272;
alphaEcho = 0.012141 / 2 + 0.000749;

% once final values are found, compute the sequence
t_Dt = [alpha90, epsilon,   delta1, epsilon, epsilon,  delta2, epsilon,     TM, epsilon,   delta2, epsilon, epsilon,  delta1, epsilon, alphaEcho];
idFine = [2:7, 9:14];
idCorse = [1, 8, 15];
DELTA = sum(t_Dt(2:8));

tau  = epsilon;
del1 = delta1+2*epsilon;
del2 = delta2+2*epsilon;
bfactor_in = bfactor;
bfactor = this.gamma^2*G_peak^2 * ( del2^2*(DELTA+tau) ...
        + ((tau^2-DELTA*tau+2*DELTA*del2)^3 - 12*del2^3*(DELTA+tau)^3) / (12*(DELTA+2*del2-tau)^3) ...
        + (del2^2*(DELTA+tau)^2*(DELTA+3*del2)) / ((DELTA+2*del2-tau)^2)... % + or - ???
        - del2*tau^2/6 + 49*tau^3/60 - del2^3/3 ...
        - (tau^2*(tau^2-DELTA*tau+2*DELTA*del2) + 3*del2^2*(DELTA+tau)*(2*DELTA+del2+2*tau)) / (3*(DELTA+2*del2-tau)) ...
        );
if abs(bfactor_in-bfactor) > 1e6
    error('bfactor does not match');
end
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
gG_peak = Sequence.BaseSequence.gamma*G_peak;
for i = 1:numel(gG)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if     t(i) >= t_ms(1) && t(i) < t_ms(2) % gradient 1a - ramp up
        gG(i) = +gG_peak*(t(i)-t_ms(1))/(t_ms(2)-t_ms(1));
    elseif t(i) >= t_ms(2) && t(i) < t_ms(3) % gradient 1a - plateau
        gG(i) = +gG_peak;
    elseif t(i) >= t_ms(3) && t(i) < t_ms(4) % gradient 1a - ramp down
        gG(i) = +gG_peak*(1 - (t(i)-t_ms(3))/(t_ms(4)-t_ms(3)));
    elseif t(i) >= t_ms(4) && t(i) < t_ms(5) % gradient 1b - ramp down
        gG(i) = -gG_peak*(t(i)-t_ms(4))/(t_ms(5)-t_ms(4));
    elseif t(i) >= t_ms(5) && t(i) < t_ms(6) % gradient 1b - plateau
        gG(i) = -gG_peak;
    elseif t(i) >= t_ms(6) && t(i) < t_ms(7) % gradient 1b - ramp up
        gG(i) = -gG_peak*(1 - (t(i)-t_ms(6))/(t_ms(7)-t_ms(6)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif t(i) >= t_ms(7+1) && t(i) < t_ms(7+2) % gradient 2a - ramp up
        gG(i) = +gG_peak*(t(i)-t_ms(7+1))/(t_ms(7+2)-t_ms(7+1));
    elseif t(i) >= t_ms(7+2) && t(i) < t_ms(7+3) % gradient 2a - plateau
        gG(i) = +gG_peak;
    elseif t(i) >= t_ms(7+3) && t(i) < t_ms(7+4) % gradient 2a - ramp down
        gG(i) = +gG_peak*(1 - (t(i)-t_ms(7+3))/(t_ms(7+4)-t_ms(7+3)));
    elseif t(i) >= t_ms(7+4) && t(i) < t_ms(7+5) % gradient 2b - ramp down
        gG(i) = -gG_peak*(t(i)-t_ms(7+4))/(t_ms(7+5)-t_ms(7+4));
    elseif t(i) >= t_ms(7+5) && t(i) < t_ms(7+6) % gradient 2b - plateau
        gG(i) = -gG_peak;
    elseif t(i) >= t_ms(7+6) && t(i) < t_ms(7+7) % gradient 2b - ramp up
        gG(i) = -gG_peak*(1 - (t(i)-t_ms(7+6))/(t_ms(7+7)-t_ms(7+6)));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

this.dt = dt;
this.gG = gG;
this.bfactor = bfactor;
this.DELTA = DELTA;
this.delta = NaN;

end
