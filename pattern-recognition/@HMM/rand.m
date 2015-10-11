function [X,S]=rand(h,nSamples)
%[X,S]=rand(h,nSamples);generates a random sequence of data
%from a given Hidden Markov Model.
%
%Input:
%h=         HMM object
%nSamples=  maximum no of output samples (scalars or column vectors)
%
%Result:
%X= matrix or row vector with output data samples
%S= row vector with corresponding integer state values
%   obtained from the h.StateGen component.
%   nS= length(S) == size(X,2)= number of output samples.
%   If the StateGen can generate infinite-duration sequences,
%       nS == nSamples
%   If the StateGen is a finite-duration MarkovChain,
%       nS <= nSamples
%
%----------------------------------------------------
%Code Authors:
%----------------------------------------------------

if numel(h)>1
    error('Method works only for a single object');
end;

S = h.StateGen.rand(nSamples);
X = zeros(length(S), h.DataSize);
for i = 1:length(S)
    X(i, :) = h.OutputDistr(S(i)).rand(1)';
end
X = X';
end
