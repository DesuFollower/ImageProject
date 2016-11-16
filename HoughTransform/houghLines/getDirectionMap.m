function [ directionMap ] = getDirectionMap( distance )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    directionMap = int16(zeros(distance*4,2));
    
    for i=1:distance
        directionMap(i,:)=[i, -1*distance];
    end
    
    for i=1:distance*2
        directionMap(i+distance,:)=[distance,i-distance];
    end
    
    for i=1:distance
        directionMap(i+3*distance,:)=[distance+1-i,distance];
    end
end

