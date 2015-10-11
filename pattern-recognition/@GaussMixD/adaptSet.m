%pD=adaptSet(pD,aState)
%method to finally adapt a GaussMixD object
%using accumulated statistics from observed data.
%
%Input:
%pD=        GaussMixD object or array of GaussD objects
%aState=    accumulated statistics from previous calls of adaptAccum
%
%Result:
%pD=        adapted version of the GaussMixD object
%
%Theory and Method:    
%The sub-object GaussD array pD(i).Gaussians has its own adaptSet method.
%In addition, this method adjusts the pD(i).MixWeight vector,
%   simply by normalizing the accumulated sum of MixWeight vectors,
%   for the observed data.
%
%References:
%   Leijon (200x). Pattern Recognition
%   Bilmes (1998). A gentle tutorial of the EM algorithm.
%
%Arne Leijon 2004-11-15 tested

function pD=adaptSet(pD,aState)
for i=1:numel(pD)%for all GaussMixD objects
    pD(i).Gaussians=adaptSet(pD(i).Gaussians,aState(i).Gaussians);%sub-GaussD sets itself
    pD(i).MixWeight=aState(i).MixWeight./sum(aState(i).MixWeight);%set normalized MixWeight
end;%easy!!!



