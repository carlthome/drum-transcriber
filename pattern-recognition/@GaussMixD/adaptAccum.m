%aState=adaptAccum(pD,aState,obsData,obsWeight)
%method to adapt array of GaussMixD objects to observed data,
%by accumulating sufficient statistics from the data,
%for later updating of the object by method adaptSet.
%
%Usage:
%First obtain the storage data structure aState from method adaptStart.
%Then, adaptAccum can be called several times with different observation data subsets.
%The aState data structure must be saved externally between calls to adaptAccum.
%Finally, the GaussMixD object(s) are updated by method adaptSet.
%
%Input:
%pD=        a GaussMixD object or multidim array of GaussMixD objects
%aState=    accumulated adaptation state preserved from previous calls,
%           first obtained from method adaptStart
%obsData=   matrix with observed column vectors,
%           each assumed to be drawn from one of the GaussMixD objects
%obsWeight= (optional) matrix with weight factors, one column for each vector in obsData,
%           and one row for each object in the GaussMixD array
%           size(obsWeight)== [length(pD(:)), size(obsData,2)]
%           obsWeight(i,t)= prop to P( GaussMixD(t)=i | obsData)
%           obsWeight must have consistent values for all calls.
%
%Result:
%aState=    accumulated adaptation data, incl. this observation data set.
%
%Arne Leijon 2005-02-14 tested
%           2006-04-12 fixed bug for case with only one mix component
%           2009-10-11 fixed bug with component sub-probabilities

function aState=adaptAccum(pD,aState,obsData,obsWeight)
nData=size(obsData,2);%number of given vector samples
nObj=numel(pD);%n of GaussMixD objects in array
if nargin<4%no external obsWeight given
    if nObj==1
        obsWeight=ones(nObj,nData);%use all data with equal weight
    else
        obsWeight=prob(pD,obsData);%assign weight to each GaussMixD object
        obsWeight=obsWeight./repmat(sum(obsWeight),nObj,1);
        %obsWeight(i,t)= P(mixS(t)= i | obsData)= P(GaussMixD(i)-> X(t))
    end;
end;
for i=1:nObj%for all GaussMixD objects
    %***find sub-Object probabilities for each mixed GaussD
    %can be done instead by the sub-Object itself ??????
    %NO, because sub-Object also needs our obsWeight
    nSubObj=length(pD(i).Gaussians);
    if nSubObj==1%no need for extra computation
        aState(i).Gaussians=adaptAccum(pD(i).Gaussians,aState(i).Gaussians,obsData,obsWeight(i,:));
        aState(i).MixWeight=aState(i).MixWeight+sum(obsWeight(i,:),2);        
    else
        subProb=prob(pD(i).Gaussians,obsData);%saved from previous call instead???
        %subProb(j,t)=P(X(t)=obsData(:,t) | subS(t)=j & mixS(t)=i )
        %***** should include previous MixWeight here??? 2009-10-08
        subProb=diag(pD(i).MixWeight)*subProb;%fix Arne Leijon, 2009-10-11
        %subProb(j,t)=P(X(t)=obsData(:,t) & subS(t)=j | mixS(t)=i )
%**** testGMM3 actually works much better without previous MixWeight!
%**** with corrected version it usually gets stuck in local maximum,
%**** but this is probably because the true MixWeights were equal,
%**** so it was better to ignore the estimated MixWeight in this case.
        denom=max(realmin,sum(subProb,1));%2005-02-14: avoid division by zero in next statement
        subProb=subProb./repmat(denom,nSubObj,1);%normalize to conditional prob.s
        %subProb(j,t)=P(subS(t)=j| X(t)=obsData(j,t) & mixS(t)=i )
        subProb=subProb.*repmat(obsWeight(i,:),nSubObj,1);%scale by externally given weights
        %subProb(j,t)=P(mixS(t)=i & subS(t)=j| X(1:T)=obsData(:,1:T) )    
        aState(i).Gaussians=adaptAccum(pD(i).Gaussians,aState(i).Gaussians,obsData,subProb);
        aState(i).MixWeight=aState(i).MixWeight+sum(subProb,2);
    end;
end;



