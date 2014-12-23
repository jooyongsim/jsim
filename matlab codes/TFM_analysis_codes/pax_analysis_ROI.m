% This code allows a user to define the ROI of paxillin stain images 
% to avoid noise from the area outside of cells.

% Default case: the input file is a tiff stack file of each paxillin-staining image
% Command is ' pax_analysis_ROI' or run the function
% If the paxillin images are separated tiff files, command "pax_analysis_ROI('non_stack')'. 

% The input file is the tiff stack file of each paxillin-staining image
function pax_analysis_ROI(s)
if nargin <1
% Read the paxillin stain image - tiff file format
    close all
    listing = dir('*.tif')
    stackfn = listing(1).name;
    
% Get the number of images
    info = imfinfo(stackfn);  
    num_images = numel(info);

% Define the ROI output of cell area, 'bwdila' is dilated ROI object of 
%'bwsa', the cell area ROI with 'strel- 50' dilation filter 
    bwdila = cell(num_images,1);
    bwsa = cell(num_images,1);

% Loop for paxillin stain images
    for k = 1:num_images
        k

% Read the image files
    img = imread(stackfn,k);
    img = double(img);

% Apply a real-space band pass filter to remove noise
    imgb = bpass(img,1,10);

% Find the intensity threshold level and apply the intensity-based morphological filter
    level = (max(max(img))-min(min(img)))*0.22+min(min(img));
    imgbw = img>level;
    bwfill = imfill(imgbw, 'holes');

% Clear the object touching the image border
    bwnobord = imclearborder(bwfill, 4);
    cc = bwconncomp(bwnobord);

% Apply eroding filter to remove the noise of cell boundaries
    seD = strel('diamond',1);
    bwnobord = imerode(bwnobord,seD);

% Find the maximum area of objects to find a cell object
    stats  = regionprops(cc, 'area');
    allArea = [stats.Area];
    idx = find(allArea == max(allArea));
    max(allArea)

% Select the recognized cell image
    sc  = regionprops(cc, 'centroid');
    centroids = cat(1, sc.Centroid);
    if isempty(centroids)||max(allArea)<20000
        figure;imagesc(img)
        bws = roipoly;
        close
    else
        bws = bwselect(bwnobord,centroids(idx,1),centroids(idx,2),4);
    end

% Show the selected ROI
    figure, imshow(bws)
    pause(0.5)
    close

% Dilate the cell object to recover the area eroded previously
    se90 = strel('diamond', 140);
    bwdil = imdilate(bws, [se90]);
    bwdila{k} = bwdil;
    bwsa{k} = bws;
    end

% Save the ROI to mat file
    save([stackfn(1:end-4) 'ROI.mat'],'bwdila')
% If the paxillin images are separated tiff files, command "pax_analysis_ROI('non_stack')'. 
elseif strcmpi(s,'one page tiffs')
% Read the paxillin stain image - tiff file format
    close all
    listing = dir('*.tif')
    stackfn = listing(1).name;
    
% Get the number of images
    info = imfinfo(stackfn);  
    num_images = numel(info);
    
% Define the ROI output of cell area, 'bwdila' is dilated ROI object of
% 'bwsa', the cell area ROI with 'strel- 50' dilation filter 
    bwdila = cell(num_images,1);
    bwsa = cell(num_images,1);

% Loop for paxillin stain images
    for k = 1:num_images
        k

% Read the image files
    img = imread(stackfn,k);
    img = double(img);

% Apply a real-space band pass filter to remove noise
    imgb = bpass(img,1,10);

% Find the intensity threshold level and apply the intensity-based morphological filter
    level = (max(max(img))-min(min(img)))*0.22+min(min(img));
    imgbw = img>level;
    bwfill = imfill(imgbw, 'holes');

% Clear the object touching the image border
    bwnobord = imclearborder(bwfill, 4);
    cc = bwconncomp(bwnobord);

% Apply eroding filter to remove the noise of cell boundaries
    seD = strel('diamond',1);
    bwnobord = imerode(bwnobord,seD);
    bwnobord = imerode(bwnobord,seD);
    
% Find the maximum area of objects to find a cell object
    stats  = regionprops(cc, 'area');
    allArea = [stats.Area];
    idx = find(allArea == max(allArea));
    max(allArea)

% Select the recognized cell image
    sc  = regionprops(cc, 'centroid');
    centroids = cat(1, sc.Centroid);
    if isempty(centroids)||max(allArea)<20000
        figure;imagesc(img)
        bws = roipoly;
        close
    else
        bws = bwselect(bwnobord,centroids(idx,1),centroids(idx,2),4);
    end

% Show the selected ROI
    figure, imshow(bws)
    pause(0.5)
    close
    
% Dilate the cell object to recover the area eroded previously
    se90 = strel('diamond', 140);
    bwdil = imdilate(bws, [se90]);
    bwdila{k} = bwdil;
    bwsa{k} = bws;
    end
% Save the ROI to mat file
    save([stackfn(1:end-4) 'ROI.mat'],'bwdila')
end
