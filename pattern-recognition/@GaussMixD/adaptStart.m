%aState=adaptStart(pD)
%starts GaussMixD object adaptation to observed data,
%by initializing accumulator data structure for sufficient statistics,
%to be used in subsequent calls to method adaptAccum and adaptSet.
%
%Input:
%pD=        GaussMixD object or array of GaussD objects
%
%Result:
%aState=    data structure to be used by methods adaptAccum and adaptSet.
%
%Theory is discussed in method adaptSet
%
%Arne Leijon 2004-11-18 tested

function aState=adaptStart(pD)
for i=1:prod(size(pD))%one storage set for each object in the array
    aState(i).Gaussians=adaptStart(pD(i).Gaussians);%to adapt sub-object
    aState(i).MixWeight=zeros(size(pD(i).MixWeight));%
end;
