classdef VQ
%VQ - class representing a Vector Quantizer.
%Continuous-valued vectors to be quantized are given columnwise, in a matrix.
%
%Usage Examples:
%vq=VQ(codebook);%construct a VQ object from a given CodeBook
%vq=create(VQ,x,10);%initialize and train a VQ object to given data
%vq=init(VQ,x,Ncodes);%initialize a VQ object for training vectors x.
%vq=trainLloyd(vq,x);%train a given vq object by generalized Lloyd algorithm
%iy=encode(vq,y);%encode each column vector of a given matrix y to row vector of integer code-index 
%z=decode(vq,iy);%reconstruct vectors encoded as index vector iy
%
%Arne Leijon 2009-07-19
%            2010-11-21 (?) single-file class definition
%Gustav Eje Henter 2011-12-06 switched to k-means++ init

    properties(Access=public)
        CodeBook=[];%   set of vector centroids used for quantization
        %               stored column-wise
    end
    methods (Access='public')
        %---------------------------- Initializing and training methods:
        function vq = VQ(cb)
            %vq=VQ(cb); Constructor method for Vector Quantizer (VQ) object
            %***Usage:
            %vq = VQ;
            %   creates a single empty vector quantizer.
            %vq = VQ(vq);
            %   just copies the given object.
            %vq = VQ(codebook)
            %   creates a VQ object from given CodeBook matrix
            switch nargin
                case 0%default empty codebook
                case 1
                    if isa(cb,'VQ')
                        vq=cb;%just copy it
                    else
                        vq.CodeBook=cb;%it must be the Codebook
                    end;
                otherwise
                    error('Too many arguments');
            end;%switch
        end
        %--------------------------
        function C=oldInit(C,X,Ncodes)% initialize Vector Quantizer
            %Input:
            %C=     the VQ object
            %X=     matrix with training vectors, stored columnwise
            %Ncodes=desired size of codebook
            %       Ncodes is forced to be <= size(X,2)
            %
            %Result:
            %C= 	new VQ object, adapted for X
            %
            %Arne Leijon 2009-07-19           
            nX=size(X,2);
            if(Ncodes>nX)
                warning('VQ:ReducedCodeBook',['CodeBook size reduced to ',num2str(nX)]);
                Ncodes=nX;
            end;        
            iC=round((1:Ncodes)*nX/Ncodes);%uniformly selected code vectors
            C.CodeBook=X(:,iC);
        end;
       function C=init(C,X,Ncodes)% initialize Vector Quantizer using k-means++
            %Input:
            %C=     the VQ object
            %X=     matrix with training vectors, stored columnwise
            %Ncodes=desired size of codebook
            %       Ncodes is forced to be <= size(X,2)
            %
            %Result:
            %C= 	new VQ object, initialized for X using k-means++, not trained
            %
            %Gustav Eje Henter 2011-12-06 tested
            nX=size(X,2);
            if(Ncodes>=nX)
                if(Ncodes>nX)
                    warning('VQ:ReducedCodeBook',['CodeBook size reduced to ',num2str(nX)]);
                    Ncodes=nX;
                end
                C.CodeBook=X; %put all datapoints in codebook
            end;
            C.CodeBook = zeros(size(X,1),Ncodes);%allocate space for codebook
            C.CodeBook(:,1) = X(:,randi(nX));%pick an initial datapoint at random
            getDist = inline('mean((X - repmat(Xref,1,size(X,2))).^2,1)','Xref','X');
            squareDists = getDist(C.CodeBook(:,1),X);%compute square distance to inital pt
            for n = 2:Ncodes,
                pD = DiscreteD(squareDists);
                iCnew = pD.rand(1);%pick new random center based on square distance
                C.CodeBook(:,n) = X(:,iCnew);%add new center to codebook
                squareDists = min(squareDists,getDist(C.CodeBook(:,n),X));%update distances
            end
        end;
        %-------------------------------------------
        function [vq,varC]=trainLloyd(vq,X, callFcn)% train Vector Quantizer for given vectors
            %for minimum Euclidean square-sum distortion.
            %The vq must be previously suitably initialized,
            %e.g. by a call to method init.
            %
            %Input:
            %vq=    a VQ object, possibly empty
            %X=     matrix with training vectors, stored column-wise
            %callFcn=   (optional) function to be called after each iteration
            %           with syntax callFcn(vq)
            %
            %Result:
            %vq=    new VQ object, adapted to given training data.
            %varC=  square deviations for each VQ cluster center
            %       size(varC)==size(C.CodeBook)
            %
            %Normally, size of CodeBook is unchanged by training, BUT
            %   CodeBook may be reduced during training, if a cluster is empty.
            %
            %Method: Generalized Lloyd algorithm
            %
            %Arne Leijon 2006-04-03 tested
            %            2010-11-19, added callback function  
            if size(vq.CodeBook,1)~=size(X,1)
                error('Incompatible vector length');
            end;
            initialCodeBookSize=size(vq.CodeBook,2);
            if initialCodeBookSize> size(X,2)/2
                warning('VQ:InsufficientData','Too few training vectors -- result may be inaccurate');
            end;
            iX=encode(vq,X);%initial encoding
            iXprevious=zeros(size(iX));%nonsense, just for start
            while any(iX~=iXprevious)%do new round of Lloyd algorithm
                %iXwrong=sum(iX~=iXprevious%for testing
                wstate=warning;
                warning off;%because we check div by 0 later
                for n=1:size(vq.CodeBook,2)
                    vq.CodeBook(:,n)=mean(X(:,iX==n),2);%modified codebook entry
                    %		vq.CodeBook(:,n)==NaN, if there were no training vectors
                end;
                vq.CodeBook=vq.CodeBook(:,isfinite(vq.CodeBook(1,:)));%remove NaN code vectors
                warning(wstate);%restore
                iXprevious=iX;%remember previous encoding
                iX=encode(vq,X);%encoding with new codebook
                if nargin>2 && ~isempty(callFcn)
                    callFcn(vq);%call-back, i.e., for plot during training
                end;
            end;%no more improvement possible
            if size(vq.CodeBook,2)<initialCodeBookSize
                warning('VQ:RemovedCode','CodeBook has been reduced during training');end;
            %
            varC=zeros(size(vq.CodeBook));%mean square deviations from cluster centres
            for n=1:size(vq.CodeBook,2)
                d=X(:,iX==n)-repmat(vq.CodeBook(:,n),1,sum(iX==n));
                varC(:,n)=mean(d.*d,2);
            end;
        end
        %-------------------------------------
        function [vq,varC]=create(vq,X,Ncodes)% initialize and optimize a VQ object
            vq=init(vq,X,Ncodes);%create a random codebook of the right size
            [vq,varC]=trainLloyd(vq,X);%and train it using same data
        end
        %
        %**************************************************************** VQ usage methods:
        %
        function iX=encode(vq,X)% encode cont.valued vectors by discrete (integer) codes
            %Input:
            %vq=    VQ object, or array of such objects
            %X=     matrix with input data vectors, stored columnwise.
            %Result:
            %iX=    row vector with index of nearest codebook point, for each vector
            %       size(iX)== [1,size(X,2)]
            %
            %Arne Leijon 2006-03-31 tested
            %           2008-01-28 small bugfix for 1-Dim data
            
            if numel(vq)>1
                error('Method works only for single object');end;
            nX=size(X,2);
            C=vq.CodeBook;
            dist=repmat((sum(C.*C,1))',1,nX)-2*C'*X;%to be minimized among C entries
            [~,iX]=min(dist);
        end
        %-----------------------
        function X=decode(vq,iX)% recreate cont.valued vectors from discrete (integer) codes
            %Input:
            %vq=    the vq object
            %iX=    row vector with code indices
            %
            %Result:
            %X= corresponding output data vectors.
            %
            %Arne Leijon 2006-03-31 tested
            if numel(vq)>1
                error('Method works only for single object');end;
            if any(iX<1) || any(iX)> size(vq.CodeBook,2)
                error('Non-existent code value');
            else
                X=vq.CodeBook(:,iX);%just look up VQ cluster centres
            end;
        end
        %---------------------
        function cb=double(vq)% convert codebook back to matrix (or cell array of matrices)
            %Result:
            %If single VQ object:
            %cb=    VQ codebook,
            %       size(cb)=[vector length, number of codevectors]
            %if array of VQ objects:
            %cb=    cell array with VQ codebooks
            %       size(cb)=size(vq)
            %
            %Arne Leijon 2006-03-31 tested
            sizObj=size(vq);
            nObj=numel(vq);
            if nObj==1
                cb=vq.CodeBook;
            else
                cb=cell(sizObj);
                for i=1:nObj
                    cb{i}=vq(i).CodeBook;
                end;
            end;
        end
    end
end
