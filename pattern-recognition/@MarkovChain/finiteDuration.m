%fd=finiteDuration(mc)
%   tests if a given MarkovChain object has finite duration.
%
%Input:
%mc= single MarkovChain object
%
%Result:
%fd= true, if duration is finite.
%
%Arne Leijon 2009-07-19 tested

function fd=finiteDuration(mc)
fd=size(mc.TransitionProb,2)==size(mc.TransitionProb,1)+1;%first condition
if fd
    %we use full() just because left-right TransitionProb may be stored as sparse)
    fd=full(sum(mc.TransitionProb(:,end)))>0;
end;
