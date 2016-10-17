classdef imageOperations
    properties
        height
        width
        image
    end
    methods (Access=private)
        function r=sampleDown(obj, ratio)
            
            step = 1/ratio;
            
            X=ceil([1:step:obj.height]);
            Y=ceil([1:step:obj.width]);
            
            r = obj.image(X,Y);
         end         
            
        function r=sampleUp(obj, ratio)
            step = 1/ratio;
            
            newHeight=ceil(obj.height*ratio);
            newWidth=ceil(obj.width*ratio);

            r =uint8(zeros(newHeight, newWidth));
            
            pImg=zeros(obj.height+2, obj.width+2);
            pImg(2:end-1,2:end-1)=obj.image;
            
       
            function r = interpolatePoint(i,j)
                % defining indexes of initial matrix values,
                % shifting by 1 as it is padded
                initX=floor(i*step)+1; initY=floor(j*step)+1;
                % defining the distance between X and X1 / Y and Y1
                diffX=initX-i*step; diffY=initY-j*step;
                
                y0= pImg(initX,initY)*diffX + pImg(initX+1,initY)*(1-diffX);
                y1= pImg(initX,initY+1)*diffX + pImg(initX+1,initY+1)*(1-diffX);
         
                r= uint8(y0*diffY + y1*(1-diffY));
            end
            
            for i = 1: newHeight
                for j=1:newWidth
                    r(i,j)=interpolatePoint(i,j);
                end
            end
        end
    end
    methods
        %Constructor
        function obj=imageOperations(img)
            [obj.height, obj.width, d] = size(img);
            if d == 3
                obj.image = rgb2gray(img);
            else
                obj.image = img;
            end
        end
% resample without anti-aliasing filter
        function r = resample(obj, ratio)
            if (ratio>1) r = sampleUp(obj,ratio); end
            if (ratio<=1) r = sampleDown(obj,ratio); end
        end
% rotate 90 degrees clockwise
        function r = rotate90cw(obj)
            for i = 1:obj.width
                for j = 1:obj.height
                    outputImage(i,j) = obj.image(obj.height-j+1,i);
                end
            end 
            r = outputImage;
        end
% rotate 90 degrees counter clockwise        
        function r = rotate90ccw(obj)
            for i = 1:obj.width
                for j = 1:obj.height
                    outputImage(i,j) = obj.image(j, obj.width-i+1);
                end
            end 
            r = outputImage;
        end
% rotate 180 degrees      
        function r = rotate180(obj)
            outputImage = obj.image(obj.height:-1:1,obj.width:-1:1);
            r = outputImage;
        end
% mirror left-right       
        function r = mirrorlr(obj)
            outputImage = obj.image(:,obj.width:-1:1);
            r = outputImage;
        end
% mirror up-down
        function r = mirrorud(obj)
            outputImage = obj.image(obj.height:-1:1,:);
            r = outputImage;
        end
% cropping 
        function r = crop(obj, height, width)
            outputImage = ones(obj.height,obj.width);        %white image that will not affect the original
            outputImage(height,width) = 0;                   %area to be masked out
            outputImage = outputImage.*im2double(obj.image); %multiplying the original with the mask image
            r = outputImage;
        end
% keep the selected area and mask out the rest
        function r = maskout(obj, height, width)
            outputImage = zeros(obj.height,obj.width);
            outputImage(height,width) = 1;
            outputImage = outputImage.*im2double(obj.image);
            r = outputImage;
        end
% shift right
        function r = shiftRight(obj, width)
            if width > obj.width
                warning('Width of shift exceeds image width');
            end
            shifted = obj.image(:, 1 : obj.width - width);
            outputImage = zeros(obj.height, obj.width);
            outputImage(:, width+1:obj.width) = im2double(shifted);
            r = outputImage;
        end
% shift down        
        function r = shiftDown(obj, height)
            if height > obj.height
                warning('Height of shift exceeds image height');
            end
            shifted = obj.image(1 : obj.height-height, :);
            outputImage = zeros(obj.height, obj.width);
            outputImage(height+1:obj.height, :) = im2double(shifted);
            r = outputImage;
        end
% shift right and down       
        function r = shiftRightDown(obj, height, width)
            if height > obj.height
                warning('Height of shift exceeds image height');
            end
            if width > obj.width
                warning('Width of shift exceeds image width');
            end
            shifted_w = obj.image(:, 1 : obj.width - width);
            shifted = shifted_w(1 : obj.height-height, :);
            outputImage = zeros(obj.height, obj.width);
            outputImage(height+1:obj.height, width+1:obj.width) = im2double(shifted);
            r = outputImage;
        end
    end
end

