classdef mceliece
    %MCELIECE Implementation of McEliece cryptosystem variants
    %   base_code implements mceliece_code class
    
    properties (Access = private)
        base_code mceliece_code = mdpc
        t int32
    end
    
    methods 
        function obj = mceliece(code_type, t, params)
            %MCELIECE Construct an instance of this class
            %   mceliece cryptosystem based on: 
            %   mdpc (code_type = 0, params = [n r w] default [2 137 14])
            %
            %   t - default weight of error vector
            if nargin < 1 || isempty(code_type)
                code_type = 0;
            end
            if nargin < 2 || isempty(t)
                t = 4;
            end
            
            obj.t = t;
            
            switch code_type
                case 0
                    if nargin<3 || isempty(params)
                        obj.base_code = mdpc();
                    else
                        obj.base_code = mdpc(params);
                    end
            end 
            [k n] = obj.get_params();
            disp(sprintf('McEliece system %s-based\nMessage length %d\nEncrypted text length %d',...
                class(obj.base_code), k,n));
        end
        
        function x = encrypt(obj,m, t)
            %ENCRYPT Message encryption
            %   m - message (length in accordance with code parameters(
            %   t - number of errors for error vector (uses default if not
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
            %DECRYPT Message decryption
            %              
            y = obj.base_code.decode(x);
        end
        
        function [ k,n] = get_params(obj)
            [k,n] = obj.base_code.get_params();
        end
    end
end

