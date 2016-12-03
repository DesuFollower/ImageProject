function newImage = houghGeneralized(im, template)
% im - image to be operated on
% template - template to be detected in im
% newImage - output image

[height,width,d] = size(template);
if d == 3
    template = rgb2gray(template);
end
canniedImage = edge(template, 'canny');
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

dPhi=pi/2;
Phi=0:dPhi:2*pi-dPhi;
rotations=zeros(2,2,length(Phi));
for i=1:length(Phi)
   rotations(:,:,i)=[cos(Phi(i)) -sin(Phi(i)); sin(Phi(i)) cos(Phi(i))]; 
end

RotatedByPi=zeros([size(Rtable) length(Phi)]);
for angle=1:length(Phi)
    for i=1:size(Rtable,1)
        RotatedByPi(i,:,angle)=rotations(:,:,angle)*Rtable(i,:)';
    end
end

[height, width, d]  = size (im);
if d == 3
    im = rgb2gray(im);
end
cannyTest = edge( im, 'canny');
votingSpace = zeros(3*height, 3*width, length(Phi));
pixelcount = size(Rtable, 1);

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

gaussianFilter = fspecial('gaussian', [13,13], 3); 

Gm = abs(gradient(votingSpace));
preMaximus = imfilter(Gm, gaussianFilter);

[height, width] = size(votingSpace(:,:,1));

for angle = 1:length(Phi)
   votingThreshold = 0.9*max(max(preMaximus(:, :, angle))); 
    for xi=1:height
        for yi=1:width
            if (preMaximus(xi, yi, angle) < votingThreshold)
               preMaximus(xi, yi, angle) = 0;
            end
        end
    end 
end
%reducing filtered coordinates to dots on a voting plane
Maximus=imregionalmax(preMaximus);

newImage = zeros(height, width, length(Phi));

numberOfShapes = sum(sum(sum(Maximus)));
centersDetected = zeros(numberOfShapes, 2, length(Phi));
index = 1;
for xi = 1:height
    for yi = 1:width
        for angle = 1:length(Phi)
            if (Maximus(xi, yi, angle))
               centersDetected(index, :, angle) = [xi yi];
               index = index + 1;
            end
        end
    end
end   
   
for i = 1: numberOfShapes
    for angle = 1:length(Phi)
        for j = 1 : pixelcount
            if(centersDetected(i, 1, angle) ~= 0 && centersDetected(i, 2, angle) ~= 0)
                xi = centersDetected(i, 1 ,angle) - RotatedByPi(j, 1, angle);
                yi = centersDetected(i, 2, angle) - RotatedByPi(j, 2, angle);
                newImage(xi, yi, angle) = 255;
            end
        end
    end
end
[height, width]  = size (im);

newImage = sum(newImage, 3);
newImage = uint8(newImage(height:2*height,width:2*width));