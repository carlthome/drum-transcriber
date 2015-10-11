%aState=adaptStart(hmm)
%   initialises adaptation data structure for a single HMM object,
%   to be saved between subsequent calls to method adaptAccum.
%
%Input:
%hmm=       single HMM object
%
%Result:
%aState=    struct representing zero weight of previous observed data,
%           with fields
%aState.MC  for the StateGen sub-object
%aState.Out for the OutputDistr sub-object
%aState.LogProb for accumulated log(prob(observations))
%
%Arne Leijon 2009-07-23 tested

function aState=adaptStart(hmm)
if length(hmm)>1
    error('Method works only for a single object');end;
aState.MC=adaptStart(hmm.StateGen);%data to adapt the MarkovChain
aState.Out=adaptStart(hmm.OutputDistr);%data to adapt the OutputDistr
aState.LogProb=0;%to store accumulated observation logprob, to use as stop crit

