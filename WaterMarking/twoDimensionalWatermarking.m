clc;
clear;
close all;

hostImage=rgb2gray(imread('Publication3.png'));
watermarkImage=rgb2gray(imread('WaterMark.png'));

levels=4;
%Wavelet Decomposition
[CHost,Sh]=wavedec2(hostImage,levels,'haar');
[CWater,Sw]=wavedec2(watermarkImage,levels,'haar');

q=0.01;%Weight of watermark coefficients
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
waterMarkedC(1,cHstart:cHend)=CHost(cHstart:cHend).*(1-q*q)+CWater(cWstart:cWend).*(q*q);

%Recompose the watermarked Image
waterMarkedImage=waverec2(waterMarkedC,Sh,'haar');

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
recWaterMarCoefficients(1,cHstart:cHend)=(waterMarkedC(cWstart:cWend)-CHost(cHstart:cHend).*(1-q*q))./(q*q);

%Recompose the watermarked Image
recoveredWatermark=waverec2(recWaterMarCoefficients,Sh,'haar');

figure(1)
subplot(2,2,1);
imshow(hostImage);
title('Host image');
subplot(2,2,2);
imshow(watermarkImage);
title('WaterMark image');
subplot(2,2,3);
imshow(uint8(waterMarkedImage));
title('Watermarked image');
subplot(2,2,4);
imshow(uint8(recoveredWatermark));
title('Recovered Watermark ');



