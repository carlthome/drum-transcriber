%[aState,logP]=adaptAccum(hmm,aState,obsData)
%method to adapt a single HMM object to observed data,
%by accumulating sufficient statistics from the data,
%for later updating of the object by method adaptSet.
%
%Usage:
%First obtain the storage data structure aState from method adaptStart.
%Then, adaptAccum can be called several times with different observation data subsets.
%The aState data structure must be saved externally between calls to adaptAccum.
%Finally, the HMM object is updated by method adaptSet.
%
%Input:
%hmm=       a single HMM object
%obsData=   matrix with a sequence of data vectors, stored columnwise,
%           supposed to be drawn from this HMM. 
%aState=    accumulated adaptation state from previous calls
%
%Result:
%aState=    accumulated adaptation state, incl. this subset of observed data,
%           must be saved externally until next call
%logP=      accumulated log( P(obsData | hmm) )
%           may be used externally as training stop criterion.
%
%Method:    Obtain from sub-object OutputDistr separate observation probabilities
%           These are used by sub-object StateGen, which also provides
%           conditional state probabilities, given whole obs.sequence.
%           These are then used as weights to adapt OutputDistr.
%
%Arne Leijon 2009-07-23 tested
%           2011-05-26, generalized prob method

function [aState,logP]=adaptAccum(hmm,aState,obsData)
% if length(hmm)>1%enough to test this in adaptStart!
%     error('Method works only for a single object');end;

[pX,lScale]=prob(hmm.OutputDistr,obsData);%scaled obs.probabilities
%pX(i,t)*exp(lScale(t)) == P[obsData(:,t) | hmm.OutputDistr(i)]
[aState.MC,gamma,logP]=adaptAccum(hmm.StateGen,aState.MC,pX);
%gamma(i,t)=P[HMMstate(t)=j | obsData, hmm]; obtained as side-result to save computation
aState.Out=adaptAccum(hmm.OutputDistr,aState.Out,obsData,gamma);
if length(lScale)==1%can happen only if length(hmm.OutputDistr)==1
    aState.LogProb=aState.LogProb+logP+size(obsData,2)*lScale;%=accum. logprob(hmm,obsData)
else
    aState.LogProb=aState.LogProb+logP+sum(lScale);%=accum. logprob(hmm,obsData)
end;
logP=aState.LogProb;%return separately, for external code clarity


