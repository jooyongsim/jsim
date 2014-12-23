function stack_maker(s)
% stack_maker('stage')
%% % if the file is clustered by stage
% for example FRET_s1.TIF > CFP_s1.TIF > YFP_s1.TIF 
if strcmp(s,'stage')
     listing = dir('*.tif')
    listing.name
    mkdir('stack')
    step = 2; % if there is only three channel 
    % step = 3; % if there is also the DIC so total 4 channel
    for ii = 1:step+1:length(listing)-step
        ii
        file = listing(ii).name
        fileTFP = listing(ii+fnum).name
        fileYFP = listing(ii+fnum*2).name
        % FRETimg =  imread(file);
        % TFPimg =  imread(listing(ii+1).name);
        % YFPimg =  imread(listing(ii+2).name);
        
        info = imfinfo(fileYFP);
        num_images = numel(info);
        sharpness = zeros(num_images,1);
        for k = 1:num_images
            img =  im2double(imread(fileYFP,k));
            sharpness(k)=estimate_sharpness(img);
        end

        [M,II] = max(sharpness);
        
        FRETimg =  imread(file,II);
        TFPimg =  imread(fileTFP,II);
        YFPimg =  imread(fileYFP,II);

        imwrite(FRETimg,['stack\' file(1:end-9) 'stack.tif'],'WriteMode','append','Compression','none');
        imwrite(TFPimg,['stack\' file(1:end-9) 'stack.tif'],'WriteMode','append','Compression','none');
        imwrite(YFPimg,['stack\' file(1:end-9) 'stack.tif'],'WriteMode','append','Compression','none');

    end
else
%% % if the file is clustered by channel
% for example FRET_s1.TIF > FRET_s2.TIF > FRET_s3.TIF .... CFP > YFP
%     if ~rem(length(listing),3) 
        %
        listing = dir('*.tif')
        listing.name
        mkdir('stack')
        name={listing.name};
        [S,INDEX] = sort_nat(name);

        fnum = length(S)/3; 
        for ii = 1:fnum
            ii
            file = S{ii}
            fileTFP = S{ii+fnum}
            fileYFP = S{ii+fnum*2}
            % FRETimg =  imread(file);
            % TFPimg =  imread(listing(ii+1).name);
            % YFPimg =  imread(listing(ii+2).name);

            info = imfinfo(fileYFP);
            num_images = numel(info);
            sharpness = zeros(num_images,1);
            for k = 1:num_images
                img =  im2double(imread(fileYFP,k));
                sharpness(k)=estimate_sharpness(img);
            end

            [M,II] = max(sharpness);
            II
            FRETimg =  imread(file,II);
            TFPimg =  imread(fileTFP,II);
            YFPimg =  imread(fileYFP,II);

    %         imwrite(FRETimg,['stack\' file(1:end-6) 'stack.tif'],'WriteMode','append','Compression','none');
    %         imwrite(TFPimg,['stack\' file(1:end-6) 'stack.tif'],'WriteMode','append','Compression','none');
    %         imwrite(YFPimg,['stack\' file(1:end-6) 'stack.tif'],'WriteMode','append','Compression','none');
            imwrite(FRETimg,['stack\' file(1:end-4) 'stack.tif'],'WriteMode','append','Compression','none');
            imwrite(TFPimg,['stack\' file(1:end-4) 'stack.tif'],'WriteMode','append','Compression','none');
            imwrite(YFPimg,['stack\' file(1:end-4) 'stack.tif'],'WriteMode','append','Compression','none');
         end
    %
%     end
end
end