% read the list of files for the lifetime data from SPCImage output files
listing_t1 = dir('*t1.asc');
listing_a1 = dir('*a1[%].asc');
listing_t2 = dir('*t2.asc');
listing_a2 = dir('*a2[%].asc');
listing_chi = dir('*chi.asc');
listing_photons = dir('*photons.asc');
listing_tm= dir('*color coded value.asc');

% Natural order sorting of the file list to sort strings containing digits in a way such that the numerical value of the digits is taken into account. 
   [fn_t1S,INDEX] = sort_nat({listing_t1.name});
   [fn_a1S,INDEX] = sort_nat({listing_a1.name});
   [fn_t2S,INDEX] = sort_nat({listing_t2.name});
   [fn_a2S,INDEX] = sort_nat({listing_a2.name});
   [fn_chiS,INDEX] = sort_nat({listing_chi.name});
   [fn_photonsS,INDEX] = sort_nat({listing_photons.name});
   [fn_tmS,INDEX] = sort_nat({listing_tm.name});
% Because we don't have leading zeros to get the right sort order, but with this function, the files are sorted out with input of example {'file1.txt','file2.txt','file10.txt'}

% Calculate the weighted average lifetime from the lifetime from each pixel
mean_tm = zeros(1,length(listing_t1));
tm_mask_v_total = [];
for i = 1:length(listing_t1)
    i
    fn_t1 = fn_t1S{i}
    fn_a1 = fn_a1S{i}
    fn_t2 = fn_t2S{i}
    fn_a2 = fn_a2S{i}
    fn_chi = fn_chiS{i}
    fn_photons = fn_photonsS{i}
    fn_tm = fn_tmS{i}
 
%Import the data from each file name
t1 = importdata(fn_t1);
t2 = importdata(fn_t2);
a1 = importdata(fn_a1);
a2 = importdata(fn_a2);
chi = importdata(fn_chi);
photons = importdata(fn_photons);

% tm can be also represented by tm = (t1.*a1+t2.*a2)/100;
tm = importdata(fn_tm);
figure;imagesc(photons)
fname = listing_t1(i).name;

%Filter out the lifetime data by the Chi-squared value
mask = chi;
mask(chi>3) = 0;
mask(chi<3) = 1;
tm_mask =tm.*mask;
 
%Filter out the lifetime data by the intensity of donor
level = mean2(photons)*3
maski = photons;
maski(photons>level) = 1;
maski(photons<=level) = 0;

% Apply mask and convert the matrix to vector for following vector operation
tm_mask =tm_mask.*maski;
tm_mask(tm_mask<1) = NaN;
tm_mask_v = img2vector(tm_mask);
 figure;imagesc(tm_mask,[1200 2800]);

% Calculate the median of the weighted average lifetime
mean_tm(i) = median(tm_mask_v); 
tm_mask_v_total=[tm_mask_v_total;tm_mask_v];
[m,n] = size(photons);
 photons_v = reshape(photons,m*n,1);
    tm(tm<1) = NaN;
    tm_v = reshape(tm,m*n,1);
    
    topEdge = max(photons_v); % define limits
    botEdge = 0; % define limits
    numBins = 200; % define the number of bins
 
% Plot histogram of photons vs. lifetime plot
    binEdges = linspace(botEdge, topEdge, numBins+1); 
    [h,whichBin] = histc(photons, binEdges); 
    for jj = 1:numBins
        flagBinMembers = (whichBin == jj);
        binMembers     = tm_v(flagBinMembers);
        binMean(jj)    = nanmean(binMembers);
    end
    binCenter = binEdges(1:end-1)+binEdges(2)/2;
    figure;plot(photons_v,tm_v,'.');
    hold on;plot(binCenter,binMean,'rO');
    axis([0 300 0 4000])
end

%Display the mean of the weighted average lifetime
mean_tm'
mean(mean_tm)
