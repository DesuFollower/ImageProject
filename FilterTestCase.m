clear;
clc;
height=200;
width=200;
signalF=10;
filterCutoff=8;
filterCutoffTwo=30;
image=sampleImage(height,width);
image=image.horizontalStripes(signalF);
figure(1)
subplot(2,3,1)
imshow(image);
title('Original Image');

subplot(2,3,4)
image_fft=fftshift(fft2(image));
imshow(mat2gray(abs(image_fft)));
title('Magnitude of FFT Original');

subplot(2,3,2)
lowPassFilter=cj2Filter(height,width);
lowPassFilter = lowPassFilter.bandStop(filterCutoff,filterCutoffTwo);
filterTimedomain=fftshift(ifft2(lowPassFilter));
%Fitting the spectrum in 0...255
scalingFactor=floor(255./max(max(abs(filterTimedomain))));
imshow(uint8(scalingFactor.*abs(filterTimedomain)));
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
imshow(mat2gray(255*abs(filteredImage_fft)));
title('Magnitude of Transformed FFT');