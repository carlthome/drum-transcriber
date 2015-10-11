%aState=adaptStart(pD)
%starts DiscreteD object adaptation to observed data,
%by initializing accumulator data structure for sufficient statistics,
%to be used in subsequent calls to method adaptAccum and adaptSet.
%
%Input:
%pD=        DiscreteD object or array of such objects
%
%Result:
%aState=    data structure to be used by methods adaptAccum and adaptSet.
%
%Theory is discussed in method adaptSet
%
%Arne Leijon 2005-10-25 tested

function aState=adaptStart(pD)
nObj=numel(pD);
aState=repmat(struct('sumWeight',0),nObj,1);%init storage
% for i=1:nObj%one storage set for each object in the array
%     aState(i).sumWeight=0;%sum of all weight factors, already zeroed
% end;
