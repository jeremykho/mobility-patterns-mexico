
function [blobnumber,blobsize,blobIsize,nsize,biggestblob,labeled] = CountBlobs(Pmat)

%Matlab function bwlabel(BW,4) returns the label matrix L that contains labels 
%for the 4-connected objects found in BW. 
%The label matrix, L, is the same size as BW.
%This function
labeled = bwlabel(Pmat,4);
blobnumber = 1:max(labeled(:));%Maximun label
blobIsize = histc(labeled(:),blobnumber);%how many times each label appears
[~,maxind] = max(blobIsize);
biggestblob = zeros(size(labeled));
biggestblob(labeled == maxind) = 1;
blobsize = 1:100;
nsize = histc(blobIsize,blobsize); %check help matlab histc
end

