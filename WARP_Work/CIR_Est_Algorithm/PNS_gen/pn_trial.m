clear all;clc;close all;
LFSR_length=9;
LFSR_length1=10;
LFSR_poly=[9 4 0];
LFSR_poly1=[10 7 0];
h = seqgen.pn('GenPoly',LFSR_poly,'Shift',0,'NumBitsOut',511,'initialstate',randint(LFSR_length,1));
h1 = seqgen.pn('GenPoly',LFSR_poly1,'Shift',0,'NumBitsOut',1023,'initialstate',randint(LFSR_length1,1));

gen_seq=generate(h);
gen_seq1=generate(h1);

gen_seq(gen_seq==0)=-1;
gen_seq1(gen_seq1==0)=-1;

seq_ac=xcorr(gen_seq);
seq_ac1=xcorr(gen_seq1);
corr=xcorr(gen_seq,gen_seq1);

figure;plot(seq_ac);
figure;plot(seq_ac1);
figure;plot(corr);


channel=[1 0.25 0.5];
rec_seq=filter(channel,1,gen_seq);
channel_cir=xcorr(rec_seq,gen_seq,'coeff');
figure;stem(channel_cir)