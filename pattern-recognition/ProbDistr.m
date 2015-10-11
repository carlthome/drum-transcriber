%ProbDistr - abstract superclass for Random-Variable Classes,
%that can be used as HMM output distributions or MixtureD components.
%
%Arne Leijon,   2009-07-23

classdef ProbDistr < ProbGenModel
    properties(Dependent,Abstract)%MUST be implemented by subclasses
        DataSize;%length of random (column) vectors, modelled by a ProbDistr object
        %tested by HMM and MixtureD constructors, because
        %ProbDistr arrays for these purposes must have equal DataSize across elements.
    end
    %subclasses should also implement, either as properties or methods:
    %Mean;
    %Variance;
    %----------------------------------------------------------------
    methods(Access=public,Abstract)%MUST be implemented by subclasses
        [pD,iOK]=init(pD,x);%initialize crudely to conform with given data        
        aState=adaptStart(pD);% initialize accumulator data structure for training
        aState=adaptAccum(pD,aState,obsData);%  Collect sufficient statistics
        %       without changing the object itself).
        %       To be called repeatedly with different data subsets).
        %       The aState result from adaptAccum must be stored externally,
        %       if training is to be continued later, with new data.
        pD=adaptSet(pD,aState);%    finally adjust the object using accumulated data.
    end
end