%test training of a discrete-valued HMM
%similar to test example in the PattRec course project.

%source model 1
mc=MarkovChain([1 0],[0.9 0.1 0;0 0.9 0.1]);
pD(1)=DiscreteD([0.1 0.2 0.6]);%state 1
pD(2)=DiscreteD([0.6 0.3 0.1]);%state 2
%h(1)=HMM('MarkovChain',mc,'OutputDistr',pD);
h(1)=HMM(mc,pD);
%source model 2
mc=MarkovChain([1 0],[0.95 0.05 0;0 0.8 0.2]);
pD(1)=DiscreteD([0.2 0.6 0.2]);%state 1
pD(2)=DiscreteD([0.4 0.2 0.4]);%state 2
%h(2)=HMM('MarkovChain',mc,'OutputDistr',pD);
h(2)=HMM(mc,pD);
%test models:
for r=1:5
    zTest1=rand(h(1),1000);
    zTest2=rand(h(2),1000);
    test1=logprob(h,zTest1)
    test2=logprob(h,zTest2)
end;
