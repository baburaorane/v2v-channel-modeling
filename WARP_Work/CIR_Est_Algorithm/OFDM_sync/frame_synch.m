function TDM1_index=frame_synch(super_frame,initial_trigger_point)

global TDM1;global NFFT;global CP;global FG;

max_corr=zeros(1,1200);
add_samples=initial_trigger_point;
if add_samples>0
    super_frame=[super_frame,super_frame(1:initial_trigger_point+1)];
elseif add_samples<0
    add_samples=abs(add_samples);
    super_frame=[super_frame(end-add_samples:end),super_frame];
end
for m=1:1200
    symbol=super_frame(initial_trigger_point+1:initial_trigger_point+NFFT+CP+FG);
    %     corr_temp=conj(TDM1).*symbol;
    %     max_corr(m)=sum(corr_temp);
    corr_temp=xcorr(TDM1,symbol,CP);
    max_corr(m)=max(corr_temp);
    initial_trigger_point=initial_trigger_point+NFFT+CP+FG;
end
temp=max(max_corr);
TDM1_index=find(max_corr==temp);


