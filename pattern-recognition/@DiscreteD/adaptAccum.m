%aState=adaptAccum(pD,aState,obsData,obsWeight)
%method to adapt DiscreteD object, or object array, to observed data,
%by accumulating sufficient statistics from the data,
%for later updating of the object by method adaptSet.
%
%Usage:
%First obtain the storage data structure aState from method adaptStart.
%Then, adaptAccum can be called several times with different observation data subsets.
%The aState data structure must be saved externally between calls to adaptAccum.
%Finally, the DiscreteD object is updated by method adaptSet.
%
%Input:
%pD=        a DiscreteD object or multidim array of DiscreteD objects
%obsData=   row vector with observed scalar samples,
%           each assumed to be drawn from one of the DiscreteD objects
%obsWeight= (optional) matrix with weight factors, one column for each sample in obsData,
%           and one row for each object in the DiscreteD array.
%           size(obsWeight)== [length(pD(:)), size(obsData,2)]
%           obsWeight must have consistent values for all calls.
%           No obsWeight given <=> all weights=1.
%aState=    accumulated adaptation state preserved from previous calls,
%           first obtained from method adaptStart
%
%Result:
%aState=    accumulated adaptation data, incl. this observation data set.
%
%Arne Leijon 2011-08-29 tested

function aState=adaptAccum(pD,aState,obsData,obsWeight)
if size(obsData,1) > 1
    error('DiscreteD object: only scalar data');
end;
obsData=round(obsData);%quantize to integer values
if min(obsData)<1
    error('Data samples out of range');
end;
maxObs=max(obsData);
nData=size(obsData,2);%number of given samples
nObj=numel(pD);%n of objects in array
if nargin<4%no external obsWeight given
   obsWeight=ones(nObj,nData);%use all data with equal weight
   if nObj>1
        warning('Several DiscreteD objects with same training data?');
   end;
end;

for i=1:nObj%for all objects
    maxM=max(maxObs,length(pD(i).ProbMass));
    M=size(aState(i).sumWeight,1);%previous max observed data value
    if M<maxM
        aState(i).sumWeight=[aState(i).sumWeight;zeros(maxM-M,1)];%extend size as needed
    end;
    for m=1:maxM%each possible observed value
        aState(i).sumWeight(m)=aState(i).sumWeight(m)+sum(obsWeight(i,obsData==m),2);
    end;
end;



