classdef imageOperations
    properties
        height
        width
        image
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
% rotate 90 degrees clockwise
        function r = rotate90cw(obj)
            for i = 1:obj.width
                for j = 1:obj.height
                    image1(i,j) = obj.image(obj.height-j+1,i);
                end
            end 
            r = image1;
        end
% rotate 90 degrees counter clockwise        
        function r = rotate90ccw(obj)
            for i = 1:obj.width
                for j = 1:obj.height
                    image1(i,j) = obj.image(j, obj.width-i+1);
                end
            end 
            r = image1;
        end
% rotate 180 degrees      
        function r = rotate180(obj)
            image1 = obj.image(obj.height:-1:1,obj.width:-1:1);
            r = image1;
        end
% mirror left-right       
        function r = mirrorlr(obj)
            image1 = obj.image(:,obj.width:-1:1);
            r = image1;
        end
% mirror up-down
        function r = mirrorud(obj)
            image1 = obj.image(obj.height:-1:1,:);
            r = image1;
        end
% cropping 
        function r = crop(obj, newHeight, newWidth)     % newHeight and newWidth are vectors
            image1 = obj.image(newHeight, newWidth);    %(1:100, 300:512 );    %rows 1:100, cols 300:512
            r = image1;
        end
% mask out selected area of the image
        function r = maskout(obj, height, width)
            image1 = ones(obj.height,obj.width);        %white image that will not affect the original
            image1(height,width) = 0;                   %area to be masked out
            image1 = image1.*im2double(obj.image);      %multiplying the original with the mask image
            r = image1;
        end
% keep the selected area and mask out the rest
        function r = maskoutside(obj, height, width)
            image1 = zeros(obj.height,obj.width);
            image1(height,width) = 1;
            image1 = image1.*im2double(obj.image);
            r = image1;
        end
    end
end


% assignin('base','i',i);