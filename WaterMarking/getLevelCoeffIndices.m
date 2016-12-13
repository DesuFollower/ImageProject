function [startC,endC]= getLevelCoeffIndices(bookKeeping,level,maxLevel,intDirection)
    %Returns the indices within the array described by the bookKeeping
    %matrix (i.e. created by wavedec2), that correspond to a direction 
    %(Vertical, Horizontal or Diagonal ) and a level within the maxLevel 
    %ranges. For Approximation level should be max level and intDir -1
    %@bookKeeping:  Second Return value of wavedec2
    %@level:        level for which the coefficient indices should be
    %               returned
    %@maxLevel:     Level of decomposition using wavedec2
    %@intDirection: Integer denoting the direction of the coefficients i.e.
    %               0 Horizontal direction
    %               1 Vertical direction
    %               2 Diagonal direction
    %              -1 for approximations at level maxLevel
    
    row=maxLevel-level+2;%Row of the corresponding level within the bookkeeping matrix
    currentSize=bookKeeping(row,1)*bookKeeping(row,2);%rows*columns
    startC=0;
     
    for i=2:row-1
        multiplier=3;%for all of the levels except the first
        if(i==2)%for the first level
            multiplier=4;  
        end
        %Add up all the levels previous to the one of interest
        startC=startC+bookKeeping(i,1)*bookKeeping(i,2)*multiplier;
    end
    
    if(level==maxLevel)%for the last level of the decomposition
        startC=currentSize;%use rows*columns since there are no further coefficients
    end    
    startC=startC+intDirection*currentSize+1;%starting index
    endC=startC+currentSize-1;%ending index
               
end