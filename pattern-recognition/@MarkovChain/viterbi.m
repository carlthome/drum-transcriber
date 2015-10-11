function [optS,logP]=viterbi(mc,logpX)
%[optS,logP]=viterbi(mc,logpX)
%calculates optimal state sequence in a Markov Chain
%for an observed sequence of log(state probability) values.
%
%Input:
%mc=    a single MarkovChain object
%logpX= matrix with a sequence of state log-prob, stored columnwise.
%       logpX(i,t) = log P( obs(t) | S(t)=i)
%
%Result:
%optS=  row vector with most probable state sequence, given the observations:
%optS=  argmax{j1..jT}(P[O(1)...O(T),S(1)=j1..S(T)=jT|HMM]
%logP=  log P[O(1)...O(T),S(1)=optS(1)..S(T)=optS(T)|HMM]
%       S(i,t)= best state of hmm(i) for x(:,t)
%       size(S)== [numel(hmm),size(x,2)]
%
%Ref:   Arne Leijon (20xx): Pattern Recognition.
%  
%Arne Leijon, 2007-05-05 not much tested
%Arne Leijon, 2012-03-18 CORRECTED to include transition to END state
%                       in case of finite-duration HMM
%**** how improve, if TransProb is sparse?

T=size(logpX,2);%N of observations
nStates=size(mc.TransitionProb,1);
lTransProb=log(mc.TransitionProb);% = -Inf for impossible transitions
lA=lTransProb(:,1:nStates);%use only square part, in case of finite-duration chain

backPointer=zeros(nStates,T);%from each state S(t) to best previous S(t-1) 
optS=zeros(1,T);%space for optimal state sequence

D=log(mc.InitialProb)+logpX(:,1);%init delta=log P[S(1),O(1)|HMM]
for t=2:T
	[D,iD]=max(repmat(D,1,nStates)+lA);%iD(j)=argmax{i}(log P[S(t-1)=i,S(t)=j,O(1)..O(t-1)|HMM])
	D=D'+logpX(:,t);%D(j)=max{i1..i(t-1)}(log P[S(1)=i1..S(t)=j,O(1)..O(t)|HMM])
	backPointer(:,t)=iD';
end;
%now D(j)=max{i1..i(T-1)}(log P[S(1)=i1..S(T)=j,O(1)..O(T)|HMM])
if mc.finiteDuration% include transition to S(T+1)= END state= nStates+1
    D=D+lTransProb(:,nStates+1);
    %now D(j)=max{i1..i(T-1)}(log P[S(1)=i1..S(T)=j,S(T+1)=END,O(1)..O(T)|HMM])
end;
%backtracking:
[logP,iD]=max(D);
optS(T)=iD;%best final state
for t=T-1:-1:1
	optS(t)=backPointer(optS(t+1),t+1);
end;
