%hmm=adaptSet(hmm,aState)
%method to finally adapt a single HMM object
%using accumulated statistics from observed training data sets.
%
%Input:
%hmm=       single HMM object
%aState=    accumulated statistics from previous calls of adaptAccum
%
%Result:
%hmm=       adapted version of the HMM object
%
%Theory and Method:    
%
%Arne Leijon 2009-07-23 tested

function hmm=adaptSet(hmm,aState)%just dispatch to sub-objects
hmm.StateGen=adaptSet(hmm.StateGen,aState.MC);
hmm.OutputDistr=adaptSet(hmm.OutputDistr,aState.Out);