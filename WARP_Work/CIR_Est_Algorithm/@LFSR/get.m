function varargout=get(varargin)
switch nargin
    case 1
        varargout{1}={varargin{1}.initialstate};
        varargout{2}={varargin{1}.currentstate};
        varargout{3}={varargin{1}.numbitsout};
        varargout{4}={varargin{1}.genpoly};
    case 2
        switch varargin{2}
            case 'initialstate'
                varargout={varargin{1}.initialstate};
            case 'currentstate'
                varargout={varargin{1}.currentstate};
            case 'numbitsout'
                varargout={varargin{1}.numbitsout};
            case 'genpoly'
                varargout={varargin{1}.genpoly};
            otherwise
                error('Unknown property');
        end
    otherwise
        error('Invalid number of arguments');
end

