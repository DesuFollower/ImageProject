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
        function obj=sampleImage(height,width)
            obj.height=height;
            obj.width=width;
            obj.image=ones(obj.height,obj.width);
        end
        
        %Horizontal Strips
        function r=horizontalStripes(obj,yFrequency)
            for row=1:obj.height
                obj.image(row,:)=127*cos(yFrequency*2*pi*(row-1)/(obj.height-1))+127;
            end
            r=uint8(obj.image);
        end
        
        %Vertical Strips
        function r=verticalStripes(obj,xFrequency)
            for column=1:obj.width
                obj.image(column,:)=127*cos(xFrequency*2*pi*(column-1)/obj.width)+127;
            end
            r=uint8(obj.image);
        end
        
        %Diagonal Stripes
        function r=diagonalStripes(obj,fx,fy)
            for row=1:obj.height
                for column=1:obj.width
                    obj.image(row,column)=127*(cos(2*pi*((fx*row/obj.height+fy*column/obj.width))/2)+1);
                end
            end
            r=uint8(obj.image);
        end
        
        %Chessboard Pattern
        function r=Chessboard(obj,fx,fy)
            for row=1:obj.height
                for column=1:obj.width
                    obj.image(row,column)=64*(square(fx*2*pi*(row-1)/obj.height)+1+square(fy*2*pi*(column-1)/obj.width)+1);
                    %marking the chess fields and then fixing them to use
                    %only two colors (white and black)
                    if obj.image(row,column)<200 && obj.image(row,column)>50
                        obj.image(row,column)=255;
                    else obj.image(row,column)=0;
                    end
                end
            end
            r=uint8(obj.image);
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
        
    end
end