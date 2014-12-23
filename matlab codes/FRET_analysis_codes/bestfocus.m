listing = dir('*.tif')
ii = 1;
file = listing(ii).name;
file = '63x_FRET_400ms_2bin_10g_3_w4YFP_s1.TIF';

info = imfinfo(file);
num_images = numel(info);
sharpness = zeros(num_images,1);
for k = 1:num_images
    img =  im2double(imread(file,k));
    sharpness(k)=estimate_sharpness(img);
end


figure;plot(sharpness,'O')