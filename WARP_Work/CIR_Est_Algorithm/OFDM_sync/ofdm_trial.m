clear all;clc;close all;

% system parameters
NFFT=4096;
CP_fract=1/8;
CP=CP_fract*NFFT;

% transmitted data
S_f=randsrc(NFFT,1,[1 -1;0.5 0.5]);
S_t=ifft(S_f,NFFT);
Tx_sym=[S_t(end-CP+1:end);S_t];

% channel 
h=[1 0 0.5];
Rx_sym=filter(h,1,Tx_sym);

% receiver operation
R_t=Rx_sym(CP+1:end);
R_f=fft(R_t,NFFT);

% channel estimated 
H=R_f./S_f;
figure;stem(H,'.');
H=ifft(H,NFFT);
figure;stem(h,'.');


