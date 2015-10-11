%aS=adaptStart(mc)
%   initialises adaptation data structure,
%   to be saved externally between subsequent calls to method adaptAccum.
%
%Input:
%mc= single MarkovChain object
%
%Result:
%aS= initialised adaptation data structure.
%
%Arne Leijon 2004-11-10 tested

function aS=adaptStart(mc)
aS.pI=zeros(size(mc.InitialProb));%for sum of P[S(1)=j | each training sub-sequence]
aS.pS=zeros(size(mc.TransitionProb));%for sum of P[S(t)=i & S(t+1)=j | all training data]
