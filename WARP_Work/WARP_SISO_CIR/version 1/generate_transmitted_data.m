% this function is to generate the transmitted samples for SISO transmitter 
% the structure of the transmitted stream :-
% capture offset - code samples - guard period .... - garbage samples 
%(to complete the buffer of the transmitter)

% functions Arguments
% Inputs :-
%         TxLength         :  length of the useful transmitted samples
%         polynomial       :  generator polynomial of the LFSR
%         polynomial_order : the order of the PN code generator polynomial
% Output :-
%         TxData           : transmitted stream
function TxData = generate_transmitted_data(TxLength,polynomial_order,polynomial)

% length of the PN code (2^n-1)
sequence_length=2^polynomial_order-1;

% guard period between transmitted samples
% we will consider a code rate equal 1/2 to encounter for long channels 
size_guard_interval=sequence_length;

% calculate the number of transmitted sequences
number_sequences=floor(TxLength/(sequence_length+size_guard_interval));
size_garbage_samples=TxLength-number_sequences*(sequence_length+size_guard_interval);

% synthesis of the LFSR and generation of the PN code
h = seqgen.pn('GenPoly',polynomial,'Shift',0,'NumBitsOut',sequence_length,'initialstate',randint(polynomial_order,1)); %#ok<FDEPR,SQGPN>
sequence=generate(h);sequence(sequence==0)=-1;

% save  the PN for the Rx (Rx will need the transmitted code to calculate
% the correlation)
save '-mat' sequence.GM sequence;

% streaming the sampels to be transmitted 
sequence_guard=[sequence; zeros(size_guard_interval,1)];
sequence_guard_mat=repmat(sequence_guard,1,number_sequences);

useful_samples=reshape(sequence_guard_mat,1,[]);
TxData=[useful_samples, zeros(1,size_garbage_samples)];
% suggestion for this functio in the case of MIMO 
% pre-decide the PN codes and put it in structure format
% save this file in a .mat file then load it in the Tx and Rx 
% change the argument of this function by adding the mode of transmission
% SISO or MIMO



