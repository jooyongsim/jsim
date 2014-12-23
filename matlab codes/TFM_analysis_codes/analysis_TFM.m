function analysis_TFM
% This code calculate the cell-cell and cell-ECM forces (i.e., Fy and Fx)
% from the traction force map data in text file format and the ROI of 
% the cell-cell junction in the comma separated value format (csv file). 
%% clean the command window, close all windows and clear all variables
clc
close all
clear all

% size of ROI which surround the cell TFM area
H = 1344;
W = 1024;

% Area of a pixel, the pixel size of 63X oil with Orca 2 in the inverted
% and window size 128, 64, 32 PIV
PixelToUm = 0.10238;
PixelToM = 0.10238*1e-6;
windowM2 = (PixelToM)^2*16; % window area meter^2
PixelWindow = 16;
windowM2 = windowM2*16^2;

%Read the pre-defined cell-cell junction position data file (comma-separated value file)
listing = dir('*.csv');
if length(listing)>=2
    disp('error too many ROI files')
else

%Convert the cell type to the array type for the file name
    fname = listing.name
%Read the file, which contains the information of the cell-cell junction location
    fileID = fopen(fname);
%File has the information in the format of following column sequence
% Cell#, BX, BY, Width, Height, Length, filename
    C = textscan(fileID,'%f %f %f %f %f %f %f %s','delimiter',',','commentStyle','//','CollectOutput',1);
    fclose(fileID);
    celldisp(C)
end
%Cell#: the index of cell in the multiple data by turns
%BX, BY: the left and top corner of the bounding box of the cell-cell junction location in pixel
%Width, Height: the width and height of the bounding box of the cell-cell junction location in pixel
%Angle: the angle of the cell-cell junction location in degree
%Length: the length of the cell-cell junction
%filename: the file name of the traction force map output (txt file)

%Convert the input data list from the cell type to the matrix type
T = C{1};
FileName = C{end};

% Define the matrix of averaged Fx, Fy
Fxii = zeros(size(FileName,1),2);
Fyii = zeros(size(FileName,1),2);
Fxii_intra = zeros(size(FileName,1),2); 
    % Here, Fxii should be converged to near zero, which depends on the noise of data
    % Here, Fxii_intra is the cell-ECM force, which calculate the absolute force in X direction

% Calculate the Fx and Fy
for ii=1:size(FileName,1)
ii
ib = T(ii,:);
% The corner of the coordinate are defined from the left and top cornder as a (1,1) of the image matrix
% x, y->> Width of image
% |
%v
% Height of image

% Read the ROI information
x = ib(2); 
y = ib(3);
w = ib(4);
h = ib(5);
angle_degree = ib(6);

% Calculate the center of the cell pair
xc = x + w/2;
yc = y + h/2;

% Convert the angle from degree to radian
angle = convang(angle_degree,'deg','rad');

% Calculate the coordinate transformation matrix
Trans = [cos(angle) -sin(angle);sin(angle) cos(angle)];
Xcp = Trans*[xc;yc];
xcp = Xcp(1);
ycp = Xcp(2);
 
% The corner coordinates are:
% x1,y1          x2,y1   ->> increase pixel
% x1,y3          x2,y3
% x1,y2          x2,y2
% |
% V
% V Increase pixel
% The corners of each cell are represented by four points, i.e., the line of x1, y3 and x2, y3 is the cell-cell junction
x1 = xcp - W/2;
y1 = ycp - H/2;
x2 = xcp + W/2;
y2 = ycp + H/2;
y3 = ycp; 
 
