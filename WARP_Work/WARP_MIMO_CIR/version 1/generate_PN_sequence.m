function PN_sequence = generate_PN_sequence(generator_polynomial)

polynomial_order = max(generator_polynomial);

% length of the PN code (2^n-1)
sequence_length=2^polynomial_order-1;

% synthesis of the LFSR and generation of the PN code
h = seqgen.pn('GenPoly',generator_polynomial,'Shift',0,'NumBitsOut',sequence_length); %#ok<SQGPN>
PN_sequence = generate(h);
PN_sequence(PN_sequence == 0) = -1;