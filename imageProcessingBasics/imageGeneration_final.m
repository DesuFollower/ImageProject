%script to manually generate all the required images at once
clc;
clear;
width=100;
height=100;
frequency=10;
%Vertical Stripes
image=ones(height,width);
for column=1:width
image(:,column)=127*sin(frequency*2*pi*column/width)+127;
end
figure(1)
imshow(uint8(image));
imwrite(uint8(image),'vertical_stripes.jpg');

%Horizontal Stripes
image=ones(height,width);
for row=1:height
image(row,:)=127*sin(frequency*2*pi*row/height)+127;
end
figure(2)
imshow(uint8(image));
imwrite(uint8(image),'horizontal_stripes.jpg');


%Chessboard stripes positive slope
frequency=5;
image=ones(height,width);
for row=1:height
    for column=1:width
    image(row,column)=64*(sin(frequency*2*pi*row/height)+1+sin(frequency*2*pi*column/width)+1);
    end
end
figure(3)
imshow(uint8(image));
imwrite(uint8(image),'chessboard.jpg');

%Diagonal stripes positive slope
fx=10;
fy=-5;
image=ones(height,width);
for row=1:height
    for column=1:width
        image(row,column)=127*(sin(2*pi*((fx*row/height+fy*column/width))/2)+1);
    end
end
figure(4)
imshow(uint8(image));
imwrite(uint8(image),'diagonal_stripes.jpg');


%Chess 
image=ones(height,width);
shift=1;
for row=1:height
    if(mod(row,frequency)==1)
            shift = shift*-1;
    end
    for column=1:width           
        image(row,column)=127*shift*square(frequency*2*pi*(column-1)/width)+127;
    end
end    
figure(5)
imshow(uint8(image));
imwrite(uint8(image),'chess.jpg');

%Gaussian
maxSigma=3;
dx=2*maxSigma/width;
dy=2*maxSigma/height;

x=-maxSigma:dx:(maxSigma-dx);
y=-maxSigma:dy:(maxSigma-dy);
[X,Y] = meshgrid(x,y);
doubleImage=mvnpdf([X(:) Y(:)]);
image = mvnpdf([X(:) Y(:)]);
image = uint8(256.*reshape(image,length(x),length(y)));
figure(6)
imshow(image);
imwrite(image,'gaussian.jpg');

