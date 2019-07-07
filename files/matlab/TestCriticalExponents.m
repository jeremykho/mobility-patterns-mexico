%% Set expected constants (see D. Stauffer, Introduction to Percolation Theory)
p_c = 0.5927;
tau = 187/91;
sigma = 36/91;

%% Set size parameters
nsamples = 3;
matrixsize = 2000;

%% Create arrays to fill
p = linspace(0.3,p_c,100);
values = zeros(100,100);
blobsize = 1:100; % Bins for region size histogram
biggestblobs = zeros(100,nsamples);

%% Calculate size statistics for various values of p and various random matrix seeds

for jj = 1:nsamples % loop over random matrices
    randmat = rand(matrixsize,matrixsize,'single');
    disp(jj)
    for ii = 1:100 % loop over values for p
        [blobnumber,blobsize,blobIsize,nsize,biggestblob,labeled] = CountBlobs( randmat < p(ii));
        values(:,ii) = values(:,ii) + nsize/nsamples;
        biggestblobs(ii,jj) = nnz(biggestblob);
    end
end
%% Display results

scrsz = get(groot,'ScreenSize');
figure('Position',[100 100 scrsz(3)/1.25 scrsz(4)/1.5])

subplot(1,2,1)
plot(blobsize,(values(:,end)),'bo')
hold on
limiting_size_dist = blobsize.^(-tau);
sizescalefactor = values(50,end)/limiting_size_dist(50);
plot(blobsize,limiting_size_dist*sizescalefactor,'k:');
set(gca,'YScale','log')
xlabel('Connected Region Size s (pixels)')
ylabel('Number of regions, n_s')

subplot(1,2,2)
mean_biggest = mean(biggestblobs,2);
plot(abs(p-p_c),mean_biggest,'ro')
hold on
yvals = abs(p-p_c).^(-(1/sigma));
scalefactor = mean_biggest(80)/yvals(80);
plot(abs(p-p_c),yvals*scalefactor,'k:')
set(gca,'YScale','log')
xlabel('|p-p_c|')
ylabel('s_{max}')
set(gcf, 'Color', 'w')