classdef (Abstract) mceliece_code
    %MCELIECE_CODE Abstact class for codes for McEliece cryptosystem 
    %[K N] = OBJ.GET_PARAMS() Returns message length K and code length N
    %Y = OBJ.ENCODE(X) Encoding function
    %X = OBJ.DECODE(Y) Decoding function
   
    methods (Abstract)
        y = encode(obj,x)
        [k n] = get_params()      
        x = decode(obj,y)
        
    end
end

