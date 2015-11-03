function [alfaHat, c]=forward(mc,pX)
%[alfaHat, c]=forward(mc,pX)
%calculates state and observation probabilities for one single data sequence,
%using the forward algorithm, for a given single MarkovChain object,
%to be used when the MarkovChain is included in a HMM object.
%
%Input:
%mc= single MarkovChain object
%pX= matrix with state-conditional likelihood values,
%   without considering the Markov depencence between sequence samples.
%	pX(j,t)= myScale(t)* P( X(t)= observed x(t) | S(t)= j ); j=1..N; t=1..T
%	(must be pre-calculated externally)
%NOTE: pX may be arbitrarily scaled, as defined externally,
%   i.e., pX may not be a properly normalized probability density or mass.
%
%NOTE: If the HMM has Finite Duration, it is assumed to have reached the end
%after the last data element in the given sequence, i.e. S(T+1)=END=N+1.
%
%Result:
%alfaHat=matrix with normalized state probabilities, given the observations:
%	alfaHat(j,t)=P[S(t)=j|x(1)...x(t), HMM]; t=1..T
%c=row vector with observation probabilities, given the HMM:
%	c(t)=P[x(t) | x(1)...x(t-1),HMM]; t=1..T
%	c(1)*c(2)*..c(t)=P[x(1)..x(t)| HMM]
%   If the HMM has Finite Duration, the last element includes
%   the probability that the HMM ended at exactly the given sequence length, i.e.
%   c(T+1)= P( S(T+1)=N+1| x(1)...x(T-1), x(T)  )
%Thus, for an infinite-duration HMM:
%   length(c)=T
%   prod(c)=P( x(1)..x(T) )
%and, for a finite-duration HMM:
%   length(c)=T+1
%   prod(c)= P( x(1)..x(T), S(T+1)=END )
%
%NOTE: IF pX was scaled externally, the values in c are
%   correspondingly scaled versions of the true probabilities.
%
%--------------------------------------------------------
%Code Authors:
%--------------------------------------------------------

T = size(pX,2); %Number of observations
N = mc.nStates(); % Number of states
q = mc.InitialProb;
A = mc.TransitionProb;

% Preallocate
alfaTemp = zeros(N, T);
c = zeros(1, T);
alfaHat = zeros(N, T);

% Initialization
alfaTemp(:, 1) = q(:, 1) .* pX(:, 1);
c(1) = sum(alfaTemp(:, 1));
alfaHat(:, 1) = alfaTemp(:, 1) / c(1);

% Forward steps
for t = 2:T
    % TODO Try to vectorize the following for-loop for better performance.
    for j = 1:N
        alfaTemp(j, t) = pX(j, t) * sum(A(:, j) .* alfaHat(:, t-1));
    end;
    c(t) = sum(alfaTemp(:, t));
    alfaHat(:, t) = alfaTemp(:, t) / c(t);
end;

% Finite? Add step
if (mc.finiteDuration())
    c(end+1) = sum(alfaHat(:, T) .* A(:, N+1));
end

end
