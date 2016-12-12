clc;
clear;
close all;
dt=0.001;
T=1;
t=0:dt:T-dt;
f0=5;
omega=2*pi*f0;
hostSignal=sin(omega*t);
watermarkSignal=0.5*sin(5*omega*t).*sin(4*omega*t)+sin(2*omega*t);
sigma=0.1;
WaterMark=randn(1,length(t));


levels=3;
[HostC,HostL]=wavedec(hostSignal,levels,'haar');
[watC,watL]=wavedec(watermarkSignal,levels,'haar');
%AlphaBlending 
q=0.25;
p=1-q;
hostCoef={};
watCoef={};
resSigCoef={};
resC=zeros(length(HostC));
start=1;
endlimit=0;

for i=1:levels+1    
    endlimit=endlimit+HostL(i);
    hostCoef{i}=HostC(start:endlimit);
    watCoef{i}=watC(start:endlimit);
    resSigCoef{i}=p*HostC(start:endlimit)+q*watC(start:endlimit);
    if(i==1)
        resSigCoef{i}=(1-q*q)*HostC(start:endlimit)+q*q*watC(start:endlimit);
    end
    resC(start:endlimit)=resSigCoef{i};
    start=start+HostL(i);
end


watermarked=waverec(resC,HostL,'haar');
%Recovering the watermark
[watCSig,watLSig]=wavedec(watermarked,levels,'haar');
RwatCoef={};
start=1;
endlimit=0;
reCW=zeros(length(HostC));
for i=1:levels+1    
    endlimit=endlimit+HostL(i);
    
    RwatCoef{i}=(watCSig(start:endlimit)- p*HostC(start:endlimit))/q;
    if(i==1)
        RwatCoef{i}=(watCSig(start:endlimit)- (1-q*q)*HostC(start:endlimit))/(q*q);
    end
    reCW(start:endlimit)=RwatCoef{i};
    start=start+HostL(i);
end

recoveredWatermark=waverec(reCW,HostL,'haar');


figure(1)
subplot(4,1,1);
plot(hostSignal);
title('Host signal');
subplot(4,1,2);
plot(watermarkSignal);

title('Watermark signal');
subplot(4,1,3);
plot(watermarked);
title('Watermarked signal');
subplot(4,1,4);
plot(recoveredWatermark);
title('Recovered Watermark');
