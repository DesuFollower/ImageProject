function [imageWithLines, votingSpace, Maximus, preMaximus] = houghLines(image)
    
    [~,~,d] = size(image);
    if d == 3
        image=rgb2gray(image);
    end
    %pre-processing image with edge detection algorithm
    canniedImage=edge(image,'canny');
    [height,width]=size(image);

    %preparing voting matrix (angle)x(distance) (Fi)x(R)
    FiSteps=270;
    dFi=1.5*pi/FiSteps;
    Fi=-pi/2:dFi:pi;

    rSteps=200;
    maxR=sqrt(width*width+height*height);
    dr=maxR/rSteps;
    R=0:dr:maxR-dr;

    votingSpace=zeros(rSteps,FiSteps);

    % maximal deviation of point from the expected line
    threshold=1;

    cosFi=cos(Fi);
    sinFi=sin(Fi);

    %filling voting matrix
    for xi=1:height
       for yi=1:width
            if(canniedImage(xi,yi))
                % going through all possible lines in the image
                % adding vote to each line point itself belongs to
                for iR=1:rSteps
                    for iFi=1:FiSteps
                        if(abs(R(iR)-(xi*cosFi(iFi)+yi*sinFi(iFi)))<=threshold)
                            votingSpace(iR,iFi)=votingSpace(iR,iFi)+1;
                        end
                    end
                end
            end 
       end
    end
    % filtering voting matix two achieve following goals:
    % 1) Throw away all lines with low amount of votes (achieved by appliyng
    % threshold)
    % 2) combine close parallel lines into one (achieved by gaussian filtering)
    Gm=abs(gradient(votingSpace));
    %here we could also use imgaussfilt function instead of creating filter
    %separately
    % imgaussfilt was added in version 2015, thus we use old variant for better
    % compatibility
    gaussianFilter = fspecial('gaussian', [13,13], 3); 
    preMaximus =imfilter(Gm,gaussianFilter);


    %applying threshold to voting matrix, throwing away values that are less
    %than 40% of maximum
    votingThreshold=0.4*max(max(preMaximus));
    for iR=1:rSteps
        for iFi=1:FiSteps
            if (preMaximus(iR,iFi)< votingThreshold)
               preMaximus(iR,iFi)=0;
            end
        end
    end 

    %reducing filtered coordinates to dots on a voting plane
    Maximus=imregionalmax(preMaximus);
    %counting dots ( i.e lines detected)
    numberOfLines =sum(sum(Maximus));
    linesDetected=zeros(numberOfLines,2);
    index=1;
    %creating array with detected lines' stats
    for iR=1:rSteps
        for iFi=1:FiSteps
            if (Maximus(iR,iFi))
               linesDetected(index,:)=[iR iFi];
               index=index+1;
            end
        end
    end   

    %drawing an image to show that lines detected match the original image
    imageWithLines=zeros(height,width);
    for xi=1:height
       for yi=1:width
                for iPoint=1:numberOfLines
                        if(abs(R(linesDetected(iPoint,1))-(xi*cos(Fi(linesDetected(iPoint,2)))+yi*sin(Fi(linesDetected(iPoint,2)))))<threshold)
                            imageWithLines(xi,yi)=255;
                        end
               end     
       end
    end
