% A function to generate gold code sequences for K users
% The offsets between the two M-sequences are chosen as random variables (but different for different users)
% Inputs 
%        K:   Number of users 
%        L    Shift register length for generating the  spreading Gold Code (Code length  2^(L)-1 )    
% Output 
%        G:   An NXK matrix with the goldcodes as its columns
function G=Gen_Gold_Code(K,L)

%Generate the random shifts for the K-users
Shifts=[];
while length(Shifts)<K
    rand_Shift=round(rand(1,1)*(2^(L-1)));
    Shifts=[Shifts,rand_Shift];
    for j=1:length(Shifts)-1
        if rand_Shift==Shifts(j);
            Shifts(length(Shifts))=[];
            break
        end
    end
end

%Generate the two prefered msequences 
switch L,
case 5,   whichSeq=[2 4];  
case 6,   whichSeq=[1 3];  
case 7,   whichSeq=[3 5];
case 8,   whichSeq=[2 16];
case 9,   whichSeq=[1 3];
end
 
m_seq_1=mseq(2,L,0,whichSeq(1));

m_seq_1(m_seq_1==-1)=0;
for i=1:K
    m_seq_2=mseq(2,L,Shifts(i),whichSeq(2));
    m_seq_2(m_seq_2==-1)=0;
    G(:,i)=xor(m_seq_1,m_seq_2);
end
G(G==0)=-1;
return