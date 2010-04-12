% frame synchronization OFDM codes 

clear all;clc;close all;

load '-mat' superframe.flo;

TDM1_t=superframe(1,:);TDM1_f=(1/sqrt(4096))*fft(TDM1_t(17+512+1:end));
WIC_t=superframe(2,:);WIC_f=(1/sqrt(4096))*fft(WIC_t(17+512+1:end));

% % the structure will be as following, transmitting each tial wi