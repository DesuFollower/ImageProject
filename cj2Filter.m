classdef cj2Filter
    %CJ2FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        height
        width
        absolute
    end
    
    
    methods
        function obj=cj2Filter(height,width)
            %Constructor
            obj.height=height;
            obj.width=width;
            obj.absolute=ones(obj.height,obj.width);
        end
        %Low Pass
        function r=lowPass(obj,cuttoffFrequency)
            %sets the spectrum of a 2d Low pass filter.
            x0=ceil((obj.height+1)/2);
            y0=ceil((obj.width+1)/2);
            obj.absolute=zeros(obj.height,obj.width);
            for row=1:obj.height
                for column=1:obj.width
                    if sqrt((row-x0)*(row-x0)+(column-y0)*(column-y0))<cuttoffFrequency
                        %if the distance from the middle of the screen is
                        %less than the cuttoff frequency set the filter to 1.
                        obj.absolute(row,column)=1.0;
                    end
                end
            end
            %The amplitude is normalized 0...1, if displayed with imshow must be
            %scaled to 255
            r=obj.absolute;
        end
        %High Pass
        function r=highPass(obj,cuttoffFrequency)
            %sets the spectrum of a 2d high pass filter.
            x0=ceil((obj.height+1)/2);
            y0=ceil((obj.width+1)/2);
            obj.absolute=ones(obj.height,obj.width);
            for row=1:obj.height
                for column=1:obj.width
                    if sqrt((row-x0)*(row-x0)+(column-y0)*(column-y0))<cuttoffFrequency
                        %if the distance from the middle of the screen is
                        %less than the cuttoff frequency set the filter to 0.
                        obj.absolute(row,column)=0.0;
                    end
                end
            end
            %The amplitude is normalized 0...1, if displayed with imshow must be
            %scaled to 255
            r=obj.absolute;
        end
        %Bandpass
        
        function r = bandPass(obj, cutoffFrequencyOne,cutoffFrequencyTwo)
            x0=ceil((obj.height+1)/2);
            y0=ceil((obj.width+1)/2);
            obj.absolute = zeros(obj.height,obj.width);
            for row = 1: obj.height
                for column= 1: obj.width
                    if sqrt((row - x0)*(row - x0)+(column - y0)*(column -y0))>cutoffFrequencyOne & sqrt((row - x0)*(row - x0)+(column - y0)*(column -y0)) <cutoffFrequencyTwo
                        obj.absolute(row, column)=1;
                    end
                end
            end
            r=obj.absolute;
            
            
        end
        function r = bandStop(obj, cutoffFrequencyOne,cutoffFrequencyTwo)
            x0=ceil((obj.height+1)/2);
            y0=ceil((obj.width+1)/2);
            obj.absolute = ones(obj.height,obj.width);
            for row = 1: obj.height
                for column= 1: obj.width
                    if sqrt((row - x0)*(row - x0)+(column - y0)*(column -y0))>cutoffFrequencyOne & sqrt((row - x0)*(row - x0)+(column - y0)*(column -y0)) <cutoffFrequencyTwo
                        obj.absolute(row, column)=0;
                    end
                end
            end
            r=obj.absolute;
            
            
        end
        function r = simple_IFFT_scaled(obj)
            filterTimedomain = fftshift(ifft2(obj.absolute));
            %Fitting the spectrum in 0...255
            scalingFactor=floor(255./max(max(abs(filterTimedomain))));
            r = scalingFactor.*abs(filterTimedomain);
        end
    end
    
end

