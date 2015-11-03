function betaHat=backward(mc,pX,c)
%betaHat=backward(mc,pX,c)
%calculates scaled observation probabilities,
%using the backward algorithm, for a given single MarkovChain,
%to be used when the MarkovChain is part of a HMM object.
%
%Input:
%mc= MarkovChain object
%pX= matrix with state-conditional likelihood values,
%   without considering the Markov depencence between sequence samples.
%	pX(j,t)= P( X(t)= observed x(t) | S(t)= j )
%	(must be pre-calculated externally)
%   NOTE: pX may be arbitrarily scaled, as defined externally,
%   i.e. it may not be a properly normalized probability density or mass.
%
%c=row vector with observation probabilities, obtained from Forward method:
%	c(t)=P[x(t) | x(1)...x(t-1),HMM]; t=1..T
%	c(1)*c(2)*..c(t)=P[x(1)..x(t)| HMM]
%   If the HMM has Finite Duration, the last element includes
%   the probability that the HMM ended at exactly the given sequence length, i.e.
%   c(T+1)=P( S(T+1)=N+1| x(1)...x(T-1), x(T)  )
%Thus, for an infinite-duration HMM:
%   length(c)=T
%   prod(c)=P( x(1)..x(T) )
%and, for a finite-duration HMM:
%   length(c)=T+1
%   prod(c)=P( x(1)..x(T), S(T+1)=END )
%
%Result:
%betaHat=matrix with scaled backward probabilities:
%	betaHat(j,t)=beta(j,t)/(c(t)*..c(T)), where
%	beta(j,t)=P[x(t+1)...x(T)| S(t)=j] for an infinite-duration HMM without END state
%	beta(j,t)=P[x(t+1)...x(T),S(T+1)=END| S(t)=j] for a finite-duration HMM
%
%NOTE: 
%For an infinite-duration HMM:
%   P[S(t)=j|x(1)..x(T)]= alfaHat(j,t)*betaHat(j,t)*c(t)
%For a finite-duration HMM with separate END state:
%   P[S(t)=j|x(1)..x(T), S(T+1)=END]= alfaHat(j,t)*betaHat(j,t)*c(t)
%
%Ref: Arne Leijon (200x) Pattern Recognition.
%
%Arne Leijon 2007-08-16 tested (changed definition of scale factors)
%           2009-09-29 tested (changed test for finite duration)

% TODO Might have bugs. testHMMGforwBackw.m differs from the course book.

T = size(pX,2); %Number of observations
N = mc.nStates(); % Number of states
q = mc.InitialProb;
A = mc.TransitionProb;

% Preallocate
beta = zeros(N, T);
betaHat = zeros(N, T);

% Initialization
beta(:, T) = ones(N, 1);
betaHat(:, T) = ones(N, 1) / c(T);
if (mc.finiteDuration())
    beta(:, T) = A(:, N+1);
    betaHat(:, T) = beta(:, T) / (c(T) * c(T+1));
end

% Backward steps
for t = T-1:-1:1
    % TODO Try to vectorize the following for-loop for better performance.
    for i = 1:N
        betaHat(i, t) = sum((A(i, 1:end-1)' .* pX(:, t+1) .* betaHat(:, t+1))) / c(t);
    end;
end;

end
