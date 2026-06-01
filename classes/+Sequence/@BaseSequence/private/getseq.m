function [t1, t2, t3, t4, gG] = getseq(pulse_sequence_type)

gamma=267.513e6; % gyromagnetic ratio for hydrogen

if strcmp(pulse_sequence_type,'PGSE')
    
    DELTA=34.6e-3; % diffusion time;time difference between the two gradients
    delta=25.4e-3; % DELTA>delta
    G=sqrt(500e6/(2*(gamma*delta)^2*(DELTA-delta/3)));
    
    alpha=0.5*(DELTA-delta);
    
    t1=alpha;
    t2=t1+delta;
    t3=3*alpha+delta;
    t4=t3+delta;
    
elseif strcmp(pulse_sequence_type,'STEAM')
    
    ramp=0.66e-3;
    flat=0.8e-3;
    
    % b calculated for DELTA=1 s and for STEAM sequence
    G_selection=struct('reference',24.83e-3,'b1000',23.56e-3,'b1200',...
        25.81e-3,'b200',10.54e-3,'b500',40.5e-3);
    G=G_selection.b500;
    TE=45e-3;
    
    DELTA=500e-3:250e-3:2000e-3;
    DELTA=DELTA(1);
    
    delta=ramp+flat; % gradient application time (DELTA>delta)
    
    alpha=TE/4-ramp-flat/2;
    TM=DELTA-2*(alpha+ramp)-flat;
    
    t1=alpha;
    t2=t1+delta;
    t3=3*alpha+TM+2*ramp+flat;
    t4=t3+delta;
    
end

gG = gamma*G;

end
