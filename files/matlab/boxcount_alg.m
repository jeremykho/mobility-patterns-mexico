%=========================================================================
%
% The program will calculate the fractal dimension of a 512x512 image
% using the box counting method.
%
% The code is just for beginners for getting an idea of box-counting
% method.
%
%=========================================================================
% initialises the varaibles for plotting the graph. scale is used to store
% the scaling factors and the count is used to store the number of boxes
% which contains parts of the image. For a given scale(1,i) value, the number
% of boxes occupied by the image will be available at count(1,i)

p=round(log2(size(c,1)));
scale=zeros(1,p);
count=zeros(1,p);

[width,height]=size(c);

for i=1:p
   % scaling factors are taken as 2,4,8,16... 2^p. 
   
   % For each scaling factor, the total number of 
   %pieces are to be calculated,
   % and the number of pieces which contain the black 
   %dots (pixels) among them are to
   % be counted.
    
   % For eg, when the scaling factor is 2, it means 
   %the image is divided into half, hence we will 
   %get 4 pieces. And have to see how many of pieces 
   %have the black dots. 
   sf=2^i;
   pieces=sf^2;
   pieceWidth=width/sf;
   pieceHeight=height/sf;
   
   %initially we assume, we have 0 black pieces
   blackPieces=0;
   % Now we have to iterate through each pieces to see
   %how many pieces have the black dots (pixel) in it. 
   %We will consider the collection of pieces as
   % a matrix. We are counting from 0 for the ease 
   %of calculations.
   
   for pieceIndex=0:pieces-1
       % row and column indices of each pieces are 
       %calculated to estimate the xy cordinates of 
       %the starting and ending of each piece.
       pieceRow=idivide(int32(pieceIndex), int32(sf));
       pieceCol=rem(pieceIndex,sf);
       xmin=(pieceCol*pieceWidth)+1;
       xmax=(xmin+pieceWidth)-1;
       ymin=(pieceRow*pieceHeight)+1;
       ymax=(ymin+pieceHeight)-1;
       
       % each piece is extracted and stored in another
       %array for convenience.
       eachPiece=c(ymin:ymax,xmin:xmax);
% now, we will check whether the piece has some black dots in it.
% then the count of the black pieces will be incremented.
           if(size(eachPiece(find(eachPiece)),1)>0)
              blackPieces=blackPieces+1;
           end
   end
   %The last piece obtained is plotted on a plot for getting a view 
   %of the splitting of the whole image.
   if(mod(p,2)==0)
      subplot(2,p/2,i), imshow(eachPiece);
   else
      subplot(2,(p+1)/2,i), imshow(eachPiece); 
   end
   
   % the count of pieces which contains the black dots for a given scaling value 
   % will be obtained here and 
   %will be stored in the respective variables.
   fprintf('%d\t->\t%d\n', sf, blackPieces);
   scale(1,i)=sf;
   count(1,i)=blackPieces;
end

% Now the process is over, the graph is plotted and 
%the fractal dimension is calculated using 
%the 'ployfit' function.
figure
Inz=find(count>0);
plot(log(scale(Inz)),log(count(Inz)),'ko');
xlabel('log(b) magnifying factor b'); ylabel('log(N(b)), number of boxes N');
title(['2D box-count']);
S=scale(Inz);%%eliminates zeros
C=count(Inz);

%%% Let us the fit function
%%% We select different regions to avoid size effects
[m,b]=polyfit(log(S(2:7)),log(C(2:7)),1);
hold on
plot(log(S),m(1)*log(S)+m(2),'r--')
legend(strcat('df= ', num2str(m(1))),'Location','northwest')
