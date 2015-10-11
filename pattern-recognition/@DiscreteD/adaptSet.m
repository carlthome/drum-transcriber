%pD=adaptSet(pD,aState)
%method to finally adapt a DiscreteD object
%using accumulated statistics from observed data.
%
%Input:
%pD=        DiscreteD object or array of such objects
%aState=    accumulated statistics from previous calls of adaptAccum
%
%Result:
%pD=        adapted version of the DiscreteD object
%
%Theory and Method:    
%From observed sample data X(n), n=1....N, we are using the 
%accumulated sum of relative weights (relative frequencies)
%
%We have an accumulated weight (column) vector
%sumWeight, with one element for each observed integer value of Z=round(X):
%sumWeight(z)= sum[w(z==Z(n))]
%
%Arne Leijon 2011-08-29, tested
%            2012-06-12, modified use of PseudoCount

function pD=adaptSet(pD,aState)
for i=1:numel(pD)%for all objects in the array
    aState(i).sumWeight=aState(i).sumWeight+pD(i).PseudoCount;%/length(aState(i).sumWeight);
    %Arne Leijon, 2012-06-12: scalar PseudoCount added to each sumWeight element
    %Reasonable, because a Jeffreys prior for the DiscreteD.Weight is
    %equivalent to 0.5 "unobserved" count for each possible outcome of the DiscreteD.
    pD(i).ProbMass=aState(i).sumWeight;%direct ML estimate
%    pD(i).ProbMass=pD(i).ProbMass./sum(pD(i).ProbMass);%normalize probability mass sum
%   normalized by DiscreteD.set.ProbMass
end;



