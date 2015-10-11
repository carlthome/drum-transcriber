%pMass=double(pD)
%converts a DiscreteD object or column vector of such objects
%to an array with ProbMass values.
%i.e. inverse of pD=DiscreteD(pMass).
%
%Result:
%pMass(i,z)= P(Z(i)=z), with Z(i)= the i-th discrete random variable.
%
%Arne Leijon 2006-09-03 tested

function pMass=double(pD)
M=0;%max discrete random integer
for i=1:numel(pD)%just in case M is not equal for all distr.
    M=max(M,length(pD(i).ProbMass));
end;
pMass=zeros(numel(pD),M);%space for ProbMass matrix
for i=1:numel(pD)
    pMass(i,1:length(pD(i).ProbMass))=pD(i).ProbMass';%row ProbMass values
end;
    