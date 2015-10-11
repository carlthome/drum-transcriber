%aState=adaptStart(pD)
%starts GaussD object adaptation to observed data,
%by initializing accumulator data structure for sufficient statistics,
%to be used in subsequent calls to method adaptAccum and adaptSet.
%
%Input:
%pD=        GaussD object or array of GaussD objects
%
%Result:
%aState=    data structure to be used by methods adaptAccum and adaptSet.
%
%Theory is discussed in method adaptSet
%
%Arne Leijon 2005-11-16 tested

function aState=adaptStart(pD)
nObj=numel(pD);
aState=repmat(struct('sumDev',0,'sumSqDev',0,'sumWeight',0),nObj,1);%init storage
for i=1:nObj%one storage set for each object in the array
    dSize=length(pD(i).Mean);
    aState(i).sumDev=zeros(dSize,1);%weighted sum of observed deviations from OLD mean
    aState(i).sumSqDev=zeros(dSize,dSize);%matrix with sum of square deviations from OLD mean
    aState(i).sumWeight=0;%sum of weight factors
end;
