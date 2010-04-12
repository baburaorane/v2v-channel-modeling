function coorected_trigger_point=fine_tuning(trigger_point,channel,ofdm_symb_num)

global NFFT;global CP;global FG;

cir=ifft(channel);
cir=cir(1:CP);
% threshold=max(abs(cir))*0.1;
% cir(abs(cir)<threshold)=0;
hm=abs(cir).^2;

index1=1;
trigger_point=trigger_point-ofdm_symb_num*(NFFT+CP+FG)-CP-FG;
for n=trigger_point-64:trigger_point+64   
    P=0;
    for m=0:length(cir)-1
        temp1=m-n;
        if temp1>=0&&temp1<=CP
            temp2=0;
        elseif temp1>CP
            temp2=temp1-CP;
        elseif temp1<0
            temp2=-1*temp1;
        end
        temp3=temp2*hm(m+1);
        P=P+temp3;
    end
    Pibi(index1)=P;
    index1=index1+1;
end
r=min(Pibi);
e=find(Pibi==r);e=e(end);
n=trigger_point-64:trigger_point+64;
coorected_trigger_point=n(e)+ofdm_symb_num*(NFFT+CP+FG)+CP+FG;

