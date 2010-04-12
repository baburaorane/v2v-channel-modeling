function LFSR_check(A)


if length(A.initialstate)==length(A.currentstate)
    if length(A.initialstate)==A.numbitsout
        if length(A.genpoly)<=length(A.initialstate)+1
            if length(A.genpoly)>=2
                return;
            else
                error('invalid polynomial length')
            end
        else
            error('the generator polynomial and the initial and final state must be of the same length')
        end
    else
        error('the number of bits must equal the length of inital and final states')
    end
else
    error('Initialstate and currentstate must be of the same length')
end