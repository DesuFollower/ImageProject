close all;
clear;
clc;

image=rgb2gray(imread('lines.jpg'));
canniedImage=edge(image,'canny');

figure(1)
subplot(2,1,1);
imshow(image);
subplot(2,1,2);
%figure(2)
imshow(canniedImage);

steps=200;
dFi=2*pi/steps;
Fi=zeros(steps);
Fi=0:dFi:2*pi-dFi;

[height,width]=size(image);
maxR=sqrt(width*width+height*height);
dr=maxR/steps;
R=0:dr:maxR-dr;

threshold=1;
votingSpace=zeros(steps,steps);

for xi=1:height
   for yi=1:width
        if(canniedImage(xi,yi))
            for iR=1:steps
                for iFi=1:steps
                    if(abs(R(iR)-(xi*cos(Fi(iFi))+yi*sin(Fi(iFi))))<=threshold)
                        votingSpace(iR,iFi)=votingSpace(iR,iFi)+1;
                    end
                end
            end
        end 
   end
end

preMaximus =imgaussfilt(votingSpace,0.01);
Maximus=imregionalmax(preMaximus);
numberOfLines =sum(sum(Maximus));
radiFy=zeros(numberOfLines,2);
index=1;
for iR=1:steps
    for iFi=1:steps
        if (Maximus(iR,iFi))
           radiFy(index,:)=[iR iFi];
           index=index+1;
        end
    end
end   

lines=zeros(height,width);
for xi=1:height
   for yi=1:width
            %if(canniedImage(xi,yi))
            for iPoint=1:numberOfLines
                    if(abs(R(radiFy(iPoint,1))-(xi*cos(Fi(radiFy(iPoint,2)))+yi*sin(Fi(radiFy(iPoint,2)))))<threshold)
                        lines(xi,yi)=255;
                    end
           end     
           %end
   end
end

figure(2)
%subplot(2,1,1);
imshow(uint8(votingSpace));
%subplot(2,1,2);
figure(4)
imshow(uint8(lines));
figure(5)
imshow(Maximus);
figure(7)
surf(preMaximus);
