%pD=adaptSet(pD,aState)
%method to finally adapt a GaussD object
%using accumulated statistics from observed data.
%
%Input:
%pD=        GaussD object or array of GaussD objects
%aState=    accumulated statistics from previous calls of adaptAccum
%
%Result:
%pD=        adapted version of the GaussD object
%
%Theory and Method:    
%From observed sample data X(n), n=1....N, we are using the deviations
%           Z(n)=X(n)-myOld, where myOld is the old mean.
%Obviously, E[Z(n)]= E[X(n)]-myOld, and cov[Z(n)]=cov[X(n)]
%
%We have accumulated weighted deviations:
%sumDev=    sum[w(n).*Z(n)]
%sumSqDev=  sum[w(n).* (Z(n)*Z(n)')]
%sumWeight= sum[w(n)]
%
%Here, weight factor w(n) is the probability that the observation X(n)
%           was actually drawn from this GaussD.
%
%To obtain a new unbiased estimate of the GaussD true MEAN, we see that
%           E[sumDev]=sum[w(n)] .*E[Z(n)].
%Thus, an unbiased estimate of the MEAN is
%newMean=   myOld + sumDev/sumWeight;
%
%To obtain a new estimate of the GaussD covariance,
%           we first calculate sq deviations from the new sample MEAN, as:
%           Y(n)= Z(n) - sumDev/sumWeight
%           S2= sum[w(n).* (Y(n)*Y(n)')]=
%             = sumSqDev - sumDev*sumDev'./sumWeight
%The ML estimate of the variance is then
%           covEstim= S2./sumWeight;
%           (If all w(n)=1, this is the usual newVarML=S2/N)
%
%However, this UNDERESTIMATES the GaussD true VARIANCE, as
%           E[S2]= var[Z(n)] .* (sumWeight - sumSqWeight/sumWeight)
%Therefore, an unbiased variance estimate would be, instead,
%newVar=    S2/(sumWeight - sumSqWeight/sumWeight)
%           (If all w(n)=1, this is the usual estimate newVar= S2/(N-1) )
%However, the purpose of the GaussD training is usually not to estimate 
%the covariance parameter in isolation,
%but rather to make the total density function fit the training data. 
%For this purpose, the ML mean and covariance are indeed optimal.
%
%Arne Leijon 2005-11-16 tested
%Arne Leijon 2010-07-30,    corrected for degenerate case with only one data point
%                           In this case, we just set StDev=Inf,
%                           to effectively kill the affected GaussD object.

function pD=adaptSet(pD,aState)
for i=1:numel(pD)%for all GaussD objects
    if aState(i).sumWeight>max(eps(pD(i).Mean))%We had at least some data
        pD(i).Mean=pD(i).Mean+ aState(i).sumDev/aState(i).sumWeight;%new mean value
        
        S2=aState(i).sumSqDev-(aState(i).sumDev*aState(i).sumDev')./aState(i).sumWeight;%sqsum around new mean
        covEstim=S2./aState(i).sumWeight;%ML covariance estimate
        if any(diag(covEstim)<eps(pD(i).Mean))%near zero, or negative
            warning('GaussD:ZeroVar',['Not enough data for GaussD #',num2str(i),'. StDev forced to Inf']);
            covEstim=diag(repmat(Inf,size(pD(i).Mean)));
            %Force ZERO probability for this GaussD, for any data
        end;
        
        if allowsCorr(pD(i))
            pD(i)=setCov(pD(i),covEstim);%adapt full covariance matrix
        else
            pD(i).StDev=sqrt(diag(covEstim));%keep it diagonal
        end;
    end;%else no observations here, do nothing
end;