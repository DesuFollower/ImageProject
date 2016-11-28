close all;
clear;
clc;

% Importing the template image and extracting the edges via Canny
image=rgb2gray(imread('HAW90.png'));
canniedImage = edge(image, 'canny');
figure (1)
imshow(canniedImage);


[height,width]=size(image);
xc = 0;
yc = 0;
% xc and yc are reference points for the center
Rtable = [];

% Filling up the Rtable with the template's edge pixels 
% relative to the reference point 
for xi=1:height
   for yi=1:width
        if(canniedImage(xi,yi))
            % going through all possible lines in the image
            % adding vote to each line point itself belongs to
            Rtable = [Rtable ; [xc-xi yc-yi]];
            
            
        end 
   end
end

%% Setting up Rotation matrix on every right angle
dPhi=pi/2;
Phi=0:dPhi:2*pi-dPhi;
rotations=zeros(2,2,length(Phi));
for i=1:length(Phi)
   rotations(:,:,i)=[cos(Phi(i)) -sin(Phi(i)); sin(Phi(i)) cos(Phi(i))]; 
end

% Creating other Rtables of the template Rotated 
RotatedByPi=zeros([size(Rtable) length(Phi)]);
for angle=1:length(Phi)
    for i=1:size(Rtable,1)
        RotatedByPi(i,:,angle)=rotations(:,:,angle)*Rtable(i,:)';
    end
end


%%

% Importing the Test Image from which we want to detect the template
% Test contains many instances of the template rotated at different angles
testImage=rgb2gray(imread('HAWRotations.png'));
cannyTest = edge( testImage, 'canny');
[height, width]  = size (testImage);
votingSpace = zeros(3*height, 3*width,length(Phi));
pixelcount = size(Rtable,1);


% Running the Hough Algorithm for voting accross all possible rotations
%Voting by matching each ege pixel to all possible reference points(centers)
for xi=1:height
   for yi=1:width
        if(cannyTest(xi,yi))
            for angle=1:length(Phi)
                for centre = 1:pixelcount
                    xv = RotatedByPi(centre,1,angle)+xi+height;
                    yv = RotatedByPi(centre,2,angle)+yi+width;
                    votingSpace(xv,yv,angle) = votingSpace(xv,yv,angle)+1;

                end
            end
        end 
   end
end

% Taking the absolute of the gradient of the resulting voting space
% So as to sharpen the local maximas and even them out with the global ones
gaussianFilter = fspecial('gaussian', [13,13], 3); 
Gm = abs(gradient(votingSpace));
% Then pass it through a Gaussian filter to Smoothen the peaks
% And form a usable result and also makes the significant peaks clear
preMaximus = imfilter(Gm, gaussianFilter);

% Threshold the Maximas to avoid any small insignificant peaks from being
% detected from the voting space
[height, width] = size(votingSpace(:,:,1));
for angle=1:length(Phi)
   votingThreshold=0.9*max(max(preMaximus(:,:,angle))); 
    for xi=1:height
        for yi=1:width
            if (preMaximus(xi,yi,angle)< votingThreshold)
               preMaximus(xi,yi,angle)=0;
            end
        end
    end 
end

%reducing filtered coordinates to dots on a voting plane
Maximus=imregionalmax(preMaximus);

% Plotting of the new Image from reconstructing the results
% Firstly collecting all Maximas in an array then plotting
% the corresponding Maximas Template according to its parameters
newImage = zeros(height, width,length(Phi));
numberOfShapes = sum(sum(sum(Maximus)));
centersDetected = zeros(numberOfShapes,2,length(Phi));
index = 1;
for xi=1:height
    for yi=1:width
        for angle=1:length(Phi)
            if (Maximus(xi,yi,angle))
               centersDetected(index,:,angle)=[xi yi];
               index=index+1;
            end
        end
    end
end   

    
for i = 1: numberOfShapes
    for angle=1:length(Phi)
        for j = 1 : pixelcount
            if(centersDetected(i,1,angle)~=0&&centersDetected(i,2,angle)~=0)
                xi = centersDetected(i,1,angle)- RotatedByPi(j,1,angle);
                yi = centersDetected(i,2,angle)- RotatedByPi(j,2,angle);
                newImage(xi,yi,angle) = 255;
            end
        end
    end
end
[height, width]  = size (testImage);

%plotting the  one of voting space
figure (2)
surf(votingSpace(:,:,4));

% Plotting the reconstructed image at the part that corresponds the test
% image..: The centre block .. since its 9*TestImage
figure (3)
newImage=sum(newImage,3);
imshow(uint8(newImage(height:2*height,width:2*width)));

%Plotting the one of the PreMaxima so as to get a glimpse of the voting space after
%the filtering is done
figure(4)
surf(preMaximus(:,:,4));
