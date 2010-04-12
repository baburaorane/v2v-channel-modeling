function TxData = generate_transmitted_data(TxLength,polynomial_order,polynomial)

sequence_length=2^polynomial_order-1;
size_guard_interval=39;
number_sequences=floor((size_guard_interval+TxLength)/sequence_length);
size_garbage_samples=TxLength-number_sequences*sequence_length;

h = seqgen.pn('GenPoly',polynomial,'Shift',0,'NumBitsOut',sequence_length,'initialstate',randint(polynomial_order,1)); %#ok<FDEPR,SQGPN>
sequence=generate(h);sequence(sequence==0)=-1;

save '-mat' sequence.GM sequence;
sequence_guard=[sequence; zeros(size_guard_interval,1)];
sequence_guard_mat=repmat(sequence_guard,1,number_sequences);

useful_samples=reshape(sequence_guard_mat,1,[]);
TxData=[useful_samples, zeros(1,size_garbage_samples)];


