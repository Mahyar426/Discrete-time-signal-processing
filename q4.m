%% Mohadeseh Ghafoori 9632133 , Mahyar Onsori 9632093
%% Clearing
clc
close all
clear all
%% defining parameters
Fs=30000;%Please choose your Fs from(2000,4000,8000,10000,20000,30000)
T=16;%running time
y=zeros(1,T*Fs);
phi=0;%initial phase
f1=0;%starting frequency
f2=4000; % final frequency
c=(f2-f1)/T; 
j=1;
%% sampling with Fs
for t=0:(1/Fs):T
        y1=cos(phi+2*pi*((c/2).*t.^(2)+(f1.*t)));%Chirp signal
        y(1,j)=y1;%vector containing samples
        j=j+1;%counter
end
%% Playing Sound with Fs
 sound(y,Fs);
