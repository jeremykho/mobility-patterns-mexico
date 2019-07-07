%%
% Load dataset
load('poi_grid.csv')
%%
% Visualize
figure
plot(poi_grid(:,1),poi_grid(:,2),'k.')
hold on

% Choose Minimum Threshold
city_total_poi = sum(poi_grid(:,3));
% idx=find(poi_grid(:,3)/city_total_poi>0.00006);
idx=find(poi_grid(:,3) > 40);
filtered_by_poi = poi_grid(idx,:);
% figure
plot(filtered_by_poi(:,1),filtered_by_poi(:,2),'r.')
title('Filtered by POIs')
%
%%Transform Coordinates in pixels
LON=filtered_by_poi(:,1);
LAT=filtered_by_poi(:,2);
DAT=filtered_by_poi(:,3);
% dl=0.00833333; %(minimun resolution between two points)
dl=0.006;
R = makerefmat(min(LON),min(LAT),dl,dl) %%matlabfunction
[pixlatrow, pixloncol ] = latlon2pix(R,LAT,LON); %%
figure
plot(pixloncol,pixlatrow,'.')
%
range=128;%decide matrix size based on resulting pixels

% Create Matrix
map_bin=zeros(range,range);
for i=1:size(pixlatrow)
    I=int32(pixlatrow(i));
    J=int32(pixloncol(i));
    if(I<=range && J<=range)
      map_bin(I,J)=1;
    end
end

% Fractal Dimension
[c]=resize_matrix(map_bin);
figure
spy(c)
figure
boxcount_alg
%
% Largest Cluster
[blobnumber,blobsize,blobIsize,nsize,biggestblob,labeled]=CountBlobs(map_bin);
plotim = (map_bin)+ 2*biggestblob + 2; %three colors 2 (empty), 3 (occupied) and 5 (biggest cluster)
figure
stepfourplot = image(plotim);
colormap('flag')
title('Largest Cluster')
xlabel('Pixels')
ylabel('Pixels')
hh = colorbar();
set(hh,'YLim',[0.5,3.5])
set(hh,'YTick',[1,2,3])
set(hh,'YTickLabel',{'Largest','Empty','Occupied'})
%
% Label Clusters
custom_colormap = jet(256);
custom_colormap(1,:) = 0.8; %set zero values to grey to better see colors
figure
imagesc(labeled)
colorbar
colormap(custom_colormap)
title('Labeled Clusters')
xlabel('Pixels')
ylabel('Pixels')

% Display the size distribution
figure()
hplot2 = plot(blobsize,(nsize/sum(nsize)),'ro');
hold on
tau = 187/91; %theoretical value
limiting_size_dist = blobsize.^(-tau); 
%Add a line as a guide to the eye to compare the 
%the scaling around p_c according to percolation theory
hplot3 = plot(blobsize,limiting_size_dist/sum(limiting_size_dist));
ylim([1e-4,1])
xlim([1,100])
xlabel('Cluster Size, n_{s}')
ylabel('Fraction of Blobs - P(n_{s})')
title('Distribution of Cluster Sizes');
set(gca,'YScale','log')
set(gca,'XScale','log')
%
% Largest Cluster
[rows,cols,cluster_biggest] = find(biggestblob);
[lat,lon] = pix2latlon(R,rows,cols);

to_csv = [lat lon];
csvwrite('biggestblob.csv',to_csv);

% Save labeled Clusters to CSV
[rows,cols,cluster_labeled] = find(labeled);
[lat,lon] = pix2latlon(R,rows,cols);

to_csv = [lat lon cluster_labeled];
csvwrite('labeled.csv',to_csv);

%%
% Location with Largest Density
[dmax,dind] = max(poi_grid(:,3));  % return value and index of most dense coordinate
coords_max=poi_grid(dind,:);       % retrieve long and lat value
fprintf('Lat,Long : %.6f,%.6f\nDensity: %.6f\n', coords_max(2), coords_max(1), coords_max(3));
%%
% Find all coords within distance, show population and distance %%%%%%%%%%%%%%%%%
% calc distances
city_cell=num2cell(poi_grid,2); % convert to cells, easier to iterate on (but memory consuming)
dists = cellfun(@(r) pos2dist(r(2),r(1),coords_max(2),coords_max(1),2),city_cell); % calc dists

city_w_dists=[poi_grid dists];
% and keep only those with population density of 500 or more
idx2=find(city_w_dists(:,3)>10);
filtered_by_pop_2=city_w_dists(idx2,:);

binranges = 0:5:60;
[B,~,idx3] = histcounts(filtered_by_pop_2(:,4),binranges);
bin_means = zeros(length(binranges)-1,2);
for n = 1:length(binranges)-1
    bin_means(n,1) = ( binranges(n) + binranges(n+1) )/ 2;
    bin_means(n,2) = mean(filtered_by_pop_2(idx3==n,3));
end
f = fit(bin_means(:,1),bin_means(:,2)/coords_max(3),'exp1');

% plot densities
figure

semilogy(filtered_by_pop_2(:,4),filtered_by_pop_2(:,3)/coords_max(3),'+','MarkerEdge',[0.8, 0.8, 0.8]);
hold on
semilogy(bin_means(:,1),bin_means(:,2)/coords_max(3),'o','MarkerFaceColor','r');
plot(f)
xlabel('Distance, r (km)')
ylabel('Density of POIs Relative to Max Density')
legend('Data','Binned Data','a*exp(-lambda*r)')
title('POI Densities at Distances (r) from the Center')
hold off
