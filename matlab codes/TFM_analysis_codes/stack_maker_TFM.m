function stack_maker_TFM(s) 
% the code generates a stack of tiff files from individual files 

    % load the file list in the working folder
    listing = dir('*.tif')

    % make a subfolder
    mkdir('stack')

    % convert the file format to matrix
    name={listing.name};
    
    % sort file name in a natural numbering order 
    [S,INDEX] = sort_nat(name);
    for ii = 1:length(S)
        if ii <10
            truncfn = 5;
        elseif ii <100
            truncfn = 6;
        else
            truncfn = 7;
        end
        ii
        
        % find the best focus plane
        file = S{ii}
        info = imfinfo(file);
        num_images = numel(info);
        sharpness = zeros(num_images,1);
        for k = 1:num_images
            img =  im2double(imread(file,k));
            sharpness(k)=fmeasure(img,'SFIL',[]);
        end
        [M,II] = max(sharpness);
        II
        selectedImg =  imread(file,II);
        stackfn = listing(1).name;
        stackfn = stackfn(1:end-5);
        
        % write image stack
        imwrite(selectedImg,['stack\' stackfn 'stack.tif'],'WriteMode','append','Compression','none');
    end
