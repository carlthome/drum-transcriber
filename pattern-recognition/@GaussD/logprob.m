%logP=logprob(pD,x) gives log(probability densities) for given vectors
%assumed to be drawn from a given GaussD object
%
%Input:
%pD=    GaussD object or array of GaussD objects
%x=     matrix with given vectors stored columnwise
%
%Result:
%logP=  log(probability densities for x)
%       size(logP)== [numel(pD),size(x,2)]
%exp(logP)=   true probability densities for x
%
%The log representation is useful because the probability densities may be
%extremely small for random vectors with many elements
%  
%Arne Leijon 2005-11-16 tested

function logP=logprob(pD,x)
%pDsize=size(pD);%size of GaussD array
nObj=numel(pD);%number of GaussD objects
nx=size(x,2);%number of observed vectors
logP=zeros(nObj,nx);%space or result
for i=1:nObj%for all GaussD objects in pD
    dSize=length(pD(i).Mean);%GaussD random vector size
    if dSize==size(x,1)%observed vector size OK
        z=pD(i).CovEigen'*(x-repmat(pD(i).Mean,1,nx));%transform to uncorrelated zero-mean elements
        z=z./repmat(pD(i).StDev,1,nx);%and normalized StDev
        logP(i,:)=-sum(z.*z,1)/2;%normalized Gaussian exponent
        logP(i,:)=logP(i,:)-sum(log(pD(i).StDev))-dSize*log(2*pi)/2;%include log(determinant) scale factor
    else
        warning('GaussD:WrongDataSize','Incompatible data size');
        logP(i,:)=repmat(-Inf,1,nx);%zero probability
    end;
end;
%*** reshape removed 2011-05-26, for compatibility. Arne Leijon
% if nObj>1
%     logP=squeeze(reshape(logP,[pDsize,nx]));%restore array format
% end;

