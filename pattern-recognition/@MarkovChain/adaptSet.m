%mc=adaptSet(mc,aState)
%method to finally adapt a single MarkovChain object
%using accumulated statistics from observed training data sets.
%
%Input:
%mc=        single MarkovChain object
%aState=    struct with accumulated statistics from previous calls of adaptAccum
%
%Result:
%mc=        adapted version of the MarkovChain object
%
%Method:
%We have accumulated, in aState:
%pI=        vector of initial state probabilities, with elements
%   pI(i)=  scalefactor* P[S(1)=i | all training sub-sequences]
%pS=        state-pair probability matrix, with elements
%   pS(i,j)=scalefactor* P[S(t)=i & S(t+1)=j | all training data]
%These data directly define the new MarkovChain, after necessary normalization.
%
%Ref:       Arne Leijon (20xx) Pattern Recognition, KTH-SIP
%
%Arne Leijon 2004-11-10 tested
%            2011-08-02 keep sparsity

function mc=adaptSet(mc,aState)
if issparse(mc.InitialProb)%keep the sparsity structure
    mc.InitialProb=sparse(aState.pI./sum(aState.pI));%normalised
else
    mc.InitialProb=aState.pI./sum(aState.pI);%normalised
end;
if issparse(mc.TransitionProb)%keep the sparsity structure
    mc.TransitionProb=sparse(aState.pS./repmat(sum(aState.pS,2),1,size(aState.pS,2)));%normalized
else
    mc.TransitionProb=aState.pS./repmat(sum(aState.pS,2),1,size(aState.pS,2));%normalized
end;
end