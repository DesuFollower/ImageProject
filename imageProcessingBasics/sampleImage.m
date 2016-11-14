%This class issues sample images based on the patterns discussed in week
% 39
% Usage example:
%   a=sampleImage(100,100);
%   imshow(a.diagonalStripes(10,10));
%   imshow(diagonalStripes(a));
classdef sampleImage
    properties
        height
        width
        image % matrix of height x width, representing the image
    end
    methods
        %Constructor
        % Default image size 100x100
        function obj=sampleImage(height,width)
            if height <= 0 || width < 0 
            obj.height=100;
            obj.width=100;
            obj.image=ones(obj.height,obj.width);    
            else 
            obj.height=height;
            obj.width=width;
            obj.image=ones(obj.height,obj.width);
            end
        end
        
        %Horizontal Strips
        function r=horizontalStripes(obj,yFrequency)
            for row=1:obj.height
                obj.image(row,:)=127*sin(yFrequency*2*pi*row/obj.height)+127;
            end
            r=obj.image;
        end
        
        %Vertical Strips
        function r=verticalStripes(obj,xFrequency)
            for column=1:obj.width
                obj.image(:, column)=127*sin(xFrequency*2*pi*column/obj.width)+127;
            end
            r=obj.image;
        end
        
        %Diagonal Stripes
        function r=diagonalStripes(obj,fx,fy)
            for row=1:obj.height
                for column=1:obj.width
                    obj.image(row,column)=127*(sin(2*pi*((fx*row/obj.height+fy*column/obj.width))/2)+1);
                end
            end
            r=obj.image;
        end
        
        %Chessboard Pattern
        function r=chessboard(obj,fx,fy)
            for row=1:obj.height
                for column=1:obj.width
                    obj.image(row,column)=64*(square(fx*2*pi*(row-1)/obj.height)+1+square(fy*2*pi*(column-1)/obj.width)+1);
                    %marking the chess fields and then fixing them to use
                    %only two colors (white and black)
                    if obj.image(row,column)<200 & obj.image(row,column)>50
                        obj.image(row,column)=255;
                    else obj.image(row,column)=0;
                    end
                end
            end
            r=obj.image;
        end
        
        %Gaussian
        function r=gaussianPattern(obj,maxSigma)
            
            dx=2*maxSigma/obj.width;
            dy=2*maxSigma/obj.height;
            
            x=-maxSigma:dx:(maxSigma-dx);
            y=-maxSigma:dy:(maxSigma-dy);
            [X,Y] = meshgrid(x,y);
            %generating probability density of the multivariate normal distribution
            obj.image = mvnpdf([X(:) Y(:)]);
            % reshaping and andjusting format of an image pixel
            obj.image = uint8(256.*reshape(obj.image,length(x),length(y)));
            r=obj.image;
        end
        
        %White square on a black background
        %squareSide is the percentage of the square side related to the
        %width of the image
        
        function r=whiteSquare(obj, squareSide)
            
            halfSquare = squareSide/2; % half the side of the square, percentage of the total width
            ymiddle = obj.height/2;  % middle point of height
            xmiddle = obj.width/2; % middle point of width
            
            %marking all the points outside of the borders black
            for row=1:obj.height
                for column=1:obj.width
                    if ((row > (ymiddle - halfSquare) && row < (ymiddle + halfSquare)) && (column> xmiddle- halfSquare && column< xmiddle + halfSquare))
                        obj.image(row,column)=255;
                    else
                        obj.image(row,column)=0;
                    end
                end
            end
            r=obj.image;
        end
        
        
        % function to calculate fft for the image after one of the
        % desisigns is applied; used in the gui
        function r = simpleFFT(obj)
            image_fft=fftshift(fft2(obj.image));
            image_fft = log(abs(image_fft) + 1); % log of the magnitude for
            image_fft = mat2gray(image_fft);    %Scale the values between 0 and 1
            r = image_fft;
            
        end
        
        
    end
end