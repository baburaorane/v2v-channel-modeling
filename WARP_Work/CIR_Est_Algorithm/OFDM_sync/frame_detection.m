clear all;clc;close all;
load '-mat' superframe.flo;
TDM1=superframe(1,:);
rec_sym=[randn(1,randi(4000,1,1)),TDM1];
% extra_sam=length(rec_sym)-length(TDM1);
% corr_out=zeros(1,extra_sam);
% for m=1:extra_sam+20
%     wind_sym=rec_sym(m:length(TDM1)+m-1);
%     y=xcorr(wind_sym,TDM1);
%     corr_out(m)=max(abs(y));
% end
corr_out=xcorr(rec_sym,TDM1);
plot(abs(corr_out))