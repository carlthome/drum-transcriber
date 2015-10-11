%logP=logprob(pD,x) gives log(probability densities) for given vectors
%assumed to be drawn from a given GaussMixD object
%
%Input:
%pD=    GaussMixD object or array of such objects
%x=     matrix with given vectors stored columnwise
%
%Result:
%logP=  log(probability densities for x)
%       size(logP)== [numel(pD),size(x,2)]
%exp(logP)=   true probability densities for x
%
%The log representation is useful because the probability densities may be
%extremely small for random vectors with many elements
%
%Arne Leijon 2004-11-15 tested
%           2011-05-24, more robust version, tested

function logP=logprob(pD,x)
%pDsize=size(pD);%size of GaussMixD array
nObj=numel(pD);%number of GaussMixD objects
nx=size(x,2);%number of observed vectors
logP=zeros(nObj,nx);
for n=1:nObj
    logPn=logprob(pD(n).Gaussians,x);%prob from all sub-Gaussians
    logS=max(logPn);
    %if length(pD(n).Gaussians)==1, logS is scalar, otherwise
    %size(logS)==[1,nx]; might be -Inf or +Inf at some places
    logPn=bsxfun(@minus,logPn,logS);%=logPn-logS expanded to matching size
    %logPn(k,t) may be NaN for some k, if logS(t)==-Inf, or logS(t)==+Inf
    logPn(isnan(logPn(:)))=0;%corrected
    logP(n,:)=logS+log(pD(n).MixWeight'*exp(logPn));
    %may be +Inf or -Inf at some places, but this is OK
end;
end