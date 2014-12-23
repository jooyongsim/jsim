fn_cy5 = '140514_CY5_stack_all.tif';
fn_yfp = '140514_YFP-stack.tif';

img1_cy5 = imread(fn_cy5,1);
img1_yfp = imread(fn_yfp,1);
info = imfinfo(fn_cy5);
num_images = numel(info);

img1_cy5 = imadjust(img1_cy5);
img1_yfp = imadjust(img1_yfp);

fn_reg_cy5 = [fn_cy5(1:end-4) '_registered.tif'];
fn_reg_yfp = [fn_yfp(1:end-4) '_registered.tif'];

imwrite(img1_cy5,fn_reg_cy5, 'WriteMode','overwrite')
imwrite(img1_yfp,fn_reg_yfp, 'WriteMode','overwrite')

for i = 2:5%num_images-1
i
    imgi_cy5 = imread(fn_cy5,i);
    imgi_cy5 = imadjust(imgi_cy5);

    imgi_yfp = imread(fn_yfp,i);
    imgi_yfp = imadjust(imgi_yfp);

%     figure;
%     imshowpair(img1_cy5,imgi_cy5);
%     pause(0.2);
    [optimizer,metric] = imregconfig('monomodal');
    % [optimizer,metric] = imregconfig('multimodal');
    tic
    optimizer.MaximumIterations = 1000;
    % optimizer.MinimumStepLength = 0.0001;
    optimizer.MinimumStepLength = 1e-6;%1e-7;
    optimizer.MaximumStepLength = 0.065;
    % optimizer.MaximumStepLength = 0.5;
    optimizer.GradientMagnitudeTolerance = 1e-7;%1e-7;
    optimizer.RelaxationFactor = 0.5;%0.7;
    % optimizer = registration.optimizer.OnePlusOneEvolutionary;
    % metric = registration.metric.MeanSquares
    % optimizer.MaximumIterations = 1000;

    %  [imgiR,R_reg]= imregister(imgi, img1, 'translation', optimizer, metric);
    tform = imregtform(imgi_cy5, img1_cy5, 'translation', optimizer, metric);
    imgiR_cy5 = imwarp(imgi_cy5,tform,'OutputView',imref2d(size(img1_cy5)));

    imgiR_yfp = imwarp(imgi_yfp,tform,'OutputView',imref2d(size(img1_cy5)));
%     imshowpair(img1_yfp,imgiR_yfp)
    timeDefault = toc
    imwrite(imgiR_yfp, fn_reg_yfp, 'WriteMode', 'append');
    imwrite(imgiR_cy5, fn_reg_cy5, 'WriteMode', 'append');
end
