function [startC,endC]= getLevelCoeffIndices(bookKeeping,level,maxLevel,intDirection)
    %0 H direction
    %1 V direction
    %2 D direction
    %-1 for approximations at level maxLevel
    
    row=maxLevel-level+2;
    currentSize=bookKeeping(row,1)*bookKeeping(row,2);
    startC=0;
    multiplier=0;
    
    for i=2:row-1
        multiplier=3;
        if(i==2)
            multiplier=4;  
        end
        startC=startC+bookKeeping(i,1)*bookKeeping(i,2)*multiplier;
    end
    if(level==maxLevel)
        startC=currentSize;
    end    
    startC=startC+intDirection*currentSize+1;
    endC=startC+currentSize-1;
       
        
end