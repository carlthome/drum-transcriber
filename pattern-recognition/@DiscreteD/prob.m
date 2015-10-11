%[p,logS]=prob(pD,Z)
%method to give the probability of a data sequence,
%assumed to be drawn from given Discrete Distribution(s).
%
%Input:
%pD=    DiscreteD object or array of DiscreteD objects
%Z=     row vector with data assumed to be drawn from a Discrete Distribution
%       (Z may be real-valued, but is always rounded to integer values)
%
%Result:
%p=     array with probability values for each element in Z,
%       for each given DiscreteD object
%       size(p)== [length(pD),size(x,2)], if pD is one-dimensional vector
%       size(p)== [size(pD),size(x,2)], if pD is multidim array
%logS=  scalar log scalefactor, for HMM compatibility, always==0
%
%Arne Leijon 2005-10-06 tested

function [p,logS]=prob(pD,Z)
if size(Z,1)>1
    error('Data must be row vector with scalar values');end;
pDsize=size(pD);%size of DiscreteD array
pDlength=prod(pDsize);%number of DiscreteD objects
nZ=size(Z,2);%number of observed data
p=zeros(pDlength,nZ);%zero prob if Z is out of range
Z=round(Z);%make sure it is integer
for i=1:pDlength%for all objects in pD
    iDataOK=(Z>=1) & (Z <=length(pD(i).ProbMass));%within range of the DiscreteD
    p(i,iDataOK )=pD(i).ProbMass(Z(iDataOK))';
end;
if pDlength>1
    p=squeeze(reshape(p,[pDsize,nZ]));%restore array format
end;
logS=0;%always no scaling, only for compatibility with other ProbDistr classes

