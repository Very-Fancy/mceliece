classdef (Abstract) mceliece_code
    %MCELIECE_CODE Abstact class for codes for McEliece cryptosystem 
    %   encode
    %   decode
    %   get_params
    
    methods (Abstract)
        y = encode(obj,x)
        [k n] = get_params()
        x = decode(obj,y)

    end
end

