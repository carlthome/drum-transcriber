%logP=logprob(hmm,x) gives conditional log(probability densities)
%for an observed sequence of (possibly vector-valued) samples,
%for each HMM object in an array of HMM objects.
%This can be used to compare how well HMMs can explain data from an unknown source.
%
%Input:
%hmm=   array of HMM objects
%x=     matrix with a sequence of observed vectors, stored columnwise
%NOTE:  hmm DataSize must be same as observed vector length, i.e.
%       hmm(i).DataSize == size(x,1), for each hmm(i).
%       Otherwise, the probability is, of course, ZERO.
%
%Result:
%logP=  array with log probabilities of the complete observed sequence.
%logP(i)=   log P[x | hmm(i)]
%           size(logP)== size(hmm)
%
%The log representation is useful because the probability densities
%exp(logP) may be extremely small for random vectors with many elements
%
%Method: run the forward algorithm with each hmm on the data.
%
%Ref:   Arne Leijon (20xx): Pattern Recognition.
%
%----------------------------------------------------
%Code Authors:
%----------------------------------------------------

function logP=logprob(hmms, x)

% Calculate forward probability per HMM.
logP = zeros(size(hmms));
for i=1:length(hmms)
    
    % Evaluate every observation in every state's PDF.
    [pX, logS] = hmms(i).OutputDistr.prob(x);
    
    % Forward algorithm for the HMM.
    [~, c] = forward(hmms(i).StateGen, pX);
    
    % TODO Remove.
    if isnan(sum(c))
        break;
    end;
    
    % Calculate probability of seeing the complete observed sequence.
    logP(i) = sum(log(c(1:end-1)) + logS);
    
    % For finite duration, include probability of being in exit state.
    if hmms(i).StateGen.finiteDuration()
        logP(i) = logP(i) + log(c(end));
    end
end;
end
