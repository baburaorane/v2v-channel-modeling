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
function TxData = generate_transmitted_data(TxLength,generator_polynomials_book)

TxData = zeros(length(generator_polynomials_book),TxLength);
sequence =  cell(length(generator_polynomials_book),1);

for m=1:length(generator_polynomials_book)
    
    generator_polynomial=cell2mat(generator_polynomials_book(m));
    
    PN_sequence = generate_PN_sequence(generator_polynomial);
    sequence_length=length(PN_sequence);
    
    sequence(m)={PN_sequence};
        
    % guard period between transmitted samples
    % we will consider a code rate equal 1/2 to encounter for long channels
    size_guard_interval=sequence_length;
    
    number_sequences=floor(TxLength/(sequence_length+size_guard_interval));
    size_garbage_samples=TxLength-number_sequences*(sequence_length+size_guard_interval);
    
    
    % streaming the sampels to be transmitted
    sequence_guard=[PN_sequence; zeros(size_guard_interval,1)];
    sequence_guard_mat = repmat(sequence_guard,1,number_sequences);
    
    cycle_length = length(sequence_guard);
    
    useful_samples = reshape(sequence_guard_mat,1,[]);
    TxData(m,:) = [useful_samples, zeros(1,size_garbage_samples)];
    
end

save '-mat' Sequences.GM sequence;
save '-mat' CycleSize.GM cycle_length;
% calculate the number of transmitted sequences
% suggestion for this functio in the case of MIMO
% pre-decide the PN codes and put it in structure format
% save this file in a .mat file then load it in the Tx and Rx
% change the argument of this function by adding the mode of transmission
% SISO or MIMO




