%pD=init(pD,x);
%initializes a GaussMixD object or array of such objects
%to conform with a set of given observed vectors.
%The agreement is very crude, and should be refined by training,
%using methods adaptStart, adaptAccum, and adaptSet.
%
%Input:
%pD=    a single GaussMixD object or array of such objects
%x=     matrix with observed vectors stored columnwise
%
%Result:
%pD=    initialized GaussMixD object or multidim GaussMixD array
%       size(pD)== same as input
%
%Method:
%For a single GaussMixD object: let its Gaussians sub-object do it.
%For a GaussMixD array: First init a GaussD array, then split each cluster.
%This initialization is crude, and should be refined by training.
%  
%Arne Leijon 2006-04-21 tested
%           2011-05-26 minor cleanup

function pD=init(pD,x)
nObj=numel(pD);
if nObj>0.5*size(x,2)
    error('Too few data vectors');end;%***reduce nObj instead???

if nObj==1
    pD.Gaussians=init(pD.Gaussians,x);%let Gaussians do it
    nGaussians=length(pD.Gaussians);
    pD.MixWeight=ones(nGaussians,1)./nGaussians;%equal mixweights
else
    %make a single Gaussians array, and then split each GaussD
    g=init(repmat(GaussD,nObj,1),x);%single GaussD at each cluster
    [~,bestG]=max(prob(g,x));%assign each data point to nearest GaussD
    for i=1:nObj
        [pD(i).Gaussians,iOK]=init(pD(i).Gaussians,x(:,bestG==i));%use only nearest data
        if any(~iOK)
            %delete Gaussians(i) where iOK(i)==0, because of too few data
            pD(i).Gaussians=pD(i).Gaussians(iOK==1);
            warning('GaussMixD:Init:ReducedSize',...
                ['GaussMixD no.',num2str(i),' reduced to ',num2str(length(pD(i).Gaussians)),' components']);
        end;        
        nGaussians=length(pD(i).Gaussians);%number of sub-objects in this mix
        pD(i).MixWeight=ones(nGaussians,1)./nGaussians;%equal mixweights
    end;
end;