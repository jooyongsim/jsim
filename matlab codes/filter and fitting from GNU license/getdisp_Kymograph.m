function displacement = getdisp_Kymograph(fname)

% this fuction read Kymograph img file and coverting to binary and calculate the
% vertical displacemetn
img = imread(fname);
h = fspecial('gaussian',[3 3],0.5);
img = imfilter(img,h);
level = graythresh(img);
BW = im2bw(img,level);
BW = imrotate(BW,90);
BW = imfill(BW,'holes');
output = sum(BW);
% figure;imshow(BW)

% figure;plot(output)
% medfn = 5;
% output = medfilt1(output,medfn);
output = smooth(output);
% figure;plot(output)
displacement = output;
% diff = output(2:end) - output(1:end-1);
% ff = 5;
% diff = output(ff:end) - output(1:end-ff+1);
% figure;plot(diff)
end
%%


