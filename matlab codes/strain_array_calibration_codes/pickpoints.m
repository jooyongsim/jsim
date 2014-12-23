% In the part of the strain array calibration
% This code is to track fiducial markers by picking points manually 

% 9/11/10 temporally change the code for the ID Glide 00M (omit 'M')
% 9/12/10 return back to the 60M 

% INPUT: reads 00M1B00.tif and following files
% 00M1B00.tif
% 00M1B10.tif
% 00M1B15.tif
% 00M1B20.tif
% The last two digit indicating pressure 0kPa, 10 kPa, 15kPa, 20kPa

% OUTPUT: save 00M1B.mat and following files
% 00M1B.mat
% includes xcord ycord
% e.g., [xcord] is 
% 16 x 4    pressure 00  pressure 10  pressure 15  pressure 20
% 16 points x coordinate ---- 

% INCLUDES
% This code should include followings
% - impixel1
% - getpts1
% These are modified from impixel, getpts in the Matlab 7.10

% NOTES:
% The first two digit indicates time points 00M is after 0 minutes of
% strain
% 1B indicates 1 column of well and B is the largest post (least strain)

function pickpoints
%Image input file name
ImgFileTime = input('Time of Image (include M)- Enter for Default[00M1B00.tif]: ', 's');

%Sparse the input file name
if isempty(ImgFileTime)
ImgFileTime = '00M';
end
%In the format of 00M1B00, the first two numbers represent the time point as a unit of minutes
%The number following 'M' (minutes) is the order of the column in 5 X 5 strain array. 
ImgFileColumn = input('Column of Image - Enter for Default[00M1B00.tif]: ', 's');
if isempty(ImgFileColumn)
ImgFileColumn = '1';
end

%The following letter from 'A' to 'E' represents the row from the top bottom (no train to maximum strain).
ImgFileRow = input('Row of Image - Enter for Default[00M1B00.tif]: ', 's');
if isempty(ImgFileRow)
ImgFileRow = 'B';
end
%The following two numbers represent the pressure applied to the membrane in the unit kPa.
%Merge file names
FileName1 = [ImgFileTime ImgFileColumn ImgFileRow '00.tif'];
FileName2 = [ImgFileTime ImgFileColumn ImgFileRow '10.tif'];
FileName3 = [ImgFileTime ImgFileColumn ImgFileRow '15.tif'];
FileName4 = [ImgFileTime ImgFileColumn ImgFileRow '20.tif'];

%pick points
img1= imread(FileName1); %unload image
img2= imread(FileName2); %load image 2
img3= imread(FileName3); %load image 3
img4= imread(FileName4); %load image 4
[x1,y1,P]=impixel1(img1); % pick beads at unload image 1

% display the picked points
for i=1:size(x1,1)
text(x1(i)+15,y1(i),['\color{red}' int2str(i)]);
end
figure;imshow(img2)
for i=1:size(x1,1)
text(x1(i)+15,y1(i),['\color{red}' int2str(i)]);
end
% pick beads at image 2
 [x2,y2,P]=impixel1; 
figure;imshow(img3)

% display the picked points
for i=1:size(x1,1)
text(x1(i)+15,y1(i),['\color{red}' int2str(i)]);
end
[x3,y3,P]=impixel1; 
figure;imshow(img4)
for i=1:size(x1,1)
text(x1(i)+15,y1(i),['\color{red}' int2str(i)]);
end

% pick beads at image 4
[x4,y4,P]=impixel1; 
xcord = [x1 x2 x3 x4]; ycord = [y1 y2 y3 y4];

% save the coordinate to txt file
FileName4SaveText=[ImgFileTime ImgFileColumn ImgFileRow '.txt'];
save(FileName4SaveText,'xcord','ycord','-ascii');
FileName4SaveMat = [ImgFileTime ImgFileColumn ImgFileRow];
save(FileName4SaveMat,'xcord','ycord');
close all
end
