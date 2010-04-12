function set(A,propname,value)
switch propname
    case 'initialstate'
        A.initialstate=value;
    case 'currentstate'
        A.currentstate=value;
    case 'numbitsout'
        A.numbitsout=value;
    case 'genpoly'
        A.genpoly=value;
    otherwise
        error('Unknown property');
end
LFSR_check(A);
assignin('caller',inputname(1),A);
