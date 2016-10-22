clear
clc
image = imread('http://www.doc.gold.ac.uk/~mas02fl/MSC101/ImageProcess/defect03_files/fig_2_3_14.jpg');
% image = imread('.\OutputImages\horizontal_stripes.jpg');
class = @imageOperations;
A = class(image);

%try different operations
op = input(['Select an operation to be performed\n 1 - rotate 90 deg clockwise\n'...
            ' 2 - rotate 90 deg counter clockwise\n 3 - rotate 180 deg\n'...
            ' 4 - mirror left-right\n 5 - mirror up-down\n 6 - crop,\n'...
            ' 7 - mask out selected area\n 8 - right shift\n 9 - down shift\n'...
            ' 10 - right and down shift\n 11 - resample\n']);
        
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
        w = input('Size of right shift (e.g. 100): ');
        img = A.shiftRight(w);
    case 9
        h = input('Size of down shift (e.g. 100): ');
        img = A.shiftDown(h);
    case 10
        h = input('Size of down shift (e.g. 100): ');
        w = input('Size of right shift (e.g. 100): ');
        img = A.shiftRightDown(h,w);
    case 11
        ratio = input('Resize ratio: ');
        aa = input('Use anti-aliasing filter (y/n): ', 's');
        if aa == 'y'
           img = A.resample(ratio, true);
        elseif aa == 'n'
           img = A.resample(ratio);         % 2nd param is optional, false by default
        else
           warning('Invalid input! Anti-aliasing filter will NOT be used.');
           img = A.resample(ratio); 
        end
    otherwise
        msgbox('Invalid Operation', 'Error','error');
        return;
end
f_original = mat2gray(abs(fftshift(fft2(image))));
f_modified = mat2gray(abs(fftshift(fft2(img))));

figure
subplot(2,2,1)
imshow(image)
title('Original image')
subplot(2,2,3)
imshow(f_original)
title('FFT of original');
subplot(2,2,2)
imshow(img)
title('Modified image')
subplot(2,2,4)
imshow(f_modified)
title('FFT of modified')