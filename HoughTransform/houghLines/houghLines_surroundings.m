close all;
clear;
clc;

image=rgb2gray(imread('testlines.png'));
%pre-processing image with edge detection algorithm
canniedImage=edge(image,'canny');
[height,width]=size(image);

%preparing voting matrix (angle)x(distance) (Fi)x(R)
FiSteps=270;
dFi=1.5*pi/FiSteps;
Fi=-pi/2:dFi:pi;

rSteps=200;
maxR=sqrt(width*width+height*height);
dR=maxR/rSteps;
R=0:dR:maxR-dR;

votingSpace=zeros(rSteps,FiSteps);

cosFi=cos(Fi);
sinFi=sin(Fi);
% Here lies the main difference between this method and usual hough lines
% detection algorithm
% Instead of checking all possible angles for one point, we use directions
% Each direction covers the range of angles
% z.B. if we have distance=1 , we have eight possible directions for point,
% for distance=2, we have 16 possible directions (here displayed with *)
% however, to prevent double-scanning of the same line we go only through
% half of the cycle (here p-point that we are currentyl checking, d -
% doubles of directions)
% distance =1 d**       example: 010            distance =2 dd***
%             dp*                010                        d###*
%             dd*                000                        d#p#*
%                                                           d###*
%                                                           ddd**
% thus, if p(point)=1 , we start checking all direction points for being=1
% as well, if they are - we translate the angle (range of angles) 
% into phi ( angle of normal line to line that we have detected) and calculate r
% in our example we have a vertical direction detected, which covers angles
% 68 to 112 (90+-22). or -22 to 22 if we translate it to normal form.
% now we calculate r for each of those values and put them into table

distance=3;
%getDirectionMap creates an array with directions referece points
directionMap =getDirectionMap(distance);
directionMapLength= distance*4;
angleSteps= FiSteps/3*2;
sectorLength = fix(angleSteps/directionMapLength);
% mapping range of angles to each direction
angleMap = int16(zeros (directionMapLength,sectorLength));
for i = 0:angleSteps-1;
    sector = fix(i/sectorLength)+1;
    angle = rem(i,sectorLength)+1;
    angleMap(sector,angle)=i+1;
end

tic
%filling voting matrix
for xi=distance+1:1:height-distance
   for yi=distance+1:1:width-distance
        if(canniedImage(xi,yi))
               currentSin=yi/(sqrt(xi^2+yi^2));
            %Determining sin of current angle
            % Here we split directions into two parts
            % So it's easier for us to determine resulting normal angle.
            for direction=1:directionMapLength/2
                C=directionMap(direction,:);
                if (canniedImage(xi+C(1), yi+C(2)))
                    for angleIndex=1:sectorLength
                        cAngle = angleMap(direction, angleIndex);
                        cFi=cAngle+90;
                        currentR= int16(floor(xi*cosFi(cFi)+yi*sinFi(cFi))/dR+1);
                        votingSpace(currentR,cFi)=votingSpace(currentR,cFi)+1;
                    end
                end
            end
            for direction=(directionMapLength/2+1):1:directionMapLength
                C=directionMap(direction,:);
                if (canniedImage(xi+C(1), yi+C(2)))
                    for angleIndex=1:sectorLength
                        cAngle = angleMap(direction, angleIndex);
                        if (sinFi(cAngle)>currentSin)
                          cFi=cAngle-90;
                        else
                          cFi=cAngle+90;
                        end
                        
                        currentR= int16(floor(xi*cosFi(cFi)+yi*sinFi(cFi))/dR+1);
                        votingSpace(currentR,cFi)=votingSpace(currentR,cFi)+1;
                    end
                end
            end

        end
   end
end
toc
tic
% filtering voting matix two achieve following goals:
% 1) Throw away all lines with low amount of votes (achieved by appliyng
% threshold)
% 2) combine close parallel lines into one (achieved by gaussian filtering)
Gm=abs(gradient(votingSpace));
%here we could also use imgaussfilt function instead of creating filter
%separately
% imgaussfilt was added in version 2015, thus we use old variant for better
% compatibility
gaussianFilter = fspecial('gaussian', [13,13], 3); 
preMaximus =imfilter(Gm,gaussianFilter);


%applying threshold to voting matrix, throwing away values that are less
%than 30% of maximum
votingThreshold=0.6*max(max(preMaximus));
for iR=1:rSteps
    for iFi=1:FiSteps
        if (preMaximus(iR,iFi)< votingThreshold)
           preMaximus(iR,iFi)=0;
        end
    end
end 

%reducing filtered coordinates to dots on a voting plane
Maximus=imregionalmax(preMaximus);
%counting dots ( i.e lines detected)
numberOfLines =sum(sum(Maximus));
linesDetected=zeros(numberOfLines,2);
index=1;
%creating array with detected lines' stats
for iR=1:rSteps
    for iFi=1:FiSteps
        if (Maximus(iR,iFi))
           linesDetected(index,:)=[iR iFi];
           index=index+1;
        end
    end
end   

% maximal deviation of point from the expected line
threshold=1;

%drawing an image to show that lines detected match the original image
imageWithLines=zeros(height,width);
for xi=1:height
   for yi=1:width
            for iPoint=1:numberOfLines
                    if(abs(R(linesDetected(iPoint,1))-(xi*cosFi(linesDetected(iPoint,2))+yi*sinFi(linesDetected(iPoint,2))))<threshold)
                        imageWithLines(xi,yi)=255;
                    end
           end     
   end
end

% Showing original image and edge-detected version
figure(1)
subplot(2,1,1);
imshow(image);
title('Original image');
subplot(2,1,2);
imshow(canniedImage);
title('Detected edges');
% Showing result against original image
figure(2)
subplot(2,1,1);
imshow(image);
title('Original image');
subplot(2,1,2);
imshow(uint8(imageWithLines));
title('Detected lines');
% Showing resulting voting space
figure(3)
surf(votingSpace);
title('Voting space');
% Showing voting space with highlighted maximums

figure(4)
surf(preMaximus);
title('Filtered voting space');
% Voting space in 2 dimensions and detected maximums
figure(5)
subplot(2,1,1);
imshow(uint8(votingSpace));
title('Voting space');
subplot(2,1,2);
imshow(Maximus);
title('Detected lines coordinates');
toc
