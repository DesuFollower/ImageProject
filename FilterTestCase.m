clear;
clc;
height=100;
width=100;
signalF=5;
filterCutoff=8;
filterCutoffTwo=15;
image=sampleImage(height,width);
image=1/2.*(image.horizontalStripes(signalF)+image.horizontalStripes(4+signalF).*1);

figure(1)
subplot(2,3,1)
imshow(image);
title('Original Image');

subplot(2,3,4)
image_fft=fftshift(fft2(image));
imshow(mat2gray(abs(image_fft)));
title('Magnitude of FFT Original');

subplot(2,3,2)
filterInstance=cj2Filter(height,width);
%filterInstance = filterInstance.bandStop(filterCutoff,filterCutoffTwo);
filterInstance = filterInstance.lowPass(filterCutoff);
filterTimedomain=fftshift(ifft2(filterInstance));
%Fitting the spectrum in 0...255
scalingFactor=floor(255./max(max(abs(filterTimedomain))));
imshow(uint8(scalingFactor.*abs(filterTimedomain)));
%imshow(uint8(scalingFactor.*filterTimedomain));
title('Time Domain of FFT filter');


subplot(2,3,5)
imshow(uint8(255*filterInstance));
title('Magnitude of FFT filter');


subplot(2,3,3)
filteredImage=cj2Transformation.filter(filterInstance,image);
%imshow(uint8(abs(filteredImage)));
scalingFactor=floor(255./max(max(abs(filteredImage))));
imshow(uint8(scalingFactor.*abs(filteredImage)));
title('Filtered Image');

subplot(2,3,6)
filteredImage_fft=fft2(filteredImage);
imshow(mat2gray(255*abs(filteredImage_fft)));
title('Magnitude of Transformed FFT');