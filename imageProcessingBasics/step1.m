%clearing environment
clc;
clear;

%reading one of our pre-generated images
image=imread('vertical_stripes.jpg');
%adding shift for better display of FFT
image_fft=fftshift(fft2(image));

% displaying original image
subplot(1,3,1)
imshow(image);
title('Original Image');

% displaying magnitude
subplot(1,3,2)
%converting matrix to grayscale and displaying it
imshow(mat2gray(abs(image_fft)));
title('Magnitude of FFT');

% displaying image reconstructed from the FFT
subplot(1,3,3)
%shifting image back and applying inverse FFT
reconstructed_image=uint8(ifft2(fftshift(image_fft)));
imshow(reconstructed_image);
title('Reconstructed Image');
