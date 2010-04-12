clear all;clc;close all;
LFSR_length=9;code_length=2^LFSR_length-1;
LFSR_length1=10;code_length1=2^LFSR_length1-1;
LFSR_poly1=[9 5 0];
LFSR_poly2=	[9 6 4 3 0];
LFSR_poly3=[10 3 0];
LFSR_poly4=[10 7 0];

h1 = seqgen.pn('GenPoly',LFSR_poly1,'Shift',0,'NumBitsOut',code_length);
h2 = seqgen.pn('GenPoly',LFSR_poly2,'Shift',0,'NumBitsOut',code_length);

h3 = seqgen.pn('GenPoly',LFSR_poly3,'Shift',0,'NumBitsOut',code_length1);
h4 = seqgen.pn('GenPoly',LFSR_poly4,'Shift',0,'NumBitsOut',code_length1);

H1 = generate(h1);
H2 = generate(h2);
gen_seq = double(xor(H1,H2));
H1 = generate(h3);
H2 = generate(h4);
gen_seq1 = double(xor(H1,H2));

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