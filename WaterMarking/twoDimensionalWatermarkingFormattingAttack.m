clc;
clear;
close all;

hostImage=rgb2gray(imread('Publication3.png'));
watermarkImage=rgb2gray(imread('WaterMark.png'));

levels=4;
%Wavelet Decomposition
[CHost,Sh]=wavedec2(hostImage,levels,'haar');
[CWater,Sw]=wavedec2(watermarkImage,levels,'haar');

q=0.1;%Weight of watermark coefficients
q1=0.01;
p1=(1-q1);
p=(1-q);%Weight of Host image
waterMarkedC=zeros(1,length(CHost));
directions=2;%0 horizontal, 1 vertical, 2 diagonal

for i=1:levels
    %for each level
    for j=0:directions
        %Find the indices corresponding to the coefficients of each
        %direction
        [cHstart,cHend]=getLevelCoeffIndices(Sh,i,levels,j);
        [cWstart,cWend]=getLevelCoeffIndices(Sw,i,levels,j);
        %weight the host and watermark coefficients with the parameters
        waterMarkedC(1,cHstart:cHend)=CHost(cHstart:cHend).*p+CWater(cWstart:cWend).*q;

    end
    
end
%Retrieve the aproximation coefficient indices
[cHstart,cHend]=getLevelCoeffIndices(Sh,levels,levels,-1);
[cWstart,cWend]=getLevelCoeffIndices(Sw,levels,levels,-1);
%weight the host and watermark approximation coefficients with the parameters
waterMarkedC(1,cHstart:cHend)=CHost(cHstart:cHend).*p1+CWater(cWstart:cWend).*q1;

%Recompose the watermarked Image
waterMarkedImageClean=waverec2(waterMarkedC,Sh,'haar');
scalingFactor=max(max(waterMarkedImageClean))/255;
%Filter waterMarkedImage
standardDeviations=1;
imwrite(uint8(waterMarkedImageClean),'WaterMarkedFormat.jpg');

waterMarkedImage=imread('WaterMarkedFormat.jpg');
%waterMarkedImage=waterMarkedImageClean;
[waterMarkedC Sh]=wavedec2(waterMarkedImage,levels,'haar');
%recovering the Watermark
recWaterMarCoefficients=zeros(1,length(CHost));

for i=1:levels
    %for each level
    for j=0:directions
        %Find the indices corresponding to the coefficients of each
        %direction
        [cHstart,cHend]=getLevelCoeffIndices(Sh,i,levels,j);%redundant just in case we have
        [cWstart,cWend]=getLevelCoeffIndices(Sw,i,levels,j);% different sizes... 
        %Watermark=(Watermarked-hostImage*weightHost)/weightWatermark
        recWaterMarCoefficients(1,cHstart:cHend)=(waterMarkedC(cWstart:cWend)-CHost(cHstart:cHend).*p)./q;

    end
    
end

%Retrieve the aproximation coefficient indices
[cHstart,cHend]=getLevelCoeffIndices(Sh,levels,levels,-1);%redundant just in case we have
[cWstart,cWend]=getLevelCoeffIndices(Sw,levels,levels,-1);% different sizes... 
%Watermark=(Watermarked-hostImage*weightHost)/weightWatermark
recWaterMarCoefficients(1,cHstart:cHend)=(waterMarkedC(cWstart:cWend)-CHost(cHstart:cHend).*p1)./q1;

%Recompose the watermarked Image
recoveredWatermark=waverec2(recWaterMarCoefficients,Sh,'haar');

figure(1)
subplot(2,3,1);
imshow(hostImage);
title('Host image');
subplot(2,3,2);
imshow(watermarkImage);
title('WaterMark image');
subplot(2,3,3);
imshow(uint8(waterMarkedImageClean));
title('Watermarked image');
subplot(2,3,4);
imshow(uint8(waterMarkedImage));
title('DifferrentFormat Watermarked image');
subplot(2,3,5);
imshow(uint8(recoveredWatermark));
title('Recovered Watermark ');



