
% Last Update 2015 05 17
% under C:\Users\Sim\Box Sync\140428_Nelson_FRET\140428_ECTS_FRET_cell_line_from_2014_DMEM_low
% Find the associated files

% FRET_image_analysis.m
% C:\Users\Sim\Box Sync\140428_Nelson_FRET\140428_ECTS_FRET_cell_line_from_2014_DMEM_low

% stack_maker_2.m
% C:\Users\Sim\Box Sync\140405_FRET_dcytoFRET_one_one_collagen mattek_dish\ECTS

% img2vector.m
% C:\Users\Sim\Documents\MATLAB

% channel sequence:
% DIC-eye
% CFP (in widefield tab)
% YFP (in widefield tab)
% tFRET(mTFP) in FRET tab

% Previous version Folder- C:\Users\Sim\Documents\Cell Experiment Images\inverted_II\131123 micropatterning project\Pruitt_Leica_DMI6000B\140109_H45_FRET_lam20ugml_col-64710ugml_stack\140109_H35_FRET_lam20ugml_col-64710ugml

% 2014 01 09 FRET calculation code for cadherin TSMod analysis
% Folder- C:\Users\Sim\Google 드라이브\Pruitt_Leica_DMI6000B\140109_H45_FRET_lam20ugml_col-64710ugml_stack\140109_H35_dcytoFRET_lam20ugml_col-64710ugml
% previous version, (C:\Users\Sim\Google 드라이브\Pruitt_Leica_DMI6000B\131216_H45_FRET\result_batch\FRETCal_cadTS_2013_batch.m)
% this code does folllowings:
% 1 select image file of each channel
    % this part is the first major modification from the previous version
    % without getting image from the stack tif file,
    % here, select the file by the file name an order
    % because the images are saved as a order of the image acquisition
    % DIC>FRET>CFP>YFP>CY5, we can count by 5 images in a row
