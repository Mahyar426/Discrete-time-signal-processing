%% Mohadeseh Ghafoori 9632133 Mahyar Onsori 9632093
%% clearing
clc
clear all
close all
%% signal reading and filter initalizing
[signal,Fs]=audioread('C:\Users\Mahyar Onsori\Desktop\e3\a2n.wav');
t=1:length(signal);
w1=1/4; 
dw=1/20;
[b1,a1]=butter(6,[w1-dw w1+dw],'stop');
n_quantize=12;
n_cascade=2;
%% part a
figure('name','Zplane');
zplane(b1,a1);
%% part b
figure('name','Frequency Response of Original Signal');
freqz(b1,a1);
%% part c
filtered_signal=filter(b1,a1,signal);
%sound(filtered_signal,Fs);
%% part d
% figure('name','Unfiltered and Filtered Signal');
% subplot(1,2,1);
% plot(t,signal);
% title('Unfiltered Signal');
% subplot(1,2,2);
% plot(t,filtered_signal);
% title('Filtered Signal');
figure('name','Part of Unfiltered and Filtered Signal');
subplot(1,2,1);
plot(signal(5000:6000));% part of signal choosen
xlim([1 1000]);
title('Part of Unfiltered Signal');
subplot(1,2,2);
plot(filtered_signal(5000:6000));
xlim([1 1000]);
title('Part of Filtered Signal');

%% quantizing coefficients
a1_quantized=round(a1,n_quantize,'significant');
b1_quantized=round(b1,n_quantize,'significant');
%% part e
figure('name','Zplane Quantized');
zplane(b1_quantized,a1_quantized);
figure('name','Zplane Comparing between Original Coefficients and Quantized');
subplot(1,2,1);
zplane(b1,a1);
title('Original Coefficients Zplane');
subplot(1,2,2);
zplane(b1_quantized,a1_quantized);
title('Quantized Coefficients Zplane');
%% part f
figure('name','Frequency Response Quantized');
freqz(b1_quantized,a1_quantized);
%% part g
filtered_signal_quantized=filter(b1_quantized,a1_quantized,signal);
%sound(filtered_signal_quantized,Fs);
%% part h is answered in report
%% part i Section one:building cascade system
z=roots(b1);
p=roots(a1);
a_cascade=zeros(6,3);%6 order-two filters with each filter having 3 coefficient
b_cascade=zeros(6,3);
for i=1:6
    a_cascade(i,:)=poly(p(2*i-1:2*i));
    b_cascade(i,:)=poly(z(2*i-1:2*i));
    a_cascade(i,:)=round(a_cascade(i,:),n_cascade,'significant');
    b_cascade(i,:)=round(b_cascade(i,:),n_cascade,'significant');
    
end
%% part i Section two : creating total system filter using convolution
a_cascade_total=a_cascade(1,:);
b_cascade_total=b_cascade(1,:);
for k=2:6
    a_cascade_total=conv(a_cascade_total,a_cascade(k,:));
    b_cascade_total=conv(b_cascade_total,b_cascade(k,:));
    % total cascade filter is created by calculating the convolution of
    % it's subsystems and also we have:
    %a1*a2*a3*a4*a5*a6=(((((a1*a2)*a3)*a4)*a5)*a6)
    %so we use this loop to reach the mentioned formula
end
%% part i section three: total cascade system zplane and comparing
figure('name','Zplane Total Cascade System');
zplane(b_cascade_total,a_cascade_total);
figure('name','Zplane Comparing between Original Coefficients and Cascaded');
subplot(1,2,1);
zplane(b1,a1);
title('Original Coefficients Zplane');
subplot(1,2,2);
zplane(b_cascade_total,a_cascade_total);
title('Cascaded Coefficients Zplane');
%% part i section four: total cascade system frequency response
figure('name','Frequency Response Cascade System');
freqz(b_cascade_total,a_cascade_total);
%% part i Section five :sending the original sound through the cascade system
cascaded_signal=filter(b_cascade_total,a_cascade_total,signal);
%for j=1:6
    %cascaded_signal=filter(b_cascade(j,:),a_cascade(j,:),cascaded_signal);
    %outcoming signal from this loop has passed through all six two-order
    %filters which are cascaded
%end
sound(cascaded_signal,Fs);
%% part i section six : plotting part of signal
figure('name','Part of Unfiltered and Filtered Signal');
subplot(1,2,1);
plot(signal(5000:6000));% part of signal choosen
xlim([1 1000]);
title('Part of Unfiltered Filtered Signal');
subplot(1,2,2);
plot(cascaded_signal(5000:6000));
xlim([1 1000]);
title('Part of Cascade Filtered Signal');


