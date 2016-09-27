clear;
clc;
heigh
image=sampleImage(100,100).horizontalStripes(15);

figure(1)
subplot(2,3,1)
imshow(image);
title('Original Image');

subplot(2,3,4)
image_fft=fftshift(fft2(image));
imshow(mat2gray(abs(image_fft)));
title('Magnitude of FFT Original');

subplot(2,3,2)
lowPassFilter=cj2Filter(100,100).lowPass(12);
filterTimedomain=ifft2(fftshift(lowPassFilter));
imshow(uint8(255*abs(filterTimedomain)));

title('Time Domain of FFT filter');


subplot(2,3,5)

imshow(uint8(255*lowPassFilter));
title('Magnitude of FFT filter');


subplot(2,3,3)
filteredImage=cj2Transformation.filter(lowPassFilter,image);
imshow(uint8(filteredImage));
title('Filtered Image');

subplot(2,3,6)
filteredImage_fft=fft2(filteredImage);
imshow(mat2gray(abs(filteredImage_fft)));
title('Magnitude of Transformed FFT');