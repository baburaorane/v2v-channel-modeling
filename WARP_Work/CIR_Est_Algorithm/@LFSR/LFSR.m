function A=LFSR(varargin)
% A = LFSR constructs a default
% PN sequence generator object A, and is equivalent to the
% following:A = LFSR('genpoly', [20 17 1], ...
%               'initialstate', [1 1 1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0],...
%               'currentstate', [1 1 1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0],...
%               'numbitsout',   1)
% A = LFSR(property1,value1,...) constructs a PN sequence generator object a
% with properties as specified by pairs of properties and values.

switch nargin
    case 0
        A=struct('initialstate',[1 1 1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0],...
                  'currentstate',[1 1 1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0],...
                  'numbitsout',20,'genpoly',[20 17 1],'efpoly',17);
        A=class(A,'LFSR');
    case 1
        if (isa(varargin{1},'LFSR'))
            A=varargin{1};
        else
            error('Input Argument Is not A LFSR object');
        end
    case 8
        chk={varargin{1},varargin{3},varargin{5},varargin{7}};
        [r1,r2,r3,r4]=checkofarg(chk);
        temp=varargin{2*r3};
        effpoly=temp(2:end-1);
        A=struct('initialstate',varargin{2*r1},'currentstate',varargin{2*r2},...
                 'numbitsout',varargin{2*r4},'genpoly',varargin{2*r3},'efpoly',effpoly);
        A=class(A,'LFSR');
        LFSR_check(A);
    otherwise
        error('Invalid number of Input Arguments.');
end