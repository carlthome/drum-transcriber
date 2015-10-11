%R=rand(pD,nData) returns random vectors drawn from a single GaussD object.
%
%Input:
%pD=    the GaussD object
%nData= scalar defining number of wanted random data vectors
%
%Result:
%R= matrix with data vectors drawn from object pD
%   size(R)== [length(pD.Mean), nData]
%
%Arne Leijon 2005-11-16 tested
%           2006-04-18 sub-state output added for compatibility
%           2009-07-20 sub-state output removed again

%function [R,U]=rand(pD,nData)%OLD version
function R=rand(pD,nData)
if length(pD)>1
    error('This method works only for a single GaussD object');
end;
R=randn(length(pD.Mean),nData);%normalized independent Gaussian random variables
% if nargout>1
%     U=zeros(1,nData);end;%GaussD has no sub-states
R=diag(pD.StDev)*R;%scaled to correct standard deviations
R=pD.CovEigen*R;%rotate to proper correlations
R=R+repmat(pD.Mean,1,nData);%translate to desired mean