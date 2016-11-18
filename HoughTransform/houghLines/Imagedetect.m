close all;
clear;
clc;

image = sampleImage(200,200);
image = image.whiteSquare(20);
canniedImage = edge(image, 'canny');
figure (1)
imshow(canniedImage);
[height,width]=size(image);
%votingSpace=zeros(rSteps,FiSteps);
xc = 0;
yc = 0;
% xc and yc are reference points for the center
Rtable = [];


for xi=1:height
   for yi=1:width
        if(canniedImage(xi,yi))
            % going through all possible lines in the image
            % adding vote to each line point itself belongs to
            Rtable = [Rtable ; [xc-xi yc-yi]];
            
            
        end 
   end
end


%testImage = [zeros(height, width); image];
testImage = image;
cannyTest = edge( testImage, 'canny');
[height, width]  = size (testImage);
votingSpace = zeros(3*height, 3*width);
[pixelcount,bla] = size(Rtable);


for xi=1:height
   for yi=1:width
        if(cannyTest(xi,yi))
            for centre = 1:pixelcount
                xv = Rtable(centre,1)+xi+height;
                yv = Rtable(centre,2)+yi+width;
                votingSpace(xv,yv) = votingSpace(xv,yv)+1;
            
            end
        end 
   end
end

figure (2)
imshow(votingSpace);
gaussianFilter = fspecial('gaussian', [13,13], 3); 

Gm = abs(gradient(votingSpace));
preMaximus = imfilter(Gm, gaussianFilter);

votingThreshold=0.8*max(max(preMaximus));
[height, width] = size(votingSpace);

for xi=1:height
    for yi=1:width
        if (preMaximus(xi,yi)< votingThreshold)
           preMaximus(xi,yi)=0;
        end
    end
end 

%reducing filtered coordinates to dots on a voting plane
Maximus=imregionalmax(preMaximus);

newImage = zeros(height, width);

numberOfShapes = sum(sum (Maximus));
centersDetected = zeros(numberOfShapes,2);
index = 1;
for xi=1:height
    for yi=1:width
        if (Maximus(xi,yi))
           centersDetected(index,:)=[xi yi];
           index=index+1;
        end
    end
end   

for i = 1: numberOfShapes
    for j = 1 : pixelcount
                xi = centersDetected(i,1)- Rtable(j,1);
                yi = centersDetected(i,2)- Rtable(j,2);
                newImage(xi,yi) = 255; 
    end
end



figure (3)
imshow(newImage);

figure(4)
imshow(preMaximus);
