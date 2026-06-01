function [ output_args ] = processSignal( input_args )
%PROCESSSIGNAL Summary of this function goes here
%   Detailed explanation goes here


% Diffusion tensor elements solver

b_factor = zeros(nDir ,1);
A        = zeros(nDir ,6);
for i=1:nDir
    if strcmp(pulse_sequence_type,'PGSE')
        b_factor(i)=(norm(directions(i,:))*gG*delta)^2*...
            (DELTA-delta/3);
        A(i,:)=(gG*delta)^2*(DELTA-delta/3)*...
            [directions(i,1)^2, directions(i,2)^2,directions(i,3)^2,...
            2*directions(i,1)*directions(i,2),2*directions(i,1)*...
            directions(i,3), 2*directions(i,2)*directions(i,3)];
    elseif strcmp(pulse_sequence_type,'STEAM')
        b_factor(i)=(norm(directions(i,:))*gG)^2*(delta^2*...
            (DELTA-delta/3)+ramp^3/30-delta*ramp^2/6);
        A(i,:)=(gG)^2*(delta^2*(DELTA-delta/3)...
            +ramp^3/30-delta*ramp^2/6)*[directions(i,1)^2, directions(i,2)^2,...
            directions(i,3)^2, 2*directions(i,1)*directions(i,2),...
            2*directions(i,1)*directions(i,3), 2*directions(i,2)*directions(i,3)];
    end
end

B = log(signal_ratio);
diff_tensor_elements=-(A.'*A)\(A.'*B); % Method of least squares/overdetermined system!

diff_tensor = eye(3).*v(1:3) + squareform(v(4:6)); % assign to tensor
[V, lambda] = eig(diff_tensor);

% PROCESSING EIGENVECTORS AND EIGENVALUES (PRINCIPAL DIFFUSIVITIES & DIRECTIONS):

lambda=diag(lambda);

[~,indices]=max(abs(V));
V_ordered=zeros(size(V));

for i=1:3
    if indices(i)==1
        lambda_x=lambda(i);
        V_ordered(:,1)=V(:,i);
    elseif indices(i)==2
        lambda_y=lambda(i);
        V_ordered(:,2)=V(:,i);
    elseif indices(i)==3
        lambda_z=lambda(i);
        V_ordered(:,3)=V(:,i);
    end
end

V=V_ordered;
ADC=[lambda_x lambda_y lambda_z];

% ANISOTROPIC INDICES:

% From signal simulations:
trace=sum(ADC);

MD=trace/3;

FA=sqrt(1.5)*norm(ADC-MD)/norm(ADC);

RA=sqrt(1/3)*norm(ADC-MD)/norm(MD);

VR=prod(ADC)/MD^2;

skewness=norm(ADC-MD,3)^3/3;

mode=moment(ADC,2).^(-1.5).*moment(ADC,3)*sqrt(2);

% From RMS simulations:
D_x_rms=rms_x^2/(2*DELTA);
D_y_rms=rms_y^2/(2*DELTA);
D_z_rms=rms_z^2/(2*DELTA);

ADC_RMS=[D_x_rms D_y_rms D_z_rms];

trace=sum(ADC_RMS);

MD_RMS=trace/3;

FA_RMS=sqrt(1.5)*norm(ADC_RMS-MD_RMS)/norm(ADC_RMS);

mode_RMS=moment(ADC_RMS,2).^(-1.5).*moment(ADC_RMS,3)*sqrt(2);

% ELLIPSOID
figure(4);
hold on
[x_e,y_e,z_e]=ellipsoid(0,0,0,ADC(1),ADC(2),ADC(3),30);
surf(x_e,y_e,z_e);
xlabel('x [a.u.]');ylabel('y [a.u.]');zlabel('z [a.u.]');
view (3)
axis normal


end

