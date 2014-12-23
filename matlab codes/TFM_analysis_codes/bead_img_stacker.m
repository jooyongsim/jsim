% This code generates stack of images before and after the trypsin treated 
% images of fluorescence beads. The images should be stored under 
% '\before_tryp folder' and '\after_tryp' folder.

function bead_img_stacker(s)
% Read the list of images before trypsin
    listing = dir('before_tryp\*.tif')
    name={listing.name};
    [S,INDEX] = sort_nat(name);
    Sb = S;
    
% Read the list of images after trypsin
    listing = dir('after_tryp\*.tif')
    name={listing.name};
    [S,INDEX] = sort_nat(name);
    listing.name;
    Sa = S;
 
% Create an output folder
    mkdir('bead_stack')
    
    for ii = 1:length(listing)
        ii

        % Read images after trypsin
        stackfn= ['after_tryp\' Sa{ii}]
        info = imfinfo(stackfn);  
        num_images = numel(info);

        % Find the best focus of the image stack
            sharpness = zeros(num_images,1);
        for k = 1:num_images
            img =  im2double(imread(stackfn,k));
            sharpness(k)=estimate_sharpness(img);
        end
        [M,II] = max(sharpness);
        imga =  imread(stackfn,II);
 
        % Read images before trypsin
        stackfn= ['before_tryp\' Sb{ii}]
        info = imfinfo(stackfn);  
        num_images = numel(info);
    
        % Find the best focus of the image stack
        sharpness = zeros(num_images,1);
        for k = 1:num_images
            img =  im2double(imread(stackfn,k));
            sharpness(k)=estimate_sharpness(img);
        end
        [M,II] = max(sharpness);
        imgb =  imread(stackfn,II);
            
        fnonly = Sb{ii};

% Write images in stack
imwrite(imga,['bead_stack\' fnonly(1:end-4) '_stack.tif'],'WriteMode','append','Compression','none');
pause(0.1)
imwrite(imgb,['bead_stack\' fnonly(1:end-4) '_stack.tif'],'WriteMode','append','Compression','none');
      
end

