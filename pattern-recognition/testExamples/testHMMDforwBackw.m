%test training of a discrete-valued HMM
%similar to test example in the PattRec course project, year 2007.
%
%Arne Leijon, 2009-07-22

%source model 1
p0=[1 0]';
A=[0.9 0.1 0;0 0.9 0.1];
B=[0.6 0.3 0.1;0.1 0.3 0.6];
mc=MarkovChain(p0,A);
pD=DiscreteD(B);%eqivalent to
% pD(1)=DiscreteD(B(1,:));%state 1
% pD(2)=DiscreteD(B(2,:));%state 2
h=HMM(mc,pD);
nStates=h.nStates
%z=rand(h,50)
z =[1 3 2 ]
T=length(z);
% [alfaHat,c]=forward(h,z);
% betaHat=backward(h,z);
pZ=prob(pD,z);
[alfaHat,c]=forward(mc,pZ)
betaHat=backward(mc,pZ,c)
gamma=alfaHat.*betaHat.*repmat(c(1:T),nStates,1)

% %compare with old HMMD routines
% [alfaHatOLD, cOLD]=HMMDforward(A,B,p0,z)
% betaHatOLD=HMMDbackward(A,B,p0,z,cOLD)
% alfaHat-alfaHatOLD
% betaHat-betaHatOLD
% c-cOLD
% 
