%[X,S]=rand(pD,nSamples) returns random vectors drawn from a single GaussMixD object.
%
%Input:
%pD=        the GaussMixD object
%nSamples=  scalar defining number of wanted random data vectors
%
%Result:
%X= matrix with data vectors drawn from object pD
%   size(X)== [DataSize, nSamples]
%S= row vector with indices of the GaussD sub-objects randomly chosen
%   size(S)== [1, nSamples]
%
%Arne Leijon 2009-07-21 tested

function [X,S]=rand(pD,nSamples)
if length(pD)>1
    error('This method works only for a single GaussMixD object');
end;
S=rand(DiscreteD(pD.MixWeight),nSamples);%random integer sequence, MixWeight distribution
X=zeros(pD.DataSize,nSamples);
for s=1:max(S)
    X(:,S==s)=rand(pD.Gaussians(s),sum(S==s));%get from randomly chosen sub-object
end;