%lP=logprob(mc, S)
%calculates log probability of complete observed state sequence
%
%Input:
%mc=    the MarkovChain object(s)
%S=     row vector with integer state-index sequence.
%       For a finite-duration Markov chain, 
%       S(end) may or may not be the END state flag = nStates+1.
%
%Result:
%lP=    vector with log probabilities
%       length(lP)== numel(mc)
%
%Arne Leijon, 2009-07-23

function lP=logprob(mc, S)
    if isempty(S)
        lP=[];
        return;
    end;
    if any(S<0) || any(S ~= round(S)) %not a proper index vector
        lP=repmat(-Inf,size(mc));
        return;
    end
    lP=zeros(size(mc));%space
    fromS=S(1:end-1);%from S(t)
    toS=S(2:end);%to S(t+1)
    for i=1:numel(mc)
        if S(1)>length(mc(i).InitialProb)
            lP(i)=-Inf;%non-existing initial state index
        else
            lP(i)=log(mc(i).InitialProb(S(1)));%Initial state
        end;
        if ~isempty(fromS)
            if max(fromS)> mc(i).nStates || S(end)>size(mc(i).TransitionProb,2)
                lP(i)=-Inf;%encountered a non-existing state index
            else
                iTrans=sub2ind(size(mc(i).TransitionProb),fromS,toS);
                lP(i)=lP(i)+sum(log(mc(i).TransitionProb(iTrans)));
            end;
        end;
    end   
end
