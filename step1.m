clc;
clear;

%image=rgb2gray(imread('1.jpg'));
image=imread('vertical_stripes.jpg');
image_fft=fftshift(fft2(image));

figure(1)
subplot(1,3,1)
imshow(image);
title('Original Image');

subplot(1,3,2)
%figure(2)
imshow(mat2gray(abs(image_fft)));
title('Magnitude of FFT');


subplot(1,3,3)
%figure(3)
reconstructed_image=uint8(ifft2(fftshift(image_fft)));
imshow(reconstructed_image);
title('Reconstructed Image');
