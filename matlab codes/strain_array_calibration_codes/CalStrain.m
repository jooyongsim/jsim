function [Exx,Eyy,Exy]=CalStrain(x,y,u,v,ctype)
% CalStrain calculates the in-plane Strain 
% INPUT x, y coordinate vector and u, v displacement vector
% x = [x1 x2 x3 x4
% ....
% ....
% .... x16] at 0 kPa tare pressure) 
 
% OUTPUTs are Exx,Eyy,Exy
% Exx = [Ex1 Ex2 Ex3
% Ex4 Ex5 Ex6
% Ex7 Ex8 Ex9]
 
% Get the size of the coordinate matrix x in M, N
[N,M]=size(x);
 
% Define the identity matrix  
I2=eye(2);
 
% Check if the coordinate is Cartesian or polar
if strcmp(ctype,'cartesian')
Exx=zeros(N-1,M-1);
Eyy=zeros(N-1,M-1);
Exy=zeros(N-1,M-1);
Exxh=0;Eyyh=0;Exyh=0;

 % Calculate the Green-Lagrange strain tensor
for i =1:N-1
for j =1:M-1;
 % Calculate the tensor elements before stretching 
X1 = [x(i,j);y(i,j)];
X2 = [x(i+1,j);y(i+1,j)];
X3 = [x(i,j+1);y(i,j+1)];
dX2=X2-X1;dX3=X3-X1;
Q = [dX2 dX3];

 % Calculate the tensor elements after stretching 
X1p = [x(i,j);y(i,j)]+[u(i,j);v(i,j)];
X2p = [x(i+1,j);y(i+1,j)]+[u(i+1,j);v(i+1,j)];
X3p = [x(i,j+1);y(i,j+1)]+[u(i,j+1);v(i,j+1)];
dX2p=X2p-X1p;dX3p=X3p-X1p;
Qp = [dX2p dX3p];

 % Calculate the deformation gradient tensor F 
F = Qp/Q; 

% Calculate the Green-Lagrange strain tensor
E=1/2*((F-I2)+(F-I2)'+(F-I2)*(F-I2)');
Exx(i,j)=E(1,1);
Eyy(i,j)=E(2,2);
Exy(i,j)=E(1,2);
Exxh=[Exxh E(1,1)];
Eyyh=[Eyyh E(2,2)];
Exyh=[Exyh E(2,1)];
end
end

 % Calculation for the polar coordinate
elseif strcmp(ctype,'polar')
Err=zeros(N-1,M-1);
Ett=zeros(N-1,M-1);
Ert=zeros(N-1,M-1);

% Calculate the Green-Lagrange strain tensor
for i =1:N-1
for j =1:M-1;

 % Calculate the tensor elements before stretching 
X1 = [x(i,j);y(i,j)];
X2 = [x(i+1,j);y(i+1,j)];
X3 = [x(i,j+1);y(i,j+1)];
dX2 = X2-X1; dX3 = X3-X1;
dX2 = [sqrt(dX2(1)^2+dX2(2)^2);atan(dX2(2)/dX2(1))];
dX3 = [sqrt(dX3(1)^2+dX3(2)^2);atan(dX3(2)/dX3(1))];
Q = [dX2 dX3];

 % Calculate the tensor elements after stretching 
X1p = [x(i,j);y(i,j)]+[u(i,j);v(i,j)];
X2p = [x(i+1,j);y(i+1,j)]+[u(i+1,j);v(i+1,j)];
X3p = [x(i,j+1);y(i,j+1)]+[u(i,j+1);v(i,j+1)];
dX2p=X2p-X1p;dX3p=X3p-X1p;
dX2p = [sqrt(dX2p(1)^2+dX2p(2)^2);atan(dX2p(2)/dX2p(1))];
dX3p = [sqrt(dX3p(1)^2+dX3p(2)^2);atan(dX3p(2)/dX3p(1))];
Qp = [dX2p dX3p];

 % Calculate the deformation gradient tensor F 
F = Qp/Q;
 
% Calculate the Green-Lagrange strain tensor
E=1/2*((F-I2)+(F-I2)'+(F-I2)*(F-I2)');
Err(i,j)=E(1,1);
Ett(i,j)=E(2,2);
Ert(i,j)=E(1,2);
end
end
Exx = Err;
Eyy = Ett;
Exy = Ert;
else

 % If the coordinate type is neither Cartesian or polar, display an error message
disp('coordinate type input error')
Exx = [];
Eyy = [];
Exy = [];
end

