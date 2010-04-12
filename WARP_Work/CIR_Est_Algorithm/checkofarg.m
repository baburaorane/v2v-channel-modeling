function [r1,r2,r3,r4]=checkofarg(a)

% check if the parameters match one of the preserved parameters also it return 
% the position of the parameter in the input arguments

if any(strcmp('initialstate',a))
    temp=strcmp('initialstate',a);
    r1=find(temp==1);
    if any(strcmp('currentstate',a))
        temp=strcmp('currentstate',a);
        r2=find(temp==1);
        if any(strcmp('genpoly',a))
            temp=strcmp('genpoly',a);
            r3=find(temp==1);
            if any(strcmp('numbitsout',a))
                temp=strcmp('numbitsout',a);
                r4=find(temp==1);

            else
                error('Invalid Parameters');
            end
        else
            error('Invalid Parameters');
        end
    else
        error('Invalid Parameters');
    end
else
    error('Invalid Parameters');
end