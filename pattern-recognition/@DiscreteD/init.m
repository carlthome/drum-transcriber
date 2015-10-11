%pD=init(pD,x);
%initializes DiscreteD object or array of such objects
%to conform with a set of given observed data values.
%The agreement is crude, and should be further refined by training,
%using methods adaptStart, adaptAccum, and adaptSet.
%
%Input:
%pD=    a single DiscreteD object or multidim array of GaussD objects
%x=     row vector with observed data samples
%
%Result:
%pD=    initialized DiscreteD object or multidim DiscreteD array
%       size(pD)== same as input
%
%Method:
%For a single DiscreteD object: Set ProbMass using all observations.
%For a DiscreteD array: Use all observations for each object,
%       and increase probability P[X=i] in pD(i),
%This is crude, but there is no general way to determine
%       how "close" observations X=m and X=n are,
%       so we cannot define "clusters" in the observed data.
%  
%Arne Leijon 2009-07-21

function pD=init(pD,x)
%sizObj=size(pD);
nObj=numel(pD);
if size(x,1)>1
    error('DiscreteD object can have only scalar data');end;
x=round(x);
maxObs=max(x);
%collect observation frequencies
fObs=zeros(maxObs,1);%observation frequencies
for m=1:maxObs
    fObs(m)=1+sum(x==m);%no zero frequencies
end;
if nObj==1
    pD.ProbMass=fObs;
else
    if nObj>maxObs
        warning('Some DiscreteD objects initialized equal');
    end;
    for i=1:nObj
        m=1+mod(i-1,maxObs);%obs value to be emphasized
        p=fObs;
        p(m)=2*p(m);%what emphasis factor to use???
        pD(i).ProbMass=p;
    end;
end;
