clear all;
clc;

image = imread('coins4.jpg');

figure()
subplot(1,2,1)
imshow(image)

[height, width, d] = size(image);
if d == 3       %in case im is RGB
    image = rgb2gray(image);
end

canniedImage = edge(image,'canny');


subplot(1,2,2)
imshow(canniedImage)

% compromise btw steps and radius range
steps = 30;
theta = 0:2*pi/steps:2*pi-2*pi/steps;

minR = 25;
maxR = 37;
dr = (maxR-minR)/steps;
R = minR:dr:maxR-dr;

margin = ceil(max(R));
votingSpace = zeros(height+2*margin, width+2*margin, steps, 'uint32');

for x = 1:height
    for y = 1:width
        if(canniedImage(x,y))
            for r = 1:steps
                for t = 1:steps
                    x0 = x - R(r)*cos(theta(t));
                    y0 = y - R(r)*sin(theta(t));
                    votingSpace(round(x0+margin),round(y0+margin),r) = votingSpace(round(x0+margin),round(y0+margin),r)+1;
                end
            end
        end
    end
end

% N=10;

 % find the maxima
threshold = 0.85*max(votingSpace(:));

nhoodxy = 10;
nhoodr = 13;
i = 1;
temp = votingSpace;
while true
   [maxPeak, indMax] = max(temp(:)); 
   if maxPeak < threshold
       break;
   end
   peakind(i) = indMax;
   [ix, iy, ir] = ind2sub(size(votingSpace), indMax);
   nhoodrStart = nhoodr;
   nhoodrEnd = nhoodr;
   if ir <= nhoodr
       nhoodrStart = ir - 1;
   end
   if ir > steps - nhoodr
       nhoodrEnd = steps - ir;
   end
   for tr = -nhoodrStart:nhoodrEnd
       for tx = -nhoodxy:nhoodxy
           for ty = -nhoodxy:nhoodxy
               temp(ix+tx, iy+ty, ir+tr) = 0;
           end
       end
   end
   i = i+1;
end
    
    % get strongest peaks
[iy, ix, ir] = ind2sub(size(votingSpace), peakind);
peaks = [ix; iy; R(ir)];
        
centers=[peaks(1,:)-margin; peaks(2,:)-margin]';
radii=peaks(3,:);

% [centers,radii] = imfindcircles(canniedImage,[20,60]);
subplot(1,2,1)
viscircles(centers, radii,'EdgeColor','b');
figure
surf(votingSpace(:,:,25));