% Read the traction force output file (text file)
TFMdata = load(FileName{ii});
X = TFMdata(:,1:2);
F = TFMdata(:,3:4);
mag = TFMdata(:,5);
Xp = (Trans*X')';
Fp = (Trans*F')';
 
% Read the piv output file
FN = FileName{ii};
pivfn = FN(10:end);
pivdata = load(pivfn);
pivU = pivdata(:,3:4);
% calculate the displacement magnitudes
UV = sqrt(pivU(:,1).^2 + pivU(:,2).^2);

% Calculate the strain energy
E = UV.*mag;
E = E*windowM2*PixelToM/2;
 
% Plot the traction force map
figure;
quiver(X(:,1),X(:,2),F(:,1),F(:,2))
figure;
quiver(Xp(:,1),Xp(:,2),Fp(:,1),Fp(:,2))
hold on
plot(x1,y1,'rO')
plot(x2,y2,'rO')
plot(x2,y3,'rO')
plot(x2,y1,'rO')
 
 % Define the temporary vector summation variable for each direction and each cell
[m,n] = size(TFMdata); 
sumX_vec1 = 0;
sumY_vec1 = 0;
sumX_vec2 = 0;% The inter cellular force vector sum for the BOTTOM CELL
sumY_vec2 = 0;% The intra cellular force vector sum for the BOTTOM CELL
sumX_vec1_intra = 0;% Whole X and Half Y of the sum of traction force
sumX_vec2_intra = 0;% Whole X and Half Y of the sum of traction force
sumX_vec = 0;% Total force balance which should be zero otherwise noise
sumY_vec = 0;
sumE_vec_top = 0;
sumE_vec_bottom = 0;

% Define the ROI of each cell in the each direction X and Y
for i = 1:m
    % Whole X and Half Y of the sum of traction force **TOP**
     if (x1<Xp(i,1))&&(x2>Xp(i,1))&&(y1<Xp(i,2))&&(y3>Xp(i,2))
         sumX_vec1 = sumX_vec1 + Fp(i,1);
         sumY_vec1 = sumY_vec1 + Fp(i,2);
         plot(Xp(i,1),Xp(i,2),'rO')
         sumE_vec_top = sumE_vec_top + abs(E(i,1));
     end
     % Whole X and Half Y of the sum of traction force **BOTTOM**
     if (x1<Xp(i,1))&&(x2>Xp(i,1))&&(y3<Xp(i,2))&&(y2>Xp(i,2))
         sumX_vec2 = sumX_vec2 + Fp(i,1);
         sumY_vec2 = sumY_vec2 + Fp(i,2);
         plot(Xp(i,1),Xp(i,2),'gO')
         sumE_vec_bottom = sumE_vec_bottom + abs(E(i,1));
     end
 
     % Calculate the absolute Force - X direction
     if (x1<Xp(i,1))&&(x2>Xp(i,1))&&(y1<Xp(i,2))&&(y3>Xp(i,2))
         sumX_vec1_intra = sumX_vec1_intra + abs(Fp(i,1));
     end
     if (x1<Xp(i,1))&&(x2>Xp(i,1))&&(y3<Xp(i,2))&&(y2>Xp(i,2))
         sumX_vec2_intra = sumX_vec2_intra + abs(Fp(i,1));
     end
 
    % Calculate the whole X, and Y vector sum of the traction force, as noise check and it should be near zero
     if (x1<TFMdata(i,1))&&(x2>TFMdata(i,1))&&(y1<TFMdata(i,2))&&(y2>TFMdata(i,2))
         sumX_vec = sumX_vec + TFMdata(i,3);
         sumY_vec = sumY_vec + TFMdata(i,4);
     end 
end
sumX_vec1_nN = sumX_vec1*windowM2*1e9;% The intra cellular force vector sum for the TOP CELL
sumY_vec1_nN = sumY_vec1*windowM2*1e9;% The inter cellular force vector sum for the TOP CELL
sumX_vec2_nN = sumX_vec2*windowM2*1e9; % The intra cellular force vector sum for the bottom cell
sumY_vec2_nN = sumY_vec2*windowM2*1e9;% The inter cellular force vector sum for the bottom cell
sumX_vec1_nN_intra = sumX_vec1_intra*windowM2*1e9; % Convert the unit from Newton/pixel2 to Newton/micron2
sumX_vec2_nN_intra = sumX_vec2_intra*windowM2*1e9;
sumX_vec_nN = sumX_vec*windowM2*1e9;
sumY_vec_nN = sumY_vec*windowM2*1e9;

% Add the calculated each forces (cell-cell and cell-ECM force, i.e., Fy and Fx to the array including all cell image data) 
Fxii_intra(ii,1) = sumX_vec1_nN_intra; % Unit in [nN]
Fxii_intra(ii,2) = sumX_vec2_nN_intra;
Fxii(ii,1) = sumX_vec1_nN;
Fxii(ii,2) = sumX_vec2_nN;
Fyii(ii,1) = sumY_vec1_nN;
Fyii(ii,2) = sumY_vec2_nN;
sumE(ii,1) = sumE_vec_top; % Unit in [J]
sumE(ii,2) = sumE_vec_bottom;
end

% Convert N X 2 force matrix for the two cell * N image data to 2*N X 1 vector array
Fyii_inter=[Fyii(:,1);-Fyii(:,2)];
Fxii_intra_ECM = reshape(Fxii_intra,size(Fxii_intra,1)*2,1);
Fyii_inter = Fyii_inter % inter cell-cell adhesion force
Fxii_intra_ECM = Fxii_intra_ECM % intra ECM traction force
sumE = sumE*1e15 % Unit in [fJ]
