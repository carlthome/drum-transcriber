%DataHandle - handle class to contain any Data structure
%to be referenced via a handle

classdef DataHandle < handle
    properties (GetAccess='public',SetAccess='public')
        Data=[];%   whatever data
    end
    methods (Access='public')
        function hG=DataHandle(varargin)
            switch nargin
                case 0;%default empty data
                case 1
                    hG.Data=varargin{1};
                otherwise
                    error('Too many arguments');
            end
        end
    end
 end