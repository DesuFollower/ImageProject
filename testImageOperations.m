clear
clc
image = imread('http://www.doc.gold.ac.uk/~mas02fl/MSC101/ImageProcess/defect03_files/fig_2_3_14.jpg');
class = @imageOperations;
A = class(image);

%try different operations
op = input(['Select an operation to be performed\n 1 - rotate 90 deg clockwise\n'...
            ' 2 - rotate 90 deg counter clockwise\n 3 - rotate 180 deg\n'...
            ' 4 - mirror left-right\n 5 - mirror up-down\n 6 - crop,\n'...
            ' 7 - mask out selected area\n 8 - mask outside selected area\n']);
        
switch op
    case 1
        img = A.rotate90cw();
    case 2
        img = A.rotate90ccw();
    case 3
        img = A.rotate180();
    case 4
        img = A.mirrorlr();
    case 5
        img = A.mirrorud();
    case 6
        h = input('Height (e.g. 100:300): ');
        w = input('Width (e.g. 100:300): ');
        img = A.crop(h, w);
    case 7
        h = input('Height (e.g. 100:300): ');
        w = input('Width (e.g. 100:300): ');
        img = A.maskout(h, w);
    case 8
        h = input('Height (e.g. 100:300): ');
        w = input('Width (e.g. 100:300): ');
        img = A.maskoutside(h, w);
    otherwise
        h = msgbox('Invalid Operation', 'Error','error');
        return;
end
figure
subplot(1,2,1)
imshow(image)
title('Original image')
subplot(1,2,2)
imshow(img)
title('Modified image')
            