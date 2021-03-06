classdef cj2Transformation
    %CJ2TRANSFORMATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function r= filter(filterAmplitude,image)
            %@filterAmplitude: m x n complex array
            %@image: m x n uint8 array
            %@returns: m x n complex array
			[~,~,d] = size(image);
           if d == 3
               image = rgb2gray(image);
           end
           filterAmplitude=fftshift(filterAmplitude);           
           r=ifft2(fftshift(fft2(image).*filterAmplitude));
            
        end     
    end
    
end

