function FRET_image_ROI_selection
% this code allows user to define the ROI (region of interest)
% where he or she wants to analyze FRET

% load the list of tif files in the working folder
listing = dir('*.tif');
name = {listing.name};
[S,INDEX] = sort_nat(name);


for i = 1:length(listing)
    i
    fname = S{i}
    
    % read and show image
    img = imread(fname,3);
    figure('Name','first choose background then cell-cell contact');
    imagesc(img)
    
    % allow a user to select ROI
    h1 = roipoly; % select the background
    h2 = roipoly; % select the signal
    
    % create mask for the ROI
    level = (mean(img(h1))+mean(img(h2)))/2;
    level = level/(2^16-1);
    mask = im2bw(img,level);

    % convert the image to NaN mask matrix
    img_masked = img;
    img_masked(~mask) = NaN;
    
    % show the matrix image
    figure; imagesc(img_masked)
    pause(0.5);
    close all

% save the ROI mask to mat file
save([fname(1:end-4) 'ROI.mat'],'h1','h2','level');
end



end