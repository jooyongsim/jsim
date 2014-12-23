function pax_analysis(s)	
% Default case: the input file is a tiff stack file of each paxillin-staining image
% Command is ' pax_analysis' or run the function
% If the paxillin images are separated tiff files, command "pax_analysis('non_stack')'. 

% The input file is the tiff stack file of each paxillin-staining image
if nargin < 1

% Close all the windows open
    close all

% Read the image files in tiff in the working folder of Matlab
    listing = dir('*.tif')

% Convert the cell format of the image name to the array format
    stackfn = listing(1).name;
    
% Read the number of tiff stack of the paxillin image file
    info = imfinfo(stackfn);  
    num_images = numel(info);
    
% Define the output file: focal adhesion area and the number of focal adhesion
    FAarea = zeros(num_images,1);
    FAnum = zeros(num_images,1);

% Calculate the focal adhesion area and the focal adhesion number
    for k = 1:num_images

    % Read the each paxillin image in the tiff stack
    img = imread(stackfn,k);
    img = double(img);

    % Apply a real-space band pass filter and suppress pixel noise and long-wavelength image variations (e.g., the brightness gradient in the field of view) while retaining information of a characteristic size of the focal adhesion
    imgb = bpass(img,1,10);

    % Apply the threshold filter of image by the intensity at 40% of the maximum intensity
    Ith = imgb>max(max(imgb))*0.4;

    % Apply a filter to find perimeter of objects in binary image
    BWoutline = bwperim(Ith);
    Segout = imgb;
    Segout(BWoutline) = max(max(imgb))*1.2;

    % Show the outline of the focal adhesion 
    figure, imagesc(Segout)

    % Find the local maxima in an image to pixel level accuracy
    pk = pkfnd(imgb,max(max(imgb))*0.4,10);
    hold on
    plot(pk(:,1), pk(:,2),'rO')

    % Put the focal adhesion area and the focal adhesion number to the data output array
    FAarea(k) = sum(sum(Ith));
    FAnum(k) = size(pk,1);
    end
    FAarea
    FAnum
    
% If the paxillin images are separated tiff files, command "pax_analysis('non_stack')'. 
else
    % Close all the windows open
    close all

    % Read the image files in tiff in the working folder of Matlab
    listing = dir('*.tif')
    
    % Convert the cell format of the image name to the array format
    name={listing.name};

    % Sort the file name in the natural numbering order
    [S,INDEX] = sort_nat(name);

    % Define the output file: focal adhesion area and the number of focal adhesion
    num_images = length(S);    
    num_cellint = length(s)
    FAarea = zeros(num_images,1);
    FAnum = zeros(num_images,1);
    FAareaCi = zeros(num_cellint,1);
    FAnumCi = zeros(num_cellint,1);
    figure(1)
    % Calculate the focal adhesion area and the focal adhesion number
    for ii =  1:length(s)
    ii
    i = s(ii);
    stackfn = S{i};

        % Read the number of tiff stack of the paxillin image file
        info = imfinfo(stackfn);
        num_stack = numel(info);

        % When each image file is stack file, select the best focus plane image
        if num_stack > 1
            sharpness = zeros(num_stack,1);

            % Evaluate the sharpness of each image
            for k = 1:num_stack
                img =  im2double(imread(stackfn,k));
                sharpness(k)=fmeasure(img,'SFIL',[]);
            end
            %         figure, plot(sharpness)

            % Find the peak of the sharpness
            if length(sharpness)>1
            [pks,locs] = findpeaks(sharpness); % or use 'minpeakdistance',3
            [M,JJ] = max(pks);
            II = locs(JJ);
            else
                II = 1;
            end
            if isempty(II)
            %             II = input('the number of focused frame? ')
                  if k>1
                      II = k-3;
                  else
                      II = 3;
                  end
            end

        % Select the best focus image
            img =  imread(stackfn,II);
        else
            img = imread(stackfn);
        end

    % Convert the image file to double format 
    img = double(img);
    hold off
    imagesc(img)

    % Apply a real-space band pass filter to suppress pixel noise
    imgb = bpass(img,1,40);

    % Apply the pre-defined ROI
    roifn = [stackfn(1:end-4) 'roi.mat'];
    if exist(roifn, 'file')
        load(roifn);
    else
        bws_out = roipoly; % select the outside
        bws_in = roipoly; % select the outside
    end
 
    % Apply filters to find the focal adhesion
   if sum(sum(bws_out))
        imgb = imgb.*bws_out.*~bws_in;

        % Show the outline of the focal adhesion 
        figure(1) imagesc(imgb)

        % Apply the intensity filter 
        Ith = imgb>max(max(imgb))*0.4;

        % Apply a filter to find perimeter of objects in binary image
        BWoutline = bwperim(Ith);
        Segout = imgb;

        % Find the local maxima in an image to pixel level accuracy
        Segout(BWoutline) = max(max(imgb))*1.2;
        pk = pkfnd(imgb,max(max(imgb))*0.4,10);
        hold on
        plot(pk(:,1), pk(:,2),'rO')

        % Put the focal adhesion area and the focal adhesion number to the data output array
        FAareaCi(ii) = sum(sum(Ith));
        FAnumCi(ii) = size(pk,1);
        if exist(roifn, 'file')
        else
        save(roifn,'bws_out','bws_in')            
        end
    end
    end
    FAareaCi
    FAnumCi
 
end
end

