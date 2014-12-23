%fname1 = 'H35_FRET_s7_FRET Efficiency (%).tif';
%fname2 = 'H35_FRET_s3_FRET.TIF';
img2 = imread(fname2);
img2v = img2vector(img2);
figure;cdfplot(img2v)
xlabel('FRET %')

fname1 = 'H35_dcytoFRET_s1_FRET Efficiency (%) .tif';
img1 = imread(fname1);
img1v = img2vector(img1);
%figure;cdfplot([img1v;img2v])
close all;
figure;cdfplot(img1v)
xlabel('FRET %')
