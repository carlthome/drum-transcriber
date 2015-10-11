%aState=adaptAccum(pD,aState,obsData,obsWeight)
%method to adapt GaussD object to observed data,
%by accumulating sufficient statistics from the data,
%for later updating of the object by method adaptSet.
%
%Usage:
%First obtain the storage data structure aState from method adaptStart.
%Then, adaptAccum can be called several times with different observation data subsets.
%The aState data structure must be saved externally between calls to adaptAccum.
%Finally, the GaussD object is updated by method adaptSet.
%
%Input:
%pD=        a GaussD object or multidim array of GaussD objects
%obsData=   matrix with observed column vectors,
%           each assumed to be drawn from one of the GaussD objects
%obsWeight= (optional) matrix with weight factors, one column for each vector in obsData,
%           and one row for each object in the GaussD array.
%           size(obsWeight)== [length(pD(:)), size(obsData,2)]
%           obsWeight must have consistent values for all calls.
%           No obsWeight given <=> all weights=1.
%aState=    accumulated adaptation state preserved from previous calls,
%           first obtained from method adaptStart
%
%Result:
%aState=    accumulated adaptation data, incl. this observation data set.
%
%Arne Leijon 2005-11-16 NOT tested for full covariance matrix

function aState=adaptAccum(pD,aState,obsData,obsWeight)
[dSize,nData]=size(obsData);%dataSize, number of given vector samples
nObj=numel(pD);%n of GaussD objects in array
if nargin<4%no external obsWeight given
    if nObj==1
        obsWeight=ones(nObj,nData);%use all data with equal weight
    else
        obsWeight=prob(pD,obsData);%assign weight to each GaussD object
        obsWeight=obsWeight./repmat(sum(obsWeight),nObj,1);%normalize
        %obsWeight(i,t)= P(objS(t)= i | X(t))
    end;
end;
for i=1:nObj%for all GaussD objects
    Dev=obsData-repmat(pD(i).Mean,1,nData);%deviations from old mean
    wDev=Dev.*repmat(obsWeight(i,:),dSize,1);%weighted -"-
    aState(i).sumDev=aState(i).sumDev+sum(wDev,2);%for later mean estimationz
    aState(i).sumSqDev=aState(i).sumSqDev+Dev*wDev';%for later covar. estim.
    aState(i).sumWeight=aState(i).sumWeight+sum(obsWeight(i,:));
end;



