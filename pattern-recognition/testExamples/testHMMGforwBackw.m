%test training of a discrete-valued HMM
%similar to test example in the PattRec course project, year 2008.
%
%Arne Leijon, 2009-07-22

%source model 1
p0=[1 0]';
A=[0.9 0.1 0;0 0.9 0.1];
mc=MarkovChain(p0,A);
pD(1)=GaussD('Mean',0,'StDev',1);
pD(2)=GaussD('Mean',3,'StDev',2);
h=HMM(mc,pD);
nStates=h.nStates
%z=rand(h,50)
x =[-0.2 2.6 1.3 ]
T=length(x);
% [alfaHat,c]=forward(h,z);
% betaHat=backward(h,z);
pX=prob(pD,x);
[alfaHat,c]=forward(mc,pX)
betaHat=backward(mc,pX,c)
gamma=alfaHat.*betaHat.*repmat(c(1:T),nStates,1)
lPHMM=logprob(h,x)
