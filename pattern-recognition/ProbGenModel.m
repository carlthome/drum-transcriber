%ProbGenModel - abstract superclass for
%Probabilistic Generative Models,
%including HMM, and various Random-Variable Distribution Classes.
%
%Generative models (as opposed to Discriminative models)
%can generate random data, i.e. they must have a rand method,
%and they can calculate the probability of observed data, given the model.
%
%Arne Leijon, 2009-07-23
%           2011-05-25, generalized prob method

classdef ProbGenModel
    methods (Access=public,Abstract)% MUST be implemented by subclasses
        X=rand(pM,nX);%     generate nX random samples X from the model pM.
        lP=logprob(pM,x);%  log probability of observed data sequence x
        %       either for complete data sequence x,
        %       or for each element in the sequence x,
        %       depending on subclass implementation.
        %
        %***** Low-level training Methods:
        %   These methods allow very large amounts of training data,
        %   perhaps too large be stored in a single data set.
        aState=adaptStart(pM);% initialize accumulator data structure for training
        aState=adaptAccum(pM,aState,obsData);%  Collect sufficient statistics
        %       without changing the object itself).
        %       To be called repeatedly with different data subsets).
        %       The aState result from adaptAccum must be stored externally,
        %       if training is to be continued later, with new data.
        pM=adaptSet(pM,aState);%    finally adjust the object using accumulated data.
    end
    methods (Access=public)
        function [p,logS]=prob(pD,x)
            %Default prob method, if not re-defined by subclass.
            %Calculates probability of each element in observed data sequence
            %Input:
            %pD=    ProbGenModel object, or array of such objects
            %x=     row vector with observed scalar values, or
            %       matrix with observed vectors, stored columnwise
            %Result:
            %p=     probability of observed x data, given each object
            %       size(p)== [numel(pD), size(x,2)]
            %logS=  log scale factor(s)
            %       if numel(pD)==1, logS is scalar, such that the true probability density is
            %       pX= p*exp(logS)
            %       if numel(pD)>1, size(logS)==[1,size(x,2)], and
            %       pX(k,t)= p(k,t)*exp(logS(t))
            %
            %Arne Leijon, 2011-05-25
            %allow different scale factors for different observations,
            %which is necessary to handle very small probability density values.
            
            logP=logprob(pD,x);%size(logP)==[numel(pD),size(x,2)]
            logS=max(logP);
            %if numel(pD)==1, logS is scalar, otherwise size(logS)==[1,nx];
            %logS might be -Inf or +Inf at some places
            logP=bsxfun(@minus,logP,logS);%=logP-logS; expanded to matching size
            %logP(k,t) may be NaN for some k, if logS(t)==-Inf, or logS(t)==+Inf
            logP(isnan(logP(:)))=0;%corrected
            %Allow f to be used externally without checking if logS==-Inf
            if size(logP,1)==1% nObj==1; logS is scalar
                if logS==-Inf
                    p=zeros(size(logP));
                else
                    p=exp(logP);
                end
            else%nObj>1; logS is row vector
                p=exp(logP);%f(:,t)==1, if logS(t)==-Inf; should be corrected:
                p(:,logS==-Inf)=0;
            end;
        end
    end
end
