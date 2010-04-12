clc;clear all;close all
load '-mat' superframe.flo superframe;
superframe(:,1:512+17)=[];
L=512;NFFT=4096;Ko=1;h=3;
TDM1=superframe(1,:);
temp1=exp(1i*2*pi*(0:1:4095)*Ko/NFFT);
temp1=repmat(temp1,1200,1);
superframe=superframe.*temp1;
clear temp1;
% %======================================================
% %channel
ts=1/5.55e6;
fd=100;
tau=[ 0 10*ts  250*ts];
pdb=[0, -3, -3];
SNR=5;
chan = rayleighchan(ts,fd,tau,pdb);
%  for n=1:1200
%      superframe(n,:)=filter(chan,superframe(n,:));
%  end
superframe=filter2(h,superframe);
superframe=awgn(superframe,SNR,'measured','db');
clear temp1;clear temp;
%======================================================
%bank of TDM1 with diff CFO
p=zeros(h,4096);
for k=1:h
    p(k,:)=exp((1i*2*pi*k*(0:1:4095))/NFFT);
end
temp=repmat(TDM1,h,1);
p=p.*temp;
clear temp;
%=======================================================
M_matrix=zeros(h,1200);
for t=1:1200
    q=superframe(t,:);
    q=repmat(q,h,1);
    y=zeros(h,2*512+1);
    for n=1:h
        y(n,:)=xcorr(q(n,:),p(n,:),512);
    end
    temp2=(abs(y)).^2;
    M_matrix(:,t)=sum(temp2,2);
end
mesh(M_matrix)
grid on
title('super frame corelation matrix')
[u v r]=find(M_matrix==max(max(M_matrix)));
display('coarse CFO ')
display(u)
display('OFDM symbol number ')
display(v)
