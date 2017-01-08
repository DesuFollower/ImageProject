% Input parameters:
%   im - image to be inspected (grayscaled or RGB)
%   rrange - radius range (e.g. [min, max])
%   threshold - between 0 and 1 (default is 0.85)
%   steps - too large => too slow, too small => inaccurate result (default is 30)
%   nhoodxy - min circle center sensitivity in pixels (between 1 and min(x,y) - default is 10)
%   nhoodr - min radius sensitivity in pixels (between 1 and steps - default is 10)
% Output variables:
%   centers - vector of potential circle centers
%   radii - vector of circle radiuses

function [centers, radii, numOfCircles] = houghCircles(im, rrange, threshold, steps, nhoodxy, nhoodr)

    [height, width, d] = size(im);
    if d == 3       %in case im is RGB
        im = rgb2gray(im);
    end
    canniedImage = edge(im,'canny');

    theta = 0:2*pi/steps:2*pi-2*pi/steps;
    minR = rrange(1);
    maxR = rrange(2);
    dr = (maxR-minR)/steps;
    R = minR:dr:maxR-dr;

    margin = ceil(max(R));
    votingSpace = zeros(height+2*margin, width+2*margin, steps, 'uint32');%the voting space is with twice the max radius bigger than the original image in height and width 

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

    peaks = getPeaks(votingSpace, R, steps, threshold, nhoodxy, nhoodr);
    centers = [peaks(1,:)-margin; peaks(2,:)-margin]';
    radii = peaks(3,:);
    numOfCircles = size(radii);
    numOfCircles = numOfCircles(2);
end
%----------------------------------------------------------------------------
function peaks = getPeaks(h, R, steps, threshold, nhoodxy, nhoodr)
     % find the maxima
    threshold = threshold*max(h(:));
    i = 1;
    temp = h;
    % supress the other maximas that fall into the mask range determined by nhoodxy and nhoodr
    while true
       [maxPeak, indMax] = max(temp(:)); 
       if maxPeak < threshold   %only values over the threshold are checked
           break;               %that makes the function extremely fast for high thresholds
       end
       peakind(i) = indMax;
       [ix, iy, ir] = ind2sub(size(h), indMax);
       nhoodrStart = nhoodr;
       nhoodrEnd = nhoodr;
       if ir <= nhoodr              
           nhoodrStart = ir - 1;
       end
       if ir > steps - nhoodr   %radius sensitivity cannot be bigger than number of steps
           nhoodrEnd = steps - ir;
       end
       for tr = -nhoodrStart:nhoodrEnd  %for every radius 
           for tx = -nhoodxy:nhoodxy    %evey pixel at tx and ty that is in the mask range
               for ty = -nhoodxy:nhoodxy %is set to 0
                   temp(ix+tx, iy+ty, ir+tr) = 0;
               end
           end
       end
       i = i+1;
    end
     % get strongest peaks
    [iy, ix, ir] = ind2sub(size(h), peakind);
    peaks = [ix; iy; R(ir)];
end
   
        

