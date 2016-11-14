clc;
clear;
width=600;
height=600;
frequency=10;
%Vertical Stripes
image=uint8(ones(height,width)*255);
image(:,1:frequency:width)=0;
figure(1)
imshow(image);
imwrite(image,'vertical_stripes.jpg');

%Horizontal Stripes
image=uint8(ones(height,width)*255);
image(1:frequency:width,:)=0;
figure(2)
imshow(image);
imwrite(image,'horizontal_stripes.jpg');

%Diagonal Stripes negative slope

image=uint8(ones(height,width)*255);
shift=1;
for column=1:width
    if shift==frequency+1
        shift=1;
    end 
    image(shift:frequency:width,column)=0;
    shift=shift+1;
end
figure(3)
imshow(image);
imwrite(image,'diagonal_stripes_negative.jpg');

%Diagonal Stripes positive slope

image=uint8(ones(height,width)*255);
shift=1;
for column=width:-1:1
    if shift==frequency+1
        shift=1;
    end 
    image(shift:frequency:width,column)=0;
    shift=shift+1;
end
figure(4)
imshow(image);
imwrite(image,'diagonal_stripes_positive.jpg');