%  FRET>TFP>YFP (gelatin CY5 labeled pattern - which didn't work well)
% 3 Select (load) ROI for background 
% 4 make a mask from the ROI, a mask of intensity threshold of YFP
    % this part is modified from a fixed threshold number to the ratio bewteen
    % threshold to select the cell-cell contact and Ostu's method
% 5 background substraction and gaussian filter
% 6 calculate FRET/(TFP+FRET) with SBT
% 7 calculate FRET/TFP without spectral bleedthrough correction
% 8 save the file

mkdir('result')

% (1)
listing = dir('*.tif')
listing.name


name={listing.name};
[S,INDEX] = sort_nat(name);

FRETptVTotal = [];
FRETpsmYFPvecTotal = [];
FRETps_ALL_Cells = [];
YFPbsg1Total = [];
% ii = 1;
for ii =1:length(S)
file = S{ii}
ii
% (1)
FRETimg =  im2double(imread(file,1));
TFPimg =  im2double(imread(file,2));
YFPimg =  im2double(imread(file,3));

% (3)
load([file(1:end-4) 'ROI.mat']);
if ~isempty(h1)
    mask = h1;

    % (4)
    % calculate the threshold for meaningful FRET
    YFPimg16 =  imread(file,3);
    level = mean(YFPimg16(h2));
    level = level/(2^16-1)*1.2;
    % level = (mean(YFPimg16(h1))+mean(YFPimg16(h2)))/2;
    % level = level/(2^16-1);
    ROIm = im2bw(YFPimg16,level);

    % (5)
    t = TFPimg;
    tm = t.*mask;
    [m,n] = size(tm);
    v = double(reshape(tm,m*n,1));
    v(~v) = NaN;
    meanv =  nanmean(v);

    TFPbs = TFPimg - meanv;

    t = YFPimg;
    tm = t.*mask;
    [m,n] = size(tm);
    v = double(reshape(tm,m*n,1));
    v(~v) = NaN;
    meanv =  nanmean(v);

    YFPbs = YFPimg - meanv;

    t = FRETimg;

    tm = t.*mask;
    [m,n] = size(tm);
    v = reshape(tm,m*n,1);
    v(~v) = NaN;
    meanv =  nanmean(v);

    FRETbs = FRETimg - meanv;

    h = fspecial('gaussian', 2, 1);
    YFPbsg1 = imfilter(YFPbs,h,'replicate');
    TFPbsg1 = imfilter(TFPbs,h,'replicate');
    FRETbsg1 = imfilter(FRETbs,h,'replicate');

    %%
    % (6) FRET/(FRET+TFP) 
    % Nelson Zeiss, 
    % FRETsbt = FRETbsg1 - YFPbsg1*0.18 - TFPbsg1*0.48;
    % FRETsbt = FRETbsg1 - YFPbsg1*0.03 - TFPbsg1*0.39;
    % Viola Leica Confocal
    % FRETsbt = FRETbsg1 - YFPbsg1*0.23 - TFPbsg1*0.59;
    % Pruitt Leica DMI6000B
    % FRETsbt = FRETbsg1 - YFPbsg1*0.06 - TFPbsg1*0.43;
    % FRETsbt = FRETbsg1 - YFPbsg1*0.5 - TFPbsg1*0.3;
    % FRETsbt = FRETbsg1 - YFPbsg1*0.2 - TFPbsg1*0.5;
    FRETsbt = FRETbsg1 - YFPbsg1*0.064 - TFPbsg1*0.84775;
    % FRETsbt = FRETbsg1 - YFPbsg1*0.0 - TFPbsg1*0.6;

    % test = reshape(YFPbsg1,m*n,1);
    % figure;hist(test,2^10)

    FRETps = FRETsbt*100./(TFPbsg1+FRETsbt);
    % test = reshape(FRETps,m*n,1);
    % figure;hist(test,2^20)
    % figure;imshow(FRETps)
    FRETpsmYFP = FRETps;

    FRETpsV_test = FRETps;
    FRETpsV_test(~ROIm) = NaN;
    FRETpsV_test(~h2) = NaN;
    FRETpsV_test(FRETpsV_test>200) = NaN;
    FRETpsV_test(FRETpsV_test<-200) = NaN;
    FRETpsV_test = img2vector(FRETpsV_test);
    % hh = figure;hist(FRETpsV_test,2^10);pause(0.5);close(hh)

    FRETpsmYFP(FRETpsmYFP>99) = NaN;
    FRETpsmYFP(FRETpsmYFP<0) = NaN;
    FRETpsmYFP(~ROIm) = NaN;
    FRETpsmYFP(~h2) = NaN;
    % hh = figure;imagesc(FRETpsmYFP);pause(0.5);close(hh)

  
    YFPbsg1(~ROIm) = NaN;
    YFPbsg1(~h2) = NaN;
    YFPbsg1v = img2vector(YFPbsg1);
    

    FRETpsmYFPvec = img2vector(FRETpsmYFP);
    FRETpsV = FRETpsmYFPvec;
    % hh = figure;hist(FRETpsV,2^10);pause(0.5);close(hh)

%     if ~isempty(FRETpsmYFPvec)
%     cdfplot(FRETpsmYFPvec)
%     hold on
%     end

    % (7) FRET/TFP without SBT
    FRET_TFP = FRETbsg1*100./TFPbsg1;
    FRETmYFP = FRET_TFP;
    FRETmYFP(~ROIm) = NaN;
    FRETmYFPvec = img2vector(FRETmYFP);
    FRETptV = FRETmYFPvec;
    % [nanmean(FRETpsmYFPvec) nanstd(FRETpsmYFPvec);nanmean(FRETmYFPvec) nanstd(FRETmYFPvec);level*2^16 0]

    imwrite(FRETmYFP,['result\FRET_F_T ' file],'tiff')
    imwrite(FRETpsmYFP,['result\FRET_ps ' file],'tiff')
    save(['result\FRETptV '  file(1:end-4) '.mat'],'FRETptV')
    save(['result\FRETpsV '  file(1:end-4) '.mat'],'FRETpsV')

    FRETps_ALL_Cells = [FRETps_ALL_Cells;FRETpsmYFPvec];

    bit = 16;
    

    
    if ii == 1
        FRETpsTotal{ii}= FRETpsV
        fileTotal{ii} = file;
        thresholdTotal{ii} = level*2^bit;
        FRETpsmYFPvecTotal(ii) = nanmean(FRETpsmYFPvec);
        FRETptVTotal(ii) = nanmean(FRETptV);
        YFPbsg1Total(ii) = nanmean(YFPbsg1v);
        save('result\FRETdata_total.mat','FRETpsTotal','fileTotal','thresholdTotal','FRETpsmYFPvecTotal','FRETptVTotal','YFPbsg1Total')
    else
        load('result\FRETdata_total.mat');
        FRETpsTotal{ii} = FRETpsV;
        fileTotal{ii} = file;
        thresholdTotal{ii} = level*2^16;
        FRETpsmYFPvecTotal(ii) = nanmean(FRETpsmYFPvec);
            FRETptVTotal(ii) = nanmean(FRETptV);
                YFPbsg1Total(ii) = nanmean(YFPbsg1v);
        save('result\FRETdata_total.mat','FRETpsTotal','fileTotal','thresholdTotal','FRETpsmYFPvecTotal','FRETptVTotal','YFPbsg1Total')
    end
end
end
FRETpsmYFPvecTotal'
nanmean(FRETpsmYFPvecTotal)
hold on
cdfplot(FRETps_ALL_Cells);
YFPbsg1Total'
% FRETptVTotal'
% mean(FRETptVTotal)


%% 

% related file log
% FRETCal_cadTS_2014_batch3.m
% Last Modified on ?2014?. ?4?. ?1?. 3:48:00
% Used to be stored C:\Users\Sim\Documents\Cell Experiment Images\inverted_II\131123 micropatterning project\140331_FRET_new_thaw_2011_vial

% FRETCal_cadTS_2014_batch4.m
% Last Modified on ?2014?년 ?4?월 ?4?일 ?금요일, ??오후 8:07:06
% Used to be stored C:\Users\Sim\Documents\Cell Experiment Images\inverted_II\131123 micropatterning project\140322_H45_FRET_timelapse_best_focus

% EcadTS_FRET_2014_05_17.m
% Last Modified on 2014?년 ?5?월 ?17?일 ?토요일, ??오후 5:47:28
% Used to be stored C:\Users\Sim\Box Sync\140426_Ecad_trunc\stacks

% FRET_historam.m
% Last Modified on ?2014?년 ?3?월 ?19?일 ?수요일, ??오후 2:34:38
% Used to be stored C:\Users\Sim\Documents\Cell Experiment Images\inverted_II\131123 micropatterning project\Pruitt_Leica_DMI6000B\140109_H45_FRET_lam20ugml_col-64710ugml_stack\140109_H35_FRET_lam20ugml_col-64710ugml


% stack_maker_2.m
% Last Modified on ?2014?년 ?5?월 ?17?일 ?토요일, ??오후 5:42:16
% Used to be stored C:\Users\Sim\Box Sync\140405_FRET_dcytoFRET_one_one_collagen mattek_dish\ECTS

% sensitivity_sbt.m
% Last Modified on ?2014?년 ?4?월 ?29?일 ?화요일, ??오후 12:32:40
% Used to be stored C:\Users\Sim\Box Sync\140409_FRET_and_truncated_each_mattek_dish\ECTS\stack
