%[S,logP]=viterbi(hmm,x)
%calculates optimal HMM state sequence
%for an observed sequence of (possibly vector-valued) samples,
%for each HMM object in an array of HMM objects.
%
%Input:
%hmm=   array of HMM objects
%x=     matrix with a sequence of observed vectors, stored columnwise
%NOTE:  hmm DataSize must be same as vector length, i.e.
%       get(hmm(i),'DataSize') == size(x,1), for every hmm(i),
%       otherwise probability is ZERO.
%
%Result:
%S=     matrix with best state sequences
%       S(i,t)= best state of hmm(i) for x(:,t)
%       size(S)== [numel(hmm),size(x,2)]
%logP=  column vector with log prob of found best state sequence
%logP(i)= lob P(x, S(i,:) | HMM(i) )
%       logP can be used to compare HMM:s, BUT NOTE
%       logP(i) is NOT log P(x | HMM(i)
%
%Method: for each hmm, calculate logprob for each state, and
%call MarkovChain/viterbi for the actual search algorithm.
%
%Ref:   Arne Leijon (200x): Pattern Recognition.
%  
%Arne Leijon 2009-07-23

function [S,logP]=viterbi(hmm,x)
hmmLength=numel(hmm);%total number of HMM objects in the array
T=size(x,2);%number of vector samples in observed sequence
S=zeros(hmmLength,T);%space for result
logP=zeros(hmmLength,1);
for i=1:hmmLength%for all HMM objects
    if hmm(i).DataSize==size(x,1)
        lPx=logprob(hmm(i).OutputDistr,x);
        [S(i,:),logP(i)]=viterbi(hmm(i).StateGen,lPx);
    else
        warning('HMM:viterbi:WrongDataSize',...
            ['Incompatible DataSize in HMM #',num2str(i)]);%but we can still continue
    end;
end;
