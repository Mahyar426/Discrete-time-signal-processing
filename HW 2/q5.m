%% Mohadeseh Ghafoori 9632133 , Mahyar Onsori 9632093
%% Clearing
clc
close all
clear all
%% defining parameters
T=16;%running time
phi=0;%initial phase
f1=0;%starting frequency
f2=4000; % final frequency
c = (f2-f1)/T;%chirpyness or slope 
n=0.005;%Window Parameter
%% Creating Oscilloscope
for i=0:160
    t=(i*n):0.0001:(i*n)+0.25;% Time Variant Window
    y=cos(phi+2*pi*((c/2).*t.^(2)+(f1.*t)));%Chirp signal
    plot(t,y,'r');
    ylim([-1 1]);
    grid on;
    drawnow
    pause(0.25);%controls the pace of the plot
end



 