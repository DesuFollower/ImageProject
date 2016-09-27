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
            obj.height=height;
            obj.width=width;
            obj.absolute=ones(obj.height,obj.width);
        end
        %Low Pass
        function r=lowPass(obj,cuttoffFrequency)
            x0=ceil(obj.height/2);
            y0=ceil(obj.width/2);
            obj.absolute=zeros(obj.height,obj.width);
            for row=1:obj.height
                for column=1:obj.width
                    if sqrt((row-x0)*(row-x0)+(column-y0)*(column-y0))<cuttoffFrequency
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
            x0=ceil(obj.height/2);
            y0=ceil(obj.width/2);
            obj.absolute=ones(obj.height,obj.width);
            for row=1:obj.height
                for column=1:obj.width
                    if sqrt((row-x0)*(row-x0)+(column-y0)*(column-y0))<cuttoffFrequency
                        obj.absolute(row,column)=0.0;
                    end 
                end
            end
            %The amplitude is normalized 0...1, if displayed with imshow must be
            %scaled to 255
            r=obj.absolute;
        end
    end
    
end

