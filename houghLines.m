clear;
clc;

image=rgb2gray(imread('lines.jpg'));
 if(abs(R15-(xi*cos(Fi(radiFy(2,i)))+yi*sin(Fi(radiFy(2,i)))))<threshold)
                    lines(xi,yi)=255;
               

canniedImage=edge(image,'canny');

figure(1)
subplot(2,1,1);
imshow(image);
subplot(2,1,2);
%figure(2)
imshow(canniedImage);

steps=50;
dFi=2*pi/steps;
Fi=zeros(steps);
Fi=0:dFi:2*pi-dFi;

[height,width]=size(image);
maxR=sqrt(width*width+height*height);
dr=maxR/steps;
R=0:dr:maxR-dr;

threshold=3;
votingSpace=zeros(steps,steps);

for xi=1:height
   for yi=1:width
        if(canniedImage(xi,yi))
            for iR=1:steps
                for iFi=1:steps
                    if(abs(R(iR)-(xi*cos(Fi(iFi))+yi*sin(Fi(iFi))))<threshold)
                        votingSpace(iR,iFi)=votingSpace(iR,iFi)+1;
                    end
                end
            end
        end 
   end
end

spectre = votingSpace;
ultima=max(max(spectre));
radiFy=zeros(2,steps);
index=1;
while ((ultima/4)<(max(max(spectre))))
    
    [val,y]=max(spectre);
    [trueMax,x]=max(val);
    thresh=3;
    for ty=-thresh:thresh
        for tx=-thresh:thresh 
            spectre(mod((y(x)+ty-1),steps)+1,mod((x+tx-1),steps)+1)= 0;
        end
    end    
    radiFy(1,index)=y(x);
    radiFy(2,index)=x;
    index=index+1;
end    

lines=zeros(height,width);
for xi=1:height
   for yi=1:width
        for i = 1:index-1
            if(canniedImage(xi,yi))

                if(abs(R(radiFy(1,i))-(xi*cos(Fi(radiFy(2,i)))+yi*sin(Fi(radiFy(2,i)))))<threshold)
                    lines(xi,yi)=255;
                end
            end
        end
   end
end

figure(2)
subplot(2,1,1);
imshow(uint8(votingSpace));
%subplot(2,1,2);
figure(4)
imshow(uint8(lines));