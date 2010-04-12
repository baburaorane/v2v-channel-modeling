function [trigger_point fine_CFO]=symbol_synchronization(data)

global NFFT;global CP;global FG;

temp=data(1+NFFT:2*NFFT+CP+FG);
temp1=data(1:NFFT+CP+FG);
correlation_part=temp.*conj(temp1);


b=ones(1,CP);
a=1;

energy_part=(abs(temp).^2)+(abs(temp1).^2);
energy_part=energy_part*0.5;

energy_part=filter(b,a,energy_part);
energy_part(1:CP+FG)=[];
correlation_part=filter(b,a,correlation_part);
correlation_part(1:CP+FG)=[];

% energy_part=movsum(energy_part,CP);
% correlation_part=movsum(correlation_part,CP);

correlation_part1=abs(correlation_part);
diff=correlation_part1-energy_part;

theta_max=max(diff);
trigger_point=find(diff==theta_max);
av_trigger_point=sum(trigger_point)/length(trigger_point);
trigger_point=round(av_trigger_point);
trigger_point=trigger_point+CP+FG-1;
fine_CFO=angle(correlation_part(trigger_point));


