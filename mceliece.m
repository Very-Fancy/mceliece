classdef mceliece
    %MCELIECE Class implements McEliece cryptosystem
    
    properties (Access = private)
        base_code mceliece_code = mdpc
        t int32
    end
    
    methods 
        function obj = mceliece(code_type, t, params)
            %MCELIECE Construct an instance of this class
            %   OBJ = MCELIECE(CODE_TYPE, T, PARAMS) Creates cryptosystem 
            %   based on specified codes class. 
            %
            %   CODE_TYPE:  0 - MDPC-codes (default [n_0 = 2 p = 137 w =14])
            %
            %   PARAMS:  code parameters; for MDPC: [n0 p w]
            %
            %   T:  default weight of error vector
            if nargin < 1 || isempty(code_type)
                code_type = 0;
            end
            if nargin < 2 || isempty(t)
                t = 3;
            end
            
            obj.t = t;
            
            if code_type ~= 0
                me = MException('MCELIECE:wrongParam','Code type is wrong, only 0 (MDPC) is supported');
                me.throw;
            end
            switch code_type
                case 0
                    if nargin<3 || isempty(params)
                        obj.base_code = mdpc();
                    else
                        if params(1) ~= 2
                            me = MException('MCELIECE:wrongParam','Code parameter n0 (param(1)) must be 2');
                            me.throw;
                        else
                            obj.base_code = mdpc(params);
                        end
                    end
            end 
            
            [k n] = obj.get_params();
            disp(sprintf('\nMcEliece system %s-based\nMessage length %d\nEncrypted text length %d\n',...
                class(obj.base_code), k,n));
        end
        
        function x = encrypt(obj,m, t)
            %X = ENCRYPT(M, T) Message encryption
            %   M:  message (length in accordance with code parameter K from
            %   OBJ.GET_PARAMS)
            %
            %   T:  number of errors for error vector (uses default OBJ.T if not
            %   set)
            
            if nargin<3 || isempty(t)
                t = obj.t;
            end
            
            cw = obj.base_code.encode(m);
            [~, n] = obj.get_params();
            e = [-ones(1,t) ones(1,n-t)];
            x = ((-1).^cw).*e;
            x = 0.5*(sign(x) + 1);
        end
        
        function y = decrypt(obj,x)
            %Y = DECRYPT(X) Message decryption
            %  
            
            y = obj.base_code.decode(x);
        end
        
        function [ k,n] = get_params(obj)
            [k,n] = obj.base_code.get_params();
        end
    end
end

