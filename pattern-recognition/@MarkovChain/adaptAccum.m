%[aState,gamma,lP]=adaptAccum(mc,aState,pX)
%method to adapt a single MarkovChain object to observed data,
%by accumulating sufficient statistics from the data,
%for later updating of the object by method adaptSet.
%
%Usage:
%First obtain the storage data structure aState from method adaptStart.
%Then, adaptAccum can be called several times with different observation data subsets.
%The aState data structure must be saved externally between calls to adaptAccum.
%Finally, the MarkovChain object is updated by method adaptSet.
%
%Input:
%mc=        single MarkovChain object
%pX=        matrix prop. to state-conditional observation probabilites, calculated externally,
%pX(j,t)=   ScaleFactor* P( X(t)= observed x(t) | S(t)= j ); j=1..N; t=1..T
%	        Must be pre-calculated externally.
%           ScaleFactor is known only externally
%aState=    accumulated adaptation state from previous calls
%
%Result:
%aState=    accumulated adaptation state, incl. this step,
%           must be saved externally until next call
%aState.pI= accumulated sum of P[S(1)=j | each training sub-sequence]
%aState.pS= accumulated sum of P[S(t)=i & S(t+1)=j | all training data]
%gamma=     conditional state probability matrix, with elements
%gamma(i,t)=P[ S(t)= i | pX for complete observation sequence]
%           returned for external use.
%lP=        scalar log(Prob(observed sequence)),
%           for external use, to save computation.
%           (NOT including external ScaleFactor of given pX)
%
%Method:    Results of forward-backward algorithm
%           are combined with Baum-Welch update rules.
%
%Ref:       Arne Leijon (200x): Pattern Recognition
%           Rabiner (1989): Tutorial on HMM. Proc IEEE, 77, 257-286.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Elegant solution provided by Niklas Bergstrom, 2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [aState,gamma,lP]=adaptAccum(mc,aState,pX)
T=size(pX,2);
nStates=mc.nStates;%Arne Leijon, 2011-08-03
% Fetch variables from the markov chain
A=mc.TransitionProb;

% Get the scaled forward and backward variables
[alfaHat c] = forward(mc,pX);
betaHat = backward(mc,pX,c);

% Calculate gamma
gamma = alfaHat.*betaHat.*repmat(c(1:T),nStates,1);

% Initial probabilities, aState.pI += gamma(t=1)
aState.pI = aState.pI + gamma(:,1);

% Calculate xi for the current sequence r
% xi(i,j,t) = alfaHat(i,t)*A(i,j)*pX(j,t+1)*betaHat(j,t+1)
% First it's possible to multiply pX and betaHat element wise since they
% correspond to each other
pXbH = pX(:,2:end).*betaHat(:,2:end);
% Then multiply alfaHat with the transpose of the result in order to get
% a matrix of size nStates x nStates with each element summed over t
aHpXbH = alfaHat(:,1:T-1)*pXbH';
% Finally multiply element wise with the previous transition probabilities
xi = aHpXbH.*A(:,1:nStates);
% Add the result to the accumulating variable, aState.pS += xi
aState.pS(:,1:nStates) = aState.pS(:,1:nStates) + xi;

% For finite duration HMM
if(finiteDuration(mc))
   aState.pS(:,nStates+1) = aState.pS(:,nStates+1) + alfaHat(:,T).*betaHat(:,T)*c(T);
end
% Calculate log probability for observing the current sequence given the
% current hmm
lP = sum(log(c));%scalar sum
