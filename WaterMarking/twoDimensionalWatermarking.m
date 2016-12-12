clc;
clear;
close all;

hostImage=rgb2gray(imread('Publication3.png'));
watermarkImage=rgb2gray(imread('WaterMark.png'));

levels=4;
[CHost,Sh]=wavedec2(hostImage,levels,'haar');
[CWater,Sw]=wavedec2(watermarkImage,levels,'haar');

q=0.01;
p=(1-q);
waterMarkedC=zeros(1,length(CHost));
directions=2;

for i=1:levels
    
    for j=0:directions
        [cHstart,cHend]=getLevelCoeffIndices(Sh,i,levels,j);
        [cWstart,cWend]=getLevelCoeffIndices(Sw,i,levels,j);
        waterMarkedC(1,cHstart:cHend)=CHost(cHstart:cHend).*p+CWater(cWstart:cWend).*q;

    end
    
end

[cHstart,cHend]=getLevelCoeffIndices(Sh,levels,levels,-1);
[cWstart,cWend]=getLevelCoeffIndices(Sw,levels,levels,-1);
waterMarkedC(1,cHstart:cHend)=CHost(cHstart:cHend).*(1-q*q)+CWater(cWstart:cWend).*(q*q);

waterMarkedImage=waverec2(waterMarkedC,Sh,'haar');










figure(1)
imshow(uint8(waterMarkedImage));
figure(2)
imshow(hostImage);


