clear all

%reading example image and preparing it for the FFT : making it grayscale
%and shifting
img = imread('http://www.doc.gold.ac.uk/~mas02fl/MSC101/ImageProcess/defect03_files/fig_2_3_14.jpg');
img = im2double(rgb2gray(img));
f = fftshift(fft2(img));
fabs = mat2gray(log(abs(f)+1));
%--------------------------------------------------------------------------
% creating Low-pass filter
K0 = 0.1;             %cutoff freq
lp = fir1(32,K0);     % Generate the lowpass filter (order, cut-off frequency)
lp_2D = ftrans2(lp);  % Convert to 2-dimensions
img_lp = imfilter(img, lp_2D, 'replicate'); %applying filter
f1 = fftshift(fft2(img_lp));        % fft of filtered image
fabs1 = mat2gray(log(abs(f1)+1));

%displaying the result of filter application
figure('name','Low Pass Filter')
subplot(2,2,1)
imshow(img)
title('Original');
subplot(2,2,2)
imshow(img_lp)
title('Filtered');
subplot(2,2,3)
imshow(fabs)
title('FFT Original');
subplot(2,2,4)
imshow(fabs1)
title('FFT Filtered');
%--------------------------------------------------------------------------
% creating averaging filter of size [r c], default is [3 3] 
filter = fspecial('average', [10 10]);
img_avg = imfilter(img, filter, 'replicate');
f1 = fftshift(fft2(img_avg));
fabs1 = mat2gray(log(abs(f1)+1));

%displaying the result of filter application
figure('name','Predefined filter - in this case averaging filter')
subplot(2,2,1)
imshow(img)
title('Original');
subplot(2,2,2)
imshow(img_avg)
title('Filtered');
subplot(2,2,3)
imshow(fabs)
title('FFT Original');
subplot(2,2,4)
imshow(fabs1)
title('FFT Filtered');
%--------------------------------------------------------------------------
% filters image with a 2-D Gaussian smoothing kernel with standard deviation of 0.5
img_gauss = imgaussfilt(img, 0.5);
f1 = fftshift(fft2(img_gauss));
fabs1 = mat2gray(log(abs(f1)+1));

figure('name','Gaussian filter')
subplot(2,2,1)
imshow(img)
title('Original');
subplot(2,2,2)
imshow(img_gauss)
title('Filtered');
subplot(2,2,3)
imshow(fabs)
title('FFT Original');
subplot(2,2,4)
imshow(fabs1)
title('FFT Filtered');