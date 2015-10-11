%[pD,iOK]=init(pD,x);
%initializes GaussD object or array of GaussD objects
%to conform with a set of given observed vectors.
%The agreement is very crude, and should be refined by training,
%using methods adaptStart, adaptAccum, and adaptSet.
%
%*****REQUIRES: VQ class ********
%
%Input:
%pD=    a single GaussD object or multidim array of GaussD objects
%x=     matrix with observed vectors stored columnwise
%
%Result:
%pD=    initialized GaussD object or multidim GaussD array
%       size(pD)== same as input
%iOK=   logical array with element== 1, where corresponding
%       pD element was properly initialized,
%       and ==0, if there was not enough data for good initialization.
%
%Method:
%For a single GaussD object: set Mean and Variance, based on all observations,
%       Previous AllowCorr property is preserved,
%       but only diagonal covariance values are initialized,
%       because there may not be enough data to set complete cov matrix.
%For a GaussD array: each element initialized to observation sub-set.
%       Use crude VQ initialization:
%       set Mean vectors at VQ cluster centers,
%       and set Variance to variance within each VQ cell.
%  
%Arne Leijon 2006-04-21 tested
%           2008-10-09, var() change for compatibility with Matlab v.6.5
%           2009-07-20, changed for Matlab R2008a class definitions
%           2011-05-26, minor cleanup

function [pD,iOK]=init(pD,x)
nObj=numel(pD);
iOK=zeros(size(pD));%space for success indicators
%dSize=size(x,1);
if nObj>size(x,2)
    error('Too few data vectors');end;
if size(x,2)==1%var cannot be estimated
    warning('GaussD:Init:TooFewData','Only one data point: default variance =1');
    varX=ones(size(x));%default variance =1
    iOK(1)=0;%variance incorrect
else
%    varX=var(x,1,2);%ML (biased) estim var of all observed data
    varX=var(x,1,2);%ML (biased) estim var of all observed data
    iOK(1)=1;%OK
end;
if nObj==1
    pD.Mean=mean(x,2);
    if allowsCorr(pD)%set Covariance, to still allow correlations
        pD.Covariance=diag(varX);
    else
        pD.Variance=varX;%set variance
    end;
else
%     SD=SD./nObj;%assuming evenly spread, maybe this is too small???
%     m=selectRandom(x,nObj);
%This method often worked OK, but sometimes very odd start
%
%Use VQ methods instead,
%although first test with VQ method locked on a local maximum.
    xVQ=create(VQ,x,nObj);%make VQ
    xCenters=xVQ.CodeBook;%VQ centroids
    xCode=encode(xVQ,x);%nearest codebook index for each vector
    for i=1:nObj
        nData=sum(xCode==i);%usable observations for this cluster
        if nData<=1%actually ==1: VQ cannot give zero data points
            warning('GaussD:Init:TooFewData',['Too few data for GaussD no.',num2str(i)]);
            iOK(i)=0;%variance incorrect
            %simply use previous (first=total) varX value again
        else
%            varX=var(x(:,xCode==i),1,2);%variance of VQ sub-cluster
            varX=var(x(:,xCode==i),1,2);%variance of VQ sub-cluster
            iOK(i)=1;%OK
        end;
        %use only diag variances, because there may not be enough data to
        %estimate all correlations, and cov matrix might become singular
        pD(i).Mean=xCenters(:,i);
        if allowsCorr(pD(i))
            pD(i).Covariance=diag(varX);%full cov
        else
            pD(i).Variance=varX;%diag cov
        end;
    end;
%Another attempt to use random initialization and rely on later EM training.
%This is much slower than VQ init, 
%but sometimes found correct global maximum, when the VQ did not!
%Arne Leijon, 2004-11-18
%
%For this method, we just throw out some random points near global mean point: 
%     SD=SD./2;%???????
%     xCenter=mean(x,2);
%     xCenters=rand(GaussD(xCenter,SD),nObj);%random points near center
%     for i=1:nObj
%         pD(i)=set(pD(i),'Mean',xCenters(:,i),'StDev',SD);
%     end;
end;

% function r=selectRandom(x,n);
% nx=size(x,2);
% nr=round([1:n]*nx./n);
% r=x(:,nr